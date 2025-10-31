import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../shared/managers/notification_store.dart';
import '../../../../data/models/models.dart';
import '../../../../data/models/app_notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../presentation/pages/widgets/animated_glowing_logo.dart';
import '../ticket_hub_screen.dart';
import '../leads/lead_follow_up_screen.dart';
import '../vendors/vendor_screen.dart';
import '../profile/profile_screen.dart';
import '../../../../core/utils/page_transitions.dart';
import 'dashboard_screen.dart';
import '../notifications/notification_screen.dart';
import '../leads/lead_screen.dart';
import '../projects/site_visit_screen.dart';
import '../bookings/booking_screen.dart';
import '../property_finder_screen.dart';
import '../projects/active_projects_screen.dart';
import '../active_tasks_screen.dart';
import 'call_stats_detail_screen.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../../data/services/database_service.dart';
import '../../../../shared/utils/role_aware_data.dart';

Color panelColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.black.withValues(alpha: 0.04);
}

Color panelBorderColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? Colors.white.withValues(alpha: 0.12)
      : const Color(0x22000000);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // screen index: 0=Home,1=Customers,2=Vendor,3=Leads
  final String _profileImageUrl =
      'https://via.placeholder.com/150/6366f1/ffffff?text=User';
  final TextEditingController _homeSearchController = TextEditingController();

  // Session/user summary values
  final DateTime _loginTime = DateTime.now();

  // Real data from database
  int _leadsCount = 0;
  int _meetingsToday = 0;
  int _activeProjectsCount = 0;
  int _activeTasksCount = 0;
  int _teamMembersCount = 0;
  bool _isLoadingStats = true;

  // Search functionality
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
    _subscribeNotifications();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      // Load leads count (role-aware)
      final List<Lead> leads = await RoleAwareData.getLeads(context);
      final int leadsCount = leads.length;

      // Load meetings today (role-aware site visits; bookings unchanged)
      final List<SiteVisit> siteVisits = await RoleAwareData.getSiteVisits(
        context,
      );
      final List<Booking> bookings = await DatabaseService.getBookings();

      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(today.year, today.month, today.day);
      final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      final int meetingsToday =
          siteVisits.where((sv) {
            if (sv.meetingFrom == null) return false;
            return sv.meetingFrom!.isAfter(startOfDay) &&
                sv.meetingFrom!.isBefore(endOfDay);
          }).length +
          bookings.where((b) {
            return b.bookingDate.isAfter(startOfDay) &&
                b.bookingDate.isBefore(endOfDay);
          }).length;

      // Load active projects (projects are global)
      final List<Project> projects = await DatabaseService.getProjects();
      final int activeProjects = projects
          .where((p) => p.status == ProjectStatus.underConstruction)
          .length;

      // Load active tasks (role-aware)
      final List<Task> tasks = await RoleAwareData.getTasks(context);
      final int activeTasks = tasks
          .where(
            (t) =>
                t.status == TaskStatus.pending ||
                t.status == TaskStatus.inProgress,
          )
          .length;

      // Load team members count from users table (unchanged)
      final List<Map<String, dynamic>> users =
          await DatabaseServiceUsersAndDisposition.getAssignableUsers();
      final int teamMembers = users.length;

      if (mounted) {
        setState(() {
          _leadsCount = leadsCount;
          _meetingsToday = meetingsToday;
          _activeProjectsCount = activeProjects;
          _activeTasksCount = activeTasks;
          _teamMembersCount = teamMembers;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  // Realtime notifications (listen to updates on public.leads)
  supabase.RealtimeChannel? _notifChannel;
  supabase.RealtimeChannel? _statsChannel;

  void _subscribeNotifications() {
    final supabase.SupabaseClient client = supabase.Supabase.instance.client;
    final supabase.RealtimeChannel ch = client.channel('public:events');
    final String? currentUserId = client.auth.currentUser?.id;

    void push(AppNotificationType type, String title, String message) {
      final store = context.read<NotificationStore>();
      final String id = DateTime.now().microsecondsSinceEpoch.toString();
      store.add(
        AppNotification(
          id: id,
          title: title,
          message: message,
          time: 'Just now',
          type: type,
          unread: true,
          createdAt: DateTime.now(),
        ),
      );
      setState(() {});
    }

    // Leads
    ch.onPostgresChanges(
      event: supabase.PostgresChangeEvent.insert,
      schema: 'public',
      table: 'leads',
      callback: (supabase.PostgresChangePayload payload) {
        push(AppNotificationType.lead, 'New Lead', 'A new lead was created');
      },
    );
    ch.onPostgresChanges(
      event: supabase.PostgresChangeEvent.update,
      schema: 'public',
      table: 'leads',
      callback: (supabase.PostgresChangePayload payload) {
        push(AppNotificationType.lead, 'Lead Updated', 'A lead was updated');
      },
    );

    // Tasks
    ch.onPostgresChanges(
      event: supabase.PostgresChangeEvent.insert,
      schema: 'public',
      table: 'tasks',
      callback: (supabase.PostgresChangePayload payload) {
        push(
          AppNotificationType.followUp,
          'Task Created',
          'A task was created',
        );
      },
    );
    ch.onPostgresChanges(
      event: supabase.PostgresChangeEvent.update,
      schema: 'public',
      table: 'tasks',
      callback: (supabase.PostgresChangePayload payload) {
        push(
          AppNotificationType.followUp,
          'Task Updated',
          'A task was updated',
        );
      },
    );

    // Tickets
    ch.onPostgresChanges(
      event: supabase.PostgresChangeEvent.insert,
      schema: 'public',
      table: 'tickets',
      callback: (supabase.PostgresChangePayload payload) {
        push(
          AppNotificationType.booking,
          'Ticket Created',
          'A ticket was created',
        );
      },
    );
    ch.onPostgresChanges(
      event: supabase.PostgresChangeEvent.update,
      schema: 'public',
      table: 'tickets',
      callback: (supabase.PostgresChangePayload payload) {
        push(
          AppNotificationType.booking,
          'Ticket Updated',
          'A ticket was updated',
        );
      },
    );

    // Site visits
    ch.onPostgresChanges(
      event: supabase.PostgresChangeEvent.insert,
      schema: 'public',
      table: 'site_visits',
      callback: (supabase.PostgresChangePayload payload) {
        push(
          AppNotificationType.calendar,
          'Site Visit Scheduled',
          'A new site visit was scheduled',
        );
      },
    );
    ch.onPostgresChanges(
      event: supabase.PostgresChangeEvent.update,
      schema: 'public',
      table: 'site_visits',
      callback: (supabase.PostgresChangePayload payload) {
        push(
          AppNotificationType.calendar,
          'Site Visit Updated',
          'A site visit was updated',
        );
      },
    );

    // Bookings
    ch.onPostgresChanges(
      event: supabase.PostgresChangeEvent.insert,
      schema: 'public',
      table: 'bookings',
      callback: (supabase.PostgresChangePayload payload) {
        push(
          AppNotificationType.booking,
          'Booking Created',
          'A new booking was created',
        );
      },
    );
    ch.onPostgresChanges(
      event: supabase.PostgresChangeEvent.update,
      schema: 'public',
      table: 'bookings',
      callback: (supabase.PostgresChangePayload payload) {
        push(
          AppNotificationType.booking,
          'Booking Updated',
          'A booking was updated',
        );
      },
    );

    _notifChannel = ch.subscribe();

    // Subscribe to stats-related table changes for real-time updates
    _subscribeStatsUpdates();

    // Also listen to user-scoped notifications table to reflect server-side notifications
    // (e.g., lead assignments) in the in-app badge immediately
    final supabase.RealtimeChannel notifCh = client.channel(
      'public:notifications',
    );
    notifCh.onPostgresChanges(
      event: supabase.PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      callback: (supabase.PostgresChangePayload payload) {
        try {
          final Map<String, dynamic> newRow = payload.newRecord;
          if (newRow == null) return;
          final String? userId = newRow['user_id'] as String?;
          if (currentUserId != null && userId == currentUserId) {
            final String title = (newRow['title'] as String?) ?? 'Notification';
            final String message = (newRow['message'] as String?) ?? '';
            push(AppNotificationType.lead, title, message);
          }
        } catch (_) {
          // Ignore malformed rows
        }
      },
    );
    notifCh.subscribe();
  }

  void _subscribeStatsUpdates() {
    final supabase.SupabaseClient client = supabase.Supabase.instance.client;
    final supabase.RealtimeChannel statsCh = client.channel('public:stats');

    // Listen to projects table changes
    statsCh.onPostgresChanges(
      event: supabase.PostgresChangeEvent.all,
      schema: 'public',
      table: 'projects',
      callback: (supabase.PostgresChangePayload payload) {
        _loadStats(); // Refresh stats when projects change
      },
    );

    // Listen to tasks table changes
    statsCh.onPostgresChanges(
      event: supabase.PostgresChangeEvent.all,
      schema: 'public',
      table: 'tasks',
      callback: (supabase.PostgresChangePayload payload) {
        _loadStats(); // Refresh stats when tasks change
      },
    );

    // Listen to users table changes
    statsCh.onPostgresChanges(
      event: supabase.PostgresChangeEvent.all,
      schema: 'public',
      table: 'users',
      callback: (supabase.PostgresChangePayload payload) {
        _loadStats(); // Refresh stats when users change
      },
    );

    _statsChannel = statsCh.subscribe();
  }

  @override
  void dispose() {
    _notifChannel?.unsubscribe();
    _statsChannel?.unsubscribe();
    _homeSearchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query.trim();
    });

    try {
      final List<Map<String, dynamic>> results = [];

      // Search leads
      try {
        final List<Lead> leads = await DatabaseService.getLeads(
          search: query,
          limit: 5,
        );
        for (final lead in leads) {
          results.add({
            'type': 'lead',
            'id': lead.id,
            'title': lead.customerName,
            'subtitle': 'Lead ID: ${lead.leadId}',
            'description': lead.projectName,
            'icon': Icons.person_search,
            'data': lead,
          });
        }
      } catch (e) {
        // Continue with other searches even if leads fail
      }

      // Search customers
      try {
        final List<Customer> customers = await DatabaseService.getCustomers(
          search: query,
          limit: 5,
        );
        for (final customer in customers) {
          results.add({
            'type': 'customer',
            'id': customer.id,
            'title': customer.name,
            'subtitle': customer.email,
            'description': customer.phone,
            'icon': Icons.person,
            'data': customer,
          });
        }
      } catch (e) {
        // Continue with other searches even if customers fail
      }

      // Search projects
      try {
        final List<Project> projects = await DatabaseService.getProjects(
          search: query,
          limit: 5,
        );
        for (final project in projects) {
          results.add({
            'type': 'project',
            'id': project.id,
            'title': project.name,
            'subtitle': project.type.name,
            'description': project.description,
            'icon': Icons.business,
            'data': project,
          });
        }
      } catch (e) {
        // Continue with other searches even if projects fail
      }

      // Search bookings
      try {
        final List<Booking> bookings = await DatabaseService.getBookings(
          search: query,
          limit: 5,
        );
        for (final booking in bookings) {
          results.add({
            'type': 'booking',
            'id': booking.id,
            'title': booking.customerName,
            'subtitle': 'SR No: ${booking.srNo}',
            'description': booking.projectName,
            'icon': Icons.confirmation_number,
            'data': booking,
          });
        }
      } catch (e) {
        // Continue with other searches even if bookings fail
      }

      // Search site visits
      try {
        final List<SiteVisit> siteVisits = await DatabaseService.getSiteVisits(
          search: query,
          limit: 5,
        );
        for (final siteVisit in siteVisits) {
          results.add({
            'type': 'site_visit',
            'id': siteVisit.id,
            'title': siteVisit.customerName,
            'subtitle': 'Site Visit',
            'description': siteVisit.projectName,
            'icon': Icons.location_on,
            'data': siteVisit,
          });
        }
      } catch (e) {
        // Continue with other searches even if site visits fail
      }

      // Search tasks
      try {
        final List<Task> tasks = await DatabaseService.getTasks(
          search: query,
          limit: 5,
        );
        for (final task in tasks) {
          results.add({
            'type': 'task',
            'id': task.id,
            'title': task.title,
            'subtitle': task.status.name,
            'description': task.description,
            'icon': Icons.task,
            'data': task,
          });
        }
      } catch (e) {
        // Continue with other searches even if tasks fail
      }

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        // Search header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search results for "$_searchQuery"',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _homeSearchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _searchResults = [];
                  });
                },
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),
        // Search results
        Expanded(
          child: _isSearching
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Searching...'),
                    ],
                  ),
                )
              : _searchResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try searching with different keywords',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return _buildSearchResultItem(result);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            result['icon'] as IconData,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          result['title'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result['subtitle'] as String),
            if (result['description'] != null)
              Text(
                result['description'] as String,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: () => _navigateToSearchResult(result),
      ),
    );
  }

  void _navigateToSearchResult(Map<String, dynamic> result) {
    final String type = result['type'] as String;

    switch (type) {
      case 'lead':
        // Navigate to lead detail or lead screen
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(child: const LeadScreen()),
        );
        break;
      case 'customer':
        // Navigate to customer detail or customer screen
        // For now, just show a snackbar
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Customer: ${result['title']}')));
        break;
      case 'project':
        // Navigate to project detail
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Project: ${result['title']}')));
        break;
      case 'booking':
        // Navigate to booking screen
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: const BookingScreen(),
          ),
        );
        break;
      case 'site_visit':
        // Navigate to site visit screen
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: const SiteVisitScreen(),
          ),
        );
        break;
      case 'task':
        // Navigate to task detail
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Task: ${result['title']}')));
        break;
    }
  }

  late final List<Widget> _screens = <Widget>[
    DashboardTab(
      loginTime: _loginTime,
      leadsCount: _leadsCount,
      meetingsToday: _meetingsToday,
      activeProjectsCount: _activeProjectsCount,
      activeTasksCount: _activeTasksCount,
      teamMembersCount: _teamMembersCount,
      isLoadingStats: _isLoadingStats,
    ),
    const CustomersTab(),
    const VendorScreen(),
    const PropertyFinderScreen(),
  ];

  Color _panelColor(BuildContext context) {
    return panelColor(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          children: <Widget>[
            AnimatedGlowingLogo(
              child: Image.asset(
                'assets/favicon.webp',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: _panelColor(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.search_rounded,
                      color: Theme.of(context).iconTheme.color,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _homeSearchController,
                        onChanged: (String value) {
                          setState(() {});
                          // Debounce search
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_homeSearchController.text == value) {
                              _performSearch(value);
                            }
                          });
                        },
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Search...',
                          hintStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                          suffixIcon: _homeSearchController.text.isNotEmpty
                              ? IconButton(
                                  tooltip: 'Clear',
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    _homeSearchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (String value) {
                          _performSearch(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Stats',
          ),
          Stack(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    SmoothPageTransitions.slideFromRight<void>(
                      child: const NotificationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_outlined),
              ),
              Positioned(
                right: 8,
                top: 10,
                child: Consumer<NotificationStore>(
                  builder: (BuildContext context, NotificationStore store, _) {
                    if (store.unreadCount == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        store.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _panelColor(context),
              child: ClipOval(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      SmoothPageTransitions.slideFromRight<void>(
                        child: const ProfileScreen(),
                      ),
                    );
                  },
                  child: Image.network(
                    _profileImageUrl,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return Icon(
                            Icons.person_outline,
                            color: Theme.of(context).iconTheme.color,
                            size: 18,
                          );
                        },
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _CircularLottieButton(
                  lottieUrl: 'assets/lottie/lead.json',
                  label: 'Lead',
                  onTap: () {
                    Navigator.of(context).push(
                      SmoothPageTransitions.slideFromRight<void>(
                        child: const LeadScreen(),
                      ),
                    );
                  },
                ),
                _CircularLottieButton(
                  lottieUrl: 'assets/lottie/site_visit.json',
                  label: 'Site Visit',
                  onTap: () {
                    Navigator.of(context).push(
                      SmoothPageTransitions.slideFromRight<void>(
                        child: const SiteVisitScreen(),
                      ),
                    );
                  },
                ),
                _CircularLottieButton(
                  lottieUrl: 'assets/lottie/booking.json',
                  label: 'Booking',
                  onTap: () {
                    Navigator.of(context).push(
                      SmoothPageTransitions.slideFromRight<void>(
                        child: const BookingScreen(),
                      ),
                    );
                  },
                ),
                _CircularLottieButton(
                  lottieUrl: 'assets/lottie/Dashboard.json',
                  label: 'Dashboard',
                  onTap: () {
                    Navigator.of(context).push(
                      SmoothPageTransitions.slideFromRight<void>(
                        child: const DashboardScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: _searchQuery.isNotEmpty
          ? _buildSearchResults()
          : _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex >= 2 ? _selectedIndex + 1 : _selectedIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (int index) {
          if (index == 2) {
            _showAddActions(context);
            return;
          }
          final int mapped = index > 2 ? index - 1 : index;
          setState(() {
            _selectedIndex = mapped;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_rounded),
            activeIcon: Icon(Icons.group),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory_outlined),
            activeIcon: Icon(Icons.store_mall_directory),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore_rounded),
            activeIcon: Icon(Icons.travel_explore),
            label: '',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({
    super.key,
    required this.loginTime,
    required this.leadsCount,
    required this.meetingsToday,
    required this.activeProjectsCount,
    required this.activeTasksCount,
    required this.teamMembersCount,
    required this.isLoadingStats,
  });

  final DateTime loginTime;
  final int leadsCount;
  final int meetingsToday;
  final int activeProjectsCount;
  final int activeTasksCount;
  final int teamMembersCount;
  final bool isLoadingStats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _UserInfoSummary(
            loginTime: loginTime,
            leadsCount: leadsCount,
            meetingsToday: meetingsToday,
          ),
          const SizedBox(height: 16),
          // Removed subtitle text per request
          const SizedBox(height: 24),
          _buildCallSummary(context),
          const SizedBox(height: 24),
          _buildStatsCard(context),
          const SizedBox(height: 24),
          _buildRecentActivity(context),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: panelBorderColor(context)),
      ),
      child: isLoadingStats
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          : Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ActiveProjectsScreen(),
                        ),
                      );
                    },
                    child: _buildStatItem(
                      context,
                      'Active Projects',
                      activeProjectsCount.toString(),
                      Icons.folder,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: panelBorderColor(context),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ActiveTasksScreen(),
                        ),
                      );
                    },
                    child: _buildStatItem(
                      context,
                      'Active Tasks',
                      activeTasksCount.toString(),
                      Icons.check_circle,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: panelBorderColor(context),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: _buildStatItem(
                      context,
                      'Team Members',
                      teamMembersCount.toString(),
                      Icons.people,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: <Widget>[
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCallSummary(BuildContext context) {
    final Map<String, int> summary = <String, int>{
      'total': 40,
      'incoming': 22,
      'outgoing': 18,
      'connected': 28,
      'notConnected': 8,
      'missed': 4,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: panelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: panelBorderColor(context)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _callTile(
              context,
              icon: Icons.call,
              label: 'All calls',
              value: '${summary['total']}',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CallStatsDetailScreen(summary: summary),
                ),
              ),
            ),
          ),
          Container(width: 1, height: 40, color: panelBorderColor(context)),
          Expanded(
            child: _callTile(
              context,
              icon: Icons.call_received,
              label: 'Incoming',
              value: '${summary['incoming']}',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CallStatsDetailScreen(summary: summary),
                ),
              ),
            ),
          ),
          Container(width: 1, height: 40, color: panelBorderColor(context)),
          Expanded(
            child: _callTile(
              context,
              icon: Icons.call_made,
              label: 'Outgoing',
              value: '${summary['outgoing']}',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CallStatsDetailScreen(summary: summary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _callTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // TODO: Load real recent activities from database
        // For now, showing placeholder
        _buildActivityItem(
          context,
          'No recent activity',
          'Check back later',
          Icons.info,
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: panelBorderColor(context)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  time,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserInfoSummary extends StatelessWidget {
  const _UserInfoSummary({
    required this.loginTime,
    required this.leadsCount,
    required this.meetingsToday,
  });

  final DateTime loginTime;
  final int leadsCount;
  final int meetingsToday;

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        '${loginTime.hour.toString().padLeft(2, '0')}:${loginTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: panelBorderColor(context)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _UserInfoItem(
              icon: Icons.login,
              label: 'Logged in',
              value: formattedTime,
            ),
          ),
          Container(width: 1, height: 40, color: panelBorderColor(context)),
          Expanded(
            child: _UserInfoItem(
              icon: Icons.event_available,
              label: 'Meetings today',
              value: meetingsToday.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserInfoItem extends StatelessWidget {
  const _UserInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Projects Tab',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Tasks Tab',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Tab',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}

class CustomersTab extends StatefulWidget {
  const CustomersTab({super.key});

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  final TextEditingController _filterNameCtrl = TextEditingController();
  final TextEditingController _filterEmailCtrl = TextEditingController();
  String _filterProjectType = 'Any';
  String _filterProject = 'Any';
  String _filterAging = 'Any';
  DateTime? _filterLastUpdate;

  // Real data from database
  List<Customer> _allCustomers = <Customer>[];
  bool _isLoadingCustomers = true;
  String? _customersError;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      setState(() {
        _isLoadingCustomers = true;
        _customersError = null;
      });

      final List<Customer> customers = await DatabaseService.getCustomers();
      setState(() {
        _allCustomers = customers;
        _isLoadingCustomers = false;
      });
    } catch (e) {
      setState(() {
        _customersError = e.toString();
        _isLoadingCustomers = false;
      });
    }
  }

  List<Customer> get _filteredCustomers {
    return _allCustomers.where((Customer c) {
      final String nameQ = _filterNameCtrl.text.trim().toLowerCase();
      final String emailQ = _filterEmailCtrl.text.trim().toLowerCase();

      if (nameQ.isNotEmpty && !c.name.toLowerCase().contains(nameQ)) {
        return false;
      }
      if (emailQ.isNotEmpty && !c.email.toLowerCase().contains(emailQ)) {
        return false;
      }
      if (_filterProjectType != 'Any' && c.projectType != _filterProjectType) {
        return false;
      }
      if (_filterProject != 'Any' && c.projectName != _filterProject) {
        return false;
      }

      // Aging filter based on days since lastUpdate
      final DateTime lu = c.updatedAt;
      final int days = DateTime.now().difference(lu).inDays;
      switch (_filterAging) {
        case 'Today':
          if (days != 0) return false;
          break;
        case '1-7 days':
          if (days < 1 || days > 7) return false;
          break;
        case '8-30 days':
          if (days < 8 || days > 30) return false;
          break;
        case '31+ days':
          if (days < 31) return false;
          break;
      }

      if (_filterLastUpdate != null) {
        final DateTime sel = DateTime(
          _filterLastUpdate!.year,
          _filterLastUpdate!.month,
          _filterLastUpdate!.day,
        );
        final DateTime row = DateTime(lu.year, lu.month, lu.day);
        if (row != sel) return false;
      }
      return true;
    }).toList();
  }

  int get _todaysCount {
    final DateTime today = DateTime.now();
    return _allCustomers
        .where(
          (Customer c) =>
              c.updatedAt.year == today.year &&
              c.updatedAt.month == today.month &&
              c.updatedAt.day == today.day,
        )
        .length;
  }

  @override
  void dispose() {
    _filterNameCtrl.dispose();
    _filterEmailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> projectTypes = <String>[
      'Any',
      'Residential',
      'Commercial',
    ];
    final List<String> projects = <String>[
      'Any',
      'Skyline Heights',
      'Tech Park',
      'Green Meadows',
    ];
    final List<String> agingOptions = <String>[
      'Any',
      'Today',
      '1-7 days',
      '8-30 days',
      '31+ days',
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _metricCard(
                  context,
                  title: 'Today\'s Customers',
                  value: _todaysCount.toString(),
                  icon: Icons.today_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricCard(
                  context,
                  title: 'Total Customers',
                  value: _allCustomers.length.toString(),
                  icon: Icons.group_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Customers',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showCustomerFilters(
                  context,
                  projectTypes,
                  projects,
                  agingOptions,
                ),
                icon: const Icon(Icons.filter_list_rounded, size: 18),
                label: const Text('Filter'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                ),
              ),
              child: _buildCustomersContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersContent(BuildContext context) {
    if (_isLoadingCustomers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_customersError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error loading customers: $_customersError'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCustomers,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredCustomers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No customers found'),
        ),
      );
    }

    return _buildCards(context, _filteredCustomers);
  }

  Widget _buildCards(BuildContext context, List<Customer> customers) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        int crossAxisCount = 1;
        if (width >= 1100) {
          crossAxisCount = 3;
        } else if (width >= 700) {
          crossAxisCount = 2;
        }
        // Adaptive aspect ratio to ensure enough vertical room per card
        double aspectRatio;
        if (crossAxisCount == 3) {
          aspectRatio = 3.0;
        } else if (crossAxisCount == 2) {
          aspectRatio = 2.4;
        } else {
          aspectRatio = 1.8;
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemCount: customers.length,
          itemBuilder: (BuildContext context, int index) {
            final Customer customer = customers[index];
            return _customerCard(context, index, customer);
          },
        );
      },
    );
  }

  Widget _customerCard(BuildContext context, int index, Customer customer) {
    final DateTime lastUpdate = customer.updatedAt;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.25),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _avatarCircle(context, customer.name),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            customer.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isToday(lastUpdate)) ...<Widget>[
                          const SizedBox(width: 6),
                          _pill(context, 'Today'),
                        ],
                        const SizedBox(width: 6),
                        _rowActions(context, customer),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.mail_outline,
                          size: 14,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            customer.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.call_outlined,
                          size: 14,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            customer.phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _quickActions(context, customer),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.year}';
  }

  // Removed unused _chip helper after simplifying card content

  Widget _rowActions(BuildContext context, Customer customer) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'view', child: Text('View')),
        const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
        const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
      ],
      onSelected: (String value) {
        if (value == 'view') {
          _showCustomerDetails(context, customer);
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action "$value" on ${customer.name}')),
        );
      },
    );
  }

  void _showCustomerDetails(BuildContext context, Customer customer) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Customer Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _detailRow(context, 'Name', customer.name),
                _detailRow(context, 'Email', customer.email),
                _detailRow(context, 'Contact', customer.phone),
                _detailRow(context, 'Assign To', customer.assignedToName),
                _detailRow(context, 'Created By', customer.createdByName),
                if (customer.projectType != null)
                  _detailRow(context, 'Project Type', customer.projectType!),
                if (customer.projectName != null)
                  _detailRow(context, 'Project', customer.projectName!),
                _detailRow(
                  context,
                  'Last Update',
                  _formatDate(customer.updatedAt),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _avatarCircle(BuildContext context, String name) {
    final String initials = _initialsFromName(name);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _initialsFromName(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r"\s+"))
        .where((String s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  bool _isToday(DateTime dt) {
    final DateTime now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  Widget _pill(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.30),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _quickActions(BuildContext context, Customer customer) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          tooltip: 'Email',
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Email ${customer.email}')));
          },
          icon: const Icon(Icons.email_outlined, size: 16),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          tooltip: 'Call',
          onPressed: () {
            Helpers.placeCall(Helpers.safeString(customer.phone));
          },
          icon: const Icon(Icons.call_outlined, size: 16),
        ),
      ],
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showCustomerFilters(
    BuildContext context,
    List<String> projectTypes,
    List<String> projects,
    List<String> agingOptions,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        final TextEditingController nameCtrl = TextEditingController(
          text: _filterNameCtrl.text,
        );
        final TextEditingController emailCtrl = TextEditingController(
          text: _filterEmailCtrl.text,
        );
        String projectType = _filterProjectType;
        String project = _filterProject;
        String aging = _filterAging;
        DateTime? lastUpdate = _filterLastUpdate;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Filter Customers',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Customer Name',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Customer Email',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: projectType,
                            items: projectTypes
                                .map(
                                  (String e) => DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? v) =>
                                setModal(() => projectType = v ?? 'Any'),
                            decoration: const InputDecoration(
                              labelText: 'Project Type',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: project,
                            items: projects
                                .map(
                                  (String e) => DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? v) =>
                                setModal(() => project = v ?? 'Any'),
                            decoration: const InputDecoration(
                              labelText: 'Project',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: aging,
                            items: agingOptions
                                .map(
                                  (String e) => DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? v) =>
                                setModal(() => aging = v ?? 'Any'),
                            decoration: const InputDecoration(
                              labelText: 'Select Aging',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final DateTime now = DateTime.now();
                              final DateTime first = DateTime(now.year - 2);
                              final DateTime last = DateTime(now.year + 1);
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: lastUpdate ?? now,
                                firstDate: first,
                                lastDate: last,
                              );
                              if (picked != null) {
                                setModal(() => lastUpdate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Last Update Date',
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.event,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    lastUpdate == null
                                        ? 'Any'
                                        : '${lastUpdate!.day.toString().padLeft(2, '0')}-'
                                              '${lastUpdate!.month.toString().padLeft(2, '0')}-'
                                              '${lastUpdate!.year}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _filterNameCtrl.clear();
                                _filterEmailCtrl.clear();
                                _filterProjectType = 'Any';
                                _filterProject = 'Any';
                                _filterAging = 'Any';
                                _filterLastUpdate = null;
                              });
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              setState(() {
                                _filterNameCtrl.text = nameCtrl.text;
                                _filterEmailCtrl.text = emailCtrl.text;
                                _filterProjectType = projectType;
                                _filterProject = project;
                                _filterAging = aging;
                                _filterLastUpdate = lastUpdate;
                              });
                              Navigator.of(ctx).pop();
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class BookingTab extends StatelessWidget {
  const BookingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Booking',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}

class LeadsTab extends StatelessWidget {
  const LeadsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Leads', style: TextStyle(color: Colors.white, fontSize: 24)),
    );
  }
}

// Show Add actions: Create Lead, Booking, Lead Follow-up
void _showAddActions(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.confirmation_number_outlined,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Ticket',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  SmoothPageTransitions.slideFromBottom<void>(
                    child: const TicketHubScreen(),
                  ),
                );
              },
            ),
            // Removed Vendor Management from plus sheet; now available in bottom nav
            // Booking removed from bottom nav; keep optional in sheet if needed later
            ListTile(
              leading: Icon(
                Icons.assignment_turned_in_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Lead Follow-up',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  SmoothPageTransitions.slideFromBottom<void>(
                    child: const LeadFollowUpScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _CircularLottieButton extends StatelessWidget {
  const _CircularLottieButton({
    required this.lottieUrl,
    this.onTap,
    this.label,
  });

  final String lottieUrl;
  final VoidCallback? onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final Color bg = panelColor(context);
    final Color border = panelBorderColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bg,
                border: Border.all(color: border),
              ),
              child: ClipOval(
                child: Center(
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Lottie.asset(
                      lottieUrl,
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                      addRepaintBoundary: true,
                      onWarning: (String warning) {},
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.error_outline,
                          color: Theme.of(context).iconTheme.color,
                          size: 28,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (label != null) ...<Widget>[
              const SizedBox(height: 6),
              SizedBox(
                width: 70,
                child: Text(
                  label!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.90),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
