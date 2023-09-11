String trim(String str, [String? chars]) {
  var pattern =
      (chars != null) ? RegExp('^[$chars]+|[$chars]+\$') : RegExp(r'^\s+|\s+$');
  return str.replaceAll(pattern, '');
}

String ltrim(String str, [String? chars]) {
  var pattern = chars != null ? RegExp('^[$chars]+') : RegExp(r'^\s+');
  return str.replaceAll(pattern, '');
}

String rtrim(String str, [String? chars]) {
  var pattern = chars != null ? RegExp('[$chars]+\$') : RegExp(r'\s+$');
  return str.replaceAll(pattern, '');
}

String join(String path0, String path1) {
  return rtrim(path0, '/') + '/' + ltrim(path1, '/');
}

String stringify(DateTime dateTime) {
  return '${dateTime.toUtc().toIso8601String().substring(0, 19).replaceAll(RegExp('[-:]'), '')}Z';
}
