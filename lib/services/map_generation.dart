

import '../models/notification.dart';
import '../models/user.dart';

class MapGeneration {
 
  generateNotificationMap(NotificationModel not) {
    return {
      NotificationModel.TITLE: not.title,
      NotificationModel.BODY: not.body,
      NotificationModel.TIME: not.time,
      NotificationModel.ID: not.primaryId,
      NotificationModel.REASON: not.reason,
      NotificationModel.RECEPIENT: not.recepient,
      NotificationModel.PARTNER: not.partnerID,
      NotificationModel.SECONDARYID: not.secondaryId,
      NotificationModel.RESCHEDULER: not.rescheduler,
      NotificationModel.CUSTOMER: not.customerID,
      NotificationModel.DELETER: not.deleter,
    };
  }

   generateUserMap(UserModel user) {
    return {
      UserModel.PHONENUMBER: user.phoneNumber,
      UserModel.TIMEOFJOINING: DateTime.now().millisecondsSinceEpoch,
      UserModel.USERNAME: user.userName,
      UserModel.PROFILEPIC: user.profilePic,
      UserModel.EMAIL: user.email,
    };
  }
}
