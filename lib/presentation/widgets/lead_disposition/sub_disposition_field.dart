import 'package:flutter/material.dart';
import '../../../data/services/database_service_masters.dart' as masters;

class SubDispositionField extends StatefulWidget {
  const SubDispositionField({
    super.key,
    required this.mainDispositionId,
    required this.value,
    required this.onChanged,
    this.labelText = 'Sub Disposition',
  });

  final String? mainDispositionId;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String labelText;

  @override
  State<SubDispositionField> createState() => _SubDispositionFieldState();
}

class _SubDispositionFieldState extends State<SubDispositionField> {
  Future<List<Map<String, dynamic>>>? _subsFuture;

  @override
  void didUpdateWidget(covariant SubDispositionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mainDispositionId != widget.mainDispositionId) {
      _refresh();
    }
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    if (widget.mainDispositionId == null || widget.mainDispositionId!.isEmpty) {
      _subsFuture = Future<List<Map<String, dynamic>>>.value(
        <Map<String, dynamic>>[],
      );
    } else {
      _subsFuture = masters.DatabaseServiceMasters.getLeadSubStatuses(
        widget.mainDispositionId!,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _subsFuture,
      builder:
          (BuildContext _, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }
            if (snap.hasError) return const Text('Failed to load');
            final List<Map<String, dynamic>> items =
                snap.data ?? <Map<String, dynamic>>[];
            return DropdownButtonFormField<String>(
              isExpanded: true,
              value: widget.value,
              items: items
                  .map(
                    (Map<String, dynamic> s) => DropdownMenuItem<String>(
                      value: (s['id'] ?? '') as String,
                      child: Text(_capitalize((s['name'] ?? '-') as String)),
                    ),
                  )
                  .toList(),
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: 'Select sub disposition',
                border: const OutlineInputBorder(),
              ),
              validator: (String? v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            );
          },
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
