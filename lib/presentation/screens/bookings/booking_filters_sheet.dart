import 'package:flutter/material.dart';

class BookingFiltersSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final VoidCallback onClear;

  const BookingFiltersSheet({
    super.key,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<BookingFiltersSheet> createState() => _BookingFiltersSheetState();
}

class _BookingFiltersSheetState extends State<BookingFiltersSheet> {
  final _customerNameController = TextEditingController();
  String _selectedPropertyType = '';
  String _selectedCategoryType = '';
  String _selectedApprovedBy = '';
  String _selectedProject = '';
  String _selectedAging = '';
  DateTime? _selectedLastUpdatedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Filter Bookings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Filters
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Name
                  _buildFilterField(
                    'Customer Name',
                    _customerNameController,
                    Icons.person,
                  ),

                  // Property Type
                  _buildDropdownField(
                    'Property Type',
                    _selectedPropertyType,
                    [
                      '2 BHK Apartment',
                      '1 BHK Apartment',
                      '3 BHK Apartment',
                      'Villa',
                      'Plot',
                    ],
                    (value) =>
                        setState(() => _selectedPropertyType = value ?? ''),
                    Icons.home,
                  ),

                  // Category Type
                  _buildDropdownField(
                    'Category Type',
                    _selectedCategoryType,
                    ['Residential', 'Commercial', 'Industrial'],
                    (value) =>
                        setState(() => _selectedCategoryType = value ?? ''),
                    Icons.category,
                  ),

                  // Approved By
                  _buildDropdownField(
                    'Approved By',
                    _selectedApprovedBy,
                    ['Manager Name', 'Senior Manager', 'Director'],
                    (value) =>
                        setState(() => _selectedApprovedBy = value ?? ''),
                    Icons.admin_panel_settings,
                  ),

                  // Project
                  _buildDropdownField(
                    'Project',
                    _selectedProject,
                    ['Project Alpha', 'Project Beta', 'Project Gamma'],
                    (value) => setState(() => _selectedProject = value ?? ''),
                    Icons.business,
                  ),

                  // Select Aging
                  _buildDropdownField(
                    'Select Aging',
                    _selectedAging,
                    ['0-30 days', '31-60 days', '61-90 days', '90+ days'],
                    (value) => setState(() => _selectedAging = value ?? ''),
                    Icons.schedule,
                  ),

                  // Last Updated Date
                  _buildDateField(
                    'Last Updated Date',
                    _selectedLastUpdatedDate,
                    (date) => setState(() => _selectedLastUpdatedDate = date),
                    Icons.calendar_today,
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      widget.onApply({
                        'customerName': _customerNameController.text,
                        'propertyType': _selectedPropertyType,
                        'categoryType': _selectedCategoryType,
                        'approvedBy': _selectedApprovedBy,
                        'project': _selectedProject,
                        'aging': _selectedAging,
                        'lastUpdatedDate': _selectedLastUpdatedDate,
                      });
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              prefixIcon: Icon(icon, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value.isEmpty ? null : value,
            decoration: InputDecoration(
              hintText: 'Select $label',
              prefixIcon: Icon(icon, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? value,
    Function(DateTime?) onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              onChanged(date);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Text(
                    value != null
                        ? '${value.day}/${value.month}/${value.year}'
                        : 'Select $label',
                    style: TextStyle(
                      color: value != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }
}
