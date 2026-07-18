import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/seat.dart';

class SeatViewController extends Notifier<SeatViewMode> {
  static const _key = 'seat_view_mode';
  @override
  SeatViewMode build() {
    _restore();
    return SeatViewMode.floor;
  }

  Future<void> _restore() async {
    final value = (await SharedPreferences.getInstance()).getString(_key);
    if (value == null) return;
    state = SeatViewMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => SeatViewMode.floor,
    );
  }

  Future<void> select(SeatViewMode mode) async {
    state = mode;
    await (await SharedPreferences.getInstance()).setString(_key, mode.name);
  }
}

final seatViewProvider = NotifierProvider<SeatViewController, SeatViewMode>(
  SeatViewController.new,
);
