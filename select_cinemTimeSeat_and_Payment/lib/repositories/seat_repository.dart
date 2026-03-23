import '../db/app_database.dart';

class SeatRepository {

  Future<List<String>> getBookedSeats(
      String cinemaName,
      String showTime,
      ) async {
    return await AppDatabase.getBookedSeats(cinemaName, showTime);
  }

  Future<void> bookSeats(
      String cinemaName,
      String showTime,
      List<String> seats,
      ) async {
    await AppDatabase.insertMultipleBookedSeats(
      cinemaName,
      showTime,
      seats,
    );
  }
}