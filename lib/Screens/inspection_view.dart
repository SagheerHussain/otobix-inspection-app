import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otobix_inspection_app/Screens/dashboard_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:otobix_inspection_app/Controller/car_inspection_controller.dart';
import 'package:otobix_inspection_app/Screens/UI_helper.dart';
import 'package:otobix_inspection_app/widgets/app_theme.dart';
import '../models/leads_model.dart';
import '../widgets/toast_widget.dart';

class StepperLock {
  static final RxSet<String> fields = <String>{}.obs;
  static bool has(String key) => fields.contains(key);
  static void clear() => fields.clear();
  static void addAll(Iterable<String> keys) => fields.addAll(keys);
  static void add(String key) => fields.add(key);
}

String _normKey(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

List<String> _tokens(String s) {
  final raw = s
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .replaceAll(RegExp(r'[_\-\.\[\]]+'), ' ')
      .toLowerCase();

  return raw
      .split(RegExp(r'\s+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

Set<String> _removeNoise(Set<String> t) {
  const noise = {
    "car",
    "vehicle",
    "inspection",
    "ie",
    "engineer",
    "customer",
    "client",
    "details",
    "detail",
    "no",
    "id",
  };
  return t..removeWhere((x) => noise.contains(x));
}

double _scoreMatch(String wantKey, String candKey) {
  final wNorm = _normKey(wantKey);
  final cNorm = _normKey(candKey);

  double score = 0;

  if (wNorm == cNorm) score += 10;

  if (cNorm.contains(wNorm) || wNorm.contains(cNorm)) score += 6;

  final wTok = _removeNoise(_tokens(wantKey).toSet());
  final cTok = _removeNoise(_tokens(candKey).toSet());

  if (wTok.isNotEmpty && cTok.isNotEmpty) {
    final inter = wTok.intersection(cTok).length;
    final uni = wTok.union(cTok).length;
    final jacc = uni == 0 ? 0.0 : (inter / uni);
    score += (jacc * 6);
  }

  return score;
}

Map<String, dynamic> _flattenAny(dynamic input) {
  final Map<String, dynamic> flat = {};

  void walk(dynamic v, String path) {
    if (v is Map) {
      v.forEach((k, val) {
        final p = path.isEmpty ? '$k' : '$path.$k';
        walk(val, p);
      });
      return;
    }
    if (v is List) {
      for (int i = 0; i < v.length; i++) {
        walk(v[i], '$path[$i]');
      }
      return;
    }
    flat[path] = v;
  }

  walk(input, '');
  return flat;
}

Map<String, dynamic> _buildSmartLookup(Map<String, dynamic> anyJson) {
  final flat = _flattenAny(anyJson);
  final Map<String, dynamic> lookup = {};

  bool ok(dynamic v) => (v ?? '').toString().trim().isNotEmpty;

  for (final e in flat.entries) {
    final path = e.key;
    final val = e.value;
    if (!ok(val)) continue;

    var last = path.split('.').last;
    last = last.replaceAll(RegExp(r'\[\d+\]'), '');

    final nkLast = _normKey(last);
    final nkPath = _normKey(path);

    lookup.putIfAbsent(nkLast, () => val);
    lookup.putIfAbsent(nkPath, () => val);
    lookup.putIfAbsent(last, () => val);
    lookup.putIfAbsent(path, () => val);
  }

  for (final e in anyJson.entries) {
    if (ok(e.value)) {
      lookup.putIfAbsent(_normKey(e.key), () => e.value);
      lookup.putIfAbsent(e.key, () => e.value);
    }
  }

  return lookup;
}

String _pickSmart(Map<String, dynamic> lookup, List<String> aliases) {
  for (final k in aliases) {
    final v1 = lookup[_normKey(k)];
    final s1 = (v1 ?? '').toString().trim();
    if (s1.isNotEmpty) return s1;

    final v2 = lookup[k];
    final s2 = (v2 ?? '').toString().trim();
    if (s2.isNotEmpty) return s2;
  }
  return '';
}

String _pickFuzzy(
  Map<String, dynamic> lookup,
  String wantKey, {
  double minScore = 6,
}) {
  double best = 0;
  dynamic bestVal;

  for (final entry in lookup.entries) {
    final k = entry.key.toString();
    final v = entry.value;
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) continue;

    final sc = _scoreMatch(wantKey, k);
    if (sc > best) {
      best = sc;
      bestVal = v;
    }
  }

  if (best >= minScore) {
    return (bestVal ?? '').toString().trim();
  }
  return '';
}

String _pickSmartOrFuzzy(
  Map<String, dynamic> lookup, {
  required String wantKey,
  List<String> aliases = const [],
}) {
  final exact = _pickSmart(lookup, [wantKey, ...aliases]);
  if (exact.isNotEmpty) return exact;
  return _pickFuzzy(lookup, wantKey);
}

Map<String, dynamic> _leadToMap(LeadsData lead) {
  final dyn = lead as dynamic;

  try {
    final m = dyn.toJson();
    if (m is Map) return Map<String, dynamic>.from(m as Map);
  } catch (_) {}

  try {
    final m = dyn.toMap();
    if (m is Map) return Map<String, dynamic>.from(m as Map);
  } catch (_) {}

  final map = <String, dynamic>{};

  void put(String k, dynamic v) {
    if (v == null) return;
    final s = v.toString().trim();
    if (s.isEmpty) return;
    map[k] = v;
  }

  try {
    put("appointmentId", dyn.appointmentId);
  } catch (_) {}
  try {
    put("emailAddress", dyn.emailAddress);
  } catch (_) {}
  try {
    put("ieName", dyn.ieName);
  } catch (_) {}
  try {
    put("city", dyn.city);
  } catch (_) {}
  try {
    put("inspectionCity", dyn.inspectionCity);
  } catch (_) {}
  try {
    put("contactNumber", dyn.contactNumber);
  } catch (_) {}
  try {
    put("customerContactNumber", dyn.customerContactNumber);
  } catch (_) {}
  try {
    put("carRegistrationNumber", dyn.carRegistrationNumber);
  } catch (_) {}
  try {
    put("registrationNumber", dyn.registrationNumber);
  } catch (_) {}
  try {
    put("registeredOwner", dyn.registeredOwner);
  } catch (_) {}
  try {
    put("ownerName", dyn.ownerName);
  } catch (_) {}
  try {
    put("registeredAddressAsPerRc", dyn.registeredAddressAsPerRc);
  } catch (_) {}
  try {
    put("make", dyn.make);
  } catch (_) {}
  try {
    put("model", dyn.model);
  } catch (_) {}
  try {
    put("variant", dyn.variant);
  } catch (_) {}
  try {
    put("engineNumber", dyn.engineNumber);
  } catch (_) {}
  try {
    put("chassisNumber", dyn.chassisNumber);
  } catch (_) {}
  try {
    put("ownershipSerialNumber", dyn.ownershipSerialNumber);
  } catch (_) {}

  return map;
}

class _LocalVideoPreview extends StatefulWidget {
  final File file;
  const _LocalVideoPreview({required this.file});

  @override
  State<_LocalVideoPreview> createState() => _LocalVideoPreviewState();
}

class _LocalVideoPreviewState extends State<_LocalVideoPreview> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file);
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: kPrimary),
          );
        }
      },
    );
  }
}

class _NetworkVideoPreview extends StatefulWidget {
  final String url;
  const _NetworkVideoPreview({required this.url});

  @override
  State<_NetworkVideoPreview> createState() => _NetworkVideoPreviewState();
}

class _NetworkVideoPreviewState extends State<_NetworkVideoPreview> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: kPrimary),
          );
        }
      },
    );
  }
}

Future<void> _showVideoPlayerDialog(
  BuildContext context,
  dynamic source, {
  required String title,
  bool isNetwork = false,
}) async {
  VideoPlayerController controller;
  if (isNetwork) {
    controller = VideoPlayerController.networkUrl(Uri.parse(source));
  } else {
    controller = VideoPlayerController.file(source);
  }

  await controller.initialize();
  final chewieController = ChewieController(
    videoPlayerController: controller,
    autoPlay: true,
    looping: false,
    allowFullScreen: true,
    allowMuting: true,
    showControls: true,
  );

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.dispose();
                    chewieController.dispose();
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Chewie(controller: chewieController),
          ),
        ],
      ),
    ),
  );

  controller.dispose();
  chewieController.dispose();
}

