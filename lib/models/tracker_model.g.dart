// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackerData _$TrackerDataFromJson(Map<String, dynamic> json) {
  return TrackerData(
    data: json['data'] as int,
    measureTime: json['measureTime'] == null
        ? null
        : DateTime.parse(json['measureTime'] as String),
    deviceId: json['deviceId'] as String,
  );
}

Map<String, dynamic> _$TrackerDataToJson(TrackerData instance) =>
    <String, dynamic>{
      'measureTime': instance.measureTime?.toIso8601String(),
      'deviceId': instance.deviceId,
      'data': instance.data,
    };

TrackerDataMultiple _$TrackerDataMultipleFromJson(Map<String, dynamic> json) {
  return TrackerDataMultiple(
    data1: json['data1'] as int,
    data2: json['data2'] as int,
    measureTime: json['measureTime'] == null
        ? null
        : DateTime.parse(json['measureTime'] as String),
    deviceId: json['deviceId'] as String,
  );
}

Map<String, dynamic> _$TrackerDataMultipleToJson(
        TrackerDataMultiple instance) =>
    <String, dynamic>{
      'measureTime': instance.measureTime?.toIso8601String(),
      'deviceId': instance.deviceId,
      'data1': instance.data1,
      'data2': instance.data2,
    };

Tracker _$TrackerFromJson(Map<String, dynamic> json) {
  return Tracker(
    id: json['id'] as int,
    displayName: json['displayName'] as String,
    trackerName: json['trackerName'] as String,
    trackerType: json['trackerType'] as String,
    graphType: json['graphType'] as String,
    trackerValues: (json['trackerValues'] as List)
        ?.map((e) => e == null
            ? null
            : TrackerValues.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    deleted: json['deleted'] as bool,
    active: json['active'] as bool,
  );
}

Map<String, dynamic> _$TrackerToJson(Tracker instance) => <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'trackerName': instance.trackerName,
      'trackerType': instance.trackerType,
      'graphType': instance.graphType,
      'trackerValues': instance.trackerValues,
      'deleted': instance.deleted,
      'active': instance.active,
    };

TrackerValues _$TrackerValuesFromJson(Map<String, dynamic> json) {
  return TrackerValues(
    id: json['id'] as int,
    displayName: json['displayName'] as String,
    valueName: json['valueName'] as String,
    baseLineMin: json['baseLineMin'] as int,
    baseLineMax: json['baseLineMax'] as int,
    minValue: json['minValue'] as int,
    maxValue: json['maxValue'] as int,
    baseSeverity: json['baseSeverity'] as int,
    units: json['units'] as String,
    offset: json['offset'] as int,
    unitsDisplayName: json['unitsDisplayName'] as String,
    severities: (json['severities'] as List)
        ?.map((e) =>
            e == null ? null : Severities.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    order: json['order'] as int,
    dataPropertyName: json['dataPropertyName'] as String,
  );
}

Map<String, dynamic> _$TrackerValuesToJson(TrackerValues instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'valueName': instance.valueName,
      'baseLineMin': instance.baseLineMin,
      'baseLineMax': instance.baseLineMax,
      'minValue': instance.minValue,
      'maxValue': instance.maxValue,
      'baseSeverity': instance.baseSeverity,
      'units': instance.units,
      'offset': instance.offset,
      'unitsDisplayName': instance.unitsDisplayName,
      'severities': instance.severities,
      'order': instance.order,
      'dataPropertyName': instance.dataPropertyName,
    };

Severities _$SeveritiesFromJson(Map<String, dynamic> json) {
  return Severities(
    id: json['id'] as int,
    minValue: json['minValue'] as int,
    maxValue: json['maxValue'] as int,
    severity: json['severity'] as int,
  );
}

Map<String, dynamic> _$SeveritiesToJson(Severities instance) =>
    <String, dynamic>{
      'id': instance.id,
      'minValue': instance.minValue,
      'maxValue': instance.maxValue,
      'severity': instance.severity,
    };
