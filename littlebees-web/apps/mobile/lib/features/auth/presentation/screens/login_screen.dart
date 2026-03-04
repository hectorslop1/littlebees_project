import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KsColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Text(
                'KinderSpace',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: KsColors.primary,
                      fontFamily: 'Quicksand',
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Inicia sesión en tu cuenta',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: KsColors.muted,
                    ),
              ),
              const SizedBox(height: 48),

              // Email field
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'tu@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password field
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Iniciar Sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
