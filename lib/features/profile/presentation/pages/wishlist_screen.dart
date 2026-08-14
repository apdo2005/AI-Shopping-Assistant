import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_ui.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      title: 'Wishlist',
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            final items = state.profile.wishlist;
            if (items.isEmpty) {
              return RefreshIndicator(
                color: ProfileTheme.primary,
                onRefresh: context.read<ProfileCubit>().fetchProfile,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 80),
                    ProfileEmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'Your wishlist is empty',
                      message: 'Products you save will appear here.',
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              color: ProfileTheme.primary,
              onRefresh: context.read<ProfileCubit>().fetchProfile,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _WishlistCard(data: items[index]),
              ),
            );
          }
          if (state is ProfileLoading || state is ProfileInitial) {
            return const _WishlistLoadingSkeleton();
          }
          // Bug fix: previously showed a static "pull to refresh" message
          // with no scrollable/refreshable widget underneath to act on —
          // there was no real way to recover from an error. Now shows the
          // shared error state with a working Retry button.
          final message = state is ProfileError ? state.message : 'Unable to load your wishlist right now.';
          return ProfileErrorState(message: message, onRetry: context.read<ProfileCubit>().fetchProfile);
        },
      ),
    );
  }
}

class _WishlistCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const _WishlistCard({required this.data});

  @override
  State<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<_WishlistCard> {
  bool _expanded = false;

  // Reads whatever keys the wishlist item map already contains — the
  // wishlist item shape isn't documented by the backend beyond "a map",
  // so this only *uses* fields if they're actually present, never assumes
  // one exists. Falls back to a generic saved-product tile otherwise.
  String? _pick(List<String> candidates) {
    for (final key in candidates) {
      final value = widget.data[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final name = _pick(['name', 'title', 'product_name', 'meal_name']);
    final image = _pick(['image', 'image_url', 'thumbnail', 'photo', 'picture']);
    final price = _pick(['price', 'final_price', 'total_price', 'amount']);

    final allEntries = widget.data.entries.where((entry) => entry.value != null).toList();
    final visibleEntries = _expanded ? allEntries : allEntries.take(3).toList();
    final hasMore = allEntries.length > 3;

    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WishlistThumbnail(imageUrl: image),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? 'Saved product',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ProfileTheme.font(size: 14, weight: FontWeight.w700),
                    ),
                    if (price != null) ...[
                      const SizedBox(height: 4),
                      Text(price, style: ProfileTheme.font(size: 13, weight: FontWeight.w600, color: ProfileTheme.primary)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.favorite_rounded, color: ProfileTheme.danger, size: 19),
            ],
          ),
          if (visibleEntries.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: ProfileTheme.divider),
            const SizedBox(height: 10),
            ...visibleEntries.map((entry) => _DetailRow(label: entry.key, value: entry.value)),
          ],
          if (hasMore) ...[
            const SizedBox(height: 2),
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Show less' : 'Show all details',
                      style: ProfileTheme.font(size: 12, weight: FontWeight.w600, color: ProfileTheme.primary),
                    ),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 17,
                      color: ProfileTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WishlistThumbnail extends StatelessWidget {
  final String? imageUrl;

  const _WishlistThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const size = 52.0;
    final hasUrl = imageUrl != null && imageUrl!.trim().isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: size,
        color: ProfileTheme.iconBackground,
        child: hasUrl
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const ProfileShimmerBox(width: size, height: size, radius: 12),
                errorBuilder: (context, error, stack) =>
                    const Icon(Icons.favorite_border_rounded, color: ProfileTheme.primary, size: 22),
              )
            : const Icon(Icons.favorite_border_rounded, color: ProfileTheme.primary, size: 22),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final Object value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(_prettifyKey(label), style: ProfileTheme.font(size: 12, color: ProfileTheme.textSecondary))),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value.toString(),
              textAlign: TextAlign.end,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: ProfileTheme.font(size: 12.5, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  static String _prettifyKey(String key) {
    final spaced = key.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    if (spaced.isEmpty) return key;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}

class _WishlistLoadingSkeleton extends StatelessWidget {
  const _WishlistLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
      children: List.generate(
        4,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProfileCard(
            child: Row(
              children: const [
                ProfileShimmerBox(width: 52, height: 52, radius: 12),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileShimmerBox(width: double.infinity, height: 14),
                      SizedBox(height: 8),
                      ProfileShimmerBox(width: 80, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
