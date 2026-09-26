import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: Text(
          'Fandom Verse Home',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}