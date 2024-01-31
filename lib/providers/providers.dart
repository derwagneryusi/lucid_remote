import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucid_remote/connect_screen.dart';

List<int> data = [
  for (int i = 0; i < 205; i++) 0,
];

class SequenceData with ChangeNotifier {
  double _brightness = 0;
  double _smoothness = 0;

  final List<bool> _sequence = [
    for (int i = 0; i < 24; i++) false,
  ];

  double getBrightness() {
    return _brightness;
  }

  double getSmoothness() {
    return _smoothness;
  }

  bool getSequence(int i) {
    return _sequence[i];
  }

  void setBrightness(double b) {
    _brightness = b;
    notifyListeners();
  }

  void setSmoothness(double s) {
    _smoothness = s;
    notifyListeners();
  }

  void setSequence(int i, bool b) {
    _sequence[i] = b;
    notifyListeners();
  }

  List<int> getBytes() {
    List<int> lst = [];
    for (int i = 0; i < 3; i++) {
      int b = 0;
      for (int j = 0; j < 8; j++) {
        b |= ((_sequence[i * 8 + j] ? 1 : 0) << j);
      }
      lst.add(b);
    }
    lst.add((_brightness * 100).toInt());
    lst.add((_smoothness * 100).toInt());
    return lst;
  }

  void setBytes(List<int> lst) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 8; j++) {
        _sequence[i * 8 + j] = (lst[i] & (1 << j)) > 0;
      }
      _brightness = lst[3] / 100.0;
      _smoothness = lst[4] / 100.0;
    }
    notifyListeners();
  }

  @override
  void dispose() {}
}

class ChannelNamesData with ChangeNotifier {
  final List<String> _channelNames = [
    for (int i = 0; i < 8; i++) "Channel ${i + 1}",
  ];

  String getChannelName(int i) {
    return _channelNames[i];
  }

  void setChannelName(int i, String n) {
    _channelNames[i] = n;
    notifyListeners();
  }
}

class IsScrollAllowed with ChangeNotifier {
  bool _scrollAllowed = true;

  bool getScrollAllowed() {
    return _scrollAllowed;
  }

  void setScrollAllowed(bool b) {
    _scrollAllowed = b;
    notifyListeners();
  }
}

class BankData with ChangeNotifier {
  double _speed = 0.5;

  final List<SequenceData> _sequenceData = [
    for (int i = 0; i < 8; i++) SequenceData(),
  ];

  double getSpeed() {
    return _speed;
  }

  SequenceData getSequence(int i) {
    return _sequenceData[i];
  }

  void setSpeed(double s) {
    _speed = s;
    notifyListeners();
  }

  void setSequence(int i, SequenceData s) {
    _sequenceData[i] = s;
    notifyListeners();
  }

  List<int> getBytes() {
    List<int> lst = [];
    for (int i = 0; i < 8; i++) {
      lst.addAll(_sequenceData[i].getBytes());
    }
    lst.add((_speed * 100).toInt());
    return lst;
  }

  void setBytes(List<int> lst) {
    for (int i = 0; i < 8; i++) {
      _sequenceData[i].setBytes(lst.getRange(i * 5, i * 5 + 5).toList());
    }
    _speed = lst[40] / 100.0;
    notifyListeners();
  }

  @override
  void dispose() {}
}

class AllBanksData with ChangeNotifier {
  late TabController controller;

  bool _get_inputs = false;
  bool _send_data = false;
  bool _reading = true;
  bool _eeprom_save = false;

  bool _single_write_request = false;
  bool _ee_save_request = false;

  int _request = 1;

  double _rc1 = 0;
  double _rc2 = 0;

  int _state = 0;

  int _secondChannelJob = 0;

  List<int> _tmp_lst = [];

  List<int> _ui_data = [
    for (int i = 0; i < 206; i++) 0,
  ];
  List<int> _device_data = [
    for (int i = 0; i < 206; i++) 0,
  ];

  int getFirstDifferentIndex() {
    for (int i = 0; i < _ui_data.length; i++) {
      if (_ui_data[i] != _device_data[i]) {
        return i;
      }
    }
    return -1;
  }

  AllBanksData() {
    var data_timer =
        Timer.periodic(const Duration(milliseconds: 100), ((data_timer) async {
      await _tick(data_timer);
    }));
  }

  void request(int r) {
    _request = r;
  }

  void singleWriteRequest() {
    _single_write_request = true;
  }

  void eeSaveRequest() {
    _ee_save_request = true;
  }

