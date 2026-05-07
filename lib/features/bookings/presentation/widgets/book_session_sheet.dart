import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../../data/models/bookings_models.dart';
import '../../data/repositories/bookings_repository.dart';
import '../screens/payment_screen.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../../core/utils/client_profile_storage.dart';
import '../../../../core/utils/profile_validators.dart';
import '../../../../core/utils/user_preferences_storage.dart';

class BookSessionSheet extends StatefulWidget {
  final int? coachId;
  final String coachName;
  final String coachSport;
  final int? coachSportId;
  final String coachImage;
  final int coachPrice;
  final List<String> availableDays;

  const BookSessionSheet({
    super.key,
    this.coachId,
    this.coachName = 'Coach',
    this.coachSport = 'Coach',
    this.coachSportId,
    this.coachImage = '',
    this.coachPrice = 500,
    this.availableDays = const [],
  });

  @override
  State<BookSessionSheet> createState() => _BookSessionSheetState();
}

class _BookSessionSheetState extends State<BookSessionSheet> {
  final BookingsRepository _repo = BookingsRepository();
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = true;
  bool _isCheckingProfile = false;
  String? _error;
  CoachAvailabilityModel? _availability;
  List<String> _visibleAvailableDays = [];
  String? _selectedDay;
  _AvailabilitySlotData? _selectedSlot;

  static const Color _freeSlotColor = Color(0xFF22C55E);
  static const Color _pendingSlotColor = Color(0xFFFACC15);
  static const Color _reservedSlotColor = Color(0xFFEF4444);
  static const Color _selectedSlotColor = Color(0xFF304FFE);

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _availability = null;
      _selectedDay = null;
      _selectedSlot = null;
    });

    if (widget.coachId == null) {
      setState(() {
        _visibleAvailableDays = _normalizeDays(widget.availableDays);
        _selectedDay = _visibleAvailableDays.isNotEmpty
            ? _visibleAvailableDays.first
            : null;
        _isLoading = false;
      });
      return;
    }

    try {
      final availability = await _repo.getCoachAvailability(widget.coachId!);
      if (!mounted) {
        return;
      }

      setState(() {
        _availability = availability;
        _visibleAvailableDays = _normalizeDays(availability.availableDays);
        _selectedDay = _visibleAvailableDays.isNotEmpty
            ? _visibleAvailableDays.first
            : null;
        _isLoading = false;
      });
      developer.log(
        'BookSessionSheet availability loaded -> '
        'inputCoachId=${widget.coachId} '
        'apiCoachId=${availability.coachId} '
        'sessionSportIds=${availability.sessions.map((session) => session.sportID).toList(growable: false)} '
        'availableDays=${availability.availableDays} '
        'upcomingAvailableDates=${availability.upcomingAvailableDates.map((entry) => {'date': entry.date, 'dayName': entry.dayName, 'hours': entry.availableHours}).toList(growable: false)}',
        name: 'BookSessionSheet',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'Failed to load available sessions';
        _isLoading = false;
      });
    }
  }

  List<String> _normalizeDays(List<String> days) {
    final normalizedDays = <String>[];
    for (final day in days) {
      final trimmedDay = day.trim();
      if (trimmedDay.isEmpty) {
        continue;
      }
      if (!normalizedDays.any(
        (existingDay) => existingDay.toLowerCase() == trimmedDay.toLowerCase(),
      )) {
        normalizedDays.add(trimmedDay);
      }
    }
    return normalizedDays;
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _formatDate(String raw) {
    try {
      final date = DateTime.parse(raw);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return raw;
    }
  }

  String _formatTime(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    if (trimmed.toUpperCase().contains('AM') ||
        trimmed.toUpperCase().contains('PM')) {
      return trimmed;
    }

    final source = trimmed.length >= 5 ? trimmed.substring(0, 5) : trimmed;
    final parts = source.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? parts[1] : '00';
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$hour12:$minute $period';
  }

  String _normalizedTimeValue(String raw) {
    final collapsed = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    return _formatTime(
      collapsed,
    ).trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
  }

  int? _sportIdFromText(String sport) {
    final s = sport.toLowerCase();
    if (s.contains('football')) return 1;
    if (s.contains('yoga')) return 2;
    if (s.contains('swimming')) return 3;
    if (s.contains('fitness')) return 4;
    if (s.contains('tennis')) return 5;
    if (s.contains('basketball')) return 6;
    if (s.contains('horse')) return 7;
    return null;
  }

  int? _resolvedCoachId() {
    final availabilityCoachId = _availability?.coachId;
    if (availabilityCoachId != null && availabilityCoachId > 0) {
      return availabilityCoachId;
    }
    return widget.coachId;
  }

  int? _resolvedSportIdForSlot(_AvailabilitySlotData slot) {
    if (slot.session?.sportID != null && slot.session!.sportID > 0) {
      return slot.session!.sportID;
    }

    final availabilitySportIds =
        _availability?.sessions
            .map((session) => session.sportID)
            .where((sportId) => sportId > 0)
            .toSet()
            .toList(growable: false) ??
        const <int>[];
    if (availabilitySportIds.length == 1) {
      return availabilitySportIds.first;
    }

    if (widget.coachSportId != null && widget.coachSportId! > 0) {
      return widget.coachSportId;
    }

    return _sportIdFromText(widget.coachSport);
  }

  List<_AvailabilityRowData> _buildRows() {
    final availability = _availability;
    if (availability == null) {
      return _visibleAvailableDays
          .map(
            (day) => _AvailabilityRowData(
              day: day,
              slots: const [],
              hasAvailabilityEntry: false,
            ),
          )
          .toList();
    }

    final orderedDays = _visibleAvailableDays.isNotEmpty
        ? _visibleAvailableDays
        : _normalizeDays([
            ...availability.dayHourSlots.map((entry) => entry.dayName),
            ...availability.upcomingAvailableDates.map(
              (entry) => entry.dayName,
            ),
          ]);

    final rows = <_AvailabilityRowData>[];
    final dayToHours = <String, List<String>>{};

    for (final day in orderedDays) {
      final dayHourEntries = availability.dayHourSlots
          .where((entry) => entry.dayName.toLowerCase() == day.toLowerCase())
          .toList(growable: false);
      final upcomingDateEntries = availability.upcomingAvailableDates
          .where((entry) => entry.dayName.toLowerCase() == day.toLowerCase())
          .toList(growable: false);

      final mappedAvailability = _buildAvailabilityEntriesForDay(
        day: day,
        dayHourEntries: dayHourEntries,
        upcomingDateEntries: upcomingDateEntries,
      );
      final hasAvailabilityEntry =
          dayHourEntries.isNotEmpty ||
          upcomingDateEntries.isNotEmpty ||
          mappedAvailability.entries.isNotEmpty;
      final slotItems = <_AvailabilitySlotData>[];

      for (final entry in mappedAvailability.entries) {
        for (final hour in entry.hours) {
          final normalizedHour = _normalizedTimeValue(hour);
          if (normalizedHour.isEmpty) {
            continue;
          }

          final alreadyExists = slotItems.any(
            (item) =>
                item.date == entry.date &&
                item.normalizedLabel == normalizedHour,
          );
          if (alreadyExists) {
            continue;
          }

          slotItems.add(
            _AvailabilitySlotData(
              day: day,
              date: entry.date,
              formattedDate: entry.formattedDate,
              label: _formatTime(hour),
              normalizedLabel: normalizedHour,
              requestStartTime: hour,
              rawSourceTime: hour,
              session: _matchSessionForAvailabilitySlot(
                availability: availability,
                day: day,
                date: entry.date,
                normalizedHour: normalizedHour,
              ),
            ),
          );
        }
      }

      final rawRenderedHours = slotItems
          .map((slot) => slot.label)
          .toList(growable: false);
      final dedupedSlotItems = _dedupeRenderedSlots(slotItems);
      dayToHours[day] = dedupedSlotItems
          .map((slot) => slot.label)
          .toList(growable: false);
      debugPrint(
        'BookSessionSheet dayName=$day source=${mappedAvailability.source} rawHours=$rawRenderedHours '
        'uniqueHours=${dedupedSlotItems.map((slot) => slot.label).toList(growable: false)}',
      );

      rows.add(
        _AvailabilityRowData(
          day: day,
          slots: dedupedSlotItems,
          hasAvailabilityEntry: hasAvailabilityEntry,
        ),
      );
    }

    debugPrint('BookSessionSheet final dayToHours=$dayToHours');

    return rows;
  }

  _MappedAvailabilityResult _buildAvailabilityEntriesForDay({
    required String day,
    required List<CoachAvailabilityDateEntry> dayHourEntries,
    required List<CoachAvailabilityDateEntry> upcomingDateEntries,
  }) {
    final dayHourEntriesWithHours = dayHourEntries
        .where((entry) => entry.availableHours.isNotEmpty)
        .toList(growable: false);

    if (dayHourEntriesWithHours.isNotEmpty) {
      final fallbackDate = _firstNonEmptyDate(upcomingDateEntries);
      final fallbackFormattedDate = fallbackDate.isNotEmpty
          ? _formatDate(fallbackDate)
          : '';

      return _MappedAvailabilityResult(
        source: 'dayHourSlots',
        entries: [
          _MappedAvailabilityEntry(
            date: fallbackDate,
            formattedDate: fallbackFormattedDate,
            hours: _uniqueHoursForEntries(dayHourEntriesWithHours),
          ),
        ],
      );
    }

    final upcomingEntriesWithHours = upcomingDateEntries
        .where((entry) => entry.availableHours.isNotEmpty)
        .toList(growable: false);

    if (upcomingEntriesWithHours.isNotEmpty) {
      final uniqueHours = <String>[];
      final seenNormalizedHours = <String>{};
      final hourToDate = <String, String>{};
      final hourToFormattedDate = <String, String>{};

      for (final entry in upcomingEntriesWithHours) {
        for (final hour in entry.availableHours) {
          final normalizedHour = _normalizedTimeValue(hour);
          if (normalizedHour.isEmpty) {
            continue;
          }
          if (seenNormalizedHours.add(normalizedHour)) {
            uniqueHours.add(hour);
            hourToDate[normalizedHour] = entry.date;
            hourToFormattedDate[normalizedHour] = entry.formattedDate.isNotEmpty
                ? entry.formattedDate
                : _formatDate(entry.date);
          }
        }
      }

      return _MappedAvailabilityResult(
        source: 'upcomingAvailableDates',
        entries: uniqueHours
            .map(
              (hour) => _MappedAvailabilityEntry(
                date: hourToDate[_normalizedTimeValue(hour)] ?? '',
                formattedDate:
                    hourToFormattedDate[_normalizedTimeValue(hour)] ?? '',
                hours: [hour],
              ),
            )
            .toList(),
      );
    }

    return const _MappedAvailabilityResult(
      source: 'none',
      entries: <_MappedAvailabilityEntry>[],
    );
  }

  SessionModel? _matchSessionForAvailabilitySlot({
    required CoachAvailabilityModel availability,
    required String day,
    required String date,
    required String normalizedHour,
  }) {
    SessionModel? sameDayAndTimeFallback;

    for (final session in availability.sessions) {
      final sessionDay = _weekdayName(
        DateTime.tryParse(session.sessionDate)?.weekday ?? 0,
      );
      if (sessionDay.toLowerCase() != day.toLowerCase()) {
        continue;
      }

      if (_normalizedTimeValue(session.startTime) == normalizedHour) {
        if (date.isEmpty) {
          return session;
        }

        if (_sameCalendarDate(session.sessionDate, date)) {
          return session;
        }

        sameDayAndTimeFallback ??= session;
      }
    }
    return sameDayAndTimeFallback;
  }

  bool _sameCalendarDate(String firstRaw, String secondRaw) {
    final first = DateTime.tryParse(firstRaw);
    final second = DateTime.tryParse(secondRaw);
    if (first == null || second == null) {
      return firstRaw.trim() == secondRaw.trim();
    }

    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  List<String> _uniqueHoursForEntries(
    List<CoachAvailabilityDateEntry> entries,
  ) {
    final uniqueHours = <String>[];
    final seen = <String>{};

    for (final entry in entries) {
      for (final hour in entry.availableHours) {
        final normalizedHour = _normalizedTimeValue(hour);
        if (normalizedHour.isEmpty || !seen.add(normalizedHour)) {
          continue;
        }
        uniqueHours.add(hour);
      }
    }

    return uniqueHours;
  }

  List<_AvailabilitySlotData> _dedupeRenderedSlots(
    List<_AvailabilitySlotData> slots,
  ) {
    final uniqueSlots = <_AvailabilitySlotData>[];
    final seen = <String>{};

    for (final slot in slots) {
      final normalizedHour = _normalizedTimeValue(slot.label);
      if (normalizedHour.isEmpty) {
        continue;
      }

      if (seen.add(normalizedHour)) {
        uniqueSlots.add(
          _AvailabilitySlotData(
            day: slot.day,
            date: slot.date,
            formattedDate: slot.formattedDate,
            label: slot.label,
            normalizedLabel: normalizedHour,
            requestStartTime: slot.requestStartTime,
            rawSourceTime: slot.rawSourceTime,
            session: slot.session,
          ),
        );
      }
    }

    return uniqueSlots;
  }

  String _firstNonEmptyDate(List<CoachAvailabilityDateEntry> entries) {
    for (final entry in entries) {
      if (entry.date.isNotEmpty) {
        return entry.date;
      }
    }
    return '';
  }

  int _availableHoursCountForDate(_AvailabilityRowData row) {
    if (row.slots.isNotEmpty) {
      return row.slots.length;
    }
    return 0;
  }

  void _selectSlot(_AvailabilitySlotData slot, _AvailabilityRowData row) {
    final slotState = _slotVisualState(slot);
    if (slotState == _AvailabilityVisualState.reserved) {
      _showSlotMessage(
        title: 'Already reserved',
        message:
            'This period is already confirmed by the coach and cannot be reserved.',
      );
      return;
    }

    if (slotState == _AvailabilityVisualState.pending) {
      _showSlotMessage(
        title: 'Pending confirmation',
        message:
            'This period is still pending coach confirmation. Please choose another available time.',
      );
      return;
    }

    developer.log(
      'BookSessionSheet selectedDay=${row.day} '
      'selectedDate=${slot.date.isNotEmpty ? slot.date : 'none'} '
      'selectedHour=${slot.requestStartTime} '
      'selectedDisplayHour=${slot.label} '
      'selectedRawSourceHour=${slot.rawSourceTime} '
      'selectedSessionId=${slot.session?.sessionID} '
      'selectedSportId=${slot.session?.sportID} '
      'availableHoursCount=${_availableHoursCountForDate(row)}',
      name: 'BookSessionSheet',
    );
    print(
      '[BookSessionSheet] selectedDay=${row.day} '
      'selectedDate=${slot.date.isNotEmpty ? slot.date : 'none'} '
      'selectedHour=${slot.requestStartTime} '
      'selectedDisplayHour=${slot.label} '
      'selectedRawSourceHour=${slot.rawSourceTime} '
      'selectedSessionId=${slot.session?.sessionID} '
      'selectedSportId=${slot.session?.sportID} '
      'availableHoursCount=${_availableHoursCountForDate(row)}',
    );

    setState(() {
      _selectedDay = row.day;
      _selectedSlot = slot;
    });
  }

  void _showSlotMessage({required String title, required String message}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _ensureClientProfileComplete() async {
    setState(() => _isCheckingProfile = true);
    try {
      final user = await _authRepository.getCurrentUser();
      final prefs = await UserPreferencesStorage.load();
      final cache = await ClientProfileStorage.load();
      final missing = ProfileValidators.missingClientProfileFields(
        profilePicture: (user.profilePicture?.trim().isNotEmpty ?? false)
            ? user.profilePicture
            : cache.imageUrl,
        phone: (user.phoneNumber?.trim().isNotEmpty ?? false)
            ? user.phoneNumber
            : cache.phone,
        location: _firstNonEmpty([user.city, user.street, cache.location]),
        sports: prefs.sports,
      );
      if (missing.isEmpty) {
        return true;
      }
      if (!mounted) {
        return false;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => _ProfileRequiredDialog(missing: missing),
      );
      return false;
    } catch (_) {
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not check your profile right now. Please try again.',
          ),
        ),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _isCheckingProfile = false);
      }
    }
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  _AvailabilityVisualState _slotVisualState(_AvailabilitySlotData slot) {
    final weeklySlotStatus = _matchingWeeklySlotStatus(slot);
    if (weeklySlotStatus != null) {
      final normalizedWeeklyStatus = normalizeBookingStatus(
        weeklySlotStatus.reservationStatus,
      );
      if (normalizedWeeklyStatus == 'pending') {
        return _AvailabilityVisualState.pending;
      }
      if (normalizedWeeklyStatus == 'confirmed' ||
          normalizedWeeklyStatus == 'completed') {
        return _AvailabilityVisualState.reserved;
      }
      if ((weeklySlotStatus.confirmedBookings) > 0) {
        return _AvailabilityVisualState.reserved;
      }
      if ((weeklySlotStatus.pendingBookings) > 0) {
        return _AvailabilityVisualState.pending;
      }
      final availableSlots = weeklySlotStatus.availableSlots;
      if (availableSlots != null && availableSlots <= 0) {
        return _AvailabilityVisualState.reserved;
      }
    }

    final session = slot.session;
    if (session == null) {
      return _AvailabilityVisualState.free;
    }

    final normalizedReservationStatus = normalizeBookingStatus(
      session.reservationStatus ?? session.status,
    );
    if (normalizedReservationStatus == 'pending') {
      return _AvailabilityVisualState.pending;
    }
    if (normalizedReservationStatus == 'confirmed' ||
        normalizedReservationStatus == 'completed') {
      return _AvailabilityVisualState.reserved;
    }
    if (normalizedReservationStatus == 'cancelled') {
      return _AvailabilityVisualState.free;
    }

    if ((session.confirmedBookings ?? 0) > 0) {
      return _AvailabilityVisualState.reserved;
    }
    if ((session.pendingBookings ?? 0) > 0) {
      return _AvailabilityVisualState.pending;
    }

    final availableSlots = session.availableSlots;
    if (availableSlots != null && availableSlots <= 0) {
      return _AvailabilityVisualState.reserved;
    }

    final bookedCount = session.bookedCount;
    if ((bookedCount ?? 0) > 0) {
      return _AvailabilityVisualState.reserved;
    }

    final normalizedStatus = normalizeBookingStatus(session.status);
    if (normalizedStatus == 'pending') {
      return _AvailabilityVisualState.pending;
    }
    if (normalizedStatus == 'confirmed' || normalizedStatus == 'completed') {
      return _AvailabilityVisualState.reserved;
    }
    if (normalizedStatus == 'cancelled') {
      return _AvailabilityVisualState.free;
    }

    final raw = session.status.trim().toLowerCase();
    if (raw.contains('free') ||
        raw.contains('open') ||
        raw.contains('available')) {
      return _AvailabilityVisualState.free;
    }

    return _AvailabilityVisualState.reserved;
  }

  CoachWeeklySlotStatus? _matchingWeeklySlotStatus(_AvailabilitySlotData slot) {
    final availability = _availability;
    if (availability == null) {
      return null;
    }

    final normalizedHour = _normalizedTimeValue(slot.label);
    for (final weeklyStatus in availability.weeklySlotStatuses) {
      if (weeklyStatus.dayName.trim().toLowerCase() !=
          slot.day.trim().toLowerCase()) {
        continue;
      }
      if (_normalizedTimeValue(weeklyStatus.hour) != normalizedHour) {
        continue;
      }
      return weeklyStatus;
    }
    return null;
  }

  Color _slotBackgroundColor({
    required _AvailabilitySlotData slot,
    required bool selected,
  }) {
    if (selected) {
      return _selectedSlotColor;
    }

    switch (_slotVisualState(slot)) {
      case _AvailabilityVisualState.free:
        return _freeSlotColor;
      case _AvailabilityVisualState.pending:
        return _pendingSlotColor;
      case _AvailabilityVisualState.reserved:
        return _reservedSlotColor;
    }
  }

  Color _slotTextColor({
    required _AvailabilitySlotData slot,
    required bool selected,
  }) {
    if (selected) {
      return Colors.white;
    }

    switch (_slotVisualState(slot)) {
      case _AvailabilityVisualState.pending:
        return Colors.black87;
      case _AvailabilityVisualState.free:
      case _AvailabilityVisualState.reserved:
        return Colors.white;
    }
  }

  bool get _canContinueBooking {
    final slot = _selectedSlot;
    if (slot == null || _selectedDay == null) {
      return false;
    }
    if (_slotVisualState(slot) != _AvailabilityVisualState.free) {
      return false;
    }
    if (slot.session != null) {
      return true;
    }
    return slot.date.isNotEmpty &&
        slot.requestStartTime.trim().isNotEmpty &&
        _resolvedCoachId() != null &&
        _resolvedSportIdForSlot(slot) != null;
  }

  int get _price {
    if (widget.coachPrice > 0) {
      return widget.coachPrice;
    }
    return 500;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows();
    final hasAnyAvailabilityRow = rows
        .where((row) => row.hasAvailabilityEntry || row.slots.isNotEmpty)
        .isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available days',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: const [
                _AvailabilityLegendChip(
                  color: _freeSlotColor,
                  label: 'Free',
                  textColor: Colors.white,
                ),
                _AvailabilityLegendChip(
                  color: _pendingSlotColor,
                  label: 'Pending',
                  textColor: Colors.black87,
                ),
                _AvailabilityLegendChip(
                  color: _reservedSlotColor,
                  label: 'Reserved',
                  textColor: Colors.white,
                ),
                _AvailabilityLegendChip(
                  color: _selectedSlotColor,
                  label: 'Selected',
                  textColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: TextButton(
                        onPressed: _loadAvailability,
                        child: Text(_error!),
                      ),
                    )
                  : !hasAnyAvailabilityRow
                  ? const Center(
                      child: Text(
                        'This coach has no available hours yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 22, color: Colors.grey.shade300),
                      itemBuilder: (context, index) {
                        final row = rows[index];

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 95,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  row.day,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: row.slots.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        row.hasAvailabilityEntry
                                            ? 'No available time slots for this day'
                                            : 'This coach has no available hours yet',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: row.slots.map((slot) {
                                        final selected =
                                            _selectedSlot?.slotKey ==
                                                slot.slotKey &&
                                            _selectedDay == row.day;

                                        return GestureDetector(
                                          onTap: () => _selectSlot(slot, row),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _slotBackgroundColor(
                                                slot: slot,
                                                selected: selected,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.05),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              slot.label,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: _slotTextColor(
                                                  slot: slot,
                                                  selected: selected,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: !_canContinueBooking || _isCheckingProfile
                    ? null
                    : () async {
                        final canBook = await _ensureClientProfileComplete();
                        if (!canBook || !mounted) {
                          return;
                        }
                        final slot = _selectedSlot!;
                        final resolvedCoachId = _resolvedCoachId();
                        final resolvedSportId = _resolvedSportIdForSlot(slot);
                        developer.log(
                          'BookSessionSheet continue booking -> '
                          'inputCoachId=${widget.coachId} '
                          'resolvedCoachId=$resolvedCoachId '
                          'resolvedSportId=$resolvedSportId '
                          'sessionId=${slot.session?.sessionID} '
                          'sessionDate=${slot.date} '
                          'requestStartTime=${slot.requestStartTime} '
                          'displayTime=${slot.label} '
                          'rawSourceTime=${slot.rawSourceTime}',
                          name: 'BookSessionSheet',
                        );
                        print(
                          '[BookSessionSheet] continue booking -> '
                          'inputCoachId=${widget.coachId} '
                          'resolvedCoachId=$resolvedCoachId '
                          'resolvedSportId=$resolvedSportId '
                          'sessionId=${slot.session?.sessionID} '
                          'sessionDate=${slot.date} '
                          'requestStartTime=${slot.requestStartTime} '
                          'displayTime=${slot.label} '
                          'rawSourceTime=${slot.rawSourceTime}',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              sessionID: slot.session?.sessionID,
                              coachID: resolvedCoachId,
                              sportID: resolvedSportId,
                              sessionDate: slot.date.isNotEmpty
                                  ? slot.date
                                  : null,
                              startTime: slot.requestStartTime,
                              day: slot.formattedDate.isNotEmpty
                                  ? slot.formattedDate
                                  : slot.day,
                              time: slot.label,
                              coachName: widget.coachName,
                              coachSport: widget.coachSport,
                              coachImage: widget.coachImage,
                              coachPrice: _price,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF304FFE),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: _isCheckingProfile
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityRowData {
  final String day;
  final List<_AvailabilitySlotData> slots;
  final bool hasAvailabilityEntry;

  const _AvailabilityRowData({
    required this.day,
    required this.slots,
    required this.hasAvailabilityEntry,
  });
}

class _AvailabilitySlotData {
  final String day;
  final String date;
  final String formattedDate;
  final String label;
  final String normalizedLabel;
  final String requestStartTime;
  final String rawSourceTime;
  final SessionModel? session;

  const _AvailabilitySlotData({
    required this.day,
    required this.date,
    required this.formattedDate,
    required this.label,
    required this.normalizedLabel,
    required this.requestStartTime,
    required this.rawSourceTime,
    this.session,
  });

  String get slotKey => '$day|$date|$normalizedLabel';
}

class _MappedAvailabilityEntry {
  final String date;
  final String formattedDate;
  final List<String> hours;

  const _MappedAvailabilityEntry({
    required this.date,
    required this.formattedDate,
    required this.hours,
  });
}

class _MappedAvailabilityResult {
  final String source;
  final List<_MappedAvailabilityEntry> entries;

  const _MappedAvailabilityResult({
    required this.source,
    required this.entries,
  });
}

enum _AvailabilityVisualState { free, pending, reserved }

class _AvailabilityLegendChip extends StatelessWidget {
  final Color color;
  final String label;
  final Color textColor;

  const _AvailabilityLegendChip({
    required this.color,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _ProfileRequiredDialog extends StatelessWidget {
  final List<String> missing;

  const _ProfileRequiredDialog({required this.missing});

  @override
  Widget build(BuildContext context) {
    final items = <_ProfileRequirement>[
      _ProfileRequirement(
        key: 'profile photo',
        label: 'Profile photo',
        icon: Icons.account_circle_outlined,
      ),
      _ProfileRequirement(
        key: 'valid Egyptian phone number',
        label: 'Phone number',
        icon: Icons.phone_iphone_outlined,
      ),
      _ProfileRequirement(
        key: 'Cairo/Giza area',
        label: 'Location',
        icon: Icons.location_on_outlined,
      ),
      _ProfileRequirement(
        key: 'preferred sport',
        label: 'Preferred sport',
        icon: Icons.sports_soccer_outlined,
      ),
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
      contentPadding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: const Text(
        'Complete your profile',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We need these details before booking so coaches can confirm your session safely.',
            style: TextStyle(color: Colors.black54, height: 1.35),
          ),
          const SizedBox(height: 16),
          ...items.map((item) {
            final isMissing = missing.contains(item.key);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMissing
                    ? const Color(0xFFFFF3F3)
                    : const Color(0xFFEFFAF2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    isMissing
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    color: isMissing
                        ? const Color(0xFFD64545)
                        : const Color(0xFF16A34A),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Icon(item.icon, color: const Color(0xFF1F3A93), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F3A93),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Go to Profile'),
          ),
        ),
      ],
    );
  }
}

class _ProfileRequirement {
  final String key;
  final String label;
  final IconData icon;

  const _ProfileRequirement({
    required this.key,
    required this.label,
    required this.icon,
  });
}
