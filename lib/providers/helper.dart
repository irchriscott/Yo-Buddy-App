import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart';

class HelperProvider{

    String formatPrice(int value){
        var number = NumberFormat.compact();
        return number.format(value);
    }

    String formatDateTime(dynamic datetime){
        var time = DateTime.parse(datetime);
        var now = DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60);
        var date = time.millisecondsSinceEpoch ~/ (1000 * 60);
        var ago = DateTime.now().subtract(Duration(minutes: now - date));
        TimeAgo timeAgo = TimeAgo();
        return timeAgo.format(ago);
    }
}