import 'package:ebroker/settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringPriceFormat on String {
  String priceFormat({
    required BuildContext context,
    bool? enabled,
  }) {
    var currencyCode = AppSettings.currencyCode;
    var currencySymbol = AppSettings.currencySymbol;

    try {
      final numericValue = double.parse(this);

      // When enabled is true, use custom abbreviation formatting
      if (enabled == true && currencyCode.isNotEmpty) {
        final config = CurrencyAbbreviationConfig.getForCurrency(
          currencyCode.toUpperCase(),
        );

        if (currencyCode.isEmpty) currencyCode = 'USD';
        if (currencySymbol.isEmpty) currencySymbol = r'$';
        for (final rule in config.rules) {
          if (numericValue >= rule.threshold) {
            final dividedValue = numericValue / rule.threshold;
            final formattedValue = dividedValue.toStringAsFixed(2);
            return '$currencySymbol$formattedValue${rule.suffix}';
          }
        }
      }

      // When enabled is false or no abbreviation rule matches
      if (numericValue % 1 == 0) {
        // Integer values
        return NumberFormat.currency(
          locale: AppSettings.priceFormat,
          symbol: currencySymbol,
          decimalDigits: 0,
        ).format(numericValue);
      } else {
        // Decimal values
        return NumberFormat.currency(
          locale: AppSettings.priceFormat,
          symbol: currencySymbol,
          decimalDigits: 2,
        ).format(numericValue);
      }
    } catch (e) {
      debugPrint('Error formatting price: $e');
      return this;
    }
  }
}

class CurrencyAbbreviationConfig {
  CurrencyAbbreviationConfig(this.rules);
  final List<AbbreviationRule> rules;

  // ignore: prefer_constructors_over_static_methods
  static CurrencyAbbreviationConfig getForCurrency(String currencyCode) {
    final southAsianCurrencies = ['INR', 'BDT', 'NPR', 'PKR', 'LKR'];
    final eastAsianCurrencies = ['JPY', 'CNY', 'KRW'];

    if (southAsianCurrencies.contains(currencyCode)) {
      return CurrencyAbbreviationConfig([
        AbbreviationRule(10000000, 'Cr'),
        AbbreviationRule(100000, 'L'),
        AbbreviationRule(1000, 'K'),
      ]);
    } else if (eastAsianCurrencies.contains(currencyCode)) {
      return CurrencyAbbreviationConfig([
        AbbreviationRule(100000000, '億'),
        AbbreviationRule(10000, '万'),
      ]);
    } else {
      // Western system (default)
      return CurrencyAbbreviationConfig([
        AbbreviationRule(1000000000, 'B'),
        AbbreviationRule(1000000, 'M'),
        AbbreviationRule(1000, 'K'),
      ]);
    }
  }
}

class AbbreviationRule {
  AbbreviationRule(this.threshold, this.suffix);
  final int threshold;
  final String suffix;
}
