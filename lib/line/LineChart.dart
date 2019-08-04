import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:positioned_tap_detector/positioned_tap_detector.dart';

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

// void main() => runApp(MyApp());

// 以下のページに記載のソースを改造
// https://www.egao-inc.co.jp/programming/flutter_simple_chart/
//

class CPTFLineChart extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new CPTFLineChartPage(),
    );
  }
}

// サンプルページ
class CPTFLineChartPage extends StatelessWidget {
  // データ1
  final List<ChartData> _debugChartList =[
    new ChartData('19/04/13 00:00:00', 60.0),
    new ChartData('19/04/14 00:00:00', 50.0).setInfo(Colors.orange),
    new ChartData('19/04/15 00:00:00', 80.0),
    new ChartData('19/04/16 00:00:00', 60.0),
    new ChartData('19/04/17 00:00:00', 50.0),
    new ChartData('19/04/18 00:00:00', 80.0),
    new ChartData('19/04/19 00:00:00', 50.0).setInfo(Colors.orange),
    new ChartData('19/04/20 00:00:00', 80.0),
    new ChartData('19/04/21 00:00:00', 60.0),
    new ChartData('19/04/22 00:00:00', 50.0),
    new ChartData('19/04/23 00:00:00', 80.0)
  ];
  // データ2
  final List<ChartData> _debugChartList2 =[
    new ChartData('19/04/10 00:00:00', 60.0),
    new ChartData('19/04/11 00:00:00', 50.0),
    new ChartData('19/04/16 00:00:00', 60.0),
    new ChartData('19/04/17 00:00:00', 50.0),
    new ChartData('19/04/18 00:00:00', 80.0),
    new ChartData('19/04/19 00:00:00', 50.0).setInfo(Colors.orange),
    new ChartData('19/04/20 00:00:00', 80.0),
    new ChartData('19/04/21 00:00:00', 60.0),
    new ChartData('19/04/22 00:00:00', 50.0),
    new ChartData('19/04/23 00:00:00', 80.0)
  ];
  // データ3
  final List<ChartData> _debugChartList3 =[
    new ChartData('19/04/13 00:00:00', 60.0),
    new ChartData('19/04/14 00:00:00', 50.0).setInfo(Colors.orange),
    new ChartData('19/04/15 00:00:00', 80.0),
    new ChartData('19/04/16 00:00:00', 60.0),
    new ChartData('19/04/17 00:00:00', 50.0),
    new ChartData('19/04/18 00:00:00', 80.0),
    new ChartData('19/04/19 00:00:00', 50.0).setInfo(Colors.orange),
    new ChartData('19/04/20 00:00:00', 80.0),
    new ChartData('19/04/25 00:00:00', 50.0).setInfo(Colors.orange),
    new ChartData('19/04/26 00:00:00', 80.0)
  ];

  // チャートのタイトルの高さ
  double CHART_TITLE_HEIGHT = 32.0;

  // チャート全体（タイトル、目盛など含む）の高さ
  // 日付文字列を９０度回転しているので大きめにする。
  double CHART_CONTAINER_HEIGHT = 260.0;

  // チャートの折れ線などの描画エリア(CustomPaint)の高さ
  double CHART_HEIGHT = 150.0;
  // ===> CHART_CONTAINER_HEIGHTからCHART_HEIGHTを引いた高さが、
  //      X軸のTicks文字列エリアに使われる

  double CHART_AXIS_Y_LABEL_WIDTH = 30.0;
  // Y軸の文字表示幅

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Line Chart', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        elevation: 1.0,

        /*
        actions: <Widget>[
          FlatButton(
            textColor: Colors.red,
            onPressed: () {
            },
            child: Text("Save"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
        */

      ),

      /*
      drawer: Container(
        width: size.width / 5 * 4,
        child: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text("Item 1"),
              ),
            ],
          ),
        ),
      ),

      */

      body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: CHART_CONTAINER_HEIGHT,
                      margin: const EdgeInsets.only(top: 10.0),
                      decoration: BoxDecoration(
                        border: new Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CPTFChartContainer(
                              _debugChartList, "CHART A",CHART_TITLE_HEIGHT,
                              CHART_CONTAINER_HEIGHT,
                              CHART_HEIGHT,
                              CHART_AXIS_Y_LABEL_WIDTH,
                              2, null, null,
                              null, null)
                      ),
                    ),
                    Container(
                      height: CHART_CONTAINER_HEIGHT,
                      margin: const EdgeInsets.only(top: 10.0),
                      decoration: BoxDecoration(
                        border: new Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CPTFChartContainer(_debugChartList2, "CHART B",CHART_TITLE_HEIGHT,
                              CHART_CONTAINER_HEIGHT,
                              CHART_HEIGHT,
                              CHART_AXIS_Y_LABEL_WIDTH,
                              0, null, null,
                              null, null)
                      ),
                    ),
                    Container(
                      height: CHART_CONTAINER_HEIGHT,
                      margin: const EdgeInsets.only(top: 10.0),
                      decoration: BoxDecoration(
                        border: new Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CPTFChartContainer(_debugChartList3, "CHART C",CHART_TITLE_HEIGHT,
                              CHART_CONTAINER_HEIGHT,
                              CHART_HEIGHT,
                              CHART_AXIS_Y_LABEL_WIDTH,
                              0, null, null,
                              null, null)
                      ),
                    ),
                  ]

              )
          )
      ),
    );
  }
}

