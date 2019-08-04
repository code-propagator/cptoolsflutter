import 'package:flutter/material.dart';
import 'dart:async';

import 'package:cptoolsflutter/login/CPTFLogin.dart';
import 'package:cptoolsflutter/login/CPTFLoginCritter.dart';
import 'package:cptoolsflutter/gui/SyncScroll.dart';
import 'package:cptoolsflutter/line/LineChart.dart';
import 'package:cptoolsflutter/line/SingleChartPage.dart';
import 'package:cptoolsflutter/line/MultiChartsPage.dart';
import 'package:cptoolsflutter/service/CPTFRest.dart';
import 'package:cptoolsflutter/task/CPTFProgressTask.dart';

import 'package:cptoolsflutter/masterdetail/CPTFMasterDetailContainer.dart';
import 'package:cptoolsflutter/masterdetail/CPTFMasterItem.dart';

import 'package:cptoolsflutter/list/CPTFItemSelection.dart';

import 'package:cptoolsflutter/app/CPTFAppInfo.dart';
import 'package:cptoolsflutter/app/CPTFHome.dart';
import 'package:cptoolsflutter/db/CPTFEntity.dart';

import 'package:cptoolsflutter/login/CPTFNewPasscode.dart';

import 'package:provider/provider.dart';

/*
MIT License

Copyright (c) 2019 Code Propagator

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    _prepareData();
  }

  //================
  // MasterDetail
  _dataForMaster(StreamController<CPTFMasterItem> sc) async {
    //#### itemの直接addしないで、ストリームにプッシュするだけで良い。
    // Item tmp = Item(...);
    // item.add(tmp) ----> ac.add(tmp);

    sc.add(CPTFMasterItem(
      title: 'Item 1',
      subtitle: 'This is the first item.',
    ));

    sc.add(CPTFMasterItem(
      title: 'Item 2',
      subtitle: 'This is the second item.',
    ));

    sc.add(CPTFMasterItem(
      title: 'Item 3',
      subtitle: 'This is the third item.',
    ));
  }

  //================
  // SingleChartPage
  // item前後のデータをList<Map>で取得する
  Future<List<Map>> _listAroundItem(LaboTest item) async {

    List<Map> maps = List<Map>();

    try {
      /*
      LaboTest entity = item;
      List<Map> maps = await Provider.of<MyAppInfo>(context).appdb.selectLaboTestPivotRow(
          entity.userId,
          entity.facilityId,
          entity.spCode,
          entity.itemCode,
          entity.spName,
          entity.itemName,
          entity.itemUnit
      ) as List<Map>;
      */

      Map<String, dynamic> map = {
        fuserId: '12345678',
        ffacilityId: 'ffff',

        fspCode: "sp00",
        fspName: 'sp',
        fitemCode: 'item000',
        fitemName: 'item',

        fsampleDatetimeJST: '2019-01-23 12:34:56',
        fitemValue: '1.0',
        fitemUnit: '[Unit]',
        fitemOut: '上限値超え',

        fdocInfoIntId: 1
      };
      maps.add(map);


      map = {
        fuserId: '12345678',
        ffacilityId: 'ffff',

        fspCode: "sp00",
        fspName: 'sp',
        fitemCode: 'item000',
        fitemName: 'item',

        fsampleDatetimeJST: '2019-01-24 12:34:56',
        fitemValue: '0.8',
        fitemUnit: '[Unit]',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 2
      };
      maps.add(map);


      map = {
        fuserId: '12345678',
        ffacilityId: 'ffff',

        fspCode: "sp00",
        fspName: 'sp',
        fitemCode: 'item000',
        fitemName: 'item',

        fsampleDatetimeJST: '2019-01-24 12:34:56',
        fitemValue: '0.8',
        fitemUnit: '[Unit]',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 3
      };
      maps.add(map);


      map = {
        fuserId: '12345678',
        ffacilityId: 'ffff',

        fspCode: "sp00",
        fspName: 'sp',
        fitemCode: 'item000',
        fitemName: 'item',

        fsampleDatetimeJST: '2019-01-24 22:22:22',//####
        fitemValue: '0.8',
        fitemUnit: '[Unit]',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 4
      };
      maps.add(map);


      map = {
        fuserId: '12345678',
        ffacilityId: 'ffff',

        fspCode: "sp00",
        fspName: 'sp',
        fitemCode: 'item000',
        fitemName: 'item',

        fsampleDatetimeJST: '2019-01-25 12:34:56',
        fitemValue: '0.1',
        fitemUnit: '[Unit]',
        fitemOut: '下限値未満',

        fdocInfoIntId: 5
      };
      maps.add(map);


      map = {
        fuserId: '12345678',
        ffacilityId: 'ffff',

        fspCode: "sp00",
        fspName: 'sp',
        fitemCode: 'item000',
        fitemName: 'item',

        fsampleDatetimeJST: '2019-02-01 12:34:56',
        fitemValue: '0.3',
        fitemUnit: '[Unit]',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 6
      };
      maps.add(map);


      map = {
        fuserId: '12345678',
        ffacilityId: 'ffff',

        fspCode: "sp00",
        fspName: 'sp',
        fitemCode: 'item000',
        fitemName: 'item',

        fsampleDatetimeJST: '2019-02-10 12:34:56',
        fitemValue: '0.4',
        fitemUnit: '[Unit]',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 7
      };
      maps.add(map);


      map = {
        fuserId: '12345678',
        ffacilityId: 'ffff',

        fspCode: "sp00",
        fspName: 'sp',
        fitemCode: 'item000',
        fitemName: 'item',

        fsampleDatetimeJST: '2019-02-11 12:34:56',
        fitemValue: '0.5',
        fitemUnit: '[Unit]',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 8
      };
      maps.add(map);


      map = {
        fuserId: '12345678',
        ffacilityId: 'ffff',

        fspCode: "sp00",
        fspName: 'sp',
        fitemCode: 'item000',
        fitemName: 'item',

        fsampleDatetimeJST: '2019-02-11 12:34:56',
        fitemValue: '0.5',
        fitemUnit: '[Unit]',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 9
      };
      maps.add(map);


      map = {
        fuserId: '12345678',
        ffacilityId: 'ffff',

        fspCode: "sp00",
        fspName: 'sp',
        fitemCode: 'item000',
        fitemName: 'item',

        fsampleDatetimeJST: '2019-02-11 12:34:56',
        fitemValue: '0.6',//####
        fitemUnit: '[Unit]',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 10
      };
      maps.add(map);

    } catch (e) {

    }

    return maps;
  }

  //-----------------------
  // MultiChartsPage
  List<Map> _dataForSingleChart(int c, Map map) {
    print('_dataForSingleChart');
    print(c);
    print(map.toString());

    List<Map> maps;

    String userId = '12345678';

    if (c == 0) {
      maps = List<Map>();

      Map<String, dynamic> dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE',
        fspName: 'SPNAME',
        fitemCode: 'ITEMCODE',
        fitemName: 'ITEMNAME',

        fsampleDatetimeJST: 'yyyy-MM-01 HH:mm:ss.ZZZ',
        fitemValue: '1.1',
        fitemUnit: 'UNIT',
        fitemOut: '上限値超え',

        fdocInfoIntId: 1
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE',
        fspName: 'SPNAME',
        fitemCode: 'ITEMCODE',
        fitemName: 'ITEMNAME',

        fsampleDatetimeJST: 'yyyy-MM-03 HH:mm:ss.ZZZ',
        fitemValue: '0.8',
        fitemUnit: 'UNIT',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 3
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-07 HH:mm:ss.ZZZ',
        fitemValue: '0.8',
        fitemUnit: 'UNIT1',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 7
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-08 HH:mm:ss.ZZZ',
        fitemValue: '0.66',
        fitemUnit: 'UNIT1',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 8
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-09 HH:mm:ss.ZZZ',
        fitemValue: '0.66',
        fitemUnit: 'UNIT1',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 9
      };
      maps.add(dummy);


      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-11 HH:mm:ss.ZZZ',
        fitemValue: '0.8',
        fitemUnit: 'UNIT1',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 11
      };
      maps.add(dummy);


    } else {

      maps = List<Map>();

      Map<String, dynamic> dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-01 HH:mm:ss.ZZZ',
        fitemValue: '1',
        fitemUnit: 'UNIT1',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 1
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-02 HH:mm:ss.ZZZ',
        fitemValue: '0.6',
        fitemUnit: 'UNIT1',
        fitemOut: '下限値未満',

        fdocInfoIntId: 2
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-02 HH:mm:ss.ZZZ',
        fitemValue: '0.6',
        fitemUnit: 'UNIT1',
        fitemOut: '下限値未満',

        fdocInfoIntId: 4
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-05 HH:mm:ss.ZZZ',
        fitemValue: '0.7',
        fitemUnit: 'UNIT1',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 5
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-06 HH:mm:ss.ZZZ',
        fitemValue: '0.7',
        fitemUnit: 'UNIT1',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 6
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-07 HH:mm:ss.ZZZ',
        fitemValue: '0.8',
        fitemUnit: 'UNIT1',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 7
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-08 HH:mm:ss.ZZZ',
        fitemValue: '0.66',
        fitemUnit: 'UNIT1',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 8
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-09 HH:mm:ss.ZZZ',
        fitemValue: '0.66',
        fitemUnit: 'UNIT1',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 9
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-10 HH:mm:ss.ZZZ',
        fitemValue: '0.66',
        fitemUnit: 'UNIT1',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 10
      };
      maps.add(dummy);

      dummy = {
        fuserId: userId,
        ffacilityId: 'FFFF',

        fspCode: 'SPCODE1',
        fspName: 'SPNAME1',
        fitemCode: 'ITEMCODE1',
        fitemName: 'ITEMNAME1',

        fsampleDatetimeJST: 'yyyy-MM-11 HH:mm:ss.ZZZ',
        fitemValue: '0.8',
        fitemUnit: 'UNIT1',
        fitemOut: '基準値範囲内',

        fdocInfoIntId: 11
      };
      maps.add(dummy);
    }

    return maps;
  }

  //-------------------
  _runRest() async {
    CPTFRest rest = CPTFRest();
    String s = await rest.getTest() as String;
    print(s);
  }

  //-------------------
  // CPTFItemSelection
  _dataForItemSelection() {
    return <SelectionItem>[
      SelectionItem(title: "Aaryan", sub: "Shah"),
      SelectionItem(title: "Ben", sub: "John"),
      SelectionItem(title: "Carrie", sub: "Brown"),
      SelectionItem(title: "Deep", sub: "Sen"),
      SelectionItem(title: "Emily", sub: "Jane"),
      SelectionItem(title: "Aaryan", sub: "Shah"),
    ];
  }

  // ItemSelection
  List<Map> itemselectionmaps = List<Map>();

  // MultiCharts
  String userId = '12345678';
  List<Map> yMaps = List<Map>();

  // SingleChart
  Map<String, dynamic> singlechartmap;

  _prepareData() {
    itemselectionmaps.clear();

    itemselectionmaps.add({
      'title': 'AAAA',
      'sub': '1111'
    });

    itemselectionmaps.add({
      'title': 'CCCC',
      'sub': '2222'
    });

    itemselectionmaps.add({
      'title': 'BBBB',
      'sub': '3333'
    });

    //--------------------------------------------------------------------------

    yMaps.clear();

    Map dummy = {
      'userId': userId,
      'facilityId': 'FFFF',
      'spCode': 'SPCODE',
      'itemCode': 'ITEMCODE',
      'spName': 'SPNAME',
      'itemName': 'ITEMNAME',
      'itemUnit': 'UNIT'
    };
    yMaps.add(dummy);

    dummy = {
      'userId': userId,
      'facilityId': 'FFFF',
      'spCode': 'SPCODE1',
      'itemCode': 'ITEMCODE1',
      'spName': 'SPNAME1',
      'itemName': 'ITEMNAME1',
      'itemUnit': 'UNIT1'
    };
    yMaps.add(dummy);

    //--------------------------------------------------------------------------

    // 初回選択（黄色）項目
    // ===> 時間軸を統合する場合は縮退により選択が変化する
    singlechartmap = {
      fuserId: '12345678',
      ffacilityId: 'ffff',

      fspCode: "sp00",
      fspName: 'sp',
      fitemCode: 'item000',
      fitemName: 'item',

      fsampleDatetimeJST: '2019-01-24 12:34:56',
      fitemValue: '0.8',
      fitemUnit: '[Unit]',
      fitemOut: '基準値範囲内',

      fdocInfoIntId: 2
    };

  }

  @override
  Widget build(BuildContext context) {
    if (true) {
      // Application with Drawer

      return MultiProvider(
        child: MaterialApp(
          title: 'Application',
          theme: ThemeData(
            primarySwatch: Colors.teal,
          ),
          //home: MyAccountPage(title: 'アカウント設定'),
          //####################
          // 画面繊維のためのルートを定義する。
          // 実際の繊維のトリガーはDrawerなどからNavigator.of(context)によって行うので、
          // ここでの定義はルート名とページのMapを用意しているだけである。
          initialRoute: '/',
          routes: {
            '/': (context) => CPTFHome(),

            '/itemselection': (context) =>
                CPTFItemSelection(
                  title: 'Item Selection',
                  srcMaps: itemselectionmaps,
                  titleKey: 'title', subKey: 'sub',
                ),

            '/itemselection2': (context) =>
                CPTFItemSelection(
                  title: 'Item Selection 2',
                  dataForItemSelection: _dataForItemSelection,
                ),

            '/masterdetail': (context) =>
                CPTFMasterDetailContainer(
                  title: 'MasterDetail',
                  dataForMaster: _dataForMaster,
                ),

            '/progresstask': (context) => CPTFProgressTask(),

            '/multicharts': (context) =>
                CPTFMultiChartsPage(
                  title: 'Multi Charts', isInTabletLayout: false,
                  yMaps: yMaps,
                  dataForSingleChart: _dataForSingleChart,),

            '/singlechart': (context) =>
                CPTFSingleChartPage(
                    title: 'Chart', isInTabletLayout: false,
                    item: LaboTest.fromMap(singlechartmap),
                    listAroundItem: _listAroundItem
                ),

            '/linechart': (context) => CPTFLineChartPage(),

            '/syncscroll': (context) => SyncScrollPage(title: 'SyncScroll'),

            '/logincritter': (context) => CPTFLoginCritter(title: 'アカウント設定'),

            '/login': (context) => CPTFLogin(title: 'Login'),

            '/newpasscode': (context) => CPTFNewPassCode(title: 'パスコード登録'),
          }
        ),

        providers: <SingleChildCloneableWidget>[
          ChangeNotifierProvider<CPTFAppInfo>(
              builder: (_) => CPTFAppInfo()),
        ],
      );
    }

    /*
    if (true) {
      return MaterialApp(
          home:CPTFItemSelection(
            title: 'Item Selection',
            srcMaps: itemselectionmaps,
            titleKey: 'title', subKey: 'sub',
          )
      );
    }


    if (true) {
      return MaterialApp(
          home:CPTFItemSelection(
            title: 'Item Selection',
            dataForItemSelection: _dataForItemSelection,
          )
      );
    }

    if (true) {
      return MaterialApp(
          home:CPTFMasterDetailContainer(
            title: 'Master Detail',
            dataForMaster: _dataForMaster,
          )
      );
    }

    if (true) {
      return MaterialApp(
          home:CPTFProgressTask()
      );
    }

    if (true) {
      _runRest();
    }
    
    if (true) {
      return MaterialApp(
          home:CPTFMultiChartsPage(title: 'Multi Charts', isInTabletLayout: false,
            yMaps: yMaps,
            dataForSingleChart: _dataForSingleChart,)
      );
    }

    if (true) {
      return MaterialApp(
          home:CPTFSingleChartPage(
            title:'Chart', isInTabletLayout: false,
            item: LaboTest.fromMap(singlechartmap),
            listAroundItem: _listAroundItem
          )
      );
    }

    if (true) {
      return MaterialApp(
          home:CPTFLineChartPage()
      );
    }

    if (true) {
      return MaterialApp(
          home:SyncScrollPage(title: 'SyncScroll')
      );
    }

    if (true) {
      return MaterialApp(
          home:CPTFLoginCritter(title: 'アカウント設定')
      );
    }

    if (true) {
      return MaterialApp(
          home:CPTFLogin(title: 'Login')
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
    */
  }
}
