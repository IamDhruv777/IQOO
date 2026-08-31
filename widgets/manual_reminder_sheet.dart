import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/memory.dart';
import '../models/memory_date.dart';
import '../providers/memory_provider.dart';
import '../services/notification_service.dart';
import '../services/image_service.dart';
import '../theme/app_theme.dart';

class ManualReminderSheet extends ConsumerStatefulWidget {
  final File? imageFile;

  const ManualReminderSheet({super.key, this.imageFile});

  @override
  ConsumerState<ManualReminderSheet> createState() =>
      _ManualReminderSheetState();
}

class _ManualReminderSheetState extends ConsumerState<ManualReminderSheet> {
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _currentImage;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.imageFile;
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _pickImage() async {
    final imageService = ImageService();
    final xFile = await imageService.pickFromGallery();
    if (xFile != null) {
      final localPath = await imageService.saveImageLocally(xFile);
      if (mounted) setState(() => _currentImage = File(localPath));
    }
  }

  void _save() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a description')));
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and time')));
      return;
    }

    final reminderDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final memory = Memory(
      id: const Uuid().v4(),
      imagePath: _currentImage?.path ?? '', // Empty string if text-only
      title: 'Manual Reminder',
      summary: _descController.text.trim(),
      category: 'notice', // Using notice category to distinguish it
      createdAt: DateTime.now(),
      dates: [
        MemoryDate(type: 'deadline', value: reminderDateTime),
      ],
      extractedText: '', // No AI extraction for manual
    );

    await ref.read(memoriesProvider.notifier).addMemory(memory);
    await NotificationService().scheduleReminder(memory, reminderDateTime);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reminder saved successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).extension<MemoryLensColors>()?.success ?? Colors.green,
          ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mlColors = Theme.of(context).extension<MemoryLensColors>()!;
    
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set Reminder',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mlColors.textPrimary)),
          const SizedBox(height: 16),
          if (_currentImage != null) ...[
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _currentImage!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton.filled(
                    onPressed: () => setState(() => _currentImage = null),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _descController,
            autofocus: _currentImage == null,
            decoration: InputDecoration(
              labelText: 'What do you need to remember?',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: _currentImage == null
                  ? IconButton(
                      icon: Icon(Icons.add_photo_alternate_outlined, color: mlColors.primary),
                      onPressed: _pickImage,
                      tooltip: 'Add Image',
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(_selectedDate == null
                      ? 'Date'
                      : '\${_selectedDate!.day}/\${_selectedDate!.month}/\${_selectedDate!.year}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time, size: 18),
                  label: Text(_selectedTime == null
                      ? 'Time'
                      : _selectedTime!.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save Reminder'),
            ),
          ),
        ],
      ),
    );
  }
}
