class Util {
  /// [Util.remap] accepts a [value] which is [originalMinValue] <= [value] <= [originalMaxValue]
  /// and returns a new value which is >= [translatedMinValue] and <= [translatedMaxValue]
  /// while maintaining the same ratio.
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

  /// [Util.makeHttps] appends 'https://' or converts 'http://' to 'https://' for the String provided
  /// in the [url] parameter. If `null` is provied to [url], [Util.makeHttps] will return `null`.
  static String makeHttps(String url) {
    if (url == null) {
      return null;
    }

    return !url.startsWith(new RegExp(r'https?:\/\/'))
        ? 'https://$url'
        : url.replaceFirst('http://', 'https://');
  }

  static T catchAndDefault<T>(
    T Function() action, {
    T defaultValue,
    void Function(dynamic) onError,
  }) {
    try {
      return action?.call();
    } catch (err) {
      onError?.call(err);
    }

    return defaultValue ?? null;
  }
}
