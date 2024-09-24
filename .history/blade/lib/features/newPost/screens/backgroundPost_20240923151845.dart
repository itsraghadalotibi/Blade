import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'post.dart';

class backgroundScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // padding: EdgeInsets.symmetric(vertical: 30),
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
            Color(0xFFFD5336),   
            Color.fromARGB(255, 139, 139, 139),
            Color(0xFFFD5336),
              ]
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 40,),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,  // Center the text and other content
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,  // Position the arrow to the left
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white, size: 32),  // Bigger arrow
                          onPressed: () {
                            Navigator.pop(context);  // Navigate back to the previous page
                          },
                        ),
                      ),
                      const Center(
                        child: Text(
                          "New Idea",
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ),
              Expanded(
                child: Container(
                  // ignore: prefer_const_constructors
                  decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                  ),
                  child: const ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    child: Post(),
                    )
                ),
                )
          ],
        ),
      ),
    );
  }
}