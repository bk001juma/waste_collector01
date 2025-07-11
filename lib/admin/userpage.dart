// ignore_for_file: use_build_context_synchronously



import 'dart:math' as logger show e;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:RecycleHub/services/authentication.dart';


class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;

  int _currentPage = 1;
  final int _limit = 10;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('username')
          .get(); // Fetch all and paginate manually

      final users = querySnapshot.docs.map((doc) {
        return {
          'uid': doc.id,
          'username': doc['username'],
          'email': doc['email'],
          'phone': doc['phone'],
          'address': doc['address'],
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _users = users;
        _filterUsers(applySetState: false); // skip setState inside _filterUsers
        _isLoading = false;
      });
    } catch (e) {
      logger.e;

      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers({bool applySetState = true}) {
    final query = _searchController.text.toLowerCase();
    final filtered = _users.where((user) {
      final name = user['username']?.toLowerCase() ?? '';
      return name.contains(query);
    }).toList();

    if (applySetState && mounted) {
      setState(() {
        _filteredUsers = filtered;
        _currentPage = 1;
      });
    } else {
      _filteredUsers = filtered;
      _currentPage = 1;
    }
  }

  Future<void> _deleteUser(String userId) async {
    await _authService.firestore.collection('users').doc(userId).delete();
    _fetchUsers();
  }

  void _showUpdateDialog(Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['username']);
    final phoneController = TextEditingController(text: user['phone']);
    final addressController = TextEditingController(text: user['address']);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Update User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // ✅ this now works
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('users').doc(user['uid']).update({
                'username': nameController.text,
                'phone': phoneController.text,
                'address': addressController.text,
              });

              Navigator.pop(dialogContext); // ✅ closes the dialog only
              _fetchUsers(); // ✅ refresh users
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }


  void _goToPreviousPage() {
    if (_currentPage > 1 && mounted) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _goToNextPage() {
    final totalPages = (_filteredUsers.length / _limit).ceil();
    if (_currentPage < totalPages && mounted) {
      setState(() {
        _currentPage++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromIndex = (_currentPage - 1) * _limit;
    final toIndex = (_currentPage * _limit);
    final visibleUsers = _filteredUsers.sublist(
      fromIndex,
      toIndex > _filteredUsers.length ? _filteredUsers.length : toIndex,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Users"),
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by username...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: visibleUsers.isEmpty
                      ? const Center(child: Text("No users found."))
                      : ListView.builder(
                          itemCount: visibleUsers.length,
                          itemBuilder: (_, index) {
                            final user = visibleUsers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              elevation: 2,
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text(user['username'] ?? 'No Name'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email: ${user['email'] ?? ''}'),
                                    Text('Phone: ${user['phone'] ?? ''}'),
                                    Text('Address: ${user['address'] ?? ''}'),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showUpdateDialog(user),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteUser(user['uid']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                      child: const Text('Previous'),
                    ),
                    const SizedBox(width: 20),
                    Text('Page $_currentPage'),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: toIndex < _filteredUsers.length ? _goToNextPage : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
    );
  }
}
