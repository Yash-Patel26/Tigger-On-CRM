import 'package:flutter/material.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({
    super.key,
    required this.vendorId,
    required this.name,
    required this.contactNumber,
    required this.email,
    required this.type,
    required this.commenceDate,
    required this.country,
    required this.state,
    required this.city,
    required this.aadhar,
    required this.address,
    required this.pincode,
    required this.companyName,
    required this.contactName,
    required this.panCard,
    required this.orgContactNumber,
    required this.gstin,
    required this.contactEmail,
    required this.designation,
    required this.services,
    required this.bankCategory,
    required this.bankName,
    required this.accountType,
    required this.ifscCode,
    required this.branchName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.isActive,
  });

  final String vendorId;
  final String name;
  final String contactNumber;
  final String email;
  final String type;
  final String commenceDate;
  final String country;
  final String state;
  final String city;
  final String aadhar;
  final String address;
  final String pincode;
  final String companyName;
  final String contactName;
  final String panCard;
  final String orgContactNumber;
  final String gstin;
  final String contactEmail;
  final String designation;
  final List<String> services;
  final String bankCategory;
  final String bankName;
  final String accountType;
  final String ifscCode;
  final String branchName;
  final String accountHolderName;
  final String accountNumber;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Header(
              name: name,
              contactNumber: contactNumber,
              email: email,
              type: type,
              commenceDate: commenceDate,
              isActive: isActive,
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Basic Details',
              children: <Widget>[
                _KeyValue('Country', country),
                _KeyValue('State', state),
                _KeyValue('City', city),
                _KeyValue('Aadhar Card Number', aadhar),
                _KeyValue('Address', address),
                _KeyValue('Pincode', pincode),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Organization Details',
              children: <Widget>[
                _KeyValue('Company Name', companyName),
                _KeyValue('Contact Name', contactName),
                _KeyValue('PAN Card', panCard),
                _KeyValue('Contact Number', orgContactNumber),
                _KeyValue('GSTIN', gstin),
                _KeyValue('Contact Email', contactEmail),
                _KeyValue('Designation', designation),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Service Details',
              children: <Widget>[
                _TableHeader(const <String>['Sr. No', 'Service Name']),
                for (int i = 0; i < services.length; i++)
                  _TableRow(<String>['${i + 1}', services[i]]),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Bank Details',
              children: <Widget>[
                _KeyValue('Category', bankCategory),
                _KeyValue('Bank Name', bankName),
                _KeyValue('Account Type', accountType),
                _KeyValue('IFSC Code', ifscCode),
                _KeyValue('Branch Name', branchName),
                _KeyValue('Account Holder Name', accountHolderName),
                _KeyValue('Account Number', accountNumber),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.contactNumber,
    required this.email,
    required this.type,
    required this.commenceDate,
    required this.isActive,
  });

  final String name;
  final String contactNumber;
  final String email;
  final String type;
  final String commenceDate;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 28,
            child: Text(name.isNotEmpty ? name[0] : '?'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _ProfileStatusChip(isActive: isActive),
                  ],
                ),
                const SizedBox(height: 6),
                _Inline(icon: Icons.phone_outlined, text: contactNumber),
                _Inline(icon: Icons.alternate_email, text: email),
                _Inline(icon: Icons.category_outlined, text: type),
                _Inline(
                  icon: Icons.event_outlined,
                  text: 'Commenced: $commenceDate',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.keyText, this.valueText);

  final String keyText;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 170,
            child: Text(keyText, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valueText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.columns);

  final List<String> columns;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < columns.length; i++)
            Expanded(
              flex: i == 0 ? 1 : 3,
              child: Text(columns[i], style: style),
            ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow(this.cells);

  final List<String> cells;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _panelBorderColor(context))),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < cells.length; i++)
            Expanded(
              flex: i == 0 ? 1 : 3,
              child: Text(
                cells[i],
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _Inline extends StatelessWidget {
  const _Inline({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: Theme.of(context).iconTheme.color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: child,
    );
  }
}

class _ProfileStatusChip extends StatelessWidget {
  const _ProfileStatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? Colors.green : Colors.redAccent;
    final String label = isActive ? 'Active' : 'Inactive';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }
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
