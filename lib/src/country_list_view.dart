import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:collection/collection.dart' show IterableExtension;
import 'country_list_theme_data.dart';
import 'country_localizations.dart';
import 'utils.dart';

import 'country_codes.dart';
import 'country_code.dart';

class CountryListView extends StatefulWidget {
  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<CountryCode>? onSelect;

  /// An optional [favorite] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? favorite;

  /// An optional argument for customizing the
  /// country list bottom sheet.
  final CountryListThemeData? countryListTheme;

  /// An optional argument for initially expanding virtual keyboard
  final bool searchAutofocus;

  const CountryListView({
    Key? key,
    this.onSelect,
    this.favorite,
    this.countryListTheme,
    this.searchAutofocus = false,
  }) : super(key: key);

  @override
  _CountryListViewState createState() => _CountryListViewState();
}

class _CountryListViewState extends State<CountryListView> {
  late List<CountryCode> _countryList;
  late List<CountryCode> _filteredList;
  late bool _searching;
  List<CountryCode>? _favoriteList;
  late TextEditingController _searchController;
  late bool _searchAutofocus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searching = false;

    List<Map<String, String>> jsonList = codes;

    _countryList = jsonList.map((json) => CountryCode.fromJson(json)).toList();

    if (widget.favorite != null) {
      _favoriteList = _countryList
          .where((e) =>
              widget.favorite!.firstWhereOrNull((f) =>
                  e.code!.toUpperCase() == f.toUpperCase() ||
                  e.dialCode == f ||
                  e.name!.toUpperCase() == f.toUpperCase()) !=
              null)
          .toList();
      ;
    }

    _filteredList = <CountryCode>[];
    _filteredList.addAll(_countryList);

    _searchAutofocus = widget.searchAutofocus;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: TextField(
            autofocus: _searchAutofocus,
            controller: _searchController,
            cursorColor: Color(0xff6a6a6a),
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: EdgeInsets.all(8),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff6a6a6a), width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffb6b9c1), width: 2)),
              hintText: widget.countryListTheme?.hintText ?? "",
              hintStyle: TextStyle(
                  color: const Color(0xffacacac),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Pretendard",
                  fontStyle: FontStyle.normal,
                  fontSize: 12.0),
              suffixIcon: _searching
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterSearchResults("");
                      },
                      color: Color(0xffb6b9c1),
                    )
                  : null,
            ),
            onChanged: _filterSearchResults,
          ),
        ),
        Expanded(
          child: Container(
              color: Colors.white,
              child: ListView(
                children: [
                  if (_searching) ...[
                    _listHeader(widget.countryListTheme?.searchingText ?? ""),
                    ..._convertSearchCountryList(_filteredList),
                  ] else ...[
                    if (_favoriteList != null) ...[
                      _listHeader(widget.countryListTheme?.favoriteText ?? ""),
                      ..._favoriteList!
                          .map<Widget>((currency) => _listRow(currency))
                          .toList(),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                    ..._convertCountryList(_filteredList)
                  ],
                ],
              )),
        ),
      ],
    );
  }

  List<Widget> _convertSearchCountryList(List<CountryCode> countryList) {
    List<Widget> result = <Widget>[];

    if (countryList.isEmpty) {
      result.add(SizedBox(
        height: 24,
      ));
      result.add(Center(
        child: Text(widget.countryListTheme?.emptyText ?? "",
            style: const TextStyle(
                color: const Color(0xffafafaf),
                fontWeight: FontWeight.w400,
                fontFamily: "Pretendard",
                fontStyle: FontStyle.normal,
                fontSize: 12.0)),
      ));
    } else {
      result.addAll(
          countryList.map<Widget>((country) => _listRow(country)).toList());
    }
    result.add(SizedBox(
      height: 12,
    ));
    return result;
  }

  List<Widget> _convertCountryList(List<CountryCode> countryList) {
    List<Widget> result = <Widget>[];

    Map<String, List<CountryCode>> groupedLists = {};
    countryList.forEach((country) {
      String name = country.name ?? "";
      if (groupedLists['${name[0]}'] == null) {
        groupedLists['${name[0]}'] = <CountryCode>[];
      }

      groupedLists['${name[0]}']!.add(country);
    });

    for (var entry in groupedLists.entries) {
      result.add(Divider(
        thickness: 8,
        color: Color(0xffebebeb),
      ));

      result.add(_listHeader(entry.key));
      result.addAll(
          entry.value.map<Widget>((country) => _listRow(country)).toList());

      result.add(SizedBox(
        height: 12,
      ));
    }
    return result;
  }

  Widget _listHeader(String text) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: Row(
            children: [
              Container(
                height: 4,
                width: 4,
                decoration: BoxDecoration(
                  color: Color(0xff23242a),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text(text)
            ],
          ),
        ),
        Container(
          height: 1,
          decoration: BoxDecoration(
            color: Color(0xffe9e9e9),
          ),
        ),
        SizedBox(
          height: 12,
        ),
      ],
    );
  }

  Widget _listRow(CountryCode country) {
    final TextStyle _textStyle =
        widget.countryListTheme?.textStyle ?? _defaultTextStyle;

    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onSelect?.call(country);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(width: 35),
              Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    country.name ?? "",
                    softWrap: false,
                    style: _textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
              SizedBox(
                width: 55,
                child: Text(
                  country.dialCode ?? "",
                  style: _textStyle,
                ),
              ),
              const SizedBox(width: 40),
              //_flagWidget(country),,
            ],
          ),
        ),
      ),
    );
  }

  void _filterSearchResults(String query) {
    List<CountryCode> _searchResult = <CountryCode>[];
    final CountryLocalizations? localizations =
        CountryLocalizations.of(context);

    if (query.isEmpty) {
      _searching = false;
      _searchResult.addAll(_countryList);
    } else {
      _searching = true;
      String s = query.toUpperCase();

      _searchResult = _countryList
          .where((e) =>
              e.code!.contains(s) ||
              e.dialCode!.contains(s) ||
              e.name!.toUpperCase().contains(s))
          .toList();
    }

    setState(() {
      _filteredList = _searchResult;
    });
  }

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 16);
}