Future<void> _showVideoPicker({
  required BuildContext context,
  required CarInspectionStepperController c,
  required String fieldKey,
  int maxDurationInSeconds = 180,
}) async {
  final result = await showModalBottomSheet<File?>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
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

          // Camera Option
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
              'Record a new video (max ${maxDurationInSeconds ~/ 60} minutes)',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            onTap: () async {
              Navigator.pop(context);
              final picker = ImagePicker();
              final video = await picker.pickVideo(
                source: ImageSource.camera,
                maxDuration: Duration(seconds: maxDurationInSeconds),
              );
              if (video != null) {
                c.setLocalVideo(fieldKey, video.path);
              }
            },
          ),

          // Gallery Option
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
            onTap: () async {
              Navigator.pop(context);
              final picker = ImagePicker();
              final video = await picker.pickVideo(source: ImageSource.gallery);
              if (video != null) {
                c.setLocalVideo(fieldKey, video.path);
              }
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

// =====================================================
// CONSTANTS FOR DROPDOWNS
// =====================================================
const List<String> yesNo = ["Yes", "No"];
const List<String> okIssue = ["Okay", "Issue"];
const List<String> workingNA = ["Working", "Not Working", "N/A"];
const List<String> infotainmentOptions = ["Touchscreen", "Non-touch", "N/A"];
const List<String> seatsUpholsteryOptions = ["Fabric", "Leather", "N/A"];
const List<String> acTypeOptions = ["Manual", "Automatic", "N/A"];
const List<String> acCoolingOptions = ["Cooling", "Not Cooling", "N/A"];
const List<String> transmissionOptions = ["Manual", "Automatic", "CVT", "AMT"];
const List<String> driveTrainOptions = ["FWD", "RWD", "AWD", "4WD"];

const List<String> rcBookAvailabilityOptions = [
  'Original',
  'Photocopy',
  'Duplicate',
  'Lost',
  'Lost with Photocopy',
];

const List<String> rcConditionOptions = ['Okay', 'Damaged', 'Faded'];

const List<String> fuelTypeOptions = [
  'Diesel',
  'Petrol',
  'Petrol+CNG',
  'Petrol+LPG',
  'Electric Vehicle',
  'Mild Hybrid',
  'Petrol / Hybrid',
  'Plug-in Hybrid',
  'Diesel / Hybrid',
];

const List<String> hypothecationDetailsOptions = [
  'Not Hypothecated',
  'Loan Active',
  'Valid Bank NOC Available',
  'NOC Not Available',
  'Loan Closed',
];
const List<String> towingCommentsOptions = [
  'Okay',
  'Scratch',
  'Major Scratch',
  'Dent',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Repaired',
  'Repainted',
  'Color Faded',
  'Vinyl Wrapped',
  'Handle Not Working',
  'Handle Damaged',
  'Replaced',
  'Damaged',
];
const List<String> mismatchInRcOptions = [
  'No Mismatch',
  'Make',
  'Model',
  'Variant',
  'Ownership Serial Number',
  'Fuel Type',
  'Color',
  'Seating Capacity',
  'Month & Year of Manufacture',
];

const List<String> roadTaxValidityOptions = ['Limited Period', 'OTT', 'LTT'];

const List<String> insuranceOptions = [
  'Policy Not Available',
  'Expired',
  'Third Party',
  'Comprehensive',
  'Zero Depreciation',
];

const List<String> rtoNocOptions = [
  'Not Applicable',
  'Issued',
  'Expired (issued 90 days ago)',
  'Missing',
];

const List<String> rtoForm28Options = [
  'Not Applicable',
  'Issued',
  'Expired (issued 90 days ago)',
  'Missing',
];

const List<String> partyPeshiOptions = [
  'Seller will not appear',
  'Seller will attend anywhere in West Bengal',
  'Seller will appear in Kolkata region only',
];

const List<String> vinPlateDetailsOptions = ['Okay', 'Damaged', 'Faded'];
const List<String> toBeScrappedOptions = ['Yes', 'No'];

const List<String> duplicateKeyOptions = ['Yes', 'No'];

const List<String> bonnetOptions = [
  'Okay',
  'Scratch',
  'Major Scratch',
  'Dent',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Repainted',
  'Faded',
  'Vinyl Wrapped',
  'Prop Stand Missing',
  'Prop Stand Damaged',
  'Hydraulic Not Working',
  'Repaired',
  'Replaced',
  'Damaged',
  'Not Opening',
];

const List<String> frontWindshieldOptions = [
  'Okay',
  'Scratched',
  'Spots',
  'Replaced',
  'Damaged',
];

const List<String> roofOptions = [
  'Okay',
  'Scratch',
  'Major Scratch',
  'Dent',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Repainted',
  'Faded',
  'Vinyl Wrapped',
  'Repaired',
  'Replaced',
  'Damaged',
];

const List<String> frontBumperOptions = [
  'Okay',
  'Scratch',
  'Major Scratch',
  'Dent',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Repainted',
  'Faded',
  'Vinyl Wrapped',
  'Repaired',
  'Welded',
  'Replaced',
  'Damaged',
  'Grill Damaged',
];

const List<String> headlampOptions = [
  'Okay',
  'Scratched',
  'Repaired',
  'Headlamp Not Working',
  'High Beam Not Working',
  'Low Beam Not Working',
  'DRL Not Working',
  'DRL Damaged',
  'Damaged',
  'Missing',
];

const List<String> foglampOptions = [
  'Okay',
  'Scratched',
  'Repaired',
  'Not Working',
  'Damaged',
  'Missing',
  'Not Applicable',
];

const List<String> fenderOptions = [
  'Okay',
  'Scratch',
  'Major Scratch',
  'Dent',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Repaired',
  'Repainted',
  'Color Faded',
  'Vinyl Wrapped',
  'Inner Lining Missing',
  'Inner Lining Damaged',
  'Inner Wheel Housing Rusted',
  'Fender Wall Repaired',
  'Fender Wall Replaced',
  'Fender Wall Damaged',
  'Replaced',
  'Damaged',
];

const List<String> alloyOptions = [
  'Okay',
  'Steel Rims',
  'Scratched',
  'Damaged',
];

const List<String> tyreLifeOptions = [
  'Tyre Life (10 - 29%)',
  'Tyre Life (30 - 49%)',
  'Tyre Life (50 - 79%)',
  'Tyre Life (80 - 100%)',
  'Damaged',
  'Resoled',
];

const List<String> orvmOptions = [
  'Okay',
  'Not Applicable',
  'Scratched',
  'Repainted',
  'Color Faded',
  'Vinyl Wrapped',
  'Repaired',
  'Auto Fold Not Working',
  'Mirror Adjustment Not Working',
  'Indicator Not Working',
  'Indicator Damaged',
  'Damaged',
];

const List<String> pillarOptions = [
  'Okay',
  'Scratch',
  'Major Scratch',
  'Dent',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Repaired',
  'Repainted',
  'Color Faded',
  'Vinyl Wrapped',
  'Rubber Beading Torn',
  'Rubber Beading Missing',
  'Replaced',
  'Damaged',
];

const List<String> doorOptions = [
  'Okay',
  'Scratch',
  'Major Scratch',
  'Dent',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Repaired',
  'Repainted',
  'Color Faded',
  'Vinyl Wrapped',
  'Handle Not Working',
  'Handle Damaged',
  'Replaced',
  'Damaged',
];
const List<String> radiatorOptions = [
  'Okay',
  'Scratch',
  'Major Scratch',
  'Dent',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Repaired',
  'Repainted',
  'Color Faded',
  'Vinyl Wrapped',
  'Handle Not Working',
  'Handle Damaged',
  'Replaced',
  'Damaged',
];

const List<String> runningBorderOptions = [
  'Okay',
  'Scratch',
  'Major Scratch',
  'Dent',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Repaired',
  'Repainted',
  'Replaced',
  'Damaged',
];

const List<String> quarterPanelOptions = [
  'Okay',
  'Scratch',
  'Major Scratch',
  'Dented',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Fuel Lid Lock Rusted',
  'Inner Wheel Housing Rusted',
  'Repaired',
  'Repainted',
  'Color Faded',
  'Vinyl Wrapped',
  'Inner Lining Missing',
  'Inner Lining Damaged',
  'Replaced',
  'Damaged',
];

const List<String> rearBumperOptions = [
  'Okay',
  'Scratch',
  'Major Scratch',
  'Dent',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Repainted',
  'Color Faded',
  'Vinyl Wrapped',
  'Repaired',
  'Welded',
  'Replaced',
  'Damaged',
];

const List<String> tailLampOptions = [
  'Okay',
  'Repaired',
  'Scratched',
  'Damaged',
  'Missing',
  'Not Working',
];

const List<String> bootDoorOptions = [
  'Okay',
  'Scratch',
  'Major Scratch',
  'Dent',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Repainted',
  'Color Faded',
  'Vinyl Wrapped',
  'Hydraulic Not Working',
  'Repaired',
  'Replaced',
  'Handle Broken / Switch Not Working',
  'Not Opening',
  'Damaged',
];

const List<String> bootFloorOptions = [
  'Okay',
  'Repainted',
  'Dent',
  'Major Dent',
  'Rust',
  'Major Rust',
  'Repair',
  'Major Repair',
  'Cracked',
  'Seal Broken',
  'Replaced',
  'Damaged',
];

const List<String> engineBayOptions = [
  'Okay',
  'Repaired',
  'Replaced',
  'Welded',
  'Damaged',
  'Rusted',
];

const List<String> engineOptions = [
  'Okay',
  'Repaired',
  'MIL Light Glowing',
  'RPM Fluctuating',
  'Over Heating',
  'Misfiring',
  'Fuel Leakage from Injector',
  'Replaced',
  'Long Cranking Due to Weak Compression',
  'Air Filter Box Damaged',
  'Knocking',
];

const List<String> batteryOptions = [
  'Okay',
  'Changed',
  'Weak',
  'Dead',
  'Jumpstart',
  'Acid Leakage',
  'Discharge Light Glowing',
  'Damaged',
];

const List<String> coolantOptions = ['Okay', 'Leaking', 'Dirty', 'Level Low'];

const List<String> engineOilDipstickOptions = ['Okay', 'Broken'];

const List<String> engineOilOptions = ['Okay', 'Leaking', 'Dirty', 'Level Low'];

const List<String> engineMountOptions = [
  'Okay',
  'Broken',
  'Loose',
  'Excess Vibration',
  'Rusted',
];

const List<String> engineBlowByOptions = [
  'No Blow By',
  'Permissible Blow By',
  'Oil Spillage On Idle',
  'Both Permissible Blow By & Oil Spillage On Idle',
  'Backcompression',
];

const List<String> exhaustSmokeOptions = ['Okay', 'Black', 'Blue', 'White'];

const List<String> clutchOptions = [
  'Okay',
  'Abnormal Noise',
  'Hard',
  'Pump Noise',
  'Oil Leakage From Rack',
  'Telescopic Adjustment Not Working',
  'Wheel Adjustment Not Working',
  'Electric Power Steering Not Working',
  'Hydraulic Power Steering Not Working',
  'Tilt Adjustment Not Working',
  'Drive Axel Noisy',
  'Drive Axel Loose',
  'Drive Axel Damaged',
  'Leakage From Differential',
];

const List<String> gearShiftOptions = [
  'Okay',
  'Hard',
  'Not Engaging',
  'Abnormal Noise',
  'Auto Transmission Not Working Properly',
  'Gear Freeplay',
  'Gear Knob Broken / Damaged',
  'Gear Box Cover Damaged',
  'Gear Box Cover Missing',
  '4x4 Lever / Knob Stuck',
];

const List<String> transmissionCommentsOptions = [
  '4X4 / AWD Not Working',
  'Gear Box Oil Leaking',
  'Abnormal Noise From Gear Box',
  'Leakage From Differential',
  '4x4 Transmission Lever Jammed',
];
const List<String> chassisDetailsOptions = [
  'Okay',
  'Damaged',
  'Leaking',
  'Dirty',
  'Level Low',
];

// =====================================================
// MANDATORY IMAGE FIELDS CONFIGURATION
// =====================================================
class MandatoryImagesConfig {
  static final Map<String, Map<String, dynamic>> mandatoryFields = {
    'lhsFenderImages': {'min': 1, 'max': 6, 'mandatory': true},
    'batteryImages': {'min': 1, 'max': 4, 'mandatory': true},
    'sunroofImages': {'min': 1, 'max': 4, 'mandatory': true},
    'frontWindshieldImages': {'min': 1, 'max': 4, 'mandatory': true},
    'roofImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsHeadlampImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsFoglampImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsHeadlampImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsFoglampImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsFrontTyreImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsRunningBorderImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsOrvmImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsAPillarImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsFrontDoorImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsBPillarImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsRearDoorImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsCPillarImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsRearTyreImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsTailLampImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsTailLampImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rearWindshieldImages': {'min': 1, 'max': 4, 'mandatory': true},
    'spareTyreImages': {'min': 1, 'max': 4, 'mandatory': true},
    'bootFloorImages': {'min': 1, 'max': 6, 'mandatory': true},
    'rhsRearTyreImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsCPillarImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsRearDoorImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsBPillarImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsFrontDoorImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsAPillarImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsRunningBorderImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsFrontTyreImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsOrvmImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsFenderImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rcTokenImages': {'min': 2, 'max': 3, 'mandatory': true},
    'insuranceImages': {'min': 2, 'max': 2, 'mandatory': true},
    'form26AndGdCopyIfRcIsLostImages': {'min': 0, 'max': 2, 'mandatory': false},
    'frontMainImages': {'min': 1, 'max': 6, 'mandatory': true},
    'bonnetClosedImages': {'min': 1, 'max': 4, 'mandatory': true},
    'bonnetOpenImages': {'min': 1, 'max': 4, 'mandatory': true},
    'frontBumperLhs45DegreeImages': {'min': 1, 'max': 4, 'mandatory': true},
    'frontBumperRhs45DegreeImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsFullViewImages': {'min': 1, 'max': 6, 'mandatory': true},
    'lhsFrontWheelImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsRearWheelImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsQuarterPanelWithRearDoorOpenImages': {
      'min': 1,
      'max': 4,
      'mandatory': true,
    },
    'rearMainImages': {'min': 1, 'max': 6, 'mandatory': true},
    'rearWithBootDoorOpenImages': {'min': 1, 'max': 6, 'mandatory': true},
    'rearBumperLhs45DegreeImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rearBumperRhs45DegreeImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsFullViewImages': {'min': 1, 'max': 6, 'mandatory': true},
    'rhsQuarterPanelWithRearDoorOpenImages': {
      'min': 1,
      'max': 4,
      'mandatory': true,
    },
    'rhsRearWheelImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsFrontWheelImages': {'min': 1, 'max': 4, 'mandatory': true},
    'engineBayImages': {'min': 1, 'max': 8, 'mandatory': true},
    'lhsApronImages': {'min': 1, 'max': 6, 'mandatory': true},
    'rhsApronImages': {'min': 1, 'max': 6, 'mandatory': true},
    'meterConsoleWithEngineOnImages': {'min': 1, 'max': 6, 'mandatory': true},
    'frontSeatsFromDriverSideImages': {'min': 1, 'max': 6, 'mandatory': true},
    'rearSeatsFromRightSideImages': {'min': 1, 'max': 6, 'mandatory': true},
    'dashboardImages': {'min': 1, 'max': 6, 'mandatory': true},
    'chassisEmbossmentImages': {'min': 1, 'max': 1, 'mandatory': true},
    'vinPlateImages': {'min': 1, 'max': 1, 'mandatory': true},
    'roadTaxImages': {'min': 1, 'max': 1, 'mandatory': true},
    'pucImages': {'min': 0, 'max': 1, 'mandatory': false},
    'frontWiperAndWasherImages': {'min': 1, 'max': 4, 'mandatory': true},
    'lhsRearFogLampImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rhsRearFogLampImages': {'min': 1, 'max': 4, 'mandatory': true},
    'rearWiperAndWasherImages': {'min': 1, 'max': 4, 'mandatory': true},
    'spareWheelImages': {'min': 1, 'max': 4, 'mandatory': true},
    'cowlTopImages': {'min': 1, 'max': 4, 'mandatory': true},
    'firewallImages': {'min': 1, 'max': 4, 'mandatory': true},
    'acImages': {'min': 1, 'max': 4, 'mandatory': true},
    'reverseCameraImages': {'min': 1, 'max': 4, 'mandatory': true},
    'odometerReadingAfterTestDriveImages': {
      'min': 1,
      'max': 4,
      'mandatory': true,
    },

    // Conditional fields
    'duplicateKeyImages': {'min': 0, 'max': 2, 'mandatory': false},
    'airbagImages': {'min': 0, 'max': 6, 'mandatory': false},
    'rtoNocImages': {'min': 0, 'max': 2, 'mandatory': false},
    'rtoForm28Images': {'min': 0, 'max': 2, 'mandatory': false},
  };

  static int getMinRequired(String fieldKey) {
    return mandatoryFields[fieldKey]?['min'] ?? 0;
  }

  static int getMaxImages(String fieldKey) {
    return mandatoryFields[fieldKey]?['max'] ?? 10;
  }

  static bool isMandatory(String fieldKey) {
    return mandatoryFields[fieldKey]?['mandatory'] ?? false;
  }

  static bool shouldShowConditionalField(
    CarInspectionStepperController c,
    String fieldKey,
  ) {
    switch (fieldKey) {
      case 'duplicateKeyImages':
        return c.getText("duplicateKey") == "Yes";
      case 'airbagImages':
        final powerWindowCount =
            int.tryParse(c.getText("noOfPowerWindows")) ?? 0;
        return powerWindowCount >= 1;
      case 'rtoNocImages':
        final rtoNoc = c.getText("rtoNoc");
        return rtoNoc == "Issued" || rtoNoc == "Expired (issued 90 days ago)";
      case 'rtoForm28Images':
        final rtoForm28 = c.getText("rtoForm28");
        return rtoForm28 == "Issued" ||
            rtoForm28 == "Expired (issued 90 days ago)";
      default:
        return false;
    }
  }
}

// =====================================================
// Keyboard Dismiss Widget
// =====================================================
class KeyboardDismissOnScroll extends StatelessWidget {
  final Widget child;
  const KeyboardDismissOnScroll({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          FocusScope.of(context).unfocus();
        }
        return false;
      },
      child: child,
    );
  }
}

