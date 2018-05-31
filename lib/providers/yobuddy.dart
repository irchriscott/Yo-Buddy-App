import 'dart:async';
import 'app.dart';
import '../models/item.dart';
import 'net.dart' as net;

class YoBuddyService{

    Future<List<Item>> getHomeItems(){
        return net.NetworkUtil().get(
            Uri.encodeFull(AppProvider().baseURL + "/items.json")
        ).then((response){
            List data = response.toList();
            List<Item> items = new List<Item>();
            data.forEach((item){
                items.add(Item.fromJson(item));
            });
            return items;
        });
    }
}