import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import '../data/entities.dart';
import '../data/mock_repositories.dart';
import '../data/repositories.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPOSITORY PROVIDERS  (swap MockXxx → HttpXxx when API is ready)
// ─────────────────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<IAuthRepository>(
  (_) => MockAuthRepository(),
);
final volunteerRepositoryProvider = Provider<IVolunteerRepository>(
  (_) => MockVolunteerRepository(),
);
final memberRepositoryProvider = Provider<IMemberRepository>(
  (_) => MockMemberRepository(),
);
final taskRepositoryProvider = Provider<ITaskRepository>(
  (_) => MockTaskRepository(),
);
final donationRepositoryProvider = Provider<IDonationRepository>(
  (_) => MockDonationRepository(),
);
final generalRequestRepositoryProvider = Provider<IGeneralRequestRepository>(
  (_) => MockGeneralRequestRepository(),
);
final mouRequestRepositoryProvider = Provider<IMouRequestRepository>(
  (_) => MockMouRequestRepository(),
);
final joiningLetterRepositoryProvider = Provider<IJoiningLetterRepository>(
  (_) => MockJoiningLetterRepository(),
);
final documentRepositoryProvider = Provider<IDocumentRepository>(
  (_) => MockDocumentRepository(),
);
final meetingRepositoryProvider = Provider<IMeetingRepository>(
  (_) => MockMeetingRepository(),
);

// ─────────────────────────────────────────────────────────────────────────────
// VOLUNTEER STATE
// ─────────────────────────────────────────────────────────────────────────────

class VolunteerNotifier extends StateNotifier<AsyncValue<List<VolunteerEntity>>> {
  VolunteerNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IVolunteerRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(VolunteerEntity v) async {
    final created = await _repo.add(v);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> update(VolunteerEntity v) async {
    final updated = await _repo.update(v);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }
}

final volunteerProvider = StateNotifierProvider<
    VolunteerNotifier, AsyncValue<List<VolunteerEntity>>>(
  (ref) => VolunteerNotifier(ref.watch(volunteerRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// MEMBER STATE
// ─────────────────────────────────────────────────────────────────────────────

class MemberNotifier extends StateNotifier<AsyncValue<List<MemberEntity>>> {
  MemberNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IMemberRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(MemberEntity m) async {
    final created = await _repo.add(m);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> update(MemberEntity m) async {
    final updated = await _repo.update(m);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }
}

final memberProvider =
    StateNotifierProvider<MemberNotifier, AsyncValue<List<MemberEntity>>>(
  (ref) => MemberNotifier(ref.watch(memberRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// TASK STATE
// ─────────────────────────────────────────────────────────────────────────────

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  TaskNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final ITaskRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(TaskEntity t) async {
    final created = await _repo.add(t);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> updateStatus(int taskId, TaskStatus status) async {
    final updated = await _repo.updateStatus(taskId, status);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }

  Future<void> submit(int taskId, {String? imagePath}) async {
    final repo = _repo;
    final current = state.value?.firstWhere((t) => t.id == taskId);
    if (current == null) return;
    final updated = await repo.update(
      current.copyWith(
        status:        TaskStatus.submitted,
        submittedAt:   AppFormatters.today(),
        uploadedImage: imagePath ?? current.uploadedImage,
      ),
    );
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }
}

final taskProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskEntity>>>(
  (ref) => TaskNotifier(ref.watch(taskRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// DONATION STATE
// ─────────────────────────────────────────────────────────────────────────────

class DonationNotifier extends StateNotifier<AsyncValue<List<DonationEntity>>> {
  DonationNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IDonationRepository _repo;
  int _receiptCounter = 5;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(DonationEntity d) async {
    final created = await _repo.add(d);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> generateReceipt(int donationId) async {
    _receiptCounter++;
    final receiptNo =
        'RCP-2025-${_receiptCounter.toString().padLeft(3, '0')}';
    final updated = await _repo.generateReceipt(donationId, receiptNo);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }
}

final donationProvider =
    StateNotifierProvider<DonationNotifier, AsyncValue<List<DonationEntity>>>(
  (ref) => DonationNotifier(ref.watch(donationRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// GENERAL REQUEST STATE
// ─────────────────────────────────────────────────────────────────────────────

class GeneralRequestNotifier
    extends StateNotifier<AsyncValue<List<GeneralRequestEntity>>> {
  GeneralRequestNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IGeneralRequestRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(GeneralRequestEntity r) async {
    final created = await _repo.add(r);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> approve(int id) async {
    final updated = await _repo.updateStatus(id, RequestStatus.approved);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }

  Future<void> reject(int id) async {
    final updated = await _repo.updateStatus(id, RequestStatus.rejected);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }
}

final generalRequestProvider = StateNotifierProvider<GeneralRequestNotifier,
    AsyncValue<List<GeneralRequestEntity>>>(
  (ref) =>
      GeneralRequestNotifier(ref.watch(generalRequestRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// MOU REQUEST STATE
// ─────────────────────────────────────────────────────────────────────────────

class MouRequestNotifier
    extends StateNotifier<AsyncValue<List<MouRequestEntity>>> {
  MouRequestNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IMouRequestRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(MouRequestEntity r) async {
    final created = await _repo.add(r);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> approve(int id) async {
    final updated = await _repo.updateStatus(id, RequestStatus.approved);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }

  Future<void> reject(int id) async {
    final updated = await _repo.updateStatus(id, RequestStatus.rejected);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }
}

final mouRequestProvider = StateNotifierProvider<MouRequestNotifier,
    AsyncValue<List<MouRequestEntity>>>(
  (ref) => MouRequestNotifier(ref.watch(mouRequestRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// JOINING LETTER STATE
// ─────────────────────────────────────────────────────────────────────────────

class JoiningLetterNotifier
    extends StateNotifier<AsyncValue<List<JoiningLetterRequestEntity>>> {
  JoiningLetterNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IJoiningLetterRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(JoiningLetterRequestEntity r) async {
    final created = await _repo.add(r);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> approve(
    int id, {
    required String generatedBy,
    required String tenure,
  }) async {
    final updated = await _repo.approve(
      id,
      generatedBy: generatedBy,
      tenure:      tenure,
    );
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }

  Future<void> reject(int id) async {
    final updated = await _repo.reject(id);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }
}

final joiningLetterProvider = StateNotifierProvider<JoiningLetterNotifier,
    AsyncValue<List<JoiningLetterRequestEntity>>>(
  (ref) => JoiningLetterNotifier(ref.watch(joiningLetterRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// DOCUMENT STATE
// ─────────────────────────────────────────────────────────────────────────────

final documentProvider =
    FutureProvider<List<DocumentEntity>>((ref) async {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.getAll();
});

// ─────────────────────────────────────────────────────────────────────────────
// MEETING STATE
// ─────────────────────────────────────────────────────────────────────────────

class MeetingNotifier extends StateNotifier<AsyncValue<List<MeetingEntity>>> {
  MeetingNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IMeetingRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> addSummary(
    int meetingId, {
    required String summary,
    String? addedBy,
  }) async {
    final updated = await _repo.addSummary(
      meetingId,
      summary:  summary,
      addedBy:  addedBy ?? 'Member',
    );
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }
}

final meetingProvider =
    StateNotifierProvider<MeetingNotifier, AsyncValue<List<MeetingEntity>>>(
  (ref) => MeetingNotifier(ref.watch(meetingRepositoryProvider)),
);