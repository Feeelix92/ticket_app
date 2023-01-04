import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticket_app/colors.dart';
import 'package:intl/intl.dart';


class RegisterScreen extends StatefulWidget {
  final VoidCallback showLoginScreen;
  const RegisterScreen({Key? key, required this.showLoginScreen}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final TextEditingController _dateInput = TextEditingController();

  @override
  void initState() {
    _dateInput.text = ""; //set the initial value of text field
    super.initState();
  }

  Future signUp() async {
    if(passwordConfirmed()){
      //create User
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      //add Details
      addUserDetails(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        int.parse(_dateInput.text),
      );
    }
  }

  Future addUserDetails(String firstName, String lastName, String email, int age) async{
    await FirebaseFirestore.instance.collection('users').add({
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'email': email,
    });
  }

  bool passwordConfirmed() {
    if(_passwordController.text.trim() == _confirmPasswordController.text.trim()){
      return true;
    } else{
      return false;
    }
  }

  _selectBirthDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now()
    );

    if(pickedDate != null ){
      String formattedDate = DateFormat('dd.MM.yyyy').format(pickedDate);
      setState(() {
        _dateInput.text = formattedDate;
      });
    }else{
      print("Kein Datum gewählt");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Registrieren',
                    style: TextStyle(
                      fontSize: 52
                    ),
                  ),
                  const SizedBox(height: 10),

                  //firstName
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        hintText: 'Vorname',
                        fillColor: accentColor2,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //lastName
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        hintText: 'Nachname',
                        fillColor: accentColor2,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //age
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child:TextField(
                        controller: _dateInput, //editing controller of this TextField
                        decoration: InputDecoration(
                          icon: const Icon(Icons.calendar_month), //icon of text field
                          hintText: "Geburtsdatum",
                          filled: true,
                          fillColor: accentColor2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: secondaryColor),
                          ),
                        ),
                        readOnly: true,
                        //set it true, so that user will not able to edit text
                        onTap: _selectBirthDate
                      )
                  ),
                  const SizedBox(height: 10),

                  //eMail
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        hintText: 'Email',
                        fillColor: accentColor2,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //Password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      obscureText: true,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        hintText: 'Password',
                        fillColor: accentColor2,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //Password Check
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      obscureText: true,
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        hintText: 'Password Check',
                        fillColor: accentColor2,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //Button
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: ElevatedButton(
                        onPressed: signUp,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: Text(
                          'Registrieren',
                          style: TextStyle(
                            color: accentColor2,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      )
                  ),

                  const SizedBox(height: 25.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Ich bin Nutzer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                          onTap: widget.showLoginScreen,
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: accentColor1,
                                fontWeight: FontWeight.bold
                            ),
                          )
                      )
                    ],
                  )
                ],
              ),
            )
        ),
      ),
    );
  }
}
