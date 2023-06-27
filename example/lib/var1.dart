part of 'main.dart';

class Variant1 extends StatelessWidget {
  const Variant1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PatternLock(
      width: 4,
      height: 4,
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
    );
  }
}
