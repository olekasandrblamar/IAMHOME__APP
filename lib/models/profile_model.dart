import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  final int age;
  final double weightInKgs;
  final double heightInCm;
  final String sex;
  final String email;

  ProfileModel({
    this.age,
    this.weightInKgs,
    this.heightInCm,
    this.sex,
    this.email,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
