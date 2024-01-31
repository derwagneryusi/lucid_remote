import 'package:flutter/material.dart';
import 'package:lucid_remote/all_banks.dart';
import 'package:lucid_remote/providers/providers.dart';
import 'package:provider/provider.dart';

class OwlApp extends StatefulWidget {
  const OwlApp({super.key});

  @override
  State<OwlApp> createState() => _OwlAppState();
}

class _OwlAppState extends State<OwlApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<IsScrollAllowed>(
            create: (_) => IsScrollAllowed()),
        ChangeNotifierProvider<AllBanksData>(create: (_) => AllBanksData()),
      ],
      child: const AllBanks(),
    );
  }
}
