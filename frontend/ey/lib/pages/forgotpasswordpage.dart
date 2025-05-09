import 'package:flutter/material.dart';
import 'package:ey/pages/passwordreset_page.dart';
import 'package:ey/appcolor.dart';
import 'package:ey/database_helper.dart';

class Forgotpasswordpage extends StatefulWidget {
  @override
  _ForgotpasswordpageState createState() => _ForgotpasswordpageState();
}

class _ForgotpasswordpageState extends State<Forgotpasswordpage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _answer1Controller = TextEditingController();
  final TextEditingController _answer2Controller = TextEditingController();
  final TextEditingController _answer3Controller = TextEditingController();

  String? _errorMessage;

  Future<void> _validateAnswers() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer votre nom d\'utilisateur.';
      });
      return;
    }

    final user = await DatabaseHelper.instance.getUser(username);
    if (user == null) {
      setState(() {
        _errorMessage = 'Utilisateur non trouvé. Veuillez vérifier votre nom d\'utilisateur.';
      });
      return;
    }

    if (_answer1Controller.text.trim().toLowerCase() == user.question1?.trim().toLowerCase() &&
        _answer2Controller.text.trim().toLowerCase() == user.question2?.trim().toLowerCase() &&
        _answer3Controller.text.trim().toLowerCase() == user.question3?.trim().toLowerCase()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PasswordResetPage(username: username,)),
      );
    } else {
      setState(() {
        _errorMessage = 'Les réponses ne correspondent pas. Veuillez réessayer.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color appcolor = AppColors.getBackground(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: appcolor,
        title: Text('Réinitialisation du mot de passe', textAlign: TextAlign.center),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.gettextcolor(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppColors.getBackgroundImage(context)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 60),
                  Text(
                    'Mot de passe oublié?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gettextcolor(context),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Veuillez entrer votre nom d\'utilisateur et répondre aux questions pour réinitialiser votre mot de passe.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.gettextcolor(context),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Nom d\'utilisateur',
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.gettextcolor(context)),
                        filled: true,
                        fillColor: appcolor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _answer1Controller,
                      decoration: InputDecoration(
                        hintText: 'Quel est ton plat préféré ?',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.gettextcolor(context)),
                        filled: true,
                        fillColor: appcolor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _answer2Controller,
                      decoration: InputDecoration(
                        hintText: 'Quel était le nom de votre premier animal de compagnie ?',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.gettextcolor(context)),
                        filled: true,
                        fillColor: appcolor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _answer3Controller,
                      decoration: InputDecoration(
                        hintText: 'Quelle est votre émission de télévision préférée de votre enfance ?',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.gettextcolor(context)),
                        filled: true,
                        fillColor: appcolor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _validateAnswers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appcolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      'étape suivante',
                      style: TextStyle(fontSize: 18, color: AppColors.gettextcolor(context)),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
