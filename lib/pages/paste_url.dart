import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_gfy/blocs/shared_url_bloc.dart';
import 'package:save_gfy/features/buttons/raised_icon_button.dart';
import 'package:save_gfy/main.dart';

typedef OnPasteCallback(String value);

class PasteUrl extends StatefulWidget {
  const PasteUrl({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PasteUrlState();
}

class _PasteUrlState extends State<PasteUrl> {
  final List<String> _validHosts = [
    ...MyApp.configService.getAppConfig().gfycat.hosts,
    ...MyApp.configService.getAppConfig().reddit.hosts,
  ];

  String _clipboardContent = '';

  Future _initClipboardData() async {
    final clipboardData = await Clipboard.getData('text/plain');
    String formattedData = clipboardData?.text?.trim() ?? '';
    if (formattedData.length > 0) {
      String matchedHost = _validHosts.firstWhere((host) {
        return formattedData.toLowerCase().contains(host);
      }, orElse: () => '');
      setState(() {
        _clipboardContent =
            matchedHost.length > 0 ? formattedData : _clipboardContent;
      });
    }
  }

  void _handlePastePressed(BuildContext context) {
    sharedUrlBloc.add(_clipboardContent);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _initClipboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 2.0,
              colors: [
                Color.fromRGBO(2, 0, 36, 1.0),
                Color.fromRGBO(9, 9, 42, 1.0),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedIconButton(
                icon: Icon(Icons.content_paste),
                iconSize: 64.0,
                padding: EdgeInsets.all(24.0),
                onPressed: _clipboardContent.length == 0
                    ? null
                    : () => _handlePastePressed(context),
              ),
              Padding(
                padding: EdgeInsets.only(top: kMaterialListPadding.top),
                child: Text(
                  _clipboardContent.length == 0
                      ? 'Nothing in your clipboard!'
                      : _clipboardContent,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
