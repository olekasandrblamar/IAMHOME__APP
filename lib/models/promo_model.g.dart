// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromoModel _$PromoModelFromJson(Map<String, dynamic> json) {
  return PromoModel(
    environmentId: json['environmentId'] as String,
    active: json['active'] as bool,
    environment: json['environment'] as String,
    code: json['code'] as String,
    dataUrl: json['dataUrl'] as String,
    authUrl: json['authUrl'] as String,
    deleted: json['deleted'] as bool,
  );
}

Map<String, dynamic> _$PromoModelToJson(PromoModel instance) =>
    <String, dynamic>{
      'environmentId': instance.environmentId,
      'active': instance.active,
      'environment': instance.environment,
      'code': instance.code,
      'dataUrl': instance.dataUrl,
      'authUrl': instance.authUrl,
      'deleted': instance.deleted,
    };
