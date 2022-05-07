import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/shared/components/constants.dart';

import '../shared/components/components/task_builder.dart';
import '../shared/components/components/task_item.dart';
import '../shared/cubit/cubit.dart';
import '../shared/cubit/states.dart';

class NewTaskScreen extends StatelessWidget {
  const NewTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          var tasks = AppCubit.get(context).newTasks;
          return tasksBuilder(tasks: tasks);
        });
  }
}
