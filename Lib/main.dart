import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PasswordListScreen(),
    );
  }
}

class PasswordListScreen extends StatefulWidget {
  @override
  _PasswordListScreenState createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<String> _passwordKeys = [];

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    _passwordKeys = await _storage.readAll().then((value) => value.keys.toList());
    setState(() {});
  }

  Future<void> _addPassword() async {
    if (_nameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      await _storage.write(key: _nameController.text, value: _passwordController.text);
      _nameController.clear();
      _passwordController.clear();
      await _loadPasswords();
    }
  }

  Future<void> _deletePassword(String key) async {
    await _storage.delete(key: key);
    await _loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Manager'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Website/Service Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ),
          ElevatedButton(
            onPressed: _addPassword,
            child: Text('Add Password'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _passwordKeys.length,
              itemBuilder: (context, index) {
                String key = _passwordKeys[index];
                return ListTile(
                  title: Text(key),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deletePassword(key),
                  ),
                  onTap: () async {
                    String? password = await _storage.read(key: key);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(key),
                        content: Text(password ?? 'No password found'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Close'),
                          ),
                        ],
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