  Future<void> switchBools() async {
    switch (_request) {
      case 0:
        _get_inputs = false;
        _send_data = false;
        _reading = false;
        _eeprom_save = false;
        break;
      case 1:
        _get_inputs = true;
        _send_data = false;
        _reading = false;
        _eeprom_save = false;
        break;
      case 2:
        _get_inputs = false;
        _send_data = true;
        _reading = false;
        _eeprom_save = false;
        break;
      case 3:
        _get_inputs = false;
        _send_data = false;
        _reading = true;
        _eeprom_save = false;
        break;
    }
    if (_single_write_request) {
      _get_inputs = false;
      _send_data = true;
      _reading = false;
      _eeprom_save = false;
    }
    if (_ee_save_request) {
      _get_inputs = false;
      _send_data = false;
      _reading = false;
      _eeprom_save = true;
    }
  }

  Future<void> _tick(Timer t) async {
    t.cancel();
    int index = getFirstDifferentIndex();
    _ui_data = getAllBytes();
    if (_get_inputs) {
      if (_state == 0) {
        await btUartWrite([0x61]);
        _state++;
      } else if (_state == 1) {
        setInputs(btUartRead() / 255.0, btUartRead() / 255.0);
        _state = 0;
        switchBools();
      }
    } else if (_send_data) {
      if (index == -1) {
        switchBools();
      } else if (_state == 0) {
        await btUartWrite([0x64]);
        _state++;
      } else if (_state == 1) {
        if (btUartRead() == 0xFA) _state++;
      } else {
        await btUartWrite([index, _ui_data[index]]);
        _device_data[index] = _ui_data[index];
        _state = 0;
        _single_write_request = false;
        switchBools();
      }
    } else if (_reading) {
      if (_state == 0) {
        while (btUartAvailable()) {
          btUartRead();
        }
        await btUartWrite([0x63]);
        _state++;
      } else if (_state == 1) {
        while (btUartAvailable()) {
          _tmp_lst.add(btUartRead());
        }
        if (_tmp_lst.length == 206) {
          setAllBytes(_tmp_lst);
          _device_data = _tmp_lst;
          _state = 0;
          switchBools();
          _tmp_lst = [];
        }
      }
    } else if (_eeprom_save) {
      if (_state == 0) {
        await btUartWrite([0x65]);
        _state++;
      } else if (_state == 1) {
        if (btUartAvailable()) {
          if (btUartRead() == 0x00) {
            _state++;
          }
        }
      } else if (_state == 2) {
        _ee_save_request = false;
        _state = 0;
        switchBools();
      }
    }
    t = Timer.periodic(const Duration(milliseconds: 1), ((t) async {
      await _tick(t);
    }));
  }

  final List<BankData> _bankData = [
    for (int i = 0; i < 5; i++) BankData(),
  ];

  int getSecondChannelJob() {
    return _secondChannelJob;
  }

  void setSecondChannelJob(int b) {
    _secondChannelJob = b;
    notifyListeners();
  }

  double getInputOne() {
    return _rc1;
  }

  double getInputTwo() {
    return _rc2;
  }

  void setInputs(double a, double b) {
    _rc1 = a;
    _rc2 = b;
    notifyListeners();
  }

  BankData getBankData(int i) {
    return _bankData[i];
  }

  void setBankData(int i, BankData b) {
    _bankData[i] = b;
    notifyListeners();
  }

  List<int> getAllBytes() {
    List<int> lst = [];
    for (int i = 0; i < 5; i++) {
      lst.addAll(_bankData[i].getBytes());
    }
    lst.add(_secondChannelJob);
    return lst;
  }

  void setAllBytes(List<int> lst) {
    for (int i = 0; i < 5; i++) {
      _bankData[i].setBytes(lst.getRange(i * 41, i * 41 + 41).toList());
    }
    _secondChannelJob = lst[lst.length - 1];
    notifyListeners();
  }
}

class CopyPasteProvider with ChangeNotifier {
  List<int> _data = [];

  List<int> getData() {
    return _data;
  }

  void setData(List<int> data) {
    _data = data;
    notifyListeners();
  }
}

class BLEProvider with ChangeNotifier {
  late LucidBLE _ble;

  LucidBLE getBLE() {
    return _ble;
  }

  void setBLE(LucidBLE ble) {
    _ble = ble;
  }
}

class FilesData with ChangeNotifier {
  FilesData(List<File> lst) {
    _files = lst;
  }

  List<File> _files = [];

  void setFiles(List<File> f) {
    _files = f;
    notifyListeners();
  }

  List<File> getFiles() {
    return _files;
  }
}
