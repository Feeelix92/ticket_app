import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_app/widgets/bold_styled_text.dart';
import '../colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final CollectionReference _users =
  FirebaseFirestore.instance.collection('users');

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {

      _firstNameController.text = documentSnapshot['firstName'];
      _lastNameController.text = documentSnapshot['lastName'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                    labelText: 'Vorname',
                    fillColor: accentColor2,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                    labelText: 'Nachname',
                    fillColor: accentColor2,
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                  onPressed: () async {
                    final String firstName = _firstNameController.text.trim();
                    final String lastName = _lastNameController.text.trim();

                    if (firstName.isNotEmpty && lastName.isNotEmpty) {

                      await _users
                          .doc(documentSnapshot!.id)
                          .update({"firstName": firstName, "lastName": lastName});
                      _firstNameController.text = '';
                      _lastNameController.text = '';
                      Navigator.of(context).pop();
                    }

                    _storeLocal(firstName, lastName);
                  },
                  child: const Text('Update'),
                )
              ],
            ),
          );
        });
  }

  _storeLocal(String firstName, String lastName) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: StreamBuilder(
        stream: _users.where("authId", isEqualTo: user.uid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];
                return SingleChildScrollView(
                  child: Column(
                    children:[
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: const Icon(
                              Icons.person,
                              size: 80.0,
                            color: Color(0xff1b998b),
                          ),
                        ),
                      ),
                      BoldStyledText(text: '${documentSnapshot["firstName"]} ${documentSnapshot['lastName']}'),
                      const SizedBox(height: 20),
                      Text(documentSnapshot['email']),
                      const SizedBox(height: 10),
                      Text(documentSnapshot['birthdate']),
                      ElevatedButton(
                        onPressed: () => _update(documentSnapshot),
                        child: const Text('Profil bearbeiten'),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
