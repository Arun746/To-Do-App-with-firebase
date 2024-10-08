// ignore_for_file: prefer_const_constructors, deprecated_member_use, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, prefer_final_fields, use_build_context_synchronously

import 'package:app/config/config.dart';
import 'package:app/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  void signup() async {
    context.loaderOverlay.show();
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      context.loaderOverlay.hide();
      _showSnackBarSuccess("User Created Successfully");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } catch (e) {
      context.loaderOverlay.hide();
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        _showSnackBarError('Email already exists');
      } else {
        _showSnackBarError(
          e.toString(),
        );
      }
    }
  }

  void _showSnackBarError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners
        ),
        duration: Duration(seconds: 2),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showSnackBarSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String labelText, Icon prefixIcon) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      labelText: labelText,
      labelStyle: const TextStyle(color: Color.fromARGB(255, 80, 108, 121)),
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: prefixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.1,
                ),
                //signup txt
                Padding(
                  padding: EdgeInsets.only(top: 0.01 * screenHeight),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign ',
                        style: TextStyle(
                          fontSize: 25 * (screenWidth / 360),
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Up',
                        style: TextStyle(
                          fontSize: 25 * (screenWidth / 360),
                          fontWeight: FontWeight.w500,
                          color: Config.themeMainColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.08 * screenWidth,
                    vertical: 0.008 * screenHeight,
                  ),
                  child: Text(
                    'Create An Account And Enjoy Our Services',
                    style: TextStyle(
                      fontSize: 16 * (screenWidth / 360),
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                //form
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 0.1 * screenWidth,
                      vertical: 0.01 * screenHeight),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: emailController,
                          decoration: _inputDecoration(
                            'Email',
                            const Icon(Icons.mail),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 0.02 * screenHeight),
                        TextFormField(
                          controller: passwordController,
                          decoration: _inputDecoration(
                            'Password',
                            const Icon(Icons.password),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          obscureText: true,
                        ),
                        SizedBox(height: 0.02 * screenHeight),
                        TextFormField(
                          controller: confirmpasswordController,
                          decoration: _inputDecoration(
                            'Confirm Password',
                            const Icon(Icons.password),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            } else if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          obscureText: true,
                        ),
                        //signuo
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 0.05 * screenHeight),
                            child: SizedBox(
                              width: screenWidth * 0.5,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    signup();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Config.themeMainColor,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //elselogin
                Text(
                  'Or',
                  style: TextStyle(
                    fontSize: 14 * (screenWidth / 360),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 0.03 * screenHeight,
                    top: screenHeight * 0.01,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontSize: 14 * (screenWidth / 360),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          ' Login',
                          style: TextStyle(
                            color: Config.themeMainColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15 * (screenWidth / 360),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }
}
