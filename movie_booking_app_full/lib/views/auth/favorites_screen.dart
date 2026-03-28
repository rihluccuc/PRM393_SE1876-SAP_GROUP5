import 'package:flutter/material.dart';

/// FavoritesScreen - Màn hình phim yêu thích
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phim yêu thích'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có phim yêu thích',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy thêm phim vào danh sách yêu thích!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
