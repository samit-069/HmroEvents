import 'package:flutter/foundation.dart';
import 'user_model.dart';
import 'user_role.dart';

class UserStore {
  UserStore._internal() {
    _users = _seedUsers();
    usersNotifier = ValueNotifier<List<AppUser>>(List.unmodifiable(_users));
  }

  static final UserStore instance = UserStore._internal();

  late final ValueNotifier<List<AppUser>> usersNotifier;
  late List<AppUser> _users;

  List<AppUser> get users => List.unmodifiable(_users);
  List<AppUser> get blockedUsers => _users.where((u) => u.isBlocked).toList();
  List<AppUser> get activeUsers => _users.where((u) => !u.isBlocked).toList();
  List<AppUser> get organizers => _users.where((u) => u.role == UserRole.organizer).toList();
  List<AppUser> get regularUsers => _users.where((u) => u.role == UserRole.user).toList();

  void toggleBlockUser(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index == -1) return;
    final user = _users[index];
    _users[index] = user.copyWith(isBlocked: !user.isBlocked);
    _notifyListeners();
  }

  void blockUser(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index == -1) return;
    final user = _users[index];
    if (!user.isBlocked) {
      _users[index] = user.copyWith(isBlocked: true);
      _notifyListeners();
    }
  }

  void unblockUser(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index == -1) return;
    final user = _users[index];
    if (user.isBlocked) {
      _users[index] = user.copyWith(isBlocked: false);
      _notifyListeners();
    }
  }

  void updateUser(AppUser updatedUser) {
    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index == -1) return;
    _users[index] = updatedUser;
    _notifyListeners();
  }

  void deleteUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    _notifyListeners();
  }

  void _notifyListeners() {
    usersNotifier.value = List.unmodifiable(_users);
  }

  List<AppUser> _seedUsers() {
    return [
      AppUser(
        id: '1',
        name: 'John Doe',
        email: 'john.doe@example.com',
        role: UserRole.user,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AppUser(
        id: '2',
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        role: UserRole.organizer,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      AppUser(
        id: '3',
        name: 'Mike Johnson',
        email: 'mike.j@example.com',
        role: UserRole.user,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      AppUser(
        id: '4',
        name: 'Sarah Williams',
        email: 'sarah.w@example.com',
        role: UserRole.organizer,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      AppUser(
        id: '5',
        name: 'David Brown',
        email: 'david.b@example.com',
        role: UserRole.user,
        isBlocked: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      AppUser(
        id: '6',
        name: 'Emily Davis',
        email: 'emily.d@example.com',
        role: UserRole.organizer,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}

