import 'package:json_annotation/json_annotation.dart';

part 'tracker_data_model.g.dart';

@JsonSerializable()
class Temperature{

  double fahrenheit = 0;
  double celsius = 0;
  DateTime measureTime;
  String deviceId;

  Temperature({
    this.fahrenheit,
    this.celsius,
    this.measureTime,
    this.deviceId
  });

  factory Temperature.fromJson(Map<String, dynamic> json) =>
      _$TemperatureFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureToJson(this);

}

@JsonSerializable()
class OxygenLevel{
  DateTime measureTime;
  String deviceId;
  int oxygenLevel = 0;

  OxygenLevel({
    this.oxygenLevel,
    this.measureTime,
    this.deviceId
  });

  factory OxygenLevel.fromJson(Map<String, dynamic> json) =>
      _$OxygenLevelFromJson(json);

  Map<String, dynamic> toJson() => _$OxygenLevelToJson(this);

}

@JsonSerializable()
class BloodPressure{
  DateTime measureTime;
  String deviceId;
  int distolic = 0;
  int systolic = 0;

  BloodPressure({
    this.distolic,
    this.systolic,
    this.measureTime,
    this.deviceId
  });

  factory BloodPressure.fromJson(Map<String, dynamic> json) =>
      _$BloodPressureFromJson(json);

  Map<String, dynamic> toJson() => _$BloodPressureToJson(this);
}

@JsonSerializable()
class HeartRate{

  DateTime measureTime;
  String deviceId;
  int heartRate = 0;

  HeartRate({
    this.heartRate,
    this.measureTime,
    this.deviceId
  });

  factory HeartRate.fromJson(Map<String, dynamic> json) =>
      _$HeartRateFromJson(json);

  Map<String, dynamic> toJson() => _$HeartRateToJson(this);

}

@JsonSerializable()
class DailySteps{
  DateTime measureTime;
  String deviceId;
  int steps = 0;

  DailySteps({
    this.steps,
    this.measureTime,
    this.deviceId
  });

  factory DailySteps.fromJson(Map<String, dynamic> json) =>
      _$DailyStepsFromJson(json);

  Map<String, dynamic> toJson() => _$DailyStepsToJson(this);
}

@JsonSerializable()
class Calories{
  DateTime measureTime;
  String deviceId;
  int calories = 0;

  Calories({
    this.calories,
    this.measureTime,
    this.deviceId
  });

  factory Calories.fromJson(Map<String, dynamic> json) =>
      _$CaloriesFromJson(json);

  Map<String, dynamic> toJson() => _$CaloriesToJson(this);

}