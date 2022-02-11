import 'package:flutter/material.dart';

abstract class GoogleMapAppPage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const GoogleMapAppPage(this.leading, this.title);

  final Widget leading;
  final String title;
}
