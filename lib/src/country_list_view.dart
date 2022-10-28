import 'package:flutter/material.dart';

import 'country.dart';
import 'country_list_theme_data.dart';
import 'country_localizations.dart';
import 'country_service.dart';
import 'res/country_codes.dart';
import 'utils.dart';

class CountryListView extends StatefulWidget {
  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country> onSelect;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [countryFilter]
  final List<String>? exclude;

  /// An optional [countryFilter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [countryFilter] and [exclude]
  final List<String>? countryFilter;

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
    required this.onSelect,
    this.exclude,
    this.favorite,
    this.countryFilter,
    this.countryListTheme,
    this.searchAutofocus = false,
  })  : assert(
          exclude == null || countryFilter == null,
          'Cannot provide both exclude and countryFilter',
        ),
        super(key: key);

  @override
  _CountryListViewState createState() => _CountryListViewState();
}

class _CountryListViewState extends State<CountryListView> {
  final CountryService _countryService = CountryService();

  late List<Country> _countryList;
  late List<Country> _filteredList;
  List<Country>? _favoriteList;
  late TextEditingController _searchController;
  late bool _searchAutofocus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _countryList = _countryService.getAll();

    _countryList =
        countryCodes.map((country) => Country.from(json: country)).toList();

    if (widget.favorite != null) {
      _favoriteList = _countryService.findCountriesByCode(widget.favorite!);
    }

    if (widget.exclude != null) {
      _countryList.removeWhere(
        (element) => widget.exclude!.contains(element.countryCode),
      );
    }

    if (widget.countryFilter != null) {
      _countryList.removeWhere(
        (element) => !widget.countryFilter!.contains(element.countryCode),
      );
    }

    _filteredList = <Country>[];
    _filteredList.addAll(_countryList);

    _searchAutofocus = widget.searchAutofocus;
  }

  @override
  Widget build(BuildContext context) {
    final String searchLabel =
        CountryLocalizations.of(context)?.countryName(countryCode: 'search') ??
            'Search';

    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: TextField(
            autofocus: _searchAutofocus,
            controller: _searchController,
            decoration: widget.countryListTheme?.inputDecoration ??
                InputDecoration(
                  labelText: searchLabel,
                  hintText: searchLabel,
                  //prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color(0xFF8C98A8).withOpacity(0.2),
                    ),
                  ),
                ),
            onChanged: _filterSearchResults,
          ),
        ),
        Expanded(
          child: Container(
              color: Colors.white,
              child: ListView(
                children: [
                  if (_favoriteList != null) ...[
                    _listHeader("즐겨찾는 국가"),
                    ..._favoriteList!
                        .map<Widget>((currency) => _listRow(currency))
                        .toList(),
                    SizedBox(
                      height: 12,
                    ),
                  ],
                  ..._convertCountryList(_filteredList),
                ],
              )),
        ),
      ],
    );
  }

  List<Widget> _convertCountryList(List<Country> countryList) {
    List<Widget> result = <Widget>[];

    Map<String, List<Country>> groupedLists = {};
    countryList.forEach((country) {
      String name = country.name;
      if (groupedLists['${name[0]}'] == null) {
        groupedLists['${name[0]}'] = <Country>[];
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

  Widget _listRow(Country country) {
    final TextStyle _textStyle =
        widget.countryListTheme?.textStyle ?? _defaultTextStyle;

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          country.nameLocalized = CountryLocalizations.of(context)
              ?.countryName(countryCode: country.countryCode)
              ?.replaceAll(RegExp(r"\s+"), " ");
          widget.onSelect(country);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 20),
                  Text(
                    CountryLocalizations.of(context)
                            ?.countryName(countryCode: country.countryCode)
                            ?.replaceAll(RegExp(r"\s+"), " ") ??
                        country.name,
                    style: _textStyle,
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 45,
                    child: Text(
                      '${isRtl ? '' : '+'}${country.phoneCode}${isRtl ? '+' : ''}',
                      style: _textStyle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  //_flagWidget(country),,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flagWidget(Country country) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      // the conditional 50 prevents irregularities caused by the flags in RTL mode
      width: isRtl ? 50 : null,
      child: Text(
        Utils.countryCodeToEmoji(country.countryCode),
        style: TextStyle(
          fontSize: widget.countryListTheme?.flagSize ?? 25,
        ),
      ),
    );
  }

  void _filterSearchResults(String query) {
    List<Country> _searchResult = <Country>[];
    final CountryLocalizations? localizations =
        CountryLocalizations.of(context);

    if (query.isEmpty) {
      _searchResult.addAll(_countryList);
    } else {
      _searchResult = _countryList
          .where((c) => c.startsWith(query, localizations))
          .toList();
    }

    setState(() => _filteredList = _searchResult);
  }

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 16);
}
