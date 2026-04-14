import 'package:flutter/material.dart';
import 'package:frontend/features/authen/create_account.dart';
import 'package:frontend/features/recipe/home_page.dart';
import 'package:frontend/features/authen/login_page.dart';
import 'package:frontend/features/profile/profile_page.dart';
import 'package:frontend/features/add_recipe/add_recipe.dart';
import 'package:frontend/features/recipe/search_page.dart';
import 'package:frontend/features/techniques/cooking_techniques_page.dart';

class AppRoutes {
  static const String login = "/login";
  static const String home = "/home";
  static const String profile = "/profile";
  static const String addRecipe = "/addRecipe";
  static const String createAccount = "/createAccount";
  static const String techniques = "/techniques";
  static const String search = "/search";

  //routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == null) {
      print("is null");
    }
    if (settings.name!.isEmpty) {
      print("is empty");
    }
    print("${settings.name}");
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case home:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => HomePage(
            username: args["username"],
            newAccount: args["newAccount"],
          ),
        );
      case profile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AccountPage(
            username: args["username"],
            newAccount: args["newAccount"],
          ),
        );
      case addRecipe:
        return MaterialPageRoute(builder: (_) => AddRecipe());
      case createAccount:
        return MaterialPageRoute(builder: (_) => CreateAccount());
      case techniques:
        return MaterialPageRoute(builder: (_) => const CookingTechniquesPage());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("error no route"))),
        );
      // settings aswell havent made that page yet felt it was better to do it this way easier to extend app
    }
  }
}
