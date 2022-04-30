import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notes_app/createnotepage.dart';
import 'package:notes_app/databaseclass.dart';
import 'package:notes_app/editpage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

var lighttheme = ThemeData(
    brightness: Brightness.light,
    textTheme: TextTheme(bodyText2: TextStyle(color: Colors.black)));
var darktheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: TextTheme(bodyText2: TextStyle(color: Colors.white)));

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
  bool searchstatus = false;
  List searchlist = [];
  bool switchmode = true;

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
        ? MaterialApp(
            theme: switchmode ? darktheme : lighttheme,
            home: Scaffold(
              backgroundColor: switchmode ? Colors.black : Colors.white,
              appBar: searchstatus
                  ? AppBar(
                      backgroundColor: Colors.amberAccent,
                      title: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)),
                            contentPadding: EdgeInsets.all(5),
                            hintText: "Search here",
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    searchstatus = false;
                                  });
                                },
                                icon: Icon(Icons.close))),
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              searchlist = [];
                              for (int i = 0; i < viewnote.length; i++) {
                                if (viewnote[i]['title']
                                    .toString()
                                    .toLowerCase()
                                    .contains(value.toString().toLowerCase())) {
                                  searchlist.add(viewnote[i]);
                                }
                              }
                            } else {
                              setState(() {
                                searchlist = viewnote;
                              });
                            }
                          });
                        },
                      ),
                    )
                  : AppBar(
                      backgroundColor: Colors.amberAccent,
                      title: Text(
                        "Notes",
                        style: TextStyle(color: Colors.black),
                      ),
                      actions: [
                        FlatButton(
                            onPressed: () {
                              setState(() {
                                searchstatus = true;
                              });
                            },
                            child: Text(
                              "SEARCH",
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.end,
                            )),
                        Switch(
                          activeColor: Colors.black,
                          inactiveThumbColor: Colors.white,
                          value: switchmode,
                          onChanged: (value) {
                            setState(() {
                              switchmode = value;
                            });
                          },
                        )
                      ],
                    ),
              body: RefreshIndicator(
                color: Colors.black,
                onRefresh: viewdata,
                child: ListView.builder(
                  itemCount: searchstatus ? searchlist.length : viewnote.length,
                  itemBuilder: (context, index) {
                    Map map =
                        searchstatus ? searchlist[index] : viewnote[index];
                    return ListTile(
                      contentPadding: EdgeInsets.all(5),
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return editpg(viewnote[index], db!);
                          },
                        ));
                      },
                      title: Text(
                        "${map['title']}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                              builder: (context) {
                                return editpg(viewnote[index], db!);
                              },
                            ));
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                                onTap: () {},
                                child: Text('Edit'),
                                value: 'edit'),
                            PopupMenuItem(
                                onTap: () {
                                  id = viewnote[index]['id'];
                                  Databasehelper().deletedata(db!, id!);
                                  setState(() {});
                                },
                                child: Text('Delete'),
                                value: 'delete'),
                            PopupMenuItem(
                                onTap: () {
                                  FlutterClipboard.copy(
                                          '${viewnote[index]['title']}\n${viewnote[index]['notes']}')
                                      .then((value) {
                                    Fluttertoast.showToast(
                                        msg: "Copied",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  });
                                },
                                child: Text('Copy'),
                                value: 'copy'),
                            PopupMenuItem(
                                onTap: () {
                                  Share.share(
                                      '${viewnote[index]['title']}\n${viewnote[index]['notes']}');
                                },
                                child: Text('Share'),
                                value: 'share'),
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
            ),
          )
        : Center(
            child: CircularProgressIndicator(
            color: Colors.black,
          ));
  }
}
