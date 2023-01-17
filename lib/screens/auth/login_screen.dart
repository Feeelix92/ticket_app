import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticket_app/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgotPassword_screen.dart';

class LoginScreen extends StatefulWidget{
  final VoidCallback showRegisterScreen;
  const LoginScreen({Key? key, required this.showRegisterScreen}) : super(key:key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late User user = FirebaseAuth.instance.currentUser!;
  late List<User> actualUser = [];
  bool isLoading = false;

  Future signIn() async {
    try{
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      getUserData();
    }on FirebaseAuthException {
      showDialog(
          context: context,
          builder: (context){
            return const AlertDialog(
              content: Text('Konrolliere deine Eingabe')
            );
          });
      setState(() {
        isLoading = false;
      });
    }


  }

  getUserData() async{
    await FirebaseFirestore.instance
        .collection('users')
        .where("authId", isEqualTo: user.uid)
        .get()
        .then((users) => users.docs.forEach(
            (user) {
              var userData = user.data();
              _storeUserDetails(
                  userData['firstName'],
                  userData['lastName'],
                  userData['email'],
                  userData['birthdate'],
                  userData['authId']
              );
            }));
  }

  _storeUserDetails(String firstName, String lastName, String email, String birthdate, String authId) async{
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('email', email);
    await prefs.setString('birthdate', birthdate);
    await prefs.setString('authId', authId);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.flutter_dash,
                  size: 120,
                ),
                const SizedBox(height: 75),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 52,

                  ),
                ),
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
                      labelText: 'Email',
                      fillColor: accentColor2,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

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
                      labelText: 'Password',
                      fillColor: accentColor2,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap:(){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return const ForgotPasswordScreen();
                          },),);
                        },
                        child: Text(
                          'Passwort vergessen?',
                          style: TextStyle(
                              color: accentColor2,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: accentColor1)
                        : Text(
                      'Login',
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
                      'Bisher kein Nutzer?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showRegisterScreen,
                      child: Text(
                        'Registrieren',
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