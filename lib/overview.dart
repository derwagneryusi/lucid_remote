import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucid_remote/picker.dart';
import 'package:lucid_remote/providers/providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'colors.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  final List<String> _listTextSelectedToggle = ["IGN", "AFTERB"];

  late TextEditingController tcon = TextEditingController();

  Future<String?> openDialog() => showDialog<String>(
      context: context,
      builder: ((context) => AlertDialog(
            title: const Text("File Name"),
            content: TextField(
              autofocus: true,
              controller: tcon,
              decoration:
                  const InputDecoration(hintText: "Enter Desired Name..."),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    String t = tcon.text;
                    tcon.clear();
                    Navigator.of(context).pop(t);
                  },
                  child: const Text("SUBMIT")),
            ],
          )));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: COLOR_ONE,
          child: SingleChildScrollView(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  color: COLOR_ONE,
                ),
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text(
                        "Channel 1 - Bank Selection",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              for (int i = 0; i < 2; i++)
                                Container(
                                  height: 15,
                                  width: MediaQuery.of(context).size.width / 5,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: SizedBox(
                              height: 15,
                              child: LinearProgressIndicator(
                                value: Provider.of<AllBanksData>(context,
                                        listen: true)
                                    .getInputOne(), // percent filled
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    COLOR_THREE_ALPHA),
                                backgroundColor: COLOR_TWO_ALPHA,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 25, 5, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (int i = 0; i < 5; i++)
                                const Icon(
                                  Icons.arrow_drop_up,
                                  color: Colors.white,
                                  size: 30,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "The small white arrows indicate the optimal signal position to guarantee proper function and no jitter caused switching between banks.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            "Channel 2",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          FlutterToggleTab(
                            width: 35,
                            height: 40,
                            borderRadius: 20,
                            selectedBackgroundColors: [COLOR_THREE],
                            unSelectedBackgroundColors: [COLOR_TWO],
                            selectedIndex:
                                Provider.of<AllBanksData>(context, listen: true)
                                    .getSecondChannelJob(),
                            selectedTextStyle: const TextStyle(
                                color: COLOR_ONE,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            unSelectedTextStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400),
                            labels: _listTextSelectedToggle,
                            selectedLabelIndex: (index) {
                              Provider.of<AllBanksData>(context, listen: false)
                                  .setSecondChannelJob(index);
                              Provider.of<AllBanksData>(context, listen: false)
                                  .singleWriteRequest();
                            },
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Visibility(
                          visible:
                              Provider.of<AllBanksData>(context, listen: false)
                                      .getSecondChannelJob() ==
                                  0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  height: 15,
                                  width: MediaQuery.of(context).size.width / 3,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: SizedBox(
                              height: 15,
                              child: LinearProgressIndicator(
                                value: Provider.of<AllBanksData>(context,
                                        listen: true)
                                    .getInputTwo(), // percent filled
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    COLOR_THREE_ALPHA),
                                backgroundColor: COLOR_TWO_ALPHA,
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              Provider.of<AllBanksData>(context, listen: false)
                                      .getSecondChannelJob() ==
                                  0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 25, 5, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (int i = 0; i < 3; i++)
                                  const Icon(
                                    Icons.arrow_drop_up,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: Provider.of<AllBanksData>(context, listen: true)
                              .getSecondChannelJob() ==
                          0,
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "IGNITION - to be able to ignite, you first need to arm the ignitor. Switch the ignitor channel from fully off (watch the bar above) to fully on and back off again within a very short time. Status LEDs will flash to indicate arming. To ignite channel 1 switch the signal to the middle (gray) area of the bar above. To ignite the second one, switch to the right darker area above.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: Provider.of<AllBanksData>(context, listen: true)
                              .getSecondChannelJob() ==
                          1,
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "The Afterburner Ring gets connected to channel 1 (ORANGE RING) and channel 2 (BLUE RING). When the afterburner is activated, the programmed sequence in B1-B5 for those two channels will be ignored!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: () async {
                                final dir =
                                    await getApplicationDocumentsDirectory();
                                final List<FileSystemEntity> entities =
                                    await dir.list().toList();
                                final List<File> flist =
                                    entities.whereType<File>().toList();
                                for (int i = 0; i < flist.length; i++) {
                                  if (!(flist[i].path.contains('llprog'))) {
                                    flist.removeAt(i);
                                  }
                                }
                                File? f = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      //return LightEditor();
                                      return MultiProvider(providers: [
                                        ChangeNotifierProvider<FilesData>(
                                            create: (_) => FilesData(flist)),
                                      ], child: myPicker());
                                    },
                                  ),
                                );
                                if (f != null) {
                                  String data = await f.readAsString();
                                  List<String> l = data.split(";");
                                  for (int i = 0; i < 8; i++) {
                                    Provider.of<ChannelNamesData>(context,
                                            listen: false)
                                        .setChannelName(i, l[i]);
                                  }
                                  data = l[8].substring(1, l[8].length - 1);
                                  l = data.split(", ");
                                  List<int> bts = [
                                    for (int i = 0; i < l.length; i++)
                                      int.parse(l[i]),
                                  ];
                                  Provider.of<AllBanksData>(context,
                                          listen: false)
                                      .setAllBytes(bts);
                                  Provider.of<AllBanksData>(context,
                                          listen: false)
                                      .controller
                                      .animateTo(1);
                                }
                                /*
                                final result =
                                    await FilePicker.platform.pickFiles();
                                if (result != null) {
                                  File f =
                                      File(result.files.first.path.toString());
                                  String data = await f.readAsString();
                                  List<String> l = data.split(";");
                                  for (int i = 0; i < 8; i++) {
                                    Provider.of<ChannelNamesData>(context,
                                            listen: false)
                                        .setChannelName(i, l[i]);
                                  }
                                  data = l[8].substring(1, l[8].length - 1);
                                  print(data.toString());
                                  l = data.split(", ");
                                  List<int> bts = [
                                    for (int i = 0; i < l.length; i++)
                                      int.parse(l[i]),
                                  ];
                                  Provider.of<AllBanksData>(context,
                                          listen: false)
                                      .setAllBytes(bts);
                                }*/
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35.0),
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.folder,
                                color: Colors.black,
                                size: 40,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: () async {
                                final s = await openDialog();
                                if (s == null || s.isEmpty) return;
                                final dir =
                                    await getApplicationDocumentsDirectory();
                                File f = File("${dir.path}/$s.llprog");
                                String data = "";
                                for (int i = 0; i < 8; i++) {
                                  data +=
                                      "${Provider.of<ChannelNamesData>(context, listen: false).getChannelName(i)};";
                                }
                                data += Provider.of<AllBanksData>(context,
                                        listen: false)
                                    .getAllBytes()
                                    .toString();
                                await f.writeAsString(data);
                                /*
                                final result = await FilePicker.platform
                                    .getDirectoryPath(
                                        dialogTitle: "Save Settings");
                                if (result != null) {
                                  File f = File("$result/$s.llprog");
                                  String data = "";
                                  for (int i = 0; i < 8; i++) {
                                    data +=
                                        "${Provider.of<ChannelNamesData>(context, listen: false).getChannelName(i)};";
                                  }
                                  data += Provider.of<AllBanksData>(context,
                                          listen: false)
                                      .getAllBytes()
                                      .toString();
                                  await f.writeAsString(data);
                                  print(data);
                                  
                                }
                                final s = await openDialog();
                                Directory appDocDir =
                                    await getApplicationDocumentsDirectory();
                                String appDocPath = appDocDir.path;
                                File f = File("$appDocPath/$s.llprog");
                                String data = "";
                                for (int i = 0; i < 8; i++) {
                                  data +=
                                      "${Provider.of<ChannelNamesData>(context, listen: false).getChannelName(i)};";
                                }
                                data += Provider.of<AllBanksData>(context,
                                        listen: false)
                                    .getAllBytes()
                                    .toString();
                                await f.writeAsString(data);
                                print(f.path.toString());
                                */
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35.0),
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.save,
                                color: Colors.black,
                                size: 40,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: () {
                                Provider.of<AllBanksData>(context,
                                        listen: false)
                                    .eeSaveRequest();
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35.0),
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.download,
                                color: Colors.black,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
