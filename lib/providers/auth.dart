import 'dart:async';
import '../models/response.dart';
import 'net.dart';
import 'app.dart';

enum userLog {
    LOGGED_IN,
    LOGGED_OUT
}

class Authentication{

    NetworkUtil netUtils = new NetworkUtil();
    static final loginURL = AppProvider().baseURL + "/user/signup.json";

    Future<ResponseService> authenticate(String email, String password) async{
        return netUtils.post(loginURL, body:{
              "user[email]": email,
              "user[password]": password
        }).then((dynamic response){
            if(response["type"] == "success"){
                return ResponseService.fromJson(response);
            } else {
                return ResponseService.fromJson(response); 
            }
        });
    }
}