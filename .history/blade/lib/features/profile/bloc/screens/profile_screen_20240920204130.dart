// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture with Edit Icon
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://your-image-url.com'),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Name and Social Media Links
              Column(
                children: [
                  Text(
                    'Rose',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.link, color: Colors.blue),
                      Icon(Icons.business, color: Colors.blue),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Skill Chips (Already implemented)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Chip(
                    label: Text('Designer'),
                    backgroundColor: Colors.red,
                  ),
                  SizedBox(width: 8),
                  Chip(
                    label: Text('Software'),
                    backgroundColor: Colors.red,
                  ),
                  SizedBox(width: 8),
                  Chip(
                    label: Text('Business'),
                    backgroundColor: Colors.red,
                  ),
                ],
              ),

              SizedBox(height: 16),

              // About Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lorem ipsum, or lipsum as it is sometimes known...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Tab Bar for Projects
              DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: Colors.blue,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.white,
                      tabs: [
                        Tab(text: 'Project Ideas'),
                        Tab(text: 'Ongoing Projects'),
                        Tab(text: 'Completed Projects'),
                      ],
                    ),
                    SizedBox(
                      height: 300, // Content height for tabs
                      child: TabBarView(
                        children: [
                          Text('Project Ideas content here...'),
                          Text('Ongoing Projects content here...'),
                          Text('Completed Projects content here...'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
