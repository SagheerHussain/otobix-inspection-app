import 'dart:io';
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
import 'package:video_compress/video_compress.dart'; // ✅ ADDED: Video compression package

const List<String> yesNo = ["Yes", "No"];
const List<String> availableNA = ["Available", "Not Available"];
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
    debugPrint("🎬 ===========================================");
    debugPrint("🎬 STARTING VIDEO COMPRESSION");
    debugPrint("🎬 Input path: $inputPath");

    // Check if input file exists
    final originalFile = File(inputPath);
    if (!await originalFile.exists()) {
      debugPrint("❌ Original video file does not exist");
      return null;
    }

    // Get original file size
    final originalSize = await originalFile.length();
    final originalSizeMB = (originalSize / (1024 * 1024)).toStringAsFixed(2);
    debugPrint(
      "📊 Original video size: $originalSizeMB MB ($originalSize bytes)",
    );

    // ✅ FIXED: New way to initialize video_compress
    debugPrint("🔄 Initializing video_compress...");

    // Get media info first to check video details
    final mediaInfo = await VideoCompress.getMediaInfo(inputPath);
    debugPrint("📹 Video info: ${mediaInfo.toJson()}");

    // Compress video - initialize happens automatically
    debugPrint("🎬 Starting compression process...");
    debugPrint("⚙️ Compression settings:");
    debugPrint("  - Quality: MediumQuality");
    debugPrint("  - Delete origin: false");

    // ✅ FIXED: Use correct compressVideo method
    final response = await VideoCompress.compressVideo(
      inputPath,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false, // Keep original file
    );

    if (response == null) {
      debugPrint("❌ Video compression returned null");
      return null;
    }

    if (response.file == null) {
      debugPrint("❌ Compressed file is null");
      return null;
    }

    debugPrint("✅ Video compression completed");
    debugPrint("📁 Compressed file path: ${response.file!.path}");

    // Check compressed file exists
    final compressedFile = File(response.file!.path);
    if (!await compressedFile.exists()) {
      debugPrint("❌ Compressed video file does not exist");
      return null;
    }

    // Get compressed file size
    final compressedSize = await compressedFile.length();
    final compressedSizeMB = (compressedSize / (1024 * 1024)).toStringAsFixed(
      2,
    );
    debugPrint(
      "📊 Compressed video size: $compressedSizeMB MB ($compressedSize bytes)",
    );

    // Calculate compression ratio
    final sizeReduction = ((originalSize - compressedSize) / originalSize * 100)
        .toStringAsFixed(1);
    final compressionRatio = (originalSize / compressedSize).toStringAsFixed(2);

    debugPrint("📈 Compression Results:");
    debugPrint("  - Original: $originalSizeMB MB");
    debugPrint("  - Compressed: $compressedSizeMB MB");
    debugPrint("  - Size reduction: $sizeReduction%");
    debugPrint("  - Compression ratio: 1:$compressionRatio");

    // Check if compression actually reduced size
    if (compressedSize >= originalSize) {
      debugPrint("⚠️ Compressed file is same or larger than original!");
      debugPrint("⚠️ Returning original file instead");
      return inputPath;
    }

    debugPrint("✅ Compression successful!");
    debugPrint("🎬 ===========================================");

    return response.file!.path;
  } catch (e, stackTrace) {
    debugPrint("❌ VIDEO COMPRESSION ERROR");
    debugPrint("❌ Error type: ${e.runtimeType}");
    debugPrint("❌ Error message: $e");
    debugPrint("❌ Stack trace: $stackTrace");
    debugPrint("🎬 ===========================================");
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
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(File(imagePaths[index])),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 3.0,
            heroAttributes: PhotoViewHeroAttributes(tag: imagePaths[index]),
          );
        },
        itemCount: imagePaths.length,
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}

