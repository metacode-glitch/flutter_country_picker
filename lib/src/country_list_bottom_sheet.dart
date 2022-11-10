import 'package:flutter/material.dart';

import 'country_list_theme_data.dart';
import 'country_list_view.dart';
import 'country_code.dart';

void showCountryListBottomSheet({
  required BuildContext context,
  ValueChanged<CountryCode>? onSelect,
  VoidCallback? onClosed,
  List<String>? favorite,
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
      countryListTheme,
      searchAutofocus,
    ),
  ).whenComplete(() {
    if (onClosed != null) onClosed();
  });
}

Widget _builder(
  BuildContext context,
  ValueChanged<CountryCode>? onSelect,
  List<String>? favorite,
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

  final BorderRadius _borderRadius = const BorderRadius.only(
    topLeft: Radius.circular(10.0),
    topRight: Radius.circular(10.0),
  );

  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
          width: 44,
          height: 44,
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
          color: Color(0xffeaebf4),
          borderRadius: _borderRadius,
          //border: Border.all(
          //  width: 1,
          //  color: Colors.orange,
          //),
        ),
        child: CountryListView(
          onSelect: onSelect,
          favorite: favorite,
          countryListTheme: countryListTheme,
          searchAutofocus: searchAutofocus,
        ),
      )
    ],
  );
}
