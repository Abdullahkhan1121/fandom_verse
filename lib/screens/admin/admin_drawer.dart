import 'package:fandom_verse/screens/admin/fandom_mng.dart';
import 'package:fandom_verse/screens/admin/mng_event.dart';
import 'package:fandom_verse/screens/admin/prd_mnd.dart';
import 'package:fandom_verse/screens/admin/user_mng.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final VoidCallback? onDashboard;
  final VoidCallback? onFandoms;
  final VoidCallback? onEvents;
  final VoidCallback? onProducts;
  final VoidCallback? onUsers;

  const AdminDrawer({
    super.key,
    this.onDashboard,
    this.onFandoms,
    this.onEvents,
    this.onProducts,
    this.onUsers,
  });

  // COLORS

  static const Color _backgroundColor = Color(0xFF080A12);
  static const Color _panelColor = Color(0xFF111522);
  static const Color _primaryColor = Color(0xFF7C5CFC);
  static const Color _primaryLightColor = Color(0xFF9D87FF);
  static const Color _goldColor = Color(0xFFE0B45A);
  static const Color _whiteColor = Color(0xFFF5F5F7);
  static const Color _mutedColor = Color(0xFF9CA3B5);

  // BUILD

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _backgroundColor,
      width: 290,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildSectionTitle('MAIN'),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    onTap: onDashboard,
                    isSelected: true,
                  ),
                  const SizedBox(height: 6),
                  _buildSectionTitle('MANAGEMENT'),

                  // FANDOMS
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.auto_awesome_rounded,
                    title: 'Manage Fandoms',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const FandomManagementScreen(),
                        ),
                      );
                    },
                  ),

                  // EVENTS
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.event_rounded,
                    title: 'Manage Events',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ManageEventsScreen(),
                        ),
                      );
                    },
                  ),

                  // PRODUCTS
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.shopping_bag_rounded,
                    title: 'Manage Products',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ProductManagementScreen(),
                        ),
                      );
                    },
                  ),

                  // USERS
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.people_alt_rounded,
                    title: 'Manage Users',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const UserManagementScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // LOGOUT
            _buildLogoutButton(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // HEADER

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _panelColor,
            _primaryColor.withValues(alpha: 0.13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  _primaryColor,
                  _primaryLightColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withValues(alpha: 0.25),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fandom Verse',
                  style: TextStyle(
                    color: _whiteColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: _goldColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SECTION TITLE

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: _mutedColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
        ),
      ),
    );
  }

  // DRAWER ITEM

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  _primaryColor.withValues(alpha: 0.20),
                  _primaryColor.withValues(alpha: 0.08),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(13),
        border: isSelected
            ? Border.all(
                color: _primaryColor.withValues(alpha: 0.20),
              )
            : null,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        leading: Icon(
          icon,
          color: isSelected ? _primaryLightColor : _mutedColor,
          size: 21,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? _whiteColor : _mutedColor,
            fontSize: 13.5,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: _primaryLightColor,
                  shape: BoxShape.circle,
                ),
              )
            : const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF5F6678),
                size: 18,
              ),
        onTap: () {
          Navigator.pop(context);
          onTap?.call();
        },
      ),
    );
  }

  // LOGOUT BUTTON

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        tileColor: Colors.redAccent.withValues(alpha: 0.06),
        leading: const Icon(
          Icons.logout_rounded,
          color: Colors.redAccent,
          size: 21,
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {
          _handleLogout(context);
        },
      ),
    );
  }

  // LOGOUT HANDLER

  Future<void> _handleLogout(BuildContext context) async {
    // Confirmation dialog

    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _panelColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: _whiteColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: _mutedColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    // Grab these BEFORE signing out. Once Firebase signs out, AuthGate
    // rebuilds and this drawer's context is disposed, so we must not
    // rely on `context` afterwards.
    final NavigatorState navigator = Navigator.of(
      context,
      rootNavigator: true,
    );
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    // Loading dialog (shown on the root navigator)
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) {
        return const PopScope(
          canPop: false,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signOut();

      // Remove the loading dialog AND every screen that was pushed on top
      // of AuthGate (Fandom Management, Products, Events, ...). What is
      // left is AuthGate, which now shows the login screen.
      navigator.popUntil((route) => route.isFirst);
    } catch (error) {
      // Close only the loading dialog.
      navigator.pop();

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Logout failed: $error'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
    }
  }
}