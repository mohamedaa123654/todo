import 'dart:async';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/modules/archive_taskes.dart';
import 'package:todo/modules/done_taskes.dart';
import 'package:todo/modules/new_taskes.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/shared/components/components/default_form_field.dart';
import 'package:todo/shared/cubit/cubit.dart';
import 'package:todo/shared/cubit/states.dart';

import '../shared/components/constants.dart';

class TodoHomeScreen extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (BuildContext context, AppState state) {
          if (state is AppInsertToDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppState state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => AppCubit.get(context)
                  .screens[AppCubit.get(context).currentIndex],
              fallback: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (cubit.isBottomSheetShown) {
                    if (formKey.currentState!.validate()) {
                      // print("XXXXXXXXXXXXXXXXXXXXXXX");
                      cubit.insertToDatabase(
                          title: titleController.text,
                          time: timeController.text,
                          date: dateController.text);
                    }
                  } else {
                    scaffoldKey.currentState
                        ?.showBottomSheet(
                          (context) => SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    defaultFormField(
                                        controller: titleController,
                                        type: TextInputType.text,
                                        validate: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'title should not be empty';
                                          }
                                        },
                                        label: 'Title',
                                        prefix: Icons.title_outlined),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    defaultFormField(
                                        controller: timeController,
                                        type: TextInputType.datetime,
                                        onTap: () {
                                          showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now())
                                              .then((value) {
                                            timeController.text = value!
                                                .format(context)
                                                .toString();
                                          });
                                        },
                                        validate: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'time should not be empty';
                                          }
                                        },
                                        label: 'Time',
                                        prefix: Icons.watch_later_outlined),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    defaultFormField(
                                        controller: dateController,
                                        type: TextInputType.datetime,
                                        onTap: () {
                                          showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime.now(),
                                                  lastDate: DateTime.parse(
                                                      '2025-05-09'))
                                              .then((value) {
                                            dateController.text =
                                                DateFormat.yMMMd()
                                                    .format(value!);
                                          });
                                        },
                                        validate: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'date should not be empty';
                                          }
                                        },
                                        label: 'Date',
                                        prefix: Icons.date_range),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          elevation: 20,
                        )
                        .closed
                        .then((value) {
                      cubit.changeBottomSheetState(
                        isShow: false,
                        icon: Icons.edit,
                      );
                    });
                    cubit.changeBottomSheetState(
                      isShow: true,
                      icon: Icons.add,
                    );
                  }
                },
                child: Icon(
                  cubit.fabIcon,
                  size: 30,
                )),
            bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: cubit.currentIndex,
                elevation: 0,
                onTap: (index) {
                  cubit.changeIndex(index);
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.menu), label: 'Taskes'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.check_circle_outline), label: 'Done'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.archive_outlined), label: 'Archive'),
                ]),
          );
        },
      ),
    );
  }
}
