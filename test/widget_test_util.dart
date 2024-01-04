import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class WidgetTestUtil {
  static Widget wrapWidgetWithMaterialApp({
    @required Widget widget,
    Locale selectedLocale = const Locale.fromSubtags(languageCode: 'en'),
    bool isGoldenTest = false,
  }) {
    return MaterialApp(
      locale: selectedLocale,
      localizationsDelegates: isGoldenTest
          ? [
              R.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ]
          : null,
      supportedLocales: R.delegate.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (R.delegate.isSupported(locale)) {
          return locale;
        }

        return Locale.fromSubtags(languageCode: selectedLocale.languageCode);
      },
      home: widget,
    );
  }

  /// Runs the onTap handler for the [TextSpan] which matches the search-string.
  static void fireOnTap(Finder finder, String text) {
    final Element element = finder.evaluate().single;
    final RenderParagraph paragraph = element.renderObject as RenderParagraph;
    // The children are the individual TextSpans which have GestureRecognizers
    paragraph.text.visitChildren((dynamic span) {
      if (span.text != text) return true; // continue iterating.

      (span.recognizer as TapGestureRecognizer).onTap();
      return false; // stop iterating, we found the one.
    });
  }
}
