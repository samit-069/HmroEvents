import 'package:flutter/material.dart';
import '../models/user_store.dart';
import '../models/user_model.dart';
import '../models/event_store.dart';
import '../models/event.dart';
import '../services/admin_api_service.dart';
import '../models/user_role.dart';
import '../widgets/event_card.dart';
import '../widgets/event_edit_dialog.dart';
import '../widgets/user_edit_dialog.dart';
import '../login_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserStore _userStore = UserStore.instance;
  final EventStore _eventStore = EventStore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load events initially
    _eventStore.refreshEvents();
    // Refresh when switching to Events tab
    _tabController.addListener(() {
      if (_tabController.index == 2) {
        _eventStore.refreshEvents();
      }
    });
  }

  void _toggleBlockUser(Map<String, dynamic> user) async {
    final id = (user['_id'] ?? user['id'] ?? '').toString();
    if (id.isEmpty) return;
    final res = await AdminApiService.blockToggle(id);
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Updated'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Failed'), backgroundColor: Colors.red),
      );
    }
  }

  void _confirmDeleteUser(Map<String, dynamic> user) {
    final id = (user['_id'] ?? user['id'] ?? '').toString();
    final display = (user['name'] ?? user['email'] ?? 'this user').toString();
    if (id.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $display? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final res = await AdminApiService.deleteUser(id);
              if (!mounted) return;
              if (res['success'] == true) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted'), backgroundColor: Colors.red),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'Failed to delete user'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialogMap(Map<String, dynamic> user) {
    final id = (user['_id'] ?? user['id'] ?? '').toString();
    if (id.isEmpty) return;
    final nameController = TextEditingController(
      text: (user['name'] ?? '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}').toString().trim(),
    );
    final emailController = TextEditingController(text: (user['email'] ?? '').toString());
    final phoneController = TextEditingController(text: (user['phone'] ?? '').toString());
    final locationController = TextEditingController(text: (user['location'] ?? '').toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 8),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              const SizedBox(height: 8),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updates = <String, dynamic>{};
              updates['name'] = nameController.text.trim();
              updates['email'] = emailController.text.trim();
              updates['phone'] = phoneController.text.trim();
              updates['location'] = locationController.text.trim();
              Navigator.pop(context);
              final res = await AdminApiService.updateUser(id, updates);
              if (!mounted) return;
              if (res['success'] == true) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User updated'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'Failed to update user'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Event Us'),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        RoleSelectionState.instance.setRole(UserRole.user);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.event), text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUsersTab(),
          _buildEventsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: AdminApiService.getMetrics(),
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final ok = snapshot.hasData && snapshot.data!['success'] == true;
        final totalUsers = ok ? snapshot.data!['totalUsers'] as int : 0;
        final blockedUsers = ok ? snapshot.data!['blockedUsers'] as int : 0;
        final totalOrganizers = ok ? snapshot.data!['organizers'] as int : 0;
        final totalEvents = ok ? snapshot.data!['totalEvents'] as int : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (loading) const LinearProgressIndicator(),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Users',
                      value: '$totalUsers',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Blocked Users',
                      value: '$blockedUsers',
                      icon: Icons.block,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Organizers',
                      value: '$totalOrganizers',
                      icon: Icons.business,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Total Events',
                      value: '$totalEvents',
                      icon: Icons.event,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickActionCard(
                icon: Icons.people_outline,
                title: 'Manage Users',
                subtitle: 'View and block/unblock users',
                onTap: () => _tabController.animateTo(1),
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildQuickActionCard(
                icon: Icons.event_note,
                title: 'View All Events',
                subtitle: 'Browse and manage events',
                onTap: () => _tabController.animateTo(2),
                color: Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.red.shade700,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.red.shade700,
              tabs: const [
                Tab(text: 'All Users'),
                Tab(text: 'Organizers'),
                Tab(text: 'Blocked'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUsersListFromBackend(() => AdminApiService.getUsers()),
                _buildUsersListFromBackend(() => AdminApiService.getOrganizers()),
                _buildUsersListFromBackend(() => AdminApiService.getBlockedUsers()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersListFromBackend(Future<List<Map<String, dynamic>>> Function() loader) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loader(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final u = list[index];
            final isOrganizer = (u['role'] ?? '') == 'organizer';
            final isBlocked = (u['isBlocked'] ?? false) == true;
            final name = (u['name'] ?? '').toString().isNotEmpty
                ? u['name']
                : '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isOrganizer ? Colors.purple.shade100 : Colors.blue.shade100,
                  child: Icon(isOrganizer ? Icons.business : Icons.person,
                      color: isOrganizer ? Colors.purple.shade700 : Colors.blue.shade700),
                ),
                title: Text(
                  name.isNotEmpty ? name : (u['email'] ?? 'Unknown'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: isBlocked ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u['email'] ?? ''),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOrganizer ? Colors.purple.shade100 : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isOrganizer ? 'Organizer' : 'User',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOrganizer ? Colors.purple.shade700 : Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isBlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Blocked',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditUserDialogMap(u),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: Icon(
                        isBlocked ? Icons.check_circle : Icons.block,
                        color: isBlocked ? Colors.green : Colors.red,
                      ),
                      onPressed: () => _toggleBlockUser(u),
                      tooltip: isBlocked ? 'Unblock' : 'Block',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserCard(AppUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.role == UserRole.organizer
              ? Colors.purple.shade100
              : Colors.blue.shade100,
          child: Icon(
            user.role == UserRole.organizer ? Icons.business : Icons.person,
            color: user.role == UserRole.organizer
                ? Colors.purple.shade700
                : Colors.blue.shade700,
          ),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: user.isBlocked ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.role == UserRole.organizer
                        ? Colors.purple.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role == UserRole.organizer ? 'Organizer' : 'User',
                    style: TextStyle(
                      fontSize: 12,
                      color: user.role == UserRole.organizer
                          ? Colors.purple.shade700
                          : Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (user.isBlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Blocked',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditUserDialog(user),
            ),
            IconButton(
              icon: Icon(
                user.isBlocked ? Icons.check_circle : Icons.block,
                color: user.isBlocked ? Colors.green : Colors.red,
              ),
              onPressed: () => _showBlockDialog(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab() {
    return RefreshIndicator(
      onRefresh: _eventStore.refreshEvents,
      child: ValueListenableBuilder<List<Event>>(
        valueListenable: _eventStore.eventsNotifier,
        builder: (context, events, _) {
          if (events.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No events found',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    EventCard(
                      event: event,
                      onBookmark: () => _eventStore.toggleBookmark(event.id),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _showEditEventDialog(event),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                            style: TextButton.styleFrom(foregroundColor: Colors.blue),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _showDeleteEventDialog(event),
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Delete'),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlockDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isBlocked ? 'Unblock User' : 'Block User'),
        content: Text(
          user.isBlocked
              ? 'Are you sure you want to unblock ${user.name}?'
              : 'Are you sure you want to block ${user.name}? This will prevent them from accessing the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _userStore.toggleBlockUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    user.isBlocked
                        ? '${user.name} has been unblocked'
                        : '${user.name} has been blocked',
                  ),
                  backgroundColor: user.isBlocked ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isBlocked ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(user.isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => UserEditDialog(
        user: user,
        onSave: (updatedUser) {
          _userStore.updateUser(updatedUser);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${updatedUser.name} has been updated'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteUserDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _userStore.deleteUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} has been deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => EventEditDialog(
        event: event,
        onSave: (updatedEvent) {
          _eventStore.updateEvent(updatedEvent);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${updatedEvent.title} has been updated'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _eventStore.deleteEvent(event.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${event.title} has been deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

