import 'todo.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Cache {
  //returns Todo box
  static Box<Todo> _getTodoBox() {
    return Hive.box<Todo>('todos');
  }

  //return list of Todos
  static List<Todo> getTodos() {
    Box<Todo> box = _getTodoBox();
    return box.values.toList();
  }

  //update Todo
  static updateTodo(Todo todo) {
    Box<Todo> box = _getTodoBox();
    box.putAt(box.keys.toList().indexOf(todo.id), todo);
  }

  //add Todo
  static void addTodo(Todo todo) {
    Box<Todo> box = _getTodoBox();
    if (todo.date.isUtc == false) {
      todo.date = todo.date.toUtc();
    }
    box.put(todo.id, todo);
  }

  //delete Todo
  static void deleteTodo(String id) {
    Box<Todo> box = _getTodoBox();
    box.deleteAt(box.keys.toList().indexOf(id));
  }

  //delete all Todos
  static void deleteAll() {
    Box<Todo> box = _getTodoBox();
    List<dynamic> keys = box.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      box.deleteAt(box.keys.toList().indexOf(keys[i]));
    }
  }

  //add list of Todos
  static void addAll(List<Todo> todos) {
    Box<Todo> box = _getTodoBox();
    for (int i = 0; i < todos.length; i++) {
      box.put(todos[i].id, todos[i]);
    }
  }

  //delete all done Todos
  static void deleteAllDone() {
    Box<Todo> box = _getTodoBox();
    List<String> keys = box.values
        .where((element) => element.done)
        .map((element) => element.id)
        .toList();
    for (int i = 0; i < keys.length; i++) {
      box.deleteAt(box.keys.toList().indexOf(keys[i]));
    }
  }

  //delete all undone Todos
  static void deleteAllUndone() {
    Box<Todo> box = _getTodoBox();
    List<String> keys = box.values
        .where((element) => element.done == false)
        .map((element) => element.id)
        .toList();
    for (int i = 0; i < keys.length; i++) {
      box.deleteAt(box.keys.toList().indexOf(keys[i]));
    }
  }

  //delete all Todos and add new Todos
  static void import(List<Todo> newTodos) {
    Box<Todo> box = _getTodoBox();
    List<Todo> todos = box.values.toList();
    for (int i = 0; i < newTodos.length; i++) {
      if (todos.where((element) => element.id == newTodos[i].id).isEmpty) {
        todos.add(newTodos[i]);
      }
    }
    deleteAll();
    addAll(todos);
  }
}
