import 'dart:math' as math;

import 'package:better_pattern_lock/better_pattern_lock.dart';
import 'package:flutter/material.dart';

part 'var1.dart';
part 'var2.dart';
part 'var3.dart';

void main() {
  runApp(const PatternLockApp());
}

class PatternLockApp extends StatelessWidget {
  const PatternLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PatternLockScreen(),
    );
  }
}

class PatternLockScreen extends StatefulWidget {
  const PatternLockScreen({super.key});

  @override
  State<PatternLockScreen> createState() => _PatternLockScreenState();

  static _PatternLockScreenState _of(BuildContext context) {
    return context.findAncestorStateOfType<_PatternLockScreenState>()!;
  }
}

class _PatternLockScreenState extends State<PatternLockScreen> {
  int x = 3;
  int y = 3;
  final colors = <int>[];
  final r = math.Random();

  final c = PageController(initialPage: 0);

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  void initState() {
    for (int i = 0; i < x * y; i++) {
      colors.add(0xff000000 + r.nextInt(0x00ffffff));
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        x = 4;
        y = 5;
      });
    });
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    colors.clear();
    for (int i = 0; i < x * y; i++) {
      colors.add(0xff000000 + r.nextInt(0x00ffffff));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: c,
          padEnds: true,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 35.0,
              ),
              child: Center(
                child: Variant1(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 35.0,
              ),
              child: Center(child: Variant2()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 35.0,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Variant3(
                      x: x,
                      y: y,
                      colors: colors,
                    ),
                    Slider(
                      value: x.toDouble(),
                      onChanged: (val) {
                        setState(() {
                          x = val.toInt();
                        });
                      },
                      min: 1.0,
                      max: 10.0,
                      divisions: 10,
                    ),
                    Slider(
                      value: y.toDouble(),
                      onChanged: (val) {
                        setState(() {
                          y = val.toInt();
                        });
                      },
                      min: 1.0,
                      max: 10.0,
                      divisions: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
