import 'package:flutter/material.dart';
import 'package:warsha/pages/request_screen.dart';

class WarshaListTile extends StatelessWidget {
  String text;
  IconData warshaIcon;
  MaterialColor color;
  
  WarshaListTile({
    super.key,
    required this.text,
    required this.color,
    required this.warshaIcon,
  });

  @override
  Widget build(BuildContext context) {
    return //mylisttile
    Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: color[500],
            borderRadius: BorderRadius.circular(12),
            // --- SHADOW ADDED HERE ---
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2), // Shadow color
                spreadRadius: 1, // How much the shadow spreads
                blurRadius: 8, // How "blurry" the shadow is
                offset: const Offset(
                  0,
                  4,
                ), // Moves shadow (x, y) - 4 is downward
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Icon(warshaIcon, color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => RequestPage(requestType: text)));
        },
      ),
    );
  }
}
