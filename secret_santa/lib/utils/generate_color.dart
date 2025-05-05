import 'dart:math';
import 'dart:ui';

class GenerateColor {
  Color generateSoftColor() {
    int red = 200 + Random().nextInt(56);
    int green = 200 + Random().nextInt(56);
    int blue = 200 + Random().nextInt(56);
    return Color.fromARGB(255, red, green, blue);
  }
}
