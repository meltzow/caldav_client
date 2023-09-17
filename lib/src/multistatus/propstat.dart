import 'package:caldav_client/src/multistatus/element.dart';
import 'package:xml/xml.dart';

class Propstat {
  final Map<String, dynamic> prop;

  Propstat({required this.prop});

  factory Propstat.fromXml(XmlElement element) {
    if (element.name.local == 'propstat') {
      var prop = <String, dynamic>{};

      var elements = element.children.whereType<XmlElement>();

      // get prop
      var props = elements
          .firstWhere((element) => element.name.local == 'prop')
          .children
          .whereType<XmlElement>();

      // set prop value
      props.forEach((element) {
        var children = element.children
            .whereType<XmlElement>()
            .map((element) => Element.fromXml(element))
            .toList();

        var value = children.isEmpty ? element.text : children;

        prop[element.name.local] = value;
      });

      return Propstat(prop: prop);
    }

    throw Error();
  }

  @override
  String toString() {
    var string = '';

    prop.forEach((key, value) {
      var valueString = value.toString();

      string += '$key: ${valueString.length > 200 ? '\n' : ''}$valueString';
    });

    return string;
  }
}
