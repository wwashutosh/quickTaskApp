import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart'; // For date formatting
import 'package:quick_task_app_assignment/login_page.dart'; // Import the login page

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
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    setState(() {
                      task.isCompleted = value!;
                    });
                  },
                ),
                title: Text(
                  task.taskName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.0),
                    Text(
                      'Due: ${DateFormat('yyyy-MM-dd').format(task.taskDueDate)}',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      task.taskDesc,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addTask(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
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

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