//----------------------------------------
//----------------------------------------
//----------------------------------------


// 共通チャートデータクラス
class ChartData {
  double y;
  String x;
  var info;// 付加情報オプション
  ChartData(this.x, this.y): super();

  ChartData setInfo(info) {
    this.info = info;
    return this;
  }
}

// double CHART_WIDTH = 300.0;
// double CHART_HEIGHT = 140.0;
// double CHART_TITLE_HEIGHT = 32.0;

// ===> チャート全体の高さは、呼び出し側で定義した、CHART_CONTAINER_HEIGHTで調整。
//     日付文字列を９０度回転しているので大きめにする。

// チャートの描写をする為に位置計算などして表示するクラス
// ===> クリック検出で再描画したいので、StatelessWidgetからStatefulWidgetに変更する。

class CPTFChartContainer extends StatefulWidget {
  CPTFChartContainer(
      this.chartDatatList,
      this.chartTitle,
      this.chartTitleHeight,
      this.chartContainerHeight,
      this.chartHeight,

      this.chartAxisYLabelWidth,
      this.initialSelectedIndex,
      this.chartSelectionChanged,

      this.fullXProviderFunc,
      this.scrollController,
      //this.acrollNotificationHandler
      this.syncController
      ) : super() {

    print('ChartContainer');

    print(chartDatatList.length.toString());
    print(chartTitle.toString());
    print(chartTitleHeight.toString());
    print(chartContainerHeight.toString());
    print(chartHeight.toString());

    print(chartAxisYLabelWidth.toString());
    print(initialSelectedIndex.toString());
    print(chartSelectionChanged.toString());

  }

  // チャートのデータ配列
  final List<ChartData> chartDatatList;// 外部入力データ

  // チャートのタイトル
  final String chartTitle;

  // チャートのタイトルの高さ
  final double chartTitleHeight;

  // チャート全体の高さ（タイトルや軸など含む）
  final double chartContainerHeight;// 呼び出しもとから指定するので、ここで数値を割り当てるとエラー

  // チャートの高さ
  final double chartHeight;

  final double chartAxisYLabelWidth;

  // 初期選択ポイントのインデックス(0,1,2,...), データ配列範囲内
  final int initialSelectedIndex;

  final chartSelectionChanged;//チャートの選択が変わったときの呼び出し関数

  final fullXProviderFunc; //他のチャートで出現するX軸の値も含めた全体を得るための関数

  final ScrollController scrollController;

  //final acrollNotificationHandler;// スクロールでのonNotificationで対応する関数
  final syncController;

  @override
  CPTFChartContainerState createState() => CPTFChartContainerState();
}

class CPTFChartContainerState extends State<CPTFChartContainer> {
  // class ChartContainer extends StatelessWidget {

  Color LABEL_X_TEXT_COLOR =  Colors.grey[900];
  Color LABEL_X_EVEN_COLOR =  Colors.grey[50];
  Color LABEL_X_ODD_COLOR =  Colors.grey[100];
  double LABEL_X_FONT_SIZE = 13.0;

  Color LABEL_Y_TEXT_COLOR =  Colors.grey[900];
  Color LABEL_Y_EVEN_COLOR =  Colors.grey[50];
  Color LABEL_Y_ODD_COLOR =  Colors.grey[100];
  double LABEL_Y_FONT_SIZE = 13.0;
  Color CHAR_AXIS_Y_CONTAINER_COLOR = Colors.grey[50];

  Color CHART_TITLE_CONTAINER_COLOR = Colors.teal;
  Color CHART_TITLE_TEXT_COLOR = Colors.white;
  double CHART_TITLE_TEXT_SIZE = 16.0;

  // チャートの上マージン
  final double _chartTopMargin =20.0;
  // チャートの左右マージン（レコード数が２件以上ある場合にX軸ラベルに適用する。）
  final double _chartSideMargin = 10.0;
  final double _chartSideMarginForOneRecord = 5.0;

  double _chartWidth = 0.0;

  // 目盛り数値の高さ
  final double _scaleNumHeight = 20.0;
  // 目盛りに表示させる数値の配列
  List<String> _scaleNumbers;// _getNormalizedChartDataListで確定する。

  List<ChartData> _normalizedChartDataList;

  String _dummy;

  int _selectedIndex;

  Map<String, int> dictXIndex() {
    Map<String, int> map = Map<String, int>();

    widget.chartDatatList.forEach((element) {
      ChartData cd = element as ChartData;
      map[cd.x] = widget.chartDatatList.indexOf(element);
    });

    return map;
  }

  /*
  // xからオブジェクトを探す。
  // ===> パフォーマンスが悪いので、dictXIndexで辞書を作って探すように修正
  ChartData find(String x) {
    ChartData found = null;

    widget.chartDatatList.forEach((element) {
      ChartData cd = element as ChartData;
      if (cd.x == x) {
        found = cd;
      }
    });

    return found;
  }
  */

