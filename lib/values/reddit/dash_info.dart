import 'package:save_gfy/models/xml/xml_element.dart';

class DashInfo {
  DashInfo({
    this.baseUrl,
    this.height,
    this.width,
    this.mimeType,
  });

  static DashInfo fromXml(XmlElement element) {
    if ((element?.name?.local ?? '') != 'Representation') {
      return null;
    }

    final height = element.getAttribute('height') ?? '';
    final width = element.getAttribute('width') ?? '';

    final baseUrlElements = element.findElements('BaseURL') ?? [];
    final baseUrlElement =
        baseUrlElements.length > 0 ? baseUrlElements.first : null;

    final mimeType = element.getAttribute('mimeType') ?? '';

    return DashInfo(
      baseUrl: baseUrlElement?.text ?? '',
      height: int.tryParse(height) ?? 0,
      width: int.tryParse(width) ?? 0,
      mimeType: mimeType,
    );
  }

  final String baseUrl;

  final int height;

  final int width;

  final String mimeType;
}
