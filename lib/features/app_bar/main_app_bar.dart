import 'package:flutter/material.dart';
import 'package:save_gfy/main.dart';
import 'package:save_gfy/values/routes.dart' as SaveGfyRoutes;

enum _Option {
  pasteUrl,
}

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  MainAppBar(this.context) {
    _handleSelectedStrategy[_Option.pasteUrl] = _handlePasteUrlSelected;
  }

  final BuildContext context;

  final Map<_Option, void Function()> _handleSelectedStrategy = Map();

  void _handleSelected(_Option option) {
    _handleSelectedStrategy[option]();
  }

  void _handlePasteUrlSelected() {
    Navigator.pushNamed(context, SaveGfyRoutes.Route.pasteUrl.path);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Here we take the value from the WebDownloader object that was created by
      // the App.build method, and use it to set our appbar title.
      title: Text(appTitle),
      actions: <Widget>[
        PopupMenuButton(
          icon: Icon(Icons.more_vert),
          onSelected: _handleSelected,
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: _Option.pasteUrl,
              child: Text('Paste a URL'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
