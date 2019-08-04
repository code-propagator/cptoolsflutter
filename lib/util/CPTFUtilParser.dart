import 'dart:async';

import 'dart:convert' show json;
import 'dart:convert' show utf8;

import "package:intl/intl.dart";
import 'package:intl/date_symbol_data_local.dart';

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


class CPTFUtilParser {
  var logger = null;// log関数を持つオブジェクト
  var logfunc = null;// log関数そのもの

  // GUI表示用のlogメソッドを持っている想定。
  // ---> dynamicで扱うことでパーサー自体は簡単にしておく。
  void log(String s) {

    // logfuncかloggerがあれば、
    // それぞれlogを出力する。

    if (logfunc != null) {
      try {
        logfunc(s);
      } catch (e) {

      }
    }
    else if (logger != null) {
      try {
        logger.log(s);
      } catch (e) {

      }
    }
  }

  Map<String, String> dictKeypathValue = null;
  Map<String, String> dictKeyapthIndentValue = null;

  void clearDict() async {
    if (dictKeypathValue == null) {
      dictKeypathValue = Map<String, String>();
    } else {
      dictKeypathValue.clear();
    }

    if (dictKeyapthIndentValue == null) {
      dictKeyapthIndentValue = Map<String, String>();
    } else {
      dictKeyapthIndentValue.clear();
    }

    int a = await 1;

    return;
  }

  String INDENT_STR = '  ';
  String indent(int level) {
    String s = '';
    for (int k = 0; k < level; k++) {
      s += INDENT_STR;
    }
    return s;
  }

  void printDict(Map<String, String> dict, bool valueOnly) {
    if (valueOnly ){
      for (String key in dict.keys) {
        log(dict[key]);
      }
    } else {
      for (String key in dict.keys) {
        log(key + ':' + dict[key]);
      }
    }
  }

  Future<String> parse(String jsonStr) async {
    // return await futureTest();

    if (jsonStr == null) {
      log('');
      return await '';
    }

    // print(jsonStr);

    var obj = null;
    try {
      obj = json.decode(jsonStr);
    } catch (e) {
      log('デコード不可');
      return await jsonStr;
    }

    if (obj == null) {
      log('デコード不可');
      return await jsonStr;
    }

    return await parseJson(obj);
  }

  Future<String> parseJson(var json) async {
    // return await futureTest();

    log('内容確認');

    int level = 0;
    String keypath = '';
    traverse(level, keypath, json);

    return await '';
  }

  void traverse(int level, String keypath, obj) {
    level++;
    // print('traverse $level ' + obj.toString());
    if (obj == null) {
      // log('$level ### NULL');
      return;
    }

    // JSON ---> Map
    Map<String, dynamic> map = ObjectToMap(obj);

    // 下部構造をもつMapが見つかった。
    if (map != null) {
      var value = null;
      String currentKey = '';
      for (String key in map.keys) {
        value = map[key];

        currentKey = keypath == '' ? key : (keypath+'.'+key);

        // log('$level: ' + currentKey + ' --- ' + (value == null ? '' : value.toString()));

        if (value is List) {
          // log('$level: ' + currentKey + ' --- ### LIST ### ' + (value == null ? '' : value.toString()));
        } else {
          Map<String, dynamic> tmp = ObjectToMap(value);
          if (tmp != null) {
            // log('### VALUE IS MAP');

          } else {
            // log('### VALUE IS NOT MAP');

            // log('$level: ' + currentKey + ' --- ' + (value == null ? '' : value.toString()));

            dictKeypathValue[currentKey] = (value == null ? '' : value.toString());
            dictKeyapthIndentValue[currentKey] =  indent(level) + (value == null ? '' : value.toString());

            // リストが格納される所に何もない場合もここにくる。
            // flutter: 2: patient.doctorFacilityPersonalID_Array ---
          }
        }

        if (value == null) {
          // 下部構造なし
          continue;
        }

        traverse(level, currentKey, value);
      }
    } else {
      // log('$level NOT MAP ' + (obj == null ? '' : obj.toString()));
      // 配列である可能性があるのでチェックする。
      if (obj is List) {
        // log('===> NOT MAP BUT LIST');
        List list = null;

        try {
          list = obj as List;
        } catch (e) {

        }
        if (list == null) {
          return;
        }

        // log('$level LIST ' + (obj == null ? '' : obj.toString()));
        int count = 0;
        String currentKey = '';
        for (var elem in list) {
          currentKey = keypath == '' ? '[$count]' : (keypath+'[$count]');

          traverse(level, currentKey, elem);
          count++;
        }
      }
      else {
        // log('$level NOT MAP NOT LIST BUT MAYBE STRING VALUE ' + keypath + ' == ' + (obj == null ? '' : obj.toString()));

        dictKeypathValue[keypath] = (obj == null ? '' : obj.toString());
        dictKeyapthIndentValue[keypath] =  indent(level) + (obj == null ? '' : obj.toString());

        return;
      }
    }
  }

