import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_inspection_app/Controller/profile_controller.dart';
import 'package:otobix_inspection_app/Screens/login_screen.dart';
import 'package:otobix_inspection_app/constants/app_colors.dart';
import 'package:otobix_inspection_app/helpers/sharedpreference_helper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.black),
            onPressed: c.fetchProfile,
            tooltip: "Refresh",
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          );
        }

        if (c.error.value.isNotEmpty && c.profile.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildErrorCard(
                message: c.error.value,
                onRetry: c.fetchProfile,
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.green,
          onRefresh: () async => c.fetchProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Gradient Profile Header Card
                _buildHeaderCard(c),
                const SizedBox(height: 16),

                _buildSectionTitle(
                  title: "Account Details",
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 10),
                _buildDetailsCard(c),
                const SizedBox(height: 18),
                _buildLogoutButton(
                  onTap: () {
                    SharedPrefsHelper.clearAll();
                    Get.to(LoginPage());
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderCard(ProfileController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.green.withOpacity(0.95),
            AppColors.green.withOpacity(0.70),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.28),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: ClipOval(
              child: SizedBox(
                width: 74,
                height: 74,
                child: c.hasImage
                    ? Image.network(
                        c.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarFallback(c),
                      )
                    : _avatarFallback(c),
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.displayName.isEmpty ? "User" : c.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 14,
                      color: Colors.white.withOpacity(0.95),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        c.displayEmail.isEmpty
                            ? "email@domain.com"
                            : c.displayEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _roleBadge(c.displayRole.isEmpty ? "User" : c.displayRole),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.lightGreenAccent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(ProfileController c) {
    return Container(
      color: Colors.white.withOpacity(0.18),
      alignment: Alignment.center,
      child: Text(
        c.initials,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _roleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 14,
            color: Colors.white.withOpacity(0.95),
          ),
          const SizedBox(width: 6),
          Text(
            role,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions({
    required VoidCallback onEdit,
    required VoidCallback onChangePass,
  }) {
    return Row(
      children: [
        Expanded(
          child: _actionTile(
            title: "Edit Profile",
            icon: Icons.edit_rounded,
            onTap: onEdit,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionTile(
            title: "Security",
            icon: Icons.lock_outline_rounded,
            onTap: onChangePass,
          ),
        ),
      ],
    );
  }

  Widget _actionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.green, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.grey.withOpacity(0.55),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ✅ SECTION TITLE
  // ============================================================
  Widget _buildSectionTitle({required String title, required IconData icon}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.green, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ✅ DETAILS CARD (clean + modern)
  // ============================================================
  Widget _buildDetailsCard(ProfileController c) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grey.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _detailRow(
            icon: Icons.phone_outlined,
            title: "Phone",
            value: c.displayPhone,
            showDivider: true,
          ),
          _detailRow(
            icon: Icons.location_on_outlined,
            title: "Location",
            value: c.displayLocation,
            showDivider: true,
          ),
          _detailRow(
            icon: Icons.home_outlined,
            title: "Address",
            value: c.primaryAddress,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
    required bool showDivider,
  }) {
    final shownValue = (value.trim().isEmpty) ? "Not set" : value;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.grey.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shownValue,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey.withOpacity(0.55),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.grey.withOpacity(0.18),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorCard({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.red.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.red,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Try Again",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton({required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.red.withOpacity(0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.red, size: 20),
            const SizedBox(width: 10),
            const Text(
              "Log Out",
              style: TextStyle(
                color: AppColors.red,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
