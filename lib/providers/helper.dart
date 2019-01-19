import 'dart:math';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart';

class HelperProvider{

    String formatPriceNumber(int value){
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

    String formatPrice(int value){
        if(value > 1000000000000){
            return "${(value / 1000000000000).roundToDouble()} Tn";
        } else if(value > 1000000000){
            return "${(value / 1000000000).roundToDouble()} Bn";
        } else if(value > 1000000){
            return "${(value / 1000000).roundToDouble()} M";
        } else if(value > 1000){
            return "${(value / 1000).roundToDouble()} K";
        } else{
            return value.toString();
        }
    }

    String formatDateTimeString(dynamic datetime){
        return DateFormat("EE, MMM d, yyyy 'at' h:mma").format(DateTime.parse(datetime));
    }

    String checkJsonURL(String url){
        if(url.endsWith(".json")){ return url; }
        else { return url + ".json"; }
    }

    String randomString(int length){
        var chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        var result = '';
        for (var i = length; i > 0; --i) result += chars[(Random().nextInt(chars.length))];
        return result;
    }
}