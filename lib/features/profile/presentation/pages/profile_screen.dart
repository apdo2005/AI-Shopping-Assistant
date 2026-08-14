import 'package:ai_shopping_assistant/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ai_shopping_assistant/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_shopping_assistant/core/constants/app_colors.dart';
import 'package:ai_shopping_assistant/core/constants/dio_helper.dart';
import 'package:ai_shopping_assistant/core/constants/secure_storage.dart';
import 'package:ai_shopping_assistant/features/profile/domain/entities/profile_entity.dart';
import 'package:ai_shopping_assistant/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:ai_shopping_assistant/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:ai_shopping_assistant/features/profile/domain/usecases/upload_profile_image_usecase.dart';
import 'package:ai_shopping_assistant/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ai_shopping_assistant/features/profile/presentation/bloc/profile_state.dart';
import 'package:ai_shopping_assistant/shared/error_view.dart';
import 'package:ai_shopping_assistant/shared/snakbar.dart';
import 'package:ai_shopping_assistant/features/auth/presentation/screens/login_screen.dart';
import 'edit_profile_screen.dart';
import 'help_center_screen.dart';
import 'personal_information_screen.dart';
import 'settings_screen.dart';
import 'wishlist_screen.dart';

/// Profile tab entry point.
///
/// UI-only redesign: the data flow below (repository -> use cases -> cubit
/// -> fetchProfile) is byte-for-byte the same as before this pass. Nothing
/// here changes an endpoint, a request body, or the profile/session/order/
/// wishlist contracts already implemented in the data layer.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ProfileRepositoryImpl(
      ProfileRemoteDataSourceImpl(DioHelper.dio),
    );
    return BlocProvider(
      create: (_) => ProfileCubit(
        GetProfileUseCase(repository),
        UploadProfileImageUseCase(repository),
        UpdateProfileUseCase(repository),
      )..fetchProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProfileTheme.background,
      appBar: AppBar(
        backgroundColor: _ProfileTheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Icon(Icons.person_rounded, color: AppColors.indigo, size: 21),
        title: Text(
          'Profile',
          style: _ProfileTheme.font(size: 15, weight: FontWeight.w700, color: AppColors.indigo),
        ),
        actions: [
          IconButton(
            onPressed: null,
            icon: Icon(Icons.search_rounded, color: AppColors.indigo.withValues(alpha: 0.35), size: 23),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _ProfileTheme.divider),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: _ProfileTheme.backgroundGradient),
        child: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _buildBody(context, state),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state is ProfileLoading || state is ProfileInitial) {
      return const _ProfileLoadingSkeleton(key: ValueKey('loading'));
    }
    if (state is ProfileError) {
      return ErrorView(
        key: const ValueKey('error'),
        message: state.message,
        onRetry: context.read<ProfileCubit>().fetchProfile,
      );
    }
    if (state is ProfileLoaded) {
      return RefreshIndicator(
        key: const ValueKey('loaded'),
        color: AppColors.indigo,
        onRefresh: context.read<ProfileCubit>().fetchProfile,
        child: _ProfileContent(profile: state.profile),
      );
    }
    return const SizedBox(key: ValueKey('blank'));
  }
}

class _ProfileContent extends StatefulWidget {
  final ProfileEntity profile;

