import 'package:flutter/material.dart';
import 'package:save_gfy/features/app_bar/main_app_bar.dart';
import 'package:save_gfy/features/viewer/viewer.dart';
import 'package:save_gfy/main.dart';

class Home extends StatelessWidget {
  const Home({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(context),
      body: Viewer(
        title: appTitle,
      ),
    );
  }
}