  initChart() {

    _dummy = DateTime.now().toString();

    int mergedSelectedIndex = widget.initialSelectedIndex;;
    List<ChartData> mergedChartDataList = null;

    //#####################################
    // 時間軸を統合（縮退）する場合は、外部から日付リスト（横軸文字列）をもらう。
    if (widget.fullXProviderFunc != null) {

      List<String> full = widget.fullXProviderFunc() as List<String>;
      // print('================ full in Chart');
      // print(full);

      int index = 0;

      Map<String, int> dictX = dictXIndex();
      // print('dictX');
      // print(dictX.toString());

      mergedChartDataList = [];

      full.toList().forEach((element) {
        String newX = element.toString();
        // print('MERGE CHECK FOR newX: ' + newX);

        ChartData found = null;//find(newX);
        if (dictX.containsKey(newX)) {
          found = widget.chartDatatList[dictX[newX] as int];

          // print('該当あり');
          mergedChartDataList.add(found);
          if (widget.chartDatatList.indexOf(found) == widget.initialSelectedIndex) {
            mergedSelectedIndex = index;
          }
        } else {
          // print('該当なし');
          ChartData cdNull = ChartData(newX, null);
          mergedChartDataList.add(cdNull);
        }

        index++;
      });

    }
    //#####################################

    _selectedIndex = mergedSelectedIndex;
    // print('====> _selectedIndex: $_selectedIndex');

    // データを正規化する
    if (mergedChartDataList != null) {
      // print('===> normalize with merged list');

      _normalizedChartDataList = _getNormalizedChartDataList(mergedChartDataList);
    } else {

      // print('===> normalize with original data');
      _normalizedChartDataList = _getNormalizedChartDataList(widget.chartDatatList);
    }

    if (_normalizedChartDataList != null) {
      // データの個数によって、チャートの幅を決める。
      // ===> スクロール可能なエリア上にあるので、大きさは実行時のデバイスの画面の向きや横幅には左右されない。
      _chartWidth = _normalizedChartDataList == null ? 0 :  40.0 * _normalizedChartDataList.length;

      Future.delayed( Duration(milliseconds: 500), () async {

        try {
          // scrollToEnd();
          scrollToItem(_selectedIndex);
        } catch (e) {

        }

        // ### Fake Selection Change
        if (widget.chartSelectionChanged != null) {
          print('====> initChart CALLING chartSelectionChanged');
          /*if (_normalizedChartDataList[_selectedIndex] != null) {
            print(_normalizedChartDataList[_selectedIndex]);
          }*/

          // Unhandled Exception: RangeError (index): Invalid value: Not in range 0..47, inclusive: -1

          widget.chartSelectionChanged(
              this,
              _selectedIndex,
              _selectedIndex >= 0 && _selectedIndex < _normalizedChartDataList.length ?
              _normalizedChartDataList[_selectedIndex] : null
          );
        } else {
          print('NO chartSelectionChanged ASSINGED');
        }

      });
    } else {
      _chartWidth = 0;
    }
  }

  @override
  initState() {
    super.initState();

    print('MyChartContainerState initState');

    if (widget.scrollController != null) {
      _chartScrollController = widget.scrollController;
    } else {
      _chartScrollController = ScrollController();
    }

    if (widget.syncController != null && _chartScrollController != null) {
      widget.syncController.registerScrollController(_chartScrollController);
    }

    initChart();
  }

  @override
  dispose() {
    print('MyChartContainerState dispose');

    if (widget.syncController != null && _chartScrollController != null) {
      widget.syncController.unregisterScrollController(_chartScrollController);
    }

    super.dispose();
  }

  // 0でない値を持っているかチェックする。
  final int ALL_ZEROS = 1;
  final int EMPTY = 2;
  final int HAS_NON_ZERO = 3;

  int hasNonZeroValue() {

    List<double> notNullValues = List<double>();

    bool foundNonZeroValue = false;

    for (var data in widget.chartDatatList) {
      double val = data.y;
      if (val == null) {
        continue;
      } else {
        //数値が存在しているが、0以外の値かどうか確認する
        if (val != 0) {
          foundNonZeroValue = true;
        }

        notNullValues.add(val);
      }
    }

    if (notNullValues.length == 0) {
      // 数値なし
      return EMPTY;
    } else {

      // 数値は見つかった
      if (foundNonZeroValue == true) {
        // 0でない値をもつリスト
        return HAS_NON_ZERO;
      } else {
        // ０しか存在しないリスト
        return ALL_ZEROS;
      }
    }
  }

