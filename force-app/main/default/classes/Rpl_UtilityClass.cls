/**
 * @description       : This utility is used for sending email
 * @author            : Kiruba Sankar M
 * @group             :
 * @last modified on  : 08-11-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/

public class Rpl_UtilityClass {
	public static void sendEmailWithPlainTextBody(Map<String, Map<String, String>> toAddressToValues) {
		if (!toAddressToValues.isEmpty()) {
            
            OrgWideEmailAddress owea = new OrgWideEmailAddress();
            owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='REVA University'];
   
			Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>{};
             
			for (String toAddress : toAddressToValues.keySet()) {
				Map<String, String> value = toAddressToValues.get(toAddress);
				String emailSubject = value.get('subject');
				String emailBody = value.get('body');
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if ( owea != null) {
                  email.setOrgWideEmailAddressId(owea.Id);
                }
				email.setSubject(emailSubject);
				email.setPlainTextBody(emailBody);
				List<String> toAddresses = new List<String>{ toAddress };
				email.setToAddresses(toAddresses);

				emails.add(email);
			}

			try {
				Messaging.sendEmail(emails);
			} catch (Exception e) {
				// Log the error using ErrorLogUtility
				ErrorLogUtility.logError(e);
			}
		}
	}

	public static void sendEmailWithAttachment(
		String emailSubject,
		String emailBody,
		String[] toAddresses,
		Blob attachmentBody,
		String attachmentName
	) {
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setSubject(emailSubject);
		email.setPlainTextBody(emailBody);
		email.setToAddresses(toAddresses);

		// Create Email File Attachment To Attach With Email
		Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
		emailAttachment.setFileName(attachmentName);
		emailAttachment.setBody(attachmentBody);

		// Attach the attachments
		email.setFileAttachments(new List<Messaging.EmailFileAttachment>{ emailAttachment });

		try {
			Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
		} catch (Exception e) {
			// Log the error using ErrorLogUtility
			ErrorLogUtility.logError(e);
		}
	}

	public static void sendEmailsUsingTemplate(Map<String, Map<String, String>> toAddressToValues) {
		if (!toAddressToValues.isEmpty()) {
            
            //New lines of code added on 21-o5-2024
            OrgWideEmailAddress owea = new OrgWideEmailAddress();
            owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='REVA University'];
            
            
			Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>{};
			for (String toAddress : toAddressToValues.keySet()) {
				Map<String, String> value = toAddressToValues.get(toAddress);

				String emailTemplateId = value.get('emailTemplateId');
				String targetObjectId = value.get('targetObjectId');
				String whatId = value.get('whatId');

				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				List<String> toAddresses = new List<String>{ toAddress };
                 if ( owea != null) {
                  email.setOrgWideEmailAddressId(owea.Id);
                }

				email.setTemplateId(emailTemplateId);
				email.setTargetObjectId(targetObjectId);
				/* email.setToAddresses(toAddresses); */
				email.setWhatId(whatId);

				emails.add(email);
			}

			try {
				Messaging.sendEmail(emails);
			} catch (Exception e) {
				// Log the error using ErrorLogUtility
				ErrorLogUtility.logError(e);
			}
		}
	}

	public static void sendWhatsAppNotification(String templateId, Map<String, Map<String, String>> phoneNumberToValues) {
		// Map of phoneNumber to comma separated values
		//String studentName, String sdate, String toNumber

		// Fetch keys from custom metadata based on templateid
		//List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c, Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = templateId];
		List<WhatsApp_Notification_Template__mdt> templateMetadata = [
			SELECT Template_Field__c, Template_ID__c
			FROM WhatsApp_Notification_Template__mdt
			WHERE Template_ID__c = :templateId
		];

		// Initialize the params map

		if (!templateMetadata.isEmpty()) {
			Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

			WhatsApp_Notification_Template__mdt metadata = templateMetadata[0];
			String[] keys = metadata.Template_Field__c.split(',');

			for (String phoneNumber : phoneNumberToValues.keySet()) {
				Map<String, String> values = phoneNumberToValues.get(phoneNumber);

				List<Yellow_AI_Utility.WhatsAppNotification> whatsappNotificationList = new List<Yellow_AI_Utility.WhatsAppNotification>();

				Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
				notification.templateId = templateId;
				notification.params = new Map<String, String>();

				for (String key : keys) {
					// Set static values for each key
					// Modify these lines to set your specific static values
					if (key.trim().equals('studentname')) {
						notification.params.put(key.trim(), values.get('studentname'));
					} else if (key.trim().equals('date')) {
						notification.params.put(key.trim(), values.get('date'));
					} else if (key.trim().equals('companyname')) {
						notification.params.put(key.trim(), values.get('companyname'));
					} else if (key.trim().equals('registrationurl')) {
						notification.params.put(key.trim(), values.get('registrationurl'));
					} else if (key.trim().equals('time')) {
						notification.params.put(key.trim(), values.get('time'));
					} else if (key.trim().equals('graduatingyear')) {
						notification.params.put(key.trim(), values.get('graduatingyear'));
					} else if (key.trim().equals('venue')) {
						notification.params.put(key.trim(), values.get('venue'));
					} else if (key.trim().equals('parentname')) {
						notification.params.put(key.trim(), values.get('parentname'));
					} else if (key.trim().equals('complanyname')) {
						notification.params.put(key.trim(), values.get('complanyname'));
					}
				}
				whatsappNotificationList.add(notification);
				phoneNumbersToNotifications.put(phoneNumber, whatsappNotificationList);
			}

			if (!phoneNumbersToNotifications.isEmpty()) {
				Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
			}
		}
	}

	@Future(callOut=true)
	public static void sendWhatsAppNotificationAsync(String templateId, String jsonString) {
		// Map of phoneNumber to comma separated values
		//String studentName, String sdate, String toNumber
		Map<String, Object> phoneNumberToValues = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
		// Fetch keys from custom metadata based on templateid
		//List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c, Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = templateId];
		List<WhatsApp_Notification_Template__mdt> templateMetadata = [
			SELECT Template_Field__c, Template_ID__c
			FROM WhatsApp_Notification_Template__mdt
			WHERE Template_ID__c = :templateId
		];

		// Initialize the params map

		if (!templateMetadata.isEmpty()) {
			Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

			WhatsApp_Notification_Template__mdt metadata = templateMetadata[0];
			String[] keys = metadata.Template_Field__c.split(',');

			for (String phoneNumber : phoneNumberToValues.keySet()) {
				Map<String, Object> values = (Map<String, Object>) phoneNumberToValues.get(phoneNumber);

				List<Yellow_AI_Utility.WhatsAppNotification> whatsappNotificationList = new List<Yellow_AI_Utility.WhatsAppNotification>();

				Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
				notification.templateId = templateId;
				notification.params = new Map<String, String>();

				for (String key : keys) {
					// Set static values for each key
					// Modify these lines to set your specific static values
					if (key.trim().equals('studentname')) {
						notification.params.put(key.trim(), (String) values.get('studentname'));
					} else if (key.trim().equals('date')) {
						notification.params.put(key.trim(), (String) values.get('date'));
					} else if (key.trim().equals('companyname')) {
						notification.params.put(key.trim(), (String) values.get('companyname'));
					} else if (key.trim().equals('registrationurl')) {
						notification.params.put(key.trim(), (String) values.get('registrationurl'));
					} else if (key.trim().equals('time')) {
						notification.params.put(key.trim(), (String) values.get('time'));
					} else if (key.trim().equals('graduatingyear')) {
						notification.params.put(key.trim(), (String) values.get('graduatingyear'));
					} else if (key.trim().equals('venue')) {
						notification.params.put(key.trim(), (String) values.get('venue'));
					} else if (key.trim().equals('parentname')) {
						notification.params.put(key.trim(), (String) values.get('parentname'));
					}
				}
				whatsappNotificationList.add(notification);
				phoneNumbersToNotifications.put(phoneNumber, whatsappNotificationList);
			}

			if (!phoneNumbersToNotifications.isEmpty()) {
				Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
			}
		}
	}

	public static void sendSMS(String SmsType, Map<String, String> toNumberMapsMessage) {
		List<SMS_API_Utility.shortMessageWrp> messages = new List<SMS_API_Utility.shortMessageWrp>();
		for (String phoneNumber : toNumberMapsMessage.keySet()) {
			SMS_API_Utility.shortMessageWrp messageWrapper = new SMS_API_Utility.shortMessageWrp();
			messageWrapper.message = toNumberMapsMessage.get(phoneNumber);
			messageWrapper.recipient = phoneNumber;
			messages.add(messageWrapper);
		}

		if (!messages.isEmpty()) {
            if(!Test.isrunningTest()){
                SMS_API_Utility.SendSMSOneToMany(SmsType, messages);
            }
			
		}
	}

	@Future(callOut=true)
	public static void sendSMSAsync(String SmsType, Map<String, String> toNumberMapsMessage) {
		List<SMS_API_Utility.shortMessageWrp> messages = new List<SMS_API_Utility.shortMessageWrp>();
		for (String phoneNumber : toNumberMapsMessage.keySet()) {
			SMS_API_Utility.shortMessageWrp messageWrapper = new SMS_API_Utility.shortMessageWrp();
			messageWrapper.message = toNumberMapsMessage.get(phoneNumber);
			messageWrapper.recipient = phoneNumber;
			messages.add(messageWrapper);
		}

		if (!messages.isEmpty()) {
            if(!Test.isrunningTest()){
			SMS_API_Utility.SendSMSOneToMany(SmsType, messages);
            }
		}
	}
}