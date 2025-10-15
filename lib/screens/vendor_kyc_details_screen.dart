import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../utils/page_transitions.dart';
import 'vendor_bank_details_screen.dart';

class VendorKycDetailsScreen extends StatefulWidget {
  const VendorKycDetailsScreen({super.key, required this.initial});

  final Map<String, dynamic> initial;

  @override
  State<VendorKycDetailsScreen> createState() => _VendorKycDetailsScreenState();
}

class _VendorKycDetailsScreenState extends State<VendorKycDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _aadharCtrl = TextEditingController();
  final TextEditingController _panCtrl = TextEditingController();
  final TextEditingController _gstCtrl = TextEditingController();

  Uint8List? _aadharBytes;
  String? _aadharFileName;
  Uint8List? _panBytes;
  String? _panFileName;
  Uint8List? _gstBytes;
  String? _gstFileName;

  @override
  void dispose() {
    _aadharCtrl.dispose();
    _panCtrl.dispose();
    _gstCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String type = (widget.initial['entityType'] as String? ?? 'company')
        .toLowerCase();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Vendor - KYC')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _stepHeader(context, currentStep: 1),
                const SizedBox(height: 12),
                Text(
                  'KYC Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (type != 'company')
                  _kycFieldWithUpload(
                    context,
                    label: 'Aadhaar',
                    controller: _aadharCtrl,
                    fileBytes: _aadharBytes,
                    fileName: _aadharFileName,
                    onUpload: () async {
                      final FilePickerResult? res = await FilePicker.platform
                          .pickFiles(withData: true);
                      if (res != null && res.files.isNotEmpty) {
                        setState(() {
                          _aadharBytes = res.files.single.bytes;
                          _aadharFileName = res.files.single.name;
                        });
                      }
                    },
                    onRemove: () => setState(() {
                      _aadharBytes = null;
                      _aadharFileName = null;
                    }),
                  ),
                const SizedBox(height: 12),
                _kycFieldWithUpload(
                  context,
                  label: 'PAN',
                  controller: _panCtrl,
                  fileBytes: _panBytes,
                  fileName: _panFileName,
                  onUpload: () async {
                    final FilePickerResult? res = await FilePicker.platform
                        .pickFiles(withData: true);
                    if (res != null && res.files.isNotEmpty) {
                      setState(() {
                        _panBytes = res.files.single.bytes;
                        _panFileName = res.files.single.name;
                      });
                    }
                  },
                  onRemove: () => setState(() {
                    _panBytes = null;
                    _panFileName = null;
                  }),
                ),
                const SizedBox(height: 12),
                if (type == 'company')
                  _kycFieldWithUpload(
                    context,
                    label: 'GSTIN',
                    controller: _gstCtrl,
                    fileBytes: _gstBytes,
                    fileName: _gstFileName,
                    onUpload: () async {
                      final FilePickerResult? res = await FilePicker.platform
                          .pickFiles(withData: true);
                      if (res != null && res.files.isNotEmpty) {
                        setState(() {
                          _gstBytes = res.files.single.bytes;
                          _gstFileName = res.files.single.name;
                        });
                      }
                    },
                    onRemove: () => setState(() {
                      _gstBytes = null;
                      _gstFileName = null;
                    }),
                  ),
                const Spacer(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _goNext,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goNext() async {
    final Map<String, dynamic> kyc = <String, dynamic>{
      ...widget.initial,
      'aadhar': _aadharCtrl.text,
      'panCard': _panCtrl.text,
      'gstin': _gstCtrl.text,
    };

    final Map<String, dynamic>? result = await Navigator.of(context).push(
      SmoothPageTransitions.slideFromRight<Map<String, dynamic>>(
        child: VendorBankDetailsScreen(initial: kyc),
      ),
    );

    if (result != null) {
      Navigator.pop(context, result);
    }
  }

  Widget _stepHeader(BuildContext context, {required int currentStep}) {
    final List<String> labels = <String>['Basic', 'KYC', 'Bank', 'Service'];
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: List<Widget>.generate(labels.length, (int index) {
            final bool selected = index == currentStep;
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: EdgeInsets.only(
                  right: index < labels.length - 1 ? 8 : 0,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withOpacity(0.10)
                      : _panelColor(context),
                  border: Border.all(color: _panelBorderColor(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: selected ? primary : onSurface,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (currentStep + 1) / labels.length,
          minHeight: 6,
          backgroundColor: _panelColor(context),
        ),
      ],
    );
  }

  Widget _formField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Enter $label',
            filled: true,
            fillColor: _panelColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _panelBorderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _panelBorderColor(context)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _kycFieldWithUpload(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required Uint8List? fileBytes,
    required String? fileName,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _formField(context, label: label, controller: controller),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('Upload'),
            ),
            const SizedBox(width: 8),
            if (fileBytes != null)
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove'),
              ),
          ],
        ),
        if (fileBytes != null) ...<Widget>[
          const SizedBox(height: 8),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _panelColor(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _panelBorderColor(context)),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildFilePreview(context, fileBytes, fileName),
          ),
        ],
      ],
    );
  }

  Widget _buildFilePreview(
    BuildContext context,
    Uint8List? bytes,
    String? fileName,
  ) {
    if (bytes == null) {
      return const SizedBox.shrink();
    }
    final String nameLower = (fileName ?? '').toLowerCase();
    final bool isImage =
        nameLower.endsWith('.png') ||
        nameLower.endsWith('.jpg') ||
        nameLower.endsWith('.jpeg') ||
        nameLower.endsWith('.webp') ||
        nameLower.endsWith('.gif');
    if (isImage) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.insert_drive_file_outlined,
            color: Theme.of(context).iconTheme.color,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName ?? 'File attached',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // URL input dialog removed; using FilePicker instead
}

Color _panelColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? Colors.white.withOpacity(0.06)
      : Colors.black.withOpacity(0.04);
}

Color _panelBorderColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.white.withOpacity(0.12) : const Color(0x22000000);
}
