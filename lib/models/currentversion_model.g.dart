// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currentversion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentversionModel _$CurrentversionModelFromJson(Map<String, dynamic> json) {
  return CurrentversionModel(
    releaseId: json['releaseId'] as String,
    active: json['active'] as bool,
    updatedAt: json['updatedAt'] as String,
    iosVersion: json['iosVersion'] as String,
    androidVersion: json['androidVersion'] as String,
    effectiveDate: json['effectiveDate'] as String,
  );
}

Map<String, dynamic> _$CurrentversionModelToJson(
        CurrentversionModel instance) =>
    <String, dynamic>{
      'releaseId': instance.releaseId,
      'active': instance.active,
      'updatedAt': instance.updatedAt,
      'iosVersion': instance.iosVersion,
      'androidVersion': instance.androidVersion,
      'effectiveDate': instance.effectiveDate,
    };
