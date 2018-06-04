import 'dart:async';
import 'app.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';
import 'net.dart' as net;

class YoBuddyService{

    SharedPreferences prefs;

    Future<List<Item>> getHomeItems(){
        return net.NetworkUtil().get(
            Uri.encodeFull(AppProvider().baseURL + "/items.json")
        ).then((response){
            net.NetworkUtil().saveDataInPreferences("home_items", json.encode(response));
            List data = response.toList();
            List<Item> items = new List<Item>();
            data.forEach((item){
                items.add(Item.fromJson(item));
            });
            return items;
        });
    }

    Future<List<Item>> getSharedHomeItems() async{
        prefs  = await SharedPreferences.getInstance();
        var itemsJson = prefs.getString("home_items");
        List itemsData = JsonDecoder().convert(itemsJson).toList();
        List<Item> items = new List<Item>();
        itemsData.forEach((item){
            items.add(Item.fromJson(item));
        });
        return items;
    }

    Future<Item> getSingleItem(int itemID){
        return net.NetworkUtil().get(
            Uri.encodeFull(AppProvider().baseURL + "/items/"+ itemID.toString() + ".json")
        ).then((response){
            return Item.fromJson(response);
        });
    }
}