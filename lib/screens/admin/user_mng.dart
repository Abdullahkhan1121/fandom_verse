import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fandom_verse/screens/admin/admin_drawer.dart';
import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // FETCH USERS
  // ============================================================

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      final users = snapshot.docs.toList();

      users.sort((a, b) {
        final aCreated = a.data()['createdAt'];
        final bCreated = b.data()['createdAt'];

        if (aCreated is Timestamp && bCreated is Timestamp) {
          return bCreated.compareTo(aCreated);
        }

        return 0;
      });

      if (!mounted) return;

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch users: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ============================================================
  // USER HELPERS
  // ============================================================

  String _getName(Map<String, dynamic> data) {
    return (data['name'] ??
            data['displayName'] ??
            data['username'] ??
            'Unknown User')
        .toString()
        .trim();
  }

  String _getEmail(Map<String, dynamic> data) {
    return (data['email'] ?? '').toString().trim();
  }

  String _getRole(Map<String, dynamic> data) {
    return (data['role'] ?? 'user').toString().trim().toLowerCase();
  }

  String _getProfileImage(Map<String, dynamic> data) {
    return (data['profileImage'] ??
            data['profileImageUrl'] ??
            data['photoURL'] ??
            data['photoUrl'] ??
            '')
        .toString()
        .trim();
  }

  bool _isVerified(Map<String, dynamic> data) {
    return data['emailVerified'] == true ||
        data['isVerified'] == true ||
        data['verified'] == true;
  }

  bool _isActive(Map<String, dynamic> data) {
    // Default existing users to active if the field
    // has not been added yet.
    return data['active'] != false;
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }

    return _users.where((doc) {
      final data = doc.data();

      final name = _getName(data).toLowerCase();
      final email = _getEmail(data).toLowerCase();
      final status = _isActive(data) ? 'active' : 'inactive';
      final verified = _isVerified(data) ? 'verified' : 'not verified';

      return name.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          status.contains(_searchQuery) ||
          verified.contains(_searchQuery);
    }).toList();
  }

  // ============================================================
  // CHANGE ACTIVE STATUS
  // ============================================================

  Future<void> _changeUserStatus(
    QueryDocumentSnapshot<Map<String, dynamic>> userDoc,
    bool newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userDoc.id)
          .update({
            'active': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      await _fetchUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? '${_getName(userDoc.data())} is now active.'
                : '${_getName(userDoc.data())} is now inactive.',
          ),
          backgroundColor: newStatus
              ? const Color(0xFF19C37D)
              : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update user status: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  // ============================================================
  // CONFIRM STATUS
  // ============================================================

  Future<void> _confirmStatusChange(
    QueryDocumentSnapshot<Map<String, dynamic>> userDoc,
    bool newStatus,
  ) async {
    final data = userDoc.data();
    final name = _getName(data);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111522),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            newStatus ? 'Activate User?' : 'Deactivate User?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            newStatus
                ? 'Allow $name to access the application again?'
                : 'Prevent $name from accessing the application?',
            style: const TextStyle(color: Colors.white60, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus
                    ? const Color(0xFF19C37D)
                    : Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(newStatus ? 'Activate' : 'Deactivate'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _changeUserStatus(userDoc, newStatus);
    }
  }

  // ============================================================
  // PROFILE AVATAR
  // ============================================================

  Widget _buildProfileAvatar(Map<String, dynamic> data, double size) {
    final imageUrl = _getProfileImage(data);
    final name = _getName(data);

    final firstLetter = name.isNotEmpty
        ? name.substring(0, 1).toUpperCase()
        : '?';

    return SizedBox(
      width: size,
      height: size,
      child: ClipPath(
        clipper: _ProfileShapeClipper(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C5CFC), Color(0xFF9D87FF)],
            ),
          ),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _avatarLetter(firstLetter);
                  },
                )
              : _avatarLetter(firstLetter),
        ),
      ),
    );
  }

  Widget _avatarLetter(String letter) {
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // VERIFIED BADGE
  // ============================================================

  Widget _buildVerifiedBadge(bool verified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: verified
            ? const Color(0xFF19C37D).withOpacity(.10)
            : Colors.redAccent.withOpacity(.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: verified
              ? const Color(0xFF19C37D).withOpacity(.25)
              : Colors.redAccent.withOpacity(.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified_rounded : Icons.error_outline_rounded,
            size: 15,
            color: verified ? const Color(0xFF19C37D) : Colors.redAccent,
          ),
          const SizedBox(width: 6),
          Text(
            verified ? 'Verified' : 'Not Verified',
            style: TextStyle(
              color: verified ? const Color(0xFF19C37D) : Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BUTTON
  // ============================================================

  Widget _buildStatusButton(
    QueryDocumentSnapshot<Map<String, dynamic>> userDoc,
  ) {
    final active = _isActive(userDoc.data());

    return GestureDetector(
      onTap: () {
        _confirmStatusChange(userDoc, !active);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF19C37D).withOpacity(.10)
              : Colors.redAccent.withOpacity(.10),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: active
                ? const Color(0xFF19C37D).withOpacity(.28)
                : Colors.redAccent.withOpacity(.28),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF19C37D) : Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              active ? 'Active' : 'Inactive',
              style: TextStyle(
                color: active ? const Color(0xFF19C37D) : Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              active ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
              color: active ? const Color(0xFF19C37D) : Colors.redAccent,
              size: 23,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // USER CARD
  // ============================================================

  Widget _buildUserCard(QueryDocumentSnapshot<Map<String, dynamic>> userDoc) {
    final data = userDoc.data();

    final name = _getName(data);
    final email = _getEmail(data);
    final verified = _isVerified(data);
    final active = _isActive(data);
    final role = _getRole(data);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.055)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          // ------------------------------------------------------
          // PROFILE
          // ------------------------------------------------------
          _buildProfileAvatar(data, 58),

          const SizedBox(width: 16),

          // ------------------------------------------------------
          // NAME + EMAIL
          // ------------------------------------------------------
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    if (role == 'admin') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0B45A).withOpacity(.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(
                            color: Color(0xFFE0B45A),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  email.isEmpty ? 'No email available' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // ------------------------------------------------------
          // VERIFIED
          // ------------------------------------------------------
          Expanded(
            flex: 2,
            child: Center(child: _buildVerifiedBadge(verified)),
          ),

          const SizedBox(width: 20),

          // ------------------------------------------------------
          // ACTIVE / INACTIVE
          // ------------------------------------------------------
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildStatusButton(userDoc),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE USER CARD
  // ============================================================

  Widget _buildMobileUserCard(
    QueryDocumentSnapshot<Map<String, dynamic>> userDoc,
  ) {
    final data = userDoc.data();

    final name = _getName(data);
    final email = _getEmail(data);
    final verified = _isVerified(data);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildProfileAvatar(data, 52),
              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email.isEmpty ? 'No email available' : email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: _buildVerifiedBadge(verified)),

              const SizedBox(width: 10),

              _buildStatusButton(userDoc),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        cursorColor: const Color(0xFF9D87FF),
        decoration: InputDecoration(
          hintText: 'Search by name, email or status...',
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.white38,
            size: 21,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white38,
                    size: 19,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final hasSearch = _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFF7C5CFC).withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                color: Color(0xFF9D87FF),
                size: 35,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              hasSearch ? 'No users found' : 'No users available',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              hasSearch
                  ? 'Try a different name, email or status.'
                  : 'Users will appear here once they register.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 650;

    return Scaffold(
      backgroundColor: const Color(0xFF080A12),

      appBar: AppBar(
        backgroundColor: const Color(0xFF080A12),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text(
          'User Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          // IconButton(
          //   tooltip: 'Refresh',
          //   onPressed: _fetchUsers,
          //   icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
          // ),
          const SizedBox(width: 10),
        ],
      ),

      drawer: AdminDrawer(),

      body: RefreshIndicator(
        color: const Color(0xFF9D87FF),
        backgroundColor: const Color(0xFF111522),
        onRefresh: _fetchUsers,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ----------------------------------------------------
            // HEADER
            // ----------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 28,
                  10,
                  isMobile ? 16 : 28,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Users',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 23 : 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'View users, verification status and account access.',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),

                    const SizedBox(height: 20),

                    _buildSearchBar(),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------
            // CONTENT
            // ----------------------------------------------------
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF9D87FF)),
                ),
              )
            else if (_filteredUsers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 28,
                  0,
                  isMobile ? 16 : 28,
                  30,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final user = _filteredUsers[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: isMobile
                          ? _buildMobileUserCard(user)
                          : _buildUserCard(user),
                    );
                  }, childCount: _filteredUsers.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// CUSTOM PROFILE SHAPE
// ================================================================

class _ProfileShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    final w = size.width;
    final h = size.height;

    path.moveTo(w * .5, 0);

    path.cubicTo(w * .72, h * .02, w * .94, h * .18, w, h * .40);

    path.cubicTo(w * 1.02, h * .63, w * .86, h * .88, w * .66, h);

    path.cubicTo(w * .42, h * 1.02, w * .15, h * .91, w * .03, h * .69);

    path.cubicTo(w * -.07, h * .48, w * .10, h * .18, w * .30, h * .06);

    path.cubicTo(w * .37, h * .02, w * .44, 0, w * .5, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

// ================================================================
// FIRESTORE DOCUMENT WRAPPER
// ================================================================
//
// Used so the list can be updated locally after changing
// active/inactive status without refetching everything.
//
