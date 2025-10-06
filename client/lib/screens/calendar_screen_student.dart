import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/event_model.dart';
import '../models/timetable_model.dart';
import '../services/auth_service.dart';
import '../services/events_service.dart';
import '../services/timetable_service.dart';
import '../widgets/add_event_dialog.dart';
import '../widgets/role_guard.dart';
import 'admin_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Manages the currently focused day in the calendar.
  DateTime _focusedDay = DateTime.now();
  // Manages the currently selected day.
  DateTime? _selectedDay;

  /// A map to hold events for each day.
  Map<DateTime, List<Event>> _events = {};

  /// A map to hold timetable periods for each day of the week.
  Map<String, List<TimetablePeriod>> _timetablePeriods = {};
  bool _isLoading = true;

  // TODO: In a real app, you'd get these from user profile/auth
  // Updated to match the actual data in your database
  final int _userSemester = 5;
  final String _userCourseCode = 'CSE';
  final String _userBatch = '1'; // Changed from 'A' to '1' to match your data
  final String _academicYear =
      '2025'; // Changed from '2024-25' to '2025' to match your data

  @override
  void initState() {
    super.initState();
    print('CALENDAR: CalendarScreen initState called');
    _fetchEvents();

    // Debug: Print current user role immediately and after frame
    final authService = AuthService();
    print('CALENDAR: AuthService instance obtained');
    print(
      'CALENDAR: Immediate check - Current user: ${authService.currentUser}',
    );
    print(
      'CALENDAR: Immediate check - User role: ${authService.currentUser?.role.name}',
    );
    print(
      'CALENDAR: Immediate check - Is admin: ${authService.currentUser?.isAdmin}',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(
        'CALENDAR: Post-frame callback - Current user: ${authService.currentUser}',
      );
      print(
        'CALENDAR: Post-frame callback - User role: ${authService.currentUser?.role.name}',
      );
      print(
        'CALENDAR: Post-frame callback - Is admin: ${authService.currentUser?.isAdmin}',
      );
      print(
        'CALENDAR: Post-frame callback - AuthService isLoggedIn: ${authService.isLoggedIn}',
      );
    });
  }

  /// Fetch events and timetable data from Supabase database
  Future<void> _fetchEvents() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch events and timetable data in parallel
      final results = await Future.wait([
        EventsService.fetchAllEvents(),
        TimetableService.fetchUserTimetableForWeek(
          semester: _userSemester,
          courseCode: _userCourseCode,
          batch: _userBatch,
          academicYear: _academicYear,
        ),
      ]);

      final List<Event> eventsList = results[0] as List<Event>;
      final Map<String, List<TimetablePeriod>> timetablePeriods =
          results[1] as Map<String, List<TimetablePeriod>>;

      // Group events by date
      final Map<DateTime, List<Event>> groupedEvents =
          EventsService.groupEventsByDate(eventsList);

      setState(() {
        _events = groupedEvents;
        _timetablePeriods = timetablePeriods;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${error.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Show Add Event dialog (Admin only)
  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        onEventAdded: () {
          _fetchEvents(); // Refresh events after adding
        },
      ),
    );
  }

  /// This function shows a pop-up dialog with the events and timetable for the selected day.
  void _showEventsPopup(DateTime day) {
    final eventsForDay = _events[day] ?? [];
    final dayName = TimetableService.getDayName(day);
    final periodsForDay = _timetablePeriods[dayName] ?? [];
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: false,
      builder: (context) => Dialog(
        insetPadding: isSmallScreen
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 0 : 20),
        ),
        elevation: 16,
        child: Container(
          width: isSmallScreen ? screenSize.width : null,
          height: isSmallScreen ? screenSize.height : null,
          constraints: isSmallScreen
              ? null
              : BoxConstraints(
                  maxWidth: 500,
                  maxHeight: screenSize.height * 0.85,
                ),
          child: SafeArea(
            top: isSmallScreen,
            bottom: isSmallScreen,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isSmallScreen ? 0 : 20),
                      topRight: Radius.circular(isSmallScreen ? 0 : 20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            Text(
                              '${_getMonthName(day.month)} ${day.year} • $dayName',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Events Section
                        if (eventsForDay.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.event_rounded,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Events',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...eventsForDay.map(
                            (event) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: _getEventTypeColor(
                                              event.type,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            event.eventName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getEventTypeColor(
                                              event.type,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            event.type,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _getEventTypeColor(
                                                event.type,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (event.description != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        event.description!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                    if (event.startTime != null ||
                                        event.endTime != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${event.startTime ?? ''} ${event.endTime != null ? '- ${event.endTime}' : ''}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Timetable Section
                        if (periodsForDay.isNotEmpty) ...[
                          if (eventsForDay.isNotEmpty)
                            const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                color: Colors.blue[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Today's Timetable",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...periodsForDay.map(
                            (period) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue[100]!,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top row with time and subject type badge
                                    Row(
                                      children: [
                                        // Time
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            '${period.startTime} - ${period.endTime}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[800],
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        // Subject type badge
                                        if (period.subjectType != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getSubjectTypeColor(
                                                period.subjectType!,
                                              ).withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              period.subjectType!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _getSubjectTypeColor(
                                                  period.subjectType!,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Subject name
                                    Text(
                                      period.subjectName ??
                                          period.subjectCode ??
                                          'Unknown Subject',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    // Subject code (if different from name)
                                    if (period.subjectCode != null &&
                                        period.subjectName != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          period.subjectCode!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    // Faculty and room in a responsive row
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 4,
                                      children: [
                                        if (period.faculty != null)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.person_rounded,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  period.faculty!,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (period.room != null)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.room_rounded,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                period.room!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Empty state
                        if (eventsForDay.isEmpty && periodsForDay.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.free_breakfast_rounded,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No events or classes today',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Enjoy your free time!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Color _getEventTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'exam':
        return Colors.red[600]!;
      case 'assignment':
        return Colors.orange[600]!;
      case 'lecture':
        return Colors.blue[600]!;
      case 'lab':
        return Colors.green[600]!;
      case 'seminar':
        return Colors.purple[600]!;
      case 'workshop':
        return Colors.teal[600]!;
      case 'holiday':
        return Colors.pink[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Color _getSubjectTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'lecture':
      case 'theory':
        return Colors.blue[700]!;
      case 'lab':
      case 'laboratory':
      case 'practical':
        return Colors.green[700]!;
      case 'tutorial':
        return Colors.orange[700]!;
      case 'seminar':
        return Colors.purple[700]!;
      case 'project':
        return Colors.indigo[700]!;
      case 'break':
      case 'lunch':
        return Colors.grey[600]!;
      default:
        return Colors.blueGrey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Institute Calendar',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          // Admin-only: Admin Panel button
          AdminOnlyWidget(
            child: IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminScreen()),
                );
              },
              tooltip: 'Admin Panel',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchEvents,
            tooltip: 'Refresh Events',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: TableCalendar<Event>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _showEventsPopup(selectedDay);
                    },
                    eventLoader: (day) {
                      return _events[day] ?? [];
                    },
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.grey,
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                      ),
                      titleTextStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                      headerPadding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      decoration: BoxDecoration(color: Colors.grey[50]),
                    ),
                    calendarStyle: CalendarStyle(
                      cellPadding: const EdgeInsets.all(4),
                      cellMargin: const EdgeInsets.all(2),

                      // Default day styling
                      defaultTextStyle: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),

                      // Weekend styling
                      weekendTextStyle: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),

                      // Today styling
                      todayDecoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.primaryColor, width: 2),
                      ),
                      todayTextStyle: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),

                      // Selected day styling
                      selectedDecoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),

                      // Outside days (previous/next month)
                      outsideTextStyle: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),

                      // Event markers
                      markersMaxCount: 3,
                      markerDecoration: BoxDecoration(
                        color: Colors.orange[400],
                        shape: BoxShape.circle,
                      ),
                      markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                      markerSize: 6,

                      // Hover effect for days with events
                      canMarkersOverflow: false,
                      markersAlignment: Alignment.bottomCenter,

                      // Cell decoration for days with events
                      defaultDecoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      weekendDecoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),

                      // Table border
                      tableBorder: TableBorder(
                        horizontalInside: BorderSide(
                          color: Colors.grey[100]!,
                          width: 0.5,
                        ),
                        verticalInside: BorderSide(
                          color: Colors.grey[100]!,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      // Admin-only floating action button for adding events
      floatingActionButton: AdminOnlyWidget(
        child: FloatingActionButton.extended(
          onPressed: _showAddEventDialog,
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Event',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          tooltip: 'Add New Event (Admin Only)',
        ),
      ),
    );
  }
}
