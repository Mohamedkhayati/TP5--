import 'package:flutter/material.dart';
import '../util/dbuse.dart';
import '../models/scol_list.dart';

class ScolListDialog {
  final txtNomClass = TextEditingController();
  final txtNbreEtud = TextEditingController();

  Widget buildDialog(BuildContext context, ScolList list, bool isNew) {
    DbUse helper = DbUse();
    if (!isNew) {
      txtNomClass.text = list.nomClass;
      txtNbreEtud.text = list.nbreEtud.toString();
    } else {
      txtNomClass.clear();
      txtNbreEtud.clear();
    }

    return AlertDialog(
      title: Text((isNew) ? 'New Class' : 'Edit Class'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      content: SingleChildScrollView(
        child: Column(children: <Widget>[
          TextField(controller: txtNomClass, decoration: InputDecoration(hintText: 'Class Name')),
          TextField(controller: txtNbreEtud, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: 'Number of students')),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text('Save Class'),
            onPressed: () async {
              list.nomClass = txtNomClass.text;
              list.nbreEtud = int.tryParse(txtNbreEtud.text) ?? 0;

              if (isNew) {
                await helper.insertClass(list);
              } else {
                await helper.updateClass(list);
              }

              Navigator.pop(context, true); // نرجع true باش نعمل refresh
            },

          ),
        ]),
      ),
    );
  }
}
