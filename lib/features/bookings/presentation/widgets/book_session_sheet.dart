import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../../data/models/bookings_models.dart';
import '../../data/repositories/bookings_repository.dart';
import '../screens/payment_screen.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../../core/utils/client_profile_storage.dart';
import '../../../../core/utils/profile_validators.dart';
import '../../../../core/utils/user_preferences_storage.dart';
import '../../../../layout/main_layout.dart';

class BookSessionSheet extends StatefulWidget {
  final int? coachId;
  final String coachName;
  final String coachSport;
  final int? coachSportId;
  final String coachImage;
  final int coachPrice;
  final List<String> availableDays;
  final List<String> coachLocations;

  const BookSessionSheet({
    super.key,
    this.coachId,
    this.coachName = 'Coach',
    this.coachSport = 'Coach',
    this.coachSportId,
    this.coachImage = '',
    this.coachPrice = 500,
    this.availableDays = const [],
    this.coachLocations = const [],
  });

  @override
  State<BookSessionSheet> createState() => _BookSessionSheetState();
}

class _BookSessionSheetState extends State<BookSessionSheet> {
  final BookingsRepository _repo = BookingsRepository();
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  bool _isLoading = true;
  bool _isCheckingProfile = false;
  String? _error;
  CoachAvailabilityModel? _availability;
  List<String> _visibleAvailableDays = [];
  String? _selectedDay;
  _AvailabilitySlotData? _selectedSlot;
  String? _selectedLocation;
  Map<String, int> _clientBookingCountsByDate = const {};

  static const int _maxClientBookingsPerDay = 2;

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
      _selectedDay = _dateKey(DateTime.now());
      _selectedSlot = null;
      _clientBookingCountsByDate = const {};
    });

    if (widget.coachId == null) {
      final bookingCounts = await _loadClientBookingCountsByDate();
      if (!mounted) {
        return;
      }
      setState(() {
        _visibleAvailableDays = _normalizeDays(widget.availableDays);
        _selectedDay = _dateKey(DateTime.now());
        _selectedLocation = _normalizedCoachLocations().isNotEmpty
            ? _normalizedCoachLocations().first
            : null;
        _clientBookingCountsByDate = bookingCounts;
        _isLoading = false;
      });
      return;
    }

    try {
      final availability = await _repo.getCoachAvailability(widget.coachId!);
      final bookingCounts = await _loadClientBookingCountsByDate();
      if (!mounted) {
        return;
      }

      setState(() {
        _availability = availability;
        _visibleAvailableDays = _normalizeDays(availability.availableDays);
        _selectedDay = _dateKey(DateTime.now());
        final locations = _normalizedCoachLocations(availability.locations);
        _selectedLocation = locations.isNotEmpty ? locations.first : null;
        _clientBookingCountsByDate = bookingCounts;
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

  List<String> _normalizedCoachLocations([List<String>? apiLocations]) {
    final values = <String>[];

    void addLocation(String value) {
      for (final part in value.split(',')) {
        final cleaned = part.trim();
        if (cleaned.isNotEmpty &&
            cleaned != 'Location not added yet' &&
            !values.contains(cleaned)) {
          values.add(cleaned);
        }
      }
    }

    for (final location in widget.coachLocations) {
      addLocation(location);
    }
    for (final location
        in apiLocations ?? _availability?.locations ?? const []) {
      addLocation(location);
    }

    return values;
  }

  Future<Map<String, int>> _loadClientBookingCountsByDate() async {
    try {
      final bookings = await _repo.getMyBookings();
      final counts = <String, int>{};
      for (final booking in bookings) {
        final status = normalizeBookingStatus(booking.status);
        if (status != 'pending' && status != 'confirmed') {
          continue;
        }

        final bookingDate = DateTime.tryParse(booking.session.sessionDate);
        if (bookingDate == null) {
          continue;
        }

        final dateKey = _dateKey(bookingDate);
        counts[dateKey] = (counts[dateKey] ?? 0) + 1;
      }
      return counts;
    } catch (error, stackTrace) {
      developer.log(
        'Could not load client booking counts',
        name: 'BookSessionSheet',
        error: error,
        stackTrace: stackTrace,
      );
      return const {};
    }
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

  String _weekdayShortName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  static String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().substring(0, 10);
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
    // Do not guess SportID from display text. Production sport IDs come from
    // the API and may differ between databases.
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

  List<_AvailabilityRowData> _buildNextSevenRows() {
    final sourceRows = _buildRows();
    final today = DateTime.now();

    return List<_AvailabilityRowData>.generate(7, (index) {
      final date = DateTime(today.year, today.month, today.day + index);
      final dateKey = _dateKey(date);
      final dayName = _weekdayName(date.weekday);

      _AvailabilityRowData? sourceRow;
      for (final row in sourceRows) {
        if (row.day.toLowerCase() == dayName.toLowerCase()) {
          sourceRow = row;
          break;
        }
      }

      final slots = <_AvailabilitySlotData>[];
      if (sourceRow != null) {
        for (final slot in sourceRow.slots) {
          if (slot.date.isNotEmpty && !_sameCalendarDate(slot.date, dateKey)) {
            continue;
          }

          slots.add(
            _AvailabilitySlotData(
              day: dayName,
              date: dateKey,
              formattedDate: _formatDate(dateKey),
              label: slot.label,
              normalizedLabel: slot.normalizedLabel,
              requestStartTime: slot.requestStartTime,
              rawSourceTime: slot.rawSourceTime,
              session: slot.session,
            ),
          );
        }
      }

      _addWeeklyStatusSlotsForDate(
        target: slots,
        dayName: dayName,
        dateKey: dateKey,
      );

      final dedupedSlots = _dedupeRenderedSlots(slots);
      return _AvailabilityRowData(
        day: dayName,
        date: dateKey,
        formattedDate: _formatDate(dateKey),
        dayShort: _weekdayShortName(date.weekday),
        dayNumber: date.day.toString(),
        slots: dedupedSlots,
        hasAvailabilityEntry:
            (sourceRow?.hasAvailabilityEntry ?? false) ||
            dedupedSlots.isNotEmpty,
      );
    });
  }

  void _addWeeklyStatusSlotsForDate({
    required List<_AvailabilitySlotData> target,
    required String dayName,
    required String dateKey,
  }) {
    final availability = _availability;
    if (availability == null) {
      return;
    }

    for (final status in availability.weeklySlotStatuses) {
      if (status.dayName.trim().toLowerCase() != dayName.toLowerCase()) {
        continue;
      }
      if (status.date.isNotEmpty && !_sameCalendarDate(status.date, dateKey)) {
        continue;
      }

      final normalizedHour = _normalizedTimeValue(status.hour);
      if (normalizedHour.isEmpty) {
        continue;
      }
      if (target.any((slot) => slot.normalizedLabel == normalizedHour)) {
        continue;
      }

      target.add(
        _AvailabilitySlotData(
          day: dayName,
          date: dateKey,
          formattedDate: _formatDate(dateKey),
          label: _formatTime(status.hour),
          normalizedLabel: normalizedHour,
          requestStartTime: status.hour,
          rawSourceTime: status.hour,
          session: _matchSessionForAvailabilitySlot(
            availability: availability,
            day: dayName,
            date: dateKey,
            normalizedHour: normalizedHour,
          ),
        ),
      );
    }
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
      return _MappedAvailabilityResult(
        source: 'dayHourSlots',
        entries: [
          _MappedAvailabilityEntry(
            date: '',
            formattedDate: '',
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

  int _availableHoursCountForDate(_AvailabilityRowData row) {
    if (row.slots.isNotEmpty) {
      return row.slots.length;
    }
    return 0;
  }

  bool _hasReachedClientDailyLimit(String dateKey) {
    if (dateKey.isEmpty) {
      return false;
    }
    return (_clientBookingCountsByDate[dateKey] ?? 0) >=
        _maxClientBookingsPerDay;
  }

  bool _isSlotSelectable(_AvailabilitySlotData slot, _AvailabilityRowData row) {
    return _slotVisualState(slot) == _AvailabilityVisualState.free &&
        !_hasReachedClientDailyLimit(row.date);
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
    setState(() {
      _selectedDay = row.date.isNotEmpty ? row.date : row.day;
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
      final prefs = await _loadLatestPreferences();
      final cache = await ClientProfileStorage.load();
      final missing = ProfileValidators.missingClientProfileFields(
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
      final shouldGoToProfile = await showDialog<bool>(
        context: context,
        builder: (context) => _ProfileRequiredDialog(missing: missing),
      );
      if (shouldGoToProfile == true && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainLayout(initialIndex: 4)),
          (route) => false,
        );
      }
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

  Future<UserPreferences> _loadLatestPreferences() async {
    try {
      final prefs = await _profileRepository.getPreferences();
      await UserPreferencesStorage.saveSnapshot(prefs);
      return prefs;
    } catch (_) {
      return UserPreferencesStorage.load();
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

  bool get _canContinueBooking {
    final slot = _selectedSlot;
    if (slot == null || _selectedDay == null) {
      return false;
    }
    if (_slotVisualState(slot) != _AvailabilityVisualState.free) {
      return false;
    }
    if (_hasReachedClientDailyLimit(_selectedDay ?? '')) {
      return false;
    }
    if (_normalizedCoachLocations().isNotEmpty &&
        (_selectedLocation == null || _selectedLocation!.trim().isEmpty)) {
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
    final rows = _buildNextSevenRows();
    final selectedRow = rows.firstWhere(
      (row) => row.date == _selectedDay,
      orElse: () => rows.first,
    );
    final selectedFreeSlots = selectedRow.slots
        .where((slot) => _isSlotSelectable(slot, selectedRow))
        .toList(growable: false);
    final coachLocations = _normalizedCoachLocations();

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
                'Choose a free time.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: const Color(0xFFE8EEFF),
                    backgroundImage: widget.coachImage.startsWith('http')
                        ? NetworkImage(widget.coachImage)
                        : null,
                    child: widget.coachImage.startsWith('http')
                        ? null
                        : Text(
                            widget.coachName.isNotEmpty
                                ? widget.coachName[0].toUpperCase()
                                : 'C',
                            style: const TextStyle(
                              color: Color(0xFF1F3A93),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.coachName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F3A93),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.coachSport} - $_price LE/hr',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                  : ListView(
                      children: [
                        const _PickerSectionLabel('DAY'),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 68,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: rows.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final row = rows[index];
                              final selected = row.date == selectedRow.date;
                              final freeCount = row.slots
                                  .where((slot) => _isSlotSelectable(slot, row))
                                  .length;
                              return _DaySelectorCard(
                                day: row.dayShort,
                                dateNumber: row.dayNumber,
                                freeCount: freeCount,
                                selected: selected,
                                onTap: () => setState(() {
                                  _selectedDay = row.date;
                                  _selectedSlot = null;
                                }),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        _PickerSectionLabel(
                          'FREE TIMES - ${selectedRow.dayShort} ${selectedRow.dayNumber}',
                        ),
                        const SizedBox(height: 10),
                        const _DurationNotice(),
                        const SizedBox(height: 12),
                        if (_hasReachedClientDailyLimit(selectedRow.date))
                          const _DayLimitNotice(),
                        if (selectedRow.slots.isEmpty ||
                            selectedFreeSlots.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Text(
                              'No free time slots for this day',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: selectedRow.slots.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisExtent: 46,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemBuilder: (context, index) {
                              final slot = selectedRow.slots[index];
                              final isFree = _isSlotSelectable(
                                slot,
                                selectedRow,
                              );
                              final selected =
                                  _selectedSlot?.slotKey == slot.slotKey &&
                                  _selectedDay == selectedRow.date;
                              return _TimeSlotChip(
                                label: slot.label,
                                selected: selected,
                                enabled: isFree,
                                onTap: isFree
                                    ? () => _selectSlot(slot, selectedRow)
                                    : null,
                              );
                            },
                          ),
                        if (coachLocations.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const _PickerSectionLabel('LOCATION'),
                          const SizedBox(height: 10),
                          _CoachLocationPicker(
                            locations: coachLocations,
                            selectedLocation: _selectedLocation,
                            onChanged: (value) {
                              setState(() => _selectedLocation = value);
                            },
                          ),
                        ] else ...[
                          const SizedBox(height: 22),
                          const _PickerSectionLabel('LOCATION'),
                          const SizedBox(height: 10),
                          const _LocationUnavailableNotice(),
                        ],
                      ],
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
                        if (!canBook || !context.mounted) {
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
                              location: _selectedLocation,
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
                        'Continue',
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
  final String date;
  final String formattedDate;
  final String dayShort;
  final String dayNumber;
  final List<_AvailabilitySlotData> slots;
  final bool hasAvailabilityEntry;

  const _AvailabilityRowData({
    required this.day,
    required this.slots,
    required this.hasAvailabilityEntry,
    this.date = '',
    this.formattedDate = '',
    this.dayShort = '',
    this.dayNumber = '',
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

class _PickerSectionLabel extends StatelessWidget {
  final String label;

  const _PickerSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF98A2B3),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.2,
      ),
    );
  }
}

class _DaySelectorCard extends StatelessWidget {
  final String day;
  final String dateNumber;
  final int freeCount;
  final bool selected;
  final VoidCallback onTap;

  const _DaySelectorCard({
    required this.day,
    required this.dateNumber,
    required this.freeCount,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6FD3F5) : const Color(0xFFEFF3FB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day $dateNumber',
              style: TextStyle(
                color: selected
                    ? const Color(0xFF153273)
                    : const Color(0xFF475467),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$freeCount free',
              style: TextStyle(
                color: selected
                    ? const Color(0xFF153273)
                    : const Color(0xFF667085),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _TimeSlotChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = !enabled
        ? const Color(0xFF98A2B3)
        : selected
        ? Colors.white
        : const Color(0xFF344054);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF304FFE)
              : enabled
              ? const Color(0xFFEFF3FB)
              : Colors.white.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: enabled
                ? Colors.transparent
                : const Color(0xFFD0D5DD).withValues(alpha: 0.55),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            decoration: enabled ? null : TextDecoration.lineThrough,
          ),
        ),
      ),
    );
  }
}

class _DurationNotice extends StatelessWidget {
  const _DurationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB9E6FE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF1570EF), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Please note: the session duration is 45 to 60 minutes.',
              style: TextStyle(
                color: Color(0xFF175CD3),
                fontSize: 12.5,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachLocationPicker extends StatelessWidget {
  final List<String> locations;
  final String? selectedLocation;
  final ValueChanged<String?> onChanged;

  const _CoachLocationPicker({
    required this.locations,
    required this.selectedLocation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7E0F2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:
              selectedLocation != null && locations.contains(selectedLocation)
              ? selectedLocation
              : null,
          isExpanded: true,
          hint: const Text(
            'Choose training location',
            style: TextStyle(
              color: Color(0xFF667085),
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF1F3A93),
          ),
          items: locations.map((location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF1F3A93),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF344054),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _LocationUnavailableNotice extends StatelessWidget {
  const _LocationUnavailableNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFEDC89)),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_off_outlined, color: Color(0xFFB54708), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'No coach locations are available yet.',
              style: TextStyle(
                color: Color(0xFFB54708),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayLimitNotice extends StatelessWidget {
  const _DayLimitNotice();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        'You can only book up to 2 sessions per day.',
        style: TextStyle(
          color: Color(0xFFD92D20),
          fontSize: 13,
          fontWeight: FontWeight.w700,
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
            onPressed: () => Navigator.of(context).pop(true),
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
