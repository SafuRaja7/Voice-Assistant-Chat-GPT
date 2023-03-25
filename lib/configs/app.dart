import 'dart:math';

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import 'app_dimensions.dart';
import 'app_theme.dart';
import 'app_typography.dart';
import 'space.dart';
import 'ui.dart';
import 'ui_props.dart';

class App {
  static bool? isLtr;
  static bool showAds = false;

  static init(BuildContext context) async {
    UI.init(context);
    AppDimensions.init();
    AppTheme.init(context);
    UIProps.init();
    Space.init();
    AppText.init();

    isLtr = Directionality.of(context) == TextDirection.ltr;
  }

  static String format(num number, [String? currencyPrefix]) {
    if (currencyPrefix != null && currencyPrefix.contains(" ")) {
      currencyPrefix = currencyPrefix.substring(0, currencyPrefix.length - 1);
    }
    return NumberFormat.currency(
      locale: 'ur',
      symbol: currencyPrefix ?? '\$',
      decimalDigits: 0,
    ).format(
      number,
    );
  }

  static String id() {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();

    return String.fromCharCodes(
      Iterable.generate(
        12,
        (_) => chars.codeUnitAt(
          rnd.nextInt(chars.length),
        ),
      ),
    );
  }

  static String requestId() {
    final date = DateFormat('MM / yyyy').format(DateTime.now());
    String uniqueId = DateTime.now().microsecondsSinceEpoch.toString();
    String uniqueIdTrim = uniqueId.substring(uniqueId.length - 6);
    String id = 'HOP-$date/$uniqueIdTrim';
    return id;
  }

  static FormFieldValidator<String> name(
    BuildContext context, {
    String? errorText,
    bool allowSpace = true,
  }) {
    return (string) {
      final parsed = string?.trim();
      final isEmpty = FormBuilderValidators.required(
        errorText: errorText,
      )(parsed);
      if (isEmpty != null) {
        return isEmpty;
      }
      return FormBuilderValidators.match(
        RegExp('^[a-zA-Z ]*\$').pattern,
        errorText: errorText,
      )(parsed);
    };
  }
}
