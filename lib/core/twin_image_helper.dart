import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as web;
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:twinned_widgets/twinned_session.dart';

class TwinImageHelper {
  static Future<PlatformFile?> pickFile() async {
    FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'JPEG', 'JPG', 'PNG'],
    );

    if (null != result) {
      return result.files.first;
    }

    return null;
  }

  static Future<twin.ImageFileEntityRes> _upload(
      web.MultipartRequest mpr, PlatformFile file) async {
    mpr.headers['APIKEY'] = TwinnedSession.instance.authToken ?? '';

    mpr.files.add(
      web.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
    );

    //debugPrint("uploading... ${mpr.url}");
    var stream = await mpr.send();
    //log("extracting...");
    var response = await stream.stream.bytesToString();
    //debugPrint("decoding: $response...");
    var map = jsonDecode(response) as Map<String, dynamic>;
    //log("converting...");
    return twin.ImageFileEntityRes.fromJson(map);
  }

  static Future<twin.ImageFileEntityRes?> uploadDomainIcon() async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/domain/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.icon.value}",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadDomainImage() async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/domain/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.image.value}",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadDomainBanner() async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/domain/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.banner.value}",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadUserImage(
      {required String userId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/user/$userId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadFloorImage(
      {required String floorId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/floor/$floorId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadAssetImage(
      {required String assetId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/asset/$assetId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadFacilityImage(
      {required String facilityId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/facility/$facilityId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadPremiseImage(
      {required String premiseId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/premise/$premiseId",
      ),
    );

    return _upload(mpr, file);
  }

  static Image getDomainImage(String id,
      {double scale = 1.0, BoxFit fit = BoxFit.contain}) {
    return Image.network(
      'https://${TwinnedSession.instance.host}/rest/nocode/TwinImage/download/${TwinnedSession.instance.domainKey}/$id',
      scale: scale,
      fit: fit,
    );
  }
}
