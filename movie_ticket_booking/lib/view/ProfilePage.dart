import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/User.dart';
import '../viewmodels/AuthViewmodels.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _cityController;
  late TextEditingController _districtController;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.user.city ?? '');
    _districtController = TextEditingController(text: widget.user.district ?? '');
  }

  @override
  void dispose() {
    _cityController.dispose();
    _districtController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Info"),
              Tab(text: "Address"),
              Tab(text: "Password"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInfoTab(),
            _buildAddressTab(),
            _buildPasswordTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          _buildInfoRow('Name', widget.user.name),
          _buildInfoRow('Email', widget.user.email),
          _buildInfoRow('Phone', widget.user.phone ?? 'Not provided'),
          _buildInfoRow('City', widget.user.city ?? 'Not provided'),
          _buildInfoRow('District', widget.user.district ?? 'Not provided'),
          _buildInfoRow('Role', widget.user.role),

          const SizedBox(height: 32),

          const Text(
            'My Vouchers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              children: [
                _buildVoucherCard('Welcome Voucher', '10% off first booking', false),
                _buildVoucherCard('Birthday Special', 'Free popcorn', false),
                _buildVoucherCard('Loyalty Reward', '20% off next booking', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Address',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              v!.isEmpty ? "City cannot be empty" : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(
                labelText: "District",
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              v!.isEmpty ? "District cannot be empty" : null,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateAddress,
                child: const Text('Update Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              v!.isEmpty ? "Current password is required" : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v!.isEmpty) {
                  return "New password is required";
                }
                if (v.length < 8) {
                  return "Password must be at least 8 characters";
                }
                if (v == _currentPasswordController.text) {
                  return "New password cannot be the same as current password";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm New Password",
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v!.isEmpty) {
                  return "Please confirm your password";
                }
                if (v != _newPasswordController.text) {
                  return "Passwords do not match";
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Change Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(String title, String description, bool isAvailable) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.card_giftcard,
          color: isAvailable ? Colors.green : Colors.grey,
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: isAvailable ? () {} : null,
          child: Text(isAvailable ? 'Use' : 'Coming Soon'),
        ),
      ),
    );
  }

  void _updateAddress() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authViewModelProvider.notifier).updateUserAddress(
        widget.user.id!,
        _cityController.text,
        _districtController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Address updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        // Update the user object to reflect changes
        setState(() {
          // We could refresh the user data here, but for simplicity, just show success
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to update address'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _changePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      final (success, error) = await ref.read(authViewModelProvider.notifier).changeUserPassword(
        widget.user.id!,
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Password changed successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        // Clear the form
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to change password: ${error ?? 'Unknown error'}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
