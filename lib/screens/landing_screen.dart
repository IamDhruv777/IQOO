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
      body: SafeArea(
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
              const SizedBox(height: 80), // Space for the big button on page 5
          ],
        ),
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
              Icon(Icons.camera_alt, color: colors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'MemoryLens',
                style: GoogleFonts.yellowtail(
                  fontSize: 24,
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
                  fontWeight: FontWeight.w600,
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
                width: _currentPage == index ? 24 : 8,
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
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.surface,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
            ),
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _subtexts[_textIndex],
              key: ValueKey<int>(_textIndex),
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colors.primary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '...and then completely forgot.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 240,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final offset = sin(_animController.value * 2 * pi) * 4;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildMiniCard(colors, -8, Offset(-60, -40 + offset), '📌 HACKATHON', 'Sep 5 Deadline', const Color(0xFF9D88F2)),
                    _buildMiniCard(colors, 6, Offset(70, -20 - offset), '🧾 RECEIPT', '₹1,842', const Color(0xFFF28888)),
                    _buildMiniCard(colors, 4, Offset(-50, 60 - offset), '💼 CONTACT', 'John Doe', const Color(0xFF88F2A3)),
                    _buildMiniCard(colors, -5, Offset(60, 50 + offset), '📋 NOTICE', 'Library closed', const Color(0xFFF2D188)),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          Text(
            'Future you is going to ask where you saved that.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildMiniCard(MemoryLensColors colors, double rotationDeg, Offset offset, String title, String subtitle, Color iconColor) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: rotationDeg * pi / 180,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Point your camera at it.',
            style: GoogleFonts.manrope(
              fontSize: 18,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 220,
                  height: 300,
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colors.primary, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'AI HACKATHON 2026',
                                style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 16, color: colors.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Registration: Sep 5',
                                style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 14, color: colors.textSecondary),
                              ),
                              Text(
                                'Main Auditorium',
                                style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 14, color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _scanController,
                        builder: (context, child) {
                          return Positioned(
                            top: _scanController.value * 300,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: colors.accent,
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.accent.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
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
                // Corner decorations
                ..._buildCorners(colors),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedOpacity(
                  opacity: _labelIndex > index ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.success.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      _labels[index],
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
      const Offset(-8, -8),
      const Offset(220 - 8, -8),
      const Offset(-8, 300 - 8),
      const Offset(220 - 8, 300 - 8),
    ];
    return positions.map((pos) => Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.primary, width: 2),
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
      duration: const Duration(milliseconds: 2500),
    );
    // Restart animation when this page is built
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Not just pixels. Context.',
            style: GoogleFonts.manrope(
              fontSize: 18,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left Card
              Container(
                width: 130,
                height: 180,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 48, color: colors.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Original Photo',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.arrow_forward_rounded, color: colors.accent, size: 28),
              const SizedBox(width: 16),
              // Right Card
              Container(
                width: 140,
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.primary),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnimatedField(0.0, 0.2, '🧠 AI Hackathon', colors.textPrimary, true),
                    const SizedBox(height: 8),
                    _buildAnimatedField(0.2, 0.4, '📋 Event', colors.textSecondary, false),
                    const SizedBox(height: 8),
                    _buildAnimatedField(0.4, 0.6, '📅 Sep 5', colors.textSecondary, false),
                    const SizedBox(height: 8),
                    _buildAnimatedField(0.6, 0.8, '📍 Main Aud.', colors.textSecondary, false),
                    const SizedBox(height: 8),
                    _buildAnimatedField(0.8, 1.0, '✓ Register', colors.success, true),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'The gallery stores pixels. MemoryLens stores meaning.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero).animate(animation),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
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
      duration: const Duration(milliseconds: 800),
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Seriously. We\'ve got it.',
            style: GoogleFonts.manrope(
              fontSize: 18,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          
          // Vault Stack
          SizedBox(
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildVaultCard(colors, -15, 0.8, 'Electricity Bill', 20),
                _buildVaultCard(colors, 0, 0.9, 'Zomato Internship', 10),
                _buildVaultCard(colors, 15, 1.0, 'Hackathon 2026', 0),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Timeline
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
          const SizedBox(height: 24),

          // Notification Card
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.3 + 0.7 * _pulseController.value),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.1 * _pulseController.value),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_active, color: colors.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registration closes tomorrow!',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'AI Hackathon 2026',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildVaultCard(MemoryLensColors colors, double yOffset, double scale, String text, double padding) {
    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Transform.scale(
        scale: scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelinePill(MemoryLensColors colors, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTimelineDottedLine(MemoryLensColors colors) {
    return Container(
      width: 30,
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
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    double dashWidth = 4, dashSpace = 4, startX = 0;
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
        // Background decorative shapes
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: 150,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.12),
            ),
          ),
        ),
        Positioned(
          top: 300,
          right: 40,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accent.withValues(alpha: 0.08),
            ),
          ),
        ),
        
        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(Icons.camera_alt, color: colors.primary, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'MemoryLens',
                      style: GoogleFonts.yellowtail(
                        fontSize: 32,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              Text(
                'Your brain has\nbetter things to do.',
                style: GoogleFonts.manrope(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: colors.textPrimary,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Let your phone remember.',
                style: GoogleFonts.yellowtail(
                  fontSize: 28,
                  color: colors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Because "I\'ll remember this" is historically unreliable.',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
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
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Get Started →',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: GoogleFonts.manrope(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
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
                        fontWeight: FontWeight.bold,
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
