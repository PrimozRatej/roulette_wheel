import 'package:flutter/material.dart';
import 'package:roulette_wheel/roulette_wheel.dart';

class RouletteTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Roulette Wheel
          Expanded(
            flex: 2,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.brown[400],
                      border: Border.all(color: Colors.black, width: 4),
                    ),
                  ),
                  // Inner Circle
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.brown[600],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 13),
                    child: RouletteWheel(),
                  ),
                ],
              ),
            ),
          ),

          // Betting Table
          Expanded(
            flex: 3,
            child: GridView.count(
              crossAxisCount: 12,
              childAspectRatio: 0.6,
              children: [
                // First Row (Numbers)
                buildNumberCell("3", Colors.red),
                buildNumberCell("6", Colors.black),
                buildNumberCell("9", Colors.red),
                buildNumberCell("12", Colors.black),
                buildNumberCell("15", Colors.red),
                buildNumberCell("18", Colors.black),
                buildNumberCell("21", Colors.red),
                // TODO here
                buildNumberCell("8", Colors.black),
                buildNumberCell("9", Colors.red),
                buildNumberCell("10", Colors.black),
                buildNumberCell("11", Colors.red),
                buildNumberCell("12", Colors.black),
                buildNumberCell("13", Colors.red),
                buildNumberCell("14", Colors.black),
                buildNumberCell("15", Colors.red),
                buildNumberCell("16", Colors.black),
                buildNumberCell("17", Colors.red),
                buildNumberCell("18", Colors.black),
                buildNumberCell("19", Colors.red),
                buildNumberCell("20", Colors.black),
                buildNumberCell("21", Colors.red),
                buildNumberCell("22", Colors.black),
                buildNumberCell("23", Colors.red),
                buildNumberCell("24", Colors.black),
                buildNumberCell("25", Colors.red),
                buildNumberCell("26", Colors.black),
                buildNumberCell("27", Colors.red),
                buildNumberCell("28", Colors.black),
                buildNumberCell("29", Colors.red),
                buildNumberCell("30", Colors.black),
                buildNumberCell("31", Colors.red),
                buildNumberCell("32", Colors.black),
                buildNumberCell("33", Colors.red),
                buildNumberCell("34", Colors.black),
                buildNumberCell("35", Colors.red),
                buildNumberCell("36", Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNumberCell(String number, Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1), // Border around the cell
        color: color, // Background color based on the number's color
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Text color (white for visibility)
          ),
        ),
      ),
    );
  }
}
