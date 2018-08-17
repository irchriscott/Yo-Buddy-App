import 'dart:async';
import 'package:buddyapp/providers/net.dart' as net;
import 'package:buddyapp/providers/app.dart';
import 'item.dart';

class Currency{

    String name;
    String abbr;

    Currency({this.name, this.abbr});

    List<Currency> getCurrencies(){
        List<Currency> currencies = new List<Currency>();
        currencies.add(Currency(name: "Ugandian Shilling", abbr: "UGX"));
        currencies.add(Currency(name: "Franc Congolais", abbr: "FC"));
        currencies.add(Currency(name: "United States Dollars", abbr: "USD"));
        return currencies;
    }
}

class Per{

    String per;
    String description;
    Per({this.per, this.description});

    String get perName => "Per " + this.per;

    List<Per> getPers(){
        List<Per> pers = new List();
        pers.add(Per(per: "Hour", description: "60 minutes"));
        pers.add(Per(per: "Day", description: "24 hours, 1440 minutes"));
        pers.add(Per(per: "Week", description: "7 days, 168 hours"));
        pers.add(Per(per: "Month", description: "30 days, 4 weeks"));
        pers.add(Per(per: "Year", description: "12 months, 360 days"));
        return pers;
    }
}

class Available{

    String from;
    String to;
    int count;

    Available({this.from, this.to, this.count});

    factory Available.fromJson(Map<String, dynamic> json){
        return Available(
            from: json['from'],
            to: json['to'],
            count: json['count']
        );
    }

    Future<List<Available>> getItemAvailable(Item item){
        return net.NetworkUtil().get(
            Uri.encodeFull(AppProvider().baseURL + "/item/${item.user.username}/enc-dt-${item.uuid}-${item.id}/available.json")
        ).then((response){
            List data = response.toList();
            List<Available> available = [];
            data.forEach((avail){
                available.add(Available.fromJson(avail));
            });
            return available;
        });
        return null;
    }
}