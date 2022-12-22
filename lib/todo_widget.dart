import 'todo.dart';
import 'tools.dart';
import 'cache.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

//update of parent widget https://stackoverflow.com/questions/48481590/how-to-set-update-state-of-statefulwidget-from-other-statefulwidget-in-flutter

class TodoWidget extends StatefulWidget {
  final Todo todo;
  final Function() notifyParent;

  @override
  State<TodoWidget> createState() => _TodoWidgetState();

  const TodoWidget(this.todo, this.notifyParent, {Key? key}) : super(key: key);
}

class _TodoWidgetState extends State<TodoWidget> {
  static const int _animationDelay = 300;

  Future<bool> _editDialog() async {
    return await showDialog(
        context: context,
        builder: (context) {
          final TextEditingController controllerName = TextEditingController();
          final TextEditingController controllerDate = TextEditingController();
          bool nameOk = false;
          bool nameEditing = false;
          bool dateOk = false;
          bool dateEditing = false;

          bool textInitialized = false;

          String? errorName() {
            //this "replacement" of initState
            if (textInitialized == false) {
              textInitialized = true;
              controllerName.text = widget.todo.name;
              controllerDate.text =
                  DateFormat('yyyy-MM-dd').format(widget.todo.date.toLocal());
            }

            //invalid
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
            //neshoda
            if (controllerDate.text.isNotEmpty) {
              dateOk = true;
            }
            return null;
          }

          //update Todo
          void updateTodo() {
            if (nameOk && dateOk) {
              Cache.addTodo(Todo(widget.todo.id, controllerName.text,
                  widget.todo.done, widget.todo.date.toLocal()));
              Tools.showInfo('todoUpdated'.tr(), context);
              Navigator.pop(context, true);
            }
          }

          //delete Todo
          void deleteTodo() {
            Cache.deleteTodo(widget.todo.id);
            Tools.showInfo('todoDeleted'.tr(), context);
            Navigator.pop(context, true);
          }

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Upravit'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text('doneTodo'.tr()),
                        Checkbox(
                          value: widget.todo.done,
                          onChanged: (_) {
                            setState(() {
                              widget.todo.done = !widget.todo.done;
                            });
                          },
                          fillColor: MaterialStateProperty.resolveWith(
                              getCheckboxColorForm),
                          checkColor: const Color.fromARGB(255, 0, 90, 149),
                        ),
                      ],
                    ),
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
                              initialDate: widget.todo.date.toLocal(),
                              firstDate: DateTime(1970),
                              lastDate: DateTime(2970));

                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            widget.todo.date = pickedDate.toUtc();

                            setState(() {
                              controllerDate.text = formattedDate;
                            });
                          }
                        }),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 5,
                            ),
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35)),
                                ),
                              ),
                              onPressed: updateTodo,
                              child: Padding(
                                padding: EdgeInsets.all(7),
                                child: Text(
                                  'saveTodo'.tr(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35)),
                                ),
                              ),
                              onPressed: deleteTodo,
                              child: Padding(
                                padding: EdgeInsets.all(7),
                                child: Text(
                                  'deleteTodo'.tr(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
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
        return value;
      }
    });
  }

  Future<void> update() async {
    setState(() {
      widget.todo.done = !widget.todo.done;
    });
    widget.todo.update();
    await Future.delayed(const Duration(milliseconds: _animationDelay));
    widget.notifyParent();
  }

  Color getCheckboxColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.white;
  }

  Color getCheckboxColorForm(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.blue;
  }

  String getDate() {
    String date = '';
    DateTime now = DateTime.now();
    now = new DateTime(now.year, now.month, now.day);

    int daysDifference = widget.todo.date.toLocal().difference(now).inDays;
    //yesterday
    if (daysDifference == -1) {
      date = 'yesterdayText'.tr();
    }
    //today
    if (widget.todo.date.toLocal().isAtSameMomentAs(now)) {
      date = 'todayText'.tr();
    }
    //tomorrow
    if (daysDifference == 1) {
      date = 'tomorrowText'.tr();
    }
    //a week ago or in a week
    if ((daysDifference < -1 && daysDifference >= -7) ||
        (daysDifference > 1 && daysDifference <= 7)) {
      date = DateFormat.EEEE().format(widget.todo.date.toLocal());
    }
    //before a week ago or more than in a week
    if ((daysDifference < -7 || daysDifference > 7) &&
        widget.todo.date.toLocal().year == now.year) {
      date = DateFormat.MMMMd().format(widget.todo.date.toLocal());
    }
    //different year
    debugPrint(widget.todo.date.year.toString() + " " + now.year.toString());
    if (widget.todo.date.toLocal().year != now.toLocal().year) {
      date = DateFormat.yMMMMd().format(widget.todo.date.toLocal());
    }
    return date;
  }

  Color getDateColor() {
    Color color = Color.fromARGB(255, 104, 189, 252);
    DateTime now = DateTime.now();
    now = new DateTime(now.year, now.month, now.day);
    if (now.isAfter(widget.todo.date.toLocal()) && widget.todo.done == false) {
      color = Colors.red;
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () async {
          bool refresh = await _editDialog();
          if (refresh) {
            widget.notifyParent();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 90, 149),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: Checkbox(
              value: widget.todo.done,
              onChanged: (_) {
                update();
              },
              fillColor: MaterialStateProperty.resolveWith(getCheckboxColor),
              checkColor: const Color.fromARGB(255, 0, 90, 149),
            ),
            title: Text(
              widget.todo.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              getDate(),
              style: TextStyle(color: getDateColor(), fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
