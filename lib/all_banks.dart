import 'package:flutter/material.dart';
import 'package:lucid_remote/colors.dart';
import 'package:provider/provider.dart';
import 'overview.dart';
import 'providers/providers.dart';
import 'single_bank.dart';

class AllBanks extends StatefulWidget {
  const AllBanks({super.key});

  @override
  State<AllBanks> createState() => _AllBanksState();
}

class _AllBanksState extends State<AllBanks>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 6, vsync: this);
    Provider.of<AllBanksData>(context, listen: false).controller = _controller;
    _controller.addListener(() {
      Provider.of<AllBanksData>(context, listen: false)
          .request(_controller.index > 0 ? 2 : 1);
    });
  }

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
        bottom: TabBar(
          controller: _controller,
          tabs: [
            const Tab(
              icon: Icon(Icons.menu),
            ),
            for (int i = 0; i < 5; i++)
              Tab(
                text: "B${i + 1}",
              )
          ],
        ),
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider<ChannelNamesData>(
              create: (_) => ChannelNamesData()),
          ChangeNotifierProvider<CopyPasteProvider>(
              create: (_) => CopyPasteProvider()),
        ],
        child: TabBarView(
          controller: _controller,
          physics: Provider.of<IsScrollAllowed>(context).getScrollAllowed()
              ? const CustomTabBarViewScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          children: [
            const Overview(),
            for (int i = 0; i < 5; i++)
              Padding(
                padding: const EdgeInsets.all(10),
                child: ChangeNotifierProvider(
                  create: (context) =>
                      Provider.of<AllBanksData>(context, listen: false)
                          .getBankData(i),
                  child: const SingleBank(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomTabBarViewScrollPhysics extends ScrollPhysics {
  const CustomTabBarViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomTabBarViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomTabBarViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 50,
        stiffness: 100,
        damping: 0.8,
      );
}
