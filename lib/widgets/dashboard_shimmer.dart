import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardShimmer extends StatelessWidget {
  final int crossAxisCount;
  const DashboardShimmer({super.key, required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    const pad = EdgeInsets.fromLTRB(18, 0, 18, 18);

    if (crossAxisCount == 1) {
      return ListView.separated(
        padding: pad,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => const _ShimmerScheduleCard(),
      );
    }

    return GridView.builder(
      padding: pad,
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 520,
      ),
      itemBuilder: (_, __) => const _ShimmerScheduleCard(),
    );
  }
}

class AppShimmer extends StatelessWidget {
  final Widget child;
  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE6EAF0),
      highlightColor: const Color(0xFFF8FAFC),
      period: const Duration(milliseconds: 1100),
      direction: ShimmerDirection.ltr,
      child: child,
    );
  }
}

class _SkelBox extends StatelessWidget {
  final double? w;
  final double h;
  final double r;
  const _SkelBox({super.key, this.w, required this.h, this.r = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFE6EAF0),
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

class _SkelCircle extends StatelessWidget {
  final double s;
  final double r;
  const _SkelCircle({super.key, required this.s, this.r = 999});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: const Color(0xFFE6EAF0),
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

class _MiniInfoSkeleton extends StatelessWidget {
  const _MiniInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: const [
          _SkelCircle(s: 34),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkelBox(w: 92, h: 10, r: 8),
                SizedBox(height: 8),
                _SkelBox(h: 12, r: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerScheduleCard extends StatelessWidget {
  const _ShimmerScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final bool isSmall = w < 380;
    final double mapH = isSmall ? 165 : 180;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: AppShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    _SkelBox(w: 74, h: 26, r: 999),
                    SizedBox(width: 8),
                    _SkelBox(w: 74, h: 26, r: 999),
                    Spacer(),
                    _SkelBox(w: 90, h: 14, r: 8),
                  ],
                ),
                const SizedBox(height: 12),

                const _SkelBox(h: 18, r: 10),
                const SizedBox(height: 8),
                const _SkelBox(w: 170, h: 16, r: 10),

                const SizedBox(height: 12),

                Container(
                  height: mapH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color(0xFFE6EAF0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            color: const Color(0xFFE6EAF0),
                            child: Stack(
                              children: const [
                                Positioned(
                                  left: 18,
                                  top: 18,
                                  child: _SkelBox(w: 90, h: 10, r: 8),
                                ),
                                Positioned(
                                  right: 22,
                                  top: 36,
                                  child: _SkelBox(w: 70, h: 10, r: 8),
                                ),
                                Positioned(
                                  left: 42,
                                  top: 62,
                                  child: _SkelBox(w: 120, h: 10, r: 8),
                                ),
                                Positioned(
                                  right: 30,
                                  top: 78,
                                  child: _SkelBox(w: 90, h: 10, r: 8),
                                ),
                                Positioned(
                                  left: 22,
                                  bottom: 54,
                                  child: _SkelBox(w: 100, h: 10, r: 8),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: const [
                                _SkelCircle(s: 34, r: 12),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _SkelBox(h: 12, r: 8),
                                      SizedBox(height: 6),
                                      _SkelBox(w: 220, h: 10, r: 8),
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

                const SizedBox(height: 14),

                Row(
                  children: const [
                    Expanded(child: _MiniInfoSkeleton()),
                    SizedBox(width: 12),
                    Expanded(child: _MiniInfoSkeleton()),
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
                    children: const [
                      _SkelCircle(s: 34, r: 12),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SkelBox(w: 88, h: 12, r: 8),
                            SizedBox(height: 10),
                            _SkelBox(h: 12, r: 8),
                            SizedBox(height: 6),
                            _SkelBox(w: 200, h: 12, r: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: const [
                    Expanded(child: _SkelBox(h: 52, r: 18)),
                    SizedBox(width: 10),
                    _SkelCircle(s: 52, r: 18),
                    SizedBox(width: 10),
                    _SkelCircle(s: 52, r: 18),
                    SizedBox(width: 10),
                    _SkelCircle(s: 52, r: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
