import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/haptics_engine.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: isDark ? Colors.white : Colors.black87),
              onPressed: () {
                HapticsEngine.selectionClick();
                Navigator.of(context).pop();
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary.withOpacity(0.15),
                      primary.withOpacity(0.02),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.privacy_tip_rounded, color: primary, size: 32),
                        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 16),
                        Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : const Color(0xFF1A0A3D),
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last updated: July 15, 2026',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 24),
                  
                  _buildIntroText(isDark),
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    icon: Icons.shield_outlined,
                    title: '1. No Data Collection',
                    content: 'Pocket Utility PRO was built from the ground up to respect your privacy. We do not collect, store, transmit, or monetize any of your personal data. Everything happens completely offline, right here on your device.',
                    isDark: isDark,
                    cardBg: cardBg,
                    primary: primary,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
                  
                  _buildSection(
                    icon: Icons.security_rounded,
                    title: '2. Device Permissions',
                    content: 'In order for certain tools to function (like the Compass, Flashlight, or Level), the app will request access to specific device hardware sensors or permissions. We strictly use these permissions temporarily while the tool is active. We never record or broadcast your location, camera feed, or sensor data.',
                    isDark: isDark,
                    cardBg: cardBg,
                    primary: primary,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),
                  
                  _buildSection(
                    icon: Icons.block_flipped,
                    title: '3. No Third-Party Tracking',
                    content: 'We do not integrate any third-party analytics frameworks, advertising SDKs, or external trackers. You will never see an ad, and your usage habits remain entirely your own business.',
                    isDark: isDark,
                    cardBg: cardBg,
                    primary: primary,
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05),
                  
                  _buildSection(
                    icon: Icons.edit_document,
                    title: '4. Changes to this Policy',
                    content: 'If we ever decide to change our privacy practices, we will update this document and release a new version of the app. Because we do not have a server connection to you, you will always be notified of changes directly through app updates.',
                    isDark: isDark,
                    cardBg: cardBg,
                    primary: primary,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05),
                  
                  const SizedBox(height: 40),
                  
                  Center(
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.heart_solid, color: primary.withOpacity(0.5), size: 24),
                        const SizedBox(height: 12),
                        Text(
                          'Built securely by Kiran\nkiran.cybergrid@gmail.com',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroText(bool isDark) {
    return Text(
      'At Pocket Utility PRO, we believe your device is your personal property, and the data generated on it belongs strictly to you. This policy outlines our commitment to ensuring a completely secure and private experience.',
      style: TextStyle(
        fontSize: 15,
        height: 1.6,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required bool isDark,
    required Color cardBg,
    required Color primary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A0A3D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withOpacity(0.15), width: 1),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
