public without sharing class RPL_StudentRegisterDriveController {
	
	@AuraEnabled(cacheable=true)
	public static List<Rpl_Student_Registration_Drive__c> getAllEligibleDrives(Id contactId) {
		Set<Id> studentRegSet = new Set<Id>();
		for (Rpl_Student_Registration__c eStd : [
			SELECT Id
			FROM Rpl_Student_Registration__c
			WHERE Contact__c = :contactId
		]) {
			studentRegSet.add(eStd.Id);
		}

		List<Rpl_Student_Registration_Drive__c> studentRegDriveList = [
			SELECT
				Id,
				Rpl_Placement_Drive__c,
				Rpl_Student_Registration__c,
				Rpl_Is_Offered__c,
				Rpl_Placement_Drive__r.Rpl_Company_Name__r.Company_Image__c,
				Rpl_Placement_Drive__r.Name,
				Rpl_Placement_Drive__r.Rpl_Company_Name__r.Name,
				Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c,
				Rpl_Placement_Drive__r.Rpl_Event_Date__c,
				Rpl_Placement_Drive__r.Rpl_Job_Description_URL__c,
				Rpl_Placement_Drive__r.Rpl_Event_End_Date__c,
				Rpl_IsApplied__c,
				Rpl_Placement_Drive__r.Rpl_Application_End_Time__c,
				Rpl_Student_Registration__r.Rpl_University_Mail_ID__c,
				Rpl_Student_Registration__r.Rpl_Is_Blocked__c,
				Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c,
				Rpl_Student_Registration__r.Rpl_Contact_No__c
			FROM Rpl_Student_Registration_Drive__c
			WHERE
				Rpl_Student_Registration__c IN :studentRegSet
				AND Rpl_Placement_Drive__c != NULL
				AND Rpl_Student_Registration__c != NULL
				AND Rpl_Is_Active__c = TRUE
			ORDER BY Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c DESC
		];

		return studentRegDriveList;
	}

	@AuraEnabled(cacheable=true)
	public static Integer getTotalNumberOfEligibleDrives() {
		Id loggedInUserId = UserInfo.getUserId();
		List<User> loggedInUser = [SELECT ContactId FROM User WHERE Id = :loggedInUserId LIMIT 1];
		if (!loggedInUser.isEmpty()) {
			String contactId = loggedInUser[0].Id;
			if (!String.isEmpty(contactId)) {
				List<Rpl_Student_Registration__c> studentRegistration = [
					SELECT Id
					FROM Rpl_Student_Registration__c
					WHERE Contact__c = :contactId
				];
				if (!studentRegistration.isEmpty()) {
					List<Rpl_Student_Registration_Drive__c> studentRegDriveList = [
						SELECT Id
						FROM Rpl_Student_Registration_Drive__c
						WHERE Rpl_Student_Registration__c = :studentRegistration[0].Id
					];
					return studentRegDriveList.size();
				}
			}
		}
		return 0;
	}

	@AuraEnabled(cacheable=true)
	public static String getUpcomingDrive() {
		Id loggedInUserId = UserInfo.getUserId();
		List<User> loggedInUser = [SELECT ContactId FROM User WHERE Id = :loggedInUserId LIMIT 1];
		if (!loggedInUser.isEmpty()) {
			String contactId = loggedInUser[0].Id;
			if (!String.isEmpty(contactId)) {
				List<Rpl_Student_Registration__c> studentRegistration = [
					SELECT Id
					FROM Rpl_Student_Registration__c
					WHERE Contact__c = :contactId
				];
				if (!studentRegistration.isEmpty()) {
					DateTime currentDateTime = System.now();

					List<Rpl_Student_Registration_Drive__c> studentRegDriveList = [
						SELECT Id, Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c
						FROM Rpl_Student_Registration_Drive__c
						WHERE
							Rpl_Student_Registration__c = :studentRegistration[0].Id
							AND Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c > :currentDateTime
						ORDER BY Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c
					];
					if (!studentRegDriveList.isEmpty()) {
						String dateString = studentRegDriveList[0]
							.Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c.format('yyyy-MM-dd');
						return dateString;
					}
				}
			}
		}
		return 'N/A';
	}

	@AuraEnabled(cacheable=true)
	public static Integer getOfferCount() {
		Id loggedInUserId = UserInfo.getUserId();
		List<User> loggedInUser = [SELECT ContactId FROM User WHERE Id = :loggedInUserId LIMIT 1];
		if (!loggedInUser.isEmpty()) {
			String contactId = loggedInUser[0].Id;
			if (!String.isEmpty(contactId)) {
				List<Rpl_Student_Registration__c> studentRegistration = [
					SELECT Id, Rpl_Offer_Count__c
					FROM Rpl_Student_Registration__c
					WHERE Contact__c = :contactId
				];
				if (!studentRegistration.isEmpty()) {
					return studentRegistration[0].Rpl_Offer_Count__c != null
						? (Integer) studentRegistration[0].Rpl_Offer_Count__c
						: 0;
				}
			}
		}
		return 0;
	}
	
	@AuraEnabled
	public static String updateIsApplied(String studentRegistrationDriveId) {
		try {
			Boolean isUpdated = false;
			if (String.isNotBlank(studentRegistrationDriveId)) {
				Rpl_Student_Registration_Drive__c studentRegDrive = [
					SELECT Id, Rpl_IsApplied__c, Rpl_Placement_Drive__c, Rpl_Interview__c
					FROM Rpl_Student_Registration_Drive__c
					WHERE Id = :studentRegistrationDriveId
				];

				List<Rpl_Placement_Drive__c> placementDrive = [
					SELECT Id, RPL_Number_Of_Applicants__c, (SELECT Id FROM Interviews__r WHERE Rpl_Round_Number__c = 1)
					FROM Rpl_Placement_Drive__c
					WHERE Id = :studentRegDrive.Rpl_Placement_Drive__c
				];

				if (!placementDrive.isEmpty()) {
					placementDrive[0].RPL_Number_Of_Applicants__c = (placementDrive[0].RPL_Number_Of_Applicants__c == null)
						? 1
						: placementDrive[0].RPL_Number_Of_Applicants__c + 1;
					if (!placementDrive[0].Interviews__r.isEmpty() && studentRegDrive.Rpl_Interview__c == null) {
						studentRegDrive.Rpl_Interview__c = placementDrive[0].Interviews__r[0].Id;
					}
				}

				if (studentRegDrive.Id != null) {
					studentRegDrive.Rpl_IsApplied__c = true;
					update studentRegDrive;
					update placementDrive;
					isUpdated = true;
				}
			}

			return (isUpdated) ? 'true' : 'false';
		} catch (Exception e) {
			// Log the error using ErrorLogUtility
			ErrorLogUtility.logError(e);
			return e.getMessage();
		}
	}


	@AuraEnabled(cacheable=true)
	public static AttachmentWrapper getAttachmentContent(String studentRegistrationDriveId) {
		AttachmentWrapper attWrapper = new AttachmentWrapper();

		List<Attachment> attachmentList = [
			SELECT Body, Name
			FROM Attachment
			WHERE ParentId = :studentRegistrationDriveId
			ORDER BY CreatedDate DESC
			LIMIT 1
		];

		if (!attachmentList.isEmpty()) {
			if (attachmentList[0].Body != null) {
				attWrapper.Body = EncodingUtil.base64Encode(attachmentList[0].Body);
			}
			attWrapper.Name = attachmentList[0].Name;
		}
		return attWrapper;
	}

	@AuraEnabled
	public static String updateIsPresent(String SRN_Number, String DriveName) {
		try {
			if (String.isNotBlank(SRN_Number) && String.isNotBlank(DriveName)) {
				List<Rpl_Student_Registration_Drive__c> studentRegDrive = [
					SELECT Id, Rpl_Is_Present__c, Rpl_Student_Registration__r.Rpl_Is_Blocked__c
					FROM Rpl_Student_Registration_Drive__c
					WHERE
						Rpl_Student_Registration__r.Contact__r.SRN_Number__c = :SRN_Number
						AND Rpl_Placement_Drive__r.Name = :DriveName
					LIMIT 1
				];

				if (!studentRegDrive.isEmpty() && studentRegDrive[0].Rpl_Student_Registration__r.Rpl_Is_Blocked__c) {
					return 'false';
				} else if (!studentRegDrive.isEmpty()) {
					studentRegDrive[0].Rpl_Is_Present__c = true;
					update studentRegDrive;
					return 'true';
				}
			}
			// Add a default return statement outside the if conditions
			return 'false';
		} catch (Exception e) {
			// Log the exception
			ErrorLogUtility.logError(e);
			// Return an error message
			return e.getMessage();
		}
	}

	public class AttachmentWrapper {
		@AuraEnabled
		public string Body;
		@AuraEnabled
		public string Name;
	}

	@AuraEnabled
	public static PlacementSummaryDetailsWrapper getPlacementSummaryDetails() {
		PlacementSummaryDetailsWrapper wrapper = new PlacementSummaryDetailsWrapper();
		wrapper.offerCount = getOfferCount();
		wrapper.totalDrives = getTotalNumberOfEligibleDrives();
		wrapper.upcomingDriveDate = getUpcomingDrive();
		return wrapper;
	}

	public class PlacementSummaryDetailsWrapper {
		@AuraEnabled
		public Integer offerCount;
		@AuraEnabled
		public Integer totalDrives;
		@AuraEnabled
		public String upcomingDriveDate;
	}
}