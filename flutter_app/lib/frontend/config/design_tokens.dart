import 'package:flutter/material.dart';

/// Design Tokens from Figma
/// 
/// TO UPDATE: Replace the values below with your Figma design tokens
/// You can find these in Figma by:
/// 1. Selecting elements and checking their properties
/// 2. Using Figma plugins like "Design Tokens" to export
/// 3. Manually noting down colors, fonts, and spacing from your design

class FigmaDesignTokens {
  // ============================================
  // COLORS - Update these with your Figma colors
  // ============================================
  
  /// Primary brand color (main app color) - From Figma Splash Screen
  static const Color primary = Color(0xFFF55D5D); // Vibrant red from Figma
  
  /// Secondary brand color
  static const Color secondary = Color(0xFF4CAF50); // SmartPrice Green
  
  /// Background color for screens
  static const Color background = Color(0xFFF5F5F5); // Light gray
  
  /// Splash screen background color - From Figma
  static const Color splashBackground = Color(0xFFF55D5D); // Vibrant red background
  
  /// Surface color for cards/containers
  static const Color surface = Color(0xFFFFFFFF); // White (update from Figma)
  
  /// Primary text color
  static const Color textPrimary = Color(0xFF1A1A1A); // Dark gray (update from Figma)
  
  /// Secondary text color
  static const Color textSecondary = Color(0xFF808080); // Medium gray (update from Figma)
  
  /// Accent color for highlights
  static const Color accent = Color(0xFFE53935); // Red accent (update from Figma)
  
  /// Error color
  static const Color error = Color(0xFFE53935); // Red (update from Figma)
  
  /// Success color
  static const Color success = Color(0xFF4CAF50); // Green (update from Figma)
  
  /// Warning color
  static const Color warning = Color(0xFFFF9800); // Orange (update from Figma)
  
  /// Info color
  static const Color info = Color(0xFF2196F3); // Blue (update from Figma)
  
  // ============================================
  // TYPOGRAPHY - Update these with your Figma fonts
  // ============================================
  
  /// Primary font family (update from Figma)
  static const String fontFamily = 'Roboto'; // Update with your Figma font
  
  /// Display/Large heading font size
  static const double fontSizeDisplay = 32.0; // Update from Figma
  
  /// H1 heading font size
  static const double fontSizeH1 = 28.0; // Update from Figma
  
  /// H2 heading font size
  static const double fontSizeH2 = 24.0; // Update from Figma
  
  /// H3 heading font size
  static const double fontSizeH3 = 20.0; // Update from Figma
  
  /// Body text font size
  static const double fontSizeBody = 16.0; // Update from Figma
  
  /// Small text font size
  static const double fontSizeSmall = 14.0; // Update from Figma
  
  /// Caption font size
  static const double fontSizeCaption = 12.0; // Update from Figma
  
  /// Font weight regular
  static const FontWeight fontWeightRegular = FontWeight.w400;
  
  /// Font weight medium
  static const FontWeight fontWeightMedium = FontWeight.w500;
  
  /// Font weight semi-bold
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  
  /// Font weight bold
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // ============================================
  // SPACING - Update these with your Figma spacing
  // ============================================
  
  /// Extra small spacing (4px)
  static const double spacingXS = 4.0;
  
  /// Small spacing (8px)
  static const double spacingSM = 8.0;
  
  /// Medium spacing (16px)
  static const double spacingMD = 16.0;
  
  /// Large spacing (24px)
  static const double spacingLG = 24.0;
  
  /// Extra large spacing (32px)
  static const double spacingXL = 32.0;
  
  /// Extra extra large spacing (48px)
  static const double spacingXXL = 48.0;
  
  // ============================================
  // BORDER RADIUS - Update these with your Figma values
  // ============================================
  
  /// Small border radius (4px)
  static const double radiusSmall = 4.0;
  
  /// Medium border radius (8px)
  static const double radiusMedium = 8.0;
  
  /// Large border radius (12px)
  static const double radiusLarge = 12.0;
  
  /// Extra large border radius (16px)
  static const double radiusXL = 16.0;
  
  /// Extra extra large border radius (24px)
  static const double radiusXXL = 24.0;
  
  /// Full circle border radius
  static const double radiusFull = 9999.0;
  
  // ============================================
  // ELEVATION/SHADOWS - Update these with your Figma values
  // ============================================
  
  /// Small elevation (1dp)
  static const double elevationSmall = 1.0;
  
  /// Medium elevation (2dp)
  static const double elevationMedium = 2.0;
  
  /// Large elevation (4dp)
  static const double elevationLarge = 4.0;
  
  /// Extra large elevation (8dp)
  static const double elevationXL = 8.0;
  
  // ============================================
  // ICON SIZES - Update these with your Figma values
  // ============================================
  
  /// Small icon size (16px)
  static const double iconSizeSmall = 16.0;
  
  /// Medium icon size (24px)
  static const double iconSizeMedium = 24.0;
  
  /// Large icon size (32px)
  static const double iconSizeLarge = 32.0;
  
  /// Extra large icon size (48px)
  static const double iconSizeXL = 48.0;
  
  // ============================================
  // BUTTON HEIGHTS - Update these with your Figma values
  // ============================================
  
  /// Small button height (32px)
  static const double buttonHeightSmall = 32.0;
  
  /// Medium button height (48px)
  static const double buttonHeightMedium = 48.0;
  
  /// Large button height (56px)
  static const double buttonHeightLarge = 56.0;
  
  // ============================================
  // TEXT STYLES - Pre-configured text styles
  // ============================================
  
  static TextStyle get textDisplay => TextStyle(
    fontSize: fontSizeDisplay,
    fontWeight: fontWeightBold,
    color: textPrimary,
    fontFamily: fontFamily,
  );
  
  static TextStyle get textH1 => TextStyle(
    fontSize: fontSizeH1,
    fontWeight: fontWeightBold,
    color: textPrimary,
    fontFamily: fontFamily,
  );
  
  static TextStyle get textH2 => TextStyle(
    fontSize: fontSizeH2,
    fontWeight: fontWeightSemiBold,
    color: textPrimary,
    fontFamily: fontFamily,
  );
  
  static TextStyle get textH3 => TextStyle(
    fontSize: fontSizeH3,
    fontWeight: fontWeightSemiBold,
    color: textPrimary,
    fontFamily: fontFamily,
  );
  
  static TextStyle get textBody => TextStyle(
    fontSize: fontSizeBody,
    fontWeight: fontWeightRegular,
    color: textPrimary,
    fontFamily: fontFamily,
  );
  
  static TextStyle get textBodySecondary => TextStyle(
    fontSize: fontSizeBody,
    fontWeight: fontWeightRegular,
    color: textSecondary,
    fontFamily: fontFamily,
  );
  
  static TextStyle get textSmall => TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: fontWeightRegular,
    color: textPrimary,
    fontFamily: fontFamily,
  );
  
  static TextStyle get textCaption => TextStyle(
    fontSize: fontSizeCaption,
    fontWeight: fontWeightRegular,
    color: textSecondary,
    fontFamily: fontFamily,
  );
}

