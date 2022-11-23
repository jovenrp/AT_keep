/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  String get blockBerthold => 'assets/fonts/Block-Berthold.ttf';
  String get productSansBoldItalic =>
      'assets/fonts/Product-Sans-Bold-Italic.ttf';
  String get productSansBold => 'assets/fonts/Product-Sans-Bold.ttf';
  String get productSansItalic => 'assets/fonts/Product-Sans-Italic.ttf';
  String get productSansRegular => 'assets/fonts/Product-Sans-Regular.ttf';
  String get proximaNovaBoldItalic =>
      'assets/fonts/Proxima-Nova-Bold-Italic.otf';
  String get proximaNovaBold => 'assets/fonts/Proxima-Nova-Bold.otf';
  String get proximaNovaItalic => 'assets/fonts/Proxima-Nova-Italic.otf';
  String get proximaNovaLightItalic =>
      'assets/fonts/Proxima-Nova-Light-Italic.otf';
  String get proximaNovaLight => 'assets/fonts/Proxima-Nova-Light.otf';
  String get proximaNovaRegular => 'assets/fonts/Proxima-Nova-Regular.otf';
  String get dawnIcons => 'assets/fonts/dawn-icons.ttf';
}

class $AssetsI18nGen {
  const $AssetsI18nGen();

  String get enUS => 'assets/i18n/en-US.json';
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  AssetGenImage get applogo =>
      const AssetGenImage('assets/images/applogo.jpeg');
  AssetGenImage get applogowhite =>
      const AssetGenImage('assets/images/applogowhite.jpeg');
  AssetGenImage get appnamelogo =>
      const AssetGenImage('assets/images/appnamelogo.png');
  AssetGenImage get logonameTransparent =>
      const AssetGenImage('assets/images/logoname_transparent.png');
  AssetGenImage get logotransparent =>
      const AssetGenImage('assets/images/logotransparent.png');
}

class Assets {
  Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsI18nGen i18n = $AssetsI18nGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage extends AssetImage {
  const AssetGenImage(String assetName) : super(assetName);

  Image image({
    Key? key,
    ImageFrameBuilder? frameBuilder,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image(
      key: key,
      image: this,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );
  }

  String get path => assetName;
}
