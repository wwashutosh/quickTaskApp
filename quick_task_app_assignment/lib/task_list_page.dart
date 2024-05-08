import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart'; // For date formatting

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class Task {
  final String taskId; // Unique identifier for each task
  String taskName;
  DateTime taskDueDate;
  String taskDesc;
  bool isCompleted;

  Task({
    required this.taskId,
    required this.taskName,
    required this.taskDueDate,
    required this.taskDesc,
    this.isCompleted = false,
  });
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> tasks = [
    Task(
      taskId: '1',
      taskName: 'Task 1',
      taskDueDate: DateTime.now().add(Duration(days: 1)),
      taskDesc: 'Description for Task 1',
    ),
    Task(
      taskId: '2',
      taskName: 'Task 2',
      taskDueDate: DateTime.now().add(Duration(days: 2)),
      taskDesc: 'Description for Task 2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: Text(task.taskName),
            subtitle: Text(
                'Due: ${DateFormat('yyyy-MM-dd').format(task.taskDueDate)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? newValue) {
                    setState(() {
                      task.isCompleted = newValue ?? false;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editTask(context, task);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteTask(task);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addTask(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _editTask(BuildContext context, Task task) {
    TextEditingController nameController =
        TextEditingController(text: task.taskName);
    TextEditingController dueDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(task.taskDueDate));
    TextEditingController descController =
        TextEditingController(text: task.taskDesc);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: dueDateController,
                decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save edited task
                setState(() {
                  task.taskName = nameController.text;
                  task.taskDueDate =
                      DateFormat('yyyy-MM-dd').parse(dueDateController.text);
                  task.taskDesc = descController.text;
                });
                // Call method to save changes to your backend (back4app)
                _saveTaskToBackend(task);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
    // Call method to delete task from your backend (back4app)
    _deleteTaskFromBackend(task);
  }

  void _addTask(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController dueDateController = TextEditingController();
    TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: dueDateController,
                decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Create new task
                Task newTask = Task(
                  taskId: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(), // Generate unique taskId
                  taskName: nameController.text,
                  taskDueDate:
                      DateFormat('yyyy-MM-dd').parse(dueDateController.text),
                  taskDesc: descController.text,
                );
                // Add new task to the list
                setState(() {
                  tasks.add(newTask);
                });
                // Call method to save new task to your backend (back4app)
                _saveTaskToBackend(newTask);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTaskToBackend(Task task) async {
    final taskObject = ParseObject('TaskDetails')
      ..set('taskId', task.taskId)
      ..set('taskName', task.taskName)
      ..set('taskDueDate', task.taskDueDate)
      ..set('taskDesc', task.taskDesc);

    try {
      final response = await taskObject.save();
      if (response.success) {
        _showToast('Task saved successfully');
      } else {
        throw Exception('Failed to save task: ${response.error?.message}');
      }
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  Future<void> _deleteTaskFromBackend(Task task) async {
    try {
      // Create a query to find the task in your back4app database based on the taskId
      final query = QueryBuilder(ParseObject('TaskDetails'))
        ..whereEqualTo('taskId', task.taskId);

      // Execute the query
      final response = await query.query();
      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        // If task is found, delete it
        final tasksToDelete = response.results!;
        final deleteResponse = await tasksToDelete[0].delete();
        if (deleteResponse.success) {
          // Task deleted successfully
          _showToast('Task deleted successfully');
        } else {
          // Failed to delete task
          throw Exception(
              'Failed to delete task: ${deleteResponse.error?.message}');
        }
      } else {
        // Task not found
        throw Exception('Task not found');
      }
    } catch (e) {
      // Handle errors
      _showToast('Error: $e');
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
