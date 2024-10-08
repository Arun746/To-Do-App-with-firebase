import 'package:app/screens/home.dart';
import 'package:app/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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

  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  void _login() async {
    if (_formKey.currentState!.validate()) {
      context.loaderOverlay.show();

      try {
        // Authenticate user with email and password
        await firebaseAuth.signInWithEmailAndPassword(
          email: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Successful login
        _showSnackBarSuccess("User Created Successfully");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Home()));
      } on FirebaseAuthException catch (e) {
        // Handle different types of errors
        if (e.code == 'user-not-found') {
          _showSnackBarError("No user found for that email.");
        } else if (e.code == 'wrong-password') {
          _showSnackBarError("Invalid Password");
        } else {
          _showSnackBarError("${e.message}");
        }
      } finally {
        // Hide loading overlay
        context.loaderOverlay.hide();
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
        duration: const Duration(seconds: 2),
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
        duration: const Duration(seconds: 2),
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 246, 248),
      body: LoaderOverlay(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.07,
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.03),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome ',
                          style: TextStyle(
                            fontSize: 25 * (screenWidth / 360),
                            fontWeight: FontWeight.w500,
                            color: const Color.fromRGBO(24, 97, 121, 0.8),
                          ),
                        ),
                        TextSpan(
                          text: 'Back',
                          style: TextStyle(
                            fontSize: 25 * (screenWidth / 360),
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(255, 25, 171, 86),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //sp txt
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.08 * screenWidth,
                  ),
                  child: Text(
                    'Check it off, feel the progress. Log in and make your day productive!',
                    style: TextStyle(fontSize: 16 * (screenWidth / 360)),
                    textAlign: TextAlign.center,
                  ),
                ),
                //form
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.04),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.11,
                            vertical: screenHeight * 0.01,
                          ),
                          child: TextFormField(
                            controller: _usernameController,
                            decoration: _inputDecoration(
                              'Email',
                              const Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email Address required';
                              }
                              return null;
                            },
                          ),
                        ),
                        // Password Field
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.11,
                            vertical: screenHeight * 0.01,
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            obscuringCharacter: '*',
                            decoration: _inputDecoration(
                              'Password',
                              const Icon(Icons.password),
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password required';
                              }
                              return null;
                            },
                          ),
                        ),
                        // Login Button
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.04),
                          child: ElevatedButton(
                            onPressed: () {
                              _login();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(24, 97, 121, 0.8),
                              shadowColor: Colors.transparent,
                              fixedSize:
                                  Size(screenWidth * 0.5, screenHeight * 0.05),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16 * (screenWidth / 360),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        // Divider
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade500,
                                  thickness: 0.8,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "Or",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 15 * (screenWidth / 360),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade500,
                                  thickness: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        // Sign Up Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUp(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(204, 133, 173, 186),
                            shadowColor: Colors.transparent,
                            fixedSize:
                                Size(screenWidth * 0.5, screenHeight * 0.05),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16 * (screenWidth / 360),
                            ),
                          ),
                        ),
                      ],
                    ),
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