// =====================================================
// MAIN SCREEN CLASS
// =====================================================
class CarInspectionStepperScreen extends StatefulWidget {
  final LeadsData lead;
  const CarInspectionStepperScreen({super.key, required this.lead});

  @override
  State<CarInspectionStepperScreen> createState() =>
      _CarInspectionStepperScreenState();
}

class _CarInspectionStepperScreenState
    extends State<CarInspectionStepperScreen> {
  late final CarInspectionStepperController c;
  final ScrollController _stepperScroll = ScrollController();
  late final Worker _stepWorker;
  final GlobalKey _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    c = Get.put(CarInspectionStepperController());
    StepperLock.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoFetchRegistrationData();
      c.applyLeadToForm(widget.lead);
      c.loadDataForAppointment(widget.lead.appointmentId.toString());
    });

    _stepWorker = ever<int>(c.currentStep, (idx) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToStep(idx));
    });
  }

  void _autoFetchRegistrationData() async {
    final registrationNumber = widget.lead.carRegistrationNumber ?? "";

    if (registrationNumber.isNotEmpty) {
      // Set the registration number first
      c.setString("registrationNumber", registrationNumber, silent: true);
      StepperLock.add("registrationNumber");

      // Then fetch RC data
      await c.fetchRcAdvancedAndFill();
    }
  }

  @override
  void dispose() {
    _stepWorker.dispose();
    _stepperScroll.dispose();
    super.dispose();
  }

  void _scrollToStep(int index) {
    if (!_stepperScroll.hasClients) return;
    const double itemSpan = 142;
    final target = (index * itemSpan) - 80;
    _stepperScroll.animateTo(
      target.clamp(0, _stepperScroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _applyLead(LeadsData lead) {
    final leadMap = _leadToMap(lead);
    final smart = _buildSmartLookup(leadMap);

    void setAndLock(String key, String value, {String? mirrorOldKey}) {
      final v = value.trim();
      if (v.isEmpty) return;

      c.setString(key, v, silent: true);
      StepperLock.add(key);

      if (mirrorOldKey != null && mirrorOldKey.trim().isNotEmpty) {
        c.setString(mirrorOldKey, v, silent: true);
        StepperLock.add(mirrorOldKey);
      }
    }

    String pick(String wantKey, {List<String> aliases = const []}) {
      return _pickSmartOrFuzzy(smart, wantKey: wantKey, aliases: aliases);
    }

    final appt = pick(
      "appointmentId",
      aliases: const ["appointment_id", "appointmentID", "apptId", "appt_id"],
    );
    if (appt.isNotEmpty) {
      setAndLock("appointmentId", appt);
    }

    final ie = pick(
      "ieName",
      aliases: const [
        "emailAddress",
        "inspectionEngineerName",
        "inspectionEngineer",
        "engineerName",
      ],
    );
    if (ie.isNotEmpty) {
      setAndLock("ieName", ie);
      c.setString("emailAddress", ie, silent: true);
      StepperLock.add("emailAddress");
    }

    final reg = pick(
      "registrationNumber",
      aliases: const [
        "carRegistrationNumber",
        "carRegistrationNo",
        "carRegNo",
        "regNo",
        "registrationNo",
        "registerationNumber",
        "carregisterationNumber",
        "registration",
      ],
    );
    if (reg.isNotEmpty) {
      setAndLock("registrationNumber", reg);
    }

    final city = pick(
      "inspectionCity",
      aliases: const ["city", "inspection_city", "registrationCity"],
    );
    if (city.isNotEmpty) {
      setAndLock("inspectionCity", city, mirrorOldKey: "city");
    }

    final phone = pick(
      "customerContactNumber",
      aliases: const [
        "contactNumber",
        "phone",
        "phoneNumber",
        "mobile",
        "mobileNumber",
        "contact",
      ],
    );
    if (phone.isNotEmpty) {
      setAndLock("contactNumber", phone);
    }

    final owner = pick(
      "ownerName",
      aliases: const ["registeredOwner", "owner", "registered_owner"],
    );
    if (owner.isNotEmpty) {
      setAndLock("registeredOwner", owner);
    }

    final addr = pick(
      "registeredAddressAsPerRc",
      aliases: const ["registeredAddress", "addressAsPerRc", "address"],
    );
    if (addr.isNotEmpty) {
      setAndLock("registeredAddressAsPerRc", addr);
    }

    final mk = pick("make", aliases: const ["carMake", "brand"]);
    if (mk.isNotEmpty) setAndLock("make", mk);

    final md = pick("model", aliases: const ["carModel", "vehicleModel"]);
    if (md.isNotEmpty) setAndLock("model", md);

    final vr = pick("variant", aliases: const ["carVariant", "trim"]);
    if (vr.isNotEmpty) setAndLock("variant", vr);

    final eng = pick("engineNumber", aliases: const ["engineNo"]);
    if (eng.isNotEmpty) setAndLock("engineNumber", eng);

    final ch = pick("chassisNumber", aliases: const ["chassisNo", "vin"]);
    if (ch.isNotEmpty) setAndLock("chassisNumber", ch);

    final ownershipSerial = pick(
      "ownershipSerialNumber",
      aliases: const ["ownershipSerial", "serialNumber"],
    );
    if (ownershipSerial.isNotEmpty) {
      setAndLock("ownershipSerialNumber", ownershipSerial);
    }

    c.touch();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      c.uiTick.value;

      return Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              key: _scaffoldKey,
              backgroundColor: AppColor.bg,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                titleSpacing: 0,
                title: const Text(
                  'Car Inspection',
                  style: TextStyle(
                    color: AppColor.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColor.textDark,
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
              body: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 88,
                          child: ListView.builder(
                            controller: _stepperScroll,
                            scrollDirection: Axis.horizontal,
                            itemCount: c.steps.length,
                            itemBuilder: (context, index) {
                              final isActive = index == c.currentStep.value;
                              final isCompleted = index < c.currentStep.value;

                              final connectorColor = isCompleted
                                  ? AppColor.stepDone
                                  : (isActive
                                        ? kPrimary
                                        : Colors.grey.shade300);

                              return Row(
                                children: [
                                  _StepItem(
                                    index: index + 1,
                                    title: c.steps[index]['title'] as String,
                                    icon: c.steps[index]['icon'] as IconData,
                                    isActive: isActive,
                                    isCompleted: isCompleted,
                                  ),
                                  if (index < c.steps.length - 1)
                                    Container(
                                      width: 34,
                                      height: 2,
                                      margin: const EdgeInsets.only(bottom: 44),
                                      color: connectorColor,
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: KeyboardDismissOnScroll(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.all(16),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) {
                            final offsetAnim = Tween<Offset>(
                              begin: const Offset(0.02, 0.02),
                              end: Offset.zero,
                            ).animate(anim);

                            return FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: offsetAnim,
                                child: child,
                              ),
                            );
                          },
                          child: _buildCurrentStep(
                            key: ValueKey<int>(c.currentStep.value),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: _BottomBarPro(
                controller: c,
                lead: widget.lead,
              ),
            ),
          ),
          // Global Loading Indicator Stacked on Top
          Obx(() {
            if (c.uploadingFields.isEmpty) return const SizedBox.shrink();

            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildCurrentStep({Key? key}) {
    switch (c.currentStep.value) {
      case 0:
        return RegistrationDocumentsStep(
          key: key,
          formKey: c.formKeys[0],
          c: c,
        );
      case 1:
        return BasicInfoStep(key: key, formKey: c.formKeys[1], c: c);
      case 2:
        return ExteriorFrontStep(key: key, formKey: c.formKeys[2], c: c);
      case 3:
        return ExteriorRearSidesStep(key: key, formKey: c.formKeys[3], c: c);
      case 4:
        return EngineMechanicalStep(key: key, formKey: c.formKeys[4], c: c);
      case 5:
        return InteriorElectronicsStep(key: key, formKey: c.formKeys[5], c: c);
      case 6:
        return MechanicalTestDriveStep(
          key: key,
          formKey: GlobalKey<FormState>(), // Add a placeholder if needed
          c: c,
        );

      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final bool isActive;
  final bool isCompleted;

  const _StepItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final Color circleColor = isCompleted
        ? AppColor.stepDone
        : (isActive ? kPrimary : Colors.grey.shade300);

    final Color textColor = isActive ? AppColor.textDark : Colors.grey.shade600;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: (isActive || isCompleted) ? circleColor : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: circleColor, width: 2.2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: circleColor.withOpacity(0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : icon,
            color: (isActive || isCompleted) ? Colors.white : circleColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 92,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomBarPro extends StatelessWidget {
  final LeadsData lead;
  final CarInspectionStepperController controller;
  const _BottomBarPro({required this.controller, required this.lead});

  @override
  Widget build(BuildContext context) {
    final step = controller.currentStep.value;
    final total = controller.steps.length;
    final isLast = step == total - 1;
    final isTestDriveStep = step == 6; // ✅ Test Drive step index = 6

    // ✅ TestDrive step ko special handling - woh last step hai but Submit button enable hona chahiye
    final shouldDisableButton =
        controller.submitLoading.value || (isLast && !isTestDriveStep);

    const double btnHeight = 52;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (step > 0)
              Expanded(
                child: SizedBox(
                  height: btnHeight,
                  child: OutlinedButton(
                    onPressed: controller.goPrev,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(btnHeight),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.black.withOpacity(0.12)),
                      foregroundColor: AppColor.textDark,
                      backgroundColor: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Previous',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (step > 0) const SizedBox(width: 10),

            Expanded(
              child: SizedBox(
                height: btnHeight,
                child: Obx(() {
                  final isLoading = controller.submitLoading.value;

                  return ElevatedButton(
                    onPressed: shouldDisableButton
                        ? null
                        : () async {
                            if (isTestDriveStep) {
                              final submitted = await controller.goNextOrSubmit(
                                leadId: lead.id.toString(),
                              );
                            } else {
                              await controller.goNextOrSubmit(
                                leadId: lead.id.toString(),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(btnHeight),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isTestDriveStep ? 'Submit' : 'Next',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isTestDriveStep
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationDocumentsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarInspectionStepperController c;

  const RegistrationDocumentsStep({
    super.key,
    required this.formKey,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final regLocked = StepperLock.has('registrationNumber');

    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader(
                  'Registration / RC Details',
                  Icons.description,
                ),
                const SizedBox(height: 14),

                // ✅ Registration Number without Fetch button (auto-fetched in init)
                buildModernTextField(
                  label: 'Registration Number', // Removed *
                  hint: 'e.g. DL 01 AB 1234',
                  icon: Icons.format_list_numbered,
                  initialValue: c.getText("registrationNumber"),
                  readOnly: regLocked,
                  onChanged: (v) {
                    if (regLocked) return;
                    c.setString("registrationNumber", v);
                  },
                ),

                buildModernDatePicker(
                  context: context,
                  label: 'Registration Date',
                  hint: 'Select date',
                  icon: Icons.event,
                  value: c.getDate("registrationDate"),
                  onChanged: (d) => c.setDate("registrationDate", d),
                ),
                buildModernDatePicker(
                  context: context,
                  label: 'Fitness Validity',
                  hint: 'Select date',
                  icon: Icons.verified,
                  value: c.getDate("fitnessValidity"),
                  onChanged: (d) {
                    c.setDate("fitnessValidity", d);
                    c.setDate("fitnessTill", d);
                  },
                ),

                // ✅ RC Book Availability Dropdown (Multi-select)
                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rcBookAvailability",
                  label: "RC Book Availability", // Removed *
                  hint: "RC Book Availability",
                  icon: Icons.book_outlined,
                  items: rcBookAvailabilityOptions,
                  requiredField: false,
                ),

                // ✅ RC Condition Dropdown (Conditional)
                Obx(() {
                  final rcAvailability = c.getText("rcBookAvailability");
                  final shouldShowRcCondition =
                      rcAvailability.contains("Original") ||
                      rcAvailability.contains("Duplicate");

                  if (!shouldShowRcCondition) {
                    return const SizedBox.shrink();
                  }

                  return buildModernSingleListDropdownKey(
                    context: context,
                    c: c,
                    keyName: "rcCondition",
                    label: "RC Condition", // Removed *
                    hint: "RC Condition",
                    icon: Icons.description_outlined,
                    items: rcConditionOptions,
                    requiredField: false,
                  );
                }),

                // ✅ Mismatch in RC Dropdown
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "mismatchInRc",
                  label: "Mismatch in RC", // Removed *
                  hint: "Mismatch in RC",
                  icon: Icons.rule_folder_outlined,
                  items: mismatchInRcOptions,
                  requiredField: false,
                ),

                buildModernTextField(
                  label: 'Policy Number',
                  hint: 'Enter policy number',
                  icon: Icons.policy_outlined,
                  initialValue: c.getText("policyNumber"),
                  onChanged: (v) {
                    c.setString("policyNumber", v);
                    c.setString("insurancePolicyNumber", v);
                  },
                ),

                // ✅ toBeScrapped Dropdown
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "toBeScrapped",
                  label: "To Be Scrapped",
                  hint: "To Be Scrapped",
                  icon: Icons.delete_outline,
                  items: toBeScrappedOptions,
                ),

                // ✅ DuplicateKey Dropdown
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "duplicateKey",
                  label: "Duplicate Key",
                  hint: "Duplicate Key",
                  icon: Icons.vpn_key_outlined,
                  items: duplicateKeyOptions,
                ),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rcTokenImages",
                  label: 'RC Token Images', // Removed *
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rcTokenImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rcTokenImages",
                  ),
                  context: context,
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Road Tax', Icons.receipt_long),
                const SizedBox(height: 14),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "roadTaxValidity",
                  label: 'Road Tax Validity', // Removed *
                  hint: 'Road Tax Validity',
                  icon: Icons.timelapse_rounded,
                  items: roadTaxValidityOptions,
                  requiredField: false,
                ),

                Obx(() {
                  final roadTaxValidity = c.getText("roadTaxValidity");
                  final shouldShowTaxValidTill =
                      roadTaxValidity == "Limited Period";

                  if (!shouldShowTaxValidTill) {
                    return const SizedBox.shrink();
                  }

                  return buildModernDatePicker(
                    context: context,
                    label: 'Tax Valid Till',
                    hint: 'Enter Tax Validity',
                    icon: Icons.event_available_rounded,
                    value: c.getDate("taxValidTill"),
                    onChanged: (v) => c.setDate("taxValidTill", v),
                  );
                }),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "roadTaxImages",
                  label: 'Road Tax Image', // Removed *
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "roadTaxImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "roadTaxImages",
                  ),
                  context: context,
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Insurance Details', Icons.security),
                const SizedBox(height: 14),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "insurance",
                  label: "Insurance", // Removed *
                  hint: "Insurance",
                  icon: Icons.security_outlined,
                  items: insuranceOptions,
                  requiredField: false,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "hypothecationDetails",
                  label: "Hypothecation Details", // Removed *
                  hint: "Hypothecation Details",
                  icon: Icons.account_balance_outlined,
                  items: hypothecationDetailsOptions,
                  requiredField: false,
                ),
                buildModernDatePicker(
                  context: context,
                  label: 'Insurance Validity',
                  hint: 'Enter Insurance Validity',
                  icon: Icons.event,
                  value: c.getDate("insuranceValidity"),
                  onChanged: (v) => c.setDate("insuranceValidity", v),
                ),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "insuranceImages",
                  label: 'Insurance Images', // Removed *
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "insuranceImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "insuranceImages",
                  ),
                  context: context,
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('RTO / Legal Documents', Icons.gavel),
                const SizedBox(height: 14),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rtoNoc",
                  label: "RTO NOC", // Removed *
                  hint: "RTO NOC",
                  icon: Icons.verified_outlined,
                  items: rtoNocOptions,
                  requiredField: false,
                ),

                Obx(() {
                  final isMandatory =
                      MandatoryImagesConfig.shouldShowConditionalField(
                        c,
                        "rtoNocImages",
                      );

                  return buildValidatedMultiImagePicker(
                    c: c,
                    fieldKey: "rtoNocImages",
                    label: 'RTO NOC Images${isMandatory ? '' : ' (optional)'}',
                    minRequired: isMandatory
                        ? MandatoryImagesConfig.getMinRequired("rtoNocImages")
                        : 0,
                    maxImages: MandatoryImagesConfig.getMaxImages(
                      "rtoNocImages",
                    ),
                    context: context,
                  );
                }),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rtoForm28",
                  label: "RTO Form 28", // Removed *
                  hint: "RTO Form 28",
                  icon: Icons.article_outlined,
                  items: rtoForm28Options,
                  requiredField: false,
                ),

                Obx(() {
                  final isMandatory =
                      MandatoryImagesConfig.shouldShowConditionalField(
                        c,
                        "rtoForm28Images",
                      );

                  return buildValidatedMultiImagePicker(
                    c: c,
                    fieldKey: "rtoForm28Images",
                    label:
                        'RTO Form 28 Images${isMandatory ? '' : ' (optional)'}',
                    minRequired: isMandatory
                        ? MandatoryImagesConfig.getMinRequired(
                            "rtoForm28Images",
                          )
                        : 0,
                    maxImages: MandatoryImagesConfig.getMaxImages(
                      "rtoForm28Images",
                    ),
                    context: context,
                  );
                }),

                Obx(() {
                  final isMandatory =
                      MandatoryImagesConfig.shouldShowConditionalField(
                        c,
                        "duplicateKeyImages",
                      );

                  return buildValidatedMultiImagePicker(
                    c: c,
                    fieldKey: "duplicateKeyImages",
                    label:
                        'Duplicate Key Images${isMandatory ? '' : ' (optional)'}',
                    minRequired: isMandatory
                        ? MandatoryImagesConfig.getMinRequired(
                            "duplicateKeyImages",
                          )
                        : 0,
                    maxImages: MandatoryImagesConfig.getMaxImages(
                      "duplicateKeyImages",
                    ),
                    context: context,
                  );
                }),

                Obx(() {
                  final rtoNocValue = c.getText("rtoNoc");
                  final shouldShowForm28Copies =
                      rtoNocValue != "Not Applicable" && rtoNocValue.isNotEmpty;

                  if (!shouldShowForm28Copies) {
                    return const SizedBox.shrink();
                  }

                  return buildValidatedMultiImagePicker(
                    c: c,
                    fieldKey: "rtoForm28CopiesImages",
                    label: 'RTO Form 28 (2 copies)', // Removed *
                    minRequired: 2,
                    maxImages: 2,
                    context: context,
                  );
                }),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "partyPeshi",
                  label: "Party Peshi", // Removed *
                  hint: "Party Peshi",
                  icon: Icons.gavel_outlined,
                  items: partyPeshiOptions,
                  requiredField: false,
                ),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "form26AndGdCopyIfRcIsLostImages",
                  label: 'Form 26 + GD Copy (if RC lost) (optional) (max 2)',
                  minRequired: 0,
                  maxImages: 2,
                  context: context,
                ),
              ],
            ),
          ),
          buildModernCard(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionHeader('PUC / Blacklist', Icons.eco),
                  const SizedBox(height: 14),
                  buildValidatedMultiImagePicker(
                    c: c,
                    fieldKey: "pucImages",
                    label: 'PUC (optional)',
                    minRequired: 0,
                    maxImages: 1,
                    context: context,
                  ),
                  buildModernDatePicker(
                    context: context,
                    label: 'PUC Validity',
                    hint: 'Enter PUC Validity',
                    icon: Icons.event,
                    value: c.getDate("pucValidity"),
                    onChanged: (d) => c.setDate("pucValidity", d),
                  ),

                  buildModernTextField(
                    label: 'PUC Number',
                    hint: 'Enter PUC Number',
                    icon: Icons.confirmation_number_outlined,
                    initialValue: c.getText("pucNumber"),
                    onChanged: (v) => c.setString("pucNumber", v),
                  ),

                  buildModernTextField(
                    label: 'RC Status',
                    hint: 'Enter RC Status',
                    icon: Icons.fact_check_outlined,
                    initialValue: c.getText("rcStatus"),
                    onChanged: (v) => c.setString("rcStatus", v),
                  ),
                ],
              ),
            ),
          ),
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Chassis & VIN', Icons.confirmation_number),
                const SizedBox(height: 14),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "chassisEmbossmentImages",
                  label: 'Chassis Embossment Image',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "chassisEmbossmentImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "chassisEmbossmentImages",
                  ),
                  context: context,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "chassisDetails",
                  label: 'Chassis Details',
                  hint: 'Enter details (optional)',
                  icon: Icons.description_outlined,
                  items: chassisDetailsOptions,
                  requiredField: false,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "vinPlateImages",
                  label: 'VIN Plate Image', // Removed *
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "vinPlateImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "vinPlateImages",
                  ),
                  context: context,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "vinPlateDetails",
                  label: 'VIN Plate Details',
                  hint: 'Enter details (optional)',
                  icon: Icons.description_outlined,
                  items: vinPlateDetailsOptions,
                  requiredField: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ✅ STEP 1: Basic Info
// =====================================================
class BasicInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarInspectionStepperController c;

  const BasicInfoStep({super.key, required this.formKey, required this.c});

  @override
  Widget build(BuildContext context) {
    final ieLocked =
        StepperLock.has("ieName") || StepperLock.has("emailAddress");
    final contactLocked = StepperLock.has("contactNumber");
    final ownerLocked = StepperLock.has("registeredOwner");
    final addrLocked = StepperLock.has("registeredAddressAsPerRc");
    final engineLocked = StepperLock.has("engineNumber");
    final chassisLocked = StepperLock.has("chassisNumber");
    final ownershipSerialLocked = StepperLock.has("ownershipSerialNumber");

    final fuelTypeValue = c.getText("fuelType");
    final fuelTypeLocked = fuelTypeValue.isNotEmpty;

    final makeValue = c.getText("make");
    final makeLockedFromAPI = makeValue.isNotEmpty;

    final modelValue = c.getText("model");
    final modelLockedFromAPI = modelValue.isNotEmpty;

    final variantValue = c.getText("variant");
    final variantLockedFromAPI = variantValue.isNotEmpty;

    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Basic Vehicle Information', Icons.info),
                const SizedBox(height: 14),
                buildModernTextField(
                  label: 'Owner Email',
                  hint: 'Enter email',
                  icon: Icons.person_outline,
                  initialValue: c.getString("ieName") == "N/A"
                      ? ""
                      : c.getString("ieName"),
                  readOnly: ieLocked,
                  onChanged: (v) {
                    if (ieLocked) return;
                    c.setString("ieName", v);
                    c.setString("emailAddress", v);
                  },
                ),
                buildModernSingleListDropdownKey(
                  c: c,
                  label: 'Inspection City',
                  hint: 'Inspection City',
                  icon: Icons.location_city_outlined,
                  context: context,
                  items: const ["Kolkata", "Howrah", "Hugli"],
                  keyName: "inspectionCity",
                ),
                buildModernTextField(
                  label: 'Color',
                  hint: 'Enter Color',
                  icon: Icons.color_lens_outlined,
                  initialValue: c.getText("color"),
                  readOnly: false, // Changed to editable
                  onChanged: (v) => c.setString("color", v),
                ),

                buildModernTextField(
                  label: 'Insurer',
                  hint: 'Enter insurer',
                  icon: Icons.shield_outlined,
                  initialValue: c.getText("insurer"),
                  readOnly: false, // Changed to editable
                  onChanged: (v) => c.setString("insurer", v),
                ),
                buildModernTextField(
                  label: 'Registered RTO',
                  hint: 'Enter Registered RTO',
                  icon: Icons.location_on_outlined,
                  initialValue: c.getText("registeredRto"),
                  readOnly: false, // Changed to editable
                  onChanged: (v) => c.setString("registeredRto", v),
                ),
                buildModernTextField(
                  label: 'Insurance Policy Number',
                  hint: 'Enter Insurance Number',
                  icon: Icons.policy_outlined,
                  initialValue: c.getText("insurancePolicyNumber"),
                  readOnly: false, // Changed to editable
                  onChanged: (v) => c.setString("insurancePolicyNumber", v),
                ),

                buildModernTextField(
                  label: 'Contact Number',
                  hint: 'Auto-filled from customer contact',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  initialValue: c.getText("contactNumber"),
                  readOnly: contactLocked,
                  onChanged: (v) {
                    if (contactLocked) return;
                    c.setString("contactNumber", v);
                  },
                ),
                buildModernTextField(
                  label: 'Registered Owner',
                  hint: 'Auto-filled from owner name',
                  icon: Icons.badge_outlined,
                  initialValue: c.getText("registeredOwner"),
                  readOnly: ownerLocked,
                  onChanged: (v) {
                    if (ownerLocked) return;
                    c.setString("registeredOwner", v);
                  },
                ),
                buildModernTextField(
                  label: 'Registered Address (as per RC)',
                  hint: 'Enter address',
                  icon: Icons.home_outlined,
                  initialValue: c.getText("registeredAddressAsPerRc"),
                  readOnly: addrLocked,
                  onChanged: (v) {
                    if (addrLocked) return;
                    c.setString("registeredAddressAsPerRc", v);
                  },
                ),
                buildModernTextField(
                  label: 'Ownership Serial Number',
                  hint: 'Auto-filled from leads',
                  icon: Icons.confirmation_number_outlined,
                  initialValue: c.getText("ownerSerialNumber"),
                  readOnly: ownershipSerialLocked,
                  onChanged: (v) {
                    if (ownershipSerialLocked) return;
                    c.setString("ownerSerialNumber", v);
                  },
                ),

                if (makeLockedFromAPI)
                  buildModernTextField(
                    label: 'Make',
                    hint: 'Make',
                    icon: Icons.directions_car_filled_outlined,
                    initialValue: makeValue,
                    readOnly: false, // Changed to editable
                    onChanged: (v) {
                      c.setString("make", v);
                    },
                  )
                else
                  buildModernSingleListDropdownKey(
                    context: context,
                    c: c,
                    keyName: "make",
                    label: "Make",
                    hint: "Make",
                    icon: Icons.directions_car_filled_outlined,
                    items: const [
                      "Maruti Suzuki",
                      "Hyundai",
                      "Tata",
                      "Mahindra",
                      "Honda",
                      "Toyota",
                      "Other",
                    ],
                  ),

                if (modelLockedFromAPI)
                  buildModernTextField(
                    label: 'Model',
                    hint: 'Model',
                    icon: Icons.car_rental_outlined,
                    initialValue: modelValue,
                    readOnly: false, // Changed to editable
                    onChanged: (v) {
                      c.setString("model", v);
                    },
                  )
                else
                  buildModernSingleListDropdownKey(
                    context: context,
                    c: c,
                    keyName: "model",
                    label: "Model",
                    hint: "Model",
                    icon: Icons.car_rental_outlined,
                    items: const [
                      "Swift",
                      "i20",
                      "Altroz",
                      "Scorpio",
                      "City",
                      "Innova",
                      "Other",
                    ],
                  ),

                if (variantLockedFromAPI)
                  buildModernTextField(
                    label: 'Variant',
                    hint: 'Enter variant',
                    icon: Icons.auto_awesome_mosaic_outlined,
                    initialValue: variantValue,
                    readOnly: false, // Changed to editable
                    onChanged: (v) {
                      c.setString("variant", v);
                    },
                  )
                else
                  buildModernSingleListDropdownKey(
                    context: context,
                    c: c,
                    keyName: "variant",
                    label: "Variant",
                    hint: "Variant",
                    icon: Icons.auto_awesome_mosaic_outlined,
                    items: const [
                      "LXI",
                      "VXI",
                      "ZXI",
                      "Base",
                      "Mid",
                      "Top",
                      "Other",
                    ],
                  ),

                if (fuelTypeLocked)
                  buildModernTextField(
                    label: 'Fuel Type', // Removed *
                    hint: 'Enter Fueltype',
                    icon: Icons.local_gas_station_outlined,
                    initialValue: fuelTypeValue,
                    readOnly: false, // Changed to editable
                    onChanged: (v) => c.setString("fuelType", v),
                  )
                else
                  buildModernSingleListDropdownKey(
                    context: context,
                    c: c,
                    keyName: "fuelType",
                    label: "Fuel Type", // Removed *
                    hint: "Fuel Type",
                    icon: Icons.local_gas_station_outlined,
                    items: fuelTypeOptions,
                    requiredField: false,
                  ),

                buildModernTextField(
                  label: 'Engine Number',
                  hint: 'Enter Engine Number',
                  icon: Icons.numbers,
                  initialValue: c.getText("engineNumber"),
                  readOnly: engineLocked,
                  onChanged: (v) {
                    if (engineLocked) return;
                    c.setString("engineNumber", v);
                  },
                ),
                buildModernTextField(
                  label: 'Chassis Number',
                  hint: 'Enter Chassis Number',
                  icon: Icons.confirmation_number_outlined,
                  initialValue: c.getText("chassisNumber"),
                  readOnly: chassisLocked,
                  onChanged: (v) {
                    if (chassisLocked) return;
                    c.setString("chassisNumber", v);
                  },
                ),
                buildModernDatePicker(
                  context: context,
                  label: 'Year & Month Of Manufacture',
                  hint: 'Enter year and month',
                  icon: Icons.calendar_today_outlined,
                  value: c.getDate("yearAndMonthOfManufacture"),
                  onChanged: (v) {
                    c.setDate("yearAndMonthOfManufacture", v);
                    c.setDate("yearMonthOfManufacture", v);
                  },
                ),
                buildModernTextField(
                  label: 'Cubic Capacity (CC)',
                  hint: 'Enter CC',
                  icon: Icons.speed_outlined,
                  keyboardType: TextInputType.number,
                  initialValue: c.getText("cubicCapacity"),
                  readOnly: false, // Changed to editable
                  onChanged: (v) => c.setString("cubicCapacity", v),
                ),
                buildModernTextField(
                  label: 'Number of Cylinders',
                  hint: 'Enter Number',
                  icon: Icons.settings_outlined,
                  keyboardType: TextInputType.number,
                  initialValue: c.getText("numberOfCylinders"),
                  readOnly: false, // Changed to editable
                  onChanged: (v) => c.setString("numberOfCylinders", v),
                ),
                buildModernTextField(
                  label: 'Hypothecated To',
                  hint: 'Enter bank/finance name',
                  icon: Icons.account_balance_outlined,
                  initialValue: c.getText("hypothecatedTo"),
                  onChanged: (v) => c.setString("hypothecatedTo", v),
                ),
                buildModernTextField(
                  label: 'Norms',
                  hint: 'Enter Norms',
                  icon: Icons.eco_outlined,
                  initialValue: c.getText("norms"),
                  readOnly: false, // Changed to editable
                  onChanged: (v) => c.setString("norms", v),
                ),
                buildModernTextField(
                  label: 'Seating Capacity',
                  hint: 'Enter Seating Capacity',
                  icon: Icons.event_seat_outlined,
                  keyboardType: TextInputType.number,
                  initialValue: c.getText("seatingCapacity"),
                  readOnly: false, // Changed to editable
                  onChanged: (v) => c.setString("seatingCapacity", v),
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "additionalDetailsDropdownList",
                  mirrorOldKey: "additionalDetails",
                  label: "Additional Details",
                  hint: "Additional Details",
                  icon: Icons.fact_check_outlined,
                  items: const [
                    "Migrated From Other State",
                    "Car Converted From Commercial To Private",
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ✅ STEP 2: Exterior Front
// =====================================================
class ExteriorFrontStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarInspectionStepperController c;
  const ExteriorFrontStep({super.key, required this.formKey, required this.c});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader(
                  'Exterior - Front Side',
                  Icons.directions_car,
                ),
                const SizedBox(height: 14),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "frontMainImages",
                  label: 'Front Main Images (min 1)', // Removed *
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "frontMainImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "frontMainImages",
                  ),
                  context: context,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "bonnet",
                  label: "Bonnet",
                  hint: "Bonnet",
                  icon: Icons.car_repair_outlined,
                  items: bonnetOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "frontBumper",
                  label: "Front Bumper",
                  hint: "Front Bumper",
                  icon: Icons.construction_outlined,
                  items: frontBumperOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "frontWindshield",
                  label: "Front Windshield",
                  hint: "Front Windshield",
                  icon: Icons.window_outlined,
                  items: frontWindshieldOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "roof",
                  label: "Roof",
                  hint: "Roof",
                  icon: Icons.roofing_outlined,
                  items: roofOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsHeadlamp",
                  label: "Left Headlamp",
                  hint: "Left Headlamp",
                  icon: Icons.highlight_outlined,
                  items: headlampOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsHeadlamp",
                  label: "Right Headlamp",
                  hint: "Right Headlamp",
                  icon: Icons.highlight_outlined,
                  items: headlampOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsFoglamp",
                  label: "Left Foglamp",
                  hint: "Left Foglamp",
                  icon: Icons.wb_cloudy_outlined,
                  items: foglampOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsFoglamp",
                  label: "Right Foglamp",
                  hint: "Right Foglamp",
                  icon: Icons.wb_cloudy_outlined,
                  items: foglampOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsFender",
                  label: "LHS Fender",
                  hint: "LHS Fender",
                  icon: Icons.car_repair_outlined,
                  items: fenderOptions,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "lhsFenderImages",
                  label: 'Left Fender Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "lhsFenderImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "lhsFenderImages",
                  ),
                  context: context,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "frontWiperAndWasher",
                  label: "Front Wiper & Washer",
                  hint: "Front Wiper & Washer",
                  icon: Icons.water_drop_outlined,
                  items: workingNA,
                ),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "frontWiperAndWasherImages",
                  label: 'Front Wiper & Washer Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "frontWiperAndWasherImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "frontWiperAndWasherImages",
                  ),
                  context: context,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "commentsOnAc",
                  label: "Comments on AC (Optional)",
                  hint: "Comments on AC",
                  icon: Icons.comment_outlined,
                  items: const [
                    "Okay",
                    "Not Cooling",
                    "Noise in AC",
                    "Gas Leakage",
                    "Compressor Issue",
                    "Blower Not Working",
                  ],
                ),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "bonnetImages",
                  label: 'Bonnet Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "bonnetImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages("bonnetImages"),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "frontBumperImages",
                  label: 'Front Bumper Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "frontBumperImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "frontBumperImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "frontWindshieldImages",
                  label: 'Front Windshield Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "frontWindshieldImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "frontWindshieldImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "roofImages",
                  label: 'Roof Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "roofImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages("roofImages"),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "bonnetClosedImages",
                  label: 'Bonnet Closed Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "bonnetClosedImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "bonnetClosedImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "bonnetOpenImages",
                  label: 'Bonnet Open Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "bonnetOpenImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "bonnetOpenImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "frontBumperLhs45DegreeImages",
                  label: 'Front Bumper Left 45° Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "frontBumperLhs45DegreeImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "frontBumperLhs45DegreeImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "frontBumperRhs45DegreeImages",
                  label: 'Front Bumper Right 45° Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "frontBumperRhs45DegreeImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "frontBumperRhs45DegreeImages",
                  ),
                  context: context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ✅ STEP 3: Exterior Rear + Sides
// =====================================================
class ExteriorRearSidesStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarInspectionStepperController c;

  const ExteriorRearSidesStep({
    super.key,
    required this.formKey,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Exterior - Rear Side', Icons.car_repair),
                const SizedBox(height: 14),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rearBumper",
                  label: "Rear Bumper",
                  hint: "Rear Bumper",
                  icon: Icons.construction_outlined,
                  items: rearBumperOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rearWindshield",
                  label: "Rear Windshield",
                  hint: "Rear Windshield",
                  icon: Icons.window_outlined,
                  items: frontWindshieldOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "bootDoor",
                  label: "Boot Door",
                  hint: "Boot Door",
                  icon: Icons.door_back_door_outlined,
                  items: bootDoorOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "bootFloor",
                  label: "Boot Floor",
                  hint: "Boot Floor",
                  icon: Icons.layers_outlined,
                  items: bootFloorOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsTailLamp",
                  label: "Left Tail Lamp",
                  hint: "Left Tail Lamp",
                  icon: Icons.lightbulb_outline,
                  items: tailLampOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsTailLamp",
                  label: "Right Tail Lamp",
                  hint: "Right Tail Lamp",
                  icon: Icons.lightbulb_outline,
                  items: tailLampOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "spareTyre",
                  label: "Spare Tyre",
                  hint: "Spare Tyre",
                  icon: Icons.tire_repair_outlined,
                  items: tyreLifeOptions,
                ),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rearWiperAndWasherImages",
                  label: 'Rear Wiper & Washer Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rearWiperAndWasherImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rearWiperAndWasherImages",
                  ),
                  context: context,
                ),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rearMainImages",
                  label: 'Rear Main Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rearMainImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rearMainImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rearWithBootDoorOpenImages",
                  label: 'Rear with Boot Door Open Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rearWithBootDoorOpenImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rearWithBootDoorOpenImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "bootFloorImages",
                  label: 'Boot Floor Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "bootFloorImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "bootFloorImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "spareTyreImages",
                  label: 'Spare Tyre Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "spareTyreImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "spareTyreImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rearBumperLhs45DegreeImages",
                  label: 'Rear Bumper Left 45° Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rearBumperLhs45DegreeImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rearBumperLhs45DegreeImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rearBumperRhs45DegreeImages",
                  label: 'Rear Bumper Right 45° Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rearBumperRhs45DegreeImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rearBumperRhs45DegreeImages",
                  ),
                  context: context,
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader(
                  'Exterior - Left Side',
                  Icons.directions_car,
                ),
                const SizedBox(height: 14),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "lhsSideMainImages",
                  label: 'Left Side Main Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "lhsSideMainImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "lhsSideMainImages",
                  ),
                  context: context,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsFrontDoor",
                  label: "Left Front Door",
                  hint: "Left Front Door",
                  icon: Icons.door_front_door_outlined,
                  items: doorOptions,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "lhsFrontDoorImages",
                  label: 'Left Front Door Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "lhsFrontDoorImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "lhsFrontDoorImages",
                  ),
                  context: context,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsRearDoor",
                  label: "Left Rear Door",
                  hint: "Left Rear Door",
                  icon: Icons.door_back_door_outlined,
                  items: doorOptions,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "lhsRearDoorImages",
                  label: 'Left Rear Door Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "lhsRearDoorImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "lhsRearDoorImages",
                  ),
                  context: context,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsQuarterPanel",
                  label: "Left Quarter Panel",
                  hint: "Left Quarter Panel",
                  icon: Icons.crop_square_outlined,
                  items: quarterPanelOptions,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "lhsQuarterPanelImages",
                  label: 'Left Quarter Panel Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "lhsQuarterPanelImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "lhsQuarterPanelImages",
                  ),
                  context: context,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsOrvm",
                  label: "Left ORVM",
                  hint: "Left ORVM",
                  icon: Icons.remove_red_eye_outlined,
                  items: orvmOptions,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "lhsOrvmImages",
                  label: 'Left ORVM Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "lhsOrvmImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "lhsOrvmImages",
                  ),
                  context: context,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsFrontAlloy",
                  label: "Left Front Alloy",
                  hint: "Left Front Alloy",
                  icon: Icons.tire_repair_outlined,
                  items: alloyOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsFrontTyre",
                  label: "Left Front Tyre",
                  hint: "Left Front Tyre",
                  icon: Icons.tire_repair_outlined,
                  items: tyreLifeOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsAPillar",
                  label: "Left A Pillar",
                  hint: "Left A Pillar",
                  icon: Icons.view_column_outlined,
                  items: pillarOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsBPillar",
                  label: "Left B Pillar",
                  hint: "Left B Pillar",
                  icon: Icons.view_column_outlined,
                  items: pillarOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsCPillar",
                  label: "Left C Pillar",
                  hint: "Left C Pillar",
                  icon: Icons.view_column_outlined,
                  items: pillarOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsRunningBorder",
                  label: "Left Running Border",
                  hint: "Left Running Border",
                  icon: Icons.border_bottom_outlined,
                  items: runningBorderOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsRearAlloy",
                  label: "Left Rear Alloy",
                  hint: "Left Rear Alloy",
                  icon: Icons.tire_repair_outlined,
                  items: alloyOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsRearTyre",
                  label: "Left Rear Tyre",
                  hint: "Left Rear Tyre",
                  icon: Icons.tire_repair_outlined,
                  items: tyreLifeOptions,
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader(
                  'Exterior - Right Side',
                  Icons.directions_car,
                ),
                const SizedBox(height: 14),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rhsSideMainImages",
                  label: 'Right Side Main Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rhsSideMainImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rhsSideMainImages",
                  ),
                  context: context,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsFrontDoor",
                  label: "Right Front Door",
                  hint: "Right Front Door",
                  icon: Icons.door_front_door_outlined,
                  items: doorOptions,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rhsFrontDoorImages",
                  label: 'Right Front Door Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rhsFrontDoorImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rhsFrontDoorImages",
                  ),
                  context: context,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsRearDoor",
                  label: "Right Rear Door",
                  hint: "Right Rear Door",
                  icon: Icons.door_back_door_outlined,
                  items: doorOptions,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rhsRearDoorImages",
                  label: 'Right Rear Door Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rhsRearDoorImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rhsRearDoorImages",
                  ),
                  context: context,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsQuarterPanel",
                  label: "Right Quarter Panel",
                  hint: "Right Quarter Panel",
                  icon: Icons.crop_square_outlined,
                  items: quarterPanelOptions,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rhsQuarterPanelImages",
                  label: 'Right Quarter Panel Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rhsQuarterPanelImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rhsQuarterPanelImages",
                  ),
                  context: context,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsOrvm",
                  label: "Right ORVM",
                  hint: "Right ORVM",
                  icon: Icons.remove_red_eye_outlined,
                  items: orvmOptions,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rhsOrvmImages",
                  label: 'Right ORVM Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rhsOrvmImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rhsOrvmImages",
                  ),
                  context: context,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsFender",
                  label: "Right Fender",
                  hint: "Right Fender",
                  icon: Icons.car_repair_outlined,
                  items: fenderOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsFrontAlloy",
                  label: "Right Front Alloy",
                  hint: "Right Front Alloy",
                  icon: Icons.tire_repair_outlined,
                  items: alloyOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsFrontTyre",
                  label: "Right Front Tyre",
                  hint: "Right Front Tyre",
                  icon: Icons.tire_repair_outlined,
                  items: tyreLifeOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsAPillar",
                  label: "Right A Pillar",
                  hint: "Right A Pillar",
                  icon: Icons.view_column_outlined,
                  items: pillarOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsBPillar",
                  label: "Right B Pillar",
                  hint: "Right B Pillar",
                  icon: Icons.view_column_outlined,
                  items: pillarOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsCPillar",
                  label: "Right C Pillar",
                  hint: "Right C Pillar",
                  icon: Icons.view_column_outlined,
                  items: pillarOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsRunningBorder",
                  label: "Right Running Border",
                  hint: "Right Running Border",
                  icon: Icons.border_bottom_outlined,
                  items: runningBorderOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsRearAlloy",
                  label: "Right Rear Alloy",
                  hint: "Right Rear Alloy",
                  icon: Icons.tire_repair_outlined,
                  items: alloyOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsRearTyre",
                  label: "Right Rear Tyre",
                  hint: "Right Rear Tyre",
                  icon: Icons.tire_repair_outlined,
                  items: tyreLifeOptions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ✅ STEP 4: Engine & Mechanical
