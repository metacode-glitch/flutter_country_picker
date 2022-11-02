import 'package:country_picker/country_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo for country picker package',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      supportedLocales: [
        const Locale('en'),
        const Locale('ar'),
        const Locale('es'),
        const Locale('de'),
        const Locale('fr'),
        const Locale('el'),
        const Locale('et'),
        const Locale('nb'),
        const Locale('nn'),
        const Locale('pl'),
        const Locale('pt'),
        const Locale('ru'),
        const Locale('hi'),
        const Locale('ne'),
        const Locale('uk'),
        const Locale('hr'),
        const Locale('tr'),
        const Locale('lv'),
        const Locale('lt'),
        const Locale('ku'),
        const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans'), // Generic Simplified Chinese 'zh_Hans'
        const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant'), // Generic traditional Chinese 'zh_Hant'
      ],
      localizationsDelegates: [
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Demo for country picker')),
      body: Column(
        children: [
          Center(
            child: Container(
              width: 120,
              height: 100,
              child: CountryCodePicker(
                onSelect: (CountryCode country) {
                  print('Select country: ${country.name}');
                },
                favorite: <String>['KR', 'CN', 'US'],
                countryListTheme: CountryListThemeData(
                    hintText: "검색할 국가 이름 또는 번호를 입력하세요.",
                    searchingText: "검색된 정보",
                    favoriteText: "즐겨찾는 국가",
                    emptyText: "조회된 정보가 없습니다.",
                    labelText: "국가선택",
                    defaultText: "국가선택",
                    textStyle: TextStyle(),
                    buttonCountyNameTextStyle: TextStyle(
                      color: const Color(0xff4d4d4d),
                      fontWeight: FontWeight.w400,
                    ),
                    buttonDialCodeTextStyle: TextStyle(
                      color: const Color(0xff4d4d4d),
                      fontWeight: FontWeight.w500,
                    ),
                    labelTextStyle: TextStyle(
                      color: const Color(0xffaeaeae),
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    downArrow: SvgPicture.asset(
                      'assets/image/arrow_down.svg',
                      color: Color(0xffb6b9c1),
                      fit: BoxFit.scaleDown,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
