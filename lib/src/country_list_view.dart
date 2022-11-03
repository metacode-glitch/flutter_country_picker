import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'country_code.dart';
import 'country_codes.dart';
import 'country_list_theme_data.dart';

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
  late String _query;
  List<CountryCode>? _favoriteList;
  late TextEditingController _searchController;
  late bool _searchAutofocus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searching = false;

    const List<Map<String, String>> jsonList = codes;

    _countryList = jsonList.map((json) => CountryCode.fromJson(json)).toList();

    if (widget.favorite != null) {
      _favoriteList = _countryList
          .where(
            (e) =>
                widget.favorite!.firstWhereOrNull((f) =>
                    e.code!.toUpperCase() == f.toUpperCase() ||
                    e.dialCode == f ||
                    e.name!.toUpperCase() == f.toUpperCase()) !=
                null,
          )
          .toList();
    }

    _filteredList = <CountryCode>[];
    _searchAutofocus = widget.searchAutofocus;
    _filteredList.addAll(_countryList);
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
            cursorColor: const Color(0xff6a6a6a),
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.all(8),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff6a6a6a), width: 2),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffb6b9c1), width: 2),
              ),
              hintText: widget.countryListTheme?.hintText ?? "",
              hintStyle: const TextStyle(
                  color: Color(0xffacacac),
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 12.0),
              suffixIcon: _searching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterSearchResults("");
                      },
                      color: const Color(0xffb6b9c1),
                    )
                  : null,
            ),
            onChanged: _filterSearchResults,
          ),
        ),
        Expanded(
          child: ColoredBox(
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
                      const SizedBox(
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
    final TextStyle textStyle =
        widget.countryListTheme?.textStyle ?? _defaultTextStyle;
    final List<Widget> result = <Widget>[];
    if (countryList.isEmpty) {
      result.add(
        const SizedBox(
          height: 24,
        ),
      );
      result.add(
        Center(
          child: Text(
            widget.countryListTheme?.emptyText ?? "",
            style: textStyle.copyWith(color: const Color(0xffafafaf)),
          ),
        ),
      );
    } else {
      result.addAll(
        countryList.map<Widget>((country) => _listRow(country)).toList(),
      );
    }
    result.add(
      const SizedBox(
        height: 12,
      ),
    );
    return result;
  }

  List<Widget> _convertCountryList(List<CountryCode> countryList) {
    final List<Widget> result = <Widget>[];
    final Map<String, List<CountryCode>> groupedLists = {};
    for (final country in countryList) {
      final String name = country.name ?? "";
      if (groupedLists[name[0]] == null) {
        groupedLists[name[0]] = <CountryCode>[];
      }

      groupedLists[name[0]]!.add(country);
    }

    for (final entry in groupedLists.entries) {
      result.add(
        const Divider(
          thickness: 8,
          color: Color(0xffebebeb),
        ),
      );

      result.add(_listHeader(entry.key));
      result.addAll(
          entry.value.map<Widget>((country) => _listRow(country)).toList());

      result.add(
        const SizedBox(
          height: 12,
        ),
      );
    }
    return result;
  }

  Widget _listHeader(String text) {
    final TextStyle textStyle =
        widget.countryListTheme?.headerTextStyle ?? _defaultTextStyle;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: Row(
            children: [
              Container(
                height: 4,
                width: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff23242a),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                text,
                style: textStyle,
              )
            ],
          ),
        ),
        Container(
          height: 1,
          decoration: const BoxDecoration(
            color: Color(0xffe9e9e9),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }

  Widget _listRow(CountryCode country) {
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
            children: [
              const SizedBox(width: 35),
              Flexible(
                fit: FlexFit.tight,
                child: _buildCountyText(country.localize(context).name ?? ""),
              ),
              SizedBox(
                width: 90,
                child: _buildCountyText(country.dialCode ?? ""),
              ),
              //_flagWidget(country),,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountyText(String text) {
    final TextStyle textStyle =
        widget.countryListTheme?.textStyle ?? _defaultTextStyle;
    if (_searching) {
      final StringBuffer stringBuffer = StringBuffer();
      final upperCase = text.toUpperCase();

      var findIdx = upperCase.indexOf(_query);
      var startIdx = 0;
      while (findIdx >= 0) {
        stringBuffer.write(text.substring(startIdx, findIdx));
        startIdx = findIdx;
        startIdx += _query.length;

        stringBuffer.write("<b>");
        stringBuffer.write(text.substring(findIdx, startIdx));
        stringBuffer.write("</b>");
        findIdx = upperCase.indexOf(_query, startIdx);
      }

      stringBuffer.write(text.substring(startIdx, text.length));
      return Html(
        data: stringBuffer.toString(),
        style: {
          "p": Style.fromTextStyle(
              textStyle.copyWith(fontWeight: FontWeight.normal)),
          "b": Style.fromTextStyle(
              textStyle.copyWith(fontWeight: FontWeight.bold)),
        },
      );
    } else {
      return Text(
        text,
        softWrap: false,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  void _filterSearchResults(String query) {
    List<CountryCode> searchResult = <CountryCode>[];
    _countryList.map((e) => e.localize(context));
    if (query.isEmpty) {
      _searching = false;
      searchResult.addAll(_countryList);
    } else {
      _searching = true;
      _query = query.toUpperCase();
      searchResult = _countryList
          .where(
            (e) =>
                e.code!.contains(_query) ||
                e.dialCode!.contains(_query) ||
                e.name!.toUpperCase().contains(_query),
          )
          .toList();
    }

    setState(() {
      _filteredList = searchResult;
    });
  }

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 16);
}
