import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:nisn/constants/constants.dart';
import 'package:nisn/constants/world_map.dart';
import 'package:nisn/models/nisn_data.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:nisn/widgets/loading_widget.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:nisn/widgets/top_back_bar.dart';

class TemporalAndSpatialView extends StatefulWidget {
  final int year;
  final List<NisnData> nisnData;
  TemporalAndSpatialView({
    Key key,
    @required this.nisnData,
    @required this.year,
  }) : super(key: key);

  @override
  State<TemporalAndSpatialView> createState() => _TemporalAndSpatialViewState();
}

class _TemporalAndSpatialViewState extends State<TemporalAndSpatialView> {
  List<_CountryDensity> _worldPopulationDensity;
  NumberFormat _numberFormat = NumberFormat('#.#');
  Map<String, List<List<LatLng>>> countryPolygons = {};
  Map<String, dynamic> processedData = {};
  MapShapeSource _mapSource;

  @override
  void initState() {
    myHustles["features"].forEach((feature) {
      List polygonCoords = feature["geometry"]["coordinates"] ?? [];
      String type = feature["geometry"]["type"] ?? "Polygon";

      if (type == "Polygon") {
        List<LatLng> polygonList = [];
        for (var cord in polygonCoords.first) {
          polygonList.add(
            LatLng(
              cord[0],
              cord[1],
            ),
          );
        }

        countryPolygons.addAll({
          feature["properties"]["name"] ?? "country": [
            polygonList,
          ],
        });
      } else {
        List<List<LatLng>> topPolygonList = [];

        for (var cordList in polygonCoords) {
          List<LatLng> polygonList = [];

          cordList.first.forEach((v) {
            polygonList.add(
              LatLng(
                v[0],
                v[1],
              ),
            );

            topPolygonList.add(polygonList);
          });
        }

        countryPolygons.addAll({
          feature["properties"]["name"] ?? "country": topPolygonList,
        });
      }
    });

    processedData = {};
    Map sortedUnProcessedData = {};

    for (var element in widget.nisnData) {
      String country = sortByCountry(LatLng(
        double.parse(element.lat.toString()),
        double.parse(element.long.toString()),
      ));

      if (country != null) {
        var countryMap = processedData[country];

        if (countryMap == null) {
          processedData.addAll({
            country: {
              "total": element.electronDensity,
              "count": 1,
              "avg": element.electronDensity,
            }
          });
        } else {
          var currentTotal = countryMap["total"] ?? 0;
          var currentCount = countryMap["count"] ?? 0;

          var newAvg =
              (currentTotal + element.electronDensity) / (currentCount + 1);

          processedData.addAll({
            country: {
              "total": currentTotal + element.electronDensity,
              "count": currentCount + 1,
              "avg": newAvg,
            }
          });
        }
      }
    }

    processedData.forEach((key, value) {
      sortedUnProcessedData.addAll({key: value["avg"] ?? 0});
    });

    _worldPopulationDensity = <_CountryDensity>[
      _CountryDensity('Monaco', sortedUnProcessedData["Monaco"] ?? 0),
      _CountryDensity('Macao', sortedUnProcessedData["Macao"] ?? 0),
      _CountryDensity('Singapore', sortedUnProcessedData["Singapore"] ?? 0),
      _CountryDensity('Hong kong', sortedUnProcessedData["Hong kong"] ?? 0),
      _CountryDensity('Gibraltar', sortedUnProcessedData["Gibraltar"] ?? 0),
      _CountryDensity('Bahrain', sortedUnProcessedData["Bahrain"] ?? 0),
      _CountryDensity('Holy See', sortedUnProcessedData["Holy See"] ?? 0),
      _CountryDensity('Maldives', sortedUnProcessedData["Maldives"] ?? 0),
      _CountryDensity('Malta', sortedUnProcessedData["Malta"] ?? 0),
      _CountryDensity('Bangladesh', sortedUnProcessedData["Bangladesh"] ?? 0),
      _CountryDensity(
          'Sint Maarten', sortedUnProcessedData["Sint Maarten"] ?? 0),
      _CountryDensity('Bermuda', sortedUnProcessedData["Bermuda"] ?? 0),
      _CountryDensity(
          'Channel Islands', sortedUnProcessedData["Channel Islands"] ?? 0),
      _CountryDensity('State of Palestine',
          sortedUnProcessedData["State of Palestine"] ?? 0),
      _CountryDensity(
          'Saint-Martin', sortedUnProcessedData["Saint-Martin"] ?? 0),
      _CountryDensity('Mayotte', sortedUnProcessedData["Mayotte"] ?? 0),
      _CountryDensity('Taiwan', sortedUnProcessedData["Taiwan"] ?? 0),
      _CountryDensity('Barbados', sortedUnProcessedData["Barbados"] ?? 0),
      _CountryDensity('Lebanon', sortedUnProcessedData["Lebanon"] ?? 0),
      _CountryDensity('Mauritius', sortedUnProcessedData["Mauritius"] ?? 0),
      _CountryDensity('Aruba', sortedUnProcessedData["Aruba"] ?? 0),
      _CountryDensity('San Marino', sortedUnProcessedData["San Marino"] ?? 0),
      _CountryDensity('Nauru', sortedUnProcessedData["Nauru"] ?? 0),
      _CountryDensity('Korea', sortedUnProcessedData["Korea"] ?? 0),
      _CountryDensity('Rwanda', sortedUnProcessedData["Rwanda"] ?? 0),
      _CountryDensity('Netherlands', sortedUnProcessedData["Netherlands"] ?? 0),
      _CountryDensity('Comoros', sortedUnProcessedData["Comoros"] ?? 0),
      _CountryDensity('India', sortedUnProcessedData["India"] ?? 0),
      _CountryDensity('Burundi', sortedUnProcessedData["Burundi"] ?? 0),
      _CountryDensity(
          'Saint-Barthélemy', sortedUnProcessedData["Saint-Barthélemy"] ?? 0),
      _CountryDensity('Haiti', sortedUnProcessedData["Haiti"] ?? 0),
      _CountryDensity('Israel', sortedUnProcessedData["Israel"] ?? 0),
      _CountryDensity('Tuvalu', sortedUnProcessedData["Tuvalu"] ?? 0),
      _CountryDensity('Belgium', sortedUnProcessedData["Belgium"] ?? 0),
      _CountryDensity('Curacao', sortedUnProcessedData["Curacao"] ?? 0),
      _CountryDensity('Philippines', sortedUnProcessedData["Philippines"] ?? 0),
      _CountryDensity('Reunion', sortedUnProcessedData["Reunion"] ?? 0),
      _CountryDensity('Martinique', sortedUnProcessedData["Martinique"] ?? 0),
      _CountryDensity('Japan', sortedUnProcessedData["Japan"] ?? 0),
      _CountryDensity('Sri Lanka', sortedUnProcessedData["Sri Lanka"] ?? 0),
      _CountryDensity('Grenada', sortedUnProcessedData["Grenada"] ?? 0),
      _CountryDensity(
          'Marshall Islands', sortedUnProcessedData["Marshall Islands"] ?? 0),
      _CountryDensity('Puerto Rico', sortedUnProcessedData["Puerto Rico"] ?? 0),
      _CountryDensity('Vietnam', sortedUnProcessedData["Vietnam"] ?? 0),
      _CountryDensity('El Salvador', sortedUnProcessedData["El Salvador"] ?? 0),
      _CountryDensity('Guam', sortedUnProcessedData["Guam"] ?? 0),
      _CountryDensity('Saint Lucia', sortedUnProcessedData["Saint Lucia"] ?? 0),
      _CountryDensity('United States Virgin Islands',
          sortedUnProcessedData["United States Virgin Islands"] ?? 0),
      _CountryDensity('Pakistan', sortedUnProcessedData["Pakistan"] ?? 0),
      _CountryDensity('Saint Vincent and the Grenadines',
          sortedUnProcessedData["Saint Vincent and the Grenadines"] ?? 0),
      _CountryDensity(
          'United Kingdom', sortedUnProcessedData["United Kingdom"] ?? 0),
      _CountryDensity(
          'American Samoa', sortedUnProcessedData["American Samoa"] ?? 0),
      _CountryDensity(
          'Cayman Islands', sortedUnProcessedData["Cayman Islands"] ?? 0),
      _CountryDensity('Jamaica', sortedUnProcessedData["Jamaica"] ?? 0),
      _CountryDensity('Trinidad and Tobago',
          sortedUnProcessedData["Trinidad and Tobago"] ?? 0),
      _CountryDensity('Qatar', sortedUnProcessedData["Qatar"] ?? 0),
      _CountryDensity('Guadeloupe', sortedUnProcessedData["Guadeloupe"] ?? 0),
      _CountryDensity('Luxembourg', sortedUnProcessedData["Luxembourg"] ?? 0),
      _CountryDensity('Germany', sortedUnProcessedData["Germany"] ?? 0),
      _CountryDensity('Kuwait', sortedUnProcessedData["Kuwait"] ?? 0),
      _CountryDensity('Gambia', sortedUnProcessedData["Gambia"] ?? 0),
      _CountryDensity(
          'Liechtenstein', sortedUnProcessedData["Liechtenstein"] ?? 0),
      _CountryDensity('Uganda', sortedUnProcessedData["Uganda"] ?? 0),
      _CountryDensity('Sao Tome and Principe',
          sortedUnProcessedData["Sao Tome and Principe"] ?? 0),
      _CountryDensity('Nigeria', sortedUnProcessedData["Nigeria"] ?? 0),
      _CountryDensity(
          'Dominican Rep.', sortedUnProcessedData["Dominican Rep."] ?? 0),
      _CountryDensity('Antigua and Barbuda',
          sortedUnProcessedData["Antigua and Barbuda"] ?? 0),
      _CountryDensity('Switzerland', sortedUnProcessedData["Switzerland"] ?? 0),
      _CountryDensity(
          'Dem. Rep. Korea', sortedUnProcessedData["Dem. Rep. Korea"] ?? 0),
      _CountryDensity('Seychelles', sortedUnProcessedData["Seychelles"] ?? 0),
      _CountryDensity('Italy', sortedUnProcessedData["Italy"] ?? 0),
      _CountryDensity('Saint Kitts and Nevis',
          sortedUnProcessedData["Saint Kitts and Nevis"] ?? 0),
      _CountryDensity('Nepal', sortedUnProcessedData["Nepal"] ?? 0),
      _CountryDensity('Malawi', sortedUnProcessedData["Malawi"] ?? 0),
      _CountryDensity('British Virgin Islands',
          sortedUnProcessedData["British Virgin Islands"] ?? 0),
      _CountryDensity('Guatemala', sortedUnProcessedData["Guatemala"] ?? 0),
      _CountryDensity('Anguilla', sortedUnProcessedData["Anguilla"] ?? 0),
      _CountryDensity('Andorra', sortedUnProcessedData["Andorra"] ?? 0),
      _CountryDensity('Micronesia', sortedUnProcessedData["Micronesia"] ?? 0),
      _CountryDensity('China', sortedUnProcessedData["China"] ?? 0),
      _CountryDensity('Togo', sortedUnProcessedData["Togo"] ?? 0),
      _CountryDensity('Indonesia', sortedUnProcessedData["Indonesia"] ?? 0),
      _CountryDensity('Isle of Man', sortedUnProcessedData["Isle of Man"] ?? 0),
      _CountryDensity('Kiribati', sortedUnProcessedData["Kiribati"] ?? 0),
      _CountryDensity('Tonga', sortedUnProcessedData["Tonga"] ?? 0),
      _CountryDensity('Czech Rep.', sortedUnProcessedData["Czech Rep."] ?? 0),
      _CountryDensity('Cabo Verde', sortedUnProcessedData["Cabo Verde"] ?? 0),
      _CountryDensity('Thailand', sortedUnProcessedData["Thailand"] ?? 0),
      _CountryDensity('Ghana', sortedUnProcessedData["Ghana"] ?? 0),
      _CountryDensity('Denmark', sortedUnProcessedData["Denmark"] ?? 0),
      _CountryDensity('Tokelau', sortedUnProcessedData["Tokelau"] ?? 0),
      _CountryDensity('Cyprus', sortedUnProcessedData["Cyprus"] ?? 0),
      _CountryDensity('Northern Mariana Islands',
          sortedUnProcessedData["Northern Mariana Islands"] ?? 0),
      _CountryDensity('Poland', sortedUnProcessedData["Poland"] ?? 0),
      _CountryDensity('Moldova', sortedUnProcessedData["Moldova"] ?? 0),
      _CountryDensity('Azerbaijan', sortedUnProcessedData["Azerbaijan"] ?? 0),
      _CountryDensity('France', sortedUnProcessedData["France"] ?? 0),
      _CountryDensity('United Arab Emirates',
          sortedUnProcessedData["United Arab Emirates"] ?? 0),
      _CountryDensity('Ethiopia', sortedUnProcessedData["Ethiopia"] ?? 0),
      _CountryDensity('Jordan', sortedUnProcessedData["Jordan"] ?? 0),
      _CountryDensity('Slovakia', sortedUnProcessedData["Slovakia"] ?? 0),
      _CountryDensity('Portugal', sortedUnProcessedData["Portugal"] ?? 0),
      _CountryDensity(
          'Sierra Leone', sortedUnProcessedData["Sierra Leone"] ?? 0),
      _CountryDensity('Turkey', sortedUnProcessedData["Turkey"] ?? 0),
      _CountryDensity('Austria', sortedUnProcessedData["Austria"] ?? 0),
      _CountryDensity('Benin', sortedUnProcessedData["Benin"] ?? 0),
      _CountryDensity('Hungary', sortedUnProcessedData["Hungary"] ?? 0),
      _CountryDensity('Cuba', sortedUnProcessedData["Cuba"] ?? 0),
      _CountryDensity('Albania', sortedUnProcessedData["Albania"] ?? 0),
      _CountryDensity('Armenia', sortedUnProcessedData["Armenia"] ?? 0),
      _CountryDensity('Slovenia', sortedUnProcessedData["Slovenia"] ?? 0),
      _CountryDensity('Egypt', sortedUnProcessedData["Egypt"] ?? 0),
      _CountryDensity('Serbia', sortedUnProcessedData["Serbia"] ?? 0),
      _CountryDensity('Costa Rica', sortedUnProcessedData["Costa Rica"] ?? 0),
      _CountryDensity('Malaysia', sortedUnProcessedData["Malaysia"] ?? 0),
      _CountryDensity('Dominica', sortedUnProcessedData["Dominica"] ?? 0),
      _CountryDensity('Syria', sortedUnProcessedData["Syria"] ?? 0),
      _CountryDensity('Cambodia', sortedUnProcessedData["Cambodia"] ?? 0),
      _CountryDensity('Kenya', sortedUnProcessedData["Kenya"] ?? 0),
      _CountryDensity('Spain', sortedUnProcessedData["Spain"] ?? 0),
      _CountryDensity('Iraq', sortedUnProcessedData["Iraq"] ?? 0),
      _CountryDensity('Timor-Leste', sortedUnProcessedData["Timor-Leste"] ?? 0),
      _CountryDensity('Honduras', sortedUnProcessedData["Honduras"] ?? 0),
      _CountryDensity('Senegal', sortedUnProcessedData["Senegal"] ?? 0),
      _CountryDensity('Romania', sortedUnProcessedData["Romania"] ?? 0),
      _CountryDensity('Myanmar', sortedUnProcessedData["Myanmar"] ?? 0),
      _CountryDensity(
          'Brunei Darussalam', sortedUnProcessedData["Brunei Darussalam"] ?? 0),
      _CountryDensity(
          "Côte d'Ivoire", sortedUnProcessedData["Côte d'Ivoire"] ?? 0),
      _CountryDensity('Morocco', sortedUnProcessedData["Morocco"] ?? 0),
      _CountryDensity('Macedonia', sortedUnProcessedData["Macedonia"] ?? 0),
      _CountryDensity('Greece', sortedUnProcessedData["Greece"] ?? 0),
      _CountryDensity('Wallis and Futuna Islands',
          sortedUnProcessedData["Wallis and Futuna Islands"] ?? 0),
      _CountryDensity('Bonaire, Sint Eustatius and Saba',
          sortedUnProcessedData["Bonaire, Sint Eustatius and Saba"] ?? 0),
      _CountryDensity('Uzbekistan', sortedUnProcessedData["Uzbekistan"] ?? 0),
      _CountryDensity(
          'French Polynesia', sortedUnProcessedData["French Polynesia"] ?? 0),
      _CountryDensity(
          'Burkina Faso', sortedUnProcessedData["Burkina Faso"] ?? 0),
      _CountryDensity('Tunisia', sortedUnProcessedData["Tunisia"] ?? 0),
      _CountryDensity('Ukraine', sortedUnProcessedData["Ukraine"] ?? 0),
      _CountryDensity('Croatia', sortedUnProcessedData["Croatia"] ?? 0),
      _CountryDensity(
          'Cook Islands', sortedUnProcessedData["Cook Islands"] ?? 0),
      _CountryDensity('Ireland', sortedUnProcessedData["Ireland"] ?? 0),
      _CountryDensity('Ecuador', sortedUnProcessedData["Ecuador"] ?? 0),
      _CountryDensity('Lesotho', sortedUnProcessedData["Lesotho"] ?? 0),
      _CountryDensity('Samoa', sortedUnProcessedData["Samoa"] ?? 0),
      _CountryDensity(
          'Guinea-Bissau', sortedUnProcessedData["Guinea-Bissau"] ?? 0),
      _CountryDensity('Tajikistan', sortedUnProcessedData["Tajikistan"] ?? 0),
      _CountryDensity('Eswatini', sortedUnProcessedData["Eswatini"] ?? 0),
      _CountryDensity('Tanzania', sortedUnProcessedData["Tanzania"] ?? 0),
      _CountryDensity('Mexico', sortedUnProcessedData["Mexico"] ?? 0),
      _CountryDensity(
          'Bosnia and Herz.', sortedUnProcessedData["Bosnia and Herz."] ?? 0),
      _CountryDensity('Bulgaria', sortedUnProcessedData["Bulgaria"] ?? 0),
      _CountryDensity('Afghanistan', sortedUnProcessedData["Afghanistan"] ?? 0),
      _CountryDensity('Panama', sortedUnProcessedData["Panama"] ?? 0),
      _CountryDensity('Georgia', sortedUnProcessedData["Georgia"] ?? 0),
      _CountryDensity('Yemen', sortedUnProcessedData["Yemen"] ?? 0),
      _CountryDensity('Cameroon', sortedUnProcessedData["Cameroon"] ?? 0),
      _CountryDensity('Nicaragua', sortedUnProcessedData["Nicaragua"] ?? 0),
      _CountryDensity('Guinea', sortedUnProcessedData["Guinea"] ?? 0),
      _CountryDensity('Liberia', sortedUnProcessedData["Liberia"] ?? 0),
      _CountryDensity('Iran', sortedUnProcessedData["Iran"] ?? 0),
      _CountryDensity('Eq. Guinea', sortedUnProcessedData["Eq. Guinea"] ?? 0),
      _CountryDensity('Montserrat', sortedUnProcessedData["Montserrat"] ?? 0),
      _CountryDensity('Fiji', sortedUnProcessedData["Fiji"] ?? 0),
      _CountryDensity(
          'South Africa', sortedUnProcessedData["South Africa"] ?? 0),
      _CountryDensity('Madagascar', sortedUnProcessedData["Madagascar"] ?? 0),
      _CountryDensity('Montenegro', sortedUnProcessedData["Montenegro"] ?? 0),
      _CountryDensity('Belarus', sortedUnProcessedData["Belarus"] ?? 0),
      _CountryDensity('Colombia', sortedUnProcessedData["Colombia"] ?? 0),
      _CountryDensity('Lithuania', sortedUnProcessedData["Lithuania"] ?? 0),
      _CountryDensity('Djibouti', sortedUnProcessedData["Djibouti"] ?? 0),
      _CountryDensity('Turks and Caicos Islands',
          sortedUnProcessedData["Turks and Caicos Islands"] ?? 0),
      _CountryDensity('Mozambique', sortedUnProcessedData["Mozambique"] ?? 0),
      _CountryDensity(
          'Dem. Rep. Congo', sortedUnProcessedData["Dem. Rep. Congo"] ?? 0),
      _CountryDensity('Palau', sortedUnProcessedData["Palau"] ?? 0),
      _CountryDensity('Bahamas', sortedUnProcessedData["Bahamas"] ?? 0),
      _CountryDensity('Zimbabwe', sortedUnProcessedData["Zimbabwe"] ?? 0),
      _CountryDensity('United States of America',
          sortedUnProcessedData["United States of America"] ?? 0),
      _CountryDensity('Eritrea', sortedUnProcessedData["Eritrea"] ?? 0),
      _CountryDensity(
          'Faroe Islands', sortedUnProcessedData["Faroe Islands"] ?? 0),
      _CountryDensity('Kyrgyzstan', sortedUnProcessedData["Kyrgyzstan"] ?? 0),
      _CountryDensity('Venezuela', sortedUnProcessedData["Venezuela"] ?? 0),
      _CountryDensity('Lao PDR', sortedUnProcessedData["Lao PDR"] ?? 0),
      _CountryDensity('Estonia', sortedUnProcessedData["Estonia"] ?? 0),
      _CountryDensity('Latvia', sortedUnProcessedData["Latvia"] ?? 0),
      _CountryDensity('Angola', sortedUnProcessedData["Angola"] ?? 0),
      _CountryDensity('Peru', sortedUnProcessedData["Peru"] ?? 0),
      _CountryDensity('Chile', sortedUnProcessedData["Chile"] ?? 0),
      _CountryDensity('Brazil', sortedUnProcessedData["Brazil"] ?? 0),
      _CountryDensity('Somalia', sortedUnProcessedData["Somalia"] ?? 0),
      _CountryDensity('Vanuatu', sortedUnProcessedData["Vanuatu"] ?? 0),
      _CountryDensity('Saint Pierre and Miquelon',
          sortedUnProcessedData["Saint Pierre and Miquelon"] ?? 0),
      _CountryDensity('Sudan', sortedUnProcessedData["Sudan"] ?? 0),
      _CountryDensity('Zambia', sortedUnProcessedData["Zambia"] ?? 0),
      _CountryDensity('Sweden', sortedUnProcessedData["Sweden"] ?? 0),
      _CountryDensity(
          'Solomon Islands', sortedUnProcessedData["Solomon Islands"] ?? 0),
      _CountryDensity('Bhutan', sortedUnProcessedData["Bhutan"] ?? 0),
      _CountryDensity('Uruguay', sortedUnProcessedData["Uruguay"] ?? 0),
      _CountryDensity(
          'Papua New Guinea', sortedUnProcessedData["Papua New Guinea"] ?? 0),
      _CountryDensity('Niger', sortedUnProcessedData["Niger"] ?? 0),
      _CountryDensity('Algeria', sortedUnProcessedData["Algeria"] ?? 0),
      _CountryDensity('S. Sudan', sortedUnProcessedData["S. Sudan"] ?? 0),
      _CountryDensity('New Zealand', sortedUnProcessedData["New Zealand"] ?? 0),
      _CountryDensity('Finland', sortedUnProcessedData["Finland"] ?? 0),
      _CountryDensity('Paraguay', sortedUnProcessedData["Paraguay"] ?? 0),
      _CountryDensity('Belize', sortedUnProcessedData["Belize"] ?? 0),
      _CountryDensity('Mali', sortedUnProcessedData["Mali"] ?? 0),
      _CountryDensity('Argentina', sortedUnProcessedData["Argentina"] ?? 0),
      _CountryDensity('Oman', sortedUnProcessedData["Oman"] ?? 0),
      _CountryDensity(
          'Saudi Arabia', sortedUnProcessedData["Saudi Arabia"] ?? 0),
      _CountryDensity('Congo', sortedUnProcessedData["Congo"] ?? 0),
      _CountryDensity(
          'New Caledonia', sortedUnProcessedData["New Caledonia"] ?? 0),
      _CountryDensity(
          'Saint Helena', sortedUnProcessedData["Saint Helena"] ?? 0),
      _CountryDensity('Norway', sortedUnProcessedData["Norway"] ?? 0),
      _CountryDensity('Chad', sortedUnProcessedData["Chad"] ?? 0),
      _CountryDensity(
          'Turkmenistan', sortedUnProcessedData["Turkmenistan"] ?? 0),
      _CountryDensity('Bolivia', sortedUnProcessedData["Bolivia"] ?? 0),
      _CountryDensity('Russia', sortedUnProcessedData["Russia"] ?? 0),
      _CountryDensity('Gabon', sortedUnProcessedData["Gabon"] ?? 0),
      _CountryDensity('Central African Rep.',
          sortedUnProcessedData["Central African Rep."] ?? 0),
      _CountryDensity('Kazakhstan', sortedUnProcessedData["Kazakhstan"] ?? 0),
      _CountryDensity('Niue', sortedUnProcessedData["Niue"] ?? 0),
      _CountryDensity('Mauritania', sortedUnProcessedData["Mauritania"] ?? 0),
      _CountryDensity('Canada', sortedUnProcessedData["Canada"] ?? 0),
      _CountryDensity('Botswana', sortedUnProcessedData["Botswana"] ?? 0),
      _CountryDensity('Guyana', sortedUnProcessedData["Guyana"] ?? 0),
      _CountryDensity('Libya', sortedUnProcessedData["Libya"] ?? 0),
      _CountryDensity('Suriname', sortedUnProcessedData["Suriname"] ?? 0),
      _CountryDensity(
          'French Guiana', sortedUnProcessedData["French Guiana"] ?? 0),
      _CountryDensity('Iceland', sortedUnProcessedData["Iceland"] ?? 0),
      _CountryDensity('Australia', sortedUnProcessedData["Australia"] ?? 0),
      _CountryDensity('Namibia', sortedUnProcessedData["Namibia"] ?? 0),
      _CountryDensity('W. Sahara', sortedUnProcessedData["W. Sahara"] ?? 0),
      _CountryDensity('Mongolia', sortedUnProcessedData["Mongolia"] ?? 0),
      _CountryDensity(
          'Falkland Is.', sortedUnProcessedData["Falkland Is."] ?? 0),
      _CountryDensity('Greenland', sortedUnProcessedData["Greenland"] ?? 0),
    ];

    _mapSource = MapShapeSource.asset(
      'assets/files/world_map.json',
      shapeDataField: 'name',
      dataCount: _worldPopulationDensity.length,
      primaryValueMapper: (int index) =>
          _worldPopulationDensity[index].countryName,
      shapeColorValueMapper: (int index) =>
          _worldPopulationDensity[index].density,
      shapeColorMappers: <MapColorMapper>[
        const MapColorMapper(
            from: 0,
            to: 100,
            color: Color.fromRGBO(128, 159, 255, 1),
            text: '{0},{100}'),
        const MapColorMapper(
            from: 100,
            to: 500,
            color: Color.fromRGBO(51, 102, 255, 1),
            text: '500'),
        const MapColorMapper(
            from: 500,
            to: 1000,
            color: Color.fromRGBO(0, 57, 230, 1),
            text: '1k'),
        const MapColorMapper(
            from: 1000,
            to: 5000,
            color: Color.fromRGBO(0, 45, 179, 1),
            text: '5k'),
        const MapColorMapper(
            from: 5000,
            to: 50000,
            color: Color.fromRGBO(0, 26, 102, 1),
            text: '50k'),
      ],
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackBar(
              icon: null,
              onPressed: null,
              text: "Temporal and Spatial View",
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(NisnData.DIRECTORY)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: LoadingWidget(),
                    );
                  } else {
                    return LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final bool scrollEnabled = constraints.maxHeight > 400;
                      double height =
                          scrollEnabled ? constraints.maxHeight : 400;
                      if (kIsWeb ||
                          (!kIsWeb &&
                              MediaQuery.of(context).orientation ==
                                  Orientation.landscape)) {
                        final double refHeight = height * 0.6;
                        height = height > 500
                            ? (refHeight < 500 ? 500 : refHeight)
                            : height;
                      }

                      return Center(
                        child: SingleChildScrollView(
                            child: SizedBox(
                          width: constraints.maxWidth,
                          height: height,
                          child: _buildMapsWidget(scrollEnabled),
                        )),
                      );
                    });
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  String sortByCountry(LatLng location) {
    String selectedCountry;

    countryPolygons.forEach((key, value) {
      for (var element in value) {
        if (selectedCountry == null) {
          if (PolygonUtil.containsLocation(location, element, true)) {
            selectedCountry = key;
          }
        }
      }
    });

    return selectedCountry;
  }

