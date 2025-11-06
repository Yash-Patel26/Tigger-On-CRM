import 'package:flutter/material.dart';
import '../../../data/services/database_service_masters.dart' as masters;

class MainDispositionField extends StatefulWidget {
  const MainDispositionField({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelText = 'Main Disposition',
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String labelText;

  @override
  State<MainDispositionField> createState() => _MainDispositionFieldState();
}

class _MainDispositionFieldState extends State<MainDispositionField> {
  late Future<List<Map<String, dynamic>>> _mainsFuture;

  @override
  void initState() {
    super.initState();
    _mainsFuture = masters.DatabaseServiceMasters.getLeadStatuses();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _mainsFuture,
      builder:
          (BuildContext _, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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
                hintText: 'Select main disposition',
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
