import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/utils/haptics_engine.dart';
import 'help_center_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  final List<Map<String, String>> _faqs = [
    {'q': 'How do I calibrate the compass?', 'a': 'Hold your phone and move it in a figure-8 motion repeatedly until the accuracy indicator improves.'},
    {'q': 'How do I change the theme?', 'a': 'Go to Settings → Appearance and toggle the Dark Mode switch. Changes apply instantly.'},
    {'q': 'Does the app work offline?', 'a': 'Yes! Pocket Utility is 100% offline. No internet connection is ever required.'},
    {'q': 'How accurate is the altimeter?', 'a': 'Accuracy depends on GPS satellite connectivity. More satellites = better accuracy.'},
    {'q': 'Can I customize my Quick Access tools?', 'a': 'Yes! Tap "Edit" next to Quick Access on the Home screen to choose your favourite tools.'},
    {'q': 'How do I pin a tool?', 'a': 'In the Tools tab, long-press any tool icon and select "Pin to top".'},
    {'q': 'Is my data safe?', 'a': 'All data is stored locally on your device. We never collect or transmit personal information.'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final bg = isDark ? const Color(0xFF0A0A12) : const Color(0xFFF5F3FF);
    final cardBg = isDark ? const Color(0xFF16161F) : Colors.white;

    final filtered = _query.isEmpty
        ? _faqs
        : _faqs.where((f) =>
            f['q']!.toLowerCase().contains(_query.toLowerCase()) ||
            f['a']!.toLowerCase().contains(_query.toLowerCase())).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withOpacity(0.3), width: 1),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: primary, size: 16),
            ),
          ),
          title: Text('Help Center', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A0A3D))),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Hero banner
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('How can we help?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Find answers to common questions', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),

            // Search bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withOpacity(0.3), width: 1.5),
                boxShadow: [BoxShadow(color: primary.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search for help...',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                  prefixIcon: Icon(Icons.search_rounded, color: primary),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(icon: Icon(Icons.close, color: primary, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); })
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ).animate().fadeIn(duration: 350.ms, delay: 80.ms),

            // FAQ list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text('Frequently Asked Questions',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white60 : Colors.black45, letterSpacing: 0.5)),
                  ),
                  ...filtered.asMap().entries.map((e) => _buildFaq(e.value, e.key, isDark, cardBg, primary)),
                  const SizedBox(height: 20),
                  // Contact section
                  Text('Still need help?',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white60 : Colors.black45, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  _buildContactCard(
                    Icons.email_outlined, 
                    'Email Support', 
                    'kiran.cybergrid@gmail.com', 
                    isDark, cardBg, primary,
                    () => launchUrl(Uri.parse('mailto:kiran.cybergrid@gmail.com')),
                  ),
                  const SizedBox(height: 10),
                  _buildContactCard(
                    Icons.chat_bubble_outline_rounded, 
                    'WhatsApp Support', 
                    'Available 9AM – 5PM', 
                    isDark, cardBg, primary,
                    () => launchUrl(Uri.parse('whatsapp://send?phone=9526480039&text=I want help or other')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaq(Map<String, String> faq, int index, bool isDark, Color cardBg, Color primary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.2), width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.help_outline_rounded, color: primary, size: 18),
          ),
          title: Text(faq['q']!, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
          trailing: Icon(Icons.expand_more_rounded, color: primary),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(faq['a']!, style: TextStyle(fontSize: 13, height: 1.5, color: isDark ? Colors.white70 : Colors.black54)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildContactCard(IconData icon, String title, String sub, bool isDark, Color cardBg, Color primary, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticsEngine.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: primary.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: primary, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text(sub, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: primary.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
