import 'package:save_gfy/models/xml/base_xml.dart';
import 'package:save_gfy/models/xml/xml_attribute.dart';
import 'package:save_gfy/models/xml/xml_name.dart';
import 'package:xml/xml.dart' as libraryXmlDocument;

class XmlElement extends BaseXml {
  XmlElement({this.libraryXmlElement})
      : super(libraryXmlParent: libraryXmlElement);

  final libraryXmlDocument.XmlElement libraryXmlElement;

  XmlName _name;

  XmlName get name => _name == null
      ? _name = XmlName(libraryXmlName: libraryXmlElement.name)
      : _name;

  String getAttribute(String name, {String namespace}) =>
      libraryXmlElement.getAttribute(name, namespace: namespace);

  XmlAttribute getAttributeNode(String name, {String namespace}) =>
      XmlAttribute(
          libraryXmlAttribute:
              libraryXmlElement.getAttributeNode(name, namespace: namespace));
}
