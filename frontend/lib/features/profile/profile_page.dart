import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget{
    final String username;
    final bool newAccount;
    const AccountPage({super.key, required this.username,required this.newAccount});

    @override
    Widget build(BuildContext context){
        return Scaffold(
           appBar: AppBar(
//                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text("Account Page"),
            )
        ); 

    }
}


