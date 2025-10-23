import 'package:flutter/material.dart';
import 'package:tigger/data/models/site_visit_model.dart';
import 'package:tigger/data/models/meeting_status_model.dart';
import 'package:tigger/data/services/site_visit_service.dart';

class SiteVisitDetailScreen extends StatefulWidget {
  final String siteVisitId;
  final Map<String, dynamic> siteVisitData;

  const SiteVisitDetailScreen({
    super.key,
    required this.siteVisitId,
    required this.siteVisitData,
  });

  @override
  State<SiteVisitDetailScreen> createState() => _SiteVisitDetailScreenState();
}

class _SiteVisitDetailScreenState extends State<SiteVisitDetailScreen>
    with TickerProviderStateMixin {
  bool _isDetailsView =
      true; // true for site visit details, false for visit history
  String _selectedMeetingStatus = 'Scheduled'; // Current meeting status
  bool _isLoading = false;
  bool _isUpdatingStatus = false;
  bool _isLoadingTimeline = false;
  bool _isLoadingStatusOptions = false;
  SiteVisit? _siteVisit;
  List<Map<String, dynamic>> _timelineData = [];
  List<MeetingStatusOption> _meetingStatusOptions = [];
  late SiteVisitService _siteVisitService;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _siteVisitService = SiteVisitService();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();

    // Initialize with default status options first
    _meetingStatusOptions = _getDefaultStatusOptions();
    _initializeMeetingStatus();

    // Fetch latest site visit data from backend
    _fetchSiteVisitData();

    // Fetch timeline data
    _fetchTimelineData();

    // Fetch meeting status options from backend
    _fetchMeetingStatusOptions();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeMeetingStatus() {
    // Initialize meeting status from the passed site visit data
    final status = widget.siteVisitData['status'] as String?;
    if (status != null) {
      _selectedMeetingStatus = _getDisplayStatus(status);
    } else if (_meetingStatusOptions.isNotEmpty) {
      // Use default status if no status is provided
      final defaultOption = _meetingStatusOptions.firstWhere(
        (opt) => opt.isDefault,
        orElse: () => _meetingStatusOptions.first,
      );
      _selectedMeetingStatus = defaultOption.displayName;
    }
  }

  String _getDisplayStatus(String status) {
    // Find the option by name and return its display name
    final option = _meetingStatusOptions.firstWhere(
      (opt) => opt.name.toLowerCase() == status.toLowerCase(),
      orElse: () => _meetingStatusOptions.firstWhere(
        (opt) => opt.isDefault,
        orElse: () => _meetingStatusOptions.first,
      ),
    );
    return option.displayName;
  }

  String _getApiStatus(String displayStatus) {
    // Find the option by display name and return its name (API value)
    final option = _meetingStatusOptions.firstWhere(
      (opt) => opt.displayName == displayStatus,
      orElse: () => _meetingStatusOptions.firstWhere(
        (opt) => opt.isDefault,
        orElse: () => _meetingStatusOptions.first,
      ),
    );
    return option.name;
  }

  Future<void> _fetchSiteVisitData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await _siteVisitService.getSiteVisit(widget.siteVisitId);
      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _siteVisit = response.data;
            _selectedMeetingStatus = _getDisplayStatus(
              _siteVisit!.status.toString().split('.').last,
            );
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        _showErrorSnackBar(
          response.message ?? 'Failed to fetch site visit data',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _showErrorSnackBar('Error fetching site visit data: $e');
    }
  }

  Future<void> _fetchTimelineData() async {
    if (mounted) {
      setState(() {
        _isLoadingTimeline = true;
      });
    }

    try {
      final response = await _siteVisitService.getSiteVisitTimeline(
        widget.siteVisitId,
      );
      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _timelineData = response.data!;
            _isLoadingTimeline = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingTimeline = false;
          });
        }
        // If timeline fetch fails, use empty list instead of showing error
        // as timeline is not critical for the main functionality
        if (mounted) {
          setState(() {
            _timelineData = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTimeline = false;
          _timelineData = [];
        });
      }
    }
  }

  Future<void> _fetchMeetingStatusOptions() async {
    if (mounted) {
      setState(() {
        _isLoadingStatusOptions = true;
      });
    }

    try {
      final response = await _siteVisitService.getMeetingStatusOptions();
      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _meetingStatusOptions = response.data!;
            _isLoadingStatusOptions = false;
          });
          // Reinitialize meeting status with new options
          _initializeMeetingStatus();
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingStatusOptions = false;
          });
        }
        // If status options fetch fails, use default hardcoded values as fallback
        if (mounted) {
          setState(() {
            _meetingStatusOptions = _getDefaultStatusOptions();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStatusOptions = false;
          _meetingStatusOptions = _getDefaultStatusOptions();
        });
      }
    }
  }

  List<MeetingStatusOption> _getDefaultStatusOptions() {
    return [
      MeetingStatusOption(
        id: '1',
        name: 'scheduled',
        displayName: 'Scheduled',
        description: 'Meeting is scheduled and pending',
        colorCode: '#2196F3',
        iconName: 'schedule',
        sortOrder: 1,
        isActive: true,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MeetingStatusOption(
        id: '2',
        name: 'completed',
        displayName: 'Completed',
        description: 'Meeting has been completed successfully',
        colorCode: '#4CAF50',
        iconName: 'check_circle',
        sortOrder: 2,
        isActive: true,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MeetingStatusOption(
        id: '3',
        name: 'cancelled',
        displayName: 'Cancelled',
        description: 'Meeting has been cancelled',
        colorCode: '#F44336',
        iconName: 'cancel',
        sortOrder: 3,
        isActive: true,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MeetingStatusOption(
        id: '4',
        name: 'rescheduled',
        displayName: 'Rescheduled',
        description: 'Meeting has been rescheduled to a different time',
        colorCode: '#FF9800',
        iconName: 'update',
        sortOrder: 4,
        isActive: true,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Future<void> _updateMeetingStatus(String newStatus) async {
    if (mounted) {
      setState(() {
        _isUpdatingStatus = true;
      });
    }

    try {
      final apiStatus = _getApiStatus(newStatus);
      final statusEnum = SiteVisitStatus.values.firstWhere(
        (e) => e.toString().split('.').last == apiStatus,
        orElse: () => SiteVisitStatus.scheduled,
      );

      final response = await _siteVisitService.updateSiteVisitStatus(
        widget.siteVisitId,
        statusEnum,
        'Status updated via mobile app',
      );

      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _siteVisit = response.data;
            _selectedMeetingStatus = newStatus;
            _isUpdatingStatus = false;
          });
        }

        // Refresh timeline data after status update
        await _fetchTimelineData();

        // Refresh site visit data to get latest info
        await _fetchSiteVisitData();

        _showSuccessSnackBar('Meeting status updated to: $newStatus');
      } else {
        if (mounted) {
          setState(() {
            _isUpdatingStatus = false;
          });
        }
        _showErrorSnackBar(
          response.message ?? 'Failed to update meeting status',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
      _showErrorSnackBar('Error updating meeting status: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Site Visit Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Information Card
                      _buildHeaderCard(),

                      // Toggle Buttons
                      _buildToggleButtons(),

                      // Content based on toggle
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                        child: _isDetailsView
                            ? _buildSiteVisitDetails()
                            : _buildVisitHistory(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top row with customer name and meeting status button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _siteVisit?.customerName ??
                            widget.siteVisitData['customerName'] ??
                            'Unknown Customer',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lead Id : ${_siteVisit?.leadId ?? widget.siteVisitData['leadId'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        'Contact : ${_siteVisit?.customerPhone ?? widget.siteVisitData['customerPhone'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isUpdatingStatus
                      ? null
                      : () => _showMeetingStatusDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isUpdatingStatus
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(_selectedMeetingStatus),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Key details in clean format
            _buildCleanDetailRow(
              'Project:',
              _siteVisit?.projectName ??
                  widget.siteVisitData['projectName'] ??
                  'N/A',
            ),
            _buildCleanDetailRow(
              'Visit Mode:',
              _siteVisit?.visitMode.toString().split('.').last ??
                  widget.siteVisitData['visitMode'] ??
                  'N/A',
            ),
            _buildCleanDetailRow(
              'Status:',
              _siteVisit?.status.toString().split('.').last ??
                  widget.siteVisitData['status'] ??
                  'N/A',
            ),
            _buildCleanDetailRow(
              'Telecaller:',
              _siteVisit?.telecallerName ??
                  widget.siteVisitData['telecallerName'] ??
                  'N/A',
            ),
            _buildCleanDetailRow(
              'Assigned At:',
              _formatDateTime(widget.siteVisitData['allocatedAt']),
            ),
            _buildCleanDetailRow(
              'Assigned By:',
              widget.siteVisitData['allocatedBy'] ?? 'N/A',
            ),
            _buildCleanDetailRow(
              'Source:',
              widget.siteVisitData['source'] ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      final String day = dateTime.day.toString().padLeft(2, '0');
      final String month = _getMonthName(dateTime.month);
      final String year = dateTime.year.toString();
      final String minute = dateTime.minute.toString().padLeft(2, '0');
      final String ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
      final int displayHour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      return '$day-$month-$year | $displayHour:$minute $ampm';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getMonthName(int month) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _calculateMeetingDuration() {
    final DateTime? from =
        _siteVisit?.meetingFrom ??
        (widget.siteVisitData['meetingFrom'] != null
            ? DateTime.tryParse(widget.siteVisitData['meetingFrom'])
            : null);
    final DateTime? to =
        _siteVisit?.meetingTo ??
        (widget.siteVisitData['meetingTo'] != null
            ? DateTime.tryParse(widget.siteVisitData['meetingTo'])
            : null);

    if (from == null || to == null) return 'N/A';

    try {
      final Duration duration = to.difference(from);

      final int hours = duration.inHours;
      final int minutes = duration.inMinutes % 60;

      if (hours > 0) {
        return '${hours.toString().padLeft(2, '0')} Hours ${minutes.toString().padLeft(2, '0')} Minutes';
      } else {
        return '${minutes.toString().padLeft(2, '0')} Minutes';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildToggleButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isDetailsView = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isDetailsView
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  'Site-Visit Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isDetailsView ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isDetailsView = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isDetailsView
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  'Visit History',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isDetailsView ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteVisitDetails() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Site Visit Details header with Reschedule button
          Row(
            children: [
              Text(
                'Site Visit Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Meeting time details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCleanDetailRow(
                  'From:',
                  _formatDateTime(
                    _siteVisit?.meetingFrom?.toIso8601String() ??
                        widget.siteVisitData['meetingFrom'],
                  ),
                ),
                _buildCleanDetailRow(
                  'To:',
                  _formatDateTime(
                    _siteVisit?.meetingTo?.toIso8601String() ??
                        widget.siteVisitData['meetingTo'],
                  ),
                ),
                _buildCleanDetailRow(
                  'Total Meeting Time:',
                  _calculateMeetingDuration(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Other Details section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Other Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCleanDetailRow(
                  'Purpose Of Meeting:',
                  _siteVisit?.purpose ??
                      widget.siteVisitData['purpose'] ??
                      'N/A',
                ),
                _buildCleanDetailRow(
                  'Address:',
                  _siteVisit?.address ??
                      widget.siteVisitData['address'] ??
                      'N/A',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitHistory() {
    // Use real timeline data from backend, fallback to empty list if loading or no data
    final List<Map<String, dynamic>> visitHistory = _timelineData.isNotEmpty
        ? _timelineData
        : [];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Timeline Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Visit Timeline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (_isLoadingTimeline)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    '${visitHistory.length} entries',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Timeline Cards or Empty State
          if (visitHistory.isEmpty && !_isLoadingTimeline)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.timeline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No timeline data available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Timeline will appear here as activities are recorded',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...visitHistory.asMap().entries.map((entry) {
              final index = entry.key;
              final visit = entry.value;
              return _buildHistoryCard(visit, index, visitHistory.length);
            }),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> visit, int index, int total) {
    final isLast = index == total - 1;
    final status = visit['status'] ?? visit['action'] ?? 'Unknown';
    final statusColor = _getStatusColor(status);

    // Parse date from various possible formats
    DateTime? date;
    if (visit['createdAt'] != null) {
      try {
        date = DateTime.parse(visit['createdAt']);
      } catch (e) {
        // Try alternative date fields
        if (visit['date'] != null) {
          try {
            date = DateTime.parse(visit['date']);
          } catch (e) {
            date = DateTime.now();
          }
        } else {
          date = DateTime.now();
        }
      }
    } else if (visit['date'] != null) {
      try {
        date = DateTime.parse(visit['date']);
      } catch (e) {
        date = DateTime.now();
      }
    } else {
      date = DateTime.now();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Timeline line
          Positioned(
            left: 20,
            top: 0,
            bottom: isLast ? 20 : 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          // Timeline dot
          Positioned(
            left: 14,
            top: 20,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Date
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  visit['description'] ??
                      visit['message'] ??
                      visit['notes'] ??
                      'Activity recorded',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                // Details Row
                Row(
                  children: [
                    if (visit['duration'] != null)
                      _buildHistoryDetail(
                        Icons.access_time,
                        visit['duration'],
                        Colors.blue,
                      ),
                    if (visit['duration'] != null && visit['attender'] != null)
                      const SizedBox(width: 16),
                    if (visit['attender'] != null || visit['userName'] != null)
                      _buildHistoryDetail(
                        Icons.person,
                        visit['attender'] ?? visit['userName'] ?? 'Unknown',
                        Colors.green,
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Notes
                if (visit['notes'] != null &&
                    visit['notes'] != visit['description']) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            visit['notes'],
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDetail(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'scheduled':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'follow-up':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'schedule':
        return Icons.schedule;
      case 'check_circle':
        return Icons.check_circle;
      case 'cancel':
        return Icons.cancel;
      case 'update':
        return Icons.update;
      case 'play_circle':
        return Icons.play_circle;
      case 'person_off':
        return Icons.person_off;
      case 'pause_circle':
        return Icons.pause_circle;
      default:
        return Icons.info;
    }
  }

  void _showMeetingStatusDialog(BuildContext context) {
    String tempSelectedStatus = _selectedMeetingStatus;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              title: const Text(
                'Meeting Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select the current meeting status:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingStatusOptions)
                    const Center(child: CircularProgressIndicator())
                  else
                    DropdownButtonFormField<String>(
                      value: tempSelectedStatus,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _meetingStatusOptions
                          .where((option) => option.isActive)
                          .map(
                            (option) => DropdownMenuItem(
                              value: option.displayName,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (option.iconName != null) ...[
                                    Icon(
                                      _getIconData(option.iconName!),
                                      size: 16,
                                      color: option.colorCode != null
                                          ? Color(
                                              int.parse(
                                                    option.colorCode!.substring(
                                                      1,
                                                    ),
                                                    radix: 16,
                                                  ) +
                                                  0xFF000000,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Flexible(child: Text(option.displayName)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            tempSelectedStatus = newValue;
                          });
                        }
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isUpdatingStatus
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: _isUpdatingStatus
                      ? null
                      : () async {
                          if (tempSelectedStatus != _selectedMeetingStatus) {
                            Navigator.of(context).pop();
                            await _updateMeetingStatus(tempSelectedStatus);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                  child: _isUpdatingStatus
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Update Status'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
