import 'dart:io';
import '../todo.dart';
import 'home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  //hive initialization
  Directory directory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter('${directory.path}/StressReducer');
  //hive adapters
  Hive.registerAdapter(TodoAdapter());
  //hive boxes
  await Hive.openBox<Todo>('todos');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('cs')],
      path: 'asset/translations',
      fallbackLocale: const Locale('en'),
      child: const StressReducer(),
    ),
  );
}

class StressReducer extends StatelessWidget {
  const StressReducer({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Stress Reducer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 72, 119),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const MyHomePage(),
    );
  }
}
