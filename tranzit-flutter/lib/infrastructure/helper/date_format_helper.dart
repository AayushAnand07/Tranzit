

import 'package:intl/intl.dart';

 class DateTimeFormatHelper{

static  String formatTime(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return DateFormat.jm().format(dt);
  }

static String formatTripDuration(String departureIso, String arrivalIso) {
  final departure = DateTime.tryParse(departureIso);
  final arrival = DateTime.tryParse(arrivalIso);

  if (departure == null || arrival == null) return '';

  final duration = arrival.difference(departure);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  final formattedDeparture = DateFormat.jm().format(departure.toLocal());
  final formattedArrival = DateFormat.jm().format(arrival.toLocal());

  return '${hours}h ${minutes}m';
}


}