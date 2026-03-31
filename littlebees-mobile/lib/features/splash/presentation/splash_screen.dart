import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _navigateToNext();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    // Just wait for the splash animation to complete.
    // The GoRouter redirect in app_router.dart handles
    // navigation based on AuthState (isLoading → isAuthenticated).
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColor(AppColors.background),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.primarySurface.withAlpha(50),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo con animaciones
              Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(50),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/Icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 600.ms)
                  .then(delay: 200.ms)
                  .shimmer(
                    duration: 1500.ms,
                    color: AppColors.primary.withAlpha(50),
                  ),

              const SizedBox(height: 40),

              // Logo text
              Image.asset(
                    'assets/images/Logo.png',
                    width: 200,
                    fit: BoxFit.contain,
                  )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 400.ms)
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 800.ms,
                    delay: 400.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 60),

              // Progress indicator
              Column(
                    children: [
                      SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            backgroundColor: context.appColor(
                              AppColors.surfaceVariant,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary.withAlpha(180),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Preparando tu experiencia...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.appColor(AppColors.textTertiary),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 800.ms)
                  .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
