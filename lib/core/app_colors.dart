import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Colors.white;
  static const Color headerBackground = Colors.white;
  static const Color divider = Color(0xFFE0E0E0);
  static const Color primaryText = Color(0xFF333333);
  static const Color mehroon = Color(0xFF77153C);
  static const Color link = Color(0xFF007BFF);
  static const Color menuGray = Color(0xFF808080); // approximate RN 'gray'

  AppColors._();

static const Color yellow = Color(0xFFF6E508);
static const Color white = Color(0xFFFFFFFF);
static const Color black = Color(0xFF000000);
static const Color blackMain = Color(0xFF262627);
static const Color blackMed = Color(0xFF404145);
static const Color blackLight = Color(0xFF3A3A3A);
static const Color blackLight01 = Color(0xFF323232);
static const Color blue = Color(0xFF0069D8);
static const Color tabblue = Color(0xFF3071B5);
static const Color whiteBackground = Color(0xFFF8F9FB);
static const Color cancelColor = Color(0xFFE1E0E4);
static const Color textColor = Color(0xFF666666);
static const Color border = Color(0xFFCCCCCC);
static const Color backOrange = Color(0xFFFFF1F1);
static const Color green = Color(0xFF00A040);
static const Color orange = Color(0xFFE9463C);
static const Color red = Color(0xFFFF0000);
static const Color grayColor = Color(0xFF999999);
static const Color backgroundOrange = Color(0xFFFFFAFA);
static const Color gold = Color(0xFFE8983F);
static const Color main = Color(0xFF3A3A3A);
static const Color darkMain = Color(0xFF372D74);
static const Color lightMain = Color(0xFF9BACE8);
static const Color darkPink = Color(0xFFC89CAB);
  static const Color grey1 = Color(0xFFD9D9D9);
  static const Color grey2 = Color(0xFF757575);
  static const Color grey3 = Color(0xFF969696);
// Skeleton shimmer specific (from InterestedUserScreen.js inline styles)
  static const Color skeletonBase = Color(0xFFD4D4D4);
  static const Color skeletonCardBg = Color(0xFFF5F5F5);
}

class ThemeColors {
ThemeColors._();

static const Color white = Color(0xFFFFFFFF);
static const Color milkWhite = Color(0xFFEEEEEE);
static const Color secondaryColor = Color(0xFF992F59);
static const Color autoCompleteBorder = Color(0x4D000000);
static const Color mehroon = Color(0xFF77153C);
static const Color filterGray = Color(0xFF4D4D4D);
static const Color profileBlack = Color(0x80000000);
static const Color red2 = Color(0xFFD00000);
static const Color shopRemove = Color(0xFF404040);
static const Color sheetSeparator = Color(0xFFCFCFCF);
static const Color privacyGray = Color(0xFF555555);
static const Color shopCard = Color(0xFFEBEBEB);
static const Color textBackground = Color(0xFFF0EFEF);
static const Color shopBackgrond = Color(0xFFF4F4F4);
static const Color sheetButton = Color(0xFFEEEDFE);
static const Color primary = Color(0xFF7041EA);
static const Color settingGray = Color(0xFFD8D8D8);
static const Color dragIcon = Color(0xFFE0E0E0);
static const Color mapBackground = Color(0xFFDDDDDD);
static const Color lightBlue = Color(0x58584CF4);
static const Color shadow = Color(0xFF04060F);
static const Color shopDesc = Color(0xFF606060);
static const Color activeDot = Color(0xFF7369F8);
static const Color blueButton = Color(0xFF584CF4);
static const Color serach = Color(0xFFF5F5F5);
static const Color screenBackground = Color(0xFFF3F3F3);
static const Color Blue = Color(0xFF1B63B1);
static const Color searchText = Color(0xFFBDBDBD);
static const Color lightYellow = Color(0xFFFFFDF6);
static const Color whiteText = Color(0xFFFFFFFF);
static const Color textFieldBg = Color(0xFFFFFFFF);
static const Color darkPink = Color(0xFFC89CAB);
static const Color green = Color(0xFF07BD74);
static const Color greyText = Color(0xFF424242);
static const Color red = Color(0xFFF75555);
static const Color gery1 = Color(0xFFD9D9D9);
static const Color grey2 = Color(0xFF757575);
static const Color grey3 = Color(0xFF969696);
static const Color darkgray = Color(0xFF7D7D7D);
static const Color gray4 = Color(0xFF727272);
static const Color lightGrey = Color(0xFF616161);
static const Color border = Color(0xFF979595);
static const Color border1 = Color(0xFF8C8888);
static const Color black = Color(0xFF000000);
static const Color lightPink = Color(0xFFE8D8DE);
static const Color placeholder_gray = Color(0xFF4D5E76);
static const Color placeholderText = Color(0xFF9E9E9E);
}

