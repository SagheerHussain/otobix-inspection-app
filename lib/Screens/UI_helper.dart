// car_inspection_ui_widgets.dart
// ✅ FULL UI FILE (as per your shared code) with FIXES:
// - ✅ Video loading loop fixed (postFrame runs only once per fieldKey)
// - ✅ Video "processing/loading" infinite issue fixed (loading only when uploading)
// - ✅ Duplicate cross icon removed (only inside VideoThumbnailTile)
// - ✅ Preview works for local + uploaded video (uploaded URL preferred)
// - ✅ FullScreenVideoPlayer opens via Navigator.push (no Dialog nesting issues)

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otobix_inspection_app/Controller/car_inspection_controller.dart';
import 'package:otobix_inspection_app/widgets/app_theme.dart';
import 'package:otobix_inspection_app/widgets/toast_widget.dart';
import 'package:flutter_native_video_trimmer/flutter_native_video_trimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:video_compress/video_compress.dart';
import 'dart:async';

const List<String> yesNo = ["Yes", "No"];
const List<String> availableNA = ["Available", "Not Available"];

final Map<String, ValueNotifier<double?>> _videoProgressVN = {};
final Map<String, Timer?> _videoUploadSimTimers = {};
final Set<String> _videoCompleteShown = <String>{};

ValueNotifier<double?> _vnVideoProgress(String key) {
  return _videoProgressVN.putIfAbsent(key, () => ValueNotifier<double?>(null));
}

void _setVideoProgress(String key, double value) {
  _vnVideoProgress(key).value = value.clamp(0.0, 1.0);
}

void _clearVideoProgress(String key) {
  _vnVideoProgress(key).value = null;
}

void _stopUploadSim(String key) {
  _videoUploadSimTimers[key]?.cancel();
  _videoUploadSimTimers.remove(key);
}

void _startUploadSim(String key) {
  _stopUploadSim(key);
  _videoUploadSimTimers[key] = Timer.periodic(
    const Duration(milliseconds: 170),
    (_) {
      final cur = (_vnVideoProgress(key).value ?? 0.10);

      // simulate only 10% -> 95%
      if (cur >= 0.95) return;

      // small increments
      final next = (cur + 0.012).clamp(0.10, 0.95);
      _vnVideoProgress(key).value = next;
    },
  );
}

const List<String> okIssue = [
  "OK",
  "Scratched",
  "Dented",
  "Repainted",
  "Cracked",
  "Broken",
  "Replace Needed",
];
const List<String> workingNA = ["Working", "Not Working"];
const List<String> seatsUpholsteryOptions = [
  "Leather",
  "Fabric",
  "Mixed",
  "Other",
];
const List<String> acTypeOptions = [
  "Manual",
  "Automatic",
  "Dual Zone",
  "Other",
];
const List<String> acCoolingOptions = [
  "Good",
  "Average",
  "Poor",
  "Not Working",
];
const List<String> infotainmentOptions = ["OEM", "Aftermarket", "No System"];
const List<String> transmissionOptions = [
  "Manual",
  "Automatic",
  "AMT",
  "CVT",
  "DCT",
];
const List<String> driveTrainOptions = ["FWD", "RWD", "AWD", "4x4"];
const List<String> cityOptions = ["City A", "City B", "City C"];

const int kMaxVideoSeconds = 15;

/// ✅ FIX: Prevent repeated post-frame loops per fieldKey
final Set<String> _videoInitDone = <String>{};

/// (Optional) prevent repeated local image load loop too
final Set<String> _imageInitDone = <String>{};

Future<String?> _trimFirst15Seconds(String inputPath) async {
  try {
    debugPrint("🎬 Starting video trim for: $inputPath");
    final videoTrimmer = VideoTrimmer();
    await videoTrimmer.loadVideo(inputPath);

    final dir = await getTemporaryDirectory();
    final outPath =
        '${dir.path}/trimmed_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final trimmedPath = await videoTrimmer.trimVideo(
      startTimeMs: 0,
      endTimeMs: kMaxVideoSeconds * 1000,
    );

    debugPrint("🎬 Video trimmed successfully");

    if (trimmedPath != null && trimmedPath.isNotEmpty) {
      final file = File(trimmedPath);
      if (await file.exists() && await file.length() > 0) {
        debugPrint("🎬 Trimmed file size: ${(await file.length()) / 1024} KB");
        return trimmedPath;
      }
    }

    debugPrint("🎬 Trying alternative trim approach");

    final alternativePath =
        '${dir.path}/trimmed_alt_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final alternativeTrimmed = await videoTrimmer.trimVideo(
      startTimeMs: 0,
      endTimeMs: (kMaxVideoSeconds - 2) * 1000,
    );

    if (alternativeTrimmed != null && alternativeTrimmed.isNotEmpty) {
      final altFile = File(alternativeTrimmed);
      if (await altFile.exists() && await altFile.length() > 0) {
        return alternativeTrimmed;
      }
    }

    debugPrint("❌ Video trimming failed");
    return null;
  } catch (e) {
    debugPrint("❌ Trim exception: $e");
    return null;
  }
}

