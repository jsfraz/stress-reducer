import 'dart:io';
import 'dart:convert';
import '../todo.dart';
import '../cache.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Tools {
  //generates uuid
  static String generateUuid() {
    return const Uuid().v4();
  }

  //toast
  static void showToast(String text, Color color) {
    Fluttertoast.showToast(msg: text, backgroundColor: color);
  }

  //snackbar
  static void showSnackBar(String text, Color color, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: color));
  }

  //toast/snack
  static void showInfo(String text, BuildContext context) {
    //android/ios
    if (Platform.isAndroid || Platform.isIOS) {
      Tools.showToast(text, const Color.fromARGB(192, 76, 76, 76));
    }
    //other
    if (Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS ||
        Platform.isFuchsia) {
      Tools.showSnackBar(text, const Color.fromARGB(255, 76, 76, 76), context);
    }
  }

  //https://pub.dev/packages/file_picker
  static Future<bool> importAndReplace() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        lockParentWindow: true);
    if (result != null) {
      try {
        String json = File(result.paths[0]!).readAsStringSync();
        //https://stackoverflow.com/questions/51053954/how-to-deserialize-a-list-of-objects-from-json-in-flutter
        Iterable l = jsonDecode(json);
        List<Todo> todos =
            List<Todo>.from(l.map((model) => Todo.fromJson(model)));
        Cache.deleteAll();
        Cache.addAll(todos);
        return true;
      } catch (e) {
        //chyba
        debugPrint(e.toString());
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<bool> import() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        lockParentWindow: true);
    if (result != null) {
      try {
        String json = File(result.paths[0]!).readAsStringSync();
        //https://stackoverflow.com/questions/51053954/how-to-deserialize-a-list-of-objects-from-json-in-flutter
        Iterable l = jsonDecode(json);
        List<Todo> todos =
            List<Todo>.from(l.map((model) => Todo.fromJson(model)));
        Cache.import(todos);
        return true;
      } catch (e) {
        //chyba
        debugPrint(e.toString());
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<bool> exportAll() async {
    List<Todo> todos = Cache.getTodos();
    if (todos.isNotEmpty) {
      String name = 'úkoly';
      String? result =
          await FilePicker.platform.getDirectoryPath(lockParentWindow: true);
      if (result != null) {
        try {
          String json = jsonEncode(todos);
          File file = File('$result/$name.json');
          if (await file.exists()) {
            file = File('$result/$name(1).json');
          }
          await file.writeAsString(json);
        } catch (e) {
          //error
          debugPrint(e.toString());
        }
      }
    }
    return false;
  }

  static Future<bool> deleteAllDone() async {
    Cache.deleteAllDone();
    return true;
  }

  static Future<bool> deleteAllUndone() async {
    Cache.deleteAllUndone();
    return true;
  }

  static Future<bool> deleteAll() async {
    Cache.deleteAll();
    return true;
  }
}

class MenuOption {
  String name;
  Color color;
  Future<bool> Function() function;

  MenuOption(this.name, this.color, this.function);
}
