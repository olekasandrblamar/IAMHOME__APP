// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) {
  return ProfileModel(
    age: json['age'] as int,
    weightInKgs: (json['weightInKgs'] as num)?.toDouble(),
    heightInCm: (json['heightInCm'] as num)?.toDouble(),
    sex: json['sex'] as String,
    email: json['email'] as String,
  );
}

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'age': instance.age,
      'weightInKgs': instance.weightInKgs,
      'heightInCm': instance.heightInCm,
      'sex': instance.sex,
      'email': instance.email,
    };
