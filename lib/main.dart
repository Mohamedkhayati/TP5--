import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'util/dbuse.dart';
import 'models/scol_list.dart';
import 'ui/students_screen.dart';
import 'ui/scol_list_dialog.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
void main() {
  // التهيئة للـ desktop أو web
  if (!kIsWeb) {
    // إذا كان app desktop أو test
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classes List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ShList(),
    );
  }
}

class ShList extends StatefulWidget {
  @override
  _ShListState createState() => _ShListState();
}

class _ShListState extends State<ShList> {
  List<ScolList> scolList = [];
  DbUse helper = DbUse();
  late ScolListDialog dialog;

  @override
  void initState() {
    super.initState();
    dialog = ScolListDialog();
    helper.openDb(); // <-- أضف هذي السطر هنا
  }


  @override
  Widget build(BuildContext context) {
    showData();
    return Scaffold(
      appBar: AppBar(title: Text('Classes list')),
      body: ListView.builder(
        itemCount: scolList.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(scolList[index].nomClass + index.toString()),
            onDismissed: (direction) {
              String strName = scolList[index].nomClass;
              helper.deleteList(scolList[index]);
              setState(() {
                scolList.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$strName deleted")));
            },
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentsScreen(scolList[index])),
                );
              },
              title: Text(scolList[index].nomClass),
              leading: CircleAvatar(child: Text(scolList[index].codClass.toString())),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => dialog.buildDialog(context, scolList[index], false),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? refresh = await showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialog.buildDialog(context, ScolList(0, '', 0), true),
          );
          if (refresh == true) {
            setState(() {
              showData(); // refresh بعد الحفظ
            });
          }
        },
        child: Icon(Icons.add),
      ),

    );
  }

  Future showData() async {
    await helper.openDb();
    scolList = await helper.getClasses();
    setState(() {
      scolList = scolList;
    });
  }

}
