public without sharing class rpl_Placement_Training_Controller {
	@AuraEnabled(cacheable=true)
	public static List<Rpl_Training_Attendances__c> getAttendanceData(string contactId) {
		return [
			SELECT Id, Rpl_Date__c, Rpl_Training_Module__r.Name, Rpl_Attendance__c
			FROM Rpl_Training_Attendances__c
			WHERE Rpl_Student__c = :contactId
			ORDER BY Rpl_Training_Module__r.Name ASC
		];
	}

	@AuraEnabled(cacheable=true)
	public static list<Rpl_Training_Assement_Result__c> getAssessmentResultData(string contactId) {
		return [
			SELECT Id, Rpl_Assessment_Date__c, Rpl_Percentages_Scored__c, Rpl_Training_Module__r.Name, Rpl_Topic__c
			FROM Rpl_Training_Assement_Result__c
			WHERE Rpl_Student__c = :contactId
		];
	}

	@AuraEnabled(cacheable=true)
	public static list<Rpl_Training_Module__c> getTrainingMaterialData(Decimal semesterNumber, String schoolName) {
		return [
			SELECT Id, Rpl_Main_Topic__c, Rpl_Sub_Topic__c, Rpl_Target__c, School_Name__c, Rpl_No_of_Hours__c
			FROM Rpl_Training_Module__c
			WHERE Rpl_School__r.Name = :schoolName AND Rpl_Semester__c = :semesterNumber
		];
	}
}