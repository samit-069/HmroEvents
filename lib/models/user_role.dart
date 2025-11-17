enum UserRole {
  user,
  organizer,
  admin,
}

class RoleSelectionState {
  RoleSelectionState._();

  static final RoleSelectionState instance = RoleSelectionState._();

  UserRole _currentRole = UserRole.user;

  UserRole get currentRole => _currentRole;
  bool get isOrganizer => _currentRole == UserRole.organizer;
  bool get isAdmin => _currentRole == UserRole.admin;

  void setRole(UserRole role) {
    _currentRole = role;
  }
}


