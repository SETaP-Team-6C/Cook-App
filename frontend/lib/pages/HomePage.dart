import 'package:flutter/material.dart';

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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 100,
              width: 100,
              child: CarouselView(
                itemExtent: 3,
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
