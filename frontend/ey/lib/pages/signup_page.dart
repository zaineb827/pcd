import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ey/pages/login_page.dart';
import 'package:ey/pages/signup_page2.dart';
import 'package:ey/appcolor.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String _selectedGender = 'choisissez votre genre';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_formKey.currentState!.validate() &&
        _selectedGender != 'choisissez votre genre') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SignUpPage2(
            username: _usernameController.text.trim(),
            password: _passwordController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            gender: _selectedGender,
          ),
        ),
      );
    } else if (_selectedGender == 'choisissez votre genre') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un genre valide')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color appcolor = AppColors.getBackground(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: appcolor,
        title: Text('S\'inscrire', textAlign: TextAlign.center),
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(width: 10, height: 50),
                    Container(
                      width: 250,
                      child: Text(
                        'Bienvenue sur la page d\'inscription !',textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 23,
                          color: AppColors.gettextcolor(context),
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Veuillez remplir vos coordonnées ci-dessous :',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.gettextcolor(context),
                      ),
                    ),
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Nom d\'utilisateur',
                          filled: true,
                          fillColor: appcolor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le nom d\'utilisateur est requis';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Mot de passe',
                          filled: true,
                          fillColor: appcolor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Le mot de passe doit comporter au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: 'Âge',
                          filled: true,
                          fillColor: appcolor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'âge est requis';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 1 || age > 120) {
                            return 'Entrez un âge valide';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: appcolor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Genre:',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.gettextcolor(context),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: appcolor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButton<String>(
                              icon: const Icon(Icons.arrow_drop_down),
                              iconEnabledColor: Color.fromARGB(255, 63, 63, 63),
                              focusColor: appcolor,
                              dropdownColor: appcolor,
                              value: _selectedGender,
                              underline: SizedBox(),
                              items:
                              <String>[
                                'choisissez votre genre',
                                'Mâle',
                                'Femelle',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedGender = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: _goToNextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appcolor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Étape suivante',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.gettextcolor(context),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Vous avez déjà un compte ?',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.gettextcolor(context),
                          ),
                        ),
                        SizedBox(width: 5),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Se connecter',
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ),
                      ],
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
}
