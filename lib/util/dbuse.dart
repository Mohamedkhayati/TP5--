import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/scol_list.dart';
import '../models/list_etudiants.dart';

class DbUse {
  final int version = 1;
  Database? db;

  static final DbUse _dbHelper = DbUse._internal();
  DbUse._internal();
  factory DbUse() => _dbHelper;

  Future<Database> openDb() async {
    if (db == null) {
      db = await openDatabase(
        join(await getDatabasesPath(), 'scol.db'),
        onCreate: (database, version) async {
          await database.execute(
              'CREATE TABLE classes(codClass INTEGER PRIMARY KEY, nomClass TEXT, nbreEtud INTEGER)');
          await database.execute('''
            CREATE TABLE etudiants(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              codClass INTEGER,
              nom TEXT,
              prenom TEXT,
              datNais TEXT,
              FOREIGN KEY(codClass) REFERENCES classes(codClass)
            )
          ''');
        },
        version: version,
      );
    }
    return db!;
  }

  Future testDb() async {
    db = await openDb();
    await db?.execute('INSERT OR REPLACE INTO classes(codClass,nomClass,nbreEtud) VALUES (101, "DSI31", 28)');
    await db?.execute('INSERT OR REPLACE INTO etudiants(id,codClass,nom,prenom,datNais) VALUES (2, 101, "Ben Foulen", "Foulen", "05/10/2023")');
    List lists = await db!.rawQuery('select * from classes');
    List items = await db!.rawQuery('select * from etudiants');
    print(lists.isNotEmpty ? lists[0].toString() : 'no classes');
    print(items.isNotEmpty ? items[0].toString() : 'no etudiants');
  }

  Future<int> insertClass(ScolList list) async {
    await openDb();
    int codClass = await db!.insert(
      'classes',
      list.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return codClass;
  }

  Future<int> insertEtudiants(ListEtudiants etud) async {
    await openDb();
    int id = await db!.insert(
      'etudiants',
      etud.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<ScolList>> getClasses() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await db!.query('classes');
    return List.generate(maps.length, (i) {
      return ScolList(
        maps[i]['codClass'],
        maps[i]['nomClass'],
        maps[i]['nbreEtud'],
      );
    });
  }

  Future<List<ListEtudiants>> getEtudiants(int code) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
    await db!.query('etudiants', where: 'codClass = ?', whereArgs: [code]);
    return List.generate(maps.length, (i) {
      return ListEtudiants(
        maps[i]['id'],
        maps[i]['codClass'],
        maps[i]['nom'],
        maps[i]['prenom'],
        maps[i]['datNais'],
      );
    });
  }

  Future<int> deleteList(ScolList list) async {
    await openDb();
    return await db!.delete('classes', where: 'codClass = ?', whereArgs: [list.codClass]);
  }

  Future<int> deleteStudent(ListEtudiants student) async {
    await openDb();
    return await db!.delete('etudiants', where: 'id = ?', whereArgs: [student.id]);
  }

  // optional update methods
  Future<int> updateClass(ScolList list) async {
    await openDb();
    return await db!.update('classes', list.toMap(), where: 'codClass = ?', whereArgs: [list.codClass]);
  }

  Future<int> updateStudent(ListEtudiants student) async {
    await openDb();
    return await db!.update('etudiants', student.toMap(), where: 'id = ?', whereArgs: [student.id]);
  }
}
