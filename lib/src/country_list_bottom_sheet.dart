import 'package:flutter/material.dart';

import 'country.dart';
import 'country_list_theme_data.dart';
import 'country_list_view.dart';

void showCountryListBottomSheet({
  required BuildContext context,
  required ValueChanged<Country> onSelect,
  VoidCallback? onClosed,
  List<String>? favorite,
  List<String>? exclude,
  List<String>? countryFilter,
  CountryListThemeData? countryListTheme,
  bool searchAutofocus = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _builder(
      context,
      onSelect,
      favorite,
      exclude,
      countryFilter,
      countryListTheme,
      searchAutofocus,
    ),
  ).whenComplete(() {
    if (onClosed != null) onClosed();
  });
}

Widget _builder(
  BuildContext context,
  ValueChanged<Country> onSelect,
  List<String>? favorite,
  List<String>? exclude,
  List<String>? countryFilter,
  CountryListThemeData? countryListTheme,
  bool searchAutofocus,
) {
  final device = MediaQuery.of(context).size.height;
  final statusBarHeight = MediaQuery.of(context).padding.top;
  final height = countryListTheme?.bottomSheetHeight ?? device * 0.6;
  //device - (statusBarHeight + (kToolbarHeight / 1.5));

  Color? _backgroundColor = countryListTheme?.backgroundColor ??
      Theme.of(context).bottomSheetTheme.backgroundColor;
  if (_backgroundColor == null) {
    if (Theme.of(context).brightness == Brightness.light) {
      _backgroundColor = Colors.white;
    } else {
      _backgroundColor = Colors.black;
    }
  }

  final BorderRadius _borderRadius = countryListTheme?.borderRadius ??
      const BorderRadius.only(
        topLeft: Radius.circular(40.0),
        topRight: Radius.circular(40.0),
      );

  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
          width: 45,
          height: 45,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            backgroundColor: Colors.white,
            child: Icon(Icons.close, color: Colors.black),
          )),
      SizedBox(height: 15),
      Container(
        height: height,
        decoration: BoxDecoration(
          color: Color(0xfff1f1f1),
          borderRadius: _borderRadius,
          //border: Border.all(
          //  width: 1,
          //  color: Colors.orange,
          //),
        ),
        child: CountryListView(
          onSelect: onSelect,
          exclude: exclude,
          favorite: favorite,
          countryFilter: countryFilter,
          countryListTheme: countryListTheme,
          searchAutofocus: searchAutofocus,
        ),
      )
    ],
  );
}
