public without sharing class Rpl_DocumentUploadClass {
	@AuraEnabled
	public static void uploadAttachment(String documentName, String fileData, Id recordId) {
		// Check if a file with the same name and linked to the record already exists
		List<ContentVersion> existingContentVersion = [
			SELECT Id, ContentDocumentId
			FROM ContentVersion
			WHERE Title = :documentName AND FirstPublishLocationId = :recordId
			ORDER BY CreatedDate DESC
			LIMIT 1
		];

		if (!existingContentVersion.isEmpty()) {
			updateExistingContentVersion(existingContentVersion[0].Id, fileData);
		} else {
			createNewContentVersion(documentName, fileData, recordId);
		}
	}

	private static void createNewContentVersion(String documentName, String fileData, Id recordId) {
		ContentVersion newContentVersion = new ContentVersion();
		newContentVersion.Title = documentName;
		newContentVersion.VersionData = EncodingUtil.base64Decode(fileData);
		newContentVersion.PathOnClient = documentName; // Set this to the desired file name
		newContentVersion.FirstPublishLocationId = recordId; // Link to the record
		insert newContentVersion;
		updateFieldDetails(documentName, recordId);
	}
	public static void updateFieldDetails(String documentName, String recordId) {
		List<Rpl_Student_Registration__c> studentRegistrationList = [
			SELECT
				Rpl_No_Of_UG_Marksheet_Uploaded__c,
				Rpl_Is_UG_Aggregate_Uploaded__c,
				Rpl_No_Of_PG_Marksheet_Uploaded__c,
				Rpl_Is_Twelveth_Marksheet_Uploaded__c,
				Rpl_Is_Tenth_Marksheet_Uploaded__c,
				Rpl_Is_Resume_Uploaded__c
			FROM Rpl_Student_Registration__c
			WHERE Id = :recordId
			LIMIT 1
		];

		if (!studentRegistrationList.isEmpty()) {
			Rpl_Student_Registration__c studentRegistration = studentRegistrationList[0];
			if (documentName.contains('UG Semester')) {
				if (studentRegistration.Rpl_No_Of_UG_Marksheet_Uploaded__c != null) {
					studentRegistration.Rpl_No_Of_UG_Marksheet_Uploaded__c += 1;
				} else {
					studentRegistration.Rpl_No_Of_UG_Marksheet_Uploaded__c = 1;
				}
			} else if (
				documentName.contains('UG Cummulative Marksheet') ||
				documentName.contains('UG Cumulative Marksheet')
			) {
				studentRegistration.Rpl_Is_UG_Aggregate_Uploaded__c = true;
			} else if (documentName.contains('PG Semester')) {
				if (studentRegistration.Rpl_No_Of_PG_Marksheet_Uploaded__c != null) {
					studentRegistration.Rpl_No_Of_PG_Marksheet_Uploaded__c += 1;
				} else {
					studentRegistration.Rpl_No_Of_PG_Marksheet_Uploaded__c = 1;
				}
			} else if (documentName.contains('Tenth Marksheet')) {
				studentRegistration.Rpl_Is_Tenth_Marksheet_Uploaded__c = true;
			} else if (documentName.contains('Twelveth Marksheet') || documentName.contains('Diploma Marksheet')) {
				studentRegistration.Rpl_Is_Twelveth_Marksheet_Uploaded__c = true;
			} else if (documentName.contains('Resume')) {
				studentRegistration.Rpl_Is_Resume_Uploaded__c = true;
			}

			update studentRegistrationList;
		}
	}
	private static void updateExistingContentVersion(Id contentVersionId, String fileData) {
		List<ContentVersion> existingContentVersion = [
			SELECT Id, ContentDocumentId, Title
			FROM ContentVersion
			WHERE Id = :contentVersionId
			LIMIT 1
		];

		if (!existingContentVersion.isEmpty()) {
			// Create a new version by inserting a new ContentVersion record
			ContentVersion newVersion = new ContentVersion();
			newVersion.Title = existingContentVersion[0].Title;
			newVersion.VersionData = EncodingUtil.base64Decode(fileData);
			newVersion.PathOnClient = existingContentVersion[0].Title;
			newVersion.ContentDocumentId = existingContentVersion[0].ContentDocumentId;
			insert newVersion;
		}
	}

	@AuraEnabled
	public static void updateIsUnderApprovalProcess(String recordId) {
		List<Rpl_Student_Registration__c> studentReg = [
			SELECT Rpl_Is_Under_Approval_Process__c
			FROM Rpl_Student_Registration__c
			WHERE Id = :recordId
			LIMIT 1
		];
		if (!studentReg.isEmpty()) {
			studentReg[0].Rpl_Is_Under_Approval_Process__c = true;
			update studentReg;
		}
	}

	@AuraEnabled(cacheable=true)
	public static List<AttachmentWrapper> getAttachments(String recordId) {
		try {
			List<AttachmentWrapper> attachmentsList = new List<AttachmentWrapper>();

			// Query ContentVersion records related to the recordId
			List<ContentVersion> contentVersions = [
				SELECT Id, Title, VersionData, FileType, ContentDocumentId
				FROM ContentVersion
				WHERE FirstPublishLocationId = :recordId
			];

			List<Rpl_Student_Registration__c> studentReg = [
				SELECT
					Rpl_Is_Resume_Verified__c,
					Rpl_Is_Tenth_Marksheet_Verified__c,
					Rpl_Is_Twelveth_Marksheet_Verified__c,
					Rpl_Is_UG_Aggregate_Verified__c,
					Rpl_PG_Verified_Semester_Marksheets__c,
					Rpl_UG_Verified_Semester_Marksheets__c,
					Rpl_Is_Diploma_Marksheet_Verified__c
				FROM Rpl_Student_Registration__c
				WHERE Id = :recordId
				LIMIT 1
			];

			if (!contentVersions.isEmpty() && !studentReg.isEmpty()) {
				for (ContentVersion contentVersion : contentVersions) {
					List<String> docTitleArray = contentVersion.Title.split(' - ');
					String docTitle = docTitleArray[1].trim();
					attachmentsList.add(
						new AttachmentWrapper(
							contentVersion.ContentDocumentId,
							docTitle,
							//contentVersion.VersionData,
							EncodingUtil.base64Encode(contentVersion.VersionData),
							contentVersion.FileType,
							studentReg[0].Rpl_Is_Tenth_Marksheet_Verified__c,
							studentReg[0].Rpl_Is_Twelveth_Marksheet_Verified__c,
							studentReg[0].Rpl_Is_Resume_Verified__c,
							studentReg[0].Rpl_Is_UG_Aggregate_Verified__c,
							studentReg[0].Rpl_Is_Diploma_Marksheet_Verified__c,
							!String.isEmpty(studentReg[0].Rpl_UG_Verified_Semester_Marksheets__c)
								? studentReg[0].Rpl_UG_Verified_Semester_Marksheets__c
								: '',
							!String.isEmpty(studentReg[0].Rpl_PG_Verified_Semester_Marksheets__c)
								? studentReg[0].Rpl_PG_Verified_Semester_Marksheets__c
								: ''
						)
					);
				}
			}

			return attachmentsList;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static Map<String, Boolean> getDocumentStatus(String recordId) {
		try {
			Map<String, Boolean> result = new Map<String, Boolean>();

			List<String> fieldNamesToQuery = new List<String>{
				'Rpl_Is_Resume_Uploaded__c',
				'Rpl_Is_Tenth_Marksheet_Uploaded__c',
				'RPL_IsGraduationComplete__c',
				'Rpl_isStudentDetailsComplete__c',
				'Rpl_Is_Twelveth_Marksheet_Uploaded__c'
			};

			List<String> ugAndPgRelatedFiedls = new List<String>{
				'Rpl_Is_UG_Aggregate_Uploaded__c',
				'Rpl_No_Of_PG_Marksheet_Uploaded__c',
				'Rpl_No_Of_UG_Marksheet_Uploaded__c',
				'Rpl_Active_Semester__c',
				'Contact__r.Primary_Academic_Program__r.Program_Type__c'
			};

			String queryString =
				'SELECT ' +
				String.join(fieldNamesToQuery, ', ') +
				', ' +
				String.join(ugAndPgRelatedFiedls, ', ') +
				' FROM Rpl_Student_Registration__c WHERE Id = :recordId LIMIT 1';

			List<Rpl_Student_Registration__c> record = Database.query(queryString);
			if (!record.isEmpty()) {
				// Iterate through fields and populate the result map
				for (String fieldName : fieldNamesToQuery) {
					result.put(fieldName, (Boolean) record[0].get(fieldName));
				}
				result.put(
					'Rpl_Is_UG_Marksheet_Uploaded__c',
					(record[0].Contact__r.Primary_Academic_Program__r.Program_Type__c != 'UG') ? 
					((Boolean) record[0].get('Rpl_Is_UG_Aggregate_Uploaded__c')) :true 
					/* (((Decimal) record[0].get('Rpl_No_Of_UG_Marksheet_Uploaded__c')) >=
					((Decimal) record[0].get('Rpl_Active_Semester__c') - 1)) */
				);

				result.put(
					'Rpl_Is_PG_Marksheet_Uploaded__c',true
					/* ((Decimal) record[0].get('Rpl_No_Of_PG_Marksheet_Uploaded__c')) >=
					((Decimal) record[0].get('Rpl_Active_Semester__c') - 1) */
				);
			}
			return result;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static List<Rpl_Student_Registration__c> getApprovalStatus(String recordId) {
		try {
			List<Rpl_Student_Registration__c> studentReg = [
				SELECT
					Name,
					Rpl_SRN__c,
					Contact__r.Personal_Email__c,
					Course_Name__c,
					Rpl_Status__c,
					Rpl_Reason_for_Documentation_Fail__c,
					Rpl_Personal_Mail_ID__c,
					Rpl_Is_Record_Shared__c,
					Contact__r.Primary_Academic_Program__r.Name
				FROM Rpl_Student_Registration__c
				WHERE Id = :recordId
			];
			return studentReg;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class AttachmentWrapper {
		@AuraEnabled
		public String id;
		@AuraEnabled
		public String Name;
		@AuraEnabled
		public String bodyBase64;
		@AuraEnabled
		public String contentType;
		@AuraEnabled
		public Boolean isTenthVerified;
		@AuraEnabled
		public Boolean isTwelvethVerified;
		@AuraEnabled
		public Boolean isResumeVerified;
		@AuraEnabled
		public Boolean isDiplomaVerified;
		@AuraEnabled
		public Boolean isUgAggregateVerified;
		@AuraEnabled
		public String ugVerifiedSemesterMarksheets;
		@AuraEnabled
		public String pgVerifiedSemesterMarksheets;

		public AttachmentWrapper(
			String id,
			String name,
			String bodyBase64,
			String contentType,
			Boolean isTenthVerified,
			Boolean isTwelvethVerified,
			Boolean isResumeVerified,
			Boolean isUgAggregateVerified,
			Boolean isDiplomaVerified,
			String ugVerifiedSemesterMarksheets,
			String pgVerifiedSemesterMarksheets
		) {
			this.id = id;
			this.Name = name;
			this.bodyBase64 = bodyBase64;
			this.contentType = contentType;
			this.isTenthVerified = isTenthVerified;
			this.isTwelvethVerified = isTwelvethVerified;
			this.isResumeVerified = isResumeVerified;
			this.isUgAggregateVerified = isUgAggregateVerified;
			this.isDiplomaVerified =isDiplomaVerified;
			this.ugVerifiedSemesterMarksheets = ugVerifiedSemesterMarksheets;
			this.pgVerifiedSemesterMarksheets = pgVerifiedSemesterMarksheets;
		}
	}
}