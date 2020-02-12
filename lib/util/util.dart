class Util {
  static double remap(
      double value,
      double originalMinValue,
      double originalMaxValue,
      double translatedMinValue,
      double translatedMaxValue) {
    if (originalMaxValue - originalMinValue == 0) return 0;

    return (value - originalMinValue) /
            (originalMaxValue - originalMinValue) *
            (translatedMaxValue - translatedMinValue) +
        translatedMinValue;
  }

  static String makeHttps(String url) {
    return !url.startsWith(new RegExp(r'https?:\/\/'))
        ? 'https://$url'
        : url.replaceFirst('http://', 'https://');
  }
}
