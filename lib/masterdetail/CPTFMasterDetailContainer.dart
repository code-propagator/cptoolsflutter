import 'dart:math';

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

// Base Project
// https://iirokrankka.com/2018/01/28/implementing-adaptive-master-detail-layouts/
//
// ===> Removed global items.
//      List<CPTFItem> is loaded with dataForMaster function using StreamController.
//      StetelessWidget is modified to StatefulWidget.

import 'package:flutter/material.dart';

import 'package:cptoolsflutter/masterdetail/CPTFMasterItem.dart';
import 'package:cptoolsflutter/masterdetail/CPTFDetail.dart';
import 'package:cptoolsflutter/masterdetail/CPTFMasterListing.dart';
import 'dart:async';

class CPTFMasterDetailContainer extends StatefulWidget {
  CPTFMasterDetailContainer({
    Key key,
    this.title,
    this.dataForMaster
  }) : super(key: key);

  final String title;
  final dataForMaster;

  @override
  _ItemMasterDetailContainerState createState() =>
      _ItemMasterDetailContainerState();
}

class _ItemMasterDetailContainerState extends State<CPTFMasterDetailContainer> {
  // スマホとタブレットでの切り替えは600がデフォルトだが、
  // スマホの場合でもスプリット表示にしたいので、小さい値にする。
  static const int kTabletBreakpoint = 260;// 600

  CPTFMasterItem _selectedItem;
  StreamController<CPTFMasterItem> streamController;// part of async package

  List<CPTFMasterItem> items = <CPTFMasterItem>[];

  loadAll(StreamController<CPTFMasterItem> sc) async {
    items.clear();

    if (widget.dataForMaster != null) {
      await widget.dataForMaster(sc);
    }

    setState(() {
      if (items.length > 0) {
        _selectedItem = items[0];
      } else {
        _selectedItem = null;
      }
    });
  }

  // Reference function for CPFTMasterListing
  List<CPTFMasterItem> _dataForMaster() {
    return items;
  }

  @override
  initState() {
    super.initState();

    //########################
    // スプリット表示の場合など詳細VIEWは子供のVIEWであるので、
    // initStateの終了タイミングが前後するとエラーが怒る。
    // ===> タイマーでラップしてから、リストデータの取得、更新を行う。

    Future.delayed( Duration(milliseconds: 500), () async {

      // リストの項目は、ストリームを使って、準備できたMyItemDataをプッシュしていく。
      // DBからのリスト取り出し ===> ストリームへプッシュ　===> itemへ追加

      streamController = StreamController.broadcast();
      streamController.stream.listen((p) => setState(() => items.add(p)));

      // 項目ロード開始
      loadAll(streamController);

      return true;
    });
  }

  Widget _buildMobileLayout() {
    return CPTFMasterListing(
      dataForMaster: _dataForMaster,
      itemSelectedCallback: (item) {
        // ### モバイル表示モードでは、
        // ### 選択された項目を引数にして、詳細画面をプッシュ表示する
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return CPTFDetail(
                isInTabletLayout: false,
                item: item,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Material(
            elevation: 4.0,
            child: CPTFMasterListing(
              dataForMaster: _dataForMaster,
              itemSelectedCallback: (item) {
                // ### タブレット表示モードでは
                // ### 詳細内容表示の更新（選択オブジェクトの変更）をする
                setState(() {
                  _selectedItem = item;
                });
              },
              selectedItem: _selectedItem,
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: CPTFDetail(
            isInTabletLayout: true,
            item: _selectedItem,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    var shortestSide = MediaQuery.of(context).size.shortestSide;

    if (shortestSide < kTabletBreakpoint) {
      content = _buildMobileLayout();
    } else {
      content = _buildTabletLayout();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title != null ? widget.title : ''),
      ),
      body: content,
    );
  }
}
