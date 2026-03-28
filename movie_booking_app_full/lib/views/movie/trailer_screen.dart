import 'package:flutter/material.dart';

/// TrailerScreen - Màn hình xem trailer
class TrailerScreen extends StatelessWidget {
  final int? movieId;
  final String? trailerId;

  const TrailerScreen({super.key, this.movieId, this.trailerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trailer'),
      ),
      body: Center(
        child: Text('Trailer Screen - Movie ID: $movieId, Trailer ID: $trailerId'),
      ),
    );
  }
}
