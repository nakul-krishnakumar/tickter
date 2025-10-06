import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/timetable_model.dart';

class TimetableService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch timetable for a specific semester, course, and batch
  static Future<Timetable?> fetchTimetable({
    required int semester,
    required String courseCode,
    required String batch,
    required String academicYear,
  }) async {
    try {
      final response = await _supabase
          .from('timetables')
          .select('*')
          .eq('semester', semester)
          .eq('course_code', courseCode)
          .eq('batch', batch)
          .eq('academic_year', academicYear)
          .limit(1);

      if (response.isEmpty) {
        return null;
      }

      return Timetable.fromJson(response.first);
    } catch (error) {
      throw Exception('Failed to fetch timetable: ${error.toString()}');
    }
  }

  /// Fetch all periods for a specific timetable
  static Future<List<TimetablePeriod>> fetchTimetablePeriods({
    required String timetableId,
  }) async {
    try {
      final response = await _supabase
          .from('timetable_periods')
          .select('*')
          .eq('timetable_id', timetableId)
          .order('start_time', ascending: true);

      return (response as List)
          .map((periodData) => TimetablePeriod.fromJson(periodData))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch timetable periods: ${error.toString()}');
    }
  }

  /// Fetch periods for a specific day
  static Future<List<TimetablePeriod>> fetchPeriodsForDay({
    required String timetableId,
    required String day,
  }) async {
    try {
      final response = await _supabase
          .from('timetable_periods')
          .select('*')
          .eq('timetable_id', timetableId)
          .eq('day', day)
          .order('start_time', ascending: true);

      return (response as List)
          .map((periodData) => TimetablePeriod.fromJson(periodData))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch periods for day: ${error.toString()}');
    }
  }

  /// Get day name from DateTime
  static String getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  /// Fetch timetable and periods for a user (you'll need to get user's details first)
  static Future<Map<String, List<TimetablePeriod>>> fetchUserTimetableForWeek({
    required int semester,
    required String courseCode,
    required String batch,
    required String academicYear,
  }) async {
    try {
      // First fetch the timetable
      final timetable = await fetchTimetable(
        semester: semester,
        courseCode: courseCode,
        batch: batch,
        academicYear: academicYear,
      );

      if (timetable == null) {
        return {};
      }

      // Then fetch all periods for this timetable
      final allPeriods = await fetchTimetablePeriods(timetableId: timetable.id);

      // Group by day
      final Map<String, List<TimetablePeriod>> groupedPeriods = {};
      for (final period in allPeriods) {
        if (groupedPeriods[period.day] == null) {
          groupedPeriods[period.day] = [];
        }
        groupedPeriods[period.day]!.add(period);
      }

      return groupedPeriods;
    } catch (error) {
      throw Exception('Failed to fetch user timetable: ${error.toString()}');
    }
  }

  /// Fetch periods for a specific date
  static Future<List<TimetablePeriod>> fetchPeriodsForDate({
    required int semester,
    required String courseCode,
    required String batch,
    required String academicYear,
    required DateTime date,
  }) async {
    try {
      // First fetch the timetable
      final timetable = await fetchTimetable(
        semester: semester,
        courseCode: courseCode,
        batch: batch,
        academicYear: academicYear,
      );

      if (timetable == null) {
        return [];
      }

      // Get day name from date
      final dayName = getDayName(date);

      // Fetch periods for that day
      return await fetchPeriodsForDay(timetableId: timetable.id, day: dayName);
    } catch (error) {
      throw Exception('Failed to fetch periods for date: ${error.toString()}');
    }
  }
}
