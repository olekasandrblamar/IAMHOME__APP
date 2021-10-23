import 'package:json_annotation/json_annotation.dart';

part 'tracker_model.g.dart';

@JsonSerializable()
class TrackerData {
  DateTime measureTime;
  String deviceId;
  double data = 0;

  TrackerData({this.data, this.measureTime, this.deviceId});

  factory TrackerData.fromJson(Map<String, dynamic> json) =>
      _$TrackerDataFromJson(json);

  Map<String, dynamic> toJson() => _$TrackerDataToJson(this);
}

@JsonSerializable()
class TrackerDataMultiple {
  DateTime measureTime;
  String deviceId;
  double data1 = 0;
  double data2 = 0;

  TrackerDataMultiple(
      {this.data1, this.data2, this.measureTime, this.deviceId});

  factory TrackerDataMultiple.fromJson(Map<String, dynamic> json) =>
      _$TrackerDataMultipleFromJson(json);

  Map<String, dynamic> toJson() => _$TrackerDataMultipleToJson(this);
}

@JsonSerializable()
class Tracker {
  int id;
  String displayName;
  String trackerName;
  String trackerType;
  String graphType;
  List<TrackerValues> trackerValues;
  bool deleted;
  bool active;
  bool mobileDisplay;
  bool mobileMeasureNow;

  Tracker(
      {this.id,
      this.displayName,
      this.trackerName,
      this.trackerType,
      this.graphType,
      this.trackerValues,
      this.deleted,
      this.active,
      this.mobileDisplay,
      this.mobileMeasureNow});

  factory Tracker.fromJson(Map<String, dynamic> json) =>
      _$TrackerFromJson(json);

  Map<String, dynamic> toJson() => _$TrackerToJson(this);
}

@JsonSerializable()
class TrackerValues {
  int id;
  String displayName;
  String valueName;
  double baseLineMin;
  double baseLineMax;
  double minValue;
  double maxValue;
  double baseSeverity;
  String units;
  double offset;
  String unitsDisplayName;
  List<Severities> severities;
  int order;
  String dataPropertyName;
  String valueDataType;

  TrackerValues(
      {this.id,
      this.displayName,
      this.valueName,
      this.baseLineMin,
      this.baseLineMax,
      this.minValue,
      this.maxValue,
      this.baseSeverity,
      this.units,
      this.offset,
      this.unitsDisplayName,
      this.severities,
      this.order,
      this.dataPropertyName,
      this.valueDataType});

  factory TrackerValues.fromJson(Map<String, dynamic> json) =>
      _$TrackerValuesFromJson(json);

  Map<String, dynamic> toJson() => _$TrackerValuesToJson(this);
}

@JsonSerializable()
class Severities {
  int id;
  double minValue;
  double maxValue;
  int severity;

  Severities({this.id, this.minValue, this.maxValue, this.severity});

  factory Severities.fromJson(Map<String, dynamic> json) =>
      _$SeveritiesFromJson(json);

  Map<String, dynamic> toJson() => _$SeveritiesToJson(this);
}
