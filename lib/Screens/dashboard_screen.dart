import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:otobix_inspection_app/Screens/notification_screen.dart';
import 'package:otobix_inspection_app/widgets/dashboard_shimmer.dart';
import 'package:otobix_inspection_app/Screens/profile_screen.dart';
import 'package:otobix_inspection_app/Screens/inspection_view.dart';
import 'package:otobix_inspection_app/constants/app_colors.dart';
import 'package:otobix_inspection_app/models/leads_model.dart';
import 'package:otobix_inspection_app/Controller/car_inspection_controller.dart';
import 'package:url_launcher/url_launcher.dart';

const String kStaticLocationTitle = "Ajoy Nagar, Santoshpur";

ButtonStyle primaryBtnStyle({required Color bg, Color? disabledBg}) {
  return ElevatedButton.styleFrom(
    backgroundColor: bg,
    foregroundColor: Colors.white,
    disabledBackgroundColor: disabledBg ?? bg.withOpacity(0.55),
    disabledForegroundColor: Colors.white.withOpacity(0.9),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.symmetric(horizontal: 18),
  ).copyWith(
    shadowColor: WidgetStateProperty.all(bg.withOpacity(0.35)),
    elevation: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return 0;
      if (states.contains(WidgetState.pressed)) return 1;
      return 3;
    }),
    overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.10)),
  );
}

ButtonStyle outlineBtnStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF0F172A),
    disabledForegroundColor: const Color(0xFF0F172A).withOpacity(0.5),
    side: const BorderSide(color: Color(0xFFE2E8F0)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.symmetric(horizontal: 18),
  );
}

String normalizeInspectionStatus(String? raw) {
  var s = (raw ?? '').trim().toLowerCase();
  if (s.isEmpty) return '';

  if (s == 'sheduled') s = 'scheduled';
  if (s == 'resheduled') s = 're-scheduled';
  if (s == 'rescheduled') s = 're-scheduled';
  if (s == 're scheduled') s = 're-scheduled';
  if (s == 'cancelled') s = 'canceled';

  if (s.contains('cancel')) return 'canceled';
  if (s.contains('inspect')) return 'inspected';
  if (s.contains('running')) return 'running';
  if (s.contains('resched')) return 're-scheduled';
  if (s.contains('re') && s.contains('sched')) return 're-scheduled';
  if (s.contains('sched')) return 'scheduled';

  return s;
}

String prettyStatusLabelFromRaw(String? raw) {
  final n = normalizeInspectionStatus(raw);
  if (n == 'canceled') return 'Canceled';
  if (n == 'scheduled') return 'Scheduled';
  if (n == 're-scheduled') return 'Re-Scheduled';
  if (n == 'running') return 'Running';
  if (n == 'inspected') return 'Inspected';
  return (raw ?? '').trim().isEmpty ? 'Scheduled' : raw!.trim();
}

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CarInspectionStepperController controller = Get.put(
    CarInspectionStepperController(),
  );

  // ✅ PageController for horizontal scrolling between tabs
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _controllerToUi(controller.dashboardTabIndex.value),
    );

    // ✅ Listen to page changes
    _pageController.addListener(() {
      if (_pageController.page?.round() != null) {
        final pageIndex = _pageController.page!.round();
        if (pageIndex >= 0 && pageIndex < _uiToController.length) {
          final ctrlIndex = _uiToController[pageIndex];
          if (controller.dashboardTabIndex.value != ctrlIndex) {
            controller.setDashboardTab(ctrlIndex);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _timeGreeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return "Good Morning!";
    if (h >= 12 && h < 17) return "Good Afternoon!";
    if (h >= 17 && h < 21) return "Good Evening!";
    return "Good Night!";
  }

  static const _uiToController = <int>[1, 0, 2, 3, 4];
  static const _uiLabels = <String>[
    "Scheduled",
    "Canceled",
    "Re-Scheduled",
    "Running",
    "Inspected",
  ];

  int _controllerToUi(int ctrlIdx) {
    final i = _uiToController.indexOf(ctrlIdx);
    return i < 0 ? 0 : i;
  }

  String _labelForControllerTab(int ctrlIdx) {
    final ui = _controllerToUi(ctrlIdx);
    return _uiLabels[ui];
  }

  String _wantedNormalizedForControllerTab(int ctrlIdx) {
    if (ctrlIdx == 0) return 'canceled';
    if (ctrlIdx == 1) return 'scheduled';
    if (ctrlIdx == 2) return 're-scheduled';
    if (ctrlIdx == 3) return 'running';
    if (ctrlIdx == 4) return 'inspected';
    return 'scheduled';
  }

  List<LeadsData> _filterByTab(List<LeadsData> all, int ctrlIdx) {
    final want = _wantedNormalizedForControllerTab(ctrlIdx);
    return all
        .where((e) => normalizeInspectionStatus(e.inspectionStatus) == want)
        .toList();
  }

  // ✅ Helper method to build content for each tab
  Widget _buildTabContent(int ctrlIdx, BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    int crossAxisCount = 1;
    if (w >= 1200) {
      crossAxisCount = 3;
    } else if (w >= 800) {
      crossAxisCount = 2;
    }

    return Obx(() {
      final all = controller.inspectionList;

      if (controller.isLoading.value) {
        return DashboardShimmer(crossAxisCount: crossAxisCount);
      }

      final tabbed = _filterByTab(all, ctrlIdx);
      final items = controller.dashboardApplySearch(tabbed);
      final q = controller.dashboardSearchQuery.value;

      if (all.isEmpty) {
        return RefreshIndicator(
          color: AppColors.green,
          onRefresh: () async => controller.getInspectionList(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: _EmptyStatePro(
                      title: "No Data yet",
                      onPrimary: () => controller.getInspectionList(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }

      if (items.isEmpty) {
        return RefreshIndicator(
          color: AppColors.green,
          onRefresh: () async => controller.getInspectionList(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: _EmptyStatePro(
                      title: q.isNotEmpty
                          ? "No results for \"$q\""
                          : "No Leads",
                      primaryText: "Refresh",
                      onPrimary: () => controller.getInspectionList(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }

      final bool hideCardActions = ctrlIdx == 0 || ctrlIdx == 4;

      return RefreshIndicator(
        color: AppColors.green,
        onRefresh: () async => controller.getInspectionList(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
              child: Row(
                children: [
                  const SizedBox(width: 6),
                  Text(
                    _labelForControllerTab(ctrlIdx),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "${items.length}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: crossAxisCount == 1
                  ? ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => ScheduleCardExact(
                        controller: controller,
                        item: items[i],
                        hideActions: hideCardActions,
                      ),
                    )
                  : GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: hideCardActions ? 460 : 520,
                      ),
                      itemBuilder: (context, i) => ScheduleCardExact(
                        controller: controller,
                        item: items[i],
                        hideActions: hideCardActions,
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _timeGreeting();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar: Obx(() {
        final selectedCtrlIndex = controller.dashboardTabIndex.value;
        final selectedUiIndex = _controllerToUi(selectedCtrlIndex);

        final isIOS = Platform.isIOS;

        // ✅ Manual safe-area padding (no double safe area)
        final bottomInset = MediaQuery.of(context).padding.bottom;
        final safeBottom = isIOS ? bottomInset.ceilToDouble() : bottomInset;

        // ✅ Sizes (tuned for iOS)
        final double iconSize = isIOS ? 20.0 : 22.0;
        final double fontSize = isIOS ? 9.0 : 10.0;
        final double spacing = isIOS ? 2.0 : 3.0;

        // ✅ Total bar height for CONTENT only (not including safeBottom)
        final double barH = isIOS ? 60.0 : 60.0;

        Widget navIcon(String path, bool isActive) {
          final c = isActive ? AppColors.green : const Color(0xFF64748B);
          return ColorFiltered(
            colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
            child: Image.asset(
              path,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
          );
        }

        Widget navLabel(String text, bool isActive) {
          return Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w800,
              fontSize: fontSize,
              height: 1.0,
              color: isActive ? AppColors.green : const Color(0xFF64748B),
            ),
          );
        }

        Widget navItem({
          required String path,
          required String text,
          required bool isActive,
          required VoidCallback onTap,
        }) {
          return Expanded(
            child: InkWell(
              onTap: onTap,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: SizedBox(
                height: barH,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    navIcon(path, isActive),
                    SizedBox(height: spacing),
                    // ✅ Give label enough room on iOS (no fixed tiny height like 11)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: navLabel(text, isActive),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return MediaQuery(
          // ✅ prevent iOS text scaling from causing tiny overflows inside bottom bar only
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Container(
            height: barH + safeBottom,
            padding: EdgeInsets.only(
              bottom: safeBottom,
              left: isIOS ? 4 : 0,
              right: isIOS ? 4 : 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalItems = _uiToController.length;
                  final availableWidth = constraints.maxWidth - (isIOS ? 8 : 0);
                  final itemW = availableWidth / totalItems;
                  final left = itemW * selectedUiIndex;

                  return Stack(
                    children: [
                      // ✅ Top indicator line
                      Positioned(
                        top: 0,
                        left: left + (isIOS ? 4 : 0),
                        width: itemW,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            height: 3,
                            width: itemW * 0.6,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),

                      // ✅ Items row
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              navItem(
                                path: "assets/images/scheduled.png",
                                text: "Scheduled",
                                isActive: selectedCtrlIndex == 1,
                                onTap: () {
                                  const uiIndex = 0;
                                  final ctrlIndex = _uiToController[uiIndex];
                                  controller.setDashboardTab(ctrlIndex);
                                  _pageController.animateToPage(
                                    uiIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                              navItem(
                                path: "assets/images/canceled.png",
                                text: "Canceled",
                                isActive: selectedCtrlIndex == 0,
                                onTap: () {
                                  const uiIndex = 1;
                                  final ctrlIndex = _uiToController[uiIndex];
                                  controller.setDashboardTab(ctrlIndex);
                                  _pageController.animateToPage(
                                    uiIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                              navItem(
                                path: "assets/images/reschedule.png",
                                text: "Re-Scheduled",
                                isActive: selectedCtrlIndex == 2,
                                onTap: () {
                                  const uiIndex = 2;
                                  final ctrlIndex = _uiToController[uiIndex];
                                  controller.setDashboardTab(ctrlIndex);
                                  _pageController.animateToPage(
                                    uiIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                              navItem(
                                path: "assets/images/running.png",
                                text: "Running",
                                isActive: selectedCtrlIndex == 3,
                                onTap: () {
                                  const uiIndex = 3;
                                  final ctrlIndex = _uiToController[uiIndex];
                                  controller.setDashboardTab(ctrlIndex);
                                  _pageController.animateToPage(
                                    uiIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                              navItem(
                                path: "assets/images/inspected.png",
                                text: "Inspected",
                                isActive: selectedCtrlIndex == 4,
                                onTap: () {
                                  const uiIndex = 4;
                                  final ctrlIndex = _uiToController[uiIndex];
                                  controller.setDashboardTab(ctrlIndex);
                                  _pageController.animateToPage(
                                    uiIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      }),

      body: SafeArea(
        child: Column(
          children: [
            // ✅ HEADER SECTION
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 28, 28),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => Text(
                                "Hi ${controller.firstName},",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  height: 1.05,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              greeting,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(999),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  InkWell(
                                    onTap: () => Get.to(NotificationsScreen()),
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.notifications_none_rounded,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () => Get.to(() => ProfileScreen()),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ✅ SEARCH
                    Obx(() {
                      final q = controller.dashboardSearchQuery.value;
                      return Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: controller.dashboardSearchCtrl,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText:
                                "Search customer, phone, city, vehicle...",
                            hintStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF64748B),
                            ),
                            suffixIcon: q.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: controller.clearDashboardSearch,
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ✅ MAIN CONTENT WITH PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                itemCount: _uiToController.length,
                onPageChanged: (pageIndex) {
                  // This is already handled in the PageController listener
                },
                itemBuilder: (context, pageIndex) {
                  final ctrlIndex = _uiToController[pageIndex];
                  return _buildTabContent(ctrlIndex, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStatePro extends StatelessWidget {
  final String title;
  final String primaryText;
  final VoidCallback? onPrimary;

  const _EmptyStatePro({
    required this.title,
    this.primaryText = "Refresh",
    this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ Crop extra transparent padding from bottom
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 0.88, // ✅ tweak 0.80 - 0.95 if needed
            child: Image.asset(
              "assets/images/nodata.png",
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          title, // ✅ use your title param
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),

        const SizedBox(height: 8),

        InkWell(
          onTap: onPrimary,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              "assets/images/reload.png",
              height: 26,
              width: 26,
            ),
          ),
        ),
      ],
    );
  }
}

class ScheduleCardExact extends StatelessWidget {
  final LeadsData item;
  final bool hideActions;
  final CarInspectionStepperController controller;

  const ScheduleCardExact({
    super.key,
    required this.item,
    this.hideActions = false,
    required this.controller,
  });

  String _safe(String? v, [String fallback = "-"]) =>
      (v == null || v.trim().isEmpty) ? fallback : v.trim();

  String _shortId(String? id) {
    final v = _safe(id, "");
    if (v.isEmpty) return "-";
    if (v.length <= 10) return v;
    return "${v.substring(0, 10)}...";
  }

  String _initials(String? name) {
    final n = _safe(name, "");
    if (n.isEmpty) return "NA";
    final parts = n.split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return "NA";
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _formatCreatedAt(String? iso) {
    if (iso == null || iso.trim().isEmpty) return "-";
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final m = months[d.month - 1];
    final dd = d.day.toString().padLeft(2, "0");
    final hh = d.hour.toString().padLeft(2, "0");
    final mm = d.minute.toString().padLeft(2, "0");
    return "$m $dd,\n$hh:$mm";
  }

  String _prettyTime(String? raw) {
    if (raw == null) return "";
    var t = raw.trim();
    if (t.isEmpty) return "";
    t = t.replaceAll(":00:00", ":00");
    t = t.replaceAll(RegExp(r"\s+"), " ");
    return t;
  }

  // ✅ NEW: ISO -> Local (inspectionDateTime)
  DateTime? _parseIsoToLocal(String? iso) {
    if (iso == null) return null;
    final s = iso.trim();
    if (s.isEmpty) return null;
    final d = DateTime.tryParse(s);
    if (d == null) return null;
    return d.toLocal();
  }

  String _fmtLocalDateTime(DateTime d) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final m = months[d.month - 1];
    final dd = d.day.toString().padLeft(2, "0");
    final hh = d.hour.toString().padLeft(2, "0");
    final mm = d.minute.toString().padLeft(2, "0");
    return "$m $dd,\n$hh:$mm";
  }

  String _normalizePhone(String input) {
    final s = input.trim();
    if (s.isEmpty) return s;
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
      if (isDigit) buf.write(ch);
      if (i == 0 && ch == '+') buf.write(ch);
    }
    return buf.toString();
  }

  String? _phoneFromApi() {
    final raw = item.customerContactNumber;
    if (raw == null) return null;
    final normalized = _normalizePhone(raw);
    if (normalized.isEmpty) return null;
    return normalized;
  }

  Future<void> _launchDialer(BuildContext context) async {
    final phone = _phoneFromApi();
    if (phone == null) return;
    final uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchSms(BuildContext context) async {
    final phone = _phoneFromApi();
    if (phone == null) return;
    final uri = Uri(scheme: 'sms', path: phone);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchMaps(BuildContext context) async {
    final address = _safe(item.inspectionAddress, "");
    final city = _safe(item.city, "");
    String location = "";
    if (address != "-" && address.isNotEmpty) {
      location = address;
      if (city != "-" && city.isNotEmpty) location += ", $city";
    } else if (city != "-" && city.isNotEmpty) {
      location = city;
    }
    if (location.isEmpty) return;

    final encodedLocation = Uri.encodeComponent(location);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedLocation',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showNotApprovedToast() {
    Get.showSnackbar(
      GetSnackBar(
        message: "Not approved by admin yet",
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final bool isSmall = w < 380;
    final double mapH = isSmall ? 165 : 180;

    final statusText = prettyStatusLabelFromRaw(item.inspectionStatus);

    final jobNumber =
        item.appointmentId != null && item.appointmentId!.trim().isNotEmpty
        ? item.appointmentId!.trim()
        : "#${_shortId(item.id)}";

    // ✅ FIX 1: Use item.model (exists in model), not vehicleModel (doesn't exist)
    final vehicleTitle = _safe(
      "${_safe(item.make, "")} ${_safe(item.model, "")}".trim(),
      "Vehicle",
    );

    final variantText = _safe(item.variant, "");
    final vehicleFullTitle = (variantText == "-" || variantText.isEmpty)
        ? vehicleTitle
        : "$vehicleTitle • $variantText";

    // ✅ FIX 2: Use ownerName (exists), not customerName (doesn't exist)
    final customerName = _safe(item.ownerName, "N/A");
    final customerInitials = _initials(item.ownerName);

    // ✅ FIX 3: Date & Time - Use only existing fields
    String dateTimeText;
    final localInspectionDT = _parseIsoToLocal(item.inspectionDateTime);

    if (localInspectionDT != null) {
      dateTimeText = _fmtLocalDateTime(localInspectionDT);
    } else {
      // Since requestedInspectionDate/Time don't exist in model, use createdAt
      dateTimeText = _formatCreatedAt(item.createdAt);
    }

    final remarks = _safe(
      item.remarks,
      _safe(item.additionalNotes, "No notes"),
    );

    // ✅ FIX 4: Location - Use only existing fields
    final locTitle = _safe(item.city, kStaticLocationTitle);
    final locSubtitle = _safe(
      item.inspectionAddress, // ✅ This field exists in model
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusChipExact(text: statusText),
                  const Spacer(),
                  Text(
                    jobNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                vehicleFullTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black54,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _launchMaps(context),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: mapH,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EEF4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          "assets/images/location.png",
                          fit: BoxFit.cover,
                        ),
                        Container(color: Colors.white.withOpacity(0.08)),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 14,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        locTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        locSubtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfoCard(
                      label: "Customer",
                      leading: _InitialCircle(text: customerInitials),
                      value: customerName,
                      valueMaxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniInfoCard(
                      label: "DATE & TIME",
                      leading: const _IconCircle(
                        icon: Icons.calendar_month_rounded,
                      ),
                      value: dateTimeText,
                      valueMaxLines: 2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFFF97316),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        remarks,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7C2D12),
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (!hideActions) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _UpdateStatusButton(item: item)),
                    const SizedBox(width: 10),
                    _CircleAction(
                      icon: Icons.call_rounded,
                      bg: const Color(0xFFEFF6FF),
                      fg: const Color(0xFF2563EB),
                      onTap: () => _launchDialer(context),
                    ),
                    const SizedBox(width: 10),
                    _CircleAction(
                      icon: Icons.chat_bubble_rounded,
                      bg: const Color(0xFFEFF6FF),
                      fg: const Color(0xFF2563EB),
                      onTap: () => _launchSms(context),
                    ),
                    const SizedBox(width: 10),
                    _CircleAction(
                      icon: Icons.navigation_rounded,
                      bg: const Color(0xFFEF4444),
                      fg: Colors.white,
                      onTap: () async {
                        final telecallingId = (item.id ?? "").trim();
                        if (telecallingId.isEmpty) {
                          Get.showSnackbar(
                            GetSnackBar(
                              message: "Lead id missing",
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.red,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(12),
                              borderRadius: 10,
                            ),
                          );
                          return;
                        }
                        Get.to(() => CarInspectionStepperScreen(lead: item));

                        // ✅ Existing date time (same item ka)
                        final DateTime dt =
                            _parseIsoToLocal(item.inspectionDateTime) ??
                            DateTime.tryParse(
                              (item.createdAt ?? "").trim(),
                            )?.toLocal() ??
                            DateTime.now();

                        // ✅ Existing remarks (same item ka)
                        final String r = (item.remarks ?? "").trim().isNotEmpty
                            ? item.remarks!.trim()
                            : (item.additionalNotes ?? "").trim();

                        // ✅ Call your new Running API (await recommended)
                        await controller.updateTelecallingRunning(
                          telecallingId: telecallingId,
                          inspectionDateTimeLocal: dt,
                          remarks: r,
                        );

                        // ✅ Navigate
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChipExact extends StatelessWidget {
  final String text;
  const _StatusChipExact({required this.text});

  String _n(String t) => t.trim().toLowerCase();

  Color _bg(String t) {
    final s = _n(t);
    if (s.contains('cancel')) return const Color(0xFFFFE4E6);
    if (s.contains('re-sched')) return const Color(0xFFFFF7ED);
    if (s.contains('running')) return const Color(0xFFEDE9FE);
    if (s.contains('inspect')) return const Color(0xFFE0F2FE);
    if (s.contains('sched')) return const Color(0xFFE9FBF2);
    return const Color(0xFFF1F5F9);
  }

  Color _border(String t) {
    final s = _n(t);
    if (s.contains('cancel')) return const Color(0xFFFDA4AF);
    if (s.contains('re-sched')) return const Color(0xFFFED7AA);
    if (s.contains('running')) return const Color(0xFFC4B5FD);
    if (s.contains('inspect')) return const Color(0xFF93C5FD);
    if (s.contains('sched')) return const Color(0xFFBBF7D0);
    return const Color(0xFFE2E8F0);
  }

  Color _fg(String t) {
    final s = _n(t);
    if (s.contains('cancel')) return const Color(0xFFEF4444);
    if (s.contains('re-sched')) return const Color(0xFFF97316);
    if (s.contains('running')) return const Color(0xFF6D28D9);
    if (s.contains('inspect')) return const Color(0xFF1D4ED8);
    if (s.contains('sched')) return const Color(0xFF16A34A);
    return const Color(0xFF334155);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _bg(text),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _border(text)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: _fg(text),
        ),
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final String label;
  final Widget leading;
  final String value;
  final int valueMaxLines;

  const _MiniInfoCard({
    required this.label,
    required this.leading,
    required this.value,
    this.valueMaxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78, // ✅ fixed height for all cards
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ keep leading size fixed so text gets consistent width
            SizedBox(width: 44, height: 44, child: Center(child: leading)),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // ✅ this is the main fix
                  Flexible(
                    child: Text(
                      value,
                      maxLines: valueMaxLines,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.05, // ✅ tighter so 2 lines fit in same height
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialCircle extends StatelessWidget {
  final String text;
  const _InitialCircle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF2563EB),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  const _IconCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(icon, color: const Color(0xFF64748B), size: 18),
    );
  }
}

class _UpdateStatusButton extends StatelessWidget {
  final LeadsData item;
  const _UpdateStatusButton({required this.item});

  static const _options = <String>["Reschedule", "Cancel"];

  String _fmtDate(DateTime d) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final m = months[d.month - 1];
    final dd = d.day.toString().padLeft(2, "0");
    return "$m $dd, ${d.year}";
  }

  String _fmtTime(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, "0");
    final mm = t.minute.toString().padLeft(2, "0");
    return "$hh:$mm";
  }

  static final ShapeBorder _menuShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
    side: const BorderSide(color: Color(0xFFF1F5F9)),
  );

  PopupMenuItem<String> _styledItem(String text, {required bool isLast}) {
    final isDanger = text.toLowerCase() == "cancel";
    return PopupMenuItem<String>(
      value: text, // ✅ IMPORTANT (onSelected works)
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: isDanger
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  Future<void> _openRescheduleDialog() async {
    final ctx = Get.context;
    if (ctx == null) return;

    DateTime? pickedDate;
    TimeOfDay? pickedTime;
    final remarksCtrl = TextEditingController();
    final RxBool isLoading = false.obs;

    try {
      await showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (dialogCtx) {
          return StatefulBuilder(
            builder: (dialogCtx, setLocal) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Reschedule",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _sheetField(
                          title: "Date",
                          value: pickedDate == null
                              ? "Choose date"
                              : _fmtDate(pickedDate!),
                          icon: Icons.calendar_month_rounded,
                          onTap: () async {
                            final now = DateTime.now();
                            final d = await showDatePicker(
                              context: dialogCtx,
                              initialDate: pickedDate ?? now,
                              firstDate: now,
                              lastDate: now.add(const Duration(days: 365)),
                            );
                            if (d != null) setLocal(() => pickedDate = d);
                          },
                        ),
                        const SizedBox(height: 10),
                        _sheetField(
                          title: "Time",
                          value: pickedTime == null
                              ? "Choose time"
                              : _fmtTime(pickedTime!),
                          icon: Icons.access_time_rounded,
                          onTap: () async {
                            final t = await showTimePicker(
                              context: dialogCtx,
                              initialTime: pickedTime ?? TimeOfDay.now(),
                            );
                            if (t != null) setLocal(() => pickedTime = t);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: remarksCtrl,
                          minLines: 2,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Remarks (required)",
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: isLoading.value
                                      ? null
                                      : () => Get.back(),
                                  style: outlineBtnStyle(),
                                  child: const Text(
                                    "Close",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Obx(() {
                                final disabled = isLoading.value;
                                return SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    style: primaryBtnStyle(bg: AppColors.green),
                                    onPressed: disabled
                                        ? null
                                        : () async {
                                            final remarks = remarksCtrl.text
                                                .trim();

                                            if (pickedDate == null ||
                                                pickedTime == null) {
                                              Get.showSnackbar(
                                                GetSnackBar(
                                                  message:
                                                      "Please select date & time",
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  margin: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  borderRadius: 10,
                                                ),
                                              );
                                              return;
                                            }

                                            if (remarks.isEmpty) {
                                              Get.showSnackbar(
                                                GetSnackBar(
                                                  message:
                                                      "Remarks are required",
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  margin: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  borderRadius: 10,
                                                ),
                                              );
                                              return;
                                            }

                                            final localDT = DateTime(
                                              pickedDate!.year,
                                              pickedDate!.month,
                                              pickedDate!.day,
                                              pickedTime!.hour,
                                              pickedTime!.minute,
                                            );

                                            final telecallingId =
                                                (item.id ?? "").trim();
                                            if (telecallingId.isEmpty) {
                                              Get.showSnackbar(
                                                GetSnackBar(
                                                  message: "Lead id missing",
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  margin: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  borderRadius: 10,
                                                ),
                                              );
                                              return;
                                            }

                                            final ctrl =
                                                Get.find<
                                                  CarInspectionStepperController
                                                >();

                                            isLoading.value = true;
                                            final ok = await ctrl
                                                .updateTelecallingReschedule(
                                                  telecallingId: telecallingId,
                                                  inspectionDateTimeLocal:
                                                      localDT,
                                                  remarks: remarks,
                                                );
                                            isLoading.value = false;

                                            if (ok) {
                                              Get.back();
                                              Get.showSnackbar(
                                                GetSnackBar(
                                                  message:
                                                      "Rescheduled successfully",
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                  backgroundColor:
                                                      AppColors.green,
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  margin: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  borderRadius: 10,
                                                ),
                                              );
                                            }
                                          },
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: disabled
                                          ? const SizedBox(
                                              key: ValueKey("loader"),
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              "Confirm",
                                              key: ValueKey("text"),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      remarksCtrl.dispose();
    }
  }

  Future<void> _openCancelDialog() async {
    final ctx = Get.context;
    if (ctx == null) return;

    final remarksCtrl = TextEditingController();
    final RxBool isLoading = false.obs;

    try {
      await showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (dialogCtx) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: remarksCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Remarks (required)",
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: isLoading.value
                                  ? null
                                  : () => Get.back(),
                              style: outlineBtnStyle(),
                              child: const Text(
                                "Close",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Obx(() {
                            final disabled = isLoading.value;
                            return SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                style: primaryBtnStyle(
                                  bg: const Color(0xFFEF4444),
                                ),
                                onPressed: disabled
                                    ? null
                                    : () async {
                                        final remarks = remarksCtrl.text.trim();
                                        if (remarks.isEmpty) {
                                          Get.showSnackbar(
                                            GetSnackBar(
                                              message: "Remarks are required",
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                              backgroundColor: Colors.red,
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              margin: const EdgeInsets.all(12),
                                              borderRadius: 10,
                                            ),
                                          );
                                          return;
                                        }

                                        final telecallingId = (item.id ?? "")
                                            .trim();
                                        if (telecallingId.isEmpty) {
                                          Get.showSnackbar(
                                            GetSnackBar(
                                              message: "Lead id missing",
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                              backgroundColor: Colors.red,
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              margin: const EdgeInsets.all(12),
                                              borderRadius: 10,
                                            ),
                                          );
                                          return;
                                        }

                                        final ctrl =
                                            Get.find<
                                              CarInspectionStepperController
                                            >();

                                        isLoading.value = true;
                                        final ok = await ctrl
                                            .updateTelecallingCancel(
                                              telecallingId: telecallingId,
                                              remarks: remarks,
                                            );
                                        isLoading.value = false;

                                        if (ok) {
                                          Get.back();
                                          Get.showSnackbar(
                                            GetSnackBar(
                                              message: "Cancelled successfully",
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                              backgroundColor: AppColors.green,
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              margin: const EdgeInsets.all(12),
                                              borderRadius: 10,
                                            ),
                                          );
                                        }
                                      },
                                child: disabled
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Confirm",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } finally {
      remarksCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (v) async {
        if (v == "Reschedule") {
          await _openRescheduleDialog();
        } else if (v == "Cancel") {
          await _openCancelDialog();
        }
      },
      offset: const Offset(0, 12),
      elevation: 18,
      color: Colors.white,
      shape: _menuShape,
      itemBuilder: (context) => [
        _styledItem("Reschedule", isLast: false),
        _styledItem("Cancel", isLast: true),
      ],
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Text(
              "Update Status",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9.h),
            ),
            Spacer(),
            Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final bool disabled;

  const _CircleAction({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color finalBg = disabled ? const Color(0xFFE2E8F0) : bg;
    final Color finalFg = disabled ? const Color(0xFF94A3B8) : fg;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.98 : 1,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: finalBg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: finalFg, size: 22),
        ),
      ),
    );
  }
}

Widget _sheetField({
  required String title,
  required String value,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    ),
  );
}
