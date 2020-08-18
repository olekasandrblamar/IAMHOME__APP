import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'devices_model.g.dart';

@JsonSerializable()
class DevicesModel {
  final Map<dynamic, dynamic> deviceMaster;

  DevicesModel({
    this.deviceMaster,
  });

  factory DevicesModel.fromJson(Map<String, dynamic> json) =>
      _$DevicesModelFromJson(json);

  Map<String, dynamic> toJson() => _$DevicesModelToJson(this);
}