  // チャートのデータを生成し返す（グラフに共通値に変換）
  // ===> ChartPainterで使用するためのもの
  // ===> 欠損値も許可するように拡張
  List<ChartData> _getNormalizedChartDataList(List<ChartData> chartDatatList) {
    _scaleNumbers = List<String>();


    print('_getNormalizedChartDataList');

    if (chartDatatList == null) return null;
    if (chartDatatList.length < 1) return null;

    // nullでも0でもない値を持っているかチェックする。
    int check = hasNonZeroValue();

    if (check == ALL_ZEROS) {

      _scaleNumbers.add('0');

      return chartDatatList;

    } else if (check == EMPTY) {

      if (chartDatatList.length < 1) return null;

    } else if (check == HAS_NON_ZERO) {
      // 処理を継続してよい
    }

    // print(chartDatatList.toString());
    // --> 大量出力注意

    List<double> list = List<double>();

    var yMin = 0.0;
    var yMax = 0.0;
    var coarseVal = 0.0;
    var coarese = 0.0;
    var coareseDigit = 0;

    while(coarese < 1.0){
      // print('while coarese $coarese');

      //小さな値で変化がない場合には、x10, x100, ...として評価して、
      //数値の「変動」と際立つようにする。
      //####
      //#### ====> すべてがnull, 0 のデータに対しては、何倍しても0のままなので、無限ループとなる。
      //####
      for (var data in chartDatatList) {
        // 欠損値nullは追加しない
        if (data.y != null) {
          double val = data.y * math.pow(10, (coareseDigit));
          // print('val $val');
          list.add(val);
        }/* else {
          print('null value');
        }*/
      }

      if (list.length < 1) {
        print('list is empty');
        break;
      }

      list.sort();
      yMin = list.first;
      yMax = list.last;

      // 最大値と最小値の差
      double _differenceVal = yMax - yMin;

      // #### 入力値がnullと0のみの場合や、すべて同じ値の場合など、
      // #### 数値に変化がないと無限ループになる。


      // 目盛り単位数を求める（2d ≤ w）
      // dは隣り合う目盛りどうしの間隔、
      // wはグラフ領域全体の幅を表す
      // http://www.eng.niigata-u.ac.jp/~nomoto/21.html
      coarseVal = _differenceVal / 2.0;
      coarese = coarseVal.round().toDouble();
      coareseDigit++;
    }

    // print('coarese $coarese');
    // print('coarseVal $coarseVal');
    // print('coareseDigit $coareseDigit');

    double scaleYMax = 0;
    double scaleYMin = 0;

    var digit = 0;
    while(coarese > 10.0){
      coarese /= 10.0;
      digit++;
    }

    // print('coarese $coarese');
    // print('coarseVal $coarseVal');
    // print('digit $digit');

    List<int> scaleValues = [1, 2, 5];
    bool isFinish = false;
    int count = 0;
    int multiple = 0;
    int scaleUnitVal = 0;
    while(!isFinish){
      scaleUnitVal = scaleValues[count] * math.pow(10, (digit + multiple)) as int;
      if ((scaleUnitVal * 2) > coarseVal) {
        isFinish = true;
      }

      if (count == (scaleValues.length - 1)) {
        count = 0;
        multiple++;
      } else {
        count++;
      }
    }

    // print('scaleUnitVal $scaleUnitVal');

    // 目盛りの数値が整数値か
    var isInteger = _isIntegerInData(chartDatatList);

    // 目盛りの下限値を算出
    var lowerScaleVal = yMin - (yMin % scaleUnitVal);
    _addScaleNumberList(lowerScaleVal, isInteger, coareseDigit);


    // 目盛りの数値一覧を生成する
    var scaleVal = lowerScaleVal;
    scaleYMin = lowerScaleVal;
    while(yMax > scaleVal){
      scaleVal += scaleUnitVal;
      scaleYMax = scaleVal;
      _addScaleNumberList(scaleVal, isInteger, coareseDigit);
    }

    _scaleNumbers = _scaleNumbers.reversed.toList();

    //print('scaleYMax ' + scaleYMax.toString());
    //print('scaleYMin ' + scaleYMin.toString());
    //print('_scaleNumbers ' + _scaleNumbers.toString());
    //print('coareseDigit ' + coareseDigit.toString());
    // 一座標の数値を算出
    double _unitPoint = 100.0 / (scaleYMax - scaleYMin);

    // Y軸の値を[0,1]に正規化した点列を作る。
    List<ChartData> _chartList = List<ChartData>();

    for (var data in chartDatatList) {
      // 欠損値nullがあればnewYもnullにしておく
      double _newY = data.y == null ? null : (100.0 - (((data.y * math.pow(10, (coareseDigit - 1))) - scaleYMin) * _unitPoint)) / 100.0;

      //print('data.x ${data.x}, data.y ${data.y} ---> _newY: $_newY');
      //#######
      // infoをそのまま引き継ぐ
      //#######
      _chartList.add(new ChartData(data.x, _newY).setInfo(data.info));
    }
    /*
    入力値が0.0から0.3までの場合に、チャートは目盛が[0.3, 0.2, 0.1, 0]となり、
    表示用の数値は0.0から1.0にスケールされる。

flutter: scaleYMax 3.0
flutter: scaleYMin 0.0
flutter: _scaleNumbers [0.3, 0.2, 0.1, 0]
flutter: coareseDigit 2
flutter: data.y 0.2 ---> _newY: 0.33333333333333326
flutter: data.y 0.2 ---> _newY: 0.33333333333333326
flutter: data.y 0.2 ---> _newY: 0.33333333333333326
flutter: data.y 0.0 ---> _newY: 1.0
flutter: data.y 0.2 ---> _newY: 0.33333333333333326
flutter: data.y 0.2 ---> _newY: 0.33333333333333326
flutter: data.y 0.0 ---> _newY: 1.0
flutter: data.y 0.3 ---> _newY: 0.0
flutter: data.y 0.3 ---> _newY: 0.0
flutter: data.y 0.3 ---> _newY: 0.0
...
     */

    return _chartList;
  }

  // 目盛り数リストに追加
  void _addScaleNumberList(double num, bool isInteger, int pow) {

    if (num == 0){
      _scaleNumbers.add('0');
    } else {

      if (pow > 1){
        var n = num / math.pow(10, (pow - 1));
        _scaleNumbers.add(n.toString());
        return;
      }

      if (isInteger) {
        int _num = num.toInt();
        _scaleNumbers.add(_num.toString());
      } else {
        _scaleNumbers.add(num.toString());
      }
    }
  }


