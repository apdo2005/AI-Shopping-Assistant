import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_shopping_assistant/core/constants/app_colors.dart';

/// Shared design system for the entire Profile section (main screen +
/// every screen reachable from it: Personal Information, Edit Profile,
/// Settings, Change Username, Change Password, Language, Active Sessions,
/// Orders, Wishlist, Help Center).
///
/// Centralising these tokens here (instead of duplicating them per screen)
/// is what keeps the whole Profile flow feeling like one app: same
/// background, same card shadow/radius, same type scale, same primary
/// gradient, same shimmer. Styled to match the Cart screen's premium
/// language (soft gradient background, white rounded cards, Poppins type).
class ProfileTheme {
  ProfileTheme._();

  static const background = Color(0xFFFCF9FF);
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF6F3FD), Color(0xFFFBFAFE)],
  );
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.indigo, Color(0xFF8B5CF6)],
  );

  static const primary = AppColors.indigo;
  static const text = Color(0xFF252331);
  static const textSecondary = Color(0xFF8E8AA3);
  static const textMuted = Color(0xFFB4AFC8);
  static const iconBackground = Color(0xFFF0ECFA);
  static const divider = Color(0xFFF0EDF4);
  static const cardBorder = Color(0xFFF0EDF4);
  static const chevron = Color(0xFF494653);
  static const danger = Color(0xFFEF4444);
  static const dangerBackground = Color(0xFFFCEEEE);
  static const dangerBorder = Color(0xFFF3D6D6);
  static const success = Color(0xFF16A34A);

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

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelStyle: font(size: 13, color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
      );
}

/// Common scaffold for every screen pushed from Profile. Keeps the same
/// soft gradient background, app bar style and safe-area handling as the
/// Profile landing screen.
class ProfilePageScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const ProfilePageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: ProfileTheme.background,
        appBar: AppBar(
          backgroundColor: ProfileTheme.background,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          title: Text(
            title,
            style: ProfileTheme.font(size: 15, weight: FontWeight.w700, color: ProfileTheme.primary),
          ),
          iconTheme: const IconThemeData(color: ProfileTheme.primary),
          actions: actions,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: ProfileTheme.divider),
          ),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: ProfileTheme.backgroundGradient),
          child: SafeArea(child: child),
        ),
      );
}

class ProfileCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ProfileCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: ProfileTheme.cardDecoration,
        child: child,
      );
}

/// A left-aligned, uppercase section label used above a [ProfileCard] group
/// (e.g. "ACCOUNT", "PRIVACY & SECURITY"). Actually renders — earlier builds
/// of some Profile sub-screens stubbed this out to an empty box, which
/// silently hid every section heading.
class ProfileSectionLabel extends StatelessWidget {
  final String text;

  const ProfileSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 6, bottom: 10),
        child: Text(
          text,
          style: ProfileTheme
              .font(size: 11.5, weight: FontWeight.w700, color: ProfileTheme.textMuted)
              .copyWith(letterSpacing: 0.6),
        ),
      );
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showChevron;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) => Material(
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
                    color: ProfileTheme.iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: ProfileTheme.primary, size: 19),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ProfileTheme.font(
                          size: 14,
                          weight: FontWeight.w600,
                          color: onTap == null ? ProfileTheme.textMuted : ProfileTheme.text,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ProfileTheme.font(size: 12, color: ProfileTheme.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showChevron)
                  Icon(Icons.chevron_right_rounded,
                      color: onTap == null ? ProfileTheme.divider : ProfileTheme.chevron, size: 22),
              ],
            ),
          ),
        ),
      );
}

class ProfileEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const ProfileEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ProfileTheme.primary.withValues(alpha: 0.10),
                      ProfileTheme.primary.withValues(alpha: 0.04),
                    ],
                  ),
                ),
                child: Icon(icon, size: 40, color: ProfileTheme.primary),
              ),
              const SizedBox(height: 20),
              Text(title, style: ProfileTheme.font(size: 16, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: ProfileTheme.font(size: 12.5, color: ProfileTheme.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      );
}

/// Consistent error state (with retry) for every Profile sub-screen, styled
/// the same as the Profile landing screen's error handling.
class ProfileErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ProfileErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ProfileTheme.danger.withValues(alpha: 0.08),
                ),
                child: const Icon(Icons.cloud_off_rounded, color: ProfileTheme.danger, size: 38),
              ),
              const SizedBox(height: 20),
              Text('Something went wrong', style: ProfileTheme.font(size: 15, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: ProfileTheme.font(size: 12.5, color: ProfileTheme.textSecondary, height: 1.5),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfileTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text('Try Again', style: ProfileTheme.font(size: 13, weight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

/// Full-width primary button with a built-in busy state. Used anywhere a
/// Profile sub-screen submits a change (Edit Profile, Change Username,
/// Language) so the "disabled while saving" / "prevent double submit"
/// behaviour is implemented once and can't drift between screens.
class ProfilePrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const ProfilePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: ProfileTheme.primary,
            disabledBackgroundColor: ProfileTheme.primary.withValues(alpha: 0.5),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                )
              : Text(label, style: ProfileTheme.font(size: 14, weight: FontWeight.w600, color: Colors.white)),
        ),
      );
}

/// Shows a premium, consistently-styled confirmation dialog and returns
/// `true` only if the destructive/confirming action was chosen. Used by
/// Logout (and anywhere else in Profile that needs a confirm step) so every
/// dialog in the flow looks and behaves the same.
Future<bool> showProfileConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(title, style: ProfileTheme.font(size: 16, weight: FontWeight.w700)),
      content: Text(message, style: ProfileTheme.font(size: 13, color: ProfileTheme.textSecondary, height: 1.4)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(cancelLabel, style: ProfileTheme.font(size: 13, color: ProfileTheme.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(
            confirmLabel,
            style: ProfileTheme.font(
              size: 13,
              weight: FontWeight.w700,
              color: destructive ? ProfileTheme.danger : ProfileTheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// Lightweight shimmer sweep built with core Flutter APIs only (no external
/// shimmer dependency), shared by every loading skeleton in the Profile
/// flow.
class ProfileShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ProfileShimmerBox({super.key, required this.width, required this.height, this.radius = 8});

  @override
  State<ProfileShimmerBox> createState() => _ProfileShimmerBoxState();
}

class _ProfileShimmerBoxState extends State<ProfileShimmerBox> with SingleTickerProviderStateMixin {
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

/// Fades + gently slides its child in on first build. Purely cosmetic;
/// wraps existing widgets without altering what they do. Shared by every
/// Profile screen's entrance animation.
class ProfileEntrance extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const ProfileEntrance({super.key, required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
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

/// Backwards-compatible alias — some older Profile sub-screens referenced
/// this name directly for divider/icon colors.
typedef ProfileUiColors = ProfileTheme;
