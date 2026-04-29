import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final List<IconData> icons = [
  Icons.electric_bolt,
  Icons.water_drop,
  Icons.carpenter,

];

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        ListView.builder(itemCount : icons.length,itemBuilder: (context,index){

        })
      ],)
    );
  }
}