  // データ内の数値はすべて整数か判断
  bool _isIntegerInData(List<ChartData> list) {
    for (var data in list) {
      if (data.y == null) {
        // 欠損値
        return false;
      }
      if (!_isInteger(data.y)) {
        return false;
      }
    }
    return true;
  }

  // 整数値か判断
  bool _isInteger(double x) {
    return (x.round() == x);
  }

  // https://stackoverflow.com/questions/44276080/how-do-i-rotate-something-15-degrees-in-flutter
  // 90度回転

  // 日付のレイアウトを生成し返す
  // #### 横軸のラベルとなる。
  // #### ===> 日付は、90度回転して表示する。

  List<Widget> _getDateLayout(List<ChartData> list) {

    //print('_getDateLayout list.length ${list.length}');
    //print('_getDateLayout list ' + list.toString());

    if (list == null) {
      return [];
    }

    // レイアウト配列
    List<Widget> _dateLayoutList = List<Widget>();

    int cnt = 0;
    Color boxColor = null;
    Color textColor = null;

    String x = '';

    for (var chartData in list) {

      boxColor = (cnt%2 == 0 ? LABEL_X_EVEN_COLOR : LABEL_X_ODD_COLOR);
      textColor = LABEL_X_TEXT_COLOR;

      // #### チャートに表示するためのinfoデータがあるか
      // #### 色指定があるか
      if (chartData.info != null) {
        if (chartData.info is Color) {
          boxColor = chartData.info as Color;

          textColor = Colors.grey[100];
        }
      }

      x = chartData.x == null ? '' : chartData.x.toString();
      print('_getDateLayout　[$cnt] chartData.x = ' + x + ', y = ' +
          (chartData.y == null ? 'null' : chartData.y.toString())
      );
      /*
flutter: _getDateLayout　chartData.x = 18/12/04 10:06:18, y = 0.8199999999999997
flutter: _getDateLayout　chartData.x = 19/03/04 11:24:55, y = 0.6133333333333335
flutter: _getDateLayout　chartData.x = 19/06/04 08:37:53, y = 0.8066666666666668
       */

      //#############
      //
      // x ---> yy/MM/dd HH:mm:ss ---> yy/MM/ddで表示
      //
      x = x.substring(0, 8);
      //#############

      Widget widget = (Expanded(
        child: Container(
          color: boxColor,
          child:RotatedBox(
              quarterTurns: 1,
              child:Text(
                x,
                style: TextStyle(
                    fontSize: LABEL_X_FONT_SIZE,
                    color: textColor
                ),
              )
          ),
          alignment: Alignment.topCenter,
        ),
      ));

      _dateLayoutList.add(widget);

      cnt++;
    }

    print('_getDateLayout _dateLayoutList ' + _dateLayoutList.length.toString());

    return _dateLayoutList;
  }

