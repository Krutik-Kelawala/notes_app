import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Databasehelper {
  Future<Database> Getdatabase() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'notes.db');

    // open the database
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'Create table Notesapp (id integer primary key autoincrement, title Text , notes Text)');
    });
    return database;
  }

  Future<void> insertdata(String title, String note, Database insertdb) async {
    String insertqry =
        "insert into Notesapp (title,notes) values ('$title','$note')";
    int insertcnt = await insertdb.rawInsert(insertqry);
    print("insert==$insertcnt");
  }

  Future<List<Map>> viewdata(Database viewdatabase) async {
    String viewqry = "Select * from Notesapp";
    List<Map> viewlist = await viewdatabase.rawQuery(viewqry);

    print("viewdata==${viewlist}");
    return viewlist;
  }

  Future<void> deletedata(Database deletedatabase, int deleteid) async {
    String deleteqry = "Delete from Notesapp where id = '${deleteid}'";
    int delete = await deletedatabase.rawDelete(deleteqry);

    print("delete==${delete}");
  }

  Future<void> updatedata(String notetitle, String enternote,
      Database updatedatabase, int updateid) async {
    String updateqry =
        "update Notesapp set title = '${notetitle}' , notes = '${enternote}' where id = '${updateid}'";

    int update = await updatedatabase.rawUpdate(updateqry);
    print("update==${update}");
  }
}

class ThemeClass{

  static ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue,
      )
  );

  static ThemeData darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.dark(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
      )
  );
}


