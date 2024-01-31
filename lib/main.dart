import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucid_remote/connect_screen.dart';
import 'package:lucid_remote/providers/providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<SharedMediaFile>? _sharedFiles;

  @override
  void initState() {
    super.initState();

    StreamSubscription _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream()
            .listen((List<SharedMediaFile> value) async {
      if (value.isNotEmpty) {
        _sharedFiles = value;
        print("Shared:" + (_sharedFiles?.map((f) => f.path).join(",") ?? ""));
        Directory dir = await getApplicationDocumentsDirectory();
        String name = value.first.path.split('/').last;
        if (name.substring(name.length - 7, name.length).compareTo('.llprog') !=
            0) {
          await _showMyDialog(name.substring(name.length - 7, name.length));
          return;
        }
        print('so sieht der weg aus:... ${value.first.path}');
        String s = (await File(Platform.isIOS
                ? value.first.path.substring(5, value.first.path.length)
                : value.first.path)
            .readAsString());
        File f = new File('${dir.path}/$name');
        await f.writeAsString(s);
        await _showMyDialog("import was successful!");
      }
    });

    ReceiveSharingIntent.getInitialMedia()
        .then((List<SharedMediaFile> value) async {
      if (value.isNotEmpty) {
        _sharedFiles = value;
        print("Shared:" + (_sharedFiles?.map((f) => f.path).join(",") ?? ""));
        Directory dir = await getApplicationDocumentsDirectory();
        String name = value.first.path.split('/').last;
        if (name.substring(name.length - 7, name.length).compareTo('.llprog') !=
            0) {
          await _showMyDialog(name.substring(name.length - 7, name.length));
          return;
        }
        String s = (await File(value.first.path).readAsString());
        File f = new File('${dir.path}/$name');
        await f.writeAsString(s);
        await _showMyDialog("import was successful!");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BLEProvider(),
      child: const ConnectScreen(),
    );
  }

  Future<void> _showMyDialog(String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
