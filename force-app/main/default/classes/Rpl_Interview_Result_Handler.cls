/**
 * @description       : This handler class handles after insert logic in Rpl_Interview_Result__C Object.
 * @author            : Kiruba Sankar M
 * @group             :
 * @last modified on  : 21-11-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/

public class Rpl_Interview_Result_Handler {
	public static void updateAfterInsert(List<Rpl_Interview_Result__c> newTrigger) {
		try {
			Set<String> SRN_Numbers = new Set<String>();
			Set<String> DriveNames = new Set<String>();
			Set<String> passedStudentRegistrationIds = new Set<String>();
			Set<String> failedStudentRegistrationIds = new Set<String>();
			Set<Decimal> roundNumber = new Set<Decimal>();
			// Extract SRN Numbers and Drive Names from the new Interview Result records
			for (Rpl_Interview_Result__c eachInterviewResult : newTrigger) {
				SRN_Numbers.add(eachInterviewResult.Rpl_SRN__c);
				DriveNames.add(eachInterviewResult.Rpl_Drive_Name__c);
				roundNumber.add(eachInterviewResult.Rpl_Round_Number__c);
			}

			if (!SRN_Numbers.isEmpty() && !DriveNames.isEmpty()) {
				// Map of SRN as key and Map<driveId, studentRegistrationDrive> as a value.
				Map<String, Map<String, Rpl_Student_Registration_Drive__c>> studentRegDriveMap = new Map<String, Map<String, Rpl_Student_Registration_Drive__c>>();

				// Query Student Registration Drive records related to the Placement Drives
				for (Rpl_Student_Registration_Drive__c drive : [
					SELECT
						Rpl_Placement_Drive__c,
						Rpl_Is_Failed__c,
						Rpl_Interview__c,
						Rpl_Interview__r.Placement_Drive__r.Name,
						Rpl_Placement_Drive__r.Rpl_CTC__c,
						Rpl_Student_Registration__r.Rpl_SRN__c,
						Rpl_Placement_Drive__r.Rpl_Total_Interview_Round__c,
						Rpl_Placement_Drive__r.Rpl_Stipend__c,
						Rpl_Interview__r.Name,
						Rpl_Is_Result_Out__c,
						Rpl_Student_Registration__r.Rpl_Companies_Got_Placed_In__c,
						Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c,
						Rpl_Interview__r.Rpl_Round_Number__c,
						Rpl_Interview__r.Rpl_Is_Final_Round__c,
						Rpl_Student_Registration__r.Rpl_University_Mail_ID__c,
						Rpl_Student_Registration__r.Contact__c,
						Rpl_Student_Registration__r.Name,
						Rpl_Student_Registration__r.Rpl_Contact_No__c,
						Rpl_Student_Registration__r.Rpl_Offer_Count__c,
						Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name,
						Rpl_Student_Registration__r.Contact__r.Father__c,
						Rpl_Student_Registration__r.Contact__r.Mother__c,
						Rpl_Student_Registration__r.Contact__r.Father__r.Email,
						Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
						Rpl_Student_Registration__r.Contact__r.Father__r.Name,
						Rpl_Student_Registration__r.Contact__r.Mother__r.Email,
						Rpl_Student_Registration__r.Contact__r.Mother__r.Name,
						Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone
					FROM Rpl_Student_Registration_Drive__c
					WHERE Rpl_Placement_Drive__r.Name IN :DriveNames AND Rpl_Student_Registration__r.Rpl_SRN__c IN :SRN_Numbers
				]) {
					if (!studentRegDriveMap.containsKey(drive.Rpl_Student_Registration__r.Rpl_SRN__c)) {
						Map<String, Rpl_Student_Registration_Drive__c> driveNameMapsStudentRegDrive = new Map<String, Rpl_Student_Registration_Drive__c>();
						driveNameMapsStudentRegDrive.put(drive.Rpl_Placement_Drive__c, drive);
						studentRegDriveMap.put(drive.Rpl_Student_Registration__r.Rpl_SRN__c, driveNameMapsStudentRegDrive);
					} else {
						Map<String, Rpl_Student_Registration_Drive__c> driveNameMapsStudentRegDrive = studentRegDriveMap.get(
							drive.Rpl_Student_Registration__r.Rpl_SRN__c
						);
						if (!driveNameMapsStudentRegDrive.containsKey(drive.Rpl_Placement_Drive__c)) {
							driveNameMapsStudentRegDrive.put(drive.Rpl_Placement_Drive__c, drive);
						}
					}
				}
				// Now even if the excel sheet has multiple drive names for the same student, the Map contains SRN as a key and Map<Drive Name, Student Registration Drive> as a key.

				if (!studentRegDriveMap.isEmpty()) {
					if (!roundNumber.isEmpty()) {
						List<Rpl_Interview__c> recruitmentStage = [
							SELECT Rpl_Is_Result_Uploaded__c
							FROM Rpl_Interview__c
							WHERE Rpl_Round_Number__c IN :roundNumber AND Placement_Drive__r.Name IN :DriveNames
						];

						if (!recruitmentStage.isEmpty() && !recruitmentStage[0].Rpl_Is_Result_Uploaded__c) {
							recruitmentStage[0].Rpl_Is_Result_Uploaded__c = true;
							update recruitmentStage;
						}
					}
					List<Rpl_Student_Registration_Drive__c> failedStudents = new List<Rpl_Student_Registration_Drive__c>();
					List<Rpl_Student_Registration_Drive__c> passedStudents = new List<Rpl_Student_Registration_Drive__c>();
					Set<String> passedStudentsDriveId = new Set<String>();
					Map<String, Rpl_Interview_Result__c> studentRegDriveIdMapsInterviewResult = new Map<String, Rpl_Interview_Result__c>();

					// Iterate through the new Interview Result records
					for (Rpl_Interview_Result__c eachInterviewResult : newTrigger) {
						if (
							studentRegDriveMap.containsKey(eachInterviewResult.Rpl_SRN__c) &&
							(eachInterviewResult.Rpl_Result__c == 'Fail' ||
							eachInterviewResult.Rpl_Result__c == 'Rejected')
						) {
							for (
								Rpl_Student_Registration_Drive__c eachStudentRegDrive : studentRegDriveMap.get(
										eachInterviewResult.Rpl_SRN__c
									)
									.values()
							) {
								failedStudents.add(eachStudentRegDrive);
								failedStudentRegistrationIds.add(eachStudentRegDrive.Rpl_Student_Registration__c);
							}
						} else if (
							studentRegDriveMap.containsKey(eachInterviewResult.Rpl_SRN__c) &&
							(eachInterviewResult.Rpl_Result__c == 'Pass' ||
							eachInterviewResult.Rpl_Result__c == 'Shortlisted' ||
							eachInterviewResult.Rpl_Result__c == 'Offered')
						) {
							for (
								Rpl_Student_Registration_Drive__c eachStudentRegDrive : studentRegDriveMap.get(
										eachInterviewResult.Rpl_SRN__c
									)
									.values()
							) {
								studentRegDriveIdMapsInterviewResult.put(eachStudentRegDrive.Id, eachInterviewResult);
								passedStudents.add(eachStudentRegDrive);
								passedStudentRegistrationIds.add(eachStudentRegDrive.Rpl_Student_Registration__c);
								passedStudentsDriveId.add(eachStudentRegDrive.Rpl_Placement_Drive__c);
							}
						}
					}
					if (!failedStudents.isEmpty()) {
						updateFailedStudents(failedStudents, failedStudentRegistrationIds);
					}
					if (!passedStudents.isEmpty()) {
						updatePassedStudents(
							passedStudents,
							passedStudentsDriveId,
							passedStudentRegistrationIds,
							studentRegDriveIdMapsInterviewResult
						);
					}
				}
			}
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
		}
	}

	public static void updateFailedStudents(
		List<Rpl_Student_Registration_Drive__c> studentRegDriveList,
		Set<String> failedStudentRegistrationIds
	) {
		if (!studentRegDriveList.isEmpty()) {
			Map<Id, Rpl_Student_Registration__c> studentRegMap = new Map<Id, Rpl_Student_Registration__c>(
				[
					SELECT Id, Rpl_Number_Of_Failed_Drives__c
					FROM Rpl_Student_Registration__c
					WHERE Id IN :failedStudentRegistrationIds
				]
			);
			Map<String, Map<string, string>> nonShortlistedWhatsappNotification = new Map<String, Map<string, string>>();
			Map<String, String> nonShortlistedSmsMap = new Map<String, String>();

			Map<String, Map<string, string>> toAddressToValues = new Map<String, Map<string, string>>();
			String nonShortlistedEmailTemplateId = Label.RPL_Not_Shortlisted_Students_Template;

			for (Rpl_Student_Registration_Drive__c eachStudentRegDrive : studentRegDriveList) {
				//Send Email To Non Shortlisted Students
				if (!String.isEmpty(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c)) {
					Map<String, String> emailValues = new Map<String, String>();
					emailValues.put('whatId', eachStudentRegDrive.Id);
					emailValues.put('targetObjectId', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__c);
					emailValues.put('emailTemplateId', nonShortlistedEmailTemplateId);
					toAddressToValues.put(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c, emailValues);
				}

				//Send Whatsapp Notification To Non Shortlisted Students
				if (eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c != null) {
					Map<String, String> whatsAppvalues = new Map<String, String>();
					whatsAppvalues.put('studentname', eachStudentRegDrive.Rpl_Student_Registration__r.Name);
					whatsAppvalues.put(
						'complanyname',
						eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name
					);
					whatsAppvalues.put('whatsAppType', 'not_shortlisted');
					nonShortlistedWhatsappNotification.put(
						eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c,
						whatsAppvalues
					);
					String smsMessage =
						'Dear ' +
						eachStudentRegDrive.Rpl_Student_Registration__r.Name +
						' Thank you for taking the time to interview for the position with ' +
						eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name +
						'. We appreciate your interest in joining the company and the effort you put into the application process. After careful consideration, we regret to inform you that you have not been shortlisted. We sincerely appreciate your interest and wish you all the best in your upcoming placement drives. REVA University';
					nonShortlistedSmsMap.put(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c, smsMessage);
				}

				if (studentRegMap.containsKey(eachStudentRegDrive.Rpl_Student_Registration__c)) {
					Rpl_Student_Registration__c studentReg = studentRegMap.get(eachStudentRegDrive.Rpl_Student_Registration__c);
					studentReg.Rpl_Number_Of_Failed_Drives__c = (studentReg.Rpl_Number_Of_Failed_Drives__c == null)
						? 1
						: studentReg.Rpl_Number_Of_Failed_Drives__c + 1;
				}
				eachStudentRegDrive.Rpl_Is_Failed__c = true;
				if (!eachStudentRegDrive.Rpl_Is_Result_Out__c) {
					eachStudentRegDrive.Rpl_Is_Result_Out__c = true;
				}
			}

			if (!toAddressToValues.isEmpty()) {
				try {
					Rpl_UtilityClass.sendEmailsUsingTemplate(toAddressToValues);
				} catch (Exception e) {
					ErrorLogUtility.logError(e);
				}
			}
			if (!nonShortlistedWhatsappNotification.isEmpty()) {
				try {
					Database.executeBatch(new RPL_SendWhatsappNotificationBatch(nonShortlistedWhatsappNotification), 30);
				} catch (Exception e) {
					ErrorLogUtility.logError(e);
				}
			}
			if (!nonShortlistedSmsMap.isEmpty()) {
				try {
					Rpl_UtilityClass.sendSMSAsync('Not Shortlisted students', nonShortlistedSmsMap);
				} catch (Exception e) {
					ErrorLogUtility.logError(e);
				}
			}
			if (!studentRegMap.values().isEmpty()) {
				update studentRegMap.values();
			}
			update studentRegDriveList;
		}
	}

	public static void updatePassedStudents(
		List<Rpl_Student_Registration_Drive__c> studentRegDriveList,
		Set<String> driveIds,
		Set<String> passedStudentRegistrationIds,
		Map<String, Rpl_Interview_Result__c> studentRegDriveIdMapsInterviewResult
	) {
		String shortlistedEmailTemplateId = Label.RPL_Round_Wise_Shortlisted_Email_Template_ID;
		String shorlistedEmailToFatherTemplateId = Label.RPl_Interview_Round_Wise_Shortlist_Email_Template_To_Father;
		String shorlistedEmailToMotherTemplateId = Label.RPl_Interview_Round_Wise_Shortlist_Email_Template_To_Mother;
		String offeredEmailToFatherTemplateId = Label.RPL_Final_Selection_Message_Email_Template_To_Father;
		String offeredEmailToMotherTemplateId = Label.RPL_Final_Selection_Message_Email_Template_To_Mother;
		String offeredEmailTemplateId = Label.RPL_Final_Round_Offered_Email_Template_ID;

		Map<Id, Rpl_Student_Registration__c> studentRegMap = new Map<Id, Rpl_Student_Registration__c>(
			[
				SELECT Id, Rpl_Offer_Count__c, Rpl_Companies_Got_Placed_In__c, Rpl_Maximum_Offered_Salary__c
				FROM Rpl_Student_Registration__c
				WHERE Id IN :passedStudentRegistrationIds
			]
		);

		List<Rpl_Placement_Drive__c> placementDriveList = [
			SELECT Id, Rpl_Total_Interview_Round__c, (SELECT Id, Rpl_Round_Number__c FROM Interviews__r)
			FROM Rpl_Placement_Drive__c
			WHERE Id IN :driveIds
		];
		Map<String, Map<Decimal, String>> driveInterviewMap = new Map<String, Map<Decimal, String>>();

		for (Rpl_Placement_Drive__c eachPlacementDrive : placementDriveList) {
			if (!driveInterviewMap.containsKey(eachPlacementDrive.Id)) {
				Map<Decimal, String> interviewRoundsMap = new Map<Decimal, String>();
				for (Rpl_Interview__c eachInterview : eachPlacementDrive.Interviews__r) {
					interviewRoundsMap.put(eachInterview.Rpl_Round_Number__c, eachInterview.Id);
				}
				driveInterviewMap.put(eachPlacementDrive.Id, interviewRoundsMap);
			}
		}

		// Now we will be having Map with key as drive and value as Map<round, interviewId>;
		Map<String, Map<string, string>> shortlistedWhatsappNotification = new Map<String, Map<string, string>>();
		Map<String, Map<string, string>> offeredWhatsAppNotification = new Map<String, Map<string, string>>();
		Map<String, Map<string, string>> toAddressToValues = new Map<String, Map<string, string>>();
		Map<String, String> shortlistedSmsMap = new Map<String, String>();
		Map<String, String> offeredSmsMap = new Map<String, String>();
		Map<String, String> shortlistedSmsMapToParent = new Map<String, String>();
		Map<String, String> offeredSmsMapToParent = new Map<String, String>();

		for (Rpl_Student_Registration_Drive__c eachStudentRegDrive : studentRegDriveList) {
			if (driveInterviewMap.containsKey(eachStudentRegDrive.Rpl_Placement_Drive__c)) {
				List<String> toAddresses = new List<String>();

				if (!String.isEmpty(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c)) {
					toAddresses.add(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c);
				}

				Map<Decimal, String> interviewRoundsMap = driveInterviewMap.get(eachStudentRegDrive.Rpl_Placement_Drive__c);
				Decimal nextRound = eachStudentRegDrive.Rpl_Interview__r.Rpl_Round_Number__c + 1;
				Boolean isLastRound = eachStudentRegDrive.Rpl_Interview__r.Rpl_Is_Final_Round__c;
				if (interviewRoundsMap.containsKey(nextRound)) {
					//Send Shortlisted Email
					if (!String.isEmpty(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c)) {
						Map<String, String> emailValues = new Map<String, String>();
						emailValues.put('whatId', eachStudentRegDrive.Id);
						emailValues.put('targetObjectId', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__c);
						emailValues.put('emailTemplateId', shortlistedEmailTemplateId);
						toAddressToValues.put(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c, emailValues);
					}
					if (!String.isEmpty(eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Email)) {
						Map<String, String> emailValuesFather = new Map<String, String>();
						emailValuesFather.put('whatId', eachStudentRegDrive.Id);
						emailValuesFather.put(
							'targetObjectId',
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__c
						);
						emailValuesFather.put('emailTemplateId', shorlistedEmailToFatherTemplateId);
						toAddressToValues.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Email,
							emailValuesFather
						);
					}
					if (!String.isEmpty(eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Email)) {
						Map<String, String> emailValuesMother = new Map<String, String>();
						emailValuesMother.put('whatId', eachStudentRegDrive.Id);
						emailValuesMother.put(
							'targetObjectId',
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__c
						);
						emailValuesMother.put('emailTemplateId', shorlistedEmailToMotherTemplateId);
						toAddressToValues.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Email,
							emailValuesMother
						);
					}

					//Send Shortlisted Whatsapp Notification
					if (eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c != null) {
						Map<String, String> whatsAppvalues = new Map<String, String>();
						whatsAppvalues.put('studentname', eachStudentRegDrive.Rpl_Student_Registration__r.Name);
						whatsAppvalues.put(
							'companyname',
							eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name
						);
						whatsAppvalues.put('whatsAppType', 'interview_round_wise_shortlist');
						shortlistedWhatsappNotification.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c,
							whatsAppvalues
						);
						String smsMessage =
							'Dear ' +
							eachStudentRegDrive.Rpl_Student_Registration__r.Name +
							', You have been shortlisted for ' +
							eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name +
							' further rounds of interview, kindly report to CDC Dept on immediate basis. REVA University';
						shortlistedSmsMap.put(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c, smsMessage);
					}
					//To Mother
					if (eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone != null) {
						Map<String, String> whatsAppvalues = new Map<String, String>();
						whatsAppvalues.put('parentname', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Name);
						whatsAppvalues.put(
							'companyname',
							eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name
						);
						whatsAppvalues.put('whatsAppType', 'interview_round_wise_shortlist1');
						shortlistedWhatsappNotification.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone,
							whatsAppvalues
						);
						String smsMessage =
							'Dear ' +
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Name +
							' Your ward has been shortlisted for ' +
							eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name +
							' further rounds of interview, kindly inform your ward to report to CDC Dept on immediate basis.. REVA University';
						shortlistedSmsMapToParent.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone,
							smsMessage
						);
					}
					//To Father
					if (eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone != null) {
						Map<String, String> whatsAppvalues = new Map<String, String>();
						whatsAppvalues.put('parentname', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Name);
						whatsAppvalues.put(
							'companyname',
							eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name
						);
						whatsAppvalues.put('whatsAppType', 'interview_round_wise_shortlist1');
						shortlistedWhatsappNotification.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
							whatsAppvalues
						);
						String smsMessage =
							'Dear ' +
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Name +
							' Your ward has been shortlisted for ' +
							eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name +
							' further rounds of interview, kindly inform your ward to report to CDC Dept on immediate basis.. REVA University';
						shortlistedSmsMapToParent.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
							smsMessage
						);
					}

					eachStudentRegDrive.Rpl_Interview__c = interviewRoundsMap.get(nextRound);
				} else if (studentRegDriveIdMapsInterviewResult.containsKey(eachStudentRegDrive.Id) && isLastRound) {
					//Send Offered Email
					if (!String.isEmpty(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c)) {
						Map<String, String> emailValues = new Map<String, String>();
						emailValues.put('whatId', eachStudentRegDrive.Id);
						emailValues.put('targetObjectId', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__c);
						emailValues.put('emailTemplateId', offeredEmailTemplateId);
						toAddressToValues.put(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c, emailValues);
					}
					if (!String.isEmpty(eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Email)) {
						Map<String, String> emailValuesFather = new Map<String, String>();
						emailValuesFather.put('whatId', eachStudentRegDrive.Id);
						emailValuesFather.put(
							'targetObjectId',
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__c
						);
						emailValuesFather.put('emailTemplateId', offeredEmailToFatherTemplateId);
						toAddressToValues.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Email,
							emailValuesFather
						);
					}
					if (!String.isEmpty(eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Email)) {
						Map<String, String> emailValuesMother = new Map<String, String>();
						emailValuesMother.put('whatId', eachStudentRegDrive.Id);
						emailValuesMother.put(
							'targetObjectId',
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__c
						);
						emailValuesMother.put('emailTemplateId', offeredEmailToMotherTemplateId);
						toAddressToValues.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Email,
							emailValuesMother
						);
					}

					//Send Offered Whatsapp Notification
					if (eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c != null) {
						Map<String, String> whatsAppvalues = new Map<String, String>();
						whatsAppvalues.put('studentname', eachStudentRegDrive.Rpl_Student_Registration__r.Name);
						whatsAppvalues.put(
							'companyname',
							eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name
						);
						whatsAppvalues.put('whatsAppType', 'final_selection');
						offeredWhatsAppNotification.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c,
							whatsAppvalues
						);
						String smsMessage =
							'Dear ' +
							eachStudentRegDrive.Rpl_Student_Registration__r.Name +
							', It is with great pleasure that we inform you about your successful placement at ' +
							eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name +
							'. You will receive your Offer letter shortly. REVA University';
						offeredSmsMap.put(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Contact_No__c, smsMessage);
					}
					//To Mothher
					if (eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone != null) {
						Map<String, String> whatsAppvalues = new Map<String, String>();
						whatsAppvalues.put('parentname', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Name);
						whatsAppvalues.put(
							'companyname',
							eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name
						);
						whatsAppvalues.put('whatsAppType', 'final_selection_message_1');
						offeredWhatsAppNotification.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone,
							whatsAppvalues
						);
						String smsMessage =
							'Dear ' +
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Name +
							' It is with great pleasure that we inform you about your ward\'s successful placement at ' +
							eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name +
							'. The offer letter will be shared with your ward shortly. REVA University';
						offeredSmsMapToParent.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone,
							smsMessage
						);
					}

					//To  Father
					if (eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone != null) {
						Map<String, String> whatsAppvalues = new Map<String, String>();
						whatsAppvalues.put('parentname', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Name);
						whatsAppvalues.put(
							'companyname',
							eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name
						);
						whatsAppvalues.put('whatsAppType', 'final_selection_message_1');
						offeredWhatsAppNotification.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
							whatsAppvalues
						);
						String smsMessage =
							'Dear ' +
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Name +
							' It is with great pleasure that we inform you about your ward\'s successful placement at ' +
							eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name +
							'. The offer letter will be shared with your ward shortly. REVA University';
						offeredSmsMapToParent.put(
							eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
							smsMessage
						);
					}

					eachStudentRegDrive.Rpl_Offered_Salary__c = eachStudentRegDrive.Rpl_Placement_Drive__r.Rpl_CTC__c != null
						? eachStudentRegDrive.Rpl_Placement_Drive__r.Rpl_CTC__c
						: eachStudentRegDrive.Rpl_Placement_Drive__r.Rpl_Stipend__c != null
								? eachStudentRegDrive.Rpl_Placement_Drive__r.Rpl_Stipend__c
								: 0;

					Rpl_Student_Registration__c studentReg = studentRegMap.get(eachStudentRegDrive.Rpl_Student_Registration__c);
					if (
						studentReg.Rpl_Maximum_Offered_Salary__c < eachStudentRegDrive.Rpl_Offered_Salary__c ||
						studentReg.Rpl_Maximum_Offered_Salary__c == null
					) {
						studentReg.Rpl_Maximum_Offered_Salary__c = eachStudentRegDrive.Rpl_Offered_Salary__c;
					}

					eachStudentRegDrive.Rpl_Is_Result_Out__c = true;
					eachStudentRegDrive.Rpl_Is_Offered_Checkbox__c = true;
					//Rpl_Student_Registration__c studentReg = studentRegMap.get(eachStudentRegDrive.Rpl_Student_Registration__c);
					studentReg.Rpl_Offer_Count__c = (eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Offer_Count__c == null)
						? 1
						: studentReg.Rpl_Offer_Count__c + 1;
					studentReg.Rpl_Companies_Got_Placed_In__c = (String.isEmpty(
							eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Companies_Got_Placed_In__c
						))
						? eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Name
						: eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Companies_Got_Placed_In__c +
						  '; ' +
						  eachStudentRegDrive.Rpl_Interview__r.Placement_Drive__r.Name;
				}
			}
		}
		if (!shortlistedWhatsappNotification.isEmpty()) {
			try {
				Database.executeBatch(new RPL_SendWhatsappNotificationBatch(shortlistedWhatsappNotification), 30);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
		if (!offeredWhatsAppNotification.isEmpty()) {
			try {
				Database.executeBatch(new RPL_SendWhatsappNotificationBatch(offeredWhatsAppNotification), 30);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
		if (!toAddressToValues.isEmpty()) {
			try {
				Rpl_UtilityClass.sendEmailsUsingTemplate(toAddressToValues);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
		if (!studentRegMap.values().isEmpty()) {
			try {
				update studentRegMap.values();
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
		if (!offeredSmsMap.isEmpty()) {
			try {
				Rpl_UtilityClass.sendSMSAsync('Final Selection Message Template', offeredSmsMap);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
		if (!shortlistedSmsMap.isEmpty()) {
			try {
				Rpl_UtilityClass.sendSMSAsync('Interview Round wise shortlist Template', shortlistedSmsMap);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
		if (!offeredSmsMapToParent.isEmpty()) {
			try {
				Rpl_UtilityClass.sendSMSAsync('Final selection to parent', offeredSmsMapToParent);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
		if (!shortlistedSmsMapToParent.isEmpty()) {
			try {
				Rpl_UtilityClass.sendSMSAsync('Interview shortlist to parent', shortlistedSmsMapToParent);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
		try {
			update studentRegDriveList;
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
		}
	}
}