class AppTheme {
AppTheme._();

static final ThemeData lightTheme = ThemeData(
brightness: Brightness.light,
primaryColor: ThemeColors.primary,
scaffoldBackgroundColor: ThemeColors.screenBackground,
// backgroundColor: ThemeColors.white,
cardColor: ThemeColors.white,
// errorColor: ThemeColors.red,
dividerColor: ThemeColors.sheetSeparator,
splashColor: ThemeColors.mehroon.withOpacity(0.12),
appBarTheme: const AppBarTheme(
backgroundColor: ThemeColors.white,
elevation: 0,
iconTheme: IconThemeData(color: ThemeColors.black),
titleTextStyle: TextStyle(
color: ThemeColors.black,
fontWeight: FontWeight.w700,
fontSize: 18,
),
),
colorScheme: const ColorScheme.light(
primary: ThemeColors.primary,
secondary: ThemeColors.mehroon,
background: ThemeColors.screenBackground,
surface: ThemeColors.white,
error: ThemeColors.red,
onPrimary: ThemeColors.white,
onSecondary: ThemeColors.white,
onBackground: ThemeColors.black,
onSurface: ThemeColors.black,
onError: ThemeColors.white,
),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: ThemeColors.black),
    displayMedium: TextStyle(color: ThemeColors.black),
    displaySmall: TextStyle(color: ThemeColors.black),
    headlineLarge: TextStyle(color: ThemeColors.black),
    headlineMedium: TextStyle(color: ThemeColors.black),
    headlineSmall: TextStyle(color: ThemeColors.black),
    bodyLarge: TextStyle(color: ThemeColors.greyText),
    bodyMedium: TextStyle(color: ThemeColors.grey2),
    titleLarge: TextStyle(color: ThemeColors.greyText),
    titleMedium: TextStyle(color: ThemeColors.grey3),
    bodySmall: TextStyle(color: ThemeColors.placeholderText),
    labelLarge: TextStyle(color: ThemeColors.white),
  ),
inputDecorationTheme: InputDecorationTheme(
filled: true,
fillColor: ThemeColors.textFieldBg,
border: OutlineInputBorder(
borderSide: const BorderSide(color: ThemeColors.border),
borderRadius: BorderRadius.circular(12),
),
enabledBorder: OutlineInputBorder(
borderSide: const BorderSide(color: ThemeColors.border),
borderRadius: BorderRadius.circular(12),
),
focusedBorder: OutlineInputBorder(
borderSide: const BorderSide(color: ThemeColors.primary),
borderRadius: BorderRadius.circular(12),
),
errorBorder: OutlineInputBorder(
borderSide: const BorderSide(color: ThemeColors.red),
borderRadius: BorderRadius.circular(12),
),
focusedErrorBorder: OutlineInputBorder(
borderSide: const BorderSide(color: ThemeColors.red),
borderRadius: BorderRadius.circular(12),
),
hintStyle: const TextStyle(color: ThemeColors.placeholderText),
),
elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(
backgroundColor: ThemeColors.primary,
foregroundColor: ThemeColors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
),
textButtonTheme: TextButtonThemeData(
style: TextButton.styleFrom(
foregroundColor: ThemeColors.mehroon,
),
),
floatingActionButtonTheme: const FloatingActionButtonThemeData(
backgroundColor: ThemeColors.primary,
foregroundColor: ThemeColors.white,
),
);
}