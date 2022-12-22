import 'cache.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

//flutter pub run build_runner build

@JsonSerializable()
@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  bool done;
  @HiveField(3)
  DateTime date;

  Todo(this.id, this.name, this.done, this.date);

  Map<String, dynamic> toJson() => _$TodoToJson(this);

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  //update
  update() {
    Cache.updateTodo(this);
  }
}
