import 'package:flutter/material.dart';
import 'package:lucid_remote/providers/providers.dart';
import 'package:provider/provider.dart';
import 'colors.dart';
import 'sequence_editor.dart';

class SingleBank extends StatefulWidget {
  const SingleBank({super.key});

  @override
  State<SingleBank> createState() => _SingleBankState();
}

class _SingleBankState extends State<SingleBank> {
  final List<bool> _isOpen = [
    for (int i = 0; i < 8; i++) false,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ListView(
              physics: Provider.of<IsScrollAllowed>(context).getScrollAllowed()
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ExpansionPanelList(
                    animationDuration: const Duration(milliseconds: 500),
                    dividerColor: COLOR_TWO,
                    expansionCallback: (i, isOpen) {
                      for (int j = 0; j < 8; j++) {
                        if (i != j && _isOpen[j]) {
                          setState(() {
                            _isOpen[j] = false;
                          });
                        } else if (i == j) {
                          setState(() {
                            _isOpen[j] = !_isOpen[j];
                          });
                        }
                      }
                    },
                    children: [
                      for (int i = 0; i < 8; i++)
                        ExpansionPanel(
                          canTapOnHeader: true,
                          backgroundColor: COLOR_ONE,
                          isExpanded: _isOpen[i],
                          headerBuilder: (context, isOpen) {
                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Positioned(
                                  child: Text(
                                    "     ${Provider.of<ChannelNamesData>(context).getChannelName(i)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                isOpen
                                    ? Positioned(
                                        right: 10,
                                        child: IconButton(
                                          icon: const Icon(Icons.edit),
                                          color: COLOR_THREE,
                                          onPressed: () async {
                                            final s = await openDialog();
                                            if (s != null) {
                                              setState(() {
                                                Provider.of<ChannelNamesData>(
                                                        context,
                                                        listen: false)
                                                    .setChannelName(i, "$s ");
                                              });
                                            }
                                          },
                                        ),
                                      )
                                    : const Text(" "),
                              ],
                            );
                          },
                          body: Listener(
                            onPointerDown: (details) {
                              Provider.of<IsScrollAllowed>(context,
                                      listen: false)
                                  .setScrollAllowed(false);
                            },
                            onPointerUp: (details) {
                              setState(() {
                                Provider.of<IsScrollAllowed>(context,
                                        listen: false)
                                    .setScrollAllowed(true);
                              });
                            },
                            child: ChangeNotifierProvider(
                              create: (context) =>
                                  Provider.of<BankData>(context, listen: false)
                                      .getSequence(i),
                              child: const SequenceEditor(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Flexible(
          flex: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: COLOR_ONE,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Copy/Paste Bank",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 60,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<CopyPasteProvider>(context,
                                      listen: false)
                                  .setData(Provider.of<BankData>(context,
                                          listen: false)
                                      .getBytes());
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.copy,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 60,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              List<int> l = Provider.of<CopyPasteProvider>(
                                      context,
                                      listen: false)
                                  .getData();
                              if (l.isNotEmpty) {
                                Provider.of<BankData>(context, listen: false)
                                    .setBytes(l);
                              }
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.paste,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 85,
                          child: Text(
                            "Speed: ${(Provider.of<BankData>(context).getSpeed() * 99 + 1).toInt()}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Slider(
                          onChanged: (double value) {
                            Provider.of<BankData>(context, listen: false)
                                .setSpeed(value);
                          },
                          value: Provider.of<BankData>(context).getSpeed(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  late TextEditingController tcon = TextEditingController();

  Future<String?> openDialog() => showDialog<String>(
      context: context,
      builder: ((context) => AlertDialog(
            title: const Text("Channel Name"),
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
}
