import 'package:twinned_api/api/twinned.swagger.dart';

class TwinnedWidgetUtils {
  static String getParameterLabel(String name, DeviceModel deviceModel) {
    for (var p in deviceModel.parameters) {
      if (p.name == name) {
        String label = p.label ?? p.name;
        return getStrippedLabel(label);
      }
    }

    return '?';
  }

  static String getStrippedLabel(String label) {
    int index = label.indexOf(":");
    if (index >= 0) {
      return label.substring(index + 1);
    }
    return label;
  }
}
