// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchdata_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchData _$WatchDataFromJson(Map<String, dynamic> json) {
  return WatchData(
    connected: json['connected'] as bool,
    deviceId: json['deviceId'] as String,
    deviceName: json['deviceName'] as String,
    message: json['message'] as String,
    additionalInformation:
        (json['additionalInformation'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
  );
}

Map<String, dynamic> _$WatchDataToJson(WatchData instance) => <String, dynamic>{
      'connected': instance.connected,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'message': instance.message,
      'additionalInformation': instance.additionalInformation,
    };