// =====================================================
class EngineMechanicalStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarInspectionStepperController c;

  const EngineMechanicalStep({
    super.key,
    required this.formKey,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Engine & Mechanical', Icons.build),
                const SizedBox(height: 14),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "upperCrossMember",
                  label: "Upper Cross Member",
                  hint: "Upper Cross Member",
                  icon: Icons.construction_outlined,
                  items: engineBayOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "radiatorSupport",
                  label: "Radiator Support",
                  hint: "Radiator Support",
                  icon: Icons.ac_unit_outlined,
                  items: engineBayOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "headlightSupport",
                  label: "Headlight Support",
                  hint: "Headlight Support",
                  icon: Icons.lightbulb_outline,
                  items: engineBayOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lowerCrossMember",
                  label: "Lower Cross Member",
                  hint: "Lower Cross Member",
                  icon: Icons.construction_outlined,
                  items: engineBayOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsApron",
                  label: "Left Apron",
                  hint: "Left Apron",
                  icon: Icons.view_sidebar_outlined,
                  items: engineBayOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsApron",
                  label: "Right Apron",
                  hint: "Right Apron",
                  icon: Icons.view_sidebar_outlined,
                  items: engineBayOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "firewall",
                  label: "Firewall",
                  hint: "Firewall",
                  icon: Icons.fireplace_outlined,
                  items: engineBayOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "cowlTop",
                  label: "Cowl Top",
                  hint: "Cowl Top",
                  icon: Icons.roofing_outlined,
                  items: engineBayOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "engine",
                  label: "Engine",
                  hint: "Engine",
                  icon: Icons.settings_outlined,
                  items: engineOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "commentsOnEngine",
                  label: 'Comments on Engine (Optional)',
                  hint: 'Enter remarks about engine',
                  icon: Icons.comment_outlined,
                  items: engineOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "battery",
                  label: "Battery",
                  hint: "Battery",
                  icon: Icons.battery_charging_full_outlined,
                  items: batteryOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "coolant",
                  label: "Coolant",
                  hint: "Coolant",
                  icon: Icons.water_outlined,
                  items: coolantOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "commentsOnRadiator",
                  label: 'Comments on Radiator (Optional)',
                  hint: 'Enter remarks about radiator',
                  icon: Icons.comment_outlined,
                  items: radiatorOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "engineOilLevelDipstick",
                  label: "Engine Oil Level Dipstick",
                  hint: "Engine Oil Level Dipstick",
                  icon: Icons.oil_barrel_outlined,
                  items: engineOilDipstickOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "engineOil",
                  label: "Engine Oil",
                  hint: "Engine Oil",
                  icon: Icons.oil_barrel_outlined,
                  items: engineOilOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "commentsOnEngineOil",
                  label: 'Comments on Engine Oil (Optional)',
                  hint: 'Enter remarks about engine oil',
                  icon: Icons.comment_outlined,
                  items: engineOilOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "engineMount",
                  label: "Engine Mount",
                  hint: "Engine Mount",
                  icon: Icons.anchor_outlined,
                  items: engineMountOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "enginePermisableBlowBy",
                  label: "Engine Permissible Blow By",
                  hint: "Engine Permissible Blow By",
                  icon: Icons.air_outlined,
                  items: engineBlowByOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "exhaustSmoke",
                  label: "Exhaust Smoke",
                  hint: "Exhaust Smoke",
                  icon: Icons.cloud_outlined,
                  items: exhaustSmokeOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "clutch",
                  label: "Clutch",
                  hint: "Clutch",
                  icon: Icons.settings_applications_outlined,
                  items: clutchOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "gearShift",
                  label: "Gear Shift",
                  hint: "Gear Shift",
                  icon: Icons.swap_horiz_outlined,
                  items: gearShiftOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "commentsOnTransmission",
                  label: 'Comments on Transmission (Optional)',
                  hint: 'Enter remarks about transmission',
                  icon: Icons.comment_outlined,
                  items: transmissionCommentsOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "transmissionComments",
                  label: "Transmission Comments",
                  hint: "Transmission Comments",
                  icon: Icons.comment_outlined,
                  items: transmissionCommentsOptions,
                ),

                buildModernMultiSelectDropdownKey(
                  context: context,
                  c: c,
                  keyName: "commentsOnTowing",
                  label: 'Comments on Towing (Optional)',
                  hint: 'Enter remarks about towing',
                  icon: Icons.comment_outlined,
                  items: towingCommentsOptions,
                ),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "cowlTopImages",
                  label: 'Cowl Top Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "cowlTopImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "cowlTopImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "firewallImages",
                  label: 'Firewall Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "firewallImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "firewallImages",
                  ),
                  context: context,
                ),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "engineBayImages",
                  label: 'Engine Bay Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "engineBayImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "engineBayImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "lhsApronImages",
                  label: 'Left Apron Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "lhsApronImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "lhsApronImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rhsApronImages",
                  label: 'Right Apron Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rhsApronImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rhsApronImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "batteryImages",
                  label: 'Battery Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "batteryImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "batteryImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "additionalEngineImages",
                  label: 'Additional Engine Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "additionalEngineImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "additionalEngineImages",
                  ),
                  context: context,
                ),

                buildValidatedVideoPicker(
                  context: context,
                  c: c,
                  fieldKey: "engineVideo",
                  label: 'Engine Video', // Removed *
                  requiredVideo: false,
                  enabled: true,
                ),

                buildValidatedVideoPicker(
                  context: context,
                  c: c,
                  fieldKey: "exhaustSmokeVideo",
                  label: 'Exhaust Smoke Video', // Removed *
                  requiredVideo: false,
                  enabled: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ✅ STEP 5: Interior & Electronics
// =====================================================
class InteriorElectronicsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarInspectionStepperController c;

  const InteriorElectronicsStep({
    super.key,
    required this.formKey,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader(
                  'Interior & Electronics',
                  Icons.airline_seat_recline_normal,
                ),
                const SizedBox(height: 14),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "irvm",
                  label: "Internal Rear View Mirror (IRVM)",
                  hint: "IRVM",
                  icon: Icons.remove_red_eye_outlined,
                  items: yesNo,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "dashboard",
                  label: "Dashboard Condition",
                  hint: "Dashboard",
                  icon: Icons.dashboard_outlined,
                  items: okIssue,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "steeringMountedMediaControls",
                  label: "Steering Mounted Media Controls",
                  hint: "Steering Media Controls",
                  icon: Icons.audiotrack_outlined,
                  items: yesNo,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "steeringMountedSystemControls",
                  label: "Steering Mounted System Controls",
                  hint: "Steering System Controls",
                  icon: Icons.settings_outlined,
                  items: yesNo,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "infotainmentSystem",
                  label: "Infotainment System",
                  hint: "Infotainment System",
                  icon: Icons.speaker_outlined,
                  items: infotainmentOptions,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "seatsUpholstery",
                  label: "Seats Upholstery",
                  hint: "Seats Upholstery",
                  icon: Icons.event_seat_outlined,
                  items: seatsUpholsteryOptions,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "reverseCamera",
                  label: "Reverse Camera",
                  hint: "Reverse Camera",
                  icon: Icons.videocam_outlined,
                  items: yesNo,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "acType",
                  label: "AC Type",
                  hint: "AC Type",
                  icon: Icons.ac_unit_outlined,
                  items: acTypeOptions,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "acCooling",
                  label: "AC Cooling",
                  hint: "AC Cooling",
                  icon: Icons.thermostat_outlined,
                  items: acCoolingOptions,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "coDriverSeatAirbag",
                  label: "Co-Driver Seat Airbag",
                  hint: "Co-Driver Airbag",
                  icon: Icons.airline_seat_recline_extra_outlined,
                  items: yesNo,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "driverSeatAirbag",
                  label: "Driver Seat Airbag",
                  hint: "Driver Airbag",
                  icon: Icons.airline_seat_recline_extra_outlined,
                  items: yesNo,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsCurtainAirbag",
                  label: "Left Curtain Airbag",
                  hint: "Left Curtain Airbag",
                  icon: Icons.window_outlined,
                  items: yesNo,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsCurtainAirbag",
                  label: "Right Curtain Airbag",
                  hint: "Right Curtain Airbag",
                  icon: Icons.window_outlined,
                  items: yesNo,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsRearSideAirbag",
                  label: "Left Rear Side Airbag",
                  hint: "Left Rear Airbag",
                  icon: Icons.airline_seat_recline_extra_outlined,
                  items: yesNo,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsRearSideAirbag",
                  label: "Right Rear Side Airbag",
                  hint: "Right Rear Airbag",
                  icon: Icons.airline_seat_recline_extra_outlined,
                  items: yesNo,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "driverSideKneeAirbag",
                  label: "Driver Side Knee Airbag",
                  hint: "Driver Knee Airbag",
                  icon: Icons.airline_seat_legroom_normal_outlined,
                  items: yesNo,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "coDriverKneeSeatAirbag",
                  label: "Co-Driver Knee Seat Airbag",
                  hint: "Co-Driver Knee Airbag",
                  icon: Icons.airline_seat_legroom_normal_outlined,
                  items: yesNo,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "driverAirbag",
                  label: "Driver Airbag",
                  hint: "Driver Airbag",
                  icon: Icons.airline_seat_recline_extra_outlined,
                  items: yesNo,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "coDriverAirbag",
                  label: "Co-Driver Airbag",
                  hint: "Co-Driver Airbag",
                  icon: Icons.airline_seat_recline_extra_outlined,
                  items: yesNo,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "driverSeat",
                  label: "Driver Seat Condition",
                  hint: "Driver Seat",
                  icon: Icons.event_seat_outlined,
                  items: okIssue,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "coDriverSeat",
                  label: "Co-Driver Seat Condition",
                  hint: "Co-Driver Seat",
                  icon: Icons.event_seat_outlined,
                  items: okIssue,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "frontCentreArmRest",
                  label: "Front Centre Arm Rest",
                  hint: "Front Arm Rest",
                  icon: Icons.chair_outlined,
                  items: okIssue,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rearSeats",
                  label: "Rear Seats Condition",
                  hint: "Rear Seats",
                  icon: Icons.event_seat_outlined,
                  items: okIssue,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "thirdRowSeats",
                  label: "Third Row Seats Condition",
                  hint: "Third Row Seats",
                  icon: Icons.event_seat_outlined,
                  items: okIssue,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsFrontDoorFeatures",
                  label: "Right Front Door Features",
                  hint: "Right Front Door",
                  icon: Icons.door_front_door_outlined,
                  items: const ["Power Window Working", "Manual", "N/A"],
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsFrontDoorFeatures",
                  label: "Left Front Door Features",
                  hint: "Left Front Door",
                  icon: Icons.door_front_door_outlined,
                  items: const ["Power Window Working", "Manual", "N/A"],
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rhsRearDoorFeatures",
                  label: "Right Rear Door Features",
                  hint: "Right Rear Door",
                  icon: Icons.door_back_door_outlined,
                  items: const ["Power Window Working", "Manual", "N/A"],
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "lhsRearDoorFeatures",
                  label: "Left Rear Door Features",
                  hint: "Left Rear Door",
                  icon: Icons.door_back_door_outlined,
                  items: const ["Power Window Working", "Manual", "N/A"],
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "commentOnInterior",
                  label: "Comment On Interior",
                  hint: "Interior Comment",
                  icon: Icons.comment_outlined,
                  items: okIssue,
                ),

                buildModernTextField(
                  label: 'Additional Interior Comments (Optional)',
                  hint: 'Enter remarks about interior',
                  icon: Icons.comment_outlined,
                  initialValue: c.getText("commentsOnInterior"),
                  onChanged: (v) => c.setString("commentsOnInterior", v),
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "sunroof",
                  label: "Sunroof",
                  hint: "Sunroof",
                  icon: Icons.wb_sunny_outlined,
                  items: yesNo,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "sunroofImages",
                  label: 'Sunroof Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "sunroofImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "sunroofImages",
                  ),
                  context: context,
                ),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "dashboardImages",
                  label: 'Dashboard Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "dashboardImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "dashboardImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "meterConsoleWithEngineOnImages",
                  label: 'Meter Console (Engine On) Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "meterConsoleWithEngineOnImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "meterConsoleWithEngineOnImages",
                  ),
                  context: context,
                ),
                Obx(() {
                  final isMandatory =
                      MandatoryImagesConfig.shouldShowConditionalField(
                        c,
                        "airbagImages",
                      );

                  return buildValidatedMultiImagePicker(
                    c: c,
                    fieldKey: "airbagImages",
                    label: 'Airbag Images${isMandatory ? '' : ' (optional)'}',
                    minRequired: isMandatory
                        ? MandatoryImagesConfig.getMinRequired("airbagImages")
                        : 0,
                    maxImages: MandatoryImagesConfig.getMaxImages(
                      "airbagImages",
                    ),
                    context: context,
                  );
                }),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "frontSeatsFromDriverSideImages",
                  label: 'Front Seats (Driver Side) Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "frontSeatsFromDriverSideImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "frontSeatsFromDriverSideImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "rearSeatsFromRightSideImages",
                  label: 'Rear Seats (Right Side) Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "rearSeatsFromRightSideImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "rearSeatsFromRightSideImages",
                  ),
                  context: context,
                ),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "acImages",
                  label: 'AC Images',
                  minRequired: MandatoryImagesConfig.getMinRequired("acImages"),
                  maxImages: MandatoryImagesConfig.getMaxImages("acImages"),
                  context: context,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "noOfPowerWindows",
                  label: "No. of Power Windows",
                  hint: "Power Windows Count",
                  icon: Icons.window_outlined,
                  items: const ["2", "4", "Not Applicable"],
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "inbuiltSpeaker",
                  label: "Inbuilt Speaker",
                  hint: "Inbuilt Speaker",
                  icon: Icons.speaker_outlined,
                  items: yesNo,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "externalSpeaker",
                  label: "External Speaker",
                  hint: "External Speaker",
                  icon: Icons.speaker_group_outlined,
                  items: yesNo,
                ),

                buildModernTextField(
                  label: "No of Airbags",
                  hint: "e.g. 2",
                  icon: Icons.shield_outlined,
                  keyboardType: TextInputType.number,
                  initialValue: c.getText("numberOfAirbags"),
                  onChanged: (v) => c.setString("numberOfAirbags", v),
                ),

                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "reverseCameraImages",
                  label: 'Reverse Camera Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "reverseCameraImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "reverseCameraImages",
                  ),
                  context: context,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "additionalInteriorImages",
                  label: 'Additional Interior Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "additionalInteriorImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "additionalInteriorImages",
                  ),
                  context: context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ✅ STEP 6: Mechanical / Test Drive
