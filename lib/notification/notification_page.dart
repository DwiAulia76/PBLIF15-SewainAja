import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class LoanCalendarPage extends StatefulWidget {
  const LoanCalendarPage({super.key});

  @override
  State<LoanCalendarPage> createState() => _LoanCalendarPageState();
}

class _LoanCalendarPageState extends State<LoanCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Loan> _loans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchLoanData();
  }

  Future<void> _fetchLoanData() async {
    final userId = await AuthService.getUserId();
    final url = Uri.parse(
      'http://10.0.2.2/admin_sewainaja/api/history.php?user_id=$userId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _loans = data.map((item) => Loan.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading loan data: $e');
    }
  }

  List<Loan> get _upcomingLoans {
    final now = DateTime.now();
    return _loans.where((loan) {
      final diff = loan.endDate.difference(now);
      return diff.inHours <= 12 && diff.inSeconds > 0;
    }).toList();
  }

  List<Loan> _getEventsForDay(DateTime day) {
    return _loans.where((loan) {
      return isSameDay(loan.endDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Peminjaman'),
        backgroundColor: Colors.blue[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: _getEventsForDay,
                  calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Colors.red[700],
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue[200],
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue[700],
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pengembalian Mendatang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _upcomingLoans.isEmpty
                      ? const Center(
                          child: Text('Tidak ada pengembalian dalam 12 jam'),
                        )
                      : ListView.builder(
                          itemCount: _upcomingLoans.length,
                          itemBuilder: (context, index) =>
                              _buildLoanCard(_upcomingLoans[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoanCard(Loan loan) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loan.itemName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Batas pengembalian: ${DateFormat('dd MMM yyyy HH:mm').format(loan.endDate)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildCountdownTimer(loan.endDate),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownTimer(DateTime endDate) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final difference = endDate.difference(now);

        if (difference.inSeconds <= 0) {
          return Text(
            'Waktu pengembalian telah habis',
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          );
        }

        final hours = difference.inHours
            .remainder(24)
            .toString()
            .padLeft(2, '0');
        final minutes = difference.inMinutes
            .remainder(60)
            .toString()
            .padLeft(2, '0');
        final seconds = difference.inSeconds
            .remainder(60)
            .toString()
            .padLeft(2, '0');

        return Text(
          'Waktu tersisa: $hours:$minutes:$seconds',
          style: TextStyle(
            color: difference.inHours < 1
                ? Colors.red[700]
                : Colors.orange[700],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        );
      },
    );
  }
}

class Loan {
  final String id;
  final String itemName;
  final DateTime startDate;
  final DateTime endDate;

  Loan({
    required this.id,
    required this.itemName,
    required this.startDate,
    required this.endDate,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'].toString(),
      itemName: json['product_name'] ?? 'Produk',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
}
