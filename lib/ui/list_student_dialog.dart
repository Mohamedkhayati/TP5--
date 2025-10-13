import 'package:flutter/material.dart';
import '../models/list_etudiants.dart';
import '../util/dbuse.dart';

class ListStudentDialog {
  final txtNom = TextEditingController();
  final txtPrenom = TextEditingController();
  final txtDatNais = TextEditingController();

  Widget buildAlert(BuildContext context, ListEtudiants student, bool isNew) {
    DbUse helper = DbUse();
    if (!isNew) {
      txtNom.text = student.nom;
      txtPrenom.text = student.prenom;
      txtDatNais.text = student.datNais;
    } else {
      txtNom.clear();
      txtPrenom.clear();
      txtDatNais.clear();
    }

    return AlertDialog(
      title: Text((isNew) ? 'New student' : 'Edit student'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(controller: txtNom, decoration: InputDecoration(hintText: 'Student Name')),
            TextField(controller: txtPrenom, decoration: InputDecoration(hintText: 'First name')),
            TextField(controller: txtDatNais, decoration: InputDecoration(hintText: 'Date naissance')),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('Save student'),
              onPressed: () async {
                student.nom = txtNom.text;
                student.prenom = txtPrenom.text;
                student.datNais = txtDatNais.text;
                if (isNew) {
                  await helper.insertEtudiants(student);
                } else {
                  await helper.updateStudent(student);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
