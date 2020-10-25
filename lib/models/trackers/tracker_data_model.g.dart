// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Temperature _$TemperatureFromJson(Map<String, dynamic> json) {
  return Temperature(
    fahrenheit: (json['fahrenheit'] as num)?.toDouble(),
    celsius: (json['celsius'] as num)?.toDouble(),
    measureTime: json['measureTime'] == null
        ? null
        : DateTime.parse(json['measureTime'] as String),
    deviceId: json['deviceId'] as String,
  );
}

Map<String, dynamic> _$TemperatureToJson(Temperature instance) =>
    <String, dynamic>{
      'fahrenheit': instance.fahrenheit,
      'celsius': instance.celsius,
      'measureTime': instance.measureTime?.toIso8601String(),
      'deviceId': instance.deviceId,
    };

OxygenLevel _$OxygenLevelFromJson(Map<String, dynamic> json) {
  return OxygenLevel(
    oxygenLevel: json['oxygenLevel'] as int,
    measureTime: json['measureTime'] == null
        ? null
        : DateTime.parse(json['measureTime'] as String),
    deviceId: json['deviceId'] as String,
  );
}

Map<String, dynamic> _$OxygenLevelToJson(OxygenLevel instance) =>
    <String, dynamic>{
      'measureTime': instance.measureTime?.toIso8601String(),
      'deviceId': instance.deviceId,
      'oxygenLevel': instance.oxygenLevel,
    };

BloodPressure _$BloodPressureFromJson(Map<String, dynamic> json) {
  return BloodPressure(
    distolic: json['distolic'] as int,
    systolic: json['systolic'] as int,
    measureTime: json['measureTime'] == null
        ? null
        : DateTime.parse(json['measureTime'] as String),
    deviceId: json['deviceId'] as String,
  );
}

Map<String, dynamic> _$BloodPressureToJson(BloodPressure instance) =>
    <String, dynamic>{
      'measureTime': instance.measureTime?.toIso8601String(),
      'deviceId': instance.deviceId,
      'distolic': instance.distolic,
      'systolic': instance.systolic,
    };

HeartRate _$HeartRateFromJson(Map<String, dynamic> json) {
  return HeartRate(
    heartRate: json['heartRate'] as int,
    measureTime: json['measureTime'] == null
        ? null
        : DateTime.parse(json['measureTime'] as String),
    deviceId: json['deviceId'] as String,
  );
}

Map<String, dynamic> _$HeartRateToJson(HeartRate instance) => <String, dynamic>{
      'measureTime': instance.measureTime?.toIso8601String(),
      'deviceId': instance.deviceId,
      'heartRate': instance.heartRate,
    };

DailySteps _$DailyStepsFromJson(Map<String, dynamic> json) {
  return DailySteps(
    steps: json['steps'] as int,
    measureTime: json['measureTime'] == null
        ? null
        : DateTime.parse(json['measureTime'] as String),
    deviceId: json['deviceId'] as String,
  );
}

Map<String, dynamic> _$DailyStepsToJson(DailySteps instance) =>
    <String, dynamic>{
      'measureTime': instance.measureTime?.toIso8601String(),
      'deviceId': instance.deviceId,
      'steps': instance.steps,
    };

Calories _$CaloriesFromJson(Map<String, dynamic> json) {
  return Calories(
    calories: json['calories'] as int,
    measureTime: json['measureTime'] == null
        ? null
        : DateTime.parse(json['measureTime'] as String),
    deviceId: json['deviceId'] as String,
  );
}

Map<String, dynamic> _$CaloriesToJson(Calories instance) => <String, dynamic>{
      'measureTime': instance.measureTime?.toIso8601String(),
      'deviceId': instance.deviceId,
      'calories': instance.calories,
    };
