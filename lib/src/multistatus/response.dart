import 'package:caldav_client/src/multistatus/propstat.dart';
import 'package:xml/xml.dart';

class Response {
  final String href;
  final String status;
  final Propstat? propstat;

  Response({required this.href, required this.status, this.propstat});

  static Response? fromXml(XmlElement element) {
    if (element.name.local == 'response') {
      final href = element.getElement('href', namespace: '*')?.innerText;
      if (href == null) {
        return null;
      }

      final propstat = element.getElement('propstat', namespace: '*');
      if (propstat == null) {
        final status = element.getElement('status', namespace: '*');
        return status == null
            ? null
            : Response(href: href, status: status.innerText);
      }
      final status = propstat.getElement('status', namespace: '*');
      return status == null
          ? null
          : Response(
              href: href,
              status: status.innerText,
              propstat: Propstat.fromXml(propstat));
    } else {
      return null;
    }
  }
}
