
import 'package:care_dart_sdk/utilities/date_utils.dart';

class SchedulerDate {
  DateTime localDateTime;
  String dayOfWeek;
  String dayOfMonth;
  String month;
  String shortMonth;

  String semanticDayOfWeek;
  String semanticMonth;

  bool isSelected = false;

  SchedulerDate(DateTime dateTime) {
    localDateTime = dateTime?.toLocal();

    dayOfWeek = DateUtils.formatDate(localDateTime, 'EEE');
    dayOfMonth = DateUtils.formatDate(localDateTime, 'd');
    month = DateUtils.formatDate(localDateTime, 'MM');
    shortMonth = DateUtils.formatDate(localDateTime, 'MMM');
    semanticDayOfWeek = DateUtils.formatDate(localDateTime, 'EEEE');
    semanticMonth = DateUtils.formatDate(localDateTime, 'MMMM');
  }

  @override
  bool operator ==(o) =>
      o is SchedulerDate &&
          localDateTime.year == o.localDateTime.year &&
          localDateTime.month == o.localDateTime.month &&
          localDateTime.day == o.localDateTime.day;

  @override
  int get hashCode =>
      (localDateTime.year + localDateTime.month + localDateTime.day).hashCode;
}

class SchedulerTime {
  DateTime localDateTime;
  String timeOfDay;

  String dayOfWeek;
  String dayOfMonth;

  bool isSelected = false;

  SchedulerTime(this.localDateTime) {
    timeOfDay = DateUtils.formatDate(localDateTime, 'jm');
    dayOfWeek = DateUtils.formatDate(localDateTime, 'EEEEE');
    dayOfMonth = DateUtils.formatDate(localDateTime, 'dd');
  }

  bool is8amLocally() {
    return localDateTime.hour >= 8;
  }

  @override
  bool operator ==(o) => o is SchedulerTime && timeOfDay == o.timeOfDay
      && dayOfMonth == o.dayOfMonth;

  @override
  int get hashCode => (timeOfDay).hashCode;
}

class SchedulerDateSlot {
  DateTime start;
  DateTime end;

  String semanticDayOfWeek;
  String semanticMonth;
  String dayOfWeek;
  String dayOfMonth;
  String month;
  String shortMonth;


  SchedulerDateSlot(DateTime _start, DateTime _end) {
    start = _start?.toLocal();
    end = _end?.toLocal();

    semanticDayOfWeek = DateUtils.formatDate(start, 'EEEE');
    semanticMonth = DateUtils.formatDate(start, 'MMMM');
    dayOfWeek = DateUtils.formatDate(start, 'EEE');
    dayOfMonth = DateUtils.formatDate(start, 'dd');
    month = DateUtils.formatDate(start, 'MM');
    shortMonth = DateUtils.formatDate(start, 'MMM');
  }

  @override
  bool operator ==(o) =>
      o is SchedulerDateSlot &&
          start.year == o.start.year &&
          start.month == o.start.month &&
          start.day == o.start.day;

  @override
  int get hashCode =>
      (start.year + start.month + start.day).hashCode;
}

class SchedulerTimeSlot {
  DateTime start;
  DateTime end;

  String timeOfDay;
  String endTimeOfDay;
  String dayOfWeek;
  String dayOfMonth;

  SchedulerTimeSlot(DateTime _start, DateTime _end) {
    start = _start?.toLocal();
    end = _end?.toLocal();

    timeOfDay = DateUtils.formatDate(start, 'jm');
    endTimeOfDay = DateUtils.formatDate(end, 'jm');
    dayOfWeek = DateUtils.formatDate(start, 'EEE');
    dayOfMonth = DateUtils.formatDate(start, 'dd');
  }

  @override
  bool operator ==(o) => o is SchedulerTimeSlot &&
      start.year == o.start.year && end.year == o.end.year &&
      start.month == o.start.month && end.month == o.end.month &&
      start.day == o.start.day && end.day == o.end.day &&
      timeOfDay == o.timeOfDay && endTimeOfDay == o.endTimeOfDay;

  @override
  int get hashCode => ("${start.year} + ${start.month} + ${start.day} + $timeOfDay").hashCode;
}
