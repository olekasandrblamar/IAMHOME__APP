import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'watchdata_model.g.dart';

@JsonSerializable()
class WatchData {
  final bool connected;
  final String deviceId;
  final String deviceName;
  final String message;
  final Map<String, String> additionalInformation;

  WatchData({
    this.connected,
    @required this.deviceId,
    this.deviceName,
    this.message,
    this.additionalInformation,
  });

  factory WatchData.fromJson(Map<String, dynamic> json) =>
      _$WatchDataFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataToJson(this);
}
