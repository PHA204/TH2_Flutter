import 'package:flutter/material.dart';

class ReadingSettings {
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;
  final String fontFamily;
  final bool isDarkMode;
  final int lastPageRead;

  ReadingSettings({
    this.fontSize = 18.0,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.fontFamily = 'Default',
    this.isDarkMode = false,
    this.lastPageRead = 0,
  });

  ReadingSettings copyWith({
    double? fontSize,
    Color? backgroundColor,
    Color? textColor,
    String? fontFamily,
    bool? isDarkMode,
    int? lastPageRead,
  }) {
    return ReadingSettings(
      fontSize: fontSize ?? this.fontSize,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      fontFamily: fontFamily ?? this.fontFamily,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      lastPageRead: lastPageRead ?? this.lastPageRead,
    );
  }

  // Convert to Map for SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'fontSize': fontSize,
      'backgroundColor': backgroundColor.value,
      'textColor': textColor.value,
      'fontFamily': fontFamily,
      'isDarkMode': isDarkMode,
      'lastPageRead': lastPageRead,
    };
  }

  // Create from Map
  factory ReadingSettings.fromMap(Map<String, dynamic> map) {
    return ReadingSettings(
      fontSize: map['fontSize'] ?? 18.0,
      backgroundColor: Color(map['backgroundColor'] ?? 0xFFFFFFFF),
      textColor: Color(map['textColor'] ?? 0xFF000000),
      fontFamily: map['fontFamily'] ?? 'Default',
      isDarkMode: map['isDarkMode'] ?? false,
      lastPageRead: map['lastPageRead'] ?? 0,
    );
  }
}