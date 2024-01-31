import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucid_remote/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'colors.dart';

class myPicker extends StatelessWidget {
  const myPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_TWO,
      appBar: AppBar(
        backgroundColor: COLOR_ONE,
        title: Image.asset(
          'assets/lucid_white.png',
          height: 20,
        ),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          for (int i = 0;
              i <
                  Provider.of<FilesData>(context, listen: true)
                      .getFiles()
                      .length;
              i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Dismissible(
                  onDismissed: (direction) async {
                    File f = Provider.of<FilesData>(context, listen: false)
                        .getFiles()
                        .elementAt(i);
                    if (direction == DismissDirection.endToStart) {
                      f.delete();
                    } else {
                      final files = <XFile>[XFile(f.path)];
                      await Share.shareXFiles(files);
                    }
                  },
                  key: Key(Provider.of<FilesData>(context, listen: true)
                      .getFiles()
                      .elementAt(i)
                      .path),
                  background: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 100,
                        color: Colors.green,
                        child: Icon(Icons.share, color: Colors.white),
                      ),
                      Container(
                        width: 100,
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ],
                  ),
                  child: Container(
                    color: COLOR_ONE,
                    child: ListTile(
                      textColor: Colors.white,
                      onTap: () {
                        File f = Provider.of<FilesData>(context, listen: false)
                            .getFiles()
                            .elementAt(i);
                        Navigator.pop(context, f);
                      },
                      title: Text(Provider.of<FilesData>(context, listen: true)
                          .getFiles()
                          .elementAt(i)
                          .path
                          .toString()
                          .split('/')
                          .last
                          .split('.')
                          .first),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
