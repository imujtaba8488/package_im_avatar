import 'package:flutter/material.dart';

import 'customized_dialog.dart';

typedef SelectedPictureSource = void Function(PictureSource);

class ImageSourceSelector extends StatelessWidget {
  final SelectedPictureSource selectedPictureSource;

  ImageSourceSelector({this.selectedPictureSource});

  @override
  Widget build(BuildContext context) {
    return CustomizedDialog(
      hasRoundedCorners: false,
      borderWidth: 0.5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          OutlineButton(
            borderSide: BorderSide.none,
            child: Text(
              'Camera',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              selectedPictureSource(PictureSource.camera);
              Navigator.pop(context);
            },
          ),
          OutlineButton(
            borderSide: BorderSide.none,
            child: Text(
              'Gallery',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              selectedPictureSource(PictureSource.gallery);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

enum PictureSource {
  camera,
  gallery,
}
