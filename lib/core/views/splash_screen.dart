import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/app_routes.dart';
import '../services/remote_config_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Scale animation (in-out effect)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    // Start animation
    _controller.forward();

    // Navigate after animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNext();
      }
    });
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
    
    // Check for update after navigation using Get.context
    // This ensures the dialog shows on the new screen and doesn't get dismissed
    await Future.delayed(const Duration(milliseconds: 500));
    if (Get.context != null) {
      await RemoteConfigService.instance.checkAndShowUpdatePopup(Get.context!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure black background
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon with animation
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback if image doesn't load
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                size: 80,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Optional: App name with fade animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Junto',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}




