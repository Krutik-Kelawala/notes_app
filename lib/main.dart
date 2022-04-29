import 'package:flutter/material.dart';
import 'package:notes_app/createnotepage.dart';
import 'package:notes_app/databaseclass.dart';
import 'package:notes_app/editpage.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MaterialApp(
    home: firstpage(),
  ));
}

class firstpage extends StatefulWidget {
  @override
  _firstpageState createState() => _firstpageState();
}

class _firstpageState extends State<firstpage> {
  bool apploadstatus = false;
  Database? db;
  List<Map> viewnote = [];
  int? id;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      apploadstatus = true;
    });
    viewdata();
  }

  Future<void> viewdata() {
    Databasehelper().Getdatabase().then((value) {
      setState(() {
        db = value;
      });
      Databasehelper().viewdata(db!).then((listmap) {
        setState(() {
          viewnote = listmap;
        });
      });
    });
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    double theheight = MediaQuery.of(context).size.height;
    double thewidth = MediaQuery.of(context).size.width;
    double statusbarheight = MediaQuery.of(context).padding.top;
    double navigatorbarheight = MediaQuery.of(context).padding.bottom;
    double appbarheight = kToolbarHeight;
    double thebodyheight =
        theheight - statusbarheight - appbarheight - navigatorbarheight;
    return apploadstatus
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.amberAccent,
              title: Text("Notes"),
              actions: [
                FlatButton(
                    onPressed: () {},
                    child: Text(
                      "SEARCH",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.end,
                    ))
              ],
            ),
            body: RefreshIndicator(
              onRefresh: viewdata,
              child: ListView.builder(
                itemCount: viewnote.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) {
                          return editpg(viewnote[index], db!);
                        },
                      ));
                    },
                    title: Text(
                      "${viewnote[index]['title']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) {
                              return editpg(viewnote[index], db!);
                            },
                          ));
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                              onTap: () {}, child: Text('Edit'), value: 'edit'),
                          PopupMenuItem(
                              onTap: () {
                                id = viewnote[index]['id'];
                                Databasehelper().deletedata(db!, id!);
                                setState(() {});
                              },
                              child: Text('Delete'),
                              value: 'delete'),
                        ];
                      },
                    ),
                    subtitle: Text(
                      "${viewnote[index]['notes']}",
                      maxLines: 3,
                    ),
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Colors.amberAccent,
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) {
                    return createnotepg();
                  },
                ));
              },
            ),
          )
        : Center(
            child: CircularProgressIndicator(
            color: Colors.black,
          ));
  }
}
