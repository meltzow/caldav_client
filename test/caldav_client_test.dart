import 'dart:io';

import 'package:caldav_client/src/authorization.dart';
import 'package:caldav_client/src/caldav_client.dart';
import 'package:mock_web_server/mock_web_server.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('A group of tests', () {
    late CalDavClient client;
    late MockWebServer mockServer;

    final username = 'juli';
    final password = '1234';

    setUp(() async {
      mockServer = MockWebServer();
      await mockServer.start();

      client = CalDavClient(
          baseUrl: mockServer.url,
          headers: Authorization(username, password).basic());
    });

    tearDown(() {
      mockServer.shutdown();
    });

    test('Get calendars', () async {
      final file = File('./test/principal.xml');
      final document = XmlDocument.parse(file.readAsStringSync());

      var response = MockResponse()
        ..body = document
        ..httpCode = 207;

      mockServer.enqueueResponse(response);

      var response1 = await client.getPrincipal('/dav.php/calendars/juli');
      response1.body;

      // /remote.php/dav/principals/users/admin/

      var request = mockServer.takeRequest();
      expect(request.method, 'PROPFIND');
      expect(request.uri.path, '/dav.php/calendars/juli');
      expect(request.headers['depth'], '0');
      expect(request.headers['authorization'], isNotNull);
      expect(request.body, isNotNull);
    });

    test('Get events', () async {
      var response = MockResponse()
        ..body = ''
        ..httpCode = 207;

      mockServer.enqueueResponse(response);

      await client.getEvents('/dav.php/calendars/juli/default/', depth: 1);

      var request = mockServer.takeRequest();
      expect(request.method, 'REPORT');
      expect(request.uri.path, '/dav.php/calendars/juli/default/');
      expect(request.headers['depth'], '1');
      expect(request.headers['authorization'], isNotNull);
      expect(request.body, isNotNull);
    });

    test('Get events in time range', () async {
      var response = MockResponse()
        ..body = ''
        ..httpCode = 207;

      mockServer.enqueueResponse(response);

      var now = DateTime.now();
      var end = DateTime.utc(2021, 11, 9);

      await client.getEventsInTimeRange(
          '/dav.php/calendars/juli/default/', now, end,
          depth: 1);

      var request = mockServer.takeRequest();
      expect(request.method, 'REPORT');
      expect(request.uri.path, '/dav.php/calendars/juli/default/');
      expect(request.headers['depth'], '1');
      expect(request.headers['authorization'], isNotNull);
      expect(request.body, isNotNull);
    });

    test('Get Changes', () async {
      var response = MockResponse()
        ..body = ''
        ..httpCode = 207;

      mockServer.enqueueResponse(response);

      await client.getChanges('/dav.php/calendars/juli/default/', depth: 1);

      var request = mockServer.takeRequest();
      expect(request.method, 'REPORT');
      expect(request.uri.path, '/dav.php/calendars/juli/default/');
      expect(request.headers['depth'], '1');
      expect(request.headers['authorization'], isNotNull);
      expect(request.body, isNotNull);
    });

    test('Download Object', () async {
      mockServer.enqueue(body: 'test');

      await client.downloadIcs(
          '/dav.php/calendars/juli/default/test.ics', './test.ics');

      var request = mockServer.takeRequest();
      expect(request.method, 'GET');
      expect(request.uri.path, '/dav.php/calendars/juli/default/test.ics');
      expect(request.headers['authorization'], isNotNull);
      expect(request.body, '');

      var file = File('./test.ics');
      var textWrited = await file.readAsString();
      expect(textWrited, 'test');
      await file.delete();
    });

    test('Multiget', () async {
      var response = MockResponse()
        ..body = ''
        ..httpCode = 207;

      mockServer.enqueueResponse(response);

      var files = ['calendar.ics', 'test.ics'];

      await client.multiget('/dav.php/calendars/juli/default/', files);

      var request = mockServer.takeRequest();
      expect(request.method, 'REPORT');
      expect(request.uri.path, '/dav.php/calendars/juli/default/');
      expect(request.headers['depth'], '1');
      expect(request.headers['authorization'], isNotNull);
      expect(request.body, isNotNull);
    });

    test('Create Calendar', () async {
      var response = MockResponse()
        ..body = ''
        ..httpCode = 201;

      mockServer.enqueueResponse(response);

      await client.putCal('/dav.php/calendars/juli/default/123.ics', '');

      var request = mockServer.takeRequest();
      expect(request.method, 'PUT');
      expect(request.uri.path, '/dav.php/calendars/juli/default/123.ics');
      expect(request.headers['content-type'], 'text/calendar; charset=utf-8');
      expect(request.headers['authorization'], isNotNull);
      expect(request.body, isNotNull);
    });

    test('Update Calendar', () async {
      var response = MockResponse()
        ..body = ''
        ..httpCode = 204;

      mockServer.enqueueResponse(response);

      await client.updateCal('/dav.php/calendars/juli/default/test.ics',
          '4a8d9170f72c7e3327b85fda0ea2f7b0', '');

      var request = mockServer.takeRequest();
      expect(request.method, 'PUT');
      expect(request.uri.path, '/dav.php/calendars/juli/default/test.ics');
      expect(request.headers['content-type'], 'text/calendar; charset=utf-8');
      expect(request.headers['if-match'], '"4a8d9170f72c7e3327b85fda0ea2f7b0"');
      expect(request.headers['authorization'], isNotNull);
      expect(request.body, isNotNull);
    });

    test('Delete Calendar', () async {
      var response = MockResponse()
        ..body = ''
        ..httpCode = 204;

      mockServer.enqueueResponse(response);

      await client.deleteCal('/dav.php/calendars/juli/default/calendar.ics',
          '4a8d9170f72c7e3327b85fda0ea2f7b0');

      var request = mockServer.takeRequest();
      expect(request.method, 'DELETE');
      expect(request.uri.path, '/dav.php/calendars/juli/default/calendar.ics');
      expect(request.headers['if-match'], '"4a8d9170f72c7e3327b85fda0ea2f7b0"');
      expect(request.headers['authorization'], isNotNull);
      expect(request.body, '');
    });
  });
}