  Widget _buildMapsWidget(bool scrollEnabled) {
    return Center(
        child: Padding(
      padding: scrollEnabled
          ? EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.05,
              bottom: MediaQuery.of(context).size.height * 0.05,
              right: 10)
          : const EdgeInsets.only(right: 10, bottom: 15),
      child: SfMapsTheme(
        data: SfMapsThemeData(
          shapeHoverColor: const Color.fromRGBO(176, 237, 131, 1),
        ),
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 30),
            child: Align(
              child: Text(
                'Average Electron Density for the year ${widget.year}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ),
          Expanded(
            child: SfMaps(
              layers: <MapLayer>[
                MapShapeLayer(
                  loadingBuilder: (BuildContext context) {
                    return const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    );
                  },
                  source: _mapSource,
                  shapeTooltipBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          '${_worldPopulationDensity[index].countryName} : ${_numberFormat.format(_worldPopulationDensity[index].density)} per sq. km.',
                          style: Theme.of(context).textTheme.caption.copyWith(
                              color: Theme.of(context).colorScheme.surface)),
                    );
                  },
                  strokeColor: Colors.white30,
                  legend: const MapLegend.bar(MapElement.shape,
                      position: MapLegendPosition.bottom,
                      overflowMode: MapLegendOverflowMode.wrap,
                      labelsPlacement: MapLegendLabelsPlacement.betweenItems,
                      padding: EdgeInsets.only(top: 15),
                      spacing: 1.0,
                      segmentSize: Size(55.0, 9.0)),
                  tooltipSettings: MapTooltipSettings(
                      color: primaryColor,
                      strokeColor: Theme.of(context).canvasColor),
                ),
              ],
            ),
          )
        ]),
      ),
    ));
  }
}

class _CountryDensity {
  _CountryDensity(this.countryName, this.density);

  final String countryName;
  final double density;
}
