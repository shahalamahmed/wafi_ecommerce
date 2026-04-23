import 'package:cloud_firestore/cloud_firestore.dart';

String readString(
  Map<String, dynamic> data,
  String key, {
  String fallback = '',
}) {
  final value = data[key];
  if (value == null) return fallback;
  return value.toString();
}

int readInt(Map<String, dynamic> data, String key, {int fallback = 0}) {
  final value = data[key];
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is num) return value.toInt();
  return fallback;
}

double readDouble(
  Map<String, dynamic> data,
  String key, {
  double fallback = 0,
}) {
  final value = data[key];
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return fallback;
}

bool readBool(Map<String, dynamic> data, String key, {bool fallback = false}) {
  final value = data[key];
  if (value is bool) return value;
  return fallback;
}

List<String> readStringList(
  Map<String, dynamic> data,
  String key, {
  List<String> fallback = const [],
}) {
  final value = data[key];
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return fallback;
}

Map<String, dynamic> readMap(
  Map<String, dynamic> data,
  String key, {
  Map<String, dynamic> fallback = const {},
}) {
  final value = data[key];
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.from(value);
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return Map<String, dynamic>.from(fallback);
}

DateTime? readDateTime(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
