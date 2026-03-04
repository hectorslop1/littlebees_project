import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/widgets/lb_card.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _pushNotifications = true;
  bool _checkInOut = true;
  bool _meals = true;
  bool _naps = true;
  bool _photos = true;
  bool _messages = true;
  bool _events = true;
  bool _dailySummary = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'Notification Preferences',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: LBCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildMasterToggle(),
                if (_pushNotifications) ...[
                  const Divider(height: 1, color: AppColors.divider),
                  _buildToggleItem(
                    icon: LucideIcons.logIn,
                    title: 'Check-in & Check-out',
                    subtitle: 'When your child arrives or leaves',
                    value: _checkInOut,
                    onChanged: (value) => setState(() => _checkInOut = value),
                    delay: 100,
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildToggleItem(
                    icon: LucideIcons.utensils,
                    title: 'Meals',
                    subtitle: 'Breakfast, lunch, and snack updates',
                    value: _meals,
                    onChanged: (value) => setState(() => _meals = value),
                    delay: 150,
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildToggleItem(
                    icon: LucideIcons.moon,
                    title: 'Naps',
                    subtitle: 'Nap time and duration',
                    value: _naps,
                    onChanged: (value) => setState(() => _naps = value),
                    delay: 200,
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildToggleItem(
                    icon: LucideIcons.camera,
                    title: 'Photos',
                    subtitle: 'New photos and activities',
                    value: _photos,
                    onChanged: (value) => setState(() => _photos = value),
                    delay: 250,
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildToggleItem(
                    icon: LucideIcons.messageSquare,
                    title: 'Messages',
                    subtitle: 'New messages from caregivers',
                    value: _messages,
                    onChanged: (value) => setState(() => _messages = value),
                    delay: 300,
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildToggleItem(
                    icon: LucideIcons.calendar,
                    title: 'Events',
                    subtitle: 'Upcoming events and reminders',
                    value: _events,
                    onChanged: (value) => setState(() => _events = value),
                    delay: 350,
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildToggleItem(
                    icon: LucideIcons.sparkles,
                    title: 'Daily Summary',
                    subtitle: 'End of day recap at 5:00 PM',
                    value: _dailySummary,
                    onChanged: (value) => setState(() => _dailySummary = value),
                    delay: 400,
                  ),
                ],
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'You can customize which notifications you receive. We recommend keeping Check-in/Check-out enabled for your child\'s safety.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildMasterToggle() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _pushNotifications
                  ? AppColors.primarySurface
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.bell,
              size: 24,
              color: _pushNotifications
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _pushNotifications ? 'Enabled' : 'Disabled',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _pushNotifications
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _pushNotifications,
            onChanged: (value) => setState(() => _pushNotifications = value),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    int delay = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: delay.ms);
  }
}
