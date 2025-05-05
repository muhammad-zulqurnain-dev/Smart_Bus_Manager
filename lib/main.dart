import 'dart:async';
import 'package:flutter/material.dart';
import 'NextScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const MyHomePage(title: 'Project'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
          () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const NextScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 70.0,
                backgroundImage: AssetImage('assets/images/bus.jpg'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Zulqarnain travel',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
