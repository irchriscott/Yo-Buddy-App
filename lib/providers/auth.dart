import 'dart:async';
import '../models/response.dart';
import 'net.dart';
import 'app.dart';
import 'session.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum userLog {
    LOGGED_IN,
    LOGGED_OUT
}

class Authentication{

    NetworkUtil netUtils = new NetworkUtil();
    static final loginURL = AppProvider().baseURL + "/user/signup.json";
    SharedPreferences prefs;

    Future<ResponseService> authenticate(String email, String password) async{
        return netUtils.post(loginURL, body:{
              "user[email]": email,
              "user[password]": password
        }).then((dynamic response){
            if(response["type"] == "success"){
                return DatabaseHelper().saveUser(User.fromJson(response["user"])).then((result){
                    this._saveUserInPreferences(json.encode(response["user"]), response["token"]);
                    if(result == 1){
                        return ResponseService.fromJson(response);
                    } else {
                        return ResponseService(type: "error", text: "An error has occured, Sorry!");
                    }
                });
            }
            return ResponseService.fromJson(response);
        });
    }

    Future<User> getSessionUser() async{
        prefs  = await SharedPreferences.getInstance();
        var user = prefs.getString("session");
        return User.fromJson(JsonDecoder().convert(user));
    }

    void _saveUserInPreferences(String session, String token) async{
        prefs = await SharedPreferences.getInstance();
        prefs.setString("session", session);
        if(token != null)
            prefs.setString("token", token);
    }

    void logoutUser() async{
        prefs = await SharedPreferences.getInstance();
        prefs.remove("session");
        DatabaseHelper().deleteUsers();
    }

    Future<int> getUserID() async {
        return this.getSessionUser().then((user) => user.id);
    }

    Future<String> getUserToken() async{
        prefs = await SharedPreferences.getInstance();
        return prefs.getString("token");
    }

    //Shall be called every time an action is performed
    void updateUserData(String token){
        netUtils.get(
            Uri.encodeFull("")
        ).then((response){
            DatabaseHelper().update(User.fromJson(response)).then((value){
                this._saveUserInPreferences(json.encode(response), null);
            });
        });
    }
}