import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'sign_in_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToSignIn() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SignInScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mlColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: _AnimatedBackground(currentPage: _currentPage, colors: colors),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(colors),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: const [
                      _PageOne(),
                      _PageTwo(),
                      _PageThree(),
                      _PageFour(),
                      _PageFive(),
                    ],
                  ),
                ),
                if (_currentPage < 4)
                  _buildBottomControls(colors)
                else
                  const SizedBox(height: 80), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(MemoryLensColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt, color: colors.primary, size: 28),
              const SizedBox(width: 8),
              Text(
                'MemoryLens',
                style: GoogleFonts.yellowtail(
                  fontSize: 28,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          if (_currentPage < 4)
            TextButton(
              onPressed: _navigateToSignIn,
              child: Text(
                'Skip',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(MemoryLensColors colors) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 32 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? colors.primary
                      : colors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.surface,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              elevation: 8,
              shadowColor: colors.primary.withValues(alpha: 0.5),
            ),
            child: const Icon(Icons.arrow_forward, size: 24),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackground extends StatefulWidget {
  final int currentPage;
  final MemoryLensColors colors;

  const _AnimatedBackground({required this.currentPage, required this.colors});

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(
            colors: widget.colors,
            isDark: isDark,
            page: widget.currentPage.toDouble(),
            animValue: _animController.value,
          ),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final MemoryLensColors colors;
  final bool isDark;
  final double page;
  final double animValue;

  _BackgroundPainter({required this.colors, required this.isDark, required this.page, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double opacity = isDark ? 0.35 : 0.25;
    
    final p1 = Paint()
      ..color = colors.primary.withValues(alpha: opacity)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
      
    final p2 = Paint()
      ..color = colors.accent.withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
      
    final p3 = Paint()
      ..color = const Color(0xFFF28888).withValues(alpha: opacity * 0.6) // Terracotta/Peach
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);

    final offset = sin(animValue * pi) * 30;

    // Shift positions slightly based on the page
    final dx1 = size.width * (0.2 + (page * 0.1));
    final dy1 = size.height * (0.2 + (page * 0.05));
    
    final dx2 = size.width * (0.8 - (page * 0.1));
    final dy2 = size.height * (0.7 - (page * 0.05));

    canvas.drawCircle(Offset(dx1 + offset, dy1 - offset), 220, p1);
    canvas.drawCircle(Offset(dx2 - offset, dy2 + offset), 250, p2);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.9), 180, p3);

    // Large floating rings
    final ring = Paint()
      ..color = colors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 300 + (page * 20), ring);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 450 + (page * 20), ring..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PageOne extends StatefulWidget {
  const _PageOne();
  @override
  State<_PageOne> createState() => _PageOneState();
}

class _PageOneState extends State<_PageOne> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _textIndex = 0;
  Timer? _timer;

  final List<String> _subtexts = [
    '"I\'ll remember this."',
    '"I\'ll save this for later."',
    '"Let me just take a photo."'
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          _textIndex = (_textIndex + 1) % _subtexts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mlColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Life is full of things we mean to remember.',
            style: GoogleFonts.manrope(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _subtexts[_textIndex],
              key: ValueKey<int>(_textIndex),
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colors.primary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '...and then completely forgot.',
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 56),
          SizedBox(
            height: 320,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final offset = sin(_animController.value * 2 * pi) * 6;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildBigCard(colors, -15, Offset(-70, -60 + offset), '📌 HACKATHON', 'Sep 5 Deadline', const Color(0xFF9D88F2), 0.9),
                    _buildBigCard(colors, 18, Offset(90, -40 - offset), '🧾 RECEIPT', '₹1,842', const Color(0xFFF28888), 0.85),
                    _buildBigCard(colors, -8, Offset(-80, 80 - offset), '📋 NOTICE', 'Library closed', const Color(0xFFF2D188), 1.0),
                    _buildBigCard(colors, 12, Offset(70, 70 + offset), '💼 CONTACT', 'John Doe', const Color(0xFF88F2A3), 1.1),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          Text(
            'Future you is going to ask where you saved that.',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildBigCard(MemoryLensColors colors, double rotationDeg, Offset offset, String title, String subtitle, Color iconColor, double scale) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: rotationDeg * pi / 180,
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: 180,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border, width: 2),
              boxShadow: [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageTwo extends StatefulWidget {
  const _PageTwo();
  @override
  State<_PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<_PageTwo> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  int _labelIndex = 0;
  Timer? _timer;
  final List<String> _labels = ['DATE ✓', 'LOCATION ✓', 'ACTION ✓'];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          if (_labelIndex < 3) {
            _labelIndex++;
          } else {
            _labelIndex = 0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mlColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'See something worth remembering?',
            style: GoogleFonts.manrope(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Point your camera at it.',
            style: GoogleFonts.manrope(
              fontSize: 20,
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 56),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Concentric lens rings
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 280, height: 280,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.primary.withValues(alpha: 0.2), width: 4)),
                        ),
                        Container(
                          width: 320, height: 320,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.primary.withValues(alpha: 0.1), width: 2)),
                        ),
                      ],
                    );
                  }
                ),
                Container(
                  width: 260,
                  height: 360,
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: colors.primary, width: 6),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'AI HACKATHON 2026',
                                style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 20, color: colors.textPrimary),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Registration: Sep 5',
                                style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16, color: colors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Main Auditorium',
                                style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16, color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _scanController,
                        builder: (context, child) {
                          return Positioned(
                            top: _scanController.value * 360,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: colors.accent,
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.accent,
                                    blurRadius: 20,
                                    spreadRadius: 8,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                ..._buildCorners(colors),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedOpacity(
                  opacity: _labelIndex > index ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.success.withValues(alpha: 0.8), width: 2),
                    ),
                    child: Text(
                      _labels[index],
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: colors.success,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Spacer(),
          Text(
            'Take the photo. Forget the details.',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  List<Widget> _buildCorners(MemoryLensColors colors) {
    final positions = [
      const Offset(-12, -12),
      const Offset(260 - 12, -12),
      const Offset(-12, 360 - 12),
      const Offset(260 - 12, 360 - 12),
    ];
    return positions.map((pos) => Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.primary, width: 4),
        ),
      ),
    )).toList();
  }
}

