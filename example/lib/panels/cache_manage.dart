import 'package:flutter/material.dart';

import '../dio_helper.dart';

class CacheManagerPanel extends StatefulWidget {
  const CacheManagerPanel({Key? key}) : super(key: key);

  @override
  State createState() => _CacheManagerPanelState();
}

enum _Mode { clearByKey, clearByKeyAndSubKey, clearAll }

class _CacheManagerPanelState extends State<CacheManagerPanel> {
  _Mode? _mode = _Mode.clearAll;
  final _url = 'article/query/0/json';
  final _keyController = TextEditingController();
  final _requestMethodController = TextEditingController();
  final _subKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Cache Manager',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).primaryColor)),
              Container(height: 50),
              Text('1. Choose mode:',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Theme.of(context).primaryColor)),
              DropdownButton<_Mode>(
                  value: _mode,
                  onChanged: (value) => setState(() => _mode = value),
                  items: <_Mode>[
                    _Mode.clearByKey,
                    _Mode.clearByKeyAndSubKey,
                    _Mode.clearAll
                  ]
                      .map<DropdownMenuItem<_Mode>>((value) =>
                          DropdownMenuItem<_Mode>(
                              value: value, child: Text(getTxtByMode(value))))
                      .toList()),
              Container(height: 20),
              for (final w in getRequestMethodViews(context)) w,
              Container(height: 20),
              for (final w in getKeyViews(context)) w,
              Container(height: 20),
              for (final w in getSubKeyViews(context)) w,
              Container(height: 20),
              Text('${getLabel()}. to clear',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Theme.of(context).primaryColor)),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: FloatingActionButton(
                      onPressed: _clear,
                      child: Text('Clear',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(color: Colors.white))))
            ]));
  }

  void _clear() {
    if (_mode == _Mode.clearAll) {
      DioHelper.getCacheManager().clearAll().then(resultPrinter);
    } else if (_mode == _Mode.clearByKey) {
      DioHelper.getCacheManager()
          .deleteByPath(_keyController.text,
              requestMethod: _requestMethodController.text)
          .then(resultPrinter);
    } else if (_mode == _Mode.clearByKeyAndSubKey) {
      // DioHelper.getCacheManager()
      //     .deleteByPrimaryKeyAndSubKey(_keyController.text,
      //         requestMethod: _requestMethodController.text,
      //         subKey: _subKeyController.text)
      //     .then(resultPrinter);
    }
  }

  void resultPrinter(bool result) {
    showSnackBar("缓存清理${result ? '成功' : '失败'}");
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  List<Widget> getRequestMethodViews(BuildContext context) {
    if (_mode == _Mode.clearAll) {
      return [];
    }
    _requestMethodController.text = 'POST';
    return [
      Text('2. RequestMethod:',
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Theme.of(context).primaryColor)),
      TextField(
          controller: _requestMethodController,
          style: Theme.of(context).textTheme.bodyLarge),
      Container(height: 20),
    ];
  }

  List<Widget> getKeyViews(BuildContext context) {
    if (_mode == _Mode.clearAll) {
      return [];
    }
    _keyController.text = "${DioHelper.baseUrl}$_url";
    return [
      Text('3. Key:',
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Theme.of(context).primaryColor)),
      TextField(
          controller: _keyController,
          style: Theme.of(context).textTheme.bodyLarge),
      Container(height: 20),
    ];
  }

  List<Widget> getSubKeyViews(BuildContext context) {
    if (_mode == _Mode.clearAll || _mode == _Mode.clearByKey) {
      return [];
    }
    _subKeyController.text = 'k=flutter';
    return [
      Text('4. Subkey:',
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Theme.of(context).primaryColor)),
      TextField(
          controller: _subKeyController,
          style: Theme.of(context).textTheme.bodyLarge),
      Container(height: 20),
    ];
  }

  String getLabel() {
    if (_mode == _Mode.clearAll) {
      return '2';
    } else if (_mode == _Mode.clearByKey)
      return '4';
    else
      return '5';
  }

  String getTxtByMode(_Mode mode) {
    if (mode == _Mode.clearAll) {
      return 'Clear All';
    } else if (mode == _Mode.clearByKey)
      return 'Clear by Key';
    else
      return 'Clear By Key and SubKey';
  }
}
