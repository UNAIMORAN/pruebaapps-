import 'package:flutter/material.dart';

import '../main.dart';

/// Lista de tareas del usuario autenticado.
///
/// Usa un `stream` de Supabase, así la lista se actualiza sola (en tiempo real)
/// cuando se insertan, completan o borran filas.
class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  final _taskController = TextEditingController();

  // Stream en tiempo real de la tabla 'todos', ordenado por fecha de creación.
  // Las políticas RLS hacen que cada usuario solo reciba SUS filas.
  final _todosStream = supabase
      .from('todos')
      .stream(primaryKey: ['id']).order('created_at');

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  /// Inserta una tarea nueva. El user_id lo asigna el `default auth.uid()`
  /// de la columna en la base de datos, así que no hace falta enviarlo.
  Future<void> _addTodo() async {
    final task = _taskController.text.trim();
    if (task.isEmpty) return;

    _taskController.clear();
    try {
      await supabase.from('todos').insert({'task': task});
    } catch (error) {
      _showMessage('No se pudo añadir la tarea.');
    }
  }

  /// Marca o desmarca una tarea como completada.
  Future<void> _toggleComplete(int id, bool isComplete) async {
    try {
      await supabase
          .from('todos')
          .update({'is_complete': isComplete}).eq('id', id);
    } catch (error) {
      _showMessage('No se pudo actualizar la tarea.');
    }
  }

  /// Borra una tarea por su id.
  Future<void> _deleteTodo(int id) async {
    try {
      await supabase.from('todos').delete().eq('id', id);
    } catch (error) {
      _showMessage('No se pudo borrar la tarea.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => supabase.auth.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Fila para escribir y añadir una tarea nueva.
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Nueva tarea...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: _addTodo,
                ),
              ],
            ),
          ),
          // Lista en tiempo real.
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _todosStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final todos = snapshot.data!;
                if (todos.isEmpty) {
                  return const Center(
                    child: Text('Aún no tienes tareas. ¡Añade una!'),
                  );
                }

                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    final id = todo['id'] as int;
                    final task = todo['task'] as String;
                    final isComplete = todo['is_complete'] as bool;

                    return Dismissible(
                      key: ValueKey(id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteTodo(id),
                      child: CheckboxListTile(
                        value: isComplete,
                        onChanged: (value) =>
                            _toggleComplete(id, value ?? false),
                        title: Text(
                          task,
                          style: TextStyle(
                            decoration: isComplete
                                ? TextDecoration.lineThrough
                                : null,
                            color: isComplete ? Colors.grey : null,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