class _PageThree extends StatefulWidget {
  const _PageThree();
  @override
  State<_PageThree> createState() => _PageThreeState();
}

class _PageThreeState extends State<_PageThree> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mlColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your photo becomes a memory.',
            style: GoogleFonts.manrope(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Not just pixels. Context.',
            style: GoogleFonts.manrope(
              fontSize: 20,
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 64),
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(300, 200),
                    painter: _ConnectionLinePainter(colors: colors, progress: _controller.value),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 140,
                    height: 200,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.border, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, size: 64, color: colors.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Original Photo',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 160,
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedField(0.1, 0.3, '🧠 AI Hackathon', colors.textPrimary, true),
                        const SizedBox(height: 12),
                        _buildAnimatedField(0.3, 0.5, '📋 Event', colors.textSecondary, false),
                        const SizedBox(height: 12),
                        _buildAnimatedField(0.5, 0.7, '📅 Sep 5', colors.textSecondary, false),
                        const SizedBox(height: 12),
                        _buildAnimatedField(0.7, 0.9, '📍 Main Aud.', colors.textSecondary, false),
                        const SizedBox(height: 12),
                        _buildAnimatedField(0.8, 1.0, '✓ Register', colors.success, true),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            'The gallery stores pixels. MemoryLens stores meaning.',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildAnimatedField(double start, double end, String text, Color color, bool isBold) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(animation),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _ConnectionLinePainter extends CustomPainter {
  final MemoryLensColors colors;
  final double progress;

  _ConnectionLinePainter({required this.colors, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = colors.accent.withValues(alpha: 0.6 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    path.moveTo(size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.5, 
      size.height * 0.2, 
      size.width * 0.5 + (size.width * 0.1 * progress), 
      size.height * 0.5
    );

    // Draw partial path based on progress
    final metric = path.computeMetrics().first;
    final extractPath = metric.extractPath(0, metric.length * progress);
    
    canvas.drawPath(extractPath, paint);
    
    // Draw glowing head
    if (progress > 0) {
      final pos = metric.getTangentForOffset(metric.length * progress)?.position;
      if (pos != null) {
        canvas.drawCircle(pos, 6, Paint()..color = colors.accent..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
        canvas.drawCircle(pos, 3, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PageFour extends StatefulWidget {
  const _PageFour();
  @override
  State<_PageFour> createState() => _PageFourState();
}

class _PageFourState extends State<_PageFour> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mlColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Now forget about it.',
            style: GoogleFonts.manrope(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Seriously. We\'ve got it.',
            style: GoogleFonts.manrope(
              fontSize: 20,
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 64),
          
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _build3DVaultCard(colors, -30, 0.7, -40, 'Electricity Bill'),
                _build3DVaultCard(colors, -15, 0.85, -20, 'Zomato Internship'),
                _build3DVaultCard(colors, 0, 1.0, 0, 'Hackathon 2026'),
              ],
            ),
          ),
          const SizedBox(height: 48),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimelinePill(colors, 'MON'),
              _buildTimelineDottedLine(colors),
              _buildTimelinePill(colors, 'WED'),
              _buildTimelineDottedLine(colors),
              _buildTimelinePill(colors, 'FRI'),
            ],
          ),
          const SizedBox(height: 32),

          SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
              CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack)
            ),
            child: FadeTransition(
              opacity: _slideController,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.4 + 0.6 * _pulseController.value),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.2 * _pulseController.value),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_active, color: colors.primary, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registration closes tomorrow!',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'AI Hackathon 2026',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          const Spacer(),
          Text(
            'Capture now. Panic less later.',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _build3DVaultCard(MemoryLensColors colors, double rotationXDeg, double scale, double yOffset, String text) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002) // extreme perspective
        ..translate(0.0, yOffset, 0.0)
        ..rotateX(rotationXDeg * pi / 180)
        ..scale(scale),
      alignment: FractionalOffset.center,
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelinePill(MemoryLensColors colors, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTimelineDottedLine(MemoryLensColors colors) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomPaint(
        painter: _DottedLinePainter(color: colors.border),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    double dashWidth = 6, dashSpace = 6, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PageFive extends StatelessWidget {
  const _PageFive();

  @override
  Widget build(BuildContext context) {
    final colors = context.mlColors;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(Icons.camera_alt, color: colors.primary, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      'MemoryLens',
                      style: GoogleFonts.yellowtail(
                        fontSize: 48,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              Text(
                'Your brain has\nbetter things to do.',
                style: GoogleFonts.manrope(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: colors.textPrimary,
                  height: 1.1,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Let your phone remember.',
                style: GoogleFonts.yellowtail(
                  fontSize: 32,
                  color: colors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Because "I\'ll remember this" is historically unreliable.',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const SignInScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(position: animation.drive(tween), child: child);
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  shadowColor: colors.primary.withValues(alpha: 0.5),
                ),
                child: Text(
                  'Get Started →',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: GoogleFonts.manrope(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const SignInScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(position: animation.drive(tween), child: child);
                          },
                        ),
                      );
                    },
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.manrope(
                        color: colors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
