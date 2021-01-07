import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'currentversion_model.g.dart';

@JsonSerializable()
class CurrentversionModel {
  final String releaseId;
  final bool active;
  final String updatedAt;
  final String iosVersion;
  final String androidVersion;
  final String effectiveDate;

  CurrentversionModel({
    this.releaseId,
    this.active,
    this.updatedAt,
    this.iosVersion,
    this.androidVersion,
    this.effectiveDate,
  });

  factory CurrentversionModel.fromJson(Map<String, dynamic> json) =>
      _$CurrentversionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentversionModelToJson(this);
}