  // 数値のレイアウトを生成し返す
  Widget _getChartNumberLayout() {
    // レイアウト配列
    List<Widget> barLayoutList = List<Widget>();

    //### すべてnullの時系列の場合でも割り算(_horizontalBarNum - 1)でNaNが発生しないように、2にセットする。
    var _horizontalBarNum = _scaleNumbers == null ? 2 :  _scaleNumbers.length;

    // グラフ目盛り数値のマージン計算
    var marginHeight = (widget.chartHeight - _chartTopMargin * 2) / (_horizontalBarNum - 1) - _scaleNumHeight;

    // #### チャートの高さ指定が小さくて計算上マイナスになってしまう場合がある。
    // #### マイナスは０に調整する。
    if (marginHeight < 0) {
      marginHeight = 0.0;
    }

    int cnt = 0;

    String label = '';

    for (var i = 0; i < _horizontalBarNum; i++) {
      cnt++;

      try {
        label = _scaleNumbers[i];
      } catch (e) {
        label = '';
      }

      Widget widget = (Container(
        color: (cnt%2 == 0 ? LABEL_Y_EVEN_COLOR : LABEL_Y_ODD_COLOR),
        child: Text(label, //#### Y軸の目盛の数字をテキストにして表示する。
            style: TextStyle(
                fontSize: LABEL_Y_FONT_SIZE,
                color: LABEL_Y_TEXT_COLOR
            )
        ),
        height: _scaleNumHeight,
        alignment: Alignment.centerRight,
        margin: EdgeInsets.only(top: (i == 0 ? 0 : marginHeight)),
      )
      );

      barLayoutList.add(widget);
    }

    // print('_getChartNumberLayout barLayoutList ' + barLayoutList.toString());
    print('_getChartNumberLayout barLayoutList ' + barLayoutList.length.toString());

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: barLayoutList,
    );
  }

  /*
  // GestureDetector
  double _x;
  double _y;
  double _len;
  */

  //------------------------------------------
  //------------------------------------------
  //------------------------------------------
  // https://pub.dev/packages/positioned_tap_detector#-installing-tab-
  String _gesture = "";
  TapPosition _position = TapPosition(Offset.zero, Offset.zero);

  void _onTap(TapPosition position) => _updateState('single tap', position);

  void _onDoubleTap(TapPosition position) =>
      _updateState('double tap', position);

  void _onLongPress(TapPosition position) =>
      _updateState('long press', position);

  // タップされた位置から描画を更新するか決める
  void _updateState(String gesture, TapPosition position) {
    print('_updateState FOR TAP');

    //setState(() {
    _gesture = gesture;
    _position = position;
    //});

    print("Gesture: $_gesture\n" +
        "Global: ${_formatOffset(_position.global)}\n" +
        "Relative: ${_formatOffset(_position.relative)}");


    // ローカルに変換した値でヒットテストする。
    double dx = _position.relative.dx;
    double dy = _position.relative.dy;

    //#### ChartPainterは実際に描画を「実施した」ので、
    //#### ヒットテストを以来ヒットテストを依頼する。

    int itemIndex = hitTestWithLastPaintedSize(dx, dy);

    print('hitTest result =  $itemIndex');

    // ヒットしたのでダミーのステート文字列を更新して
    // ステートのbuildが呼ばれるようにする。
    // ChartPainterはbulidの中で確保されるので、
    // 最新の_selectedIndexとともに描画が行われる。
    setState(() {
      _selectedIndex = itemIndex;
      _dummy = DateTime.now().toString();
    });

    // ===> コールバックを使う
    if (widget.chartSelectionChanged != null) {
      print('====> _updateState CALLING chartSelectionChanged');


      if (_selectedIndex >= 0 && _selectedIndex < _normalizedChartDataList.length) {
        if (_normalizedChartDataList[_selectedIndex] != null) {
          print(_normalizedChartDataList[_selectedIndex]);
        }

        widget.chartSelectionChanged(
            this, _selectedIndex, _normalizedChartDataList[_selectedIndex]);
      }
    } else {
      print('NO chartSelectionChanged ASSINGED');
    }
  }

  // #### ChartPainter上のヒットテスト ####
  // ChartPainterはbuidの都度確保して描画を行うが、
  // ヒットテストは、ChartPainterに対して問い合わせるのではなく、ステートクラスで行う。
  // ホットスポット（点）をどこに描画するのか、ChartPainterのロジックと一定するものを
  // ここで用意して、ヒットテストに使う。
  Offset getPointOffset(Size size, double y, int count) {
    // 欠損値があれば描画しないのでオフセットはnull
    if (y == null) {
      return null;
    }

    double pointY = _chartTopMargin + ((size.height - _chartTopMargin * 2) * y);
    double scopeWidth = size.width - (_chartSideMargin * 2);
    double pointX = (scopeWidth / (_normalizedChartDataList.length * 2) * (count + 1)) + (scopeWidth / (_normalizedChartDataList.length * 2) * count) + _chartSideMargin;

    return  Offset(pointX, pointY);
  }

  int hitTestWithLastPaintedSize(double dx, double dy) {
    Offset curr = null;
    int len = _normalizedChartDataList.length;

    Size size = Size(_chartWidth, widget.chartHeight);

    int r = 10;

    for (var i = 0; i <  len; i++) {
      // 欠損値は判定できない
      if (_normalizedChartDataList[i].y == null) continue;

      curr = getPointOffset(size, _normalizedChartDataList[i].y, i);
      if (curr == null) {
        continue;
      }

      print('curr ${curr.dx}, ${curr.dy}');
      if (
      dx - r < curr.dx && curr.dx < dx + r
          && dy - r < curr.dy && curr.dy < dy + r
      ) {
        print('HIT !!!!');

        print('selectedIndex = $i');
        _selectedIndex = i;

        return _selectedIndex;
      }
      else {
        print('MISS');
      }
    }

    return -1;
  }


  String _formatOffset(Offset offset) =>
      "${offset.dx.toStringAsFixed(1)}, ${offset.dy.toStringAsFixed(1)}";
  //------------------------------------------
  //------------------------------------------
  //------------------------------------------


  ScrollController _chartScrollController;

  void scrollToEnd() {
    if (_chartScrollController != null) {
      _chartScrollController.animateTo(
          _chartWidth,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    }
  }

  // #### 所定のポイントまでスクロールする。
  // #### _ILaboTestChartPageStateなど呼び出し元から呼び出せるようにした。
  // ===> スクロールとともに選択状態も変える。
  void scrollToItem(int index) {
    if (_normalizedChartDataList == null) return;

    if (index < 0 || index >= _normalizedChartDataList.length) {
      // out of bounds
      return;
    }

    ChartData data = _normalizedChartDataList[index];
    if (data.y == null) return;

    Offset curr =  getPointOffset(Size(_chartWidth, widget.chartHeight), data.y, index);
    if (curr == null) return;

    double offset = curr.dx;
    // 点の中心がスクロールに左にぴったりくるので、点が半分だけみえる状態になる。
    // ==> 少し余裕をみて値を設定する。
    offset = offset - CHART_PAINT_POINT_CIRCLE_SIZE * 10;
    if (offset < 0.01) {
      offset = 0.0;
    }

    _chartScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);

    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {

    // 正規化したデータを使ってペイントするためのヘルパーを用意する。
    // ===> 「現在の」状態で描画をしなおすので、chartPainterを使いまわすのではなく、
    //       buildのタイミングで確保すること。
    ChartPainter chartPainter = ChartPainter(
        _scaleNumbers == null ? 0 : _scaleNumbers.length,
        _chartTopMargin,
        _normalizedChartDataList,
        _chartSideMargin,
        widget.initialSelectedIndex,
        _selectedIndex,
        _dummy
    );

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // タイトル
          Container(
            color: CHART_TITLE_CONTAINER_COLOR,
            alignment: Alignment.topCenter,
            height: widget.chartTitleHeight,
            child: Container(
              margin: const EdgeInsets.only(left: 10.0, right: 0, top: 5.0, bottom: 0),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.chartTitle,// タイトル文字列

                style: TextStyle(
                    fontSize: CHART_TITLE_TEXT_SIZE,
                    color: CHART_TITLE_TEXT_COLOR),
              ),
            ),
          ),

          //　タイトルの下に１つだけExpendedを配置して、全体をカバーする。
          Expanded(
              child:
              Row(children: <Widget>[

                // Y軸の目盛の文字
                Container(
                  color: CHAR_AXIS_Y_CONTAINER_COLOR,
                  alignment: Alignment.topCenter,
                  width: widget.chartAxisYLabelWidth,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: _getChartNumberLayout(),
                  ),
                ),

                // チャート描画エリア
                Expanded(child:NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    // 時間軸を統合する場合はfullProviderFuncがあり、
                    // スクローラーを同期させる。
                    if (widget.fullXProviderFunc != null &&
                        widget.syncController != null &&
                        _chartScrollController != null) {

                      widget.syncController.processNotification(
                          scrollInfo, _chartScrollController);
                    }
                  },
                  child:
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _chartScrollController,
                      child: Container(
                        width: _chartWidth,
                        child:
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              PositionedTapDetector(
                                  onTap: _onTap,
                                  onDoubleTap: _onDoubleTap,
                                  onLongPress: _onLongPress,
                                  child:
                                  Container(// マージンをいれず、CustomPaintの描画エリアとサイズを一致させておく
                                    color: Colors.black,//### ここの色は隠される。
                                    // width: CHART_WIDTH,//### ここでサイズ指定をしなければ均等に横に展開される。
                                    height:widget.chartHeight,
                                    child: CustomPaint(
                                      // 経線とプロットを描く
                                      painter: chartPainter,
                                      child: Container(
                                      ),
                                    ),
                                  )
                                //----------
                              ),

                              // X軸の文字
                              Expanded(child: Container(
                                width: _chartWidth,
                                color: Colors.grey[50], // ここの色はデータなしの場合にだけ見える。
                                // ##### marginはデータが１件しかない場合には１項目を隠してしまうので、
                                // ##### ２件以上ある場合にだけ大きな値を使う。１件の場合は0
                                margin: _normalizedChartDataList.length > 1 ? EdgeInsets.symmetric(horizontal: _chartSideMargin) : EdgeInsets.all(_chartSideMarginForOneRecord),
                                child: Row(children:_getDateLayout(_normalizedChartDataList)),
                              )),

                            ]
                        ),
                      )


                  ),
                ),
                ),

              ],
              )),
        ]
    );
  }
}

