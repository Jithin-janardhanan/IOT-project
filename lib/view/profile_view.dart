import 'package:flutter/material.dart';
import 'package:iot/provider/user_provider.dart';
import 'package:provider/provider.dart';

class profileView extends StatelessWidget {
  const profileView({super.key});

  @override
  Widget build(BuildContext context) {
     final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          centerTitle: true,
        ),
        body: user == null
            ? Center(child: Text('User information not avail.able'))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileItem('Username', user.username),
                    _buildProfileItem('Name', '${user.firstName} ${user.lastName}'),
                    _buildProfileItem('Email', user.email),
                    _buildProfileItem('Phone', user.phoneNumber),
                    _buildProfileItem('Address', user.address),
                    _buildProfileItem('Role', user.role),
                  ],
                )));
  }
}
 Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            value.isNotEmpty ? value : 'Not provided',
            style: TextStyle(fontSize: 16),
          ),
          Divider(),
        ],
      ),
    );
  }

