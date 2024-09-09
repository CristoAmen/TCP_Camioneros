// ignore_for_file: file_names

import 'package:flutter/material.dart';

void showAlert(
    BuildContext context, String title, String content, List<Widget> actions) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions,
      );
    },
  );
}
