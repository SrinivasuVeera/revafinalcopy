trigger RPL_CompanyTrigger on Rpl_Company__c (before insert, before update) {
	RPL_CompanyHandler.companyImageUpdateAndValidation(Trigger.New, Trigger.OldMap);
}