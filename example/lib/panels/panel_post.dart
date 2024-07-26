
import 'package:dio_http_cache_extension/dio_http_cache_extension.dart';
import 'package:flutter/material.dart';

import '../dio_helper.dart';
import 'helper.dart';

class PostPanel extends StatefulWidget {
  @override
  State createState() => _PostPanelState();
}

class _PostPanelState extends State<PostPanel> {
  Map<String, String?> _content = {'Hello ~': ''};
  var _url = 'article/query/0/json';
  late TextEditingController _paramsController;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _paramsController = TextEditingController(text: 'flutter');
    _urlController = TextEditingController(text: _url);
  }

  void _doRequest() {
    final params = _paramsController.text;
    final paramsAvailable = params.isNotEmpty;
    setState(() => _content = {'Requesting': params});
    DioHelper.getDio()
        .post(_urlController.text,
            data: paramsAvailable ? {'k': params} : {},
            options: buildCacheOptions(Duration(hours: 1),
                subKey: paramsAvailable ? 'k=$params' : null,
                forceRefresh: false))
        .then((response) => setState(() =>
            _content = PanelHelper.getPrintContent(_url, params, response)))
        .catchError((onError, stackTrace) => setState(
            () => _content = PanelHelper.getPrintError(onError, stackTrace)));
  }

  @override
  Widget build(BuildContext context) {
    return PanelHelper.buildNormalPanel('Normal POST example', _urlController,
        _paramsController, _content, _doRequest);
  }
}
