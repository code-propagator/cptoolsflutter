import 'package:flutter/material.dart';

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

// http://www.coderzheaven.com/2019/01/24/flutter-tutorials-datatable-android-ios/

class SelectionItem {
  String title;
  String sub;
  var info;

  SelectionItem({this.title, this.sub});

  SelectionItem setInfo(info) {
    this.info = info;
    return this;
  }

  /*
  static List<SelectionItem> getItems() {
    return <SelectionItem>[
      SelectionItem(title: "Aaryan", sub: "Shah"),
      SelectionItem(title: "Ben", sub: "John"),
      SelectionItem(title: "Carrie", sub: "Brown"),
      SelectionItem(title: "Deep", sub: "Sen"),
      SelectionItem(title: "Emily", sub: "Jane"),
      SelectionItem(title: "Aaryan", sub: "Shah"),
    ];
  }
  */
}

class CPTFItemSelection extends StatefulWidget {
  CPTFItemSelection({Key key,
    this.title, this.srcMaps,
    this.titleKey, this.subKey,
    this.titleLabel, this.subLabel,
    this.dataForItemSelection
  }) : super(key: key);

  final String title;

  final List<Map> srcMaps;//元データ

  final String titleKey;// 検索フィールに使うキー名
  final String subKey;// サブ表示に使うキー名

  final String titleLabel;// 検索用カラム・ヘッダ
  final String subLabel;// サブカラム・ヘッダ

  final dataForItemSelection;

  @override
  _CPTFItemSelectionState createState() => _CPTFItemSelectionState();
}

class _CPTFItemSelectionState extends State<CPTFItemSelection> {

  List<SelectionItem> allItems = List<SelectionItem>(); // 最初に用意した全レコード

  List<SelectionItem> items = List<SelectionItem>();// テーブルに表示する（フィルターされた項目）

  List<SelectionItem> selectedItems = List<SelectionItem>();// 選択チェックされている項目

  String _titleLabel = '';
  String _subLabel = '';

  bool sort;

  _clearTextField() {
    // テキストフィールドのGUI上から文字をクリアする
    editingController.clear();

    // 他のGUI部品を再描画させる
    setState(() {
      _filterWord = null;
    });

    // GUIフィルターも実行しておく
    filterSearchResults(_filterWord);
  }

