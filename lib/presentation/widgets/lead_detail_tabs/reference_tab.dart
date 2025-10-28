import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/models/models.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../presentation/screens/leads/lead_detail_screen.dart';

/// Reference Tab Widget
///
/// This widget is extracted from lead_detail_screen.dart to improve code organization.
/// It displays and manages references (referrals to and by the lead).
class ReferenceTab extends StatefulWidget {
  const ReferenceTab({super.key, required this.leadId});

  final String leadId;

  @override
  State<ReferenceTab> createState() => _ReferenceTabState();
}

class _ReferenceTabState extends State<ReferenceTab> {
  late Future<List<Map<String, dynamic>>> _refsFutureTo;
  late Future<List<Map<String, dynamic>>> _refsFutureBy;

  @override
  void initState() {
    super.initState();
    _loadReferences();
  }

  void _loadReferences() {
    setState(() {
      _refsFutureTo = DatabaseService.getLeadReferences(
        leadId: widget.leadId,
        direction: 'to',
      );
      _refsFutureBy = DatabaseService.getLeadReferences(
        leadId: widget.leadId,
        direction: 'by',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openAddRefSheet,
                icon: const Icon(FontAwesomeIcons.plus),
                label: const Text('Create Reference'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Referred To Details',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _referredToCard(context),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.withOpacity(0.2)),
            const SizedBox(height: 12),
            Text(
              'Referred By Details',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _referredByCard(context),
          ],
        ),
      ),
    );
  }

  Widget _refCard(
    BuildContext context,
    Map<String, String> r,
    String nameLabel,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _kvSmall(
                  context,
                  nameLabel,
                  // Accept both snake_case (DB) and camelCase (UI) keys
                  '${r['first_name'] ?? r['firstName'] ?? ''} '
                          '${r['middle_name'] ?? r['middleName'] ?? ''} '
                          '${r['last_name'] ?? r['lastName'] ?? ''}'
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .trim(),
                  isLink: true,
                  onTap: () {
                    // Linked lead id can be snake_case
                    final String? leadId = r['linked_lead_id'] ?? r['leadId'];
                    if (leadId == null || leadId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lead not linked to this reference'),
                        ),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext ctx) =>
                            LeadDetailScreen(leadId: leadId),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _kvSmall(
                  context,
                  'Contact',
                  (r['contact'] ?? r['phone'] ?? '').trim(),
                ),
                const SizedBox(height: 8),
                _kvSmall(context, 'Email', (r['email'] ?? '').trim()),
                const SizedBox(height: 8),
                if ((r['note'] ?? '').trim().isNotEmpty)
                  _kvSmall(context, 'Note', (r['note'] ?? '').trim()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _referredToCard(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _refsFutureTo,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(child: Text('Failed to load')),
              );
            }
            final List<Map<String, dynamic>> items =
                snapshot.data ?? <Map<String, dynamic>>[];
            if (items.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(child: Text("Didn't Refer To Anyone")),
              );
            }
            return Column(
              children: items
                  .map(
                    (Map<String, dynamic> r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _refCard(
                        context,
                        r.map((k, v) => MapEntry(k, v?.toString() ?? '')),
                        'Referred To Name',
                      ),
                    ),
                  )
                  .toList(),
            );
          },
    );
  }

  Widget _referredByCard(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _refsFutureBy,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(child: Text('Failed to load')),
              );
            }
            final items = snapshot.data ?? <Map<String, dynamic>>[];
            if (items.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(child: Text("Didn't Refer By Anyone")),
              );
            }
            return Column(
              children: items
                  .map(
                    (Map<String, dynamic> r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _refCard(
                        context,
                        r.map((k, v) => MapEntry(k, v?.toString() ?? '')),
                        'Referred By Name',
                      ),
                    ),
                  )
                  .toList(),
            );
          },
    );
  }

  Widget _kvSmall(
    BuildContext context,
    String keyLabel,
    String value, {
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          keyLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        isLink
            ? InkWell(
                onTap: onTap,
                child: Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            : Text(
                value.isEmpty ? '-' : value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
      ],
    );
  }

  void _openAddRefSheet() {
    final TextEditingController fCtrl = TextEditingController();
    final TextEditingController mCtrl = TextEditingController();
    final TextEditingController lCtrl = TextEditingController();
    final TextEditingController cCtrl = TextEditingController();
    final TextEditingController eCtrl = TextEditingController();
    final TextEditingController noteCtrl = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Create Reference',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(FontAwesomeIcons.xmark),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Reference First Name *',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: fCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Reference First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? v) => (v == null || v.trim().isEmpty)
                      ? 'First name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Reference Middle Name',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: mCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Reference Middle Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Reference Last Name',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: lCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Reference Last Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Reference Contact *',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: cCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Reference Contact',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? v) => (v == null || v.trim().isEmpty)
                      ? 'Contact is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Reference Email *',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: eCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Reference Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    final bool ok = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(v.trim());
                    return ok ? null : 'Enter a valid email';
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Reference Requirement Note',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: noteCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Reference Requirement Note',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      try {
                        // Auto-create a linked lead from the reference details
                        final String customerName = <String>[
                          fCtrl.text.trim(),
                          mCtrl.text.trim(),
                          lCtrl.text.trim(),
                        ].where((String s) => s.isNotEmpty).join(' ');
                        final Lead linkedLead =
                            await DatabaseService.createLeadMinimal(
                              customerName: customerName.isEmpty
                                  ? 'New Referral'
                                  : customerName,
                              email: eCtrl.text.trim(),
                              phone: cCtrl.text.trim(),
                              source: LeadSource.referral,
                            );

                        // Create the reference with linked_lead_id set
                        await DatabaseService.createLeadReference(
                          leadId: widget.leadId,
                          direction: 'to',
                          firstName: fCtrl.text.trim(),
                          middleName: mCtrl.text.trim().isEmpty
                              ? null
                              : mCtrl.text.trim(),
                          lastName: lCtrl.text.trim(),
                          contact: cCtrl.text.trim(),
                          email: eCtrl.text.trim(),
                          note: noteCtrl.text.trim(),
                          linkedLeadId: linkedLead.id,
                        );
                        if (!mounted) return;
                        _loadReferences();
                        Navigator.of(ctx).pop();
                        await Helpers.showSuccessDialog(
                          context,
                          title: 'Reference created successfully',
                          message: 'A new lead has been linked.',
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to create: $e')),
                        );
                      }
                    },
                    child: const Text('Create'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
