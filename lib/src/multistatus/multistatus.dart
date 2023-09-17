import 'package:caldav_client/src/multistatus/response.dart';
import 'package:xml/xml.dart';

class MultiStatus {
  final List<Response> response;
  final String? syncToken;

  MultiStatus({required this.response, this.syncToken});

  factory MultiStatus.fromXml(XmlDocument element) {
    var child = element.firstElementChild;

    if (child!.name.local == 'multistatus') {
      // add responses
      final response = child.children
          .whereType<XmlElement>()
          .where((element) => element.name.local == 'response')
          .map((element) => Response.fromXml(element))
          .whereType<Response>()
          .toList();

      final syncToken =
          child.getElement('sync-token', namespace: '*')?.innerText;
      return MultiStatus(response: response, syncToken: syncToken);
    } else if (child.name.local == 'error') {
      if (child.firstElementChild?.name.local == 'valid-sync-token') {
        throw FormatException('Invalid sync token');
      }
    }
    throw FormatException();
  }

  factory MultiStatus.fromString(String string) {
    var document = XmlDocument.parse(string);

    return MultiStatus.fromXml(document);
  }
}