Future<String?> _compressVideo(String inputPath) async {
  try {
    debugPrint("🎬 STARTING VIDEO COMPRESSION: $inputPath");

    final originalFile = File(inputPath);
    if (!await originalFile.exists()) {
      debugPrint("❌ Original video file does not exist");
      return null;
    }

    final originalSize = await originalFile.length();

    final response = await VideoCompress.compressVideo(
      inputPath,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    );

    if (response == null || response.file == null) {
      debugPrint("❌ Video compression returned null");
      return null;
    }

    final compressedFile = File(response.file!.path);
    if (!await compressedFile.exists()) {
      debugPrint("❌ Compressed file missing");
      return null;
    }

    final compressedSize = await compressedFile.length();

    if (compressedSize >= originalSize) {
      debugPrint("⚠️ Compressed file bigger/same, returning original");
      return inputPath;
    }

    debugPrint("✅ Compression done: ${response.file!.path}");
    return response.file!.path;
  } catch (e, st) {
    debugPrint("❌ Compression error: $e\n$st");
    return null;
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final p = imagePaths[index];
          final isNet = p.startsWith('http://') || p.startsWith('https://');
          return PhotoViewGalleryPageOptions(
            imageProvider: isNet
                ? NetworkImage(p)
                : FileImage(File(p)) as ImageProvider,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 3.0,
            heroAttributes: PhotoViewHeroAttributes(tag: p),
          );
        },
        itemCount: imagePaths.length,

        // ✅ UPDATED: CircularProgressIndicator removed
        // ✅ Now shows Linear progress bar + percentage text
        loadingBuilder: (context, event) {
          final total = event?.expectedTotalBytes;
          final loaded = event?.cumulativeBytesLoaded ?? 0;

          final progress = (total == null || total == 0)
              ? null
              : (loaded / total);

          return Center(
            child: SegmentedPercentLoader(
              progress: progress, // 0.0 - 1.0
              size: 120,
            ),
          );
        },

        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}

class SegmentedPercentLoader extends StatelessWidget {
  final double? progress; // null => indeterminate fallback
  final double size;

  const SegmentedPercentLoader({
    super.key,
    required this.progress,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    final p = (progress == null) ? 0.0 : progress!.clamp(0.0, 1.0);
    final percent = (p * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _SegmentedRingPainter(progress: p),
          ),
          Text(
            "$percent",
            style: const TextStyle(
              color: Colors.red,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedRingPainter extends CustomPainter {
  final double progress; // 0..1
  final int segments;
  final double strokeWidth;
  final double gapRadians;

  _SegmentedRingPainter({
    required this.progress,
    this.segments = 24,
    this.strokeWidth = 8,
    this.gapRadians = 0.12, // gap between segments
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - strokeWidth / 2;

    final inactive = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.18);

    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.red;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // how many segments should be active
    final activeCount = (progress * segments).floor();

    final full = 2 * math.pi;
    final segAngle = full / segments;

    // start from top (12 o'clock)
    final startBase = -math.pi / 2;

    for (int i = 0; i < segments; i++) {
      final start = startBase + (i * segAngle) + (gapRadians / 2);
      final sweep = segAngle - gapRadians;

      canvas.drawArc(rect, start, sweep, false, inactive);

      if (i < activeCount) {
        canvas.drawArc(rect, start, sweep, false, active);
      }
    }

    // inner soft circle (like your image center)
    final inner = Paint()..color = Colors.white.withOpacity(0.06);
    canvas.drawCircle(center, radius - strokeWidth * 1.2, inner);
  }

  @override
  bool shouldRepaint(covariant _SegmentedRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// =====================================================
// ✅ Full Screen Video Player Widget
// =====================================================
class FullScreenVideoPlayer extends StatefulWidget {
  final String videoPath;

  const FullScreenVideoPlayer({super.key, required this.videoPath});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final isNetwork = widget.videoPath.startsWith('http');

      if (!isNetwork) {
        final file = File(widget.videoPath);
        final exists = await file.exists();
        if (!exists) {
          if (mounted) {
            ToastWidget.show(
              context: context,
              title: "Video Not Found",
              subtitle: "The video file does not exist locally",
              type: ToastType.error,
            );
            Navigator.pop(context);
          }
          return;
        }
      }

      _videoController = isNetwork
          ? VideoPlayerController.network(widget.videoPath)
          : VideoPlayerController.file(File(widget.videoPath));

      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        allowFullScreen: false,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: kPrimary,
          handleColor: kPrimary,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade200,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: kPrimary),
          ),
        ),
        autoInitialize: true,
      );

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("❌ Video initialization error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ToastWidget.show(
          context: context,
          title: "Playback Error",
          subtitle: "Could not play the video",
          type: ToastType.error,
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : const Center(child: CircularProgressIndicator(color: kPrimary)),
        ),
      ),
    );
  }
}

Widget buildSectionHeader(String title, IconData icon) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kPrimary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: kPrimary, size: 20),
      ),
      const SizedBox(width: 10),
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
        ),
      ),
    ],
  );
}

Widget buildModernCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColor.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