// =====================================================
// ✅ ADDED: Full Screen Video Player Widget
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
      // Check if video exists locally
      final file = File(widget.videoPath);
      final exists = await file.exists();

      if (!exists && !widget.videoPath.startsWith('http')) {
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

      // Initialize video controller
      if (widget.videoPath.startsWith('http')) {
        _videoController = VideoPlayerController.network(widget.videoPath);
      } else {
        _videoController = VideoPlayerController.file(File(widget.videoPath));
      }

      await _videoController.initialize();

      // Initialize Chewie controller for better controls
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        allowFullScreen: false, // We're already in full screen
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

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Video initialization error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
    debugPrint("🎯 Building single dropdown: $keyName");

    final current = c.getText(keyName).trim();
    final currentValue = current.isEmpty ? null : current;

    final actualItems = c.getDropdownItems(keyName);
    if (actualItems.isNotEmpty) {
      debugPrint("📦 Sample items: ${actualItems.take(3).join(', ')}");
    }

    return buildModernDropdown(
      context: context,
      label: label,
      hint: hint,
      icon: icon,
      items: actualItems,
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
    debugPrint("🎯 Building multi-select dropdown: $keyName");

    final selectedInit = _normalizePickedOrder(
      _parseCsvList(c.getText(keyName)),
      items,
    );

    final actualItems = c.getDropdownItems(keyName);
    debugPrint("📦 Items for $keyName: ${actualItems.length} items");
    if (actualItems.isNotEmpty) {
      debugPrint("📦 Sample items: ${actualItems.take(3).join(', ')}");
    }

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
    setState(() {
      _tempSelected = List<String>.from(widget.items);
    });
  }

  void _clearAll() {
    setState(() {
      _tempSelected.clear();
    });
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                    style: TextButton.styleFrom(
                      foregroundColor: kPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
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
                child: Icon(Icons.video_library, color: Colors.blue),
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
                child: Icon(Icons.photo_library, color: Colors.blue),
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
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final localImages = await c.loadLocalImagesFromStorage(fieldKey);
    if (localImages.isNotEmpty &&
        !c
            .getLocalImages(fieldKey)
            .any((element) => localImages.contains(element))) {
      c.localPickedImages[fieldKey] = List<String>.from(localImages);
      c.touch();
    }
  });

  final imagePaths = c.getLocalImages(fieldKey);
  final uploadedUrls = c.getList(fieldKey);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
      SizedBox(
        height: 98,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: enabled ? (imagePaths.length + 1) : imagePaths.length,
          itemBuilder: (context, index) {
            if (enabled && index == imagePaths.length) {
              if (imagePaths.length >= maxImages) return const SizedBox();

              return GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final source = await _showImageSourceDialog(context);
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
                      final remaining = maxImages - imagePaths.length;
                      if (remaining > 0) {
                        await c.setLocalImages(fieldKey, [
                          ...imagePaths,
                          picked.path,
                        ]);
                      }
                    }
                  } else {
                    final pickedFiles = await picker.pickMultiImage();
                    if (pickedFiles.isNotEmpty) {
                      final newPaths = pickedFiles.map((f) => f.path).toList();
                      final remaining = maxImages - imagePaths.length;
                      final toAdd = newPaths.take(remaining).toList();
                      await c.setLocalImages(fieldKey, [
                        ...imagePaths,
                        ...toAdd,
                      ]);
                    }
                  }
                },
                child: _addTile(),
              );
            }

            final imagePath = imagePaths[index];
            final isUploaded =
                imagePath.startsWith('http://') ||
                imagePath.startsWith('https://') ||
                uploadedUrls.contains(imagePath);

            // ✅ ADDED: Check if image is loading (local storage se)
            final isLoading = !isUploaded && !imagePath.startsWith('http');

            return GestureDetector(
              onTap: () {
                Navigator.of(context!).push(
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageViewer(
                      imagePaths: imagePaths,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: 98,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: validationError
                            ? Colors.red
                            : Colors.grey.shade300,
                      ),
                      image: isLoading
                          ? null // Don't show image while loading
                          : DecorationImage(
                              image: isUploaded && imagePath.startsWith('http')
                                  ? NetworkImage(imagePath) as ImageProvider
                                  : FileImage(File(imagePath)),
                              fit: BoxFit.cover,
                            ),
                      color: isLoading ? Colors.grey.shade100 : null,
                    ),
                    child: isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kPrimary,
                              ),
                            ),
                          )
                        : null,
                  ),

                  if (!isLoading && enabled)
                    Positioned(
                      top: 6,
                      right: 14,
                      child: GestureDetector(
                        onTap: () async {
                          await c.removeImage(fieldKey, imagePath);
                        },
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

                  // ✅ Upload status indicator
                  if (!isLoading)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (c.isFieldUploading(fieldKey))
                              const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                  color: Colors.white,
                                ),
                              )
                            else if (isUploaded)
                              const Icon(
                                Icons.cloud_done,
                                size: 10,
                                color: Colors.green,
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 14),
    ],
  );
}

