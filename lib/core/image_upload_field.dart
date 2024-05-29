import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:twinned_widgets/core/twin_image_helper.dart';

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
        if (null != imageId)
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
      var res = await TwinImageHelper.uploadDomainImage();
      if (null == res) {
        return null;
      }
      if (res!.ok) {
        alert('Upload Failed', 'Unknown failure');
      } else {
        setState(() {
          widget.config[widget.parameter] = res!.entity!.id!;
        });
      }
    });
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}
