import 'package:ceras/models/watchdata_model.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'devices_model.g.dart';

@JsonSerializable()
class DevicesModel {
  final Map<dynamic, dynamic> deviceMaster;
  WatchModel watchInfo;
  bool wifiConnected = false;

  DevicesModel({
    this.deviceMaster,
    this.watchInfo,
    this.wifiConnected,
  });

  factory DevicesModel.fromJson(Map<String, dynamic> json) =>
      _$DevicesModelFromJson(json);

  Map<String, dynamic> toJson() => _$DevicesModelToJson(this);
}
