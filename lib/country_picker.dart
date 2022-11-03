library country_picker;

import 'package:flutter/material.dart';

import 'src/country_code.dart';
import 'src/country_codes.dart';
import 'src/country_list_bottom_sheet.dart';
import 'src/country_list_theme_data.dart';

export 'src/country_code.dart';
export 'src/country_list_theme_data.dart';
export 'src/country_localizations.dart';

class CountryCodePicker extends StatefulWidget {
  final ValueChanged<CountryCode>? onSelect;
  final List<String>? favorite;
  final CountryListThemeData? countryListTheme;
  final String? initialSelection;
  const CountryCodePicker({
    Key? key,
    this.onSelect,
    this.favorite,
    this.countryListTheme,
    this.initialSelection,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CountryCodePickerState();
  }
}

class CountryCodePickerState extends State<CountryCodePicker> {
  String _selectedCountry = "";

  @override
  void initState() {
    super.initState();

    if (widget.initialSelection != null) {
      const List<Map<String, String>> jsonList = codes;

      final countryList =
          jsonList.map((json) => CountryCode.fromJson(json)).toList();
      final find = countryList.firstWhere(
        (element) =>
            element.code == widget.initialSelection ||
            element.dialCode == widget.initialSelection,
        orElse: () => CountryCode(),
      );
      if (find.name != null) {
        _selectedCountry = "${find.dialCode} ${find.name}";
        return;
      }
    }
    _selectedCountry = widget.countryListTheme?.defaultText ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle =
        widget.countryListTheme?.labelTextStyle ?? _defaultTextStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.countryListTheme?.labelText ?? "",
          style: textStyle,
        ),
        OutlinedButton(
          onPressed: () {
            showCountryPicker(
              context: context,
              onSelect: (value) {
                setState(() {
                  _selectedCountry = "${value.dialCode} ${value.name}";
                });
                widget.onSelect?.call(value);
              },
              countryListTheme: widget.countryListTheme,
              favorite: widget.favorite,
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.fromLTRB(9, 5, 9, 5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.countryListTheme?.downArrow != null) ...[
                _selectedCountyText(_selectedCountry),
                widget.countryListTheme!.downArrow!
              ] else ...[
                _selectedCountyText(_selectedCountry),
              ]
            ],
          ),
        )
      ],
    );
  }

  Widget _selectedCountyText(String text) {
    final TextStyle textStyle =
        widget.countryListTheme?.buttonCountyNameTextStyle ?? _defaultTextStyle;

    return Flexible(
        fit: FlexFit.tight,
        child: Text(
          text,
          softWrap: false,
          style: textStyle.copyWith(color: const Color(0xff4d4d4d)),
        ));
  }

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 16);
}

/// Shows a bottom sheet containing a list of countries to select one.
///
/// The callback function [onSelect] call when the user select a country.
/// The function called with parameter the country that the user has selected.
/// If the user cancels the bottom sheet, the function is not call.
///
///  An optional [exclude] argument can be used to exclude(remove) one ore more
///  country from the countries list. It takes a list of country code(iso2).
///
/// An optional [countryFilter] argument can be used to filter the
/// list of countries. It takes a list of country code(iso2).
/// Note: Can't provide both [countryFilter] and [exclude]
///
/// An optional [favorite] argument can be used to show countries
/// at the top of the list. It takes a list of country code(iso2).
///
/// An optional [showPhoneCode] argument can be used to show phone code.
///
/// [countryListTheme] can be used to customizing the country list bottom sheet.
///
/// [onClosed] callback which is called when CountryPicker is dismiss,
/// whether a country is selected or not.
///
/// [searchAutofocus] can be used to initially expand virtual keyboard
///
/// The `context` argument is used to look up the [Scaffold] for the bottom
/// sheet. It is only used when the method is called. Its corresponding widget
/// can be safely removed from the tree before the bottom sheet is closed.
void showCountryPicker({
  required BuildContext context,
  ValueChanged<CountryCode>? onSelect,
  VoidCallback? onClosed,
  List<String>? favorite,
  CountryListThemeData? countryListTheme,
  bool searchAutofocus = false,
}) {
  showCountryListBottomSheet(
    context: context,
    onSelect: onSelect,
    onClosed: onClosed,
    favorite: favorite,
    countryListTheme: countryListTheme,
    searchAutofocus: searchAutofocus,
  );
}
