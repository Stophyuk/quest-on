import 'package:flutter/material.dart';
import 'package:quest_on/core/constants/app_constants.dart';

/// Quest ON 앱 테마
class AppTheme {
  // 컬러 팔레트 (Vibrant & Motivating)
  static const Color primaryColor = Color(0xFF8B5CF6); // Vivid Purple - 성장, 영감, 변화
  static const Color primaryLight = Color(0xFFA78BFA); // Light Purple
  static const Color primaryDark = Color(0xFF7C3AED); // Deep Purple
  static const Color secondaryColor = Color(0xFFEC4899); // Hot Pink - 에너지, 열정
  static const Color backgroundColor = Color(0xFFF5F3FF); // Soft Purple Tint - 따뜻함
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF22C55E); // Vibrant Green - 성취감 강조
  static const Color successLight = Color(0xFF4ADE80);
  static const Color warningColor = Color(0xFFFF9500); // Warm Orange - 따뜻한 배려
  static const Color goldColor = Color(0xFFFFD700); // Gold

  // 텍스트 컬러
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // UI 요소 컬러
  static const Color borderColor = Color(0xFFE5E7EB);

  // 컨디션별 컬러
  static const Map<int, Color> conditionColors = {
    AppConstants.conditionBest: Color(0xFF10B981), // Green
    AppConstants.conditionGood: Color(0xFF3B82F6), // Blue
    AppConstants.conditionNormal: Color(0xFFFBBF24), // Yellow
    AppConstants.conditionBad: Color(0xFFF59E0B), // Orange
    AppConstants.conditionWorst: Color(0xFFEF4444), // Red
  };

  // 카테고리별 컬러
  static const Map<String, Color> categoryColors = {
    AppConstants.categoryHealth: Color(0xFF10B981),
    AppConstants.categoryStudy: Color(0xFF6366F1),
    AppConstants.categoryWork: Color(0xFFF59E0B),
    AppConstants.categoryHobby: Color(0xFFEC4899),
    AppConstants.categoryRelationship: Color(0xFF8B5CF6),
    AppConstants.categoryOther: Color(0xFF6B7280),
  };

  // Opacity 상수 (Agent-Full.md: Magic Numbers 제거)
  static const double opacityVeryLight = 0.05;
  static const double opacityLight = 0.1;
  static const double opacityMedium = 0.2;
  static const double opacityHigh = 0.5;
  static const double opacityVeryHigh = 0.8;

  // 그라데이션 (Gradients for Motivation & Energy)
  static const LinearGradient motivationGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)], // Purple to Pink
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF06B6D4)], // Green to Cyan
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF9500), Color(0xFFFBBF24)], // Orange to Yellow
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 라이트 테마 (Agent-Full.md: 성능 최적화 - static final로 캐싱)
  static final ThemeData lightTheme = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: false,  // Temporarily disabled due to shader compiler issue
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,

      // AppBar 테마
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card 테마 (더 부드럽고 입체적으로)
      cardTheme: CardThemeData(
        elevation: 4, // 더 입체적
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 더 라운드하게
        ),
        color: surfaceColor,
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),

      // FloatingActionButton 테마
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // BottomNavigationBar 테마
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chip 테마
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryColor.withValues(alpha: opacityMedium),
        labelStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Input 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // ElevatedButton 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),

      // TextButton 테마
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // ProgressIndicator 테마
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Color(0xFFE5E7EB),
      ),

      // 텍스트 테마
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
      ),
    );
  }

  // 다크 테마 (추후 구현, Agent-Full.md: 성능 최적화 - static final로 캐싱)
  static final ThemeData darkTheme = lightTheme; // 일단 라이트 테마와 동일
}
