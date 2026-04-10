import 'dart:async';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import 'entities.dart';
import 'mock_data_source.dart';
import 'repositories.dart';

// ── Auth ─────────────────────────────────────────────────────────────────────
class MockAuthRepository implements IAuthRepository {
  @override
  Future<UserEntity?> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      return MockDataSource.users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserEntity?> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      // Mocking google sign in by returning an admin
      return MockDataSource.users.firstWhere((u) => u.email == 'admin@hopeconnect.org');
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<UserEntity?> watchAuthState() => Stream.value(null);

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }
}

// ── Volunteers ───────────────────────────────────────────────────────────────
class MockVolunteerRepository implements IVolunteerRepository {
  final List<VolunteerEntity> _data = List.of(MockDataSource.volunteers);

  @override
  Future<List<VolunteerEntity>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _data;
  }

  @override
  Stream<List<VolunteerEntity>> watchAll() => Stream.fromFuture(getAll());

  @override
  Future<VolunteerEntity?> getById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _data.where((v) => v.id == id).firstOrNull;
  }

  @override
  Stream<VolunteerEntity?> watchById(int id) => Stream.fromFuture(getById(id));

  @override
  Future<VolunteerEntity> add(VolunteerEntity volunteer) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newV = volunteer.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(newV);
    return newV;
  }

  @override
  Future<VolunteerEntity> update(VolunteerEntity volunteer) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _data.indexWhere((v) => v.id == volunteer.id);
    if (idx != -1) _data[idx] = volunteer;
    return volunteer;
  }

  @override
  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _data.removeWhere((v) => v.id == id);
  }
}

// ── Members ──────────────────────────────────────────────────────────────────
class MockMemberRepository implements IMemberRepository {
  final List<MemberEntity> _data = List.of(MockDataSource.members);

  @override
  Future<List<MemberEntity>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _data;
  }

  @override
  Stream<List<MemberEntity>> watchAll() => Stream.fromFuture(getAll());

  @override
  Future<MemberEntity?> getById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _data.where((m) => m.id == id).firstOrNull;
  }

  @override
  Stream<MemberEntity?> watchById(int id) => Stream.fromFuture(getById(id));

  @override
  Future<MemberEntity> add(MemberEntity member) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newM = member.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(newM);
    return newM;
  }

  @override
  Future<MemberEntity> update(MemberEntity member) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _data.indexWhere((m) => m.id == member.id);
    if (idx != -1) _data[idx] = member;
    return member;
  }

  @override
  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _data.removeWhere((m) => m.id == id);
  }
}

// ── Tasks ────────────────────────────────────────────────────────────────────
class MockTaskRepository implements ITaskRepository {
  final List<TaskEntity> _data = List.of(MockDataSource.tasks);

  @override
  Future<List<TaskEntity>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _data;
  }

  @override
  Stream<List<TaskEntity>> watchAll() => Stream.fromFuture(getAll());

  @override
  Future<List<TaskEntity>> getByAssignee(int assigneeId, AssigneeType type) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _data.where((t) => t.assignedToId == assigneeId && t.assignedToType == type).toList();
  }

  @override
  Stream<List<TaskEntity>> watchByAssignee(int assigneeId, AssigneeType type) => Stream.fromFuture(getByAssignee(assigneeId, type));

  @override
  Future<TaskEntity> add(TaskEntity task) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newT = task.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(newT);
    return newT;
  }

  @override
  Future<TaskEntity> update(TaskEntity task) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _data.indexWhere((t) => t.id == task.id);
    if (idx != -1) _data[idx] = task;
    return task;
  }

  @override
  Future<TaskEntity> updateStatus(int taskId, TaskStatus status) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _data.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _data[idx] = _data[idx].copyWith(status: status);
      return _data[idx];
    }
    throw Exception('Task not found');
  }
}

// ── General Requests ─────────────────────────────────────────────────────────
class MockGeneralRequestRepository implements IGeneralRequestRepository {
  final List<GeneralRequestEntity> _data = List.of(MockDataSource.generalRequests);

