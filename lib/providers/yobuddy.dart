import 'dart:async';
import 'app.dart';
import 'dart:convert';
import 'net.dart' as net;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buddyapp/models/item.dart';
import 'package:buddyapp/models/response.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/models/comment.dart';
import 'package:buddyapp/models/category.dart';
import 'package:buddyapp/models/borrow.dart';

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
    }

    void _saveBorrowingInSharedPreferences(String borrowings) async{
        prefs = await SharedPreferences.getInstance();
        prefs.setString("borrowings", borrowings);
    }

    Future<List<Borrow>> getBorrowing(String sessionToken) async{
        return net.NetworkUtil().get(
            Uri.encodeFull(AppProvider().baseURL + "/session/borrowing.json?token=$sessionToken")
        ).then((response){
             this._saveBorrowingInSharedPreferences(json.encode(response));
             List data = response.toList();
             List<Borrow> borrowings = List<Borrow>();
             data.forEach((borrow){
                 borrowings.add(Borrow.fromJson(borrow));
             });
             return borrowings;
        });
    }

    Future<List<Borrow>> getBorrowingsInPreferences() async{
        prefs  = await SharedPreferences.getInstance();
        var borrowingsJson = prefs.getString("borrowings");
        if(borrowingsJson != null){
            List borrowingsData = JsonDecoder().convert(borrowingsJson).toList();
            List<Borrow> borrowings = [];
            borrowingsData.forEach((borrow){
                borrowings.add(Borrow.fromJson(borrow));
            });
            return borrowings;
        }
        return null;
    }

    void _saveBorrowMessageInSharedPreferences(int borrowID, String messages) async{
        prefs = await SharedPreferences.getInstance();
        prefs.setString("borrow_messages_$borrowID", messages);
    }

    Future<List<BorrowMessage>> getBorrowMessages(int borrowID, String url, String sessionToken) async{
        return net.NetworkUtil().get(AppProvider().baseURL + url + "?token=$sessionToken").then((response){
            this._saveBorrowMessageInSharedPreferences(borrowID, json.encode(response));
            List data = response.toList();
            List<BorrowMessage> messages = List<BorrowMessage>();
            data.forEach((message){
                messages.add(BorrowMessage.fromJson(message));
            });
            return messages;
        });
    }

    Future<List<BorrowMessage>> getBorrowMessagesInSharedPreferences(int borrowID) async{
        prefs  = await SharedPreferences.getInstance();
        var messagesJson = prefs.getString("borrow_messages_$borrowID");
        if(messagesJson != null){
            List messagesData = JsonDecoder().convert(messagesJson).toList();
            List<BorrowMessage> borrowings = [];
            messagesData.forEach((borrow){
                borrowings.add(BorrowMessage.fromJson(borrow));
            });
            return borrowings;
        }
        return null;
    }

}