// =====================================================
// ✅ MODIFIED: VideoThumbnailTile - Added loading indicator
// =====================================================
class VideoThumbnailTile extends StatelessWidget {
  final String videoPath;
  final bool enabled;
  final VoidCallback onRemove;
  final bool isUploaded;
  final bool isLoading; // ✅ ADDED: Loading state

  const VideoThumbnailTile({
    required this.videoPath,
    required this.enabled,
    required this.onRemove,
    this.isUploaded = false,
    this.isLoading = false, // ✅ ADDED: Default false
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading
          ? null // Disable tap while loading
          : () {
              // Open video in full screen dialog
              showDialog(
                context: context,
                barrierColor: Colors.black87,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(20),
                  child: FullScreenVideoPlayer(videoPath: videoPath),
                ),
              );
            },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
              color: isLoading
                  ? Colors.grey.shade100
                  : Colors.black.withOpacity(0.05),
            ),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: kPrimary,
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play button overlay
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
                      if (videoPath.startsWith('http'))
                        Text(
                          'Cloud Video',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        )
                      else
                        Text(
                          'Local Video',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade600,
                          ),
                        ),
                    ],
                  ),
          ),
          if (!isLoading && enabled)
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
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

        final trimmedPath = await _trimFirst15Seconds(videoFile.path);

        if (trimmedPath == null) {
          ToastWidget.show(
            context: context,
            title: "Video Processing Failed",
            subtitle: "Could not trim the video. Please try again.",
            type: ToastType.error,
          );
          return;
        }

        c.setLocalVideo(fieldKey, trimmedPath);
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