  Map<String, dynamic> ObjectToMap(obj) {
    Map<String, dynamic> map = null;
    try {
      map = obj as Map<String, dynamic>;
      return map;
    } catch (e) {
      return null;
    }
  }

  String readAsSafeString(obj, String key) {
    if (obj == null) return '';

    try {
      return obj[key] == null ? '' : obj[key].toString();
    } catch (e) {
      return '';
    }
  }

  String value(String keypath) {
    return readAsSafeString(dictKeypathValue, keypath);
  }

  bool isStartEnd(String keypath, String start, String end) {
    if (keypath.startsWith(start) && keypath.endsWith(end)) {
      return true;
    } else {
      return false;
    }
  }

  String valueStartEnd(String keypath, String start, String end) {
    if (keypath.startsWith(start) && keypath.endsWith(end)) {
      return value(keypath);
    } else {
      return '';
    }
  }

  bool isStartMidEnd(String keypath, String start, String mid, String end) {
    if (keypath.startsWith(start) && keypath.contains(mid) && keypath.endsWith(end)) {
      return true;
    } else {
      return false;
    }
  }

  String valueStartMidEnd(String keypath, String start, String mid, String end) {
    if (keypath.startsWith(start) && keypath.contains(mid) && keypath.endsWith(end)) {
      return value(keypath);
    } else {
      return '';
    }
  }

  String valueAsUTC(String keypath) {
    try {
      String v = value(keypath);
      if (v != null && v.length > 0) {
        return epochToUTCString(v);
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  String valueAsJST(String keypath) {
    try {
      String v = value(keypath);
      if (v != null && v.length > 0) {
        return epochToJSTString(v);
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  String epochToJSTString(String epochString, {bool showMillis = false}) {
    // confirmDate:1181833200000
    // https://www.epochconverter.com/

    // Assuming that this timestamp is in milliseconds:
    // GMT: 2007年6月14日 Thursday 15:00:00
    // Your time zone: 2007年6月15日 金曜日 00:00:00 GMT+09:00
    // Relative: 12 years ago

    // String epochString = '1181833200000';
    // ===> JST文字列への変換が必要。
    // log(epochString);

    initializeDateFormatting('ja_JP');
    var localDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(epochString), isUtc: true).toLocal();
    // var utcDate = localDate.toUtc();
    // log('#### LOCAL: $localDate');
    // log('#### UTC: $utcDate');

    // flutter: 1181833200000
    // flutter: #### LOCAL: 2007-06-15 00:00:00.000
    // flutter: #### UTC: 2007-06-14 15:00:00.000Z

    String res = localDate.toString();

    if (showMillis == true) {
      return res;
    } else {
      // ミリ秒の'.ZZZ'をカットする場合
      return dropMillis(res);
    }
  }

  // 文字列の末尾４文字をカットする。
  // ミリ秒の'.ZZZ'をカットする場合に使用可能。
  String dropMillis(String s) {
    if (s == null) return null;
    if (s.length <= 4) return s;

    try {
      return s.substring(0, s.length - 4);
    } catch (e) {
      return s;
    }
  }

  String epochToUTCString(String epochString) {
    // confirmDate:1181833200000
    // https://www.epochconverter.com/

    // Assuming that this timestamp is in milliseconds:
    // GMT: 2007年6月14日 Thursday 15:00:00
    // Your time zone: 2007年6月15日 金曜日 00:00:00 GMT+09:00
    // Relative: 12 years ago

    // String epochString = '1181833200000';
    // ===> JST文字列への変換が必要。
    // log(epochString);

    initializeDateFormatting('ja_JP');
    var localDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(epochString), isUtc: true).toLocal();
    var utcDate = localDate.toUtc();
    // log('#### LOCAL: $localDate');
    // log('#### UTC: $utcDate');

    // flutter: 1181833200000
    // flutter: #### LOCAL: 2007-06-15 00:00:00.000
    // flutter: #### UTC: 2007-06-14 15:00:00.000Z

    return utcDate.toString();
  }
}
