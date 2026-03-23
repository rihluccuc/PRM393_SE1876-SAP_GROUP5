import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cinema.dart';
import '../repositories/cinema_repository.dart';

final cinemaProvider = FutureProvider<List<Cinema>>((ref) async {
  try {
    return await CinemaRepository().getCinemas();
  } catch (e) {
    throw Exception('Failed to load cinemas: $e');
  }
});