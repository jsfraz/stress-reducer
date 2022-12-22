import 'todo.dart';
import 'cache.dart';
import 'todo_widget.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'tools.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  final String title = 'Stress Reducer';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Todo> todos;

  List<MenuOption> options = [
    //TODO add import/export
    /*
    MenuOption('exportTodos'.tr(), Colors.black, Tools.exportAll),
    MenuOption('importTodos'.tr(), Colors.black, Tools.import),
    MenuOption(
        'importAndReplaceTodos'.tr(), Colors.red, Tools.importAndReplace),
    */
    MenuOption('deleteDoneTodos'.tr(), Colors.red, Tools.deleteAllDone),
    MenuOption('deleteUndoneTodos'.tr(), Colors.red, Tools.deleteAllUndone),
    MenuOption('deleteAllTodos'.tr(), Colors.red, Tools.deleteAll)
  ];

  @override
  void initState() {
    super.initState();
    //laod Todos
    todos = Cache.getTodos();
  }

  //page refresh
  void refersh() {
    setState(() {
      todos = Cache.getTodos();
    });
  }

  //scroll widgets
  List<Widget> getWidgetList(List<Todo> todoList) {
    List<Widget> widgetList = [];
    widgetList.add(const Padding(padding: EdgeInsets.only(top: 10)));
    for (int i = 0; i < todoList.length; i++) {
      widgetList.add(TodoWidget(todoList[i], refersh));
    }
    return widgetList;
  }

  //dialog for adding new Todo
  Future<bool> _addDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          final TextEditingController controllerName = TextEditingController();
          final TextEditingController controllerDate = TextEditingController();
          bool nameOk = false;
          bool nameEditing = false;
          bool dateOk = false;
          bool dateEditing = false;
          DateTime dateTime = DateTime.now();

          String? errorName() {
            if ((controllerName.text.isEmpty) && nameEditing) {
              return 'shortName'.tr();
            }
            //valid
            if (controllerName.text.isNotEmpty) {
              nameOk = true;
            }
            return null;
          }

          String? errorDate() {
            if ((controllerDate.text.isEmpty) && dateEditing) {
              return 'emptyDate'.tr();
            }
            //invalid
            if (controllerDate.text.isNotEmpty) {
              dateOk = true;
            }
            return null;
          }

          //add Todo
          void addTodo() {
            if (nameOk && dateOk) {
              Cache.addTodo(Todo(
                  Tools.generateUuid(), controllerName.text, false, dateTime));
              Navigator.pop(context, true);
            }
          }

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('newTodo'.tr()),
              content: SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controllerName,
                      onChanged: (_) => setState(() {
                        nameEditing = true;
                      }),
                      decoration: InputDecoration(
                          errorText: errorName(), hintText: 'todoName'.tr()),
                    ),
                    //https://mobikul.com/date-picker-in-flutter/
                    TextField(
                        controller: controllerDate,
                        onChanged: (_) => setState(() {
                              dateEditing = true;
                            }),
                        decoration: InputDecoration(
                            errorText: errorDate(),
                            icon: const Icon(Icons.calendar_today),
                            labelText: 'todoDate'.tr()),
                        readOnly: true,
                        onTap: () async {
                          setState(() {
                            dateEditing = true;
                          });
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime(2100));

                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            dateTime = pickedDate;

                            setState(() {
                              controllerDate.text = formattedDate;
                            });
                          }
                        }),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35)),
                          ),
                        ),
                        onPressed: addTodo,
                        child: Padding(
                          padding: EdgeInsets.all(7),
                          child: Text(
                            'newTodo'.tr(),
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        }).then((value) {
      if (value == null) {
        return false;
      } else {
        if (value) {
          Tools.showInfo('todoCreated'.tr(), context);
        }
        return value;
      }
    });
    //https://www.codegrepper.com/code-examples/dart/flutter+get+value+from+dialog+on+close
  }

  //https://stackoverflow.com/questions/58144948/easiest-way-to-add-3-dot-pop-up-menu-appbar-in-flutter
  handleClick(MenuOption option) async {
    bool refresh = await option.function.call();
    if (refresh) {
      refersh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            PopupMenuButton<MenuOption>(
              tooltip: 'optionsMenu'.tr(),
              onSelected: handleClick,
              itemBuilder: (BuildContext context) =>
                  options.map((MenuOption e) {
                return PopupMenuItem<MenuOption>(
                  value: e,
                  child: Text(e.name, style: TextStyle(color: e.color)),
                );
              }).toList(),
            ),
          ],
          title: Text(widget.title),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'undoneTodos'.tr(),
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Tab(
                child: Text(
                  'doneTodos'.tr(),
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          foregroundColor: const Color.fromARGB(255, 0, 90, 149),
          backgroundColor: Colors.white,
          onPressed: () async {
            bool refresh = await _addDialog(context);
            if (refresh) {
              refersh();
            }
          },
          tooltip: 'newTodo'.tr(),
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Flexible(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: getWidgetList(todos
                          .where((element) => element.done == false)
                          .toList()
                        ..sort((e1, e2) => e1.date.compareTo(e2.date))),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Flexible(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: getWidgetList(
                          todos.where((element) => element.done).toList()
                            ..sort((e1, e2) => e2.date.compareTo(e1.date))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
