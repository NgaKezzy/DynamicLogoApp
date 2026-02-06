import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';

/// Enum representing available app icon types
enum AppIconType { defaultIcon, tet, christmas }

/// Service to manage dynamic app icon changes
class DynamicIconService {
  // Native channel for Android
  static const _androidChannel = MethodChannel(
    'com.example.dynamic_logo_app/icon',
  );

  /// Changes the app icon to the specified type
  ///
  /// On iOS: Uses flutter_dynamic_icon_plus
  /// On Android: Uses native MethodChannel for immediate effect
  Future<bool> setIcon(AppIconType iconType) async {
    try {
      String? iconName;
      switch (iconType) {
        case AppIconType.defaultIcon:
          iconName = null;
          break;
        case AppIconType.tet:
          iconName = 'tet_icon';
          break;
        case AppIconType.christmas:
          iconName = 'christmas_icon';
          break;
      }

      if (Platform.isAndroid) {
        // Use native channel for Android
        await _androidChannel.invokeMethod('setIcon', {'iconName': iconName});
        debugPrint('Android icon changed to: ${iconName ?? "default"}');
      } else if (Platform.isIOS) {
        // Use flutter_dynamic_icon_plus for iOS
        await FlutterDynamicIconPlus.setAlternateIconName(iconName: iconName);
        debugPrint('iOS icon changed to: ${iconName ?? "default"}');
      }
      return true;
    } catch (e) {
      debugPrint('Error changing app icon: $e');
      return false;
    }
  }

  /// Gets the current alternate icon name (null if using default)
  Future<String?> getCurrentIconName() async {
    try {
      if (Platform.isAndroid) {
        return await _androidChannel.invokeMethod<String?>('getIcon');
      } else if (Platform.isIOS) {
        return await FlutterDynamicIconPlus.alternateIconName;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current icon: $e');
      return null;
    }
  }

  /// Checks if changing app icons is supported on this device
  Future<bool> isSupported() async {
    try {
      if (Platform.isAndroid) {
        return true; // Android always supports this via activity-alias
      } else if (Platform.isIOS) {
        return await FlutterDynamicIconPlus.supportsAlternateIcons;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Automatically sets the appropriate icon based on current date
  ///
  /// - Tet: January 20 - February 10 (covers Lunar New Year period)
  /// - Christmas: December 20 - December 31
  /// - Default: All other times
  Future<void> autoSetIconByDate() async {
    final now = DateTime.now();

    // Tet period (late January to early February)
    if ((now.month == 1 && now.day >= 20) ||
        (now.month == 2 && now.day <= 10)) {
      await setIcon(AppIconType.tet);
    }
    // Christmas period
    else if (now.month == 12 && now.day >= 20) {
      await setIcon(AppIconType.christmas);
    }
    // Default for all other times
    else {
      await setIcon(AppIconType.defaultIcon);
    }
  }

  /// Gets the display name for an icon type
  String getIconDisplayName(AppIconType type) {
    switch (type) {
      case AppIconType.defaultIcon:
        return 'Mặc định';
      case AppIconType.tet:
        return 'Tết Nguyên Đán 🧧';
      case AppIconType.christmas:
        return 'Giáng Sinh 🎄';
    }
  }
}