  @override
  Future<List<GeneralRequestEntity>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _data;
  }

  @override
  Stream<List<GeneralRequestEntity>> watchAll() => Stream.fromFuture(getAll());

  @override
  Future<GeneralRequestEntity> add(GeneralRequestEntity request) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newR = request.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(newR);
    return newR;
  }

  @override
  Future<GeneralRequestEntity> updateStatus(int id, RequestStatus status) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _data.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _data[idx] = _data[idx].copyWith(status: status);
      return _data[idx];
    }
    throw Exception('Not found');
  }
}

// ── MOU Requests ─────────────────────────────────────────────────────────────
class MockMouRequestRepository implements IMouRequestRepository {
  final List<MouRequestEntity> _data = List.of(MockDataSource.mouRequests);

  @override
  Future<List<MouRequestEntity>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _data;
  }

  @override
  Stream<List<MouRequestEntity>> watchAll() => Stream.fromFuture(getAll());

  @override
  Future<MouRequestEntity> add(MouRequestEntity request) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newR = request.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(newR);
    return newR;
  }

  @override
  Future<MouRequestEntity> updateStatus(int id, RequestStatus status) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _data.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _data[idx] = _data[idx].copyWith(status: status);
      return _data[idx];
    }
    throw Exception('Not found');
  }
}

// ── Joining Letter Requests ──────────────────────────────────────────────────
class MockJoiningLetterRepository implements IJoiningLetterRepository {
  final List<JoiningLetterRequestEntity> _data = List.of(MockDataSource.joiningLetterRequests);

  @override
  Future<List<JoiningLetterRequestEntity>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _data;
  }

  @override
  Stream<List<JoiningLetterRequestEntity>> watchAll() => Stream.fromFuture(getAll());

  @override
  Future<JoiningLetterRequestEntity> add(JoiningLetterRequestEntity request) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newR = request.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    _data.add(newR);
    return newR;
  }

  @override
  Future<JoiningLetterRequestEntity> approve(int id, {required String generatedBy, required String tenure}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _data.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _data[idx] = _data[idx].copyWith(
        status: RequestStatus.approved,
        generatedBy: generatedBy,
        tenure: tenure,
      );
      return _data[idx];
    }
    throw Exception('Not found');
  }

  @override
  Future<JoiningLetterRequestEntity> reject(int id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _data.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _data[idx] = _data[idx].copyWith(status: RequestStatus.rejected);
      return _data[idx];
    }
    throw Exception('Not found');
  }
}

// ── Documents ────────────────────────────────────────────────────────────────
class MockDocumentRepository implements IDocumentRepository {
  @override
  Future<List<DocumentEntity>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockDataSource.documents;
  }

  @override
  Stream<List<DocumentEntity>> watchAll() => Stream.fromFuture(getAll());

  @override
  Future<List<DocumentEntity>> getByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockDataSource.documents.where((d) => d.category == category).toList();
  }

  @override
  Stream<List<DocumentEntity>> watchByCategory(String category) => Stream.fromFuture(getByCategory(category));
}

// ── Meetings ─────────────────────────────────────────────────────────────────
class MockMeetingRepository implements IMeetingRepository {
  final List<MeetingEntity> _data = List.of(MockDataSource.meetings);

  @override
  Future<List<MeetingEntity>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _data;
  }

  @override
  Stream<List<MeetingEntity>> watchAll() => Stream.fromFuture(getAll());

  @override
  Future<MeetingEntity> addMeeting(MeetingEntity meeting) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newId = _data.isEmpty ? 1 : _data.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;
    final entityToAdd = meeting.copyWith(id: newId);
    _data.add(entityToAdd);
    return entityToAdd;
  }

  @override
  Future<MeetingEntity> addSummary(int meetingId, {required String summary, required String addedBy}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _data.indexWhere((m) => m.id == meetingId);
    if (idx != -1) {
      _data[idx] = _data[idx].copyWith(
        summary: summary,
        addedBy: addedBy,
        status: MeetingStatus.completed,
      );
      return _data[idx];
    }
    throw Exception('Not found');
  }
}