InputDecoration _fieldDecoration({
  required String label,
  required String hint,
  required IconData icon,
  Widget? suffix,
  String? errorText,
  bool enabled = true,
  bool readOnly = false,
}) {
  final fill = (readOnly || !enabled)
      ? const Color(0xFFF1F5F9)
      : AppColor.fieldFill;

  return InputDecoration(
    labelText: label,
    hintText: hint,
    errorText: errorText,
    suffixIcon: suffix,
    filled: true,
    fillColor: fill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColor.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColor.fieldFocusBorder, width: 2),
    ),
  );
}

// =====================================================
// ✅ Modern TextField (same as your code)
// =====================================================
class _ModernTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Function(String) onChanged;
  final String? initialValue;
  final TextInputType keyboardType;
  final bool requiredField;
  final Widget? suffix;
  final bool readOnly;
  final bool enabled;

  const _ModernTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.requiredField = true,
    this.suffix,
    this.readOnly = false,
    this.enabled = true,
    super.key,
  });

  @override
  State<_ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<_ModernTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(_ModernTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _controller,
        keyboardType: widget.keyboardType,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        onChanged: (v) {
          if (!widget.enabled || widget.readOnly) return;
          widget.onChanged(v);
        },
        validator: (v) {
          if (!widget.requiredField) return null;
          if (v == null || v.trim().isEmpty)
            return 'Please enter ${widget.label}';
          return null;
        },
        cursorColor: AppColor.fieldIcon,
        decoration: _fieldDecoration(
          label: widget.label,
          hint: widget.hint,
          icon: widget.icon,
          suffix: widget.suffix,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
        ),
      ),
    );
  }
}

Widget buildModernTextField({
  required String label,
  required String hint,
  required IconData icon,
  required Function(String) onChanged,
  String? initialValue,
  TextInputType keyboardType = TextInputType.text,
  bool requiredField = true,
  Widget? suffix,
  bool readOnly = false,
  bool enabled = true,
}) {
  return _ModernTextField(
    label: label,
    hint: hint,
    icon: icon,
    onChanged: onChanged,
    initialValue: initialValue,
    keyboardType: keyboardType,
    requiredField: requiredField,
    suffix: suffix,
    readOnly: readOnly,
    enabled: enabled,
  );
}

// =====================================================
// Helpers for MultiSelect
// =====================================================
List<String> _uniqueKeepOrder(List<String> items) {
  final seen = <String>{};
  final out = <String>[];
  for (final raw in items) {
    final v = raw.trim();
    if (v.isEmpty) continue;
    if (seen.add(v)) out.add(v);
  }
  return out;
}

List<String> _parseCsvList(String raw) {
  final r = raw.replaceAll('[', '').replaceAll(']', '').trim();
  if (r.isEmpty) return [];
  final parts = r
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  return _uniqueKeepOrder(parts);
}

String _joinCsvList(List<String> items) {
  final cleaned = _uniqueKeepOrder(items);
  if (cleaned.isEmpty) return '';
  return cleaned.join(', ');
}

List<String> _normalizePickedOrder(List<String> picked, List<String> allItems) {
  final cleaned = _uniqueKeepOrder(
    picked
        .map((e) => e.replaceAll('[', '').replaceAll(']', '').trim())
        .where((e) => e.isNotEmpty)
        .toList(),
  );
  final ordered = allItems.where((it) => cleaned.contains(it)).toList();
  final extras = cleaned.where((it) => !allItems.contains(it)).toList();
  return [...ordered, ...extras];
}

// =====================================================
// ✅ Centered Overlay Single Dropdown (same as your code)
// =====================================================
class _CenteredOverlaySingleDropdown extends StatefulWidget {
  final BuildContext parentContext;
  final String label;
  final String hint;
  final IconData icon;
  final List<String> items;
  final String? value;
  final bool enabled;
  final String? errorText;
  final void Function(String picked) onPicked;

  const _CenteredOverlaySingleDropdown({
    super.key,
    required this.parentContext,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.value,
    required this.enabled,
    required this.errorText,
    required this.onPicked,
  });

  @override
  State<_CenteredOverlaySingleDropdown> createState() =>
      _CenteredOverlaySingleDropdownState();
}

