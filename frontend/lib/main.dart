import 'package:flutter/material.dart';

void main() {
  runApp(const CookApp());
}

class CookApp extends StatelessWidget {
  const CookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cook App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(title: 'Cook App Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
