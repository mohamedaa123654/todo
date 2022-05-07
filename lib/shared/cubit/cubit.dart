import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/shared/cubit/states.dart';

import '../../modules/archive_taskes.dart';
import '../../modules/done_taskes.dart';
import '../../modules/new_taskes.dart';
import '../components/constants.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screens = [
    const NewTaskScreen(),
    const DoneTaskScreen(),
    const ArchiveTaskScreen()
  ];
  List<String> titles = [
    'New Taskes',
    'Done Taskes',
    'Archive Taskes',
  ];
  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavigationBarState());
  }

  late Database database;
  List<Map> tasks = [];
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDatabase() async {
    openDatabase('todo.db', version: 1, onCreate: (database, version) async {
      print('database Created');

      await database
          .execute(
              'CREATE TABLE Tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT,  status TEXT)')
          .then((value) {
        print('table Created');
      }).catchError((error) {
        print(error);
      });
    }, onOpen: (database) {
      print('database file is opened');
      getDatabase(database);
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    }).catchError((error) {
      print('errro when opening the file');
    });
  }

  // insert to database
  void insertToDatabase({
    required String title,
    required String date,
    required String time,
  }) {
    database.transaction((txn) async {
      // insert into tableName
      txn
          .rawInsert(
              'INSERT INTO Tasks( title, date,time,status) VALUES("$title", "$date", "$time","new")')
          .then((value) {
        print('$value is inserted successfully');

        emit(AppInsertToDatabaseState());

        getDatabase(database);
      }).catchError((error) {
        print('an error when inserting into database');
      });
    });
  }

  void getDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppGetDatabaseLoadingState());

    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new')
          newTasks.add(element);
        else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });

      emit(AppGetDatabaseState());
    });
  }

  void updateData({
    required String status,
    required int id,
  }) async {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value) {
      getDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({
    required int id,
  }) async {
    await database
        .rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  IconData fabIcon = Icons.edit;

  bool isBottomSheetShown = false;
  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;

    emit(AppChangeBottomSheetState());
  }
}