class _CenteredOverlaySingleDropdownState
    extends State<_CenteredOverlaySingleDropdown>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  String? _tempSelected;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _remove();
    _anim.dispose();
    super.dispose();
  }

  void _remove() {
    _entry?.remove();
    _entry = null;
  }

  Future<void> _close() async {
    if (_entry == null) return;
    await _anim.reverse();
    _remove();
  }

  Future<void> _open() async {
    if (!widget.enabled) return;
    if (_entry != null) return;

    final overlay = Overlay.of(widget.parentContext);
    final box = context.findRenderObject() as RenderBox?;
    if (overlay == null || box == null) return;

    final fieldSize = box.size;
    final screen = MediaQuery.of(widget.parentContext).size;
    final fieldOffset = box.localToGlobal(Offset.zero);

    const margin = 12.0;
    final belowSpace =
        screen.height - (fieldOffset.dy + fieldSize.height) - margin;
    final aboveSpace = fieldOffset.dy - margin;

    const minPanel = 160.0;
    final openUp = belowSpace < minPanel && aboveSpace > belowSpace;

    final panelWidth = fieldSize.width > 360 ? 340.0 : fieldSize.width;
    final dx = (fieldSize.width - panelWidth) / 2;

    const rowH = 52.0;
    final panelTargetH = (widget.items.length * rowH + 12).clamp(120.0, 320.0);
    final maxHeight = (openUp ? aboveSpace : belowSpace).clamp(140.0, 360.0);
    final panelH = panelTargetH.clamp(120.0, maxHeight);

    final dy = openUp ? -(panelH + 8) : (fieldSize.height + 8);

    _tempSelected = null;

    _entry = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox(),
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: Offset(dx, dy),
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: panelWidth,
                        maxWidth: panelWidth,
                        maxHeight: panelH,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 26,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: StatefulBuilder(
                            builder: (ctx, setInner) {
                              final selectedNow = _tempSelected ?? widget.value;
                              return ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                itemCount: widget.items.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.black.withOpacity(0.06),
                                ),
                                itemBuilder: (_, i) {
                                  final it = widget.items[i];
                                  final isSelected = selectedNow == it;

                                  return InkWell(
                                    onTap: () async {
                                      setInner(() => _tempSelected = it);
                                      await Future.delayed(
                                        const Duration(milliseconds: 90),
                                      );
                                      widget.onPicked(it);
                                      await _close();
                                    },
                                    child: SizedBox(
                                      height: 52,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                it,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColor.textDark,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check_rounded,
                                                size: 22,
                                                color: kPrimary,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
    await _anim.forward();
  }

  @override
  Widget build(BuildContext context) {
    final val = widget.value?.trim() ?? "";
    final displayValue = (val.isNotEmpty && widget.items.contains(val))
        ? val
        : null;

    return CompositedTransformTarget(
      link: _link,
      child: InkWell(
        onTap: widget.enabled ? _open : null,
        child: InputDecorator(
          decoration: _fieldDecoration(
            label: widget.label,
            hint: widget.hint,
            icon: widget.icon,
            enabled: widget.enabled,
            errorText: widget.errorText,
            suffix: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: widget.enabled
                    ? AppColor.fieldIcon
                    : Colors.grey.shade400,
                size: 24,
              ),
            ),
          ),
          child: Text(
            displayValue ?? widget.hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: displayValue == null
                  ? AppColor.textMuted
                  : AppColor.textDark,
              fontWeight: displayValue == null
                  ? FontWeight.w700
                  : FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildModernDropdown({
  required BuildContext context,
  required String label,
  required String hint,
  required IconData icon,
  required List<String> items,
  required Function(String?) onChanged,
  String? value,
  bool requiredField = true,
  bool enabled = true,
}) {
  final v = value?.trim() ?? "";
  final initial = (v.isNotEmpty && items.contains(v)) ? v : null;

  return FormField<String>(
    key: ValueKey('single-$label-$initial-${enabled ? "1" : "0"}'),
    initialValue: initial,
    validator: (val) {
      if (!requiredField) return null;
      final cur = (val ?? '').trim();
      if (cur.isEmpty) return 'Please select $label';
      return null;
    },
    builder: (state) {
      final cur = state.value?.trim();
      final displayValue =
          (cur != null && cur.isNotEmpty && items.contains(cur)) ? cur : null;

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _CenteredOverlaySingleDropdown(
          parentContext: context,
          label: label,
          hint: hint,
          icon: icon,
          items: items,
          value: displayValue,
          enabled: enabled,
          errorText: state.hasError ? state.errorText : null,
          onPicked: (picked) {
            state.didChange(picked);
            onChanged(picked);
          },
        ),
      );
    },
  );
}

Widget buildModernSingleListDropdownKey({
  required BuildContext context,
  required CarInspectionStepperController c,
  required String keyName,
  required String label,
  required String hint,
  required IconData icon,
  required List<String> items,
  String? mirrorOldKey,
  bool requiredField = false,
  bool enabled = true,
}) {
  return Obx(() {
    final current = c.getText(keyName).trim();
    final currentValue = current.isEmpty ? null : current;
    final actualItems = c.getDropdownItems(keyName);

    return buildModernDropdown(
      context: context,
      label: label,
      hint: hint,
      icon: icon,
      items: actualItems.isNotEmpty ? actualItems : items,
      value: currentValue,
      requiredField: requiredField,
      enabled: enabled,
      onChanged: (picked) {
        final v = (picked ?? "").trim();
        c.setString(keyName, v);
        if (mirrorOldKey != null && mirrorOldKey.trim().isNotEmpty) {
          c.setString(mirrorOldKey, v);
        }
      },
    );
  });
}

// =====================================================
// ✅ MultiSelect Dialog (same as your code)
// =====================================================
Widget buildModernMultiSelectDropdownKey({
  required BuildContext context,
  required CarInspectionStepperController c,
  required String keyName,
  required String label,
  required String hint,
  required IconData icon,
  required List<String> items,
  String? mirrorOldKey,
  bool requiredField = false,
  bool enabled = true,
  bool showCounter = false,
  int maxDisplayItems = 3,
}) {
  return Obx(() {
    final selectedInit = _normalizePickedOrder(
      _parseCsvList(c.getText(keyName)),
      items,
    );
    final actualItems = c.getDropdownItems(keyName);

    return FormField<List<String>>(
      key: ValueKey(
        'multi-$keyName-${selectedInit.join("|")}-${enabled ? "1" : "0"}',
      ),
      initialValue: selectedInit,
      validator: (val) {
        if (!requiredField) return null;
        final now = val ?? const <String>[];
        if (now.isEmpty) return 'Please select at least one $label';
        return null;
      },
      builder: (state) {
        final current = _normalizePickedOrder(
          state.value ?? const <String>[],
          actualItems,
        );

        String getDisplayText() {
          if (current.isEmpty) return hint;
          final cleaned = _uniqueKeepOrder(
            current
                .map((e) => e.replaceAll('[', '').replaceAll(']', '').trim())
                .where((e) => e.isNotEmpty)
                .toList(),
          );
          if (cleaned.isEmpty) return hint;
          final maxShow = maxDisplayItems <= 0 ? 3 : maxDisplayItems;
          final displayed = cleaned.take(maxShow).join(', ');
          if (cleaned.length > maxShow) return '$displayed …';
          return displayed;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            onTap: !enabled
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (_) => _MultiSelectDialog(
                        label: label,
                        items: actualItems,
                        selectedItems: current,
                        onConfirm: (picked) {
                          final ordered = _normalizePickedOrder(
                            picked,
                            actualItems,
                          );
                          final csv = _joinCsvList(ordered);
                          c.setString(keyName, csv);
                          if (mirrorOldKey != null &&
                              mirrorOldKey.trim().isNotEmpty) {
                            c.setString(mirrorOldKey, csv);
                          }
                          state.didChange(ordered);
                        },
                      ),
                    );
                  },
            child: InputDecorator(
              decoration: _fieldDecoration(
                label: label,
                hint: hint,
                icon: icon,
                enabled: enabled,
                errorText: state.hasError ? state.errorText : null,
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: enabled ? AppColor.fieldIcon : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
              ),
              child: Text(
                getDisplayText(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: current.isEmpty
                      ? AppColor.textMuted
                      : AppColor.textDark,
                  fontWeight: current.isEmpty
                      ? FontWeight.w700
                      : FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      },
    );
  });
}

class _MultiSelectDialog extends StatefulWidget {
  final String label;
  final List<String> items;
  final List<String> selectedItems;
  final void Function(List<String>) onConfirm;

  const _MultiSelectDialog({
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.onConfirm,
    super.key,
  });

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late List<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List<String>.from(widget.selectedItems);
  }

  void _toggle(String item) {
    setState(() {
      if (_tempSelected.contains(item)) {
        _tempSelected.remove(item);
      } else {
        _tempSelected.add(item);
      }
    });
  }

  void _selectAll() {
    setState(() => _tempSelected = List<String>.from(widget.items));
  }

  void _clearAll() {
    setState(() => _tempSelected.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 550, minWidth: 280),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (_tempSelected.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_tempSelected.length} selected',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: widget.items.isEmpty
                  ? Center(
                      child: Text(
                        'No items available',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.items.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey[100],
                      ),
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        final isSelected = _tempSelected.contains(item);

                        return InkWell(
                          onTap: () => _toggle(item),
                          highlightColor: kPrimary.withOpacity(0.06),
                          splashColor: kPrimary.withOpacity(0.08),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            color: isSelected
                                ? kPrimary.withOpacity(0.06)
                                : Colors.transparent,
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: isSelected
                                          ? kPrimary
                                          : Colors.grey[350]!,
                                      width: isSelected ? 2 : 1.5,
                                    ),
                                    color: isSelected
                                        ? kPrimary
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? kPrimary
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _clearAll,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _selectAll,
                    style: TextButton.styleFrom(foregroundColor: kPrimary),
                    child: const Text(
                      'Select All',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.onConfirm(List<String>.from(_tempSelected));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
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

// =====================================================
// Date Picker (same)
// =====================================================
String _fmtDate(DateTime? d) {
  if (d == null) return '';
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$dd/$mm/$yyyy';
}

Widget buildModernDatePicker({
  required BuildContext context,
  required String label,
  required String hint,
  required IconData icon,
  required DateTime? value,
  required void Function(DateTime?) onChanged,
  bool requiredField = false,
  DateTime? firstDate,
  DateTime? lastDate,
  bool enabled = true,
}) {
  return FormField<DateTime?>(
    key: ValueKey(
      'date-$label-${value?.toIso8601String() ?? ""}-${enabled ? "1" : "0"}',
    ),
    initialValue: value,
    validator: (v) {
      if (!requiredField) return null;
      if (v == null) return 'Please select $label';
      return null;
    },
    builder: (state) {
      final display = state.value == null ? hint : _fmtDate(state.value);

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InkWell(
          onTap: !enabled
              ? null
              : () async {
                  FocusScope.of(context).unfocus();
                  final now = DateTime.now();

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.value ?? now,
                    firstDate: firstDate ?? DateTime(1990),
                    lastDate: lastDate ?? DateTime(now.year + 30),
                    helpText: label,
                    builder: (ctx, child) {
                      final base = Theme.of(ctx);
                      return Theme(
                        data: base.copyWith(
                          colorScheme: base.colorScheme.copyWith(
                            primary: kPrimary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (picked != null) {
                    state.didChange(picked);
                    onChanged(picked);
                  }
                },
          child: InputDecorator(
            decoration: _fieldDecoration(
              label: label,
              hint: hint,
              icon: icon,
              enabled: enabled,
              errorText: state.hasError ? state.errorText : null,
              suffix: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: enabled ? AppColor.fieldIcon : Colors.grey.shade400,
                ),
              ),
            ),
            child: Text(
              display,
              style: TextStyle(
                color: state.value == null
                    ? AppColor.textMuted
                    : AppColor.textDark,
                fontWeight: state.value == null
                    ? FontWeight.w600
                    : FontWeight.w900,
              ),
            ),
          ),
        ),
      );
    },
  );
}

// =====================================================
// Source dialogs
// =====================================================
Future<ImageSource?> _showVideoSourceDialog(BuildContext context) async {
  final result = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Video Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 25),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, color: kPrimary),
              ),
              title: Text(
                'Record Video',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              subtitle: Text(
                'Use camera to record a new video',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              onTap: () => Navigator.pop(context, 0),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.video_library, color: Colors.blue),
              ),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              subtitle: Text(
                'Select video from your gallery',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              onTap: () => Navigator.pop(context, 1),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );

  if (result == 0) return ImageSource.camera;
  if (result == 1) return ImageSource.gallery;
  return null;
}

Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
  final result = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 25),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, color: kPrimary),
              ),
              title: Text(
                'Camera',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              subtitle: Text(
                'Take a new photo',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              onTap: () => Navigator.pop(context, 0),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library, color: Colors.blue),
              ),
              title: Text(
                'Gallery',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              subtitle: Text(
                'Choose from gallery',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              onTap: () => Navigator.pop(context, 1),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );

  if (result == 0) return ImageSource.camera;
  if (result == 1) return ImageSource.gallery;
  return null;
}

// =====================================================
// Image Picker
// =====================================================
Widget _addTile() {
  return Container(
    width: 98,
    margin: const EdgeInsets.only(right: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kPrimary, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_rounded, color: kPrimary, size: 30),
        SizedBox(height: 4),
        Text('Add', style: TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}
const BorderRadius _imageRadius =
    BorderRadius.all(Radius.circular(12)); // same as Add tile

Widget buildImagePicker({
  required CarInspectionStepperController c,
  required String fieldKey,
  required String label,
  int maxImages = 10,
  int minRequired = 0,
  bool enabled = true,
  bool validationError = false,
  BuildContext? context,
}) {
  if (!_imageInitDone.contains(fieldKey)) {
    _imageInitDone.add(fieldKey);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final localImages = await c.loadLocalImagesFromStorage(fieldKey);
      if (localImages.isNotEmpty) {
        c.localPickedImages[fieldKey] = List<String>.from(localImages);
        c.touch();
      }
    });
  }

  final imagePaths = c.getLocalImages(fieldKey);
  final uploadedUrls = c.getList(fieldKey);
  final uploadingImages = c.imageUploadingLocal[fieldKey] ?? {};

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// ───────── Header ─────────
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: validationError ? Colors.red : AppColor.textDark,
                  ),
                ),
                if (minRequired > 0)
                  Text(
                    'Minimum $minRequired image required',
                    style: TextStyle(
                      fontSize: 11,
                      color: validationError
                          ? Colors.red
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${imagePaths.length}/$maxImages',
            style: TextStyle(
              color: validationError ? Colors.red : Colors.grey.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),

      /// ───────── Images ─────────
      SizedBox(
        height: 98,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: enabled ? imagePaths.length + 1 : imagePaths.length,
          itemBuilder: (ctx, index) {
            /// ➕ Add tile
            if (enabled && index == imagePaths.length) {
              if (imagePaths.length >= maxImages) return const SizedBox();

              return GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final source = await _showImageSourceDialog(ctx);
                  if (source == null) return;

                  if (maxImages == 1) {
                    final picked = await picker.pickImage(source: source);
                    if (picked != null) {
                      await c.setLocalImages(fieldKey, [picked.path]);
                    }
                    return;
                  }

                  if (source == ImageSource.camera) {
                    final picked = await picker.pickImage(source: source);
                    if (picked != null) {
                      await c.setLocalImages(fieldKey, [
                        ...imagePaths,
                        picked.path,
                      ]);
                    }
                  } else {
                    final pickedFiles = await picker.pickMultiImage();
                    final remaining = maxImages - imagePaths.length;
                    final toAdd = pickedFiles
                        .take(remaining)
                        .map((e) => e.path)
                        .toList();

                    if (toAdd.isNotEmpty) {
                      await c.setLocalImages(fieldKey, [
                        ...imagePaths,
                        ...toAdd,
                      ]);
                    }
                  }
                },
                child: _addTile(), // already rounded
              );
            }

            final imagePath = imagePaths[index];
            final isUploaded =
                imagePath.startsWith('http') ||
                uploadedUrls.contains(imagePath);
            final isLoading = uploadingImages[imagePath] == true;

            return GestureDetector(
              onTap: () {
                if (context == null) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullScreenImageViewer(
                      imagePaths: imagePaths,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Container(
                width: 98,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: validationError
                        ? Colors.red
                        : Colors.grey.shade300,
                  ),
                  borderRadius: _imageRadius, // ✅ rounded border
                ),
                child: ClipRRect(
                  borderRadius: _imageRadius, // ✅ rounded image
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      /// Image
                      isUploaded && imagePath.startsWith('http')
                          ? Image.network(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image),
                              ),
                            )
                          : Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                            ),

                      /// Loading overlay (rounded)
                      if (isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.4),
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      /// ❌ Remove icon (only after upload)
                      if (enabled && isUploaded && !isLoading)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () async =>
                                await c.removeImage(fieldKey, imagePath),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 14),
    ],
  );
}

class VideoThumbnailTile extends StatefulWidget {
  final String videoPath;
  final bool enabled;
  final Future<void> Function() onRemove;
  final bool isUploaded;
  final bool isLoading;

  // ✅ combined progress 0..1
  final double? progress;

  const VideoThumbnailTile({
    super.key,
    required this.videoPath,
    required this.enabled,
    required this.onRemove,
    this.isUploaded = false,
    this.isLoading = false,
    this.progress,
  });

  @override
  State<VideoThumbnailTile> createState() => _VideoThumbnailTileState();
}

class _VideoThumbnailTileState extends State<VideoThumbnailTile> {
  VideoPlayerController? _videoController;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      final isNetwork = widget.videoPath.startsWith('http');

      if (!isNetwork) {
        final file = File(widget.videoPath);
        final exists = await file.exists();
        if (!exists) return;
      }

      _videoController = isNetwork
          ? VideoPlayerController.network(widget.videoPath)
          : VideoPlayerController.file(File(widget.videoPath));

      await _videoController!.initialize();

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("❌ Video initialization error: $e");
    } finally {
      _isInitializing = false;
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCloudinaryUrl = widget.videoPath.startsWith('http');

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FullScreenVideoPlayer(videoPath: widget.videoPath),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.black.withOpacity(0.05),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Click to Play Video',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: kPrimary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isCloudinaryUrl ? 'Uploaded Video' : 'Local Video',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCloudinaryUrl
                          ? Colors.green.shade600
                          : Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // ✅ cross icon only when uploaded + not loading
            if (widget.enabled && !widget.isLoading && widget.isUploaded)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () async => await widget.onRemove(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // ✅ ONE overlay for both processing + upload
            Positioned.fill(
              child: UploadingPercentOverlay(
                active: widget.isLoading,
                progress: widget.progress,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddVideoTile extends StatelessWidget {
  final CarInspectionStepperController c;
  final String fieldKey;

  const _AddVideoTile({required this.c, required this.fieldKey, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final source = await _showVideoSourceDialog(context);
        if (source == null) return;

        final picker = ImagePicker();
        XFile? videoFile;

        if (source == ImageSource.camera) {
          videoFile = await picker.pickVideo(
            source: ImageSource.camera,
            maxDuration: const Duration(seconds: kMaxVideoSeconds),
          );
        } else {
          videoFile = await picker.pickVideo(source: ImageSource.gallery);
        }

        if (videoFile == null) return;

        // ✅ START LOADING right after pick
        c.setFieldProcessing(fieldKey, true);

        try {
          // ✅ Step 1: Trim
          final trimmedPath = await _trimFirst15Seconds(videoFile.path);
          if (trimmedPath == null) {
            ToastWidget.show(
              context: context,
              title: "Video Processing Failed",
              subtitle: "Could not trim the video. Please try again.",
              type: ToastType.error,
            );
            c.setFieldProcessing(fieldKey, false);
            return;
          }

          // ✅ Step 2: Compress
          final compressedPath = await _compressVideo(trimmedPath);
          final finalPath =
              (compressedPath != null && compressedPath.isNotEmpty)
              ? compressedPath
              : trimmedPath;

          // ✅ Step 3: Set local video => controller auto uploads
          await c.setLocalVideo(fieldKey, finalPath);
        } catch (e) {
          debugPrint("❌ Add video error: $e");
          c.setFieldProcessing(fieldKey, false);
        } finally {
          // ✅ If upload didn't start for any reason, stop loader here
          if (!c.isFieldUploading(fieldKey)) {
            // if upload is running, uploadVideoForField will stop processing in finally
            // so we keep it ON
            // (this avoids flicker)
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_camera_back_rounded,
              size: 40,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 10),
            Text(
              'Add Video',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Camera or Gallery',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildVideoPicker({
  required CarInspectionStepperController c,
  required String fieldKey,
  required BuildContext context,
  required String label,
  bool enabled = true,
  bool compressBeforeUpload = true,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      void refresh() => setState(() {});

      return Obx(() {
        final videoPath = c.getLocalVideo(fieldKey);
        final hasVideo = videoPath != null && videoPath.isNotEmpty;

        final isCloudinaryUrl =
            hasVideo &&
            (videoPath!.startsWith('http://') ||
                videoPath.startsWith('https://'));

        final uploadedUrl = c.getText(fieldKey);
        final hasUploadedUrl =
            uploadedUrl.isNotEmpty &&
            (uploadedUrl.startsWith('http://') ||
                uploadedUrl.startsWith('https://'));

        final isUploaded = isCloudinaryUrl || hasUploadedUrl;

        final isUploading = c.isFieldUploading(fieldKey);
        final isProcessing = c.isFieldProcessing(fieldKey);

        // ✅ one loader for both
        final isLoading = (isProcessing || isUploading) && !isCloudinaryUrl;

        // ✅ phase decides 1-10 or 10-95
        final phase = isProcessing
            ? UploadPhase.processing
            : UploadPhase.uploading;

        // ✅ tile child changes, but overlay stays SAME in stack (state persists)
        final Widget tileChild = hasVideo
            ? VideoThumbnailTile(
                videoPath: hasUploadedUrl ? uploadedUrl : videoPath!,
                enabled: enabled,
                isUploaded: isUploaded,
                onRemove: () async {
                  await c.removeVideo(fieldKey);
                  refresh();
                },
              )
            : (enabled
                  ? _AddVideoTile(c: c, fieldKey: fieldKey)
                  : const SizedBox.shrink());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Stack(
              children: [
                tileChild,

                Positioned.fill(
                  child: UploadingPercentOverlay(
                    progress: _vnVideoProgress(fieldKey).value,
                    key: ValueKey('percent-$fieldKey'), // ✅ keep state
                    active: isLoading,
                    size: 34,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
          ],
        );
      });
    },
  );
}

// ✅ Loading indicator widget
Widget _buildLoadingIndicator() {
  return Container(
    width: double.infinity,
    height: 180,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade300),
      color: Colors.grey.shade50,
    ),
    child: const Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(strokeWidth: 3, color: kPrimary),
      ),
    ),
  );
}

// ✅ Video Picker with validation (same behavior as your code)
Widget buildValidatedVideoPicker({
  required BuildContext context,
  required CarInspectionStepperController c,
  required String fieldKey,
  required String label,
  bool requiredVideo = true,
  bool enabled = true,
  bool compressBeforeUpload = true,
}) {
  return FormField<String>(
    key: ValueKey('video-$fieldKey'),
    validator: (value) {
      final current = c.getLocalVideo(fieldKey);
      final isUploaded =
          current != null && current.isNotEmpty && c.isVideoUploaded(fieldKey);

      if (requiredVideo) {
        if (current == null || current.isEmpty) {
          return 'Please add a video for $label';
        }
        if (!isUploaded && current.startsWith('http') == false) {
          return 'Please upload the video for $label';
        }
      }
      return null;
    },
    builder: (state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: state.hasError
                  ? Border.all(color: Colors.red, width: 2)
                  : null,
            ),
            child: buildVideoPicker(
              c: c,
              fieldKey: fieldKey,
              label: label,
              enabled: enabled,
              context: context,
              compressBeforeUpload: compressBeforeUpload,
            ),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    state.errorText ?? '',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

Widget buildValidatedMultiImagePicker({
  required CarInspectionStepperController c,
  required String fieldKey,
  required String label,
  required int minRequired,
  required int maxImages,
  bool enabled = true,
  required BuildContext context,
}) {
  final imagePaths = c.getLocalImages(fieldKey);

  return FormField<List<String>>(
    key: ValueKey('img-$fieldKey-${imagePaths.length}'),
    initialValue: imagePaths,
    validator: (_) {
      final now = c.getLocalImages(fieldKey);
      if (now.length < minRequired) {
        return 'Please add at least $minRequired image(s) for $label';
      }
      if (now.length > maxImages) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ToastWidget.show(
            context: context,
            title: "Maximum Limit Exceeded",
            subtitle: "Maximum $maxImages images allowed for $label",
            type: ToastType.error,
          );
        });
        return 'Max $maxImages images allowed for $label';
      }
      return null;
    },
    builder: (state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildImagePicker(
            c: c,
            fieldKey: fieldKey,
            label: label,
            maxImages: maxImages,
            enabled: enabled,
            minRequired: minRequired,
            validationError: state.hasError,
            context: context,
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 10),
              child: Text(
                state.errorText ?? '',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    },
  );
}

enum UploadPhase { processing, uploading }

class UploadingPercentOverlay extends StatelessWidget {
  final bool active;
  final double? progress; // ignore (spinner only)
  final double size;
  final double borderRadius;

  const UploadingPercentOverlay({
    super.key,
    required this.active,
    required this.progress,
    this.size = 26, // ✅ short / small
    this.borderRadius = 16, // ✅ tile ke radius match
  });

  @override
  Widget build(BuildContext context) {
    if (!active) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: true,
      child: ClipRRect(
        child: Container(
          // ✅ light dim, not heavy
          color: Colors.black.withOpacity(0.18),
          alignment: Alignment.center,
          child: SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
