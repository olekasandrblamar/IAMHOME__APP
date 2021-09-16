// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DevicesModel _$DevicesModelFromJson(Map<String, dynamic> json) {
  return DevicesModel(
    deviceMaster: json['deviceMaster'] as Map<String, dynamic>,
    watchInfo: json['watchInfo'] == null
        ? null
        : WatchModel.fromJson(json['watchInfo'] as Map<String, dynamic>),
    wifiConnected: json['wifiConnected'] == null?false:true,
  );
}

Map<String, dynamic> _$DevicesModelToJson(DevicesModel instance) =>
    <String, dynamic>{
      'deviceMaster': instance.deviceMaster,
      'watchInfo': instance.watchInfo,
      'wifiConnected': instance.wifiConnected,
    };
