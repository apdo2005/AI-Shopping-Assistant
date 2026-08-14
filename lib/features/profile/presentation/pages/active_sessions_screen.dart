import 'package:flutter/material.dart';

import 'package:ai_shopping_assistant/features/profile/domain/entities/profile_entity.dart';
import '../widgets/profile_ui.dart';

class ActiveSessionsScreen extends StatelessWidget {
  final List<ActiveSessionEntity> sessions;

  const ActiveSessionsScreen({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      title: 'Active Sessions',
      child: sessions.isEmpty
          ? const ProfileEmptyState(
              icon: Icons.devices_other_outlined,
              title: 'No active sessions',
              message: 'Your active sessions will be shown here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _SessionCard(session: sessions[index]),
            ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ActiveSessionEntity session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: session.isCurrent ? ProfileTheme.iconBackground : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              session.isCurrent ? Icons.verified_user_outlined : Icons.devices_other_outlined,
              color: session.isCurrent ? ProfileTheme.primary : ProfileTheme.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.name, style: ProfileTheme.font(size: 14, weight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  session.isCurrent
                      ? 'Current session • Active'
                      : session.lastUsedAt == null
                          ? 'Last used: unknown'
                          : 'Last used: ${session.lastUsedAt}',
                  style: ProfileTheme.font(size: 12, color: ProfileTheme.textSecondary),
                ),
              ],
            ),
          ),
          if (session.isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ProfileTheme.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'This device',
                style: ProfileTheme.font(size: 10, weight: FontWeight.w700, color: ProfileTheme.success),
              ),
            ),
        ],
      ),
    );
  }
}
