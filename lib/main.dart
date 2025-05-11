import 'package:flutter/material.dart';

import 'api_service.dart';
import 'user_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dio API Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> _futureUsers;
  bool _isLoading = true;
  String _error = '';

  final List<IconData> _userIcons = [Icons.person];

  @override
  void initState() {
    super.initState();
    _futureUsers = ApiService().fetchUsers();
    _futureUsers
        .then((value) {
          setState(() {
            _isLoading = false;
          });
        })
        .catchError((e) {
          setState(() {
            _isLoading = false;
            _error = e.toString();
          });
        });
  }

  IconData _getRandomIcon(int index) {
    return _userIcons[index % _userIcons.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User List')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : FutureBuilder<List<User>>(
                future: _futureUsers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    List<User> users = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white,
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade400,
                              child: Icon(
                                _getRandomIcon(index),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              users[index].name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No data available'));
                  }
                },
              ),
    );
  }
}
