import 'package:ceras/models/watchdata_model.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'devices_model.g.dart';

@JsonSerializable()
class DevicesModel {
  final Map<dynamic, dynamic> deviceMaster;
  WatchModel watchInfo;

  DevicesModel({
    this.deviceMaster,
    this.watchInfo,
  });

  factory DevicesModel.fromJson(Map<String, dynamic> json) =>
      _$DevicesModelFromJson(json);

  Map<String, dynamic> toJson() => _$DevicesModelToJson(this);
}
