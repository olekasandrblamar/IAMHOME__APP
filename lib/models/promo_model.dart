import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'promo_model.g.dart';

@JsonSerializable()
class PromoModel {
  final String environmentId;
  final bool active;
  final String environment;
  final String code;
  final String dataUrl;
  final String authUrl;
  final bool deleted;

  PromoModel({
    this.environmentId,
    this.active,
    this.environment,
    this.code,
    this.dataUrl,
    this.authUrl,
    this.deleted,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) =>
      _$PromoModelFromJson(json);

  Map<String, dynamic> toJson() => _$PromoModelToJson(this);
}
