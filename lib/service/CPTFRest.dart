import 'dart:async';

import 'package:path/path.dart' as p;

import 'package:http/http.dart' as http; // POST
import 'package:dio/dio.dart' as d; // GET
import 'dart:io';

import 'dart:convert' show json;
import 'dart:convert' show utf8;

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

// dio
// https://github.com/flutterchina/dio

// json
// https://stackoverflow.com/questions/52763642/flutter-doesnt-want-to-import-json

// form
// https://tech.mokelab.com/CrossPlatform/Flutter/http/post.html

// Verify
// https://stackoverflow.com/questions/54285172/how-to-solve-flutter-certificate-verify-failed-error-while-performing-a-post-req/54359013

class CPTFRest {

  Future <String> wait(int s){
    return Future.delayed( Duration(seconds: s), () async {
      return DateTime.now().toString();
    });
  }

  Future<String> postFormDefault(String reqUrl, body) async {
    // return await futureTest();

    try {
      http.Client client = http.Client();
      http.Response response = await client.post(reqUrl, body: body);

      if (response.statusCode == 200) {
        return await (response.body.toString());
      } else {
        return await ('ERROR');
      }

    } catch (e) {
      print(e);

      return await '';
    }
  }

  // Verify
  // https://stackoverflow.com/questions/54285172/how-to-solve-flutter-certificate-verify-failed-error-while-performing-a-post-req/54359013

  // Post Form
  Future<String> postFormVerify(String reqUrl, String form) async {
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      /*Map map = {
        "uid": userId,
        "password": password
      };*/

      print('reqUrl');
      print(reqUrl);

      print('form');
      print(form);

      HttpClientRequest request = await client.postUrl(Uri.parse(reqUrl));

      // request.headers.contentType = ContentType("application", "json", charset: "utf-8");
      request.headers.contentType = ContentType("application", "x-www-form-urlencoded", charset: "utf-8");

      // request.add(utf8.encode(json.encode(map)));

      // String s = 'uid=' + Uri.encodeQueryComponent(userId) + '&' + 'password=' + Uri.encodeQueryComponent(password);

      request.write(form);

      HttpClientResponse resp = await request.close();
      print('resp');
      // print(resp);// Instance of '_HttpClientResponse'
      if (resp != null) {
        print(resp.statusCode);
        print(resp.headers);

        // 500 Internal Server Error
      }

      if (resp.statusCode == 200) {
        String reply = await resp.transform(utf8.decoder).join();
        return await (reply);
      } else {

        return await ('ERROR');
      }
    } catch (e) {
      print(e);

      return await '';
    }
  }

  // Post JSON
  Future<String> postJSONVerify(String reqUrl, Map map) async {
    try {
      if (reqUrl == null || map == null) {
        return '';
      }

      print(postJSONVerify);
      print(reqUrl);
      print(map.toString());

      HttpClient client = HttpClient();
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      /*Map map = {
        "uid": userId,
        "password": password
      };*/

      print('reqUrl');
      print(reqUrl);

      HttpClientRequest request = await client.postUrl(Uri.parse(reqUrl));

      request.headers.contentType = ContentType("application", "json", charset: "utf-8");
      // request.headers.contentType = ContentType("application", "x-www-form-urlencoded", charset: "utf-8");

      // #### JSON文字列を更にUTF-8にエンコードして投入する
      request.add(utf8.encode(json.encode(map)));

      // String s = 'uid=' + Uri.encodeQueryComponent(userId) + '&' + 'password=' + Uri.encodeQueryComponent(password);
      // log(s);
      // request.write(jsonString);

      HttpClientResponse resp = await request.close();
      print('resp');
      // print(resp);// Instance of '_HttpClientResponse'
      if (resp != null) {
        print(resp.statusCode);
        print(resp.headers);

        /*
        内部サーバエラーの場合(500)なども発生する。
         */
      }

      if (resp.statusCode == 200) {
        String reply = await resp.transform(utf8.decoder).join();
        return await (reply);
      } else {

        return 'ERROR';
      }
    } catch (e) {
      print(e);

      return '';
    }
  }

  Future<String> getTest() async {
    // dio
    // https://github.com/flutterchina/dio
    try {
      var response = await d.Dio().get("http://penelope.tv/");
      return await (response.data.toString());
    } catch (e) {
      print(e);
      return await '';
    }
  }
}