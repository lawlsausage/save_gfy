import 'package:xml/xml.dart' as libraryXmlDocument;

class XmlName {
  XmlName({this.libraryXmlName});

  final libraryXmlDocument.XmlName libraryXmlName;

  String get prefix => libraryXmlName.prefix;

  String get local => libraryXmlName.local;

  String get qualified => libraryXmlName.qualified;

  String get namespaceUri => libraryXmlName.namespaceUri;
}