import 'package:flutter/material.dart';

class Plan extends StatefulWidget {
  @override
  _PlanState createState() => _PlanState();
}

class _PlanState extends State<Plan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff8B0505),
        elevation: 50,
        centerTitle: true,
        title: Text(
          'Masar',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,fontFamily: "Poppins"),
        ),
        leading: Row(
          children: [
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Image.asset(
                'images/logo.png',
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(child: Text('Here is your Masar!',style: TextStyle(fontSize: 22,fontFamily: "Poppins",color: Color(0xff8B0505),),)),

            ],
          ),
        ),
      ),

    );
  }
}
