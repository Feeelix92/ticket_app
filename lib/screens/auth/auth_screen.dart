import 'package:flutter/cupertino.dart';
import 'package:ticket_app/screens/auth/login_screen.dart';
import 'package:ticket_app/screens/auth/register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  bool showLoginScreen = true;
  void toggleScreens(){
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLoginScreen){
      return LoginScreen(showRegisterScreen: toggleScreens);
    } else{
      return RegisterScreen(showLoginScreen: toggleScreens);
    }
  }
}
