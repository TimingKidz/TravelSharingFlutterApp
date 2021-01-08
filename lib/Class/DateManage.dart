import 'package:intl/intl.dart';

import '../main.dart';

class DateManage{
  String datetimeFormat(String check, String date) {
    var datetimeFromDB = DateTime.parse(date);
    String locale = prefs.getString("lang");
    if(check == "full") {
      return DateFormat('d MMM yyyy | HH:mm', locale).format(datetimeFromDB);
    }else if(check == "date"){
      return DateFormat('d MMMM yyyy', locale).format(datetimeFromDB);
    }else if(check == "day"){
      return DateFormat('d', locale).format(datetimeFromDB);
    }else if(check == "month"){
      return DateFormat('MMM', locale).format(datetimeFromDB);
    }else if(check == "year"){
      return DateFormat('yyyy', locale).format(datetimeFromDB);
    }else if(check == "time"){
      return DateFormat('HH:mm', locale).format(datetimeFromDB);
    }else{
      return "Wrong input parameter.";
    }
  }
}