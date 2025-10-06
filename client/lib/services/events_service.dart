import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

class EventsService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all events from the database
  static Future<List<Event>> fetchAllEvents() async {
    try {
      final response = await _supabase
          .from('events')
          .select('*')
          .order('date', ascending: true);

      return (response as List)
          .map((eventData) => Event.fromJson(eventData))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch events: ${error.toString()}');
    }
  }

  /// Fetch events for a specific date range
  static Future<List<Event>> fetchEventsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase
          .from('events')
          .select('*')
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: true);

      return (response as List)
          .map((eventData) => Event.fromJson(eventData))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch events for date range: ${error.toString()}');
    }
  }

  /// Fetch events for a specific user based on their semester and batch
  static Future<List<Event>> fetchEventsForUser({
    required int semester,
    required int batch,
  }) async {
    try {
      final response = await _supabase
          .from('events')
          .select('*')
          .contains('semester', [semester])
          .contains('batch', [batch])
          .order('date', ascending: true);

      return (response as List)
          .map((eventData) => Event.fromJson(eventData))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch user-specific events: ${error.toString()}');
    }
  }

  /// Group events by date
  static Map<DateTime, List<Event>> groupEventsByDate(List<Event> events) {
    final Map<DateTime, List<Event>> groupedEvents = {};
    
    for (final event in events) {
      final eventDate = DateTime.utc(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      
      if (groupedEvents[eventDate] == null) {
        groupedEvents[eventDate] = [];
      }
      groupedEvents[eventDate]!.add(event);
    }
    
    return groupedEvents;
  }
}