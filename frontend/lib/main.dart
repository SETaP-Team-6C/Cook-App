import 'package:flutter/material.dart';
import 'package:frontend/core/routes.dart';
import 'package:frontend/core/theme.dart';


void main(){
    runApp(const CookApp());
}

class CookApp extends StatelessWidget {
    const CookApp({super.key});
// basically redid main and moved everything out 
// all core files are basically just name spaces 
    @override
      Widget build(BuildContext context) {
        return MaterialApp(
            title: "Cook App",
            theme: AppTheme.lightTheme, 
            initialRoute: AppRoutes.login,
            onGenerateRoute: AppRoutes.generateRoute
        );
      }
  
}
