import 'package:fandom_verse/screens/products/products_screen.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 50,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  'Fandom Verse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
            ListTile(
  leading: const Icon(Icons.shopping_bag),
  title: const Text('Products'),
  onTap: () {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductsScreen(),
      ),
    );
  },
),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Discover'),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Wishlist'),
            onTap: () => Navigator.pop(context),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}