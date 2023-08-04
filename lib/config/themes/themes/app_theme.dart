

import 'package:flutter/material.dart';
import 'color_schemas/color_schemes.g.dart';

class AppTheme {

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,

  );

}