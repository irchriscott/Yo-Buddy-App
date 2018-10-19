import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart';

class HelperProvider{

    String formatPrice(int value){
        return NumberFormat.compact().format(value);
    }

    String formatDateTime(dynamic datetime){
        var time = DateTime.parse(datetime);
        var now = DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60);
        var date = time.millisecondsSinceEpoch ~/ (1000 * 60);
        var ago = DateTime.now().subtract(Duration(minutes: now - date));
        TimeAgo timeAgo = TimeAgo();
        return timeAgo.format(ago);
    }

    String formatDateTimeString(dynamic datetime){
        return DateFormat("EE, MMM d, yyyy 'at' h:mma").format(DateTime.parse(datetime));
    }

    String checkJsonURL(String url){
        if(url.endsWith(".json")){ return url; }
        else { return url + ".json"; }
    }
}