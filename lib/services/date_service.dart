import 'package:intl/intl.dart';

class DateService {
  Map getWeekCountMap(int to, int from) {
    bool past = to < from;

    Duration dd = DateTime.fromMillisecondsSinceEpoch(from).difference(
      DateTime.fromMillisecondsSinceEpoch(to),
    );

    double days = dd.inDays.abs().toDouble();
    double weekCount = days / 7;

    return {
      "weeks": int.parse(weekCount.toStringAsFixed(0)),
      "past": past,
      "daysInt": dd.inDays.abs(),
      "seconds": dd.inSeconds.abs(),
      "days": days,
    };
  }

  String getCoolTime(int milliseconds) {
    final now = DateTime.now();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    DateTime guy = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    String day =
        now.day == guy.day && now.month == guy.month && now.year == guy.year
            ? "Today"
            : yesterday.day == guy.day &&
                    yesterday.month == guy.month &&
                    yesterday.year == guy.year
                ? "Yesterday"
                : tomorrow.day == guy.day &&
                        tomorrow.month == guy.month &&
                        tomorrow.year == guy.year
                    ? "Tomorrow"
                    : dateFromMilliseconds(milliseconds);

    String time = timeIn24Hours(milliseconds);

    return "$day at $time";
  }

  datewithoutFirstWords(int milliseconds) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    String rest = DateFormat.yMMMd().format(dt);

    return rest;
  }

  String dateFromMilliseconds(int milliseconds) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    String day = DateFormat.E().format(dt);
    String rest = DateFormat.yMMMd().format(dt);

    String concat = "$day $rest";
    return concat;
  }

  int convertMillisecondsToNightCount(int milliseconds) {
    double dd = milliseconds / (24 * 60 * 60 * 1000);

    return dd.toInt();
  }

  String dateInNumbers(int milliseconds) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    String formattedTime = DateFormat('EEEE d LLLL, y').format(dt);

    return formattedTime;
  }

  String timeIn24Hours(int milliseconds) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    String formattedTime = DateFormat('HH:mm').format(dt);

    return formattedTime;
  }

  String monthInText(int milliseconds) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    String formattedTime = DateFormat('LLLL').format(dt);

    return formattedTime;
  }

  String dayNumberInText(int milliseconds) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    String formattedTime = DateFormat('d').format(dt);

    return formattedTime;
  }
}
