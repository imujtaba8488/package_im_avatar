import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'image_source_selector.dart';

/// Signature of the function fired when an image is selected either from the gallery or the camera.
typedef _OnSelection = void Function(String imagePath, File imageFile);

/// The Avatar widget uses the built-in CircularAvatar widget to show an avatar image, __with the added support for selecting an image from the gallery or the camera.__ Clicking the Avatar widget presents the user with a choice to select an image either from the gallery or from the camera. Once the image is selected, the Avatar image is immediately replaced with the new image selected. _It is the responsiblity of the class user to store the imagePath or imageFile as required provided in the onSelection callback and update the [networkPath] or [localPath] accordingly in order to preserve the new image within the Avatar._
class Avatar extends StatefulWidget {
  /// Radius of the circular avatar.
  final double radius;

  /// Fired when an image is selected either from the camera or the gallery.
  final _OnSelection onSelection;

  /// Once the image is selected from the camera or the gallery, it may be permanantly displayed within the Avatar using the networkPath, retrieved using the onSelection callback.
  final String networkPath;

  /// Once the image is selected from the camera or the gallery, it may be permanantly displayed within the Avatar using the localPath, retrieved using the onSelection callback.
  final String localPath;

  /// Whether the avatar selection from camera or gallery is disabled or not.
  final bool selectionDisabled;

  /// Shape of the avatar, for example, circular or square.
  final AvatarShape avatarShape;

  /// Whether to disable the animation when setting a new image.
  final bool loadingAnimationDisabled;

  /// The animation effect to show when setting a new image.
  final Curve loadingAnimationEffect;

  /// The duration of the loading animation.
  final Duration loadingAnimationDuration;

  Avatar({
    this.radius = 50.0,
    this.onSelection,
    this.networkPath,
    this.localPath,
    this.selectionDisabled = false,
    this.avatarShape = AvatarShape.circular,
    this.loadingAnimationDisabled = false,
    this.loadingAnimationEffect = Curves.bounceIn,
    this.loadingAnimationDuration = const Duration(milliseconds: 1500),
  }) {
    assert(
        networkPath != null && localPath == null ||
            networkPath == null && localPath != null ||
            networkPath == null && localPath == null,
        'Only one of the paths i.e networkPath and localPath can be specified');
  }

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> with SingleTickerProviderStateMixin {
  /// The default path to be used for the avatar image, which is typically set to 'assets/default_avatar.png' initially and changed to the local path of the image, when an image is selected.
  String _defaultImagePath;

  /// An image file created out of the local path of the image selected. Typically, required the the user app requires to store the picture locally or on cloud.
  File _imageFile;
  String _networkPath;
  String _localPath;

  /// The source used to capture an image i.e. either camera or gallery.
  PictureSource _pictureSource;

  /// Since usings assets in dart requires a package attribute to be specified in the AssetImage, this exists for that sole reasons. Otherwise it could have been omitted altogether.
  bool _usePackageDefaultImage;

  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _defaultImagePath = 'assets/default_avatar.png';
    _networkPath = widget.networkPath;
    _localPath = widget.localPath;
    _pictureSource = PictureSource.gallery;

    //* MUST CHANGE TO 'TRUE' IN PACKAGE. FOR TESTING IN THIS PROJECT SET IT TO 'FALSE'.
    _usePackageDefaultImage = false;

    _animationController = AnimationController(
      vsync: this,
      duration: widget.loadingAnimationDuration,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _animation = Tween(begin: 0.0, end: widget.radius).animate(CurvedAnimation(
        parent: _animationController, curve: widget.loadingAnimationEffect));

    return IgnorePointer(
      ignoring: widget.selectionDisabled,
      child: InkWell(
        onTap: _showImageSelectorDialog,
        child: Container(
          decoration: BoxDecoration(
            shape: widget.avatarShape == AvatarShape.circular
                ? BoxShape.circle
                : BoxShape.rectangle,
          ),
          height: _animation.status == AnimationStatus.dismissed
              ? widget.radius
              : _animation.value,
          width: _animation.status == AnimationStatus.dismissed
              ? widget.radius
              : _animation.value,
          child: widget.avatarShape == AvatarShape.circular
              ? ClipOval(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Image(
                      image: _avatarImage(),
                    ),
                  ),
                )
              : FittedBox(
                  fit: BoxFit.cover,
                  child: Image(
                    image: _avatarImage(),
                  ),
                ),
        ),
      ),
    );
  }

  /// Shows the Camera or Gallery selection dialog.
  void _showImageSelectorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ImageSourceSelector(
          selectedPictureSource: (PictureSource picSource) {
            _pictureSource = picSource;
            _pickImage();
          },
        );
      },
    );
  }

  /// Calls the permission_handler to first ask for media permission. Subsequently, uses the ImagePicker to pick an image either from the gallary or from the camera, as specified in the [ImageSourceSelector].
  void _pickImage() async {
    if (await Permission.storage.request().isGranted) {
      final ImagePicker imagePicker = ImagePicker();

      final pickedFile = await imagePicker.getImage(
        source: _pictureSource == PictureSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 25,
      );

      /// If the user did select an image. A lot many times user may decide to simply cancel the image pick operation by say hitting the back button, in that case the pickedFile will be null.
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);

        setState(() {
          // Since, the avatar image immediately needs to be updated with the image selected, both network and local path become null.
          _networkPath = null;
          _localPath = null;

          _defaultImagePath = pickedFile.path;

          _usePackageDefaultImage = false;

          // Run animation when loading a new image.
          if (!widget.loadingAnimationDisabled) {
            _animationController.reset();
            _animationController.forward();
          }
        });

        if (widget.onSelection != null) {
          widget.onSelection(_defaultImagePath, _imageFile);
        }
      }
    }
  }

  ImageProvider _avatarImage() {
    if (_networkPath != null) {
      return NetworkImage(_networkPath);
    } else if (_localPath != null) {
      return AssetImage(_localPath);
    } else {
      return AssetImage(
        _defaultImagePath,
        package: _usePackageDefaultImage ? 'im_avatar' : null,
      );
    }
  }
}

enum AvatarShape {
  circular,
  square,
}
