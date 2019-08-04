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

final String fAccount = "Account";
final String fId = 'Id';
final String fUserId = "UserId";
final String fPassword = "Password";
final String fSimplePassword = "SimplePassword";
final String fDocInfo = "DocInfo";

final String fdocId = "docId";
final String ffacilityId = "facilityId";
final String ffacilityPersonalId = "facilityPersonalId";
final String fregionalId = "regionalId";
final String fcontentModuleType = "contentModuleType";
final String fmmlVersion = "mmlVersion";
final String fdocInfo = "docInfo";
final String fconfirmDateJST = "confirmDateJST";
final String fconfirmDateUTC = "confirmDateUTC";
final String ftitle = "title";
final String ffacilityName = "facilityName";
final String faccountUserId = "accountUserId";

final String fBookmark = "Bookmark";
final String fuserId = "userId";
final String fitemLabel = "itemLabel";
final String fcontents = "contents";

final String fDocument = "Document";
final String fdocument = "document";
final String fparsed = "parsed";

final String fKeyValueString = "KeyValueString";
final String fKey = 'Key';
final String fValue = 'Value';

final String fLaboTest = "LaboTest";
final String fspCode = "spCode";
final String fspName = "spName";
final String fitemCode = "itemCode";
final String fitemName = "itemName";
final String fsampleDatetimeJST = "sampleDatetimeJST";
final String fitemValue = "itemValue";
final String fitemUnit = "itemUnit";
final String fitemOut = "itemOut";
final String fdocInfoIntId = "docInfoIntId";

class KeyValueString {
  String Key;
  String Value;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      fKey: Key,
      fValue: Value
    };

    return map;
  }

  KeyValueString();

  KeyValueString.fromMap(Map map) {
    Key = map[fKey] as String;
    Value = map[fValue] as String;
  }
}

class Account {
  String UserId;
  String Password;
  String SimplePassword;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      fUserId: UserId,
      fPassword: Password,
      fSimplePassword: SimplePassword
    };

    return map;
  }

  Account();

  Account.fromMap(Map map) {
    UserId = map[fUserId] as String;
    Password = map[fPassword] as String;
    SimplePassword = map[fSimplePassword] as String;
  }
}

class Bookmark {
  int Id;
  String userId;
  String itemLabel;
  String contents;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      fuserId: userId,
      fitemLabel: itemLabel,
      fcontents: contents
    };
    if (Id != null) {
      map[fId] = Id;
    }

    return map;
  }

  Bookmark();

  Bookmark.fromMap(Map map) {
    Id = (map[fId] == null ? null : map[Id] as int);

    userId = map[fuserId] as String;
    itemLabel = map[fitemLabel] as String;
    contents = map[fcontents] as String;
  }
}

class DocInfo {
  int Id;

  String docId;
  String facilityId;
  String facilityPersonalId;

  String regionalId;
  String contentModuleType;
  String mmlVersion;

  String docInfo;
  String confirmDateJST;
  String confirmDateUTC;

  String title;
  String facilityName;
  String accountUserId;

  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {
      fdocId: docId,
      ffacilityId: facilityId,
      ffacilityPersonalId: facilityPersonalId,

      fregionalId: regionalId,
      fcontentModuleType: contentModuleType,
      fmmlVersion: mmlVersion,

      fdocInfo: docInfo,
      fconfirmDateJST: confirmDateJST,
      fconfirmDateUTC: confirmDateUTC,

      ftitle: title,
      ffacilityName: facilityName,
      faccountUserId: accountUserId
    };
    if (Id != null) {
      map[fId] = Id;
    }

    return map;
  }

  DocInfo();

  DocInfo.fromMap(Map map) {
    Id = (map[fId] == null ? null : map[fId] as int);

    docId = map[fdocId] as String;
    facilityId = map[ffacilityId] as String;
    facilityPersonalId = map[ffacilityPersonalId] as String;

    regionalId = map[fregionalId] as String;
    contentModuleType = map[fcontentModuleType] as String;
    mmlVersion = map[fmmlVersion] as String;

    docInfo = map[fdocInfo] as String;
    confirmDateJST = map[fconfirmDateJST] as String;
    confirmDateUTC = map[fconfirmDateUTC] as String;

    title = map[ftitle] as String;
    facilityName = map[ffacilityName] as String;
    accountUserId = map[faccountUserId] as String;
  }
}

class Document {
  int Id;

  String docId;
  String facilityId;
  String facilityPersonalId;

  String regionalId;
  String contentModuleType;
  String mmlVersion;

  String document;
  String parsed;
  String accountUserId;

  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {
      fdocId: docId,
      ffacilityId: facilityId,
      ffacilityPersonalId: facilityPersonalId,

      fregionalId: regionalId,
      fcontentModuleType: contentModuleType,
      fmmlVersion: mmlVersion,

      fdocument: document,
      fparsed: parsed,
      faccountUserId: accountUserId
    };
    if (Id != null) {
      map[fId] = Id;
    }

    return map;
  }

  Document();

  Document.fromMap(Map map) {
    Id = (map[fId] == null ? null : map[fId] as int);

    docId = map[fdocId] as String;
    facilityId = map[ffacilityId] as String;
    facilityPersonalId = map[ffacilityPersonalId] as String;

    regionalId = map[fregionalId] as String;
    contentModuleType = map[fcontentModuleType] as String;
    mmlVersion = map[fmmlVersion] as String;

    document = map[fdocument] as String;
    parsed = map[fparsed] as String;
    accountUserId = map[faccountUserId] as String;
  }
}

class LaboTest {
  int Id;

  String userId;
  String facilityId;

  String spCode;
  String spName;
  String itemCode;
  String itemName;

  String sampleDatetimeJST;
  String itemValue;
  String itemUnit;
  String itemOut;

  int docInfoIntId;

  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {
      fuserId: userId,
      ffacilityId: facilityId,

      fspCode: spCode,
      fspName: spName,
      fitemCode: itemCode,
      fitemName: itemName,

      fsampleDatetimeJST: sampleDatetimeJST,
      fitemValue: itemValue,
      fitemUnit: itemUnit,
      fitemOut: itemOut,

      fdocInfoIntId: docInfoIntId
    };
    if (Id != null) {
      map[fId] = Id;
    }

    return map;
  }

  LaboTest();

  LaboTest.fromMap(Map map) {
    Id = (map[fId] == null ? null : map[Id] as int);

    userId = map[fuserId] as String;
    facilityId = map[ffacilityId] as String;

    spCode = map[fspCode] as String;
    spName = map[fspName] as String;
    itemCode = map[fitemCode] as String;
    itemName = map[fitemName] as String;

    sampleDatetimeJST = map[fsampleDatetimeJST] as String;
    itemValue = map[fitemValue] as String;
    itemUnit = map[fitemUnit] as String;
    itemOut = map[fitemOut] as String;

    docInfoIntId = map[fdocInfoIntId] as int;
  }
}
