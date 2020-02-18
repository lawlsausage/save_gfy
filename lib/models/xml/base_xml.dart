import 'package:save_gfy/models/xml/xml_element.dart';
import 'package:save_gfy/models/xml/xml_node.dart';
import 'package:xml/xml.dart' as libraryXmlDocument;

abstract class BaseXml extends XmlNode {
  BaseXml({this.libraryXmlParent}) : super(libraryXmlNode: libraryXmlParent);

  final libraryXmlDocument.XmlParent libraryXmlParent;

  Iterable<XmlElement> findElements(String name, {String namespace}) =>
      libraryXmlParent
          .findElements(name, namespace: namespace)
          .map((f) => XmlElement(libraryXmlElement: f));
}
