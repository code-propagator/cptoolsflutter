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

class CPTFDetail extends StatefulWidget {
  CPTFDetail({
    Key key,
    @required this.isInTabletLayout,
    @required this.item,
  }) : super(key: key);

  final bool isInTabletLayout;
  final CPTFMasterItem item;

  @override
  _CPTFDetailState createState() => _CPTFDetailState();
}

class _CPTFDetailState extends State<CPTFDetail> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.item?.title ?? 'No item selected!',
          style: textTheme.headline,
        ),
        Text(
          widget.item?.subtitle ?? 'Please select one on the left.',
          style: textTheme.subhead,
        ),
      ],
    );

    if (widget.isInTabletLayout) {
      return Center(child: content);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
      ),
      body: Center(child: content),
    );
  }
}
