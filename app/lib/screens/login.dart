import 'package:app/provider/loginprovider.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/screens/signup.dart';
import 'package:loader_overlay/loader_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    DateTime? lastBackPressTime;

    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (lastBackPressTime == null ||
            now.difference(lastBackPressTime!) > Duration(seconds: 3)) {
          lastBackPressTime = now;
          SnackBarMsg.showError(context, "Press again to exit", 1);
          return Future.value(false);
        }
        //exit app
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 239, 246, 248),
        body: LoaderOverlay(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.07),
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
                  SizedBox(height: screenHeight * 0.05),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 0.08 * screenWidth),
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
                      child: Column(
                        children: [
                          Consumer(
                            builder: (context, ref, _) {
                              final loginNotifier =
                                  ref.read(loginProvider.notifier);
                              return Column(
                                children: [
                                  // Email Field
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.11,
                                      vertical: screenHeight * 0.01,
                                    ),
                                    child: TextFormField(
                                      decoration: _inputDecoration(
                                        'Email',
                                        const Icon(Icons.person),
                                      ),
                                      onChanged: (value) =>
                                          loginNotifier.setUsername(value),
                                    ),
                                  ),
                                  // Password Field
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.11,
                                      vertical: screenHeight * 0.01,
                                    ),
                                    child: TextFormField(
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
                                              _passwordVisible =
                                                  !_passwordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      onChanged: (value) =>
                                          loginNotifier.setPassword(value),
                                    ),
                                  ),
                                  // Login Button
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: screenHeight * 0.04),
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          loginNotifier.login(ref, context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(
                                            24, 97, 121, 0.8),
                                        shadowColor: Colors.transparent,
                                        fixedSize: Size(screenWidth * 0.5,
                                            screenHeight * 0.05),
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
                                ],
                              );
                            },
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          // Divider and Sign Up Button
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
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
      ),
    );
  }

//input decoration
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
}
