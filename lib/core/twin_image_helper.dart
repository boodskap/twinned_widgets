import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as web;
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:twinned_widgets/twinned_session.dart';

class TwinImageHelper {
  static Future<PlatformFile?> pickFile(
      {List<String> allowedExtensions = const [
        'jpg',
        'png',
        'jpeg',
        'JPEG',
        'JPG',
        'PNG'
      ]}) async {
    FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (null != result) {
      return result.files.first;
    }

    return null;
  }

  static Future<twin.ImageFileEntityRes?>? _upload(
      web.MultipartRequest mpr, PlatformFile file) async {
    try {
      debugPrint('ApiKey ${TwinnedSession.instance.authToken}');
      mpr.headers['APIKEY'] = TwinnedSession.instance.authToken ?? '';

      mpr.files.add(
        web.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
      );

      debugPrint('Uploading...');
      var stream = await mpr.send();
      var response = await stream.stream.bytesToString();

      debugPrint('Decoding response...');
      var map = jsonDecode(response) as Map<String, dynamic>;

      debugPrint('Converting response... ${jsonEncode(map)}');
      return twin.ImageFileEntityRes.fromJson(map);
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    return null;
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

  static Future<twin.AssetBulkUploadRes?> uploadAssetBulkUpload(
      PlatformFile file,
      {required String premiseId,
      required String facilityId,
      required String floorId,
      required String assetModelId,
      required String deviceModelId,
      required List<String> roleIds,
      required List<String> clientIds}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/Asset/bulk/upload",
      ),
    );

    try {
      debugPrint('ApiKey ${TwinnedSession.instance.authToken}');
      mpr.headers['APIKEY'] = TwinnedSession.instance.authToken ?? '';
      mpr.headers['premiseId'] = premiseId;
      mpr.headers['facilityId'] = facilityId;
      mpr.headers['floorId'] = floorId;
      mpr.headers['assetModelId'] = assetModelId;
      mpr.headers['deviceModelId'] = deviceModelId;
      if (clientIds.isNotEmpty) mpr.headers['clientIds'] = clientIds.join(',');
      if (roleIds.isNotEmpty) mpr.headers['roleIds'] = roleIds.join(',');

      mpr.files.add(
        web.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
      );

      debugPrint('Uploading...');
      var stream = await mpr.send();
      var response = await stream.stream.bytesToString();

      debugPrint('Decoding response...');
      var map = jsonDecode(response) as Map<String, dynamic>;

      debugPrint('Converting response... ${jsonEncode(map)}');
      return twin.AssetBulkUploadRes.fromJson(map);
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    return null;
  }

  static Future<twin.ImageFileEntityRes?>? uploadDomainImage() async {
    try {
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
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
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
