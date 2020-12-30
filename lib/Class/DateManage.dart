import 'package:intl/intl.dart';

class DateManage{
  String datetimeFormat(String check, String date) {
    var datetimeFromDB = DateTime.parse(date);
    if(check == "full"){
      return DateFormat('d MMM yyyy | HH:mm').format(datetimeFromDB);
    }else if(check == "day"){
      return DateFormat('d').format(datetimeFromDB);
    }else if(check == "month"){
      return DateFormat('MMM').format(datetimeFromDB);
    }else if(check == "year"){
      return DateFormat('yyyy').format(datetimeFromDB);
    }else if(check == "time"){
      return DateFormat('HH:mm').format(datetimeFromDB);
    }else{
      return "Wrong input parameter.";
    }
  }
}