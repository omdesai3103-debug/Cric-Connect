import 'package:flutter/material.dart';
import '../app_drawer.dart'; 

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
       drawer: const AppDrawer(), 
      body: const Center(child: Text('Your stats and player search')),
    );
  }
}