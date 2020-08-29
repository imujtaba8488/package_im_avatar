# Examples

```dart
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:im_avatar/im_avatar.dart';

main() => MyApp();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Homepage(),
      ),
    );
  }
}

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  File imageFile;
  String networkUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Avatar(
        selectionDisabled: true,
        radius: 30.0,
        networkPath: networkUrl,
        onSelection: (String url, File file) {
          networkUrl = url;
          imageFile = file;
        },
        avatarShape: AvatarShape.circular,
      ),
    );
  }
}
```
