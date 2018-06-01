import 'package:intl/intl.dart';

class DateTimeHelper{
    
    DateTime _time;
    DateTimeHelper(this._time);
    var _now = DateTime.now();

    int get offset => this.getOffset().inSeconds;
    String get datetime => this.getDateTime();

    Duration getOffset(){
        return  _now.difference(_time.toLocal());
    }

    String getDateTime(){
        if(offset < 60){
            return "Just Now";
        } else if (offset >= 60 && offset < 3600){
            return this.getOffset().inMinutes.toString() + this.plurialize(this.getOffset().inMinutes, "minute");
        } else if (offset >= 3600 && offset < 86400){
            return this.getOffset().inHours.toString() + this.plurialize(this.getOffset().inHours, "hour");
        } else if (offset >= 86400 && offset< 604800){
            return this.getOffset().inDays.toString() + this.plurialize(this.getOffset().inDays, "hour");
        } else if (offset>= 604800 && offset< 31104000 ){
            return DateFormat("EEE, MMM d 'at' h:mm a").format(_time.toLocal());
        } else {
            return DateFormat("EEE, MMM d yyyy 'at' h:mm a").format(_time.toLocal());
        }
    }

    String plurialize(int count, String text){
        String start = " ";
        return start + (count > 1 ? text + "s ago" : text + "ago");
    } 
}