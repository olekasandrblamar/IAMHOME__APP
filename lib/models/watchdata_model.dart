import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'watchdata_model.g.dart';

@JsonSerializable()
class WatchModel {
  bool connected;
  final String deviceId;
  final String deviceName;
  final String message;
  String deviceType;
  final bool deviceFound;
  String batteryStatus;
  String connectionStatus;
  final Map<String, String> additionalInformation;
  final bool upgradeAvailable;
  bool connectionPending;

  WatchModel({
    this.connected,
    @required this.deviceId,
    this.deviceName,
    this.message,
    this.additionalInformation,
    this.deviceType,
    this.deviceFound,
    this.batteryStatus,
    this.upgradeAvailable
  });

  factory WatchModel.fromJson(Map<String, dynamic> json) =>
      _$WatchModelFromJson(json);

  Map<String, dynamic> toJson() => _$WatchModelToJson(this);
}
