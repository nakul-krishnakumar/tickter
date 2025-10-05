import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
  /// In a real app, you would fetch this from your Supabase database.
  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2025, 9, 25): ['Team Meeting', 'Project Deadline'],
    DateTime.utc(2025, 9, 28): ['Doctor\'s Appointment'],
  };

  /// This function shows a pop-up dialog with the events for the selected day.
  void _showEventsPopup(DateTime day) {
    final eventsForDay = _events[day] ?? [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Events on ${day.day}/${day.month}/${day.year}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: eventsForDay.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(eventsForDay[index]),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institute Calendar'),
      ),
      body: TableCalendar(
        // The first and last available days in the calendar.
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        // This is the day that the calendar is currently focused on.
        focusedDay: _focusedDay,
        // The format of the calendar (month, two weeks, week).
        calendarFormat: CalendarFormat.month,
        // Determines which day is currently selected.
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        // This function is called every time a user taps on a day.
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay; // update `_focusedDay` as well
          });
          _showEventsPopup(selectedDay);
        },
        // This function places markers below days that have events.
        eventLoader: (day) {
          return _events[day] ?? [];
        },
      ),
    );
  }
}