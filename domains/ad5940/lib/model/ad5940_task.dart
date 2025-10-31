part of '../ad5940.dart';

@CopyWith()
@JsonSerializable()
class AD5940Task with EquatableMixin {
  final List<Ad5940Command> commands;

  final List<AD5940Result> results;

  AD5940Task({required this.commands, required this.results});

  @override
  List<Object?> get props => [commands, results];

  factory AD5940Task.fromJson(Map<String, dynamic> json) =>
      _$AD5940TaskFromJson(json);

  // @override
  Map<String, dynamic> toJson() => _$AD5940TaskToJson(this);
  // 目前不需要 _toJson，因為 AD5940Task 沒有被包在其他類別的 @JsonKey 中
  // 如果未來需要類似 SeatCushionSet 的容器類別，可以取消註釋
  // static Map<String, dynamic> _toJson(AD5940Task seatCushion) =>
  //     seatCushion.toJson();
}

extension AD5940TaskList on List<AD5940Task> {
  Iterable<Map<String, dynamic>> ad5940TasksToJson() => map((r) => r.toJson());
  String ad5940TasksJsonEncode() =>
      "[${map((r) => jsonEncode(r.toJson())).join(",")}]";
}

extension AD5940TaskString on String {
  Iterable<AD5940Task> ad5940TasksJsonDecode() =>
      (jsonDecode(this) as Iterable<dynamic>).map(
        (e) => AD5940Task.fromJson(e),
      );
}