// https://medium.com/flutteropen/canvas-tutorial-05-how-to-use-the-gesture-with-the-custom-painter-in-the-flutter-3fc4c2deca06
// CustomPainterの上でタップを検出する。
// ===> GestureDetectorで独自に調整しないで、ライブラリを使う。

Color CHART_PAINT_BACKGROUND_COLOR = Colors.green[50];
Color CHART_PAINT_AXIS_Y_TICK_LINE_COLOR = Colors.grey;
Color CHART_PAINT_LINE_COLOR = Colors.grey[400];
Color CHART_PAINT_POINT_COLOR = Colors.grey[900];
double CHART_PAINT_POINT_CIRCLE_SIZE = 7.0;

Color CHART_PAINT_FIRSTSELECTED_COLOR = Colors.yellow;
Color CHART_PAINT_SELECTED_COLOR = Colors.teal;

double CHART_PAINT_SELECTED_STROKE_WIDTH = 4.0;

// チャートグラフ
class ChartPainter extends CustomPainter {

  final double _circleSize = CHART_PAINT_POINT_CIRCLE_SIZE;
  int _horizontalBarNum;
  double _horizontalAdjustHeight = 10.0;
  double _varticalAdjustWidth = 20.0;

  int selectedIndex = -1;// 点を選択状態にする要素index (-1など配列要素範囲外でもよい）
  int firstSelectedIndex;// 最初に与えられた選択インデックス

  String dummy;

  List<ChartData> _chartList;// 描画用に正規化されたChartDataのリスト

  ChartPainter(
      this._horizontalBarNum,
      this._horizontalAdjustHeight,
      this._chartList,
      this._varticalAdjustWidth,
      this.firstSelectedIndex,
      this.selectedIndex,
      this.dummy
      ): super() {

    print('##### INIT CHART PAINTER $firstSelectedIndex, $selectedIndex');

  }

  Size lastPaintedSize;
  void keepLastPaintedSize(Size size) {
    // print('paint with size ' + size.toString()); // Size(300.0, 140.0)
    lastPaintedSize = size;
  }

  @override
  void paint(Canvas canvas, Size size) {

    keepLastPaintedSize(size);

    // ===> flutter: paint with size Size(364.0, 140.0)
    //      flutter: paint with size Size(846.0, 140.0)
    //
    // ===> チャートに指定した高さに一致する。
    //      チャートの高さ
    //       final double _chartHeight = CHART_HEIGHT;


    final paint = Paint();
    paint.color = CHART_PAINT_BACKGROUND_COLOR;
    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);


