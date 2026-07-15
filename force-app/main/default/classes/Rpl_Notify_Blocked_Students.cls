public class Rpl_Notify_Blocked_Students implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	public List<String> studentRegistrationDriveIds;
	public String blockedNotificationToStudent = Label.RPL_Block_Notification_To_Student;
	public string blockedNotificationToParent = Label.RPL_Block_Notification_To_Parent;
	private Map<String, String> smsMap = new Map<String, String>();
	private Map<String, String> smsMapToParent = new Map<String, String>();

	@InvocableMethod(Description='Notify Blocked Students')
	public static void notifyBlockedStudents(List<List<String>> studentRegistrationDriveIds) {
		Database.executeBatch(new Rpl_Notify_Blocked_Students(studentRegistrationDriveIds[0]), 30);
	}

	public Rpl_Notify_Blocked_Students(List<String> ids) {
		this.studentRegistrationDriveIds = ids;
	}

	public Database.queryLocator start(Database.BatchableContext bc) {
		String query = 'SELECT Id, Rpl_Student_Registration__r.Contact__c, Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c, Rpl_Student_Registration__r.Rpl_Contact_No__c,Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name ,Rpl_Student_Registration__r.Name, Rpl_Placement_Drive__r.Rpl_Company_Name__r.Name, Rpl_Placement_Drive__r.Rpl_Event_End_Date__c, Rpl_Placement_Drive__r.Rpl_For_Graduating_Year__c, Rpl_Placement_Drive__r.Rpl_Application_End_Time__c, Rpl_Student_Registration__r.Contact__r.Father__r.Email, Rpl_Student_Registration__r.Contact__r.Father__r.Name, Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone, Rpl_Student_Registration__r.Contact__r.Father__c, Rpl_Student_Registration__r.Contact__r.Mother__c, Rpl_Student_Registration__r.Contact__r.Mother__r.Email, Rpl_Student_Registration__r.Contact__r.Mother__r.Name, Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone  FROM Rpl_Student_Registration_Drive__c Where Id In: studentRegistrationDriveIds';
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<Rpl_Student_Registration_Drive__c> studentRegDriveList) {
		Map<String, Map<string, string>> toAddressToValues = new Map<String, Map<string, string>>();
		for (Rpl_Student_Registration_Drive__c eachStudentRegDrive : studentRegDriveList) {
			//Send Offered Email Notification
			if (!String.isEmpty(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c)) {
				Map<String, String> emailValues = new Map<String, String>();
				emailValues.put('whatId', eachStudentRegDrive.Id);
				emailValues.put('targetObjectId', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__c);
				emailValues.put('emailTemplateId', blockedNotificationToStudent);
				toAddressToValues.put(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c, emailValues);
			}
			if (!String.isEmpty(eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Email)) {
				Map<String, String> emailValuesFather = new Map<String, String>();
				emailValuesFather.put('whatId', eachStudentRegDrive.Id);
				emailValuesFather.put('targetObjectId', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__c);
				emailValuesFather.put('emailTemplateId', blockedNotificationToParent);
				toAddressToValues.put(
					eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Email,
					emailValuesFather
				);
			}
			if (!String.isEmpty(eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Email)) {
				Map<String, String> emailValuesMother = new Map<String, String>();
				emailValuesMother.put('whatId', eachStudentRegDrive.Id);
				emailValuesMother.put('targetObjectId', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__c);
				emailValuesMother.put('emailTemplateId', blockedNotificationToParent);
				toAddressToValues.put(
					eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Email,
					emailValuesMother
				);
			}

			//Send Whatsapp and SMS Notification
			if (eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c != null) {
				Map<String, Map<string, string>> blockedWhatsappNotification = new Map<String, Map<string, string>>();
				Map<String, String> whatsAppvalues = new Map<String, String>();
				whatsAppvalues.put('studentname', eachStudentRegDrive.Rpl_Student_Registration__r.Name);
				whatsAppvalues.put(
					'companyname',
					eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name
				);
				whatsAppvalues.put('whatsAppType', 'status_blocked_notification_student');
				blockedWhatsappNotification.put(
					eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c,
					whatsAppvalues
				);
				String smsMessage =
					'Dear ' +
					eachStudentRegDrive.Rpl_Student_Registration__r.Name +
					', Please be informed that we have not received confirmation of your attendance for ' +
					eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name +
					' placement drive. As a result your registration is currently Blocked. Contact CDC to get the status changed. REVA University';
				smsMap.put(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c, smsMessage);
				try {
					Rpl_UtilityClass.sendWhatsAppNotification('status_blocked_notification_student', blockedWhatsappNotification);
				} catch (Exception e) {
					ErrorLogUtility.logError(e);
				}
			}
			if (eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone != null) {
				Map<String, Map<string, string>> blockedWhatsappNotification = new Map<String, Map<string, string>>();
				Map<String, String> whatsAppvalues = new Map<String, String>();
				whatsAppvalues.put('parentname', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Name);
				whatsAppvalues.put('studentname', eachStudentRegDrive.Rpl_Student_Registration__r.Name);
				whatsAppvalues.put(
					'companyname',
					eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name
				);
				whatsAppvalues.put('whatsAppType', 'status_blocked_notification_to_parents');
				blockedWhatsappNotification.put(
					eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone,
					whatsAppvalues
				);
				String smsMessage =
					'Dear Mr./Ms. ' +
					eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Name +
					', We would like to bring to your attention that, we have not received the attendance confirmation of your ward ' +
					eachStudentRegDrive.Rpl_Student_Registration__r.Name +
					' for ' +
					eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name +
					' placement drive. As a result your ward\'s placement registration is currently Blocked. REVA University';
				smsMapToParent.put(
					eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone,
					smsMessage
				);
				try {
					Rpl_UtilityClass.sendWhatsAppNotification(
						'status_blocked_notification_to_parents',
						blockedWhatsappNotification
					);
				} catch (Exception e) {
					ErrorLogUtility.logError(e);
				}
			}
			if (eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone != null) {
				Map<String, String> whatsAppvalues = new Map<String, String>();
				Map<String, Map<string, string>> blockedWhatsappNotification = new Map<String, Map<string, string>>();
				whatsAppvalues.put('parentname', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Name);
				whatsAppvalues.put(
					'companyname',
					eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name
				);
				whatsAppvalues.put('studentname', eachStudentRegDrive.Rpl_Student_Registration__r.Name);
				whatsAppvalues.put('whatsAppType', 'status_blocked_notification_to_parents');
				blockedWhatsappNotification.put(
					eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
					whatsAppvalues
				);
				String smsMessage =
					'Dear Mr./Ms. ' +
					eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Name +
					', We would like to bring to your attention that, we have not received the attendance confirmation of your ward ' +
					eachStudentRegDrive.Rpl_Student_Registration__r.Name +
					' for ' +
					eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name +
					' placement drive. As a result your ward\'s placement registration is currently Blocked. REVA University';
				smsMapToParent.put(
					eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
					smsMessage
				);
				try {
					Rpl_UtilityClass.sendWhatsAppNotification(
						'status_blocked_notification_to_parents',
						blockedWhatsappNotification
					);
				} catch (Exception e) {
					ErrorLogUtility.logError(e);
				}
			}
		}
		if (!toAddressToValues.isEmpty()) {
			try {
				Rpl_UtilityClass.sendEmailsUsingTemplate(toAddressToValues);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
	}
	public void finish(Database.BatchableContext bc) {
		if (!smsMap.isEmpty()) {
			try {
				Rpl_UtilityClass.sendSMS('Block notification to student', smsMap);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
		if (!smsMapToParent.isEmpty()) {
			try {
				Rpl_UtilityClass.sendSMS('Block notification to parent', smsMapToParent);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
	}
}