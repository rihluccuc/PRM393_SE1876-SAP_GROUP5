import 'package:flutter/material.dart';
import '../repositories/cinema_repository.dart';
import '../models/cinema.dart';
import 'seat_selection_screen.dart';

class CinemaListScreen extends StatefulWidget {
  const CinemaListScreen({super.key});

  @override
  State<CinemaListScreen> createState() => _CinemaListScreenState();
}

class _CinemaListScreenState extends State<CinemaListScreen> {
  late List<Cinema> cinemas = [];
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  String? errorMessage;  // Add error state

  @override
  void initState() {
    super.initState();
    _loadCinemas();
  }

  Future<void> _loadCinemas() async {
    try {
      final repo = CinemaRepository();
      cinemas = await repo.getCinemas();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load cinemas: $e';  // Set error message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildDateSection(),
          Expanded(child: _buildCinemaList()),
        ],
      ),
    );
  }

  // ================= APP BAR =================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.red,
      centerTitle: true,
      title: const Text(
        "Danh sách rạp phim",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // ================= DATE SECTION =================
  Widget _buildDateSection() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          _buildDateList(),
          const SizedBox(height: 8),
          _buildSelectedDateText(),
        ],
      ),
    );
  }

  // Scroll ngang các ngày
  Widget _buildDateList() {
    final now = DateTime.now();

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          DateTime date = now.add(Duration(days: index));
          bool isSelected =
              selectedDate.day == date.day &&
                  selectedDate.month == date.month;

          return _buildDateItem(date, isSelected);
        },
      ),
    );
  }

  Widget _buildDateItem(DateTime date, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
      },
      child: Container(
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getWeekday(date),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              "${date.day}",
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateText() {
    return Text(
      "Thứ ${_getWeekday(selectedDate)}, ${selectedDate.day} Tháng ${selectedDate.month}, ${selectedDate.year}",
      style: const TextStyle(color: Colors.white70),
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = [
      "CN",
      "T2",
      "T3",
      "T4",
      "T5",
      "T6",
      "T7"
    ];
    return weekdays[date.weekday % 7];
  }

  // ================= CINEMA LIST =================
  Widget _buildCinemaList() {
    return Container(
      color: Colors.grey[100],
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: cinemas.length,
        itemBuilder: (context, index) {
          return _buildCinemaItem(cinemas[index]);
        },
      ),
    );
  }

  Widget _buildCinemaItem(Cinema cinema) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          cinema.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${cinema.distance} km"),
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: cinema.showtimes
                  .map((time) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SeatSelectionScreen(cinemaName: cinema.name, showTime: time),
                    ),
                  );
                },
                child: Text(time),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}