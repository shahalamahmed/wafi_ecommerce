import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/user_role.dart';
import 'package:wafi_ecommerce/core/widgets/role_guard.dart';
import '../../features/auth/auth_provider.dart';

final usersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final tenantId = ref.watch(tenantIdProvider);
  if (tenantId == null || tenantId.isEmpty) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .where('tenantId', isEqualTo: tenantId)
      .snapshots()
      .map((s) => s.docs.map((d) {
    final data = d.data();
    data['uid'] = d.id;
    return data;
  }).toList());
});

class UsersManagementScreen extends ConsumerStatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  ConsumerState<UsersManagementScreen> createState() =>
      _UsersManagementScreenState();
}

class _UsersManagementScreenState
    extends ConsumerState<UsersManagementScreen> {
  String? _filterRole;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersStreamProvider);
    final myUid      = ref.watch(authControllerProvider).uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [

        _RoleFilterBar(
          selected: _filterRole,
          onChanged: (r) => setState(() => _filterRole = r),
        ),

        Expanded(
          child: usersAsync.when(
            loading: () =>
            const Center(child: CircularProgressIndicator()),
            error:   (e, _) => Center(child: Text('Error: $e')),
            data:    (users) {
              final filtered = _filterRole == null
                  ? users
                  : users.where((u) => u['role'] == _filterRole).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('No users found'));
              }

              return ListView.separated(
                padding:   const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
                itemBuilder: (_, i) => _UserCard(
                  user:    filtered[i],
                  isMe:    filtered[i]['uid'] == myUid,
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _RoleFilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _RoleFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final roles = ['admin', 'manager', 'staff', 'viewer'];
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label:    const Text('All'),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          ...roles.map((r) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label:    Text(UserRole.fromString(r).displayName),
              selected: selected == r,
              onSelected: (_) => onChanged(selected == r ? null : r),
            ),
          )),
        ],
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  final Map<String, dynamic> user;
  final bool isMe;

  const _UserCard({required this.user, required this.isMe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role     = UserRole.fromString(user['role']);
    final email    = user['email']  as String? ?? '';
    final uid      = user['uid']    as String? ?? '';
    final isActive = user['isActive'] as bool? ?? true;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(children: [

        CircleAvatar(
          backgroundColor: _roleColor(role).withOpacity(0.12),
          child: Text(
            email.isNotEmpty ? email[0].toUpperCase() : '?',
            style: TextStyle(
              color:      _roleColor(role),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isMe)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color:        Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('You',
                        style: TextStyle(
                            fontSize: 11, color: Colors.blue)),
                  ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                _RoleBadge(role: role),
                const SizedBox(width: 8),
                Icon(
                  isActive
                      ? Icons.check_circle
                      : Icons.cancel,
                  size: 14,
                  color: isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? Colors.green : Colors.red,
                  ),
                ),
              ]),
            ],
          ),
        ),

        if (!isMe)
          RoleGuard(
            canAccess: (r) => r == UserRole.admin,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  color: Color(0xFF94A3B8)),
              onSelected: (val) =>
                  _handleAction(context, val, uid, role),
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'admin',
                    child: Text('Set Admin')),
                const PopupMenuItem(
                    value: 'manager',
                    child: Text('Set Manager')),
                const PopupMenuItem(
                    value: 'staff',
                    child: Text('Set Staff')),
                const PopupMenuItem(
                    value: 'viewer',
                    child: Text('Set Viewer')),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                    isActive ? 'Deactivate' : 'Activate',
                    style: TextStyle(
                      color: isActive ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value:  'delete',
                  child: Text('Delete User',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
      ]),
    );
  }

  Future<void> _handleAction(
      BuildContext context,
      String action,
      String uid,
      UserRole currentRole,
      ) async {
    final db = FirebaseFirestore.instance;

    if (['admin', 'manager', 'staff', 'viewer'].contains(action)) {
      await db.collection('users').doc(uid).update({'role': action});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role updated to $action')),
        );
      }
    } else if (action == 'toggle') {
      final current = user['isActive'] as bool? ?? true;
      await db.collection('users').doc(uid).update({'isActive': !current});
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title:   const Text('Delete User?'),
          content: const Text('This cannot be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await db.collection('users').doc(uid).delete();
      }
    }
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:   return Colors.purple;
      case UserRole.manager: return Colors.blue;
      case UserRole.staff:   return Colors.teal;
      case UserRole.viewer:  return Colors.grey;
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role) {
      case UserRole.admin:   color = Colors.purple; break;
      case UserRole.manager: color = Colors.blue;   break;
      case UserRole.staff:   color = Colors.teal;   break;
      case UserRole.viewer:  color = Colors.grey;   break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        role.displayName,
        style: TextStyle(
          fontSize:   11,
          color:      color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}