import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:testlib/testlib.dart';
import 'package:testapp/adjustCommandExecutor.dart';
import 'package:testapp/command.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  AdjustCommandExecutor _adjustCommandExecutor;
  String _clientSdkPlatform = '';
  String _clientSdk = '';

  String _baseUrl;
  String _gdprUrl;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    String _address = '192.168.8.224';
    if (Platform.isAndroid) {
      _clientSdkPlatform = 'android4.16.0';
      String _protocol = 'https';
      String _port = '8443';
      // String _address = '10.0.2.2';
      _baseUrl = _protocol + '://' + _address + ':' + _port;
      _gdprUrl = _protocol + '://' + _address + ':' + _port;
    } else {
      _clientSdkPlatform = 'ios4.16.0';
      String _protocol = 'http';
      String _port = '8080';
      // String _address = '127.0.0.1';
      _baseUrl = _protocol + '://' + _address + ':' + _port;
      _gdprUrl = _protocol + '://' + _address + ':' + _port;
    }

    // init test library
    Testlib.init(_baseUrl);

    _adjustCommandExecutor = new AdjustCommandExecutor(_baseUrl, _gdprUrl);
    _clientSdk = 'flutter4.16.0@$_clientSdkPlatform';

    Testlib.doNotExitAfterEnd();
    
    // Testlib.addTest('current/app-secret/Test_AppSecret_with_secret');
    // Testlib.addTestDirectory('current/event-tracking');
    // Testlib.addTestDirectory('current/init-malformed');
    // Testlib.addTestDirectory('current/attribution-callback');
    // Testlib.addTestDirectory('current/event-callbacks');
    // Testlib.addTestDirectory('current/session-callbacks');
    // Testlib.addTestDirectory('current/push-token');
    // Testlib.addTestDirectory('current/deeplink-deferred');
    Testlib.addTest('current/push-token/Test_PushToken_before_install');
    // Testlib.addTest('current/init-malformed/Test_Init_Malformed_wrong_environment');
    // Testlib.addTestDirectory('current/session-parameters');
    // Testlib.addTest('current/event-callbacks/Test_EventCallback_failure');
    // Testlib.addTest('current/deeplink/Test_Deeplink_beforeStart');

    Testlib.setExecuteCommandHalder((final dynamic callArgs) {
      Command command = new Command(callArgs);
      print('>>> EXECUTING METHOD: [${command.className}.${command.methodName}] <<<');
      _adjustCommandExecutor.executeCommand(command);
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Testlib.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Flutter test app'),
        ),
        body: new CustomScrollView(shrinkWrap: true, slivers: <Widget>[
          new SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: new SliverList(
                  delegate: new SliverChildListDelegate(<Widget>[
                new Text('Running on: $_platformVersion\n'),
                buildCupertinoButton(
                    'Start Test Session',
                    () => Testlib.startTestSession(_clientSdk))
              ])))
        ]),
      ),
    );
  }

  static Widget buildCupertinoButton(String text, Function action) {
    return new CupertinoButton(
      child: Text(text),
      color: CupertinoColors.activeBlue,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
      onPressed: action,
    );
  }
}