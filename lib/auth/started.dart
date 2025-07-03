import 'package:flutter/material.dart';

// Widget Tombol Utama dengan Animasi
class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? const Color(0xFF0045A8)
                      : const Color(0xFF0052CC),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF0052CC,
                      ).withOpacity(_isHovered ? 0.4 : 0.3),
                      blurRadius: 10,
                      spreadRadius: _isHovered ? 2 : 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: null,
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Widget Tombol Sekunder dengan Animasi
class SecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? const Color(0xFF0052CC).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0052CC),
                    width: _isHovered ? 2.0 : 1.5,
                  ),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: null,
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: _isHovered
                          ? const Color(0xFF0045A8)
                          : const Color(0xFF0052CC),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class StartedPage extends StatelessWidget {
  const StartedPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFE3F2FD)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    // Logo dan Nama Aplikasi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 10),
                        Text(
                          'SewainAja',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0052CC),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Ilustrasi dengan animasi
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        height: 250,
                        child: Stack(
                          children: [
                            Positioned(
                              right: 0,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 40,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBBDEFB),
                                  borderRadius: BorderRadius.circular(90),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                height: 220,
                                width: 220,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0052CC,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(110),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 80,
                                      color: Color(0xFF0052CC),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Sewa",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0052CC),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Teks Deskripsi
                    Text(
                      'Sewa Barang Kebutuhanmu\nDengan Mudah dan Terpercaya',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0052CC),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Temukan berbagai barang sewaan berkualitas\ndengan harga terjangkau',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),

                // Tombol Aksi dengan animasi
                Column(
                  children: [
                    PrimaryButton(
                      text: 'Daftar Sekarang',
                      onPressed: () {
                        Navigator.pushNamed(context, '/auth/daftar');
                      },
                    ),
                    const SizedBox(height: 15),
                    SecondaryButton(
                      text: 'Masuk ke Akun',
                      onPressed: () {
                        Navigator.pushNamed(context, '/auth/login');
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
