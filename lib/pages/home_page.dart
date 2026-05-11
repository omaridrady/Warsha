import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/services/user_service.dart';
import 'package:warsha/util/warsha_list_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

clsUser? currentUser;

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[600],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                currentUser == null
                    ? CircularProgressIndicator()
                    : Text(
                        "Hi, ${currentUser!.name}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                SizedBox(height: 20),
                //Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange[500],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Search",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
            SizedBox(height:40 ,),
          //snackbar
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Choose Your Warsha :",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 25,),
                      WarshaListTile(
                        text: "Pluming",
                        color: Colors.blue,
                        warshaIcon: Icons.water_drop,
                      ),
                      WarshaListTile(
                        text: "Electricity",
                        color: Colors.yellow,
                        warshaIcon: Icons.electric_bolt,
                      ),
                      WarshaListTile(
                        text: "Smithing",
                        color: Colors.red,
                        warshaIcon: Icons.local_fire_department_rounded,
                      ),
                      WarshaListTile(
                        text: "Planting",
                        color: Colors.green,
                        warshaIcon: Icons.account_tree,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getCurrentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = await UserService.getUser(prefs.getString("uid")!);
    setState(() {
      currentUser = user;
    });
  }
}
