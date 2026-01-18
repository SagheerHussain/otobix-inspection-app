import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_inspection_app/constants/app_colors.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final String type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.type = "info",
    this.isRead = false,
  });
}

class NotificationsController extends GetxController {
  final RxList<NotificationItem> items = <NotificationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    seedDemo();
  }

  void seedDemo() {
    items.assignAll([
      NotificationItem(
        id: "1",
        title: "Lead Approved",
        message:
            "Admin approved Amit Parekh lead. You can start inspection now.",
        createdAt: DateTime.now().subtract(const Duration(minutes: 7)),
        type: "success",
        isRead: false,
      ),
      NotificationItem(
        id: "2",
        title: "New Allocation",
        message: "You have received a new lead allocation for today.",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        type: "info",
        isRead: false,
      ),
      NotificationItem(
        id: "3",
        title: "Reschedule Requested",
        message: "Customer requested time change. Please review & update.",
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        type: "warning",
        isRead: true,
      ),
    ]);
  }

  int get unreadCount => items.where((e) => !e.isRead).length;

  void markAllRead() {
    for (final n in items) {
      n.isRead = true;
    }
    items.refresh();
  }

  void clearAll() {
    items.clear();
  }

  void markRead(String id) {
    final i = items.indexWhere((e) => e.id == id);
    if (i == -1) return;
    items[i].isRead = true;
    items.refresh();
  }

  Future<void> refreshList() async {
    // 🔄 future: API call
    await Future.delayed(const Duration(milliseconds: 700));
    // demo: nothing
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";
    if (diff.inDays < 7) return "${diff.inDays} days ago";
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  IconData _iconForType(String t) {
    final s = t.toLowerCase();
    if (s.contains("success")) return Icons.check_circle_rounded;
    if (s.contains("warning")) return Icons.warning_rounded;
    if (s.contains("danger") || s.contains("error")) return Icons.error_rounded;
    return Icons.notifications_rounded;
  }

  Color _toneBg(String t) {
    final s = t.toLowerCase();
    if (s.contains("success")) return const Color(0xFFE9FBF2);
    if (s.contains("warning")) return const Color(0xFFFFF7ED);
    if (s.contains("danger") || s.contains("error"))
      return const Color(0xFFFFE4E6);
    return const Color(0xFFEFF6FF);
  }

  Color _toneFg(String t) {
    final s = t.toLowerCase();
    if (s.contains("success")) return const Color(0xFF16A34A);
    if (s.contains("warning")) return const Color(0xFFF97316);
    if (s.contains("danger") || s.contains("error"))
      return const Color(0xFFEF4444);
    return const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    final NotificationsController c = Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
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
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Obx(() {
                      final unread = c.unreadCount;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: unread > 0
                              ? const Color(0xFFFFF7ED)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: unread > 0
                                ? const Color(0xFFFED7AA)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          unread > 0 ? "$unread Unread" : "All read",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: unread > 0
                                ? const Color(0xFFF97316)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (c.items.isEmpty) {
                  return _EmptyNotifications(onReload: () => c.seedDemo());
                }

                return RefreshIndicator(
                  color: AppColors.green,
                  onRefresh: c.refreshList,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    itemCount: c.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final n = c.items[i];
                      final icon = _iconForType(n.type);
                      final bg = _toneBg(n.type);
                      final fg = _toneFg(n.type);

                      return InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          c.markRead(n.id);
                          // ✅ Future: navigate based on type (approved -> open lead etc.)
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // icon bubble
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(icon, color: fg, size: 22),
                              ),
                              const SizedBox(width: 12),

                              // text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _timeAgo(n.createdAt),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      n.message,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF475569),
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              // unread dot
                              if (!n.isRead)
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                )
                              else
                                const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  final VoidCallback onReload;
  const _EmptyNotifications({required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_off_rounded,
                size: 42,
                color: AppColors.green,
              ),
              const SizedBox(height: 10),
              const Text(
                "No notifications",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "You're all caught up. Any updates will appear here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onReload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Reload",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
