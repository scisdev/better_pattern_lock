import 'dart:math';

import 'package:better_pattern_lock/better_pattern_lock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
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
}

class _PatternLockScreenState extends State<PatternLockScreen> {
  int x = 3;
  int y = 3;
  final colors = <int>[];
  final r = Random();

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
        child: Center(
          child: FractionallySizedBox(
            widthFactor: .75,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: PatternLock(
                      width: x,
                      height: y,
                      onEntered: (pattern) {
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                'entered ${pattern.join('-')}',
                              ),
                            ),
                          );
                      },
                      linkageSettings: PatternLockLinkageSettings.distance(3),
                      linkPainter: const PatternLockLinkGradientPainter(
                        width: 10.0,
                        gradient: SweepGradient(
                          center: FractionalOffset.center,
                          colors: <Color>[
                            Color(0xFF4285F4),
                            Color(0xFF34A853),
                            Color(0xFFFBBC05),
                            Color(0xFFEA4335),
                            Color(0xFF4285F4),
                          ],
                          stops: <double>[0.0, 0.25, 0.5, 0.75, 1.0],
                        ),
                        isGlobal: true,
                      ),
                      drawLineToPointer: true,
                      cellBuilder: (ctx, ind, anim) {
                        return Material(
                          type: MaterialType.circle,
                          color: Colors.transparent,
                          elevation: 32.0 * anim,
                          animationDuration: Duration.zero,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.lerp(
                                Theme.of(ctx).colorScheme.background,
                                Color(colors[ind]),
                                anim,
                              )!,
                              border: Border.all(
                                width: 1.0,
                                color: Colors.grey,
                                strokeAlign: -1.0,
                              ),
                            ),
                          ),
                        );
                      },
                      cellActiveArea: const PatternLockCellActiveArea(
                        shape: PatternLockCellAreaShape.circle,
                        units: PatternLockCellAreaUnits.relative,
                        dimension: .75,
                      ),
                      animationDuration: const Duration(milliseconds: 350),
                    ),
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
        ),
      ),
    );
  }
}
