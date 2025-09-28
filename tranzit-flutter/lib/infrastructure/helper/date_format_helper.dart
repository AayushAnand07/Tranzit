

import 'package:intl/intl.dart';

 class DateTimeFormatHelper{


   static String formatTime(String dateStr) {
     final dt = DateTime.tryParse(dateStr);
     if (dt == null) return dateStr;
     return DateFormat.jm().format(dt.toLocal());
   }

static String formatDate(String dateStr) {
  final dt = DateTime.tryParse(dateStr);
  if (dt == null) return dateStr;
  return DateFormat('MMM d, yyyy').format(dt);
}


   String formatDate_dMMyyyy(String isoDate) {
     DateTime date = DateTime.parse(isoDate);
     return DateFormat('d MMM yyyy').format(date);
   }


   static String getDateFromQR(String qrPayload) {
   List<String> parts = qrPayload.split('-');
   if (parts.length >= 6) {
     String isoDate = "${parts[parts.length-3]}-${parts[parts.length-2]}-${parts[parts.length-1]}";
   return formatDate(isoDate);
   }
   return '';
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