// =====================================================
class MechanicalTestDriveStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarInspectionStepperController c;

  const MechanicalTestDriveStep({
    super.key,
    required this.formKey,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Mechanical / Test Drive', Icons.drive_eta),
                const SizedBox(height: 14),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "commentsOnClusterMeter",
                  label: "Comments on Cluster Meter",
                  hint: "Cluster Meter",
                  icon: Icons.speed_outlined,
                  items: okIssue,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "fuelLevel",
                  label: "Fuel Level",
                  hint: "Fuel Level",
                  icon: Icons.local_gas_station_outlined,
                  items: const ["Full", "3/4", "1/2", "1/4", "Empty", "N/A"],
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "abs",
                  label: "ABS (Anti-lock Braking System)",
                  hint: "ABS",
                  icon: Icons.car_crash_outlined,
                  items: yesNo,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "steering",
                  label: "Steering",
                  hint: "Steering",
                  icon: Icons.directions_outlined,
                  items: workingNA,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "brakes",
                  label: "Brakes",
                  hint: "Brakes",
                  icon: Icons.car_crash_outlined,
                  items: workingNA,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "suspension",
                  label: "Suspension",
                  hint: "Suspension",
                  icon: Icons.settings_suggest_outlined,
                  items: workingNA,
                ),
                buildModernTextField(
                  label: 'Odometer Before Test Drive (KMs)',
                  hint: 'e.g. 52340',
                  icon: Icons.speed_outlined,
                  keyboardType: TextInputType.number,
                  initialValue: c.getText("odometerReadingBeforeTestDrive"),
                  onChanged: (v) {
                    c.setString("odometerReadingBeforeTestDrive", v);
                    c.setString("odometerReadingInKms", v);
                  },
                ),

                buildModernTextField(
                  label: 'Odometer After Test Drive (KMs)',
                  hint: 'e.g. 52345',
                  icon: Icons.speed_outlined,
                  keyboardType: TextInputType.number,
                  initialValue: c.getText("odometerReadingAfterTestDriveInKms"),
                  onChanged: (v) =>
                      c.setString("odometerReadingAfterTestDriveInKms", v),
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rearWiperWasher",
                  label: "Rear Wiper Washer",
                  hint: "Rear Wiper Washer",
                  icon: Icons.water_drop_outlined,
                  items: workingNA,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "rearDefogger",
                  label: "Rear Defogger",
                  hint: "Rear Defogger",
                  icon: Icons.deblur_outlined,
                  items: workingNA,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "frontWiperAndWasher",
                  label: "Front Wiper & Washer",
                  hint: "Front Wiper & Washer",
                  icon: Icons.water_drop_outlined,
                  items: workingNA,
                ),

                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "transmissionType",
                  label: "Transmission Type",
                  hint: "Transmission Type",
                  icon: Icons.settings_input_component_outlined,
                  items: transmissionOptions,
                ),
                buildModernSingleListDropdownKey(
                  context: context,
                  c: c,
                  keyName: "driveTrain",
                  label: "Drive Train",
                  hint: "Drive Train",
                  icon: Icons.alt_route_outlined,
                  items: driveTrainOptions,
                ),
                buildValidatedMultiImagePicker(
                  c: c,
                  fieldKey: "odometerReadingAfterTestDriveImages",
                  label: 'Odometer After Test Drive Images',
                  minRequired: MandatoryImagesConfig.getMinRequired(
                    "odometerReadingAfterTestDriveImages",
                  ),
                  maxImages: MandatoryImagesConfig.getMaxImages(
                    "odometerReadingAfterTestDriveImages",
                  ),
                  context: context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ✅ STEP 7: Final Details Step
// =====================================================
class FinalDetailsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarInspectionStepperController c;

  const FinalDetailsStep({super.key, required this.formKey, required this.c});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Final Approval', Icons.checklist),
                const SizedBox(height: 14),
                // buildModernTextField(
                //   label: 'Approved By',
                //   hint: 'Enter name',
                //   icon: Icons.verified_user,
                //   initialValue: c.getText("approvedBy"),
                //   onChanged: (v) => c.setString("approvedBy", v),
                // ),
                buildModernDatePicker(
                  context: context,
                  label: 'Approval Date',
                  hint: 'Select date',
                  icon: Icons.event,
                  value: c.getDate("approvalDate"),
                  onChanged: (d) => c.setDate("approvalDate", d),
                ),
                // buildModernTextField(
                //   label: 'Approval Status',
                //   hint: 'e.g. Approved / Rejected',
                //   icon: Icons.fact_check_outlined,
                //   initialValue: c.getText("approvalStatus"),
                //   onChanged: (v) => c.setString("approvalStatus", v),
                // ),
                // buildModernTextField(
                //   label: 'Status',
                //   hint: 'Enter status',
                //   icon: Icons.info_outline,
                //   initialValue: c.getText("status"),
                //   onChanged: (v) => c.setString("status", v),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class ReviewStep extends StatelessWidget {
//   final CarInspectionStepperController c;

//   const ReviewStep({super.key, required this.c});

//   String _pick(String key) => c.getText(key).trim();

//   Widget _kv(String k, String v) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 160,
//             child: Text(
//               k,
//               style: TextStyle(
//                 color: Colors.grey.shade700,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               v.isEmpty ? '-' : v,
//               style: const TextStyle(fontWeight: FontWeight.w800),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return buildModernCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           buildSectionHeader('Review Summary', Icons.preview),
//           const SizedBox(height: 14),

//           _kv('Appointment Id', _pick("appointmentId")),
//           _kv('Registration Number', _pick("registrationNumber")),
//           _kv('Make', _pick("make")),
//           _kv('Model', _pick("model")),
//           _kv('Variant', _pick("variant")),
//           _kv('Fuel Type', _pick("fuelType")),

//           const Divider(height: 26),

//           _kv('Inspection Engineer', _pick("ieName")),
//           _kv('Inspection City', _pick("inspectionCity")),
//           _kv('Contact Number', _pick("contactNumber")),

//           const Divider(height: 26),

//           _kv('RC Book Availability', _pick("rcBookAvailability")),
//           _kv('RC Condition', _pick("rcCondition")),
//           _kv('To Be Scrapped', _pick("toBeScrapped")),
//           _kv('Duplicate Key', _pick("duplicateKey")),
//           _kv('Mismatch In RC', _pick("mismatchInRc")),
//           _kv('Insurance', _pick("insurance")),
//           _kv('Hypothecation Details', _pick("hypothecationDetails")),
//           _kv('Road Tax Validity', _pick("roadTaxValidity")),
//           _kv('RTO NOC', _pick("rtoNoc")),
//           _kv('RTO Form 28', _pick("rtoForm28")),
//           _kv('Party Peshi', _pick("partyPeshi")),

//           const Divider(height: 26),

//           _kv('Bonnet', _pick("bonnet")),
//           _kv('Front Bumper', _pick("frontBumper")),
//           _kv('Front Windshield', _pick("frontWindshield")),
//           _kv('Roof', _pick("roof")),
//           _kv('Rear Bumper', _pick("rearBumper")),
//           _kv('Boot Door', _pick("bootDoor")),
//         ],
//       ),
//     );
//   }
// }

class ValidatedVideoPickerWidget extends StatelessWidget {
  final CarInspectionStepperController controller;
  final String fieldKey;
  final String label;
  final bool requiredVideo;
  final bool enabled;
  final int maxDurationInSeconds;
  final double? maxFileSizeMB;

  const ValidatedVideoPickerWidget({
    super.key,
    required this.controller,
    required this.fieldKey,
    required this.label,
    this.requiredVideo = false,
    this.enabled = true,
    this.maxDurationInSeconds = 15,
    this.maxFileSizeMB = 100,
  });

  @override
  Widget build(BuildContext context) {
    final localVideo = controller.getLocalVideo(fieldKey);
    final uploadedVideo = controller.getString(fieldKey, def: "");
    final isUploading = controller.isFieldUploading(fieldKey);
    final hasVideo = localVideo != null || uploadedVideo.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with duration info
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: requiredVideo && !hasVideo
                          ? Colors.red
                          : AppColor.textDark,
                    ),
                  ),
                  if (requiredVideo)
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Max: ${maxDurationInSeconds}s • Max size: ${maxFileSizeMB}MB',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),

        // Video Preview with Duration Info
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBorderColor(context, hasVideo, uploadedVideo),
              width: hasVideo ? 2 : 1,
            ),
            color: Colors.grey.shade50,
          ),
          child: _buildVideoPreview(
            context,
            localVideo,
            uploadedVideo,
            isUploading,
            hasVideo,
          ),
        ),

        const SizedBox(height: 12),

        // Action Buttons
        _buildActionButtons(context, localVideo, uploadedVideo, isUploading),

        // Status and Info
        if (hasVideo) _buildStatusInfo(localVideo, uploadedVideo),

        // Validation Error (if any)
        if (requiredVideo && !hasVideo)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Video is required',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Color _getBorderColor(
    BuildContext context,
    bool hasVideo,
    String uploadedVideo,
  ) {
    if (!hasVideo) return Colors.grey.shade300;
    if (uploadedVideo.isNotEmpty) return Colors.green;
    return Theme.of(context).primaryColor;
  }

  Widget _buildVideoPreview(
    BuildContext context,
    String? localVideo,
    String uploadedVideo,
    bool isUploading,
    bool hasVideo,
  ) {
    if (!hasVideo) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'No video selected',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Video thumbnail
        // Positioned.fill(
        //   child: VideoThumbnailTile(
        //     videoPath: localVideo!,
        //     enabled: true,
        //     onRemove: () {},
        //   ),
        // ),

        // Duration overlay
        if (localVideo != null)
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FutureBuilder<Duration>(
                future: _getVideoDuration(localVideo),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final duration = snapshot.data!;
                    return Text(
                      '${duration.inSeconds}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

        // Play button
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _playVideo(context, localVideo, uploadedVideo),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Remove button
        if (enabled && hasVideo)
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                controller.clearVideoData(fieldKey);
                if (requiredVideo) {
                  ToastWidget.show(
                    context: context,
                    title: "Video Removed",
                    subtitle: "Please select a new video",
                    type: ToastType.warning,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),

        // Upload progress
        if (isUploading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text('Uploading...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    String? localVideo,
    String uploadedVideo,
    bool isUploading,
  ) {
    return Row(
      children: [
        // Upload Button
        if (localVideo != null && !isUploading && uploadedVideo.isEmpty)
          Expanded(
            child: ElevatedButton(
              onPressed: enabled ? () => _handleUpload(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 20),
                  SizedBox(width: 8),
                  Text('Upload Video'),
                ],
              ),
            ),
          ),

        if (localVideo != null && !isUploading && uploadedVideo.isEmpty)
          const SizedBox(width: 10),

        // Select/Record Video Button
        Expanded(
          child: PopupMenuButton<VideoSource>(
            onSelected: (source) => _handleVideoSelection(context, source),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: VideoSource.gallery,
                child: Row(
                  children: [
                    Icon(Icons.video_library, color: kPrimary),
                    SizedBox(width: 8),
                    Text('Choose from Gallery'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: VideoSource.camera,
                child: Row(
                  children: [
                    Icon(Icons.videocam, color: kPrimary),
                    SizedBox(width: 8),
                    Text('Record Video'),
                  ],
                ),
              ),
            ],
            child: OutlinedButton(
              onPressed: enabled && !isUploading ? () {} : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: kPrimary),
                foregroundColor: kPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_settings, size: 20),
                  SizedBox(width: 8),
                  Text('Select Video'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo(String? localVideo, String uploadedVideo) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            uploadedVideo.isNotEmpty
                ? '✓ Video uploaded successfully'
                : '● Video selected (not uploaded yet)',
            style: TextStyle(
              color: uploadedVideo.isNotEmpty ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (localVideo != null)
            FutureBuilder<Duration>(
              future: _getVideoDuration(localVideo),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final duration = snapshot.data!;
                  return Text(
                    'Duration: ${duration.inSeconds} seconds',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }

  Future<Duration> _getVideoDuration(String path) async {
    try {
      final controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      final duration = controller.value.duration;
      await controller.dispose();
      return duration;
    } catch (e) {
      return Duration.zero;
    }
  }

  Future<void> _playVideo(
    BuildContext context,
    String? localVideo,
    String uploadedVideo,
  ) async {
    if (localVideo != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoPath: localVideo,
            title: label,
            isNetwork: false,
          ),
        ),
      );
    } else if (uploadedVideo.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoPath: uploadedVideo,
            title: label,
            isNetwork: true,
          ),
        ),
      );
    }
  }

  Future<void> _handleUpload(BuildContext context) async {
    final url = await controller.uploadVideoForField(fieldKey);

    if (url != null) {
      ToastWidget.show(
        context: context,
        title: "Success",
        subtitle: "Video uploaded to Cloudinary",
        type: ToastType.success,
      );
    }
  }

  Future<void> _handleVideoSelection(
    BuildContext context,
    VideoSource source,
  ) async {
    if (source == VideoSource.gallery) {
      await controller.pickVideoWithDurationCheck(
        context: context,
        fieldKey: fieldKey,
        maxDurationInSeconds: maxDurationInSeconds,
      );
    } else {
      await controller.recordVideoWithDurationLimit(
        context: context,
        fieldKey: fieldKey,
        maxDurationInSeconds: maxDurationInSeconds,
      );
    }
  }
}

// Supporting enums and classes
enum VideoSource { gallery, camera }

class VideoPlayerScreen extends StatelessWidget {
  final String videoPath;
  final String title;
  final bool isNetwork;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.title,
    this.isNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: isNetwork
            ? VideoPlayerWidget.network(videoPath)
            : VideoPlayerWidget.file(videoPath),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final bool isNetwork;

  const VideoPlayerWidget.network(String url, {super.key})
    : videoPath = url,
      isNetwork = true;

  const VideoPlayerWidget.file(String path, {super.key})
    : videoPath = path,
      isNetwork = false;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = widget.isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
        : VideoPlayerController.file(File(widget.videoPath));

    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: kPrimary,
        handleColor: kPrimary,
        backgroundColor: Colors.grey.shade300,
        bufferedColor: Colors.grey.shade500,
      ),
      placeholder: Container(color: Colors.black),
      autoInitialize: true,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Chewie(controller: _chewieController!);
  }
}
