class WidgetUtil {
  static String getStrippedLabel(String label) {
    int index = label.indexOf(":");
    if (index >= 0) {
      return label.substring(index + 1);
    }
    return label;
  }
}
