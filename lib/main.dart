import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class Etudiant {
  final String id;
  final String nom;
  final String dateDeNaissance;
  final String adresse;
  final List<int> notes;

  Etudiant({
    required this.id,
    required this.nom,
    required this.dateDeNaissance,
    required this.adresse,
    required this.notes,
  });

  factory Etudiant.fromJson(Map<String, dynamic> json) {
    return Etudiant(
      id: json['id'].toString(),
      nom: json['nom'],
      dateDeNaissance: json['dateDeNaissance'],
      adresse: json['adresse'],
      notes: List<int>.from(json['notes']),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Etudiant> students = [];
  String selectedDateOfBirth = "";
  String filteredName = "";
  final TextEditingController nomController = TextEditingController();
  final TextEditingController dateDeNaissanceController =
      TextEditingController();
  final TextEditingController villeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  getData() async {
    try {
      var response = await Dio().get("http://192.168.1.5:3000/teste");
      var res = response.data;
      print("Response: $res");

      students.addAll(
          List.generate(res.length, (index) => Etudiant.fromJson(res[index])));

      print("Students: $students");
      setState(() {});
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void showExistingStudents() {
    setState(() {
      filteredName = "";
      selectedDateOfBirth = "";
    });
  }

  void showAddStudentForm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un étudiant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextFormField(
                controller: dateDeNaissanceController,
                decoration: const InputDecoration(
                    labelText: 'Date de naissance (jj/mm/aaaa)'),
              ),
              TextFormField(
                controller: villeController,
                decoration: const InputDecoration(labelText: 'Ville'),
              ),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                    labelText: 'Notes (séparées par des virgules)'),
              ),
              ElevatedButton(
                onPressed: () {
                  final nom = nomController.text;
                  final dateDeNaissance = dateDeNaissanceController.text;
                  final ville = villeController.text;
                  final notes = notesController.text
                      .split(',')
                      .map((note) => int.parse(note.trim()))
                      .toList();
                  addStudent(nom, dateDeNaissance, ville, notes);
                  Navigator.of(context).pop();
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> addStudent(
      String nom, String dateDeNaissance, String ville, List<int> notes) async {
    try {
      final response = await Dio().post("http://192.168.1.5:3000/teste", data: {
        'nom': nom,
        'dateDeNaissance': dateDeNaissance,
        'adresse': ville,
        'notes': notes,
      });

      if (response.statusCode == 200) {
        students.add(Etudiant(
          id: response.data['id'].toString(),
          nom: nom,
          dateDeNaissance: dateDeNaissance,
          adresse: ville,
          notes: notes,
        ));
        setState(() {});
      } else {
        print("Échec de la requête : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur : $e");
    }
  }

  void showUpdateStudentForm(Etudiant student) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier un étudiant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomController..text = student.nom,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextFormField(
                controller: dateDeNaissanceController
                  ..text = student.dateDeNaissance,
                decoration: const InputDecoration(
                    labelText: 'Date de naissance (jj/mm/aaaa)'),
              ),
              TextFormField(
                controller: villeController..text = student.adresse,
                decoration: const InputDecoration(labelText: 'Ville'),
              ),
              TextFormField(
                controller: notesController..text = student.notes.join(', '),
                decoration: const InputDecoration(
                    labelText: 'Notes (séparées par des virgules)'),
              ),
              ElevatedButton(
                onPressed: () {
                  final nom = nomController.text;
                  final dateDeNaissance = dateDeNaissanceController.text;
                  final ville = villeController.text;
                  final notes = notesController.text
                      .split(',')
                      .map((note) => int.parse(note.trim()))
                      .toList();
                  updateStudent(student.id, nom, dateDeNaissance, ville, notes);
                  Navigator.of(context).pop();
                },
                child: const Text('Modifier'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateStudent(String id, String nom, String dateDeNaissance,
      String ville, List<int> notes) async {
    try {
      final response =
          await Dio().put("http://192.168.1.5:3000/teste/$id", data: {
        'nom': nom,
        'dateDeNaissance': dateDeNaissance,
        'adresse': ville,
        'notes': notes,
      });

      if (response.statusCode == 200) {
        final index = students.indexWhere((student) => student.id == id);
        if (index != -1) {
          students[index] = Etudiant(
            id: id,
            nom: nom,
            dateDeNaissance: dateDeNaissance,
            adresse: ville,
            notes: notes,
          );
          setState(() {});
        }
      } else {
        print("Échec de la requête : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur : $e");
    }
  }

  void showDeleteStudentConfirmation(Etudiant student) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer un étudiant'),
          content: Text('Êtes-vous sûr de vouloir supprimer ${student.nom} ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                deleteStudent(student.id);
                Navigator.of(context).pop();
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteStudent(String id) async {
    try {
      final response = await Dio().delete("http://192.168.1.5:3000/teste/$id");

      if (response.statusCode == 200) {
        students.removeWhere((student) => student.id == id);
        setState(() {});
      } else {
        print("Échec de la requête : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Liste des étudiants'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: showExistingStudents,
              child: const Text('Afficher les étudiants existants'),
            ),
            ElevatedButton(
              onPressed: showAddStudentForm,
              child: const Text('Ajouter un étudiant'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Filtrer par nom'),
              onChanged: (value) {
                setState(() {
                  filteredName = value.toLowerCase();
                });
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Date de naissance (jj/mm/aaaa)'),
              onChanged: (value) {
                setState(() {
                  selectedDateOfBirth = value;
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final studentName = student.nom.toLowerCase();
                  if ((filteredName.isEmpty ||
                          studentName.contains(filteredName)) &&
                      (selectedDateOfBirth.isEmpty ||
                          student.dateDeNaissance == selectedDateOfBirth)) {
                    return ListTile(
                      title: Text(student.nom),
                      subtitle:
                          Text('Date de naissance: ${student.dateDeNaissance}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => showUpdateStudentForm(student),
                            child: const Text('Modifier'),
                          ),
                          TextButton(
                            onPressed: () =>
                                showDeleteStudentConfirmation(student),
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
