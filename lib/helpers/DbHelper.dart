import 'dart:async';
import 'dart:io' as io;
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truptiboppo/models/News.dart';
//import 'package:flutter_crud/model/employee.dart';

class DBHelper {
  static final dbname = "newsdb.db";
  static final dbversion = 1;
  static final tablename = "News";

  static Database? _db;




  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initiateDatabase();
    return _db;
  }

  initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, dbname);
    return await openDatabase(path, version: dbversion, onCreate: _onCreate);
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "newsdb.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE News(author TEXT, title TEXT, url TEXT, urlimage TEXT,publishedat TEXT )");
    print("Created tables");
  }

  void saveNews(News news) async {
    var dbClient = await db;
    print("Added News");
    await dbClient!.transaction((txn) async {
     return await txn.rawQuery('INSERT INTO News(author, title, url, urlimage, publishedat) VALUES(?,?,?,?,?)',[news.author,news.title,news.url,news.urlimage,news.publishedat]);

    });
  }

  Future<List<News>> getNews() async {
    var dbClient = await db;
    List<Map> list = await dbClient!.rawQuery('SELECT * FROM News');
    List<News> news = [];
    for (int i = 0; i < list.length; i++) {
      news.add(new News(author:list[i]["author"],title: list[i]["title"], url:list[i]["url"], urlimage:list[i]["urlimage"], publishedat: list[i]["publishedat"], ));
    }
    print("News fetched");
    print(news.length);
    return news;
  }



  Future<int> getNewsCount() async {
    Database? db = await this.db;
    var result = 0;
    result=Sqflite.firstIntValue(
        await db!.rawQuery("SELECT COUNT (*) FROM News")
    )!;
    return result;
  }




  Future close() async {
    await _db!.close();
  }





}