    // 罫線横軸
    paint.color = CHART_PAINT_AXIS_Y_TICK_LINE_COLOR;
    var horizontalHeight = (size.height - _horizontalAdjustHeight * 2) / (_horizontalBarNum - 1);
    for (var i = 0; i < _horizontalBarNum; i++) {
      double y = horizontalHeight * i + _horizontalAdjustHeight;
      // print('y = $y');
      // flutter: y = NaN
      if ('$y' == 'NaN') {
        y = 0.0;
      } else {
        canvas.drawLine(Offset(10, y), Offset(size.width - 10, y), paint);
      }
    }

    int len = _chartList == null ? 0 : _chartList.length;
    Offset o1 = null;
    Offset o2 = null;
    int firstNonNullIndex = 0;
    Offset curr = null;

    //#####
    // 欠損値 (y == null)の場合を考慮する。
    //#####

    // 折れ線が点の上に描かれないように、先に描く
    paint.color = CHART_PAINT_LINE_COLOR;
    paint.strokeWidth = CHART_PAINT_SELECTED_STROKE_WIDTH;

    // 折れ線の線分を先に描く
    bool showLine = true;

    if (showLine) {
      if (len <= 1) {
        // １点のみ
      } else {
        // 最初の「欠損していない」ポイントを探す
        for (var i = 0; i < len; i++) {
          // ポイントのオフセットを取得する。欠損値なら描画しないのでオフセットもnull
          curr = _chartList[i].y == null ? null : getPointOffset(
              size, _chartList[i].y, i);
          if (curr != null) {
            o1 = curr;
            firstNonNullIndex = i;
            break;
          }
        }

        if (o1 == null) {
          // すべて欠損
        } else {
          // 欠損していないインデックスから開始する（末尾である可能性あり）
          if (firstNonNullIndex == len - 1) {
            // 末尾の１点
          } else {
            // 見つかった箇所から末尾まで。
            for (var i = firstNonNullIndex; i <= (len - 1); i++) {
              // ポイントのオフセットを取得する。欠損値なら描画しないのでオフセットもnull
              curr = _chartList[i].y == null ? null : getPointOffset(
                  size, _chartList[i].y, i);


              //###############################
              // 欠損はとばして、存在する点を結ぶ方針
              o2 = curr;
              if (o1 != null && o2 != null) {
                // PAINT LINE
                canvas.drawLine(o1, o2, paint);
                // FOR NEXT
                o1 = o2;
                continue;
              }
              //###############################

            }
          }
        }
      }
    }

    // 最後に点を描く
    for (var i = 0; i <  len; i++) {
      if (_chartList[i].y == null) continue;

      curr = _createPoint(canvas, size, paint, _chartList[i].y, i);
    }
  }

  Offset getPointOffset(Size size, double y, int count) {
    if (y == null) return null;

    double pointY = _horizontalAdjustHeight + ((size.height - _horizontalAdjustHeight * 2) * y);
    double scopeWidth = size.width - (_varticalAdjustWidth * 2);
    double pointX = (scopeWidth / (_chartList.length * 2) * (count + 1)) + (scopeWidth / (_chartList.length * 2) * count) + _varticalAdjustWidth;

    return  Offset(pointX, pointY);
  }

  Offset _createPoint(Canvas canvas, Size size, Paint paint, double y, int count) {

    double pointY = _horizontalAdjustHeight + ((size.height - _horizontalAdjustHeight * 2) * y);
    double scopeWidth = size.width - (_varticalAdjustWidth * 2);
    double pointX = (scopeWidth / (_chartList.length * 2) * (count + 1)) + (scopeWidth / (_chartList.length * 2) * count) + _varticalAdjustWidth;

    // 円背景
    paint.color = CHART_PAINT_POINT_COLOR;//(y > 0.1 ? Colors.red : Colors.blue);
    if (_chartList[count].info != null) {
      if (_chartList[count].info is Color) {
        paint.color = _chartList[count].info as Color;
      }
    }
    canvas.drawCircle(Offset(pointX, pointY), _circleSize, paint);

    // 円線
    // ====> 選択状態の時にだけ描くと効果的。
    //
    // #### firstSelectedIndexがあれば、まず描く
    if (count == firstSelectedIndex &&
        firstSelectedIndex >= 0 && firstSelectedIndex <_chartList.length) {

      Paint line = new Paint()
        ..color = CHART_PAINT_FIRSTSELECTED_COLOR
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      canvas.drawCircle(
          Offset(pointX, pointY),
          _circleSize,
          line
      );
    }

    // #### チャートの選択が変わった場合に描く
    if (count == selectedIndex &&
        selectedIndex >= 0 && selectedIndex <_chartList.length) {

      Paint line = new Paint()
        ..color = CHART_PAINT_SELECTED_COLOR
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      canvas.drawCircle(
          Offset(pointX, pointY),
          _circleSize + 5,
          line
      );
    }

    return  Offset(pointX, pointY);
  }

  //#####################
  // 表示内容がまったく変わらないような場合は、falseによりpaintを１回だけに抑止できるが、
  // selectedIndexが変化して、その都度再描画をするので、trueを返すようにする。
  // ステートのbuildがよばれた場合には、一緒にpaintが行われる。
  //#####################
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}