/**
 * @description       : This class is used to retrieve data to the LWC thus displaying interview results.
 * @author            : Kiruba Sankar M
 * @group             :
 * @last modified on  : 22-11-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public without sharing class RPL_InterviewHandler {
	@AuraEnabled(cacheable=true)
	public static RPL_InterviewHandlerWrapperClass getAllInterviews(String studentRegDriveId) {
		try {
			RPL_InterviewHandlerWrapperClass rplInterviewWrapper = new RPL_InterviewHandlerWrapperClass();

			Rpl_Student_Registration_Drive__c studentRegistrationDrive = [
				SELECT
					Rpl_Is_Failed__c,
					Rpl_Interview__r.Name,
					Rpl_Interview__r.Rpl_Round_Number__c,
					Rpl_Placement_Drive__c,
					Rpl_Is_Result_Out__c
				FROM Rpl_Student_Registration_Drive__c
				WHERE Id = :studentRegDriveId AND Rpl_Interview__c != NULL AND Rpl_Placement_Drive__c != NULL
				LIMIT 1
			];

			if (studentRegistrationDrive != null) {
				List<Rpl_Interview__c> interviewList = [
					SELECT Name, Rpl_Interview_Time__c, Rpl_Round_Number__c
					FROM Rpl_Interview__c
					WHERE
						Rpl_Round_Number__c <= :studentRegistrationDrive.Rpl_Interview__r.Rpl_Round_Number__c
						AND Placement_Drive__c = :studentRegistrationDrive.Rpl_Placement_Drive__c
					ORDER BY Rpl_Round_Number__c ASC
				];

				if (interviewList != null) {
					rplInterviewWrapper.interviewList = interviewList;
					rplInterviewWrapper.studentRegistrationDrive = studentRegistrationDrive;
				}
			}

			return rplInterviewWrapper;
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class RPL_InterviewHandlerWrapperClass {
		@AuraEnabled
		public List<Rpl_Interview__c> interviewList;
		@AuraEnabled
		public Rpl_Student_Registration_Drive__c studentRegistrationDrive;
	}
}