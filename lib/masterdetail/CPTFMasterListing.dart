import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:cptoolsflutter/masterdetail/CPTFMasterItem.dart';

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

class CPTFMasterListing extends StatefulWidget {
  CPTFMasterListing({
    Key key,
    @required this.itemSelectedCallback,
    this.selectedItem,
    this.dataForMaster,
  }) : super(key: key);

  final ValueChanged<CPTFMasterItem> itemSelectedCallback;
  final CPTFMasterItem selectedItem;

  final dataForMaster;

  @override
  _CPTFMasterListingState createState() =>
      _CPTFMasterListingState();
}

class _CPTFMasterListingState extends State<CPTFMasterListing> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CPTFMasterItem> items = null;
    try {
      if (widget.dataForMaster != null) {
        items = widget.dataForMaster() as List<CPTFMasterItem>;
      } else {
        items = List<CPTFMasterItem>();
      }
    } catch (e) {
      items = List<CPTFMasterItem>();
    }

    return ListView(
      children: items.map((item) {
        
        String title = item.title != null ? item.title : '';
        String sub = item.subtitle != null ? item.subtitle : '';

        return ListTile(
          title: Text(title, style: TextStyle(fontSize: 12.0)),
          subtitle: Text(sub, style: TextStyle(fontSize: 10.0)),
          onTap: () => widget.itemSelectedCallback(item),
          selected: widget.selectedItem == item,
        );
      }).toList(),
    );
  }
}
