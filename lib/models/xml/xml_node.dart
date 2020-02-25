import 'package:xml/xml.dart' as libraryXmlDocument;

class XmlNode {
  XmlNode({this.libraryXmlNode});

  final libraryXmlDocument.XmlNode libraryXmlNode;
  
  String get text => libraryXmlNode.text;
}
