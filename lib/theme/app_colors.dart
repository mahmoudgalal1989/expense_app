import 'package:flutter/material.dart';

class AppColors {
  // ===== Core Colors =====

  // Light Theme Colors
  static const Color light0 = Color(0xFFFFFFFF);
  static const Color light50 = Color(0xFFF2F4F8);
  static const Color light100 = Color(0xFFE5E9EC);
  static const Color light200 = Color(0xFFBCC4CB);
  static const Color light300 = Color(0xFF8B98A4);
  static const Color light400 = Color(0xFF626B72);
  static const Color light500 = Color(0xFF1E2A34);

  // Dark Theme Colors
  static const Color dark0 = Color(0xFFFFFFFF);
  static const Color dark100 = Color(0xFFACB0B3);
  static const Color dark200 = Color(0xFF9EA0A3);
  static const Color dark300 = Color(0xFF868A8D);
  static const Color dark400 = Color(0xFF6E7276);
  static const Color dark500 = Color(0xFF565B5F);
  static const Color dark600 = Color(0xFF3D4348);
  static const Color dark700 = Color(0xFF32383E);
  static const Color dark800 = Color(0xFF1E252A);
  static const Color dark900 = Color(0xFF151A1F);

  // Semantic Colors
  static const Color error50 = Color(0xFFFBECEB);
  static const Color error100 = Color(0xFFF7D6D6);
  static const Color error300 = Color(0xFFE88584);
  static const Color error500 = Color(0xFFDC4847);
  static const Color error700 = Color(0xFF821F1E);

  static const Color success50 = Color(0xFFEBF7F1);
  static const Color success100 = Color(0xFFD8EDE4);
  static const Color success300 = Color(0xFF49DE9A);
  static const Color success500 = Color(0xFF3AAB78);
  static const Color success700 = Color(0xFF236748);

  static const Color warning50 = Color(0xFFFFF4E5);
  static const Color warning100 = Color(0xFFFFEDCC);
  static const Color warning300 = Color(0xFFFFC666);
  static const Color warning500 = Color(0xFFFFA100);
  static const Color warning700 = Color(0xFF996000);

  static const Color information50 = Color(0xFFE5F3F8);
  static const Color information100 = Color(0xFFCCE6F0);
  static const Color information300 = Color(0xFF66B5D1);
  static const Color information500 = Color(0xFF0084B3);
  static const Color information700 = Color(0xFF004F6B);

  // Opacity Colors
  static const Color opacity5 = Color(0x0DFFFFFF);
  static const Color opacity8 = Color(0x14FFFFFF);
  static const Color opacity15 = Color(0x26FFFFFF);
  static const Color opacity20 = Color(0x33FFFFFF);
  static const Color opacity40 = Color(0x66FFFFFF);

  // Premium Color
  static const Color premium = Color(0xFF0CBBA1);

  // ===== Text Colors =====
  static const textPrimaryLight = light500;
  static const textPrimaryDark = dark0;
  
  static const textSecondaryLight = light300;
  static const textSecondaryDark = dark300;
  
  static const textTertiaryLight = light300;
  static const textTertiaryDark = dark400;
  
  static const textInvertedLight = light0;
  static const textInvertedDark = dark900;
  
  static const textSuccessLight = success500;
  static const textSuccessDark = success300;
  
  static const textErrorLight = error500;
  static const textErrorDark = error300;
  
  static const textPremiumLight = premium;
  static const textPremiumDark = premium;
  
  static const textOpacityLight = light300;
  static const textOpacityDark = opacity40;

  // ===== Background Colors =====
  
  // Background - Base
  static const bgPrimaryLight = light50;
  static const bgPrimaryDark = dark900;
  
  static const bgSecondaryLight = light0;
  static const bgSecondaryDark = dark800;
  
  static const bgTertiaryLight = light50;
  static const bgTertiaryDark = dark700;
  
  // Background - Inverted
  static const bgInvertedPrimaryLight = light500;
  static const bgInvertedPrimaryDark = dark0;
  
  static const bgInvertedSecondaryLight = light0;
  static const bgInvertedSecondaryDark = dark100;
  
  // Background - Opacity
  static const bg5Light = light50;
  static const bg5Dark = opacity5;
  
  static const bg8Light = light0;
  static const bg8Dark = opacity8;
  
  static const bg15PressedLight = light0;
  static const bg15PressedDark = opacity15;
  
  static const bg20Light = light0;
  static const bg20Dark = opacity20;
  
  static const bg40Light = light0;
  static const bg40Dark = opacity40;
  
  // Background - Status
  static const bgDeleteLight = light0;
  static const bgDeleteDark = error500;
  
