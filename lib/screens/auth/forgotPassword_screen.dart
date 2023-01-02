
import 'package:flutter/material.dart';

import '../../colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Gib deine Mail ein und wir schicken dir einen Link zum Zurücksetzen zu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Email',
                fillColor: accentColor2,
                filled: true,
              ),
            ),
          ),

          const SizedBox(height: 10),

          MaterialButton(
            onPressed: (){},
            color: secondaryColor,
            child: Text(
              'Passwort zurücksetzen',
              style: TextStyle(color: accentColor3),
            ),
          )
        ],
      ),
    );
  }
}
