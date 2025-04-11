import 'package:flutter/material.dart';
import 'package:roulette_wheel/roulette_wheel.dart';

class RouletteTable extends StatefulWidget {
  const RouletteTable({super.key});

  @override
  State<RouletteTable> createState() => _RouletteTableState();
}

class _RouletteTableState extends State<RouletteTable> with SingleTickerProviderStateMixin {
  final GlobalKey<RouletteWheelState> rouletteWheelState = GlobalKey<RouletteWheelState>();
  bool _isSpinning = false;
  int? _winningNumber;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSpin() {
    if (_isSpinning) return;
    setState(() => _isSpinning = true);
    rouletteWheelState.currentState?.spin();
  }

  void _handleRoundEnd(int winningNumber) {
    if (!mounted) return;

    setState(() {
      _winningNumber = winningNumber;
    });

    _animationController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _animationController.reset();
      setState(() {
        _isSpinning = false;
        _winningNumber = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      floatingActionButton: AnimatedOpacity(
        opacity: _isSpinning ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton.large(
          onPressed: _handleSpin,
          backgroundColor: Colors.red[700],
          child: const Icon(Icons.casino, size: 40),
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: SizedBox.shrink(),
          ),
          // Roulette Wheel
          Expanded(
            flex: 8,
            child: RouletteWheel(
              key: rouletteWheelState,
              onRoundEnd: _handleRoundEnd,
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox.shrink(),
          ),
          // Betting Table
          Expanded(
            flex: 12,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 13,
              childAspectRatio: 0.4,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black),
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                      bottom: BorderSide.none,
                    ),
                    color: Colors.green,
                  ),
                ),
                buildNumberCell("3", Colors.red),
                buildNumberCell("6", Colors.black),
                buildNumberCell("9", Colors.red),
                buildNumberCell("12", Colors.black),
                buildNumberCell("15", Colors.red),
                buildNumberCell("18", Colors.black),
                buildNumberCell("21", Colors.red),
                buildNumberCell("24", Colors.black),
                buildNumberCell("27", Colors.red),
                buildNumberCell("30", Colors.black),
                buildNumberCell("33", Colors.red),
                buildNumberCell("36", Colors.black),
                buildNumberCell("0", Colors.green),
                buildNumberCell("2", Colors.red),
                buildNumberCell("5", Colors.black),
                buildNumberCell("8", Colors.red),
                buildNumberCell("11", Colors.black),
                buildNumberCell("14", Colors.red),
                buildNumberCell("17", Colors.black),
                buildNumberCell("20", Colors.red),
                buildNumberCell("23", Colors.black),
                buildNumberCell("26", Colors.red),
                buildNumberCell("29", Colors.black),
                buildNumberCell("32", Colors.red),
                buildNumberCell("35", Colors.black),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide.none,
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                      bottom: BorderSide(color: Colors.black),
                    ),
                    color: Colors.green,
                  ),
                ),
                buildNumberCell("1", Colors.red),
                buildNumberCell("4", Colors.black),
                buildNumberCell("7", Colors.red),
                buildNumberCell("10", Colors.black),
                buildNumberCell("13", Colors.red),
                buildNumberCell("16", Colors.black),
                buildNumberCell("19", Colors.red),
                buildNumberCell("22", Colors.black),
                buildNumberCell("25", Colors.red),
                buildNumberCell("28", Colors.black),
                buildNumberCell("31", Colors.red),
                buildNumberCell("34", Colors.black),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget buildNumberCell(String number, Color color) {
    final isWinning = _winningNumber != null && number == _winningNumber.toString();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isWinning ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: color,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