  static const bgSuccessPrimaryLight = success100;
  static const bgSuccessPrimaryDark = success500;
  
  static const bgSuccessSecondaryLight = success500;
  static const bgSuccessSecondaryDark = success50;
  
  static const bgErrorPrimaryLight = error100;
  static const bgErrorPrimaryDark = error500;
  
  static const bgErrorSecondaryLight = error500;
  static const bgErrorSecondaryDark = error50;
  
  // Background - Foreground
  static const bgFgPrimaryLight = light0;
  static const bgFgPrimaryDark = dark900;
  
  static const bgFgSecondaryLight = light100;
  static const bgFgSecondaryDark = dark500;
  
  static const bgFgTertiaryLight = light300;
  static const bgFgTertiaryDark = dark300;
  
  static const bgFgInvertedLight = light500;
  static const bgFgInvertedDark = dark0;

  // ===== Border Colors =====
  static const borderPrimaryLight = light100;
  static const borderPrimaryDark = opacity8;

  static const borderSecondaryLight = light100;
  static const borderSecondaryDark = dark600;

  static const borderSelectedLight = light500;
  static const borderSelectedDark = dark0;

  // ===== Category Colors =====
  static const Map<String, Color> categoryColors = {
    'F76775': Color(0xFFF76775),
    'F46262': Color(0xFFF46262),
    'F78667': Color(0xFFF78667),
    'F49862': Color(0xFFF49862),
    'FB923C': Color(0xFFFB923C),
    'FBBF24': Color(0xFFFBBF24),
    'FACC15': Color(0xFFFACC15),
    '60A5FA': Color(0xFF60A5FA),
    '11B8FF': Color(0xFF11B8FF),
    '22D3EE': Color(0xFF22D3EE),
    '2DD4BF': Color(0xFF2DD4BF),
    '34D399': Color(0xFF34D399),
    '4ADE80': Color(0xFF4ADE80),
    'A3E635': Color(0xFFA3E635),
    'F9C463': Color(0xFFF9C463),
    'F3D04F': Color(0xFFF3D04F),
    'F39C12': Color(0xFFF39C12),
    '7965AE': Color(0xFF7965AE),
    'DD8A06': Color(0xFFDD8A06),
    'D35400': Color(0xFFD35400),
    'B24902': Color(0xFFB24902),
    'A63414': Color(0xFFA63414),
    '27AE60': Color(0xFF27AE60),
    '5BC953': Color(0xFF5BC953),
    '818CF8': Color(0xFF818CF8),
    '9CA66E': Color(0xFF9CA66E),
    'A8C85B': Color(0xFFA8C85B),
    '9B882B': Color(0xFF9B882B),
    '9C6B1A': Color(0xFF9C6B1A),
    'ADB749': Color(0xFFADB749),
    'C94C46': Color(0xFFC94C46),
    'E879F9': Color(0xFFE879F9),
    'E36B67': Color(0xFFE36B67),
    'F472B6': Color(0xFFF472B6),
    'BF6CFF': Color(0xFFBF6CFF),
    'A78BFA': Color(0xFFA78BFA),
    'C084FC': Color(0xFFC084FC),
    '64748B': Color(0xFF64748B),
    '9C59B6': Color(0xFF9C59B6),
    'A33D8A': Color(0xFFA33D8A),
    '7268FF': Color(0xFF7268FF),
  };

  // ===== Gradients =====
  static const List<Color> backgroundGradient = [
    Color(0xFF1A1E1F),
    Color(0xFF0C0F11),
  ];

  // Button gradient
  static const List<Color> buttonGradient = [
    Color(0xFFEFF2F6),
    Color(0xFFDFDFDF),
  ];

  // ===== Legacy Colors (to be deprecated) =====
  @Deprecated('Use textPrimaryLight/Dark instead')
  static const textPrimary = Colors.white;

  @Deprecated('Use textSecondaryLight/Dark instead')
  static const textSecondary = Color(0xFF8A8A8A);

  @Deprecated('Use textDark instead of dark900')
  static const textDark = Color(0xFF151A1F);

  @Deprecated('Use borderPrimaryLight/Dark instead')
  static const borderLight = Colors.white;

  @Deprecated('Use appropriate shadow color from theme')
  static const shadow = Color.fromRGBO(0, 0, 0, 0.1);

  @Deprecated('Use appropriate theme color')
  static const navBarUnselected = Color.fromRGBO(255, 255, 255, 0.7);

  @Deprecated('Use appropriate theme color')
  static const divider = Color(0x14FFFFFF);

  @Deprecated('Use appropriate theme color')
  static const cardBackground = Color(0xFF1A1E1F);
}
