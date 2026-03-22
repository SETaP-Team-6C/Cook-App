import 'package:flutter/material.dart';
import 'package:frontend/core/routes.dart';
import 'package:http/http.dart' as http;

class User {
  final TextEditingController _userFnameController = TextEditingController();
  final TextEditingController _userLnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final User user = User();

  // async func returns Future of type void is like in rust needs
  Future<void> _sendUser(userFname, userLname, password, newAccount) async {
    try {
      final response = await http.post(
        Uri.parse(
          "http://localhost:5000/authenticate",
        ), // need to change per create account and login :)
        headers: {
          "Content-Type":
              "application/x-www-form-urlencoded", // changed as backend requests form
        },
        body: {
          // removed json encode as again form backend
          "user_fname": userFname,
          "user_lname": userLname,
          "user_password": password,
        },
      );

      if (response.statusCode == 200) {
        print("yipppeee it works (hit backend) ${response.body}");
      } else {
        print("fail somewhere ${response.statusCode}");
      }
    } catch (e) {
      print("error here =>: $e");
    }
  }

  void _handleAuth(bool newAccount) async {
    String userFname = user._userFnameController.text.trim();
    String userLname = user._userLnameController.text.trim();
    String userPassword = user._passwordController.text.trim();

    await _sendUser(userFname, userLname, userPassword, newAccount);

    String username = "$userFname $userLname";

    Navigator.pushReplacementNamed(
      // uses named routing now instead of direct calling
      context,
      AppRoutes.home,
      arguments: {"username": username, "newAccount": newAccount},
    );
  }

  @override
  void dispose() {
    // clean up
    user._userFnameController.dispose();
    user._userLnameController.dispose();
    user._passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: user._userFnameController, // allows use of value
                  decoration: InputDecoration(
                    labelText: "User first name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "please enter a valid name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: user
                      ._userLnameController, // like fields in html so need .value to get value
                  decoration: InputDecoration(
                    labelText: "User last name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "please enter a valid name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: user._passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "please enter a valid password";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _handleAuth(false);
                    }
                  },
                  child: Text("Login"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Push CreateAccount and await returned result (username/newAccount)
                    final result = await Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.createAccount,
                    );
                    if (result is Map && result['username'] != null) {
                      // If the create account screen returned a message, show it briefly
                      if (result['message'] != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'].toString())),
                        );
                        // allow a short moment for the SnackBar to appear before navigating
                        await Future.delayed(const Duration(milliseconds: 300));
                      }

                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.home,
                        arguments: {
                          'username': result['username'],
                          'newAccount': result['newAccount'] ?? true,
                        },
                      );
                    }
                  },
                  child: const Text("Create Account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
