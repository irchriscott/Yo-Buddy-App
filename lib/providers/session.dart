import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import '../models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
    static final DatabaseHelper _instance = new DatabaseHelper.internal();
    factory DatabaseHelper() => _instance;
    String tableName = "User";

    static Database _db;

    Future<Database> get db async {
        if(_db != null)
            return _db;
        _db = await initDb();
        return _db;
    }

    DatabaseHelper.internal();

    initDb() async {
        io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
        String path = join(documentsDirectory.path, "main.db");
        var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
        return theDb;
    }
    

    void _onCreate(Database db, int version) async {
        await db.execute("CREATE TABLE $tableName (id INTEGER PRIMARY KEY, name TEXT, username TEXT, email TEXT, country TEXT, town TEXT, image TEXT, gender TEXT, followers INTEGER, following INTEGER, url TEXT, items INTEGER, requests INTEGER, borrow INTEGER, favourites INTEGER)");
        print("Created tables");
    }

    Future<int> saveUser(User user) async {
        var dbClient = await db;
        int res = await dbClient.insert(tableName, user.toMap());
        return res;
    }

    Future<int> deleteUsers() async {
        var dbClient = await db;
        int res = await dbClient.delete(tableName);
        return res;
    }

    Future<bool> isLoggedIn() async {
        var dbClient = await db;
        var res = await dbClient.query(tableName);
        return res.length > 0 ? true : false;
    }

    Future<User> userData() async {
        var dbClient = await db;
        return await dbClient.query(tableName, limit: 1).then((result){
            if(result.length > 0){
                return User.fromMap(result.first);
            }
            return null;
        });
    }

    Future<int> update(User user) async {
        var dbClient = await db;
        return await dbClient.update(tableName, user.toMap(),
            where: "id = ?", whereArgs: [user.id]);
    }    

    Future close() async {
        var dbClient = await db;
        dbClient.close();
    }
}