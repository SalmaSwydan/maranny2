import 'package:flutter/material.dart';

/// Usage:
///   SafetyModerationScreen(userType: 'client')  ← client side menu
///   SafetyModerationScreen(userType: 'coach')   ← coach side menu
class SafetyModerationScreen extends StatefulWidget {
  final String userType;
  const SafetyModerationScreen({super.key, required this.userType});

  @override
  State<SafetyModerationScreen> createState() =>
      _SafetyModerationScreenState();
}

class _SafetyModerationScreenState
    extends State<SafetyModerationScreen> {
  static const _blue1 = Color(0xFF1F3A93);
  static const _blue2 = Color(0xFF6FD3F5);

  bool get _isCoach => widget.userType == 'coach';

  // ─── Blocked list (mock) ──────────────────────────────────
  late List<_BlockedPerson> _blockedList;

  // ─── Report form ──────────────────────────────────────────
  final _targetController = TextEditingController();
  final _descriptionController = TextEditingController();
  late Map<String, bool> _reasons;

  // ─── Report history (mock) ────────────────────────────────
  late List<_ReportRecord> _reportHistory;

  @override
  void initState() {
    super.initState();
    if (_isCoach) {
      // Coach sees blocked trainees
      _blockedList = [
        _BlockedPerson(
            name: 'Sara Khalil',
            role: 'Trainee',
            date: '2024-03-05'),
      ];
      // Coach-specific report reasons
      _reasons = {
        'No-show / Repeated cancellations': false,
        'Inappropriate behavior': false,
        'Harassment': false,
        'Abusive language': false,
        'Fraud / Fake booking': false,
        'Other': false,
      };
      _reportHistory = [
        _ReportRecord(
            name: 'Omar Saleh',
            date: '2024-06-10',
            tag: 'No-show',
            description:
            'Client did not show up and ignored all follow-up messages.'),
      ];
    } else {
      // Client sees blocked coaches
      _blockedList = [
        _BlockedPerson(
            name: 'Hossam Ali',
            role: 'Coach',
            date: '2024-01-10'),
        _BlockedPerson(
            name: 'Medhat Ali',
            role: 'Coach',
            date: '2025-01-11'),
      ];
      // Client-specific report reasons — reporting a COACH
      _reasons = {
        'Fake or misleading profile': false,
        'Unprofessional conduct': false,
        'Inappropriate behavior': false,
        'No-show / Session not delivered': false,
        'Overcharging / Payment fraud': false,
        'Harassment': false,
        'Other': false,
      };
      _reportHistory = [
        _ReportRecord(
            name: 'Ahmed Fawzy',
            date: '2024-05-15',
            tag: 'Inappropriate behavior',
            description:
            'Sent inappropriate messages during the session.'),
      ];
    }
  }

  @override
  void dispose() {
    _targetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _unblock(_BlockedPerson person) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Unblock'),
        content: Text(
            'Are you sure you want to unblock ${person.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _blockedList.remove(person));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                  Text('${person.name} has been unblocked')));
            },
            child: const Text('Unblock',
                style: TextStyle(color: _blue1)),
          ),
        ],
      ),
    );
  }

  void _submitReport() {
    final anyChecked = _reasons.values.any((v) => v);
    if (_targetController.text.trim().isEmpty || !anyChecked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Please fill in the name/email and select a reason.')));
      return;
    }
    final tag = _reasons.entries
        .firstWhere((e) => e.value,
        orElse: () => const MapEntry('Other', true))
        .key;
    setState(() {
      _reportHistory.insert(
          0,
          _ReportRecord(
            name: _targetController.text.trim(),
            date: DateTime.now().toIso8601String().substring(0, 10),
            tag: tag,
            description: _descriptionController.text.trim().isEmpty
                ? 'No description provided'
                : _descriptionController.text.trim(),
          ));
      _targetController.clear();
      _descriptionController.clear();
      _reasons.updateAll((_, __) => false);
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Report Submitted'),
        ]),
        content: const Text(
            'Thank you. Our moderation team will review your report shortly.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                  style: TextStyle(color: _blue1))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBlockedSection(),
                const SizedBox(height: 12),
                _buildBlockInfoBox(),
                const SizedBox(height: 16),
                _buildReportForm(),
                const SizedBox(height: 16),
                _buildReportHistory(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [_blue1, _blue2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 20, 16),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Text('Safety & Moderation',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ]),
        ),
      ),
    );
  }

  // ─── Blocked section ──────────────────────────────────────
  Widget _buildBlockedSection() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.block, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              _isCoach ? 'Blocked Trainees' : 'Blocked Coaches',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ]),
          const SizedBox(height: 12),
          if (_blockedList.isEmpty)
            Text(
              _isCoach
                  ? 'You have no blocked trainees.'
                  : 'You have no blocked coaches.',
              style: const TextStyle(color: Colors.grey),
            ),
          ..._blockedList.map((p) =>
              _BlockedTile(person: p, onUnblock: () => _unblock(p))),
        ],
      ),
    );
  }

  // ─── Block info box ───────────────────────────────────────
  Widget _buildBlockInfoBox() {
    final items = _isCoach
        ? [
      "They can't view your coach profile",
      "They can't book sessions with you",
      "They can't send you messages",
      "They won't appear in your client list",
    ]
        : [
      "They can't find your profile",
      "They can't book sessions with you",
      "They can't message you",
      "You won't see their availability",
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: _blue2.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isCoach
                ? 'What happens when you block a trainee?'
                : 'What happens when you block a coach?',
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _blue1),
          ),
          const SizedBox(height: 8),
          ...items.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✓ ',
                    style: TextStyle(
                        color: _blue1,
                        fontWeight: FontWeight.bold)),
                Expanded(
                    child: Text(t,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ─── Report form ──────────────────────────────────────────
  Widget _buildReportForm() {
    // Labels change based on role
    final reportTitle =
    _isCoach ? 'Report a Trainee' : 'Report a Coach';
    final reportSubtitle = _isCoach
        ? 'Report a trainee for misconduct or policy violations.'
        : 'Report a coach for unprofessional conduct or policy violations.';
    final fieldLabel =
    _isCoach ? 'Trainee Name or Email' : 'Coach Name or Email';
    final fieldHint = _isCoach
        ? "Enter the trainee's name or email"
        : "Enter the coach's name or email";

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(children: [
            const Icon(Icons.warning_amber_outlined,
                color: Colors.orange, size: 22),
            const SizedBox(width: 8),
            Text(reportTitle,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 6),
          Text(reportSubtitle,
              style:
              const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          // Name / email field
          _FieldLabel(fieldLabel),
          const SizedBox(height: 6),
          _TextField1(controller: _targetController, hint: fieldHint),
          const SizedBox(height: 14),

          // Reasons
          const _FieldLabel('Reason for Report'),
          const SizedBox(height: 6),
          ..._reasons.keys.map((r) => _CheckRow(
            label: r,
            value: _reasons[r]!,
            onChanged: (v) =>
                setState(() => _reasons[r] = v!),
          )),
          const SizedBox(height: 12),

          // Description
          const _FieldLabel('Description'),
          const SizedBox(height: 6),
          _TextField1(
            controller: _descriptionController,
            hint:
            'Describe what happened. Include dates, times and any relevant details.',
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitReport,
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Submit Report',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Important info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️  Important Information',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.orange)),
                const SizedBox(height: 8),
                ...[
                  'All reports are reviewed by our moderation team',
                  'Reports are kept confidential',
                  'False reports may result in account restrictions',
                  'We take all reports seriously and act accordingly',
                ].map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text('✓ ',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      Expanded(
                          child: Text(t,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Report history ───────────────────────────────────────
  Widget _buildReportHistory() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Report History',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_reportHistory.isEmpty)
            const Text('No reports submitted yet.',
                style: TextStyle(color: Colors.grey)),
          ..._reportHistory.map((r) => _HistoryTile(r)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────
class _BlockedPerson {
  final String name, role, date;
  _BlockedPerson(
      {required this.name, required this.role, required this.date});
}

class _ReportRecord {
  final String name, date, tag, description;
  _ReportRecord(
      {required this.name,
        required this.date,
        required this.tag,
        required this.description});
}

// ─────────────────────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2))
      ],
    ),
    child: child,
  );
}

class _BlockedTile extends StatelessWidget {
  final _BlockedPerson person;
  final VoidCallback onUnblock;
  const _BlockedTile(
      {required this.person, required this.onUnblock});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade300,
          child: Text(person.name[0],
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${person.role} • Blocked on ${person.date}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
              ],
            )),
        TextButton(
          onPressed: onUnblock,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF1F3A93),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFF1F3A93)),
            ),
          ),
          child: const Text('Unblock',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _CheckRow(
      {required this.label,
        required this.value,
        required this.onChanged});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onChanged(!value),
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF1F3A93),
          materialTapTargetSize:
          MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13))),
      ]),
    ),
  );
}

class _HistoryTile extends StatelessWidget {
  final _ReportRecord record;
  const _HistoryTile(this.record);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                  child: Text(record.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13))),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(record.tag,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(record.date,
                style:
                const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(record.description,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black87)),
          ]),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600));
}

class _TextField1 extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _TextField1(
      {required this.controller,
        required this.hint,
        this.maxLines = 1});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        const TextStyle(fontSize: 12, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            const BorderSide(color: Color(0xFF1F3A93))),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
      ),
    );
  }
}