public class RPL_SendEmailToEligibleStudents implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	public String driveId;
	public String eligibleNotificationTemplate = Label.RPL_Eligible_Drive_Notifcation_Template;
	public String eligibleNotificationToFatherTemplate = Label.RPL_Drive_Registration_Message_Email_Template_To_Father;
	public String eligibleNotificationToMotherTemplate = Label.RPL_Drive_Registration_Message_Email_Template_To_Mother;
	public String studentPortalLink = Label.RPL_Student_Portal_Link;

	private Map<String, String> smsMap = new Map<String, String>();
	private Map<String, String> smsMapToParent = new Map<String, String>();

	public RPL_SendEmailToEligibleStudents(String driveId) {
		this.driveId = driveId;
	}

	@InvocableMethod(label='Activate Drive And Send Notificaiton To Eligible Students')
	public static void activateRPL_SendEmailToEligibleStudentsBatch(List<String> driveId) {
		Database.executeBatch(new RPL_SendEmailToEligibleStudents(driveId[0]), 30);
	}

	public Database.QueryLocator start(Database.BatchableContext context) {
		// Query the records you want to process
		String query =
			'SELECT Id, Rpl_Student_Registration__r.Contact__c, Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c, Rpl_Student_Registration__r.Rpl_Contact_No__c, Rpl_Student_Registration__r.Name, Rpl_Placement_Drive__r.Rpl_Company_Name__r.Name, Rpl_Placement_Drive__r.Rpl_Event_End_Date__c, Rpl_Placement_Drive__r.Rpl_For_Graduating_Year__c, Rpl_Placement_Drive__r.Rpl_Application_End_Time__c, Rpl_Student_Registration__r.Contact__r.Father__r.Email, Rpl_Student_Registration__r.Contact__r.Father__r.Name, Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone, Rpl_Student_Registration__r.Contact__r.Father__c, Rpl_Student_Registration__r.Contact__r.Mother__c, Rpl_Student_Registration__r.Contact__r.Mother__r.Email, Rpl_Student_Registration__r.Contact__r.Mother__r.Name, Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone  FROM Rpl_Student_Registration_Drive__c Where Rpl_Placement_Drive__c = \'' +
			this.driveId +
			'\' AND Rpl_Student_Registration__r.Contact__r.Email != NULL';
		return Database.getQueryLocator(query);
	}

	// Execute method to perform the actual processing
	public void execute(Database.BatchableContext context, List<Rpl_Student_Registration_Drive__c> scope) {
		Set<String> userIds = new Set<String>();

		List<Rpl_Student_Registration_Drive__c> studentRegDriveToUpdate = new List<Rpl_Student_Registration_Drive__c>();

		Map<String, Map<String, String>> toAddressToValues = new Map<String, Map<String, String>>();

		for (Rpl_Student_Registration_Drive__c eachStudentRegistrationDrive : scope) {
			Map<String, Map<String, String>> phoneNumberToValues = new Map<String, Map<String, String>>();
			// Updating Rpl_Is_Notification_Email_Sent__c to true and updating.

			// Send Email notification
			List<String> toAddresses = new List<String>();
			if (eachStudentRegistrationDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c != null) {
				Map<String, String> whatsAppvalues = new Map<String, String>();
				String studentName = eachStudentRegistrationDrive.Rpl_Student_Registration__r.Name != null
					? eachStudentRegistrationDrive.Rpl_Student_Registration__r.Name
					: 'REVA Student';
				String companyName = eachStudentRegistrationDrive.Rpl_Placement_Drive__r.Rpl_Company_Name__r.Name != null
					? eachStudentRegistrationDrive.Rpl_Placement_Drive__r.Rpl_Company_Name__r.Name
					: '____';
				String registrationEndDate = String.valueOf(
					eachStudentRegistrationDrive.Rpl_Placement_Drive__r.Rpl_Event_End_Date__c
				);
				String forGraduatingYear = eachStudentRegistrationDrive.Rpl_Placement_Drive__r.Rpl_For_Graduating_Year__c !=
					null
					? String.valueOf(eachStudentRegistrationDrive.Rpl_Placement_Drive__r.Rpl_For_Graduating_Year__c)
					: '____';
				String contactNumber = String.valueOf(
					eachStudentRegistrationDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c
				);
				String endTime = '11:59 PM';
				if (eachStudentRegistrationDrive.Rpl_Placement_Drive__r.Rpl_Application_End_Time__c != null) {
					String hour = String.valueOf(
						eachStudentRegistrationDrive.Rpl_Placement_Drive__r.Rpl_Application_End_Time__c.hour()
					);
					hour = hour == '0' ? '12' : hour;
					String minute = String.valueOf(
						eachStudentRegistrationDrive.Rpl_Placement_Drive__r.Rpl_Application_End_Time__c.minute()
					);
					String AMorPM = eachStudentRegistrationDrive.Rpl_Placement_Drive__r.Rpl_Application_End_Time__c.hour() >= 12
						? 'PM'
						: 'AM';
					endTime = hour + ':' + minute + ' ' + AMorPM;
				}

				whatsAppvalues.put('studentname', studentName);
				whatsAppvalues.put('date', registrationEndDate);
				whatsAppvalues.put('companyname', companyName);
				whatsAppvalues.put('graduatingyear', forGraduatingYear);
				whatsAppvalues.put('time', endTime);
				whatsAppvalues.put('registrationurl', studentPortalLink);

				phoneNumberToValues.put(
					eachStudentRegistrationDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c,
					whatsAppvalues
				);
				try {
					Rpl_UtilityClass.sendWhatsAppNotification('drive_intimation_registration_copy1', phoneNumberToValues);
					eachStudentRegistrationDrive.Rpl_Is_Notification_Email_Sent__c = true;
					studentRegDriveToUpdate.add(eachStudentRegistrationDrive);
				} catch (Exception e) {
					ErrorLogUtility.logError(e);
				}
				String message =
					'Dear ' +
					studentName +
					', ' +
					companyName +
					' Hiring Process has been scheduled for ' +
					forGraduatingYear +
					' graduating batch. Please register yourself if, interested. Last date to register is ' +
					registrationEndDate +
					' before ' +
					endTime +
					'. Check email for more information. REVA UNIVERSITY';
				smsMap.put(eachStudentRegistrationDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c, message);

				if (eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone != null) {
					Map<String, Map<String, String>> phoneNumberToValuesMother = new Map<String, Map<String, String>>();
					whatsAppvalues.put(
						'parentname',
						eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Name
					);
					phoneNumberToValuesMother.put(
						eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone,
						whatsAppvalues
					);
					try {
						Rpl_UtilityClass.sendWhatsAppNotification(
							'drive_intimation_registration_message2',
							phoneNumberToValuesMother
						);
						eachStudentRegistrationDrive.Rpl_Is_Notification_Email_Sent__c = true;
					} catch (Exception e) {
						ErrorLogUtility.logError(e);
					}
					String messageToMother =
						'Dear ' +
						eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Name +
						' ' +
						companyName +
						' Hiring Process has been scheduled for ' +
						forGraduatingYear +
						' graduating batch. Please inform your ward to register themselves, if interested. Last date to register is ' +
						registrationEndDate +
						' before ' +
						endTime +
						'. Check email for more information. REVA University';
					smsMapToParent.put(
						eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone,
						messageToMother
					);
				}
				if (eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone != null) {
					Map<String, Map<String, String>> phoneNumberToValuesFather = new Map<String, Map<String, String>>();
					whatsAppvalues.put(
						'parentname',
						eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Name
					);
					phoneNumberToValuesFather.put(
						eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
						whatsAppvalues
					);
					try {
						Rpl_UtilityClass.sendWhatsAppNotification(
							'drive_intimation_registration_message2',
							phoneNumberToValuesFather
						);
						eachStudentRegistrationDrive.Rpl_Is_Notification_Email_Sent__c = true;
					} catch (Exception e) {
						ErrorLogUtility.logError(e);
					}
					String messageToFather =
						'Dear ' +
						eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Name +
						' ' +
						companyName +
						' Hiring Process has been scheduled for ' +
						forGraduatingYear +
						' graduating batch. Please inform your ward to register themselves, if interested. Last date to register is ' +
						registrationEndDate +
						' before ' +
						endTime +
						'. Check email for more information. REVA University';
					smsMapToParent.put(
						eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
						messageToFather
					);
				}
			}

			// Rpl_UtilityClass.whatsappDriveIntimationNotification(studentName ,companyName , registrationEndDate, '11:59 PM', forGraduatingYear, studentPortalLink, contactNumber);
			if (!String.isEmpty(eachStudentRegistrationDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c)) {
				// Rpl_UtilityClass.sendEmailsUsingTemplate(eligibleNotificationTemplate, eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__c, eachStudentRegistrationDrive.Id, toAddresses);
				Map<String, String> emailValues = new Map<String, String>();
				emailValues.put('whatId', eachStudentRegistrationDrive.Id);
				emailValues.put('targetObjectId', eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__c);
				emailValues.put('emailTemplateId', eligibleNotificationTemplate);
				toAddressToValues.put(
					eachStudentRegistrationDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c,
					emailValues
				);
			}
			if (!String.isEmpty(eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Email)) {
				Map<String, String> emailValuesFather = new Map<String, String>();
				emailValuesFather.put('whatId', eachStudentRegistrationDrive.Id);
				emailValuesFather.put(
					'targetObjectId',
					eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Father__c
				);
				emailValuesFather.put('emailTemplateId', eligibleNotificationToFatherTemplate);
				toAddressToValues.put(
					eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Email,
					emailValuesFather
				);
			}
			if (!String.isEmpty(eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Email)) {
				Map<String, String> emailValuesMother = new Map<String, String>();
				emailValuesMother.put('whatId', eachStudentRegistrationDrive.Id);
				emailValuesMother.put(
					'targetObjectId',
					eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Mother__c
				);
				emailValuesMother.put('emailTemplateId', eligibleNotificationToMotherTemplate);
				toAddressToValues.put(
					eachStudentRegistrationDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Email,
					emailValuesMother
				);
			}
		}

		if (!toAddressToValues.isEmpty()) {
			try {
				Rpl_UtilityClass.sendEmailsUsingTemplate(toAddressToValues);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}

		if (!studentRegDriveToUpdate.isEmpty()) {
			try {
				update studentRegDriveToUpdate;
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
	}

	// Finish method to perform any post-processing
	public void finish(Database.BatchableContext context) {
		if (!smsMap.isEmpty()) {
			try {
				Rpl_UtilityClass.sendSMS('Drive Intimation Message Template', smsMap);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
		if (!smsMapToParent.isEmpty()) {
			try {
				Rpl_UtilityClass.sendSMS('Drive registration to parent', smsMapToParent);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}

		// Perform any post-processing logic here
	}
}