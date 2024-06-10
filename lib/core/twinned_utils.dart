import 'package:flutter/material.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/core/twin_image_helper.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:chopper/chopper.dart' as chopper;
import 'package:google_fonts/google_fonts.dart';

class TwinnedUtils {
  static Future<twin.DeviceModel?> getDeviceModel(
      {required String modelId}) async {
    try {
      var res = await TwinnedSession.instance.twin.getDeviceModel(
          apikey: TwinnedSession.instance.authToken, modelId: modelId);

      if (TwinnedUtils.validateResponse(res)) {
        return res.body?.entity;
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  static String? getDeviceModelIcon(
      {required String field, required twin.DeviceModel deviceModel}) {
    for (var p in deviceModel.parameters) {
      if (p.name == field) {
        return p.icon;
      }
    }
  }

  static Image? getDeviceModelIconImage(
      {required String field,
      required twin.DeviceModel deviceModel,
      double scale = 1.0,
      BoxFit fit = BoxFit.contain}) {
    String? iconId =
        TwinnedUtils.getDeviceModelIcon(field: field, deviceModel: deviceModel);
    if (null != iconId && iconId.trim().isNotEmpty) {
      return TwinImageHelper.getDomainImage(iconId, scale: scale, fit: fit);
    }
  }

  static Future<Image?> getDeviceModelIdIconImage(
      {required String field,
      required String modelId,
      double scale = 1.0,
      BoxFit fit = BoxFit.contain}) async {
    twin.DeviceModel? deviceModel = await getDeviceModel(modelId: modelId);
    if (null != deviceModel) {
      return getDeviceModelIconImage(
          field: field, deviceModel: deviceModel, scale: scale, fit: fit);
    }
  }

  static Future<twin.Device?> getDevice({required String deviceId}) async {
    try {
      var res = await TwinnedSession.instance.twin.getDevice(
          apikey: TwinnedSession.instance.authToken, deviceId: deviceId);

      if (TwinnedUtils.validateResponse(res)) {
        return res.body?.entity;
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  static Future<Image?> getDeviceIconImage(
      {required String field,
      required twin.Device device,
      double scale = 1.0,
      BoxFit fit = BoxFit.contain}) async {
    return TwinnedUtils.getDeviceModelIdIconImage(
        field: field, modelId: device.modelId, scale: scale, fit: fit);
  }

  static Future<Image?> getDeviceIdIconImage(
      {required String field,
      required String deviceId,
      double scale = 1.0,
      BoxFit fit = BoxFit.contain}) async {
    twin.Device? device = await getDevice(deviceId: deviceId);
    if (null != device) {
      return getDeviceIconImage(
          field: field, device: device, scale: scale, fit: fit);
    }
  }

  static TextStyle getTextStyle(FontConfig fontConfig,
      {bool googleFonts = false}) {
    if (googleFonts) {
      return GoogleFonts.getFont(
        fontConfig.fontFamily,
        fontSize: fontConfig.fontSize,
        fontWeight: fontConfig.fontBold ? FontWeight.bold : FontWeight.normal,
        color: Color(fontConfig.fontColor),
      );
    }

    return TextStyle(
      fontFamily: fontConfig.fontFamily,
      fontSize: fontConfig.fontSize,
      fontWeight: fontConfig.fontBold ? FontWeight.bold : FontWeight.normal,
      color: Color(fontConfig.fontColor),
    );
  }

  static bool validateResponse(chopper.Response r) {
    if (null == r.body) {
      debugPrint('Error: ${r.bodyString}');
      return false;
    }
    if (!r.body.ok) {
      debugPrint('Error: ${r.bodyString}');
      return false;
    }
    return true;
  }

  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
