import 'package:save_gfy/models/xml/xml_name.dart';
import 'package:save_gfy/models/xml/xml_node.dart';
import 'package:xml/xml.dart' as libraryXmlDocument;

class XmlAttribute extends XmlNode {
  XmlAttribute({this.libraryXmlAttribute})
      : super(libraryXmlNode: libraryXmlAttribute);

  final libraryXmlDocument.XmlAttribute libraryXmlAttribute;

  XmlName _name;

  XmlName get name => _name == null
      ? _name = XmlName(libraryXmlName: libraryXmlAttribute.name)
      : _name;

  String get value => libraryXmlAttribute.value;
}
