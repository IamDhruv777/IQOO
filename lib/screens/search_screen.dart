import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:io';
import '../models/memory.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/memory_card.dart';
import '../utils/date_utils.dart';
import '../theme/app_theme.dart';
import 'memory_details_screen.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _speech = stt.SpeechToText();
  bool _isListening = false;

  List<Memory> _results = [];
  String? _aiAnswer;
  bool _loading = false;
  bool _searched = false;
  bool _isFallback = false;
  String _lastQuery = '';

  static const _suggestions = [
    'What deadlines are coming up?',
    'What internships did I save?',
    'What was that event near the library?',
    'What do I know about the hackathon?',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _controller.text = widget.initialQuery!;
        _search(widget.initialQuery!);
      } else {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _aiAnswer = null;
        _searched = false;
      });
      return;
    }
    if (query == _lastQuery) return;
    _lastQuery = query;
    setState(() => _loading = true);

    try {
      final allMemories = await DatabaseService().getAllMemories();
      final aiResult = await AiService().rankMemoriesForQuery(query, allMemories);

      List<Memory> results = [];
      String? answer;

      if (aiResult != null && aiResult.rankedIds.isNotEmpty) {
        final idToMemory = {for (final m in allMemories) m.id: m};
        results = aiResult.rankedIds
            .where((id) => idToMemory.containsKey(id))
            .map((id) => idToMemory[id]!)
            .toList();
        answer = aiResult.answer;
      } else {
        results = await DatabaseService().keywordSearch(query);
        if (aiResult != null && aiResult.answer.isNotEmpty) {
           answer = aiResult.answer;
        }
      }

      if (mounted) {
        setState(() {
          _results = results;
          _aiAnswer = answer;
          _loading = false;
          _searched = true;
          _isFallback = false;
        });
      }
    } catch (_) {
      try {
        final fallback = await DatabaseService().keywordSearch(query);
        if (mounted) {
          setState(() {
            _results = fallback;
            _aiAnswer = null;
            _loading = false;
            _searched = true;
            _isFallback = true;
          });
        }
      } catch (__) {
        if (mounted) {
          setState(() {
            _results = [];
            _loading = false;
            _searched = true;
            _isFallback = true;
          });
        }
      }
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
            _search(_controller.text);
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mlColors = context.mlColors;
    final bool canPop = Navigator.canPop(context);
    
    return Scaffold(
      backgroundColor: mlColors.background,
      appBar: AppBar(
        backgroundColor: mlColors.background,
        elevation: 0,
        titleSpacing: canPop ? 0 : 16,
        leading: canPop
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: mlColors.icon),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Container(
          decoration: BoxDecoration(
            color: mlColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: mlColors.border),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(color: mlColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search your memories…',
              hintStyle: TextStyle(color: mlColors.textSecondary, fontSize: 15),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 20, color: mlColors.icon),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _searched = false;
                          _aiAnswer = null;
                        });
                        _focusNode.requestFocus();
                      },
                    ),
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none, 
                        color: _isListening ? mlColors.primary : mlColors.icon, size: 22),
                    onPressed: _listen,
                  ),
                ],
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: _search,
            onChanged: (v) => setState(() {}),
          ),
        ),
        actions: [
          if (_controller.text.trim().isNotEmpty)
            TextButton(
              onPressed: () => _search(_controller.text),
              child: Text('Search', style: TextStyle(color: mlColors.primary)),
            ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: mlColors.primary),
                    const SizedBox(height: 16),
                    Text('Searching with Gemini...',
                        style: TextStyle(color: mlColors.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Reasoning across your memories',
                        style: TextStyle(color: mlColors.textSecondary)),
                  ],
                ),
              )
            : !_searched
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What do you remember?',
                          style: GoogleFonts.manrope(
                            fontSize: 22, fontWeight: FontWeight.w800, color: mlColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ask in plain language — MemoryLens reasons\nacross everything you\'ve captured.',
                          style: GoogleFonts.manrope(fontSize: 13, color: mlColors.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'TRY ASKING',
                          style: GoogleFonts.manrope(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: mlColors.textSecondary, letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._suggestions.map((q) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              _controller.text = q;
                              _search(q);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: mlColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: mlColors.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded, size: 16, color: mlColors.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '"$q"',
                                      style: GoogleFonts.manrope(
                                        fontSize: 13, color: mlColors.textPrimary, fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: mlColors.icon),
                                ],
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isFallback)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: mlColors.warning.withValues(alpha: 0.1),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: mlColors.warning, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'AI search unavailable right now. Showing local keyword matches.',
                                  style: TextStyle(color: mlColors.warning, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_aiAnswer != null && _aiAnswer!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: mlColors.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: mlColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: mlColors.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'MemoryLens',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: mlColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _aiAnswer!,
                                style: TextStyle(
                                  color: mlColors.textPrimary,
                                  height: 1.5,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      if (_results.isNotEmpty && _aiAnswer != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 8),
                          child: Text(
                            'SOURCES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: mlColors.textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),

                      if (_results.isEmpty)
                        const Expanded(
                          child: EmptyStateWidget(
                            emoji: '🤔',
                            title: 'No memories found',
                            subtitle: 'Try adjusting your search terms.',
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              return MemoryCard(
                                memory: _results[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MemoryDetailsScreen(memory: _results[index]),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
