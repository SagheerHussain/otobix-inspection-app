import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_inspection_app/Controller/profile_controller.dart';
import 'package:otobix_inspection_app/constants/app_colors.dart';

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
          ),
        ],
      ),

      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          );
        }

        if (c.error.value.isNotEmpty && c.profile.value == null) {
          return _buildErrorState(c);
        }

        return RefreshIndicator(
          color: AppColors.green,
          onRefresh: () async => c.fetchProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(c),
                const SizedBox(height: 16),

                _buildSectionTitle(
                  title: "Account Details",
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 10),

                _buildDetailsCard(c),
                const SizedBox(height: 18),

                /// ✅ LOGOUT BUTTON WITH LOADING
                Obx(() => _buildLogoutButton(
                      isLoading: c.logoutloading.value,
                      onTap: c.logoutloading.value ? null : () => c.logout(),
                    )),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ===========================================================
  // HEADER
  // ===========================================================
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
            AppColors.green.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 37,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: c.hasImage
                ? ClipOval(
                    child: Image.network(
                      c.imageUrl,
                      width: 74,
                      height: 74,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(c),
                    ),
                  )
                : _avatarFallback(c),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  c.displayEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _roleBadge(c.displayRole),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(ProfileController c) {
    return Center(
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
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ===========================================================
  // DETAILS
  // ===========================================================
  Widget _buildDetailsCard(ProfileController c) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grey.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          _detailRow("Phone", c.displayPhone),
          _detailRow("Location", c.displayLocation),
          _detailRow("Address", c.primaryAddress),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.grey.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "—" : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // LOGOUT BUTTON
  // ===========================================================
  Widget _buildLogoutButton({
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.red.withOpacity(0.25)),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.red),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout_rounded,
                        color: AppColors.red, size: 20),
                    SizedBox(width: 10),
                    Text(
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
      ),
    );
  }

  // ===========================================================
  // ERROR STATE
  // ===========================================================
  Widget _buildErrorState(ProfileController c) {
    return Center(
      child: ElevatedButton(
        onPressed: c.fetchProfile,
        child: const Text("Retry"),
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.green),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
