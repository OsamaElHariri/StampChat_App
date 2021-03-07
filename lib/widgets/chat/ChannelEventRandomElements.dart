import 'dart:math';

import 'package:flutter/material.dart';

class ChannelEventRandomElements {
  static var stampBorders = [
    "assets/circle.png",
    "assets/star.png",
    "assets/square.png",
  ];

  static var memberIcons = [
    "assets/circle_icon.png",
    "assets/star_icon.png",
    "assets/square_icon.png",
  ];

  static num getStampRotation(int stampId) =>
      _random(stampId).nextDouble() * 20 - 10;

  static String getStampBorderAsset(int memberId) =>
      stampBorders[_random(memberId).nextInt(stampBorders.length)];

  static Color getStampColor(int memberId) =>
      HSVColor.fromAHSV(1.0, _random(memberId).nextDouble() * 360, 0.65, 0.60)
          .toColor();

  static String getMemberIcon(int memberId) =>
      memberIcons[_random(memberId).nextInt(memberIcons.length)];

  static Random _random(int x) => Random(Random(x).nextInt(pow(2, 30)));
}
