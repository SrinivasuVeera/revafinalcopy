public without sharing class RPL_AdmitCardTemplateController {
	@AuraEnabled
	public static void generateAdmitCard(
		String studentRegDriveId,
		String personalEmailId
	) {
		PageReference pageRef = Page.RPL_Admint_Card_V1;
		pageRef.getParameters().put('id', studentRegDriveId);
		Blob pdfBlob;
		try {
			pdfBlob = pageRef.getContentAsPdf();
			savePDFAsAttachment(studentRegDriveId, pdfBlob, personalEmailId);
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
		}
	}

	@AuraEnabled
	public static void savePDFAsAttachment(
		Id studentRegistrationDriveId,
		Blob pdfBlob,
		String personalEmailId
	) {
		List<Rpl_Student_Registration_Drive__c> studentRegDrive = [
			SELECT
				Id,
				Rpl_Placement_Drive__r.Name,
				Rpl_Student_Registration__r.Name,
				Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c,
				Rpl_Placement_Drive__r.Rpl_Company_Name__r.Name,
				Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c,
				Rpl_Placement_Drive__r.Rpl_Venue__c,
				Rpl_Student_Registration__r.Rpl_Contact_No__c,
				Rpl_Student_Registration__r.Contact__c,
				Rpl_Student_Registration__r.Contact__r.Father__r.Email,
				Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
				Rpl_Student_Registration__r.Contact__r.Father__r.Name,
				Rpl_Student_Registration__r.Contact__r.Mother__r.Email,
				Rpl_Student_Registration__r.Contact__r.Mother__r.Name,
				Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone,
				Rpl_Student_Registration__r.Contact__r.Father__c,
				Rpl_Student_Registration__r.Contact__r.Mother__c
			FROM Rpl_Student_Registration_Drive__c
			WHERE Id = :studentRegistrationDriveId
		];

		String attName = 'AdmitCard.pdf';
		if (!studentRegDrive.isEmpty()) {
			attName =
				studentRegDrive[0].Rpl_Placement_Drive__r.Name +
				' ' +
				'Admit Card.pdf';
		}

		if (
			studentRegDrive[0].Rpl_Student_Registration__r.Rpl_Contact_No__c != null
		) {
			Map<String, String> smsMap = new Map<String, String>();
			Map<String, String> smsMapToParent = new Map<String, String>();

			Map<String, Map<string, string>> phoneNumberToValues = new Map<String, Map<string, string>>();
			Map<String, String> whatsAppvalues = new Map<String, String>();
			String studentName = studentRegDrive[0].Rpl_Student_Registration__r.Name;
			String companyName = studentRegDrive[0]
				.Rpl_Placement_Drive__r.Rpl_Company_Name__r.Name;
			String sDate = studentRegDrive[0]
					.Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c != null
				? String.valueOf(
						studentRegDrive[0]
							.Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c.date()
				  )
				: '__________';

			String sTime = '__:__';
			if (
				studentRegDrive[0].Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c != null
			) {
				String hour = String.valueOf(
					studentRegDrive[0]
						.Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c.hour()
				);
				hour = hour == '0' ? '12' : hour;
				String minute = String.valueOf(
					studentRegDrive[0]
						.Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c.minute()
				);
				String AMorPM = studentRegDrive[0]
						.Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c.hour() >= 12
					? 'PM'
					: 'AM';
				sTime = hour + ':' + minute + ' ' + AMorPM;
			}

			String venue = studentRegDrive[0].Rpl_Placement_Drive__r.Rpl_Venue__c !=
				null
				? studentRegDrive[0].Rpl_Placement_Drive__r.Rpl_Venue__c
				: 'REVA University';
			String toNumber = String.valueOf(
				studentRegDrive[0].Rpl_Student_Registration__r.Rpl_Contact_No__c
			);
			whatsAppvalues.put('studentname', studentName);
			whatsAppvalues.put('date', sDate);
			whatsAppvalues.put('companyname', companyName);
			whatsAppvalues.put('venue', venue);
			whatsAppvalues.put('time', sTime);
			phoneNumberToValues.put(toNumber, whatsAppvalues);

			try {
				Rpl_UtilityClass.sendWhatsAppNotification(
					'drive_confirmation_copy1',
					phoneNumberToValues
				);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
			if (
				studentRegDrive[0]
					.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone != null
			) {
				Map<String, Map<String, String>> phoneNumberToValuesMother = new Map<String, Map<String, String>>();
				whatsAppvalues.put(
					'parentname',
					studentRegDrive[0]
						.Rpl_Student_Registration__r.Contact__r.Mother__r.Name
				);
				phoneNumberToValuesMother.put(
					studentRegDrive[0]
						.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone,
					whatsAppvalues
				);
				try {
					Rpl_UtilityClass.sendWhatsAppNotification(
						'drive_conformation_message',
						phoneNumberToValuesMother
					);
					studentRegDrive[0].Rpl_Is_Notification_Email_Sent__c = true;
				} catch (Exception e) {
					ErrorLogUtility.logError(e);
				}
				String smsMessage =
					'Dear ' +
					studentRegDrive[0]
						.Rpl_Student_Registration__r.Contact__r.Mother__r.Name +
					' Your ward has been shortlisted for ' +
					companyName +
					' further rounds of interview, which is scheduled on ' +
					sDate +
					' ' +
					sTime +
					' @REVA Campus. Check email. REVA University';
				smsMapToParent.put(
					studentRegDrive[0]
						.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone,
					smsMessage
				);
			}
			if (
				studentRegDrive[0]
					.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone != null
			) {
				Map<String, Map<String, String>> phoneNumberToValuesFather = new Map<String, Map<String, String>>();
				whatsAppvalues.put(
					'parentname',
					studentRegDrive[0]
						.Rpl_Student_Registration__r.Contact__r.Father__r.Name
				);
				phoneNumberToValuesFather.put(
					studentRegDrive[0]
						.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
					whatsAppvalues
				);
				try {
					Rpl_UtilityClass.sendWhatsAppNotification(
						'drive_conformation_message',
						phoneNumberToValuesFather
					);
					studentRegDrive[0].Rpl_Is_Notification_Email_Sent__c = true;
				} catch (Exception e) {
					ErrorLogUtility.logError(e);
				}
				String smsMessage =
					'Dear ' +
					studentRegDrive[0]
						.Rpl_Student_Registration__r.Contact__r.Father__r.Name +
					' Your ward has been shortlisted for ' +
					companyName +
					' further rounds of interview, which is scheduled on ' +
					sDate +
					' ' +
					sTime +
					' @REVA Campus. Check email. REVA University';
				smsMapToParent.put(
					studentRegDrive[0]
						.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
					smsMessage
				);
			}
			String smsMessageToStudent =
				'Dear ' +
				studentName +
				', You have been shortlisted for ' +
				companyName +
				' further rounds of interview, which is scheduled on ' +
				sDate +
				' ' +
				sTime +
				' @ REVA Campus. Check email. REVA University';
			smsMap.put(toNumber, smsMessageToStudent);
			if (!smsMap.isEmpty()) {
				try {
					Rpl_UtilityClass.sendSMS(
						'Drive confirmation Message Template',
						smsMap
					);
				} catch (Exception e) {
					ErrorLogUtility.logError(e);
				}
			}
			if (!smsMapToParent.isEmpty()) {
				try {
					Rpl_UtilityClass.sendSMS(
						'Drive confirmation to parent',
						smsMapToParent
					);
				} catch (Exception e) {
					ErrorLogUtility.logError(e);
				}
			}
		}

		// Send email with Admit Card attachment
		String driveConfirmationTemplateId = Label.RPL_Eligible_Drive_Confirmation_Template;
		String eligibleNotificationToFatherTemplate = Label.RPL_Drive_Confirmation_Message_Email_Template_To_Father;
		String eligibleNotificationToMotherTemplate = Label.RPL_Drive_Confirmation_Message_Email_Template_To_Mother;
		Map<String, Map<string, string>> toAddressToValues = new Map<String, Map<string, string>>();
		if (
			!String.isEmpty(
				studentRegDrive[0].Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c
			)
		) {
			Map<String, String> emailValues = new Map<String, String>();
			emailValues.put('whatId', studentRegDrive[0].Id);
			emailValues.put(
				'targetObjectId',
				studentRegDrive[0].Rpl_Student_Registration__r.Contact__c
			);
			emailValues.put('emailTemplateId', driveConfirmationTemplateId);
			toAddressToValues.put(
				studentRegDrive[0].Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c,
				emailValues
			);
			String subject = 'Admit Card';
			String body = 'Please find your Admit Card attached.';
			Blob attachmentBlob = pdfBlob;
			String[] toAddresses = new List<String>{
				studentRegDrive[0].Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c
			};
			try {
				Rpl_UtilityClass.sendEmailWithAttachment(
					subject,
					body,
					toAddresses,
					attachmentBlob,
					attName
				);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
		if (
			!String.isEmpty(
				studentRegDrive[0]
					.Rpl_Student_Registration__r.Contact__r.Father__r.Email
			)
		) {
			Map<String, String> emailValuesFather = new Map<String, String>();
			emailValuesFather.put('whatId', studentRegDrive[0].Id);
			emailValuesFather.put(
				'targetObjectId',
				studentRegDrive[0].Rpl_Student_Registration__r.Contact__r.Father__c
			);
			emailValuesFather.put(
				'emailTemplateId',
				eligibleNotificationToFatherTemplate
			);
			toAddressToValues.put(
				studentRegDrive[0]
					.Rpl_Student_Registration__r.Contact__r.Father__r.Email,
				emailValuesFather
			);
		}
		if (
			!String.isEmpty(
				studentRegDrive[0]
					.Rpl_Student_Registration__r.Contact__r.Mother__r.Email
			)
		) {
			Map<String, String> emailValuesMother = new Map<String, String>();
			emailValuesMother.put('whatId', studentRegDrive[0].Id);
			emailValuesMother.put(
				'targetObjectId',
				studentRegDrive[0].Rpl_Student_Registration__r.Contact__r.Mother__c
			);
			emailValuesMother.put(
				'emailTemplateId',
				eligibleNotificationToMotherTemplate
			);
			toAddressToValues.put(
				studentRegDrive[0]
					.Rpl_Student_Registration__r.Contact__r.Mother__r.Email,
				emailValuesMother
			);
		}
		try {
			Rpl_UtilityClass.sendEmailsUsingTemplate(toAddressToValues);
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
		}

		Attachment attachment = new Attachment();
		attachment.Body = pdfBlob;
		attachment.ParentId = studentRegistrationDriveId;
		attachment.Name = attName;
		try {
			insert attachment;
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
		}
	}
}