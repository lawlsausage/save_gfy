import 'package:save_gfy/models/xml/base_xml.dart';
import 'package:xml/xml.dart' as libraryXmlDocument;

class XmlDocument extends BaseXml {
  XmlDocument({this.libraryDocument}) : super(libraryXmlParent: libraryDocument);

  /// This is the direct XmlDocument implementation provided by a library. It is recommended not to
  /// use this directly as it may be replaced by a different library over time.
  final libraryXmlDocument.XmlDocument libraryDocument;

  static XmlDocument fromString(String xmlString) => XmlDocument(libraryDocument: libraryXmlDocument.parse(xmlString));
}
