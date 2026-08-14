import 'package:flutter/material.dart';

import '../widgets/profile_ui.dart';

/// No FAQ content, contact address, or report-a-problem endpoint exists
/// anywhere in this project (checked the whole codebase for support
/// emails/links and found none). Per the "don't invent support
/// functionality" rule, this stays a clear, honest "not available yet"
/// state rather than fabricated FAQ copy or a fake mailto link — just
/// restyled to match the rest of the Profile flow.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      title: 'Help Center',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
        children: [
          const ProfileSectionLabel('SUPPORT'),
          ProfileCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ProfileMenuTile(
                  icon: Icons.question_answer_outlined,
                  title: 'Frequently Asked Questions',
                  subtitle: 'Not available yet',
                  onTap: () => _notice(context),
                ),
                const Divider(height: 1, color: ProfileTheme.divider),
                ProfileMenuTile(
                  icon: Icons.support_agent_outlined,
                  title: 'Contact Support',
                  subtitle: 'Not available yet',
                  onTap: () => _notice(context),
                ),
                const Divider(height: 1, color: ProfileTheme.divider),
                ProfileMenuTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Report a Problem',
                  subtitle: 'Not available yet',
                  onTap: () => _notice(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const ProfileSectionLabel('ABOUT'),
          const ProfileCard(
            padding: EdgeInsets.zero,
            child: ProfileMenuTile(
              icon: Icons.info_outline_rounded,
              title: 'About the App',
              showChevron: false,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ProfileTheme.iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: ProfileTheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Support isn\'t connected to a backend yet, so these actions are placeholders for now.',
                    style: ProfileTheme.font(size: 11.5, color: ProfileTheme.textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _notice(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support actions are not configured yet.')),
      );
}
