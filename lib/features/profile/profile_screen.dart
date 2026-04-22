import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/shared/widgets/snackbar_message.dart';

// ─── Firestore stream provider ────────────────────────────────────────────────
final _profileStreamProvider =
StreamProvider.family<Map<String, dynamic>?, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((s) => s.data());
});

const _coverSeeds = [
  10, 18, 22, 33, 44, 55, 66, 77, 88, 99,
  110, 121, 132, 143, 154, 165, 176, 187,
];

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploadingPhoto = false;
  String? _pendingCoverUrl; // optimistic UI

  Future<void> _changeProfilePhoto(String uid) async {
    final picker = ImagePicker();
    final picked =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (picked == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      final file = File(picked.path);
      final storageRef =
      FirebaseStorage.instance.ref('profile_photos/$uid.jpg');
      await storageRef.putFile(file);
      final url = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'photoUrl': url});
      if (mounted) {
        SnackbarMessage.show(
            context: context, message: 'Profile photo updated ✓');
      }
    } catch (_) {
      if (mounted) {
        SnackbarMessage.show(
            context: context, message: 'Failed to update photo.');
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _setCoverPhoto(String uid, String imageUrl) async {
    setState(() => _pendingCoverUrl = imageUrl);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'coverUrl': imageUrl});
      if (mounted) {
        SnackbarMessage.show(
            context: context, message: 'Cover photo updated ✓');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _pendingCoverUrl = null);
        SnackbarMessage.show(
            context: context, message: 'Failed to update cover.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final uid = authState.uid ?? '';
    final profileAsync = ref.watch(_profileStreamProvider(uid));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return profileAsync.when(
      loading: () => _LoadingScreen(isDark: isDark),
      error: (e, _) => _ErrorScreen(message: e.toString()),
      data: (data) {
        final email = data?['email'] as String? ?? authState.email ?? '';
        final photoUrl = data?['photoUrl'] as String?;
        final coverUrl =
            _pendingCoverUrl ?? data?['coverUrl'] as String?;
        final tenantId =
            data?['tenantId'] as String? ?? authState.tenantId ?? 'Wafi Store';
        final role = data?['role'] as String? ?? authState.role ?? 'admin';

        return DefaultTabController(
          length: 1,
          child: Scaffold(
            backgroundColor: isDark
                ? AppColors.bgPrimary
                : AppColors.bgPrimaryLight,
            body: Stack(
              fit: StackFit.expand,
              children: [
                _ProfileBackdrop(isDark: isDark),
                NestedScrollView(
                  physics: const BouncingScrollPhysics(),
                  headerSliverBuilder: (ctx, innerScrolled) => [
                    // Cover SliverAppBar
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      pinned: true,
                      stretch: true,
                      expandedHeight: 270,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        background: _CoverHeader(
                          coverUrl: coverUrl,
                          isDark: isDark,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),

                    // Profile card
                    SliverToBoxAdapter(
                      child: _ProfileCard(
                        email: email,
                        tenantId: tenantId,
                        role: role,
                        photoUrl: photoUrl,
                        uid: uid,
                        uploadingPhoto: _uploadingPhoto,
                        onPickPhoto: () => _changeProfilePhoto(uid),
                        isDark: isDark,
                      ),
                    ),

                    // Pinned tab bar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _PinnedTabDelegate(
                        isDark: isDark,
                        child: _GlassTabBar(isDark: isDark),
                      ),
                    ),
                  ],
                  body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _CoverPickerGrid(
                        uid: uid,
                        activeCoverUrl: coverUrl,
                        onSelect: (url) => _setCoverPhoto(uid, url),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Backdrop ─────────────────────────────────────────────────────────────────
class _ProfileBackdrop extends StatelessWidget {
  final bool isDark;
  const _ProfileBackdrop({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [AppColors.bgSecondary, AppColors.bgPrimary, AppColors.bgTertiary]
                  : [AppColors.bgSecondaryLight, AppColors.bgPrimaryLight, AppColors.bgTertiaryLight],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -60,
          child: _GlowOrb(
              size: 240,
              color: AppColors.primary.withOpacity(isDark ? 0.22 : 0.14)),
        ),
        Positioned(
          bottom: 120,
          left: -60,
          child: _GlowOrb(
              size: 200,
              color: AppColors.purple.withOpacity(isDark ? 0.18 : 0.10)),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

// ─── Cover header ─────────────────────────────────────────────────────────────
class _CoverHeader extends StatelessWidget {
  final String? coverUrl;
  final bool isDark;
  final VoidCallback onBack;

  const _CoverHeader({
    required this.coverUrl,
    required this.isDark,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover image or placeholder
        coverUrl != null
            ? Image.network(
          coverUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _CoverPlaceholder(isDark: isDark),
        )
            : _CoverPlaceholder(isDark: isDark),

        // Gradient overlay
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x440F172A),
                Color(0x000F172A),
                Color(0xCC0F172A),
              ],
              stops: [0.0, 0.42, 1.0],
            ),
          ),
        ),

        // Back button
        Positioned(
          top: MediaQuery.paddingOf(context).top + 10,
          left: 16,
          child: _GlassCircleControl(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
        ),

        // Bottom label
        Positioned(
          left: 24,
          right: 24,
          bottom: 26,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap a photo below to update your cover.',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  final bool isDark;
  const _CoverPlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
              : [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
        ),
      ),
    );
  }
}

// ─── Profile card ─────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String email;
  final String tenantId;
  final String role;
  final String? photoUrl;
  final String uid;
  final bool uploadingPhoto;
  final VoidCallback onPickPhoto;
  final bool isDark;

  const _ProfileCard({
    required this.email,
    required this.tenantId,
    required this.role,
    required this.photoUrl,
    required this.uid,
    required this.uploadingPhoto,
    required this.onPickPhoto,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Glass card body
          Padding(
            padding: const EdgeInsets.only(top: 66),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.fromLTRB(20, 80, 20, 24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.07)
                        : Colors.white.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.14)
                          : Colors.black.withOpacity(0.06),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5)
                            .withOpacity(isDark ? 0.18 : 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Display name derived from email/tenantId
                      Text(
                        _displayName(tenantId),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info rows
                      _InfoRow(
                        icon: Icons.storefront_outlined,
                        value: tenantId,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.verified_user_outlined,
                        value: role.toUpperCase(),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.fingerprint_rounded,
                        value: uid.length > 20
                            ? '${uid.substring(0, 20)}…'
                            : uid,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 22),
                      _RoleBadge(role: role),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Avatar with + button
          Positioned(
            top: 0,
            child: _AvatarWithUpload(
              photoUrl: photoUrl,
              uploading: uploadingPhoto,
              onTap: onPickPhoto,
            ),
          ),
        ],
      ),
    );
  }

  String _displayName(String tenantId) {
    // tenantId is usually "store_name_uid", clean it up
    final parts = tenantId.split('_');
    if (parts.length <= 1) return tenantId;
    // Drop the uid at the end (last part looks like a Firebase UID)
    final lastPart = parts.last;
    final withoutUid = lastPart.length > 16
        ? parts.sublist(0, parts.length - 1)
        : parts;
    return withoutUid
        .map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }
}

// ─── Avatar with upload button ────────────────────────────────────────────────
class _AvatarWithUpload extends StatelessWidget {
  final String? photoUrl;
  final bool uploading;
  final VoidCallback onTap;

  const _AvatarWithUpload({
    required this.photoUrl,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Gradient ring
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF4F46E5),
                Color(0xFF7C3AED),
                Color(0xFFA855F7),
              ],
            ),
          ),
          child: CircleAvatar(
            radius: 56,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 52,
              backgroundColor: const Color(0xFFEDE9FE),
              backgroundImage:
              photoUrl != null ? NetworkImage(photoUrl!) : null,
              child: photoUrl == null
                  ? const Icon(
                Icons.person_rounded,
                size: 44,
                color: Color(0xFF7C3AED),
              )
                  : null,
            ),
          ),
        ),

        // Upload loading overlay
        if (uploading)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x88000000),
              ),
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

        // + button
        if (!uploading)
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 2, bottom: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Info row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF4F46E5).withOpacity(0.18)
                : const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF6D28D9), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white.withOpacity(0.82) : const Color(0xFF334155),
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Role badge ───────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        role.toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ─── Glass tab bar ────────────────────────────────────────────────────────────
class _GlassTabBar extends StatelessWidget {
  final bool isDark;
  const _GlassTabBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.14)
                    : Colors.black.withOpacity(0.06),
                width: 0.8,
              ),
            ),
            child: TabBar(
              tabs: const [Tab(text: 'Choose Cover')],
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.poppins(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
              ),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pinned tab delegate ──────────────────────────────────────────────────────
class _PinnedTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool isDark;

  const _PinnedTabDelegate({required this.child, required this.isDark});

  @override
  double get minExtent => 66;

  @override
  double get maxExtent => 66;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: isDark
          ? AppColors.bgPrimary.withOpacity(0.82)
          : AppColors.bgPrimaryLight.withOpacity(0.82),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedTabDelegate old) =>
      old.isDark != isDark || old.child != child;
}

