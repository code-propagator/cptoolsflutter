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

class SyncScrollController {
  List<ScrollController> _registeredScrollControllers = new List<ScrollController>();

  ScrollController _scrollingController;
  bool _scrollingActive = false;

  SyncScrollController(List<ScrollController> controllers) {
    if (controllers != null) {
      controllers.forEach((controller) => registerScrollController(controller));
    }
  }

  void unregisterScrollController(ScrollController controller) {
    try {
      _registeredScrollControllers.remove(controller);
    } catch (e) {

    }
  }

  void registerScrollController(ScrollController controller) {
    _registeredScrollControllers.add(controller);
  }

  bool processNotification(ScrollNotification notification, ScrollController sender) {
    //print('processNotification');

    if (notification is ScrollStartNotification && !_scrollingActive) {
      _scrollingController = sender;
      _scrollingActive = true;
      return true;
    }

    if (identical(sender, _scrollingController) && _scrollingActive) {
      if (notification is ScrollEndNotification) {
        _scrollingController = null;
        _scrollingActive = false;
        return true;
      }

      if (notification is ScrollUpdateNotification) {
        _registeredScrollControllers.forEach((controller) => {if (!identical(_scrollingController, controller)) controller..jumpTo(_scrollingController.offset)});
        return true;
      }
    }

    return true;
  }
}

class SyncScrollPage extends StatefulWidget {
  SyncScrollPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SyncScrollPageState createState() => _SyncScrollPageState();
}

class _SyncScrollPageState extends State<SyncScrollPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  ScrollController _firstScroller = new ScrollController();
  ScrollController _secondScroller = new ScrollController();

  SyncScrollController _syncScroller;
  var listItem = [];

  @override
  void initState() {

    for (int k = 0; k < 100; k++) {
      listItem.add("Item " + k.toString());
    }

    _syncScroller = new SyncScrollController([_firstScroller , _secondScroller]);

    super.initState();
  }

  //#### SingleChildScrollView
  // https://stackoverflow.com/questions/54859779/scroll-multiple-scrollable-widgets-in-sync

  //#### ListView with onNotification
  // https://medium.com/@diegoveloper/flutter-lets-know-the-scrollcontroller-and-scrollnotification-652b2685a4ac


  @override
  Widget buildScroll(BuildContext context) {
    return Container(
        height: 80,
        child:
        Row(children:<Widget>[

          /*

          NotificationListener<ScrollNotification>(
              child: SingleChildScrollView(
                  controller: _firstScroller,
                  child:
                  Column(
                    children: <Widget>[
                    Text('00'),
                    Text('01'),
                    Text('02'),
                    Text('03'),
                    Text('04'),
                    Text('05'),
                    Text('06'),
                    Text('07'),
                    Text('08'),
                    Text('09'),
                    Text('10'),

                  ],)

              ),
              onNotification: (ScrollNotification scrollInfo) {
                _syncScroller.processNotification(scrollInfo, _firstScroller);
              }
          ),

          NotificationListener<ScrollNotification>(
              child: SingleChildScrollView(
                  controller: _secondScroller,
                  child: Column( children: <Widget>[
                    Text('b00'),
                    Text('b01'),
                    Text('b02'),
                    Text('b03'),
                    Text('b04'),
                    Text('b05'),
                    Text('b06'),
                    Text('b07'),
                    Text('b08'),
                    Text('b09'),
                    Text('b10'),
                  ],)
              ),
              onNotification: (ScrollNotification scrollInfo) {
                _syncScroller.processNotification(scrollInfo, _secondScroller);
              }
          ),

          */

        ] )


    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            */

            Container(
              height: 200,
              width: 100,
              child:
              NotificationListener<ScrollNotification>(
                onNotification: (notification) => _syncScroller.processNotification(notification, _firstScroller),
                child: ListView.builder(
                  controller: _firstScroller,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: Padding(
                        child: Text('$index', style: TextStyle(fontSize: 22.0),),
                        padding: EdgeInsets.all(20.0),),
                    );},
                  itemCount: listItem.length,
                ),
              ),),


            Container(
              height: 200,
              width: 100,
              child:
              NotificationListener<ScrollNotification>(
                onNotification: (notification) => _syncScroller.processNotification(notification, _secondScroller),
                child: ListView.builder(
                  controller: _secondScroller,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: Padding(
                        child: Text('$index', style: TextStyle(fontSize: 22.0),),
                        padding: EdgeInsets.all(20.0),),
                    );},
                  itemCount: listItem.length,
                ),
              ),),


            buildScroll(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}