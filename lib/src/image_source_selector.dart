import 'package:flutter/material.dart';

import 'customized_dialog.dart';

/// Callback fired when a picture / image source is selected.
typedef SelectedPictureSource = void Function(PictureSource);

// A widget which displays only two options i.e. Camera and Gallery for selection purpose.
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

/// Defines the two possible values of selection.
enum PictureSource {
  /// Whether to select from camera.
  camera,

  /// Whether to select from gallery.
  gallery,
}