// ─── Cover picker grid ────────────────────────────────────────────────────────
class _CoverPickerGrid extends StatelessWidget {
  final String uid;
  final String? activeCoverUrl;
  final void Function(String url) onSelect;
  final bool isDark;

  const _CoverPickerGrid({
    required this.uid,
    required this.activeCoverUrl,
    required this.onSelect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
      physics: const BouncingScrollPhysics(),
      itemCount: _coverSeeds.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final seed = _coverSeeds[index];
        final imageUrl = 'https://picsum.photos/seed/$seed/800/500';
        final isActive = activeCoverUrl == imageUrl;

        return GestureDetector(
          onTap: () => onSelect(imageUrl),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF7C3AED)
                    : Colors.transparent,
                width: isActive ? 3 : 0,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.38),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isActive ? 18 : 20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) =>
                    progress == null
                        ? child
                        : Container(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  // Subtle overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0x44000000),
                        ],
                      ),
                    ),
                  ),
                  // Active checkmark
                  if (isActive)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF7C3AED),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Glass circle control ─────────────────────────────────────────────────────
class _GlassCircleControl extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassCircleControl({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.16),
              border: Border.all(
                color: Colors.white.withOpacity(0.38),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

// ─── Loading / Error screens ──────────────────────────────────────────────────
class _LoadingScreen extends StatelessWidget {
  final bool isDark;
  const _LoadingScreen({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgPrimary : AppColors.bgPrimaryLight,
      body: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7C3AED),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Error: $message',
          style: GoogleFonts.poppins(color: Colors.red),
        ),
      ),
    );
  }
}