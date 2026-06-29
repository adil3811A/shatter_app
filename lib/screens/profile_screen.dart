import 'package:flutter/material.dart';
import '../utils/env.dart' as env;
import '../data/models/user_session.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserSession? _session;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await LocalStorageService().getSession();
    if (mounted) {
      setState(() {
        _session = session;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _session?.displayName ?? 'Julian Vane';
    final username = _session?.username ?? 'julian_stealth';
    final initials = displayName.length >= 2 
        ? displayName.substring(0, 2).toUpperCase() 
        : displayName.substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E13),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Profile Card Header Area
              Center(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Gradient Cover Banner
                    Container(
                      height: 140,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF8B5CF6), // Bright Violet
                            Color(0xFF4C1D95), // Deep Purple
                            Color(0xFF1E1B4B), // Indigo-black
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    // Avatar partially overlapping the banner
                    Transform.translate(
                      offset: const Offset(0, 40),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0F0E13),
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundImage: env.isTesting || _session != null
                              ? null
                              : const NetworkImage(
                                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
                                ),
                          child: env.isTesting || _session != null
                              ? Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 54), // Spacing for offset avatar

              // Name & Username
              Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@$username',
                style: const TextStyle(
                  color: Color(0xFF7C758E),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 16),

              // Active status banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Shatter Protocol Secure',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Statistics Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1724),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF242038).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('1,234', 'Messages'),
                      _buildVerticalDivider(),
                      _buildStatColumn('342', 'Contacts'),
                      _buildVerticalDivider(),
                      _buildStatColumn('16', 'Secure Keys'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Options List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1724),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF242038).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildOptionRow(
                        icon: Icons.shield_outlined,
                        title: 'Device Security Logs',
                      ),
                      _buildDivider(),
                      _buildOptionRow(
                        icon: Icons.key_outlined,
                        title: 'Manage E2E Keys',
                      ),
                      _buildDivider(),
                      _buildOptionRow(
                        icon: Icons.info_outline_rounded,
                        title: 'Privacy Policy',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1724),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF242038).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await AuthService().logout();
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Logout failed: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Logout Session',
                      style: TextStyle(
                        color: Color(0xFFFDA4AF), // Red/coral text
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),

              // Space for bottom nav bar
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7C758E),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFF242038).withOpacity(0.5),
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

  Widget _buildOptionRow({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7C758E), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF7C758E),
            size: 24,
          ),
        ],
      ),
    );
  }
}
