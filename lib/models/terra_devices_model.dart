import 'package:ceras/models/watchdata_model.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class TerraDevicesModel {
  String imageUrl;
  String deviceName;

  TerraDevicesModel({
    this.imageUrl,
    this.deviceName,
  });
}
