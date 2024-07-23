import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'color_picker.dart';
import 'account_page.dart';
import 'home_page.dart';
import 'search_page.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  final Map<DateTime, List<Map<String, dynamic>>> _todos = {};
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Color _selectedColor = Colors.red;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('todos').get();
      setState(() {
        _todos.clear();
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime date = (data['date'] as Timestamp).toDate();
          if (_todos[date] == null) {
            _todos[date] = [];
          }
          _todos[date]!.add({
            'id': doc.id,
            'task': data['task'],
            'color': data['color'],
            'timestamp': date,
          });
        }
      });
    } catch (e) {
      print('Error fetching todos: $e');
    }
  }

  Future<void> _addTodo() async {
    final task = _controller.text;
    if (task.isNotEmpty) {
      final newTodo = {
        'task': task,
        'color': _selectedColor.value,
        'date': Timestamp.fromDate(_selectedDay),
      };

      try {
        DocumentReference docRef = await FirebaseFirestore.instance.collection('todos').add(newTodo);
        newTodo['id'] = docRef.id;

        setState(() {
          if (_todos[_selectedDay] != null) {
            _todos[_selectedDay]!.add(newTodo);
          } else {
            _todos[_selectedDay] = [newTodo];
          }
          _controller.clear();
        });
      } catch (e) {
        print('Error adding todo: $e');
      }
    }
  }

  Future<void> _deleteTodo(DateTime date, int index) async {
    try {
      String todoId = _todos[date]![index]['id'];
      await FirebaseFirestore.instance.collection('todos').doc(todoId).delete();

      setState(() {
        _todos[date]?.removeAt(index);
        if (_todos[date]?.isEmpty ?? false) {
          _todos.remove(date);
        }
      });
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void navigateToPage(Widget page) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            padding: EdgeInsets.all(16),
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
                onPressed: () {
                  navigateToPage(HomePage());
                },
              ),
              GButton(
                icon: Icons.search,
                text: 'Search',
                onPressed: () {
                  navigateToPage(SearchPage());
                },
              ),
              GButton(
                icon: Icons.calendar_today_outlined,
                text: 'Todo',
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profile',
                onPressed: () {
                  navigateToPage(AccountPage());
                },
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('Todo Calendar'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (_todos[date] != null && _todos[date]!.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      right: 1,
                      child: Wrap(
                        spacing: 2,
                        children: _todos[date]!.map((todo) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Color(todo['color']),
                              shape: BoxShape.circle,
                            ),
                            width: 5,
                            height: 5,
                          );
                        }).toList(),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter a todo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                    ),
                    child: Icon(Icons.add),
                    onPressed: _addTodo,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text('Select color:'),
                SizedBox(width: 10),
                ColorPicker(
                  onColorChanged: (Color? color) {
                    if (color != null) {
                      setState(() {
                        _selectedColor = color;
                      });
                    }
                  },
                  selectedColor: _selectedColor,
                ),
              ],
            ),
            Expanded(
              child: _todos[_selectedDay] == null || _todos[_selectedDay]!.isEmpty
                  ? Center(
                child: Text(
                  'No todos yet, add some!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _todos[_selectedDay]!.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: Icon(Icons.check_circle_outline, color: Color(_todos[_selectedDay]![index]['color'])),
                      title: Text(_todos[_selectedDay]![index]['task']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTodo(_selectedDay, index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
