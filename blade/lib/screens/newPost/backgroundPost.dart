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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
            Colors.orange.shade900,
            Colors.orange.shade800,
            Colors.orange.shade400
            ]
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 40,),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Text("New Idea", style: TextStyle(color: Colors.white, fontSize: 40),),
                // Text("New Idea", style: TextStyle(color: Colors.white, fontSize: 20),),
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