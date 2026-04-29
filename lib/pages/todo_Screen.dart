import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:warsha/pages/todos_module.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {

  List<Todosmodule> todos = [];
  final addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: addController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (addController.text.isNotEmpty) {
                                final SharedPreferences prefs = await SharedPreferences.getInstance();

                                final newTodo = Todosmodule(
                                  userId: prefs.getString("uid") ,
                                  title: addController.text,
                                  completed: false,
                                );
                                addTodos(newTodo);
                                addController.clear();
                                Navigator.pop(context);
                              }
                            },
                            child: Text("Add"),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: todos.isEmpty
          ? Center(child: Text("No Todos"))
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    onTap: (){
                      setState(() {
                        todos[index].completed = !todos[index].completed!;
                        editTodos(todos[index]);
                      });

                    },
                    leading: Checkbox(value: todos[index].completed, onChanged: (val){
                      setState(() {
                        todos[index].completed = val;
                        editTodos(todos[index]);
                      });
                    }),
                    trailing: Container(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        TextField(
                                          controller: addController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (addController
                                                  .text
                                                  .isNotEmpty) {
                                                todos[index].title =
                                                    addController.text;
                                                editTodos(todos[index]);
                                              }
                                              addController.clear();
                                              Navigator.pop(context);
                                            },
                                            child: Text("Edit"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              deleteTodos(todos[index].id!);
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                    tileColor: todos[index].completed!
                        ? Colors.green
                        : Colors.red,
                    title: Text(todos[index].title!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> getTodos() async {
    FirebaseFirestore.instance.collection("todo").snapshots().listen((
      snapshot,
    ) {
      final data = snapshot.docs
          .map((doc) => Todosmodule.fromJson(doc.data(), doc.id))
          .toList();
      setState(() {
        todos = data;
      });
    });
  }

  Future<bool> addTodos(Todosmodule todo) async {
    try {
      FirebaseFirestore.instance.collection("todo").add(todo.toJson());
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> deleteTodos(String id) async {
    try {
      FirebaseFirestore.instance.collection("todo").doc(id).delete();
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> editTodos(Todosmodule todo) async {
    try {
      FirebaseFirestore.instance
          .collection("todo")
          .doc(todo.id)
          .update(todo.toJson());
    } catch (e) {
      return false;
    }
    return true;
  }
}
