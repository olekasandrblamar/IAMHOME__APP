// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackerData _$TrackerDataFromJson(Map<String, dynamic> json) {
  return TrackerData(
    data: (json['data'] as num)?.toDouble(),
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
    data1: (json['data1'] as num)?.toDouble(),
    data2: (json['data2'] as num)?.toDouble(),
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
    mobileDisplay: json['mobileDisplay'] as bool,
    mobileMeasureNow: json['mobileMeasureNow'] as bool
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
      'mobileDisplay': instance.mobileDisplay,
      'mobileMeasureNow': instance.mobileMeasureNow
    };

TrackerValues _$TrackerValuesFromJson(Map<String, dynamic> json) {
  return TrackerValues(
    id: json['id'] as int,
    displayName: json['displayName'] as String,
    valueName: json['valueName'] as String,
    baseLineMin: (json['baseLineMin'] as num)?.toDouble(),
    baseLineMax: (json['baseLineMax'] as num)?.toDouble(),
    minValue: (json['minValue'] as num)?.toDouble(),
    maxValue: (json['maxValue'] as num)?.toDouble(),
    baseSeverity: (json['baseSeverity'] as num)?.toDouble(),
    units: json['units'] as String,
    offset: (json['offset'] as num)?.toDouble(),
    unitsDisplayName: json['unitsDisplayName'] as String,
    severities: (json['severities'] as List)
        ?.map((e) =>
            e == null ? null : Severities.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    order: json['order'] as int,
    dataPropertyName: json['dataPropertyName'] as String,
    valueDataType: json['valueDataType'] as String,
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
      'valueDataType': instance.valueDataType,
    };

Severities _$SeveritiesFromJson(Map<String, dynamic> json) {
  return Severities(
    id: json['id'] as int,
    minValue: (json['minValue'] as num)?.toDouble(),
    maxValue: (json['maxValue'] as num)?.toDouble(),
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
