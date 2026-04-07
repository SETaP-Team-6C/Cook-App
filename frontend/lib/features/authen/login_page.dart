import 'package:flutter/material.dart';
import 'package:frontend/core/routes.dart';
import 'package:frontend/features/authen/services/account_services.dart';

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
  final LoginService loginService = LoginService();

  void showMsg(BuildContext context, String msg, int time) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${msg}"),
        duration: Duration(seconds: time),
      ),
    );
  }

  // async func returns Future of type void is like in rust needs
  Future<void> _sendUser(userFname, userLname, password, newAccount) async {
    try {
      final data = await loginService.authenticate(
        userFname,
        userLname,
        password,
      );
      if (!mounted) return;

      if (data.statusCode == 200) {
        String username = "$userFname $userLname";

        Navigator.pushReplacementNamed(
          // uses named routing now instead of direct calling
          context,
          AppRoutes.home,
          arguments: {"username": username, "newAccount": newAccount},
        );

        showMsg(context, "logged in", 2);
      } else {
        showMsg(context, "invalid credientials", 2);
      }
    } catch (e) {
      showMsg(context, "server error", 2);
    }
  }

  void _handleAuth(bool newAccount) async {
    String userFname = user._userFnameController.text.trim();
    String userLname = user._userLnameController.text.trim();
    String userPassword = user._passwordController.text.trim();

    await _sendUser(userFname, userLname, userPassword, newAccount);
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
                    final result = await Navigator.pushNamed(
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
