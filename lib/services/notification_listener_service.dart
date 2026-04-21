import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/services/notification_service.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';

/// A provider that sets up listeners on data providers and triggers
/// role-based local push notifications when relevant data changes occur.
final notificationListenerProvider = Provider<void>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return;

  final isAdmin = currentUser.role == UserRole.admin || currentUser.role == UserRole.superAdmin;

  // Listen to MOU Requests
  ref.listen<AsyncValue<List<MouRequestEntity>>>(mouRequestProvider, (previous, next) {
    if (previous == null || previous.isLoading) return;
    
    final prevList = previous.value ?? [];
    final nextList = next.value ?? [];

    for (final newReq in nextList) {
      final oldReq = prevList.where((r) => r.id == newReq.id).firstOrNull;
      
      if (oldReq == null) {
        // New request created
        if (isAdmin) {
          PushNotificationService.instance.showNotification(
            title: 'New MOU Request', 
            body: 'A new MOU request was submitted for ${newReq.patientName}.'
          );
        }
      } else if (oldReq.status != newReq.status) {
        // Status changed
        if (newReq.requesterId == currentUser.id) {
          if (newReq.status == RequestStatus.approved) {
            PushNotificationService.instance.showNotification(
              title: 'MOU Approved', 
              body: 'Your MOU request for ${newReq.patientName} was approved.'
            );
          } else if (newReq.status == RequestStatus.rejected) {
            PushNotificationService.instance.showNotification(
              title: 'MOU Rejected', 
              body: 'Your MOU request for ${newReq.patientName} was rejected.'
            );
          }
        } else if (isAdmin && newReq.status == RequestStatus.waitingAdmin) {
           PushNotificationService.instance.showNotification(
              title: 'MOU Escalated', 
              body: 'An MOU request for ${newReq.patientName} needs your final approval.'
            );
        }
      }
    }
  });

  // Listen to General Requests
  ref.listen<AsyncValue<List<GeneralRequestEntity>>>(generalRequestProvider, (previous, next) {
    if (previous == null || previous.isLoading) return;
    final prevList = previous.value ?? [];
    final nextList = next.value ?? [];

    for (final newReq in nextList) {
      final oldReq = prevList.where((r) => r.id == newReq.id).firstOrNull;
      
      if (oldReq == null) {
        if (isAdmin) {
          PushNotificationService.instance.showNotification(
            title: 'New Request', 
            body: '${newReq.requesterName} submitted a new ${newReq.requestType.displayLabel}.'
          );
        }
      } else if (oldReq.status != newReq.status) {
        if (newReq.requesterId == currentUser.id) {
           if (newReq.status == RequestStatus.approved) {
            PushNotificationService.instance.showNotification(
              title: 'Request Approved', 
              body: 'Your ${newReq.requestType.displayLabel} was approved.'
            );
          } else if (newReq.status == RequestStatus.rejected) {
            PushNotificationService.instance.showNotification(
              title: 'Request Rejected', 
              body: 'Your ${newReq.requestType.displayLabel} was rejected.'
            );
          }
        }
      }
    }
  });

  // Listen to Tasks
  ref.listen<AsyncValue<List<TaskEntity>>>(taskProvider, (previous, next) {
    if (previous == null || previous.isLoading) return;
    final prevList = previous.value ?? [];
    final nextList = next.value ?? [];

    for (final newTask in nextList) {
      final oldTask = prevList.where((t) => t.id == newTask.id).firstOrNull;
      
      if (oldTask == null) {
        // New Task
        if (newTask.assignedToId == currentUser.id) {
          PushNotificationService.instance.showNotification(
            title: 'New Task Assigned', 
            body: 'You have been assigned: "${newTask.title}".'
          );
        }
      } else if (oldTask.status != newTask.status) {
        if (newTask.assignedToId == currentUser.id) {
          if (newTask.status == TaskStatus.approved) {
            PushNotificationService.instance.showNotification(
              title: 'Task Approved', 
              body: 'Your submission for "${newTask.title}" was approved.'
            );
          } else if (newTask.status == TaskStatus.rejected) {
            PushNotificationService.instance.showNotification(
              title: 'Task Rejected', 
              body: 'Your submission for "${newTask.title}" was rejected.'
            );
          }
        } else if (isAdmin) {
          if (newTask.status == TaskStatus.submitted) {
            PushNotificationService.instance.showNotification(
              title: 'Task Submitted', 
              body: '${newTask.assignedToName} submitted "${newTask.title}" for review.'
            );
          } else if (newTask.status == TaskStatus.waitingAdmin) {
            PushNotificationService.instance.showNotification(
              title: 'Task Escalated', 
              body: '"${newTask.title}" needs Admin approval.'
            );
          }
        }
      }
    }
  });

});
