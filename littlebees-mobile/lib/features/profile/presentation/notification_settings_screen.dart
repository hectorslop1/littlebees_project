import 'package:flutter/material.dart';
import 'widgets/notification_settings.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias'),
        elevation: 0,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: NotificationSettings(),
        ),
      ),
    );
  }
}
