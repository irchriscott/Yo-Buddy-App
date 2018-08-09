import 'dart:async';
import 'app.dart';
import 'dart:convert';
import 'net.dart' as net;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';
import '../models/response.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../models/category.dart';

class YoBuddyService{

    SharedPreferences prefs;

    Future<ResponseService> followUser(int userID, int sessionID, String sessionToken){
        return net.NetworkUtil().post(
            Uri.encodeFull(AppProvider().baseURL + "/user/" + sessionID.toString() + "/follow.json?token=" + sessionToken),
            body: {
              "follow[following_id]": userID.toString(),
              "follow[session]": sessionID.toString()
            }
        ).then((response){
            return ResponseService.fromJson(response);
        });
    }

    Future<List<Item>> getHomeItems(){
        return net.NetworkUtil().get(
            Uri.encodeFull(AppProvider().baseURL + "/items.json")
        ).then((response){
            this._saveItemsInPreferences(json.encode(response));
            List data = response.toList();
            List<Item> items = new List<Item>();
            data.forEach((item){
                items.add(Item.fromJson(item));
            });
            return items;
        });
    }

    void _saveItemsInPreferences(String items)async{
        prefs = await SharedPreferences.getInstance();
        prefs.setString("home_items", items);
    }

    Future<List<Item>> getSharedHomeItems() async{
        prefs  = await SharedPreferences.getInstance();
        var itemsJson = prefs.getString("home_items");
        if(itemsJson != null){
            List itemsData = JsonDecoder().convert(itemsJson).toList();
            List<Item> items = [];
            itemsData.forEach((item){
                items.add(Item.fromJson(item));
            });
            return items;
        }
        return null;
    }

    Future<Item> getSingleItem(String username, String uuid, int itemID){
        return net.NetworkUtil().get(
            Uri.encodeFull(AppProvider().baseURL + "/item/" + username + "/enc-dt-" + uuid + "-"+ itemID.toString() + ".json")
        ).then((response){
            return Item.fromJson(response);
        });
    }

    Future<ResponseService> likeItem(Item item, User session, String sessionToken){
        return net.NetworkUtil().post(
            Uri.encodeFull(AppProvider().baseURL + "/item/" + item.id.toString() + "/like.json?token=" + sessionToken),
            body: {
                "like[item_id]": item.id.toString(),
                "like[session]": session.id.toString()
            }
        ).then((response){
            return ResponseService.fromJson(response);
        });
    }

    void _saveCommentsInSharedPreferences(int itemID, String comments) async{
        prefs = await SharedPreferences.getInstance();
        prefs.setString("item_comments_$itemID", comments);
    }
    
    Future<List<Comment>> getItemComments(int itemID){
        return net.NetworkUtil().get(
            Uri.encodeFull(AppProvider().baseURL + "/items/" + itemID.toString() + "/comments.json")
        ).then((response){
            this._saveCommentsInSharedPreferences(itemID, json.encode(response));
            List data = response.toList();
            List<Comment> comments = [];
            data.forEach((comment){
                comments.add(Comment.fromJson(comment));
            });
            return comments;
        }); 
    }

    Future<List<Comment>> getItemCommentsInPreferences(int itemID) async{
        prefs  = await SharedPreferences.getInstance();
        var commentsJson = prefs.getString("item_comments_$itemID");
        if(commentsJson != null){
            List commentsData = JsonDecoder().convert(commentsJson).toList();
            List<Comment> comments = [];
            commentsData.forEach((comment){
                comments.add(Comment.fromJson(comment));
            });
            return comments;
        }
        return null;
    }

    void _saveCategoriesInSharedPreferences(String categories) async{
        prefs = await SharedPreferences.getInstance();
        prefs.setString("categories", categories);
    }

    Future<List<Category>> getAllCategories() async{
        return net.NetworkUtil().get(
            Uri.encodeFull(AppProvider().baseURL + "/categories/all.json")
        ).then((response) {
            this._saveCategoriesInSharedPreferences(json.encode(response));
            List data = response.toList();
            List<Category> categories = List<Category>();
            data.forEach((category){
               categories.add(Category.fromJson(category));
            });
            return categories;
        });
        return null;
    }
}