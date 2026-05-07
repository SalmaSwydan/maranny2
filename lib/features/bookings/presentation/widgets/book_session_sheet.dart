import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../../data/models/bookings_models.dart';
import '../../data/repositories/bookings_repository.dart';
import '../screens/payment_screen.dart';

class BookSessionSheet extends StatefulWidget {
  final int? coachId;
  final String coachName;
  final String coachSport;
  final String coachImage;
  final int coachPrice;
  final List<String> availableDays;

  const BookSessionSheet({
    super.key,
    this.coachId,
    this.coachName = 'Coach',
    this.coachSport = 'Coach',
    this.coachImage = '',
    this.coachPrice = 500,
    this.availableDays = const [],
  });

  @override
  State<BookSessionSheet> createState() => _BookSessionSheetState();
}

class _BookSessionSheetState extends State<BookSessionSheet> {
  final BookingsRepository _repo = BookingsRepository();

  bool _isLoading = true;
  String? _error;
  CoachAvailabilityModel? _availability;
  List<String> _visibleAvailableDays = [];
  String? _selectedDay;
  _AvailabilitySlotData? _selectedSlot;

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

    final availabilitySportIds = _availability?.sessions
            .map((session) => session.sportID)
            .where((sportId) => sportId > 0)
            .toSet()
            .toList(growable: false) ??
        const <int>[];
    if (availabilitySportIds.length == 1) {
      return availabilitySportIds.first;
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
    for (final session in availability.sessions) {
      final sessionDay = _weekdayName(
        DateTime.tryParse(session.sessionDate)?.weekday ?? 0,
      );
      if (sessionDay.toLowerCase() != day.toLowerCase()) {
        continue;
      }

      if (date.isNotEmpty && session.sessionDate != date) {
        continue;
      }

      if (_normalizedTimeValue(session.startTime) == normalizedHour) {
        return session;
      }
    }
    return null;
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

  bool get _canContinueBooking {
    final slot = _selectedSlot;
    if (slot == null || _selectedDay == null) {
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
                                              color: selected
                                                  ? const Color(0xFF304FFE)
                                                  : Colors.white,
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
                                                color: selected
                                                    ? Colors.white
                                                    : Colors.black87,
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
                onPressed: !_canContinueBooking
                    ? null
                    : () {
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
                child: const Text(
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
