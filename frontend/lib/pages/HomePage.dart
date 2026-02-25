import 'package:flutter/material.dart';
import 'package:frontend/pages/profilePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.username, required this.newAccount});

  final String username; // changed to reflect user naem
  final bool newAccount; //check for new account

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
// got rid of boiler plate incrementor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("welcome, ${widget.username}"), //changed to welcome based on what the user puts in 
        actions: [ // actions is far right allows for buttons on appBar use leading for left
                    IconButton(
                        onPressed: () {
                            Navigator.pushReplacement(
                                context, 
                                MaterialPageRoute(
                                    builder: (context) => AccountPage(
                                        username: widget.username, 
                                        newAccount: widget.newAccount
                                    )
                                )
                            );     
                        }, 
                        icon: Icon(Icons.account_box_rounded)
                    ),
                    IconButton(
                        onPressed: () {
                            print("clicked on the settings button");
                        }, 
                        icon: Icon(Icons.settings)
                    )
                ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 400,
              width: 400,
              child: CarouselView(
                itemExtent: 20, // this is why it doesnt show up idk what the idea is/was but it was too small 3 pixels
                children: <Widget>[
                  Text('Recipes'),
                  Text('Profile'),
                  Text('Pantry'),
                ],
              ),
            ),
            Text('Recipes'),
            Text('Profile'),
            Text('Pantry'),
          ],
        ),
      ),
    );
  }
}
