/**
 * @description       : This handler class handles after insert logic in Rpl_Interview__c Object.
 * @author            : Kiruba Sankar M
 * @group             :
 * @last modified on  : 22-11-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/

public class Rpl_InterviewTriggerHandler {
	public static void updateStudentRegistrationDrive(List<Rpl_Interview__c> newTrigger) {
		try {
			Map<String, Rpl_Interview__c> driveIdInterviewMap = new Map<String, Rpl_Interview__c>();

			// Build a map of Placement Drive Id to Interview record for first round interviews
			for (Rpl_Interview__c eachInterview : newTrigger) {
				if (eachInterview.Rpl_Round_Number__c == 1) {
					driveIdInterviewMap.put(eachInterview.Placement_Drive__c, eachInterview);
				}
			}

			if (!driveIdInterviewMap.isEmpty()) {
				// Query Student Registration Drive records related to the Placement Drives
				List<Rpl_Student_Registration_Drive__c> studentRegDriveList = [
					SELECT Rpl_Placement_Drive__c, Rpl_Interview__c
					FROM Rpl_Student_Registration_Drive__c
					WHERE Rpl_Placement_Drive__c IN :driveIdInterviewMap.keySet()
				];

				if (!studentRegDriveList.isEmpty()) {
					// Update Student Registration Drive records with the first round of interviews
					for (Rpl_Student_Registration_Drive__c eachStudentRegDrive : studentRegDriveList) {
						if (driveIdInterviewMap.containsKey(eachStudentRegDrive.Rpl_Placement_Drive__c)) {
							eachStudentRegDrive.Rpl_Interview__c = driveIdInterviewMap.get(eachStudentRegDrive.Rpl_Placement_Drive__c)
								.Id;
						}
					}

					update studentRegDriveList;
				}
			}
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
		}
	}

	public static void pullStudentsToNextRound(
		List<Rpl_Interview__c> recruitmentStages,
		Map<Id, Rpl_Interview__c> oldRecruitmentStagesMap,
		Boolean isUpdate
	) {
		List<Rpl_Interview__c> pullOfferedStudentRecruitmentStage = new List<Rpl_Interview__c>();
		for (Rpl_Interview__c eachStage : recruitmentStages) {
			if (isUpdate) {
				if (
					eachStage.Rpl_Pull_Prev_Round_Shortlisted_Students__c == true &&
					oldRecruitmentStagesMap.get(eachStage.Id).Rpl_Pull_Prev_Round_Shortlisted_Students__c == false
				) {
					pullOfferedStudentRecruitmentStage.add(eachStage);
				}
			} else if (!isUpdate && eachStage.Rpl_Pull_Prev_Round_Shortlisted_Students__c) {
				pullOfferedStudentRecruitmentStage.add(eachStage);
			}
		}

		if (!pullOfferedStudentRecruitmentStage.isEmpty()) {
			String shortlistedEmailTemplateId = Label.RPL_Round_Wise_Shortlisted_Email_Template_ID;
			String shorlistedEmailToFatherTemplateId = Label.RPl_Interview_Round_Wise_Shortlist_Email_Template_To_Father;
			String shorlistedEmailToMotherTemplateId = Label.RPl_Interview_Round_Wise_Shortlist_Email_Template_To_Mother;
			Map<String, Map<string, string>> shortlistedWhatsappNotification = new Map<String, Map<string, string>>();

			Map<String, Map<string, string>> toAddressToValues = new Map<String, Map<string, string>>();
			Map<String, String> shortlistedSmsMap = new Map<String, String>();
			Map<String, String> shortlistedSmsMapToParent = new Map<String, String>();

			Id newStageIdToGetPulled = pullOfferedStudentRecruitmentStage[0].Id;
			Id placementDriveId = pullOfferedStudentRecruitmentStage[0].Placement_Drive__c;

			Decimal previousStageRound = pullOfferedStudentRecruitmentStage[0].Rpl_Round_Number__c - 1;
			List<Rpl_Interview__c> previousStage = [
				SELECT Id
				FROM Rpl_Interview__c
				WHERE Rpl_Round_Number__c = :previousStageRound AND Placement_Drive__c = :placementDriveId
			];
			if (!previousStage.isEmpty()) {
				List<Rpl_Student_Registration_Drive__c> studentRegDriveList = [
					SELECT
						Id,
						Rpl_Student_Registration__c,
						Rpl_Interview__c,
						Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c,
						Rpl_Student_Registration__r.Rpl_Contact_No__c,
						Rpl_Student_Registration__r.Contact__c,
						Rpl_Student_Registration__r.Name,
						Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name,
						Rpl_Student_Registration__r.Contact__r.Father__c,
						Rpl_Student_Registration__r.Contact__r.Mother__c,
						Rpl_Is_Failed__c,
						Rpl_Student_Registration__r.Contact__r.Father__r.Email,
						Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
						Rpl_Student_Registration__r.Contact__r.Father__r.Name,
						Rpl_Student_Registration__r.Contact__r.Mother__r.Email,
						Rpl_Student_Registration__r.Contact__r.Mother__r.Name,
						Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone
					FROM Rpl_Student_Registration_Drive__c
					WHERE
						Rpl_Interview__c = :previousStage[0].Id
						AND Rpl_Student_Registration__c != NULL
						AND Rpl_Is_Failed__c = FALSE
				];

				for (Rpl_Student_Registration_Drive__c eachStudentRegDrive : studentRegDriveList) {
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
					eachStudentRegDrive.Rpl_Interview__c = newStageIdToGetPulled;
				}
				if (!shortlistedSmsMapToParent.isEmpty()) {
					try {
						Rpl_UtilityClass.sendSMSAsync('Interview shortlist to parent', shortlistedSmsMapToParent);
					} catch (Exception e) {
						ErrorLogUtility.logError(e);
					}
				}
				if (!shortlistedWhatsappNotification.isEmpty()) {
					try {
						Database.executeBatch(new RPL_SendWhatsappNotificationBatch(shortlistedWhatsappNotification), 30);
						//Rpl_UtilityClass.sendWhatsAppNotificationAsync('interview_round_wise_shortlist', jsonStringOffered);
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
				if (!shortlistedSmsMap.isEmpty()) {
					try {
						Rpl_UtilityClass.sendSMSAsync('Interview Round wise shortlist Template', shortlistedSmsMap);
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
	}

	public static void updateShortlistedStudents(
		List<Rpl_Interview__c> recruitmentStages,
		Map<Id, Rpl_Interview__c> oldRecruitmentStagesMap
	) {
		set<Id> filteredRecruitmentStages = new Set<Id>();

		for (Rpl_Interview__c eachStage : recruitmentStages) {
			if (
				eachStage.Rpl_Is_Final_Round__c == true &&
				oldRecruitmentStagesMap.get(eachStage.Id).Rpl_Is_Final_Round__c == false
			) {
				filteredRecruitmentStages.add(eachStage.Id);
			}
		}
		if (!filteredRecruitmentStages.isEmpty()) {
			String offeredEmailToFatherTemplateId = Label.RPL_Final_Selection_Message_Email_Template_To_Father;
			String offeredEmailToMotherTemplateId = Label.RPL_Final_Selection_Message_Email_Template_To_Mother;
			String offeredEmailTemplateId = Label.RPL_Final_Round_Offered_Email_Template_ID;

			Map<Id, Rpl_Student_Registration_Drive__c> studentRegDriveMap = new Map<Id, Rpl_Student_Registration_Drive__c>(
				[
					SELECT
						Id,
						Rpl_Is_Result_Out__c,
						Rpl_Offered_Salary__c,
						Rpl_Student_Registration__c,
						Rpl_Placement_Drive__r.Rpl_CTC__c,
						Rpl_Placement_Drive__r.Name,
						Rpl_Student_Registration__r.Rpl_Contact_No__c,
						Rpl_Student_Registration__r.Contact__c,
						Rpl_Student_Registration__r.Contact__r.Father__c,
						Rpl_Student_Registration__r.Contact__r.Mother__c,
						Rpl_Student_Registration__r.Contact__r.Father__r.Email,
						Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone,
						Rpl_Student_Registration__r.Contact__r.Father__r.Name,
						Rpl_Student_Registration__r.Contact__r.Mother__r.Email,
						Rpl_Student_Registration__r.Contact__r.Mother__r.Name,
						Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone,
						Rpl_Placement_Drive__r.Rpl_Stipend__c,
						Rpl_Student_Registration__r.Name,
						Rpl_Interview__r.Placement_Drive__r.Rpl_Company_Name__r.Name,
						Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c
					FROM Rpl_Student_Registration_Drive__c
					WHERE
						Rpl_Interview__c IN :filteredRecruitmentStages
						AND Rpl_Student_Registration__c != NULL
						AND Rpl_Is_Failed__c = FALSE
				]
			);
			Set<Id> studentRegIds = new Set<Id>();
			for (Rpl_Student_Registration_Drive__c eachStudentRegDrive : studentRegDriveMap.values()) {
				studentRegIds.add(eachStudentRegDrive.Rpl_Student_Registration__c);
			}
			if (!studentRegIds.isEmpty()) {
				Map<String, Map<string, string>> offeredWhatsAppNotification = new Map<String, Map<string, string>>();
				Map<String, String> offeredSmsMap = new Map<String, String>();
				Map<String, Map<string, string>> toAddressToValues = new Map<String, Map<string, string>>();
				Map<String, String> offeredSmsMapToParent = new Map<String, String>();
				Map<Id, Rpl_Student_Registration__c> studentRegMap = new Map<Id, Rpl_Student_Registration__c>(
					[
						SELECT Rpl_Companies_Got_Placed_In__c, Rpl_Maximum_Offered_Salary__c, Rpl_Offer_Count__c
						FROM Rpl_Student_Registration__c
						WHERE Id IN :studentRegIds
					]
				);

				if (!studentRegMap.isEmpty()) {
					for (Rpl_Student_Registration_Drive__c eachStudentRegDrive : studentRegDriveMap.values()) {
						eachStudentRegDrive.Rpl_Is_Result_Out__c = true;
						eachStudentRegDrive.Rpl_Offered_Salary__c = eachStudentRegDrive.Rpl_Placement_Drive__r.Rpl_CTC__c != null
							? eachStudentRegDrive.Rpl_Placement_Drive__r.Rpl_CTC__c
							: eachStudentRegDrive.Rpl_Placement_Drive__r.Rpl_Stipend__c != null
									? eachStudentRegDrive.Rpl_Placement_Drive__r.Rpl_Stipend__c
									: 0;
						if (studentRegMap.containsKey(eachStudentRegDrive.Rpl_Student_Registration__c)) {
							//Send Offered Email Notification
							if (!String.isEmpty(eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c)) {
								Map<String, String> emailValues = new Map<String, String>();
								emailValues.put('whatId', eachStudentRegDrive.Id);
								emailValues.put('targetObjectId', eachStudentRegDrive.Rpl_Student_Registration__r.Contact__c);
								emailValues.put('emailTemplateId', offeredEmailTemplateId);
								toAddressToValues.put(
									eachStudentRegDrive.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c,
									emailValues
								);
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
							if (eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.MobilePhone != null) {
								Map<String, String> whatsAppvalues = new Map<String, String>();
								whatsAppvalues.put(
									'parentname',
									eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Mother__r.Name
								);
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
							if (eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.MobilePhone != null) {
								Map<String, String> whatsAppvalues = new Map<String, String>();
								whatsAppvalues.put(
									'parentname',
									eachStudentRegDrive.Rpl_Student_Registration__r.Contact__r.Father__r.Name
								);
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

							Rpl_Student_Registration__c studentReg = studentRegMap.get(
								eachStudentRegDrive.Rpl_Student_Registration__c
							);
							studentReg.Rpl_Companies_Got_Placed_In__c = (String.isEmpty(studentReg.Rpl_Companies_Got_Placed_In__c))
								? eachStudentRegDrive.Rpl_Placement_Drive__r.Name
								: studentReg.Rpl_Companies_Got_Placed_In__c + '; ' + eachStudentRegDrive.Rpl_Placement_Drive__r.Name;
							studentReg.Rpl_Offer_Count__c = studentReg.Rpl_Offer_Count__c == null
								? 0
								: studentReg.Rpl_Offer_Count__c + 1;
							studentReg.Rpl_Maximum_Offered_Salary__c = studentReg.Rpl_Maximum_Offered_Salary__c == null ||
								studentReg.Rpl_Maximum_Offered_Salary__c < eachStudentRegDrive.Rpl_Offered_Salary__c
								? eachStudentRegDrive.Rpl_Offered_Salary__c
								: studentReg.Rpl_Maximum_Offered_Salary__c;
						}
					}
					if (!offeredSmsMapToParent.isEmpty()) {
						try {
							Rpl_UtilityClass.sendSMSAsync('Final selection to parent', offeredSmsMapToParent);
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
					if (!offeredSmsMap.isEmpty()) {
						try {
							Rpl_UtilityClass.sendSMSAsync('Final Selection Message Template', offeredSmsMap);
						} catch (Exception e) {
							ErrorLogUtility.logError(e);
						}
					}
					try {
						update studentRegMap.values();
						update studentRegDriveMap.values();
					} catch (Exception e) {
						ErrorLogUtility.logError(e);
					}
				}
			}
		}
	}
}