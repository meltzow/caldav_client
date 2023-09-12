import 'package:caldav_client/src/cal_response.dart';
import 'caldav_base.dart';
import 'utils.dart';

class CalDavClient extends CalDavBase {
  CalDavClient(
      {required String baseUrl,
      Duration? connectionTimeout,
      Map<String, dynamic>? headers})
      : super(
            baseUrl: baseUrl,
            connectionTimeout: connectionTimeout,
            headers: headers);

  Future<CalResponse> getPrincipal({int depth = 0}) {
    final body = '''
    <d:propfind xmlns:d="DAV:">
      <d:prop>
        <d:current-user-principal />
      </d:prop>
    </d:propfind>
    ''';
    return propfind('', body, depth: depth);
  }

  Future<CalResponse> getCalendars(String path, {int depth = 1}) {
    final body = '''
    <d:propfind xmlns:d="DAV:" xmlns:cs="http://calendarserver.org/ns/" xmlns:c="urn:ietf:params:xml:ns:caldav">
      <d:prop>
        <d:resourcetype />
        <d:displayname />
        <cs:getctag />
        <c:supported-calendar-component-set />
      </d:prop>
    </d:propfind>
    ''';
    return propfind(path, body, depth: depth);
  }

  /// This request will give us every object that's a VCALENDAR object, and its etag.
  Future<CalResponse> getEvents(String path, {int depth = 1}) {
    var body = '''
    <c:calendar-query xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav">
    <d:prop>
        <d:getetag />
        <d:sync-token />
        <c:calendar-data>
          <c:expand start="19000101T000000Z" end="99991231T235959Z" />
        </c:calendar-data>
    </d:prop>
    <c:filter>
        <c:comp-filter name="VCALENDAR">
          <c:comp-filter name="VEVENT">
            <c:time-range start= "19000101T000000Z" end="99991231T235959Z" />
          </c:comp-filter>
        </c:comp-filter>
    </c:filter>
    </c:calendar-query>
    ''';

    return report(path, body, depth: depth);
  }

  /// This request will give us every object that's a VCALENDAR object, and its etag in a given time range.
  Future<CalResponse> getEventsInTimeRange(
      String path, DateTime start, DateTime end,
      {int depth = 1}) {
    final normalizedStart = stringify(start);
    final normalizedEnd = stringify(end);
    var body = '''
    <c:calendar-query xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav">
    <d:prop>
        <d:getetag />
        <c:calendar-data>
          <c:expand start="$normalizedStart" end="$normalizedEnd" />
        </c:calendar-data>
    </d:prop>
    <c:filter>
        <c:comp-filter name="VCALENDAR">
          <c:comp-filter name="VEVENT">
            <c:time-range start="$normalizedStart" end="$normalizedEnd" /> 
          </c:comp-filter>
        </c:comp-filter>
    </c:filter>
    </c:calendar-query>
    ''';

    return report(path, body, depth: depth);
  }

  /// Request the ctag again on the calendar. If the ctag did not change, you still
  /// have the latest copy.
  /// If it did change, you must request all the etags in the entire calendar again.
  Future<CalResponse> getChanges(String path,
      {String syncToken = '', int depth = 1}) {
    var body = '''
    <d:sync-collection xmlns:d="DAV:">
      <d:sync-token>$syncToken</d:sync-token>
      <d:sync-level>1</d:sync-level>
      <d:prop>
        <d:getetag />
      </d:prop>
    </d:sync-collection>
    ''';

    return report(path, body, depth: depth);
  }

  /// calendar-multiget REPORT is used to retrieve specific calendar object resources
  /// from within a collection, if the Request- URI is a collection, or to retrieve
  /// a specific calendar object resource, if the Request-URI is a calendar object
  /// resource.
  Future<CalResponse> multiget(String path, List<String> hrefs,
      {int depth = 1}) {
    var body = '''
    <c:calendar-multiget xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav">
      <d:prop>
        <c:calendar-data>
          <c:expand start="19000101T000000Z" end="99991231T235959Z" />
        </c:calendar-data>
      </d:prop>
      <c:filter>
        <c:comp-filter name="VCALENDAR">
          <c:comp-filter name="VEVENT">
            <c:time-range start= "19000101T000000Z" end="99991231T235959Z" />
          </c:comp-filter>
        </c:comp-filter>
      </c:filter>
      ''' +
        hrefs.map((href) => '<d:href>$href</d:href>').join('\n') +
        '''
    </c:calendar-multiget>
    ''';

    return report(path, body, depth: depth);
  }
}
