import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import 'entities.dart';
import 'mock_data_source.dart';
import 'repositories.dart';

// ── Shared helper ─────────────────────────────────────────────────────────────

/// Simulates a 200ms network round-trip so loading states are visible in the UI.
Future<T> _delay<T>(T value) async {
  await Future<void>.delayed(const Duration(milliseconds: 200));
  return value;
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH
// ─────────────────────────────────────────────────────────────────────────────

class MockAuthRepository implements IAuthRepository {
  @override
  Future<UserEntity?> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // Mock: any password works as long as the email matches a known user.
    try {
      return MockDataSource.users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {}
}

// ─────────────────────────────────────────────────────────────────────────────
// VOLUNTEERS
// ─────────────────────────────────────────────────────────────────────────────

class MockVolunteerRepository implements IVolunteerRepository {
  final List<VolunteerEntity> _data =
      List.from(MockDataSource.volunteers);

  @override
  Future<List<VolunteerEntity>> getAll() => _delay(List.unmodifiable(_data));

  @override
  Future<VolunteerEntity?> getById(int id) =>
      _delay(_data.where((v) => v.id == id).firstOrNull);

  @override
  Future<VolunteerEntity> add(VolunteerEntity volunteer) async {
    final withId = volunteer.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(withId);
    return _delay(withId);
  }

  @override
  Future<VolunteerEntity> update(VolunteerEntity volunteer) async {
    final i = _data.indexWhere((v) => v.id == volunteer.id);
    if (i != -1) _data[i] = volunteer;
    return _delay(volunteer);
  }

  @override
  Future<void> delete(int id) async {
    _data.removeWhere((v) => v.id == id);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEMBERS
// ─────────────────────────────────────────────────────────────────────────────

class MockMemberRepository implements IMemberRepository {
  final List<MemberEntity> _data = List.from(MockDataSource.members);

  @override
  Future<List<MemberEntity>> getAll() => _delay(List.unmodifiable(_data));

  @override
  Future<MemberEntity?> getById(int id) =>
      _delay(_data.where((m) => m.id == id).firstOrNull);

  @override
  Future<MemberEntity> add(MemberEntity member) async {
    final withId = member.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(withId);
    return _delay(withId);
  }

  @override
  Future<MemberEntity> update(MemberEntity member) async {
    final i = _data.indexWhere((m) => m.id == member.id);
    if (i != -1) _data[i] = member;
    return _delay(member);
  }

  @override
  Future<void> delete(int id) async {
    _data.removeWhere((m) => m.id == id);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TASKS
// ─────────────────────────────────────────────────────────────────────────────

class MockTaskRepository implements ITaskRepository {
  final List<TaskEntity> _data = List.from(MockDataSource.tasks);

  @override
  Future<List<TaskEntity>> getAll() => _delay(List.unmodifiable(_data));

  @override
  Future<List<TaskEntity>> getByAssignee(
    int assigneeId,
    AssigneeType type,
  ) =>
      _delay(_data
          .where((t) =>
              t.assignedToId == assigneeId && t.assignedToType == type)
          .toList());

  @override
  Future<TaskEntity> add(TaskEntity task) async {
    final withId = task.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(withId);
    return _delay(withId);
  }

  @override
  Future<TaskEntity> update(TaskEntity task) async {
    final i = _data.indexWhere((t) => t.id == task.id);
    if (i != -1) _data[i] = task;
    return _delay(task);
  }

  @override
  Future<TaskEntity> updateStatus(int taskId, TaskStatus status) async {
    final i = _data.indexWhere((t) => t.id == taskId);
    if (i == -1) throw StateError('Task $taskId not found');
    final updated = _data[i].copyWith(
      status: status,
      submittedAt: status == TaskStatus.submitted
          ? AppFormatters.today()
          : _data[i].submittedAt,
    );
    _data[i] = updated;
    return _delay(updated);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DONATIONS
// ─────────────────────────────────────────────────────────────────────────────

class MockDonationRepository implements IDonationRepository {
  final List<DonationEntity> _data = List.from(MockDataSource.donations);

  @override
  Future<List<DonationEntity>> getAll() => _delay(List.unmodifiable(_data));

  @override
  Future<DonationEntity> add(DonationEntity donation) async {
    final withId =
        donation.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(withId);
    return _delay(withId);
  }

  @override
  Future<DonationEntity> generateReceipt(
    int donationId,
    String receiptNumber,
  ) async {
    final i = _data.indexWhere((d) => d.id == donationId);
    if (i == -1) throw StateError('Donation $donationId not found');
    final updated = _data[i].copyWith(
      receiptGenerated: true,
      receiptNumber:    receiptNumber,
    );
    _data[i] = updated;
    return _delay(updated);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GENERAL REQUESTS
// ─────────────────────────────────────────────────────────────────────────────

class MockGeneralRequestRepository implements IGeneralRequestRepository {
  final List<GeneralRequestEntity> _data =
      List.from(MockDataSource.generalRequests);

  @override
  Future<List<GeneralRequestEntity>> getAll() =>
      _delay(List.unmodifiable(_data));

  @override
  Future<GeneralRequestEntity> add(GeneralRequestEntity request) async {
    final withId =
        request.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(withId);
    return _delay(withId);
  }

  @override
  Future<GeneralRequestEntity> updateStatus(
    int id,
    RequestStatus status,
  ) async {
    final i = _data.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('Request $id not found');
    final updated = _data[i].copyWith(status: status);
    _data[i] = updated;
    return _delay(updated);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOU REQUESTS
// ─────────────────────────────────────────────────────────────────────────────

class MockMouRequestRepository implements IMouRequestRepository {
  final List<MouRequestEntity> _data = List.from(MockDataSource.mouRequests);

  @override
  Future<List<MouRequestEntity>> getAll() => _delay(List.unmodifiable(_data));

  @override
  Future<MouRequestEntity> add(MouRequestEntity request) async {
    final withId =
        request.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(withId);
    return _delay(withId);
  }

  @override
  Future<MouRequestEntity> updateStatus(
    int id,
    RequestStatus status,
  ) async {
    final i = _data.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('MOU Request $id not found');
    final updated = _data[i].copyWith(status: status);
    _data[i] = updated;
    return _delay(updated);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JOINING LETTER REQUESTS
// ─────────────────────────────────────────────────────────────────────────────

class MockJoiningLetterRepository implements IJoiningLetterRepository {
  final List<JoiningLetterRequestEntity> _data =
      List.from(MockDataSource.joiningLetterRequests);

  @override
  Future<List<JoiningLetterRequestEntity>> getAll() =>
      _delay(List.unmodifiable(_data));

  @override
  Future<JoiningLetterRequestEntity> add(JoiningLetterRequestEntity request) async {
    final withId = request.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(withId);
    return _delay(withId);
  }

  @override
  Future<JoiningLetterRequestEntity> approve(
    int id, {
    required String generatedBy,
    required String tenure,
  }) async {
    final i = _data.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('Joining letter request $id not found');
    final updated = _data[i].copyWith(
      status:      RequestStatus.approved,
      generatedBy: generatedBy,
      tenure:      tenure.isNotEmpty ? tenure : _data[i].tenure,
    );
    _data[i] = updated;
    return _delay(updated);
  }

  @override
  Future<JoiningLetterRequestEntity> reject(int id) async {
    final i = _data.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('Joining letter request $id not found');
    final updated = _data[i].copyWith(status: RequestStatus.rejected);
    _data[i] = updated;
    return _delay(updated);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DOCUMENTS
// ─────────────────────────────────────────────────────────────────────────────

class MockDocumentRepository implements IDocumentRepository {
  @override
  Future<List<DocumentEntity>> getAll() =>
      _delay(List.unmodifiable(MockDataSource.documents));

  @override
  Future<List<DocumentEntity>> getByCategory(String category) =>
      _delay(MockDataSource.documents
          .where((d) => d.category == category)
          .toList());
}

// ─────────────────────────────────────────────────────────────────────────────
// MEETINGS
// ─────────────────────────────────────────────────────────────────────────────

class MockMeetingRepository implements IMeetingRepository {
  final List<MeetingEntity> _data = List.from(MockDataSource.meetings);

  @override
  Future<List<MeetingEntity>> getAll() => _delay(List.unmodifiable(_data));

  @override
  Future<MeetingEntity> addSummary(
    int meetingId, {
    required String summary,
    required String addedBy,
  }) async {
    final i = _data.indexWhere((m) => m.id == meetingId);
    if (i == -1) throw StateError('Meeting $meetingId not found');
    final updated = _data[i].copyWith(
      summary:  summary,
      addedBy:  addedBy,
      status:   MeetingStatus.completed,
    );
    _data[i] = updated;
    return _delay(updated);
  }
}