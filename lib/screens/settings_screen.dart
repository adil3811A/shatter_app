import 'package:flutter/material.dart';
import '../utils/env.dart' as env;

// Custom high-fidelity switch toggle matching the design
class ShatterSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ShatterSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value ? const Color(0xFFC5B3F9) : const Color(0xFF2E2A38),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings toggle states
  bool _locationServices = false;
  bool _activeStatus = true;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E13), // Deep dark background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Header
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 4.0),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // Profile card
                _buildProfileCard(),

                const SizedBox(height: 24),

                // PRIVACY & SECURITY
                _buildSectionHeader('PRIVACY & SECURITY'),
                _buildCardContainer([
                  _buildSettingRow(
                    icon: Icons.lock_outline_rounded,
                    title: 'E2E Encryption',
                    subtitle: 'Your messages are always secure',
                    trailing: const Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFFC5B3F9),
                      size: 20,
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingRow(
                    icon: Icons.location_on_outlined,
                    title: 'Location services',
                    trailing: ShatterSwitch(
                      value: _locationServices,
                      onChanged: (val) {
                        setState(() {
                          _locationServices = val;
                        });
                      },
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingRow(
                    icon: Icons.visibility_outlined,
                    title: 'Active status',
                    trailing: ShatterSwitch(
                      value: _activeStatus,
                      onChanged: (val) {
                        setState(() {
                          _activeStatus = val;
                        });
                      },
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // NOTIFICATIONS
                _buildSectionHeader('NOTIFICATIONS'),
                _buildCardContainer([
                  _buildSettingRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'Push notifications',
                    trailing: ShatterSwitch(
                      value: _pushNotifications,
                      onChanged: (val) {
                        setState(() {
                          _pushNotifications = val;
                        });
                      },
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingRow(
                    icon: Icons.volume_up_outlined,
                    title: 'Notification sound',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Stealth Pulse',
                          style: TextStyle(
                            color: Color(0xFFC5B3F9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF7C758E),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // ACCOUNT
                _buildSectionHeader('ACCOUNT'),
                _buildCardContainer([
                  _buildSettingRow(
                    iconWidget: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      child: const Text(
                        '***',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    title: 'Change password',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF7C758E),
                      size: 24,
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingRow(
                    icon: Icons.delete_outline_rounded,
                    iconColor: const Color(0xFFFDA4AF), // Coral/reddish tint
                    title: 'Delete account',
                    titleColor: const Color(0xFFFDA4AF),
                  ),
                ]),

                const SizedBox(height: 20),

                // ABOUT
                _buildSectionHeader('ABOUT'),
                _buildCardContainer([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Feedback',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Custom feedback text area
                        Container(
                          height: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1B24).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF2E2A38),
                              width: 1,
                            ),
                          ),
                          child: const TextField(
                            maxLines: null,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Help us improve Shatter...',
                              hintStyle: TextStyle(color: Color(0xFF7C758E), fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Send Feedback Button
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF231E2D),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Send Feedback',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // Shatter Protocol Version
                Center(
                  child: Text(
                    'Shatter Protocol Version               v3.4.0 BETA',
                    style: TextStyle(
                      color: const Color(0xFF7C758E).withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Spacer for floating bottom navigation bar
                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1724), // Sleek secondary container color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF242038).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Circular avatar with active green status dot
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF242038),
                backgroundImage: env.isTesting
                    ? null
                    : const NetworkImage(
                        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
                      ),
                child: env.isTesting
                    ? const Text(
                        'JV',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981), // Emerald green
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1B1724),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Julian Vane',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '@julian_stealth',
                  style: TextStyle(
                    color: Color(0xFF7C758E),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Edit profile button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC5B3F9), // Pastel lavender button
              foregroundColor: const Color(0xFF161320), // Dark text color
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Edit profile',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF7C758E),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1724),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF242038).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: const Color(0xFF242038).withOpacity(0.5),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildSettingRow({
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
    required String title,
    Color? titleColor,
    String? subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          // Icon on left
          iconWidget ??
              Icon(
                icon,
                color: iconColor ?? const Color(0xFF7C758E),
                size: 22,
              ),
          const SizedBox(width: 16),
          // Title / Subtitle Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor ?? Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF7C758E),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