// ✅ UPDATED: buildVideoPicker with automatic compression on widget load
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

      // ✅ AUTO-COMPRESSION WHEN WIDGET LOADS
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        debugPrint("🔄 Loading video for field: $fieldKey");

        final localVideo = await c.loadLocalVideoFromStorage(fieldKey);
        if (localVideo != null && localVideo.isNotEmpty) {
          if (c.getLocalVideo(fieldKey) != localVideo) {
            debugPrint("📥 Video loaded from storage: $localVideo");
            c.localPickedVideos[fieldKey] = localVideo;
            refresh();
          }

          // ✅ AUTOMATIC COMPRESSION - yeh har baar video load hone par chalega
          if (!localVideo.startsWith('http')) {
            debugPrint("🎬 Checking if video needs compression...");

            // Skip if already compressed
            if (!localVideo.contains('compressed_') &&
                !localVideo.contains('_compressed')) {
              debugPrint("⚡ Auto-compressing video...");
              final compressedPath = await _compressVideo(localVideo);

              if (compressedPath != null && compressedPath != localVideo) {
                debugPrint("✅ Video compressed! Updating in controller...");
                debugPrint("   Original: $localVideo");
                debugPrint("   Compressed: $compressedPath");

                // Update controller with compressed video
                c.setLocalVideo(fieldKey, compressedPath);

                // Show toast notification
                ToastWidget.show(
                  context: context,
                  title: "Video Optimized",
                  subtitle: "Size reduced for faster upload",
                  type: ToastType.success,
                );

                refresh();
              }
            } else {
              debugPrint("📦 Video already compressed, skipping");
            }
          }
        }
      });

      return Obx(() {
        final videoPath = c.getLocalVideo(fieldKey);
        final hasVideo = videoPath != null && videoPath.isNotEmpty;
        final isUploaded = hasVideo ? c.isVideoUploaded(fieldKey) : false;
        final uploadedUrl = hasVideo ? c.getText(fieldKey) : '';

        final isLoadingVideo =
            hasVideo &&
            !videoPath!.startsWith('http') &&
            !isUploaded &&
            !c.isFieldUploading(fieldKey);

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
                Obx(() {
                  final loading = c.isFieldUploading(fieldKey);
                  final uploaded = hasVideo && isUploaded;
                  final canUpload =
                      enabled && hasVideo && !loading && !uploaded;

                  final bgColor = uploaded
                      ? kPrimary.withOpacity(0.10)
                      : const Color(0xFFF8FAFC);

                  final borderColor = uploaded
                      ? kPrimary.withOpacity(0.35)
                      : AppColor.border;

                  return InkWell(
                    onTap: canUpload
                        ? () async {
                            try {
                              debugPrint("🔼 UPLOAD BUTTON CLICKED");
                              debugPrint("🔼 Field: $fieldKey");
                              debugPrint("🔼 Video path: $videoPath");
                              debugPrint(
                                "🔼 Compress before upload: $compressBeforeUpload",
                              );

                              String videoToUpload = videoPath!;

                              if (compressBeforeUpload &&
                                  !videoPath.startsWith('http')) {
                                debugPrint(
                                  "🎬 Additional compression before upload...",
                                );

                                // Show compression toast
                                ToastWidget.show(
                                  context: context,
                                  title: "Final Compression",
                                  subtitle: "Preparing for upload...",
                                  type: ToastType.info,
                                );

                                final compressedPath = await _compressVideo(
                                  videoPath,
                                );

                                if (compressedPath != null &&
                                    compressedPath != videoPath) {
                                  debugPrint("✅ Final compression successful");
                                  videoToUpload = compressedPath;

                                  // Update controller
                                  c.setLocalVideo(fieldKey, compressedPath);

                                  await Future.delayed(
                                    const Duration(milliseconds: 500),
                                  );
                                }
                              }

                              debugPrint("☁️ Uploading video: $videoToUpload");
                              await c.uploadVideoForField(fieldKey);

                              refresh();
                            } catch (e) {
                              debugPrint("❌ Upload error: $e");
                              ToastWidget.show(
                                context: context,
                                title: "Upload Failed",
                                subtitle: "Please try again.",
                                type: ToastType.error,
                              );
                            }
                          }
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (loading)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kPrimary,
                              ),
                            )
                          else if (uploaded)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: kPrimary,
                            ),
                          if (loading || uploaded) const SizedBox(width: 6),
                          Text(
                            uploaded ? "Uploaded" : "Upload",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: uploaded ? kPrimary : AppColor.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 10),

            if (hasVideo)
              VideoThumbnailTile(
                videoPath: uploadedUrl.isNotEmpty && isUploaded
                    ? uploadedUrl
                    : videoPath!,
                enabled: enabled,
                isUploaded: isUploaded,
                isLoading: isLoadingVideo,
                onRemove: () {
                  c.setLocalVideo(fieldKey, null);
                  refresh();
                },
              )
            else if (enabled)
              _AddVideoTile(c: c, fieldKey: fieldKey),

            const SizedBox(height: 14),
          ],
        );
      });
    },
  );
}

// ✅ UPDATED: buildValidatedVideoPicker with auto compression
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
    validator: (_) {
      final current = c.getLocalVideo(fieldKey);
      if (requiredVideo && (current == null || current.isEmpty)) {
        return 'Please add a video for $label';
      }
      return null;
    },
    builder: (state) {
      // ✅ Add auto-compression check when form builds
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final videoPath = c.getLocalVideo(fieldKey);
        if (videoPath != null && !videoPath.startsWith('http')) {
          debugPrint("🔄 Form validation checking video: $fieldKey");
          await _compressVideo(videoPath);
        }
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildVideoPicker(
            c: c,
            fieldKey: fieldKey,
            label: label,
            enabled: enabled,
            context: context,
            compressBeforeUpload: compressBeforeUpload,
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