  @override
  void initState() {
    // init text filter
    editingController = TextEditingController(text: _filterWord == null ? '' : _filterWord);


    _titleLabel = widget.titleLabel == null ? 'TITLE' : widget.titleLabel;
    _subLabel = widget.subLabel == null ? '' : widget.subLabel;

    // 外部からデータがさればそれを投入する。
    allItems.clear();
    if (widget.srcMaps == null) {
      // なければダミー（デバッグ）
      if (widget.dataForItemSelection != null) {
        allItems =
            widget.dataForItemSelection(); //SelectionItem.getItems();// データをロード
      }
    } else {

      for (Map map in widget.srcMaps) {

        String title = map[widget.titleKey] != null ? map[widget.titleKey].toString() : '';

        String sub = '';
        if (widget.subKey != null) {
          sub = map[widget.subKey] != null ? map[widget.subKey]
              .toString() : '';
        }

        SelectionItem selectionItem = SelectionItem(title: title, sub: sub).setInfo(map);

        allItems.add(selectionItem);
      }
    }

    items.addAll(allItems);

    // 初期ソートを実施
    sort = true;
    // items.sort((a, b) => a.title.compareTo(b.title));
    onSortColum(0, sort);

    // 選択項目をクリア
    selectedItems.clear();

    super.initState();
  }


  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        items.sort((a, b) => a.title.compareTo(b.title));
      } else {
        items.sort((a, b) => b.title.compareTo(a.title));
      }
    }
  }

  onSelectedRow(bool selected, SelectionItem item) async {
    setState(() {
      if (selected) {
        selectedItems.add(item);
      } else {
        selectedItems.remove(item);
      }
    });
  }

  deleteSelected() async {
    setState(() {
      if (selectedItems.isNotEmpty) {
        List<SelectionItem> temp = [];
        temp.addAll(selectedItems);
        for (SelectionItem rec in temp) {
          items.remove(rec);
          selectedItems.remove(rec);
        }
      }
    });
  }

  SingleChildScrollView dataBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        sortAscending: sort,
        sortColumnIndex: 0,
        columns: [
          DataColumn(
              label: Text(_titleLabel),
              numeric: false,
              // tooltip: "This is First Name",
              onSort: (columnIndex, ascending) {
                setState(() {
                  sort = !sort;
                });
                onSortColum(columnIndex, ascending);
              }),
          DataColumn(
            label: Text(_subLabel),
            numeric: false,
            // tooltip: "This is Last Name",
          ),
        ],
        rows: items.map( (rec) => DataRow(
            selected: selectedItems.contains(rec),
            onSelectChanged: (b) {
              print("Onselect");
              onSelectedRow(b, rec);
            },
            cells: [
              DataCell(
                Text(rec.title),
                /*
                  onTap: () {
                    // #### DatqRowのonSelecteChangedがあるので、
                    // #### ここにonTapを定義してしまうと、イベントを奪ってしまう。
                    print('Selected ${rec.title}');
                  },
                 */
              ),
              DataCell(
                Text(rec.sub),
              ),
            ]),
        ).toList(),
      ),
    );
  }


  //----------------------------------------------------------------------------
  // https://blog.usejournal.com/flutter-search-in-listview-1ffa40956685

  String _filterWord = '';

  // https://stackoverflow.com/questions/43214271/how-do-i-supply-an-initial-value-to-a-text-field
  // 初期テキストは、
  // initStateでセットするコントローラの初期値として同じテキストをセットすると良い。
  //　===>
  // TextFormFieldのinitialValue属性にセットすると、初回nullでエラーとなってしまうので使わない。

  TextEditingController editingController = TextEditingController();

  // final duplicateItems = List<String>.generate(10000, (i) => "Item $i");
  // var items = List<String>();

  void dispose() {
    if (editingController != null) {
      editingController.dispose();
    }

    super.dispose();
  }

  void filterSearchResults(String query) {

    // 全件を対象とする。
    List<SelectionItem> tmpSearchList = List<SelectionItem>();
    tmpSearchList.addAll(allItems);

    if (query != null && query.isNotEmpty && query != '') {
      // フィルター
      List<SelectionItem> tmpListData = List<SelectionItem>();

      tmpSearchList.forEach((item) {
        // タイトル文字列にqueryが含まれるか（部分一致）
        if(item.title.contains(query)) {
          tmpListData.add(item);
        }
      });

      // フィルター結果をitems（表示用リスト）に入れる（上書き）
      // ソートを実行する
      setState(() {
        items.clear();
        items.addAll(tmpListData);
        onSortColum(0, sort);
      });

    } else {

      // 全件を表示させる（フィルターなし）
      // ソートを実行する
      setState(() {
        items.clear();
        items.addAll(allItems);
        onSortColum(0, sort);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title != null ? widget.title : ''),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[

          Padding(padding: EdgeInsets.all(10.0), child:
          TextField(
            onChanged: (value) {
              print('TextField onChange $value');
              setState(() {
                _filterWord = value;
              });
              filterSearchResults(value);
            },
            controller: editingController,
            decoration: InputDecoration(
                labelText: "Filter",
                hintText: "Filter",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0))),

                suffix: SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: IconButton(
                    padding: EdgeInsets.all(0.0),
                    iconSize: 18.0,
                    icon: Icon(Icons.clear, size: 18.0),
                    onPressed: _clearTextField, //### インライン実装不可。関数で切り出し。
                  )
                ),

            ),
          ),),

          /*
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20.0),
                child: OutlineButton(
                  child: Text('DELETE SELECTED'),
                  onPressed: selectedItems.isEmpty
                      ? null
                      : () {
                    deleteSelected();
                  },
                ),
              ),

            ],
          ),
          */


          // テーブル本体
          Expanded(
            child: dataBody(),
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              Padding(
                padding: EdgeInsets.all(20.0),
                child: OutlineButton(
                  child: Text('結果表示 ${selectedItems.length}'),
                  onPressed: () {

                    for (SelectionItem item in selectedItems) {
                      print(item.toString());
                    }
                    /*
                    if (false) {
                      // 選択を全て解除する
                      setState(() {
                        selectedItems.clear();
                      });
                    } else {
                      // 全て選択する
                      setState(() {
                        selectedItems.clear();
                        selectedItems.addAll(items);
                      });
                    }
                    */

                  },
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }
}