import 'package:flutter/material.dart';
import 'package:ey/database_helper.dart';
import 'package:ey/appcolor.dart';
import 'package:ey/pages/signup_page3.dart';

class SignUpPage2 extends StatefulWidget {
  final String username;
  final String password;
  final int age;
  final String gender;

  const SignUpPage2({
    required this.username,
    required this.password,
    required this.age,
    required this.gender,
    Key? key,
  }) : super(key: key);

  @override
  _SignUpPage2State createState() => _SignUpPage2State();
}

class _SignUpPage2State extends State<SignUpPage2> {
  final TextEditingController question1Controller = TextEditingController();
  final TextEditingController question2Controller = TextEditingController();
  final TextEditingController question3Controller = TextEditingController();

  @override
  void dispose() {
    question1Controller.dispose();
    question2Controller.dispose();
    question3Controller.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    if (question1Controller.text.trim().isEmpty ||
        question2Controller.text.trim().isEmpty ||
        question3Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez répondre à toutes les questions.')),
      );
      return;
    }

    final user = User(
      username: widget.username,
      password: widget.password,
      age: widget.age,
      gender: widget.gender,
      question1: question1Controller.text.trim(),
      question2: question2Controller.text.trim(),
      question3: question3Controller.text.trim(),
    );

    try {
      await DatabaseHelper.instance.insertUser(user);

      ScaffoldMessenger.of(
        context,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignUpPage3()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de l\'enregistrement de l\'utilisateur : $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color appcolor = AppColors.getBackground(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: appcolor,
        title: Text('Étape 2: Questions de sécurité'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.gettextcolor(context),
        ),
        iconTheme: IconThemeData(color: AppColors.gettextcolor(context)),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),
                    Container(
                      width: 300,
                      child: Text(
                        'Deuxième étape : répondez à ces questions de sécurité pour récupérer votre compte en cas d’oubli de mot de passe.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gettextcolor(context),
                        ),
                      ),
                    ),
                    SizedBox(height: 60),
                    _buildTextField(
                      controller: question1Controller,
                      hintText: 'Quelle est ta couleur préférée ?',
                      appcolor: appcolor,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: question2Controller,
                      hintText: 'Quel est le nom de jeune fille de ta mère ?',
                      appcolor: appcolor,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: question3Controller,
                      hintText:
                      'Votre plat préféré ?',
                      appcolor: appcolor,
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _validateAndSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appcolor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          'Étape suivante',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.gettextcolor(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Color appcolor,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: appcolor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