  const _ProfileContent({required this.profile});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final user = profile.user;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                _Entrance(
                  controller: _controller,
                  interval: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
                  child: _ProfileHeader(user: user),
                ),
                const SizedBox(height: 22),
                _Entrance(
                  controller: _controller,
                  interval: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
                  child: _SectionGroup(
                    title: 'ACCOUNT',
                    children: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Personal Information',
                        subtitle: _contactSubtitle(user),
                        onTap: () => _pushWithProfileCubit(
                          context,
                          PersonalInformationScreen(profile: profile),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        subtitle: 'Password, sessions & language',
                        onTap: () => _pushWithProfileCubit(
                          context,
                          SettingsScreen(profile: profile),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _Entrance(
                  controller: _controller,
                  interval: const Interval(0.25, 0.9, curve: Curves.easeOutCubic),
                  child: _SectionGroup(
                    title: 'ORDERS & WISHLIST',
                    children: [
                      // _MenuItem(
                      //   icon: Icons.receipt_long_outlined,
                      //   label: 'Orders',
                      //   subtitle: _countLabel(profile.orderCount, 'order'),
                      //   onTap: () => _pushWithProfileCubit(context, const OrdersScreen()),
                      // ),
                      _MenuItem(
                        icon: Icons.favorite_border_rounded,
                        label: 'Wishlist',
                        subtitle: _countLabel(profile.wishlistCount, 'item'),
                        onTap: () => _pushWithProfileCubit(context, const WishlistScreen()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _Entrance(
                  controller: _controller,
                  interval: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
                  child: _SectionGroup(
                    title: 'SUPPORT',
                    children: [
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help Center',
                        subtitle: 'FAQs & contact support',
                        onTap: () => _push(context, const HelpCenterScreen()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _Entrance(
                  controller: _controller,
                  interval: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
                  child: const _LogoutButton(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _countLabel(int count, String noun) => '$count $noun${count == 1 ? '' : 's'}';

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _pushWithProfileCubit(BuildContext context, Widget page) {
    final cubit = context.read<ProfileCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BlocProvider.value(value: cubit, child: page)),
    );
  }
}

/// Fades + gently slides its child in on first build. Purely cosmetic;
/// wraps existing widgets without altering what they do.
class _Entrance extends StatelessWidget {
  final AnimationController controller;
  final Interval interval;
  final Widget child;

  const _Entrance({required this.controller, required this.interval, required this.child});

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(parent: controller, curve: interval);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final value = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatefulWidget {
  final ProfileUserEntity user;

  const _ProfileHeader({required this.user});

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  final ImagePicker _picker = ImagePicker();
  File? _previewImage;
  bool _isUploading = false;

  // Unchanged from the previous implementation: same picker options, same
  // ProfileCubit.uploadProfileImage/fetchProfile calls, same success/error
  // messaging. Only the surrounding visuals below were touched.
  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image == null || !mounted) return;
    setState(() {
      _previewImage = File(image.path);
      _isUploading = true;
    });
    final url = await context.read<ProfileCubit>().uploadProfileImage(image.path);
    if (!mounted) return;
    if (url == null) {
      setState(() {
        _previewImage = null;
        _isUploading = false;
      });
      CustomSnackBar().errorBar(context, 'Unable to upload the profile image.');
      return;
    }
    await context.read<ProfileCubit>().fetchProfile();
    if (mounted) {
      setState(() => _isUploading = false);
      CustomSnackBar().successBar(context, 'Profile image updated successfully.');
    }
  }

  void _openEditProfile(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final state = cubit.state;
    if (state is! ProfileLoaded) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: EditProfileScreen(profile: state.profile),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final subtitle = _contactSubtitle(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        gradient: _ProfileTheme.headerGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x336366F1), blurRadius: 24, offset: Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: _EditProfileButton(onTap: () => _openEditProfile(context)),
          ),
          Transform.translate(
            offset: const Offset(0, -6),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _AvatarImage(
                  previewFile: _previewImage,
                  imageUrl: user.profileImageUrl,
                  initials: _initials(user.displayName),
                  size: 88,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 3,
                    shadowColor: Colors.black26,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _isUploading ? null : _pickImage,
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: _isUploading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.indigo),
                              )
                            : const Icon(Icons.camera_alt_outlined, size: 15, color: AppColors.indigo),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: _ProfileTheme.font(size: 20, weight: FontWeight.w700, color: Colors.white),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: _ProfileTheme.font(size: 12.5, color: Colors.white.withValues(alpha: 0.85)),
            ),
          ],
        ],
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditProfileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular avatar with a fixed footprint (no layout jump), an initials
/// fallback that is always present underneath, a shimmer while the network
/// image decodes, and a silent fallback to initials on any load error.
/// Does not change where the image URL comes from or how it is uploaded.
class _AvatarImage extends StatelessWidget {
  final File? previewFile;
  final String? imageUrl;
  final String initials;
  final double size;

  const _AvatarImage({
    required this.previewFile,
    required this.imageUrl,
    required this.initials,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Initials fallback: always rendered first so a missing/broken
            // image never leaves a blank circle.
            Container(
              color: _ProfileTheme.iconBackground,
              alignment: Alignment.center,
              child: Text(
                initials,
                style: _ProfileTheme.font(size: size * 0.32, weight: FontWeight.w700, color: AppColors.indigo),
              ),
            ),
            if (previewFile != null)
              Image.file(previewFile!, fit: BoxFit.cover)
            else if (hasUrl)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const _ShimmerBox(width: double.infinity, height: double.infinity, radius: 0);
                },
                errorBuilder: (context, error, stack) {
                  if (kDebugMode) debugPrint('Profile image failed to load: $error');
                  // Falls through to the initials layer already painted below.
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 10),
          child: Text(
            title,
            style: _ProfileTheme
                .font(size: 11.5, weight: FontWeight.w700, color: _ProfileTheme.textMuted)
                .copyWith(letterSpacing: 0.6),
          ),
        ),
        Container(
          decoration: _ProfileTheme.cardDecoration,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const Divider(height: 1, color: _ProfileTheme.divider),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: _ProfileTheme.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.indigo, size: 19),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: _ProfileTheme.font(size: 14, weight: FontWeight.w600, color: _ProfileTheme.text),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _ProfileTheme.font(size: 12, color: _ProfileTheme.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _ProfileTheme.chevron, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  const _LogoutButton();

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isLoggingOut = false;

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Log out?', style: _ProfileTheme.font(size: 16, weight: FontWeight.w700)),
        content: Text(
          'You will need to sign in again to access your account.',
          style: _ProfileTheme.font(size: 13, color: _ProfileTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel', style: _ProfileTheme.font(size: 13, color: _ProfileTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Log out',
              style: _ProfileTheme.font(size: 13, weight: FontWeight.w700, color: _ProfileTheme.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) _logout(context);
  }

  // Same FirebaseAuth.signOut + SecureStorage.clear + navigation reset as
  // before; only the confirmation step, the busy state, and the double-tap
  // guard around it are new.
  Future<void> _logout(BuildContext context) async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      await SecureStorage().clear();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (_) {
      if (context.mounted) {
        setState(() => _isLoggingOut = false);
        CustomSnackBar().errorBar(context, 'Unable to log out. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _isLoggingOut ? null : () => _confirmLogout(context),
        icon: _isLoggingOut
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: _ProfileTheme.danger),
              )
            : const Icon(Icons.logout_rounded, size: 19, color: _ProfileTheme.danger),
        label: Text(
          _isLoggingOut ? 'Logging out...' : 'Logout',
          style: _ProfileTheme.font(size: 14, weight: FontWeight.w600, color: _ProfileTheme.danger),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledForegroundColor: _ProfileTheme.danger,
          side: const BorderSide(color: Color(0xFFF3D6D6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
    );
  }
}

/// Skeleton shown while the profile is first loading. Mirrors the shape of
/// the loaded header + section cards below so nothing "jumps" once the
/// real data arrives.
class _ProfileLoadingSkeleton extends StatelessWidget {
  const _ProfileLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _ProfileTheme.cardBorder),
                  ),
                  child: const Column(
                    children: [
                      _ShimmerBox(width: 88, height: 88, radius: 44),
                      SizedBox(height: 16),
                      _ShimmerBox(width: 140, height: 16),
                      SizedBox(height: 8),
                      _ShimmerBox(width: 180, height: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                for (final rows in const [2, 2, 1]) ...[
                  Container(
                    width: double.infinity,
                    decoration: _ProfileTheme.cardDecoration,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    child: Column(
                      children: [
                        for (var i = 0; i < rows; i++) ...[
                          if (i != 0) const SizedBox(height: 18),
                          const Row(
                            children: [
                              _ShimmerBox(width: 36, height: 36, radius: 18),
                              SizedBox(width: 13),
                              Expanded(child: _ShimmerBox(width: double.infinity, height: 14)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Lightweight shimmer sweep built with core Flutter APIs only (matches the
/// approach already used by the Cart feature's ShimmerBox, kept local here
/// so this screen doesn't reach into another feature's widget tree).
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({required this.width, required this.height, this.radius = 8});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = _controller.value;
            return LinearGradient(
              begin: Alignment(-1.5 + dx * 3, 0),
              end: Alignment(0.5 + dx * 3, 0),
              colors: const [Color(0xFFEFEBFA), Color(0xFFFAF8FF), Color(0xFFEFEBFA)],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFFEFEBFA),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Design tokens for the Profile section only, styled to match the Cart
/// screen's premium look (soft gradient background, white rounded cards,
/// subtle indigo-tinted shadow, Poppins type). Kept local to this feature,
/// same approach CartTheme takes, so it can't ripple into unrelated screens.
class _ProfileTheme {
  _ProfileTheme._();

  static const background = Color(0xFFFCF9FF);
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF6F3FD), Color(0xFFFBFAFE)],
  );
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.indigo, Color(0xFF8B5CF6)],
  );

  static const text = Color(0xFF252331);
  static const textSecondary = Color(0xFF8E8AA3);
  static const textMuted = Color(0xFFB4AFC8);
  static const iconBackground = Color(0xFFF0ECFA);
  static const divider = Color(0xFFF0EDF4);
  static const cardBorder = Color(0xFFF0EDF4);
  static const chevron = Color(0xFF494653);
  static const danger = Color(0xFFEF4444);

  static final cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: cardBorder),
    boxShadow: const [
      BoxShadow(color: Color(0x100B0628), blurRadius: 18, offset: Offset(0, 8)),
    ],
  );

  static TextStyle font({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color color = text,
    double? height,
  }) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color, height: height);
}

String? _contactSubtitle(ProfileUserEntity user) {
  final email = user.email.trim();
  if (email.isNotEmpty) return email;
  final phone = user.phone?.trim();
  if (phone != null && phone.isNotEmpty) return '${user.countryCode ?? ''}$phone';
  return null;
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
  final initials = parts.take(2).map((part) => part[0]).join();
  return initials.isEmpty ? '?' : initials.toUpperCase();
}
