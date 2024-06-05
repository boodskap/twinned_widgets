import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:twinned_widgets/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart' as twin;

class ImageUploadField extends StatefulWidget {
  final Map<String, dynamic> config;
  final String parameter;

  const ImageUploadField(
      {super.key, required this.config, required this.parameter});

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends BaseState<ImageUploadField> {
  String? imageId;

  @override
  void initState() {
    imageId = widget.config[widget.parameter];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (imageId?.isNotEmpty ?? false)
          SizedBox(
              width: 100,
              height: 100,
              child: TwinImageHelper.getDomainImage(imageId!)),
        IconButton(
            onPressed: () async {
              await _upload();
            },
            icon: const Icon(Icons.upload)),
      ],
    );
  }

  Future _upload() async {
    await execute(() async {
      twin.ImageFileEntityRes? res = await TwinImageHelper.uploadDomainImage();
      if (null == res) {
        return null;
      }
      if (res?.ok ?? false) {
        setState(() {
          widget.config[widget.parameter] = res?.entity?.id;
        });
      } else {
        alert('Upload Failed', 'Unknown failure');
      }
    });
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}
