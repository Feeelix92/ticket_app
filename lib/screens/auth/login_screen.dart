import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ticket_app/colors.dart';

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

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
    );
    print(_emailController.text.trim());
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
                              color: accentColor1,
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
                    child: Text(
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