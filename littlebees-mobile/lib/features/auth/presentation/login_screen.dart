import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_button.dart';
import '../../../design_system/widgets/lb_input.dart';
import '../application/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
      // Router redirect will handle navigation automatically
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                _buildLogo(),

                const SizedBox(height: 48),

                _buildHeader(context),

                const SizedBox(height: 48),

                _buildEmailField(),

                const SizedBox(height: 20),

                _buildPasswordField(),

                const SizedBox(height: 12),

                _buildForgotPassword(context),

                const SizedBox(height: 32),

                _buildLoginButton(),

                const SizedBox(height: 24),

                _buildDivider(),

                const SizedBox(height: 24),

                _buildSignUpPrompt(context),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
          child: Image.asset(
            'assets/images/Logo.png',
            width: 220,
            fit: BoxFit.contain,
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 500.ms);
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Welcome back',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),

        const SizedBox(height: 8),

        Text(
              'Sign in to continue',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            )
            .animate()
            .fadeIn(duration: 500.ms, delay: 100.ms)
            .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildEmailField() {
    return LBInput(
          controller: _emailController,
          label: 'Email',
          hintText: 'your.email@example.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: LucideIcons.mail,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildPasswordField() {
    return LBInput(
          controller: _passwordController,
          label: 'Password',
          hintText: '••••••••',
          obscureText: !_isPasswordVisible,
          prefixIcon: LucideIcons.lock,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
              size: 20,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset coming soon'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Text(
          'Forgot password?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }

  Widget _buildLoginButton() {
    return LBButton(
          text: _isLoading ? 'Signing in...' : 'Sign In',
          onPressed: _isLoading ? null : _handleLogin,
          icon: _isLoading
              ? null
              : const Icon(
                  LucideIcons.logIn,
                  size: 20,
                  color: AppColors.textOnPrimary,
                ),
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 500.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms);
  }

  Widget _buildSignUpPrompt(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Don\'t have an account? ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sign up coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Sign up',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 700.ms);
  }
}
