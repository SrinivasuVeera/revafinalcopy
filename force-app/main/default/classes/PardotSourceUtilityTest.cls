@isTest
public class PardotSourceUtilityTest {
    
    private static final String SPECIFIC_SCHOOL = 'School of Performing Arts and Indic Studies';
    
    @isTest
    static void testSetSourcesOnLead() {
        // create a new lead with a value for utm_source__c
        
        Id AdmissionSiteUserId = [Select GuestRecordDefaultOwnerId from Site Where MasterLabel='Admissions' Limit 1].GuestRecordDefaultOwnerId;
        
        User AdmissionSiteUser = [Select Id, Name from User Where Id = :AdmissionSiteUserId];
        System.runAs(AdmissionSiteUser){
            system.debug('GuestUserId'+AdmissionSiteUser.id);
            Lead oldLead = new Lead(utm_source__c = 'google', LastName='TestLead1', Email='TestLead1@test.com',LeadSource='Web');
            insert oldLead;
            
            Lead newLead = [Select Name, utm_source__c, ownerId from Lead Where Email = 'TestLead1@test.com'];
            newLead.LastName = 'UpdatedTestLead1';
            update newLead; 
            PardotSourceUtility.setSourcesOnLead(newLead, oldLead);
            System.assertEquals('google', newLead.Primary_Source__c);
            oldLead.Primary_Source__c = 'bing';
            update oldLead;
            PardotSourceUtility.setSourcesOnLead(newLead, oldLead);
            System.assertEquals('google', newLead.Secondary_Source__c);
            oldLead.Secondary_Source__c = 'yahoo';
            update oldLead;
            PardotSourceUtility.setSourcesOnLead(newLead, oldLead);
            System.assertEquals('google', newLead.Tertiary_Source__c);
        }
    }
    @istest
    static void testSetSourcesOnContact(){
        
        id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        id accUniversityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        id accAcademicProgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        
        Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
        accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;
        
        Contact oldContact = new Contact();   
        oldContact.FirstName = 'Performing Arts First Name';
        oldContact.LastName = 'Performing Arts Last Name';
        oldContact.MobilePhone = '+91-9535768042';
        oldContact.RecordTypeId  = conRecTypeId;
        oldContact.Assigned__c = False;
        oldContact.School__c = accRecPerformingArts.Id;
        insert oldContact;
        
        
        Contact NewContact = [Select Name, Record_Type_Name__c,pi__last_activity__c,pi__first_touch_url__c from Contact Where FirstName = 'Performing Arts First Name'];
        NewContact.utm_source__c = 'google';
        update NewContact;
        
        Map<Id,Contact> oldContactMap = new Map<Id,Contact>();
        oldContactMap.put(oldContact.id,oldContact);
        List<Contact> newContactList = new List<Contact>();
        newContactList.add(NewContact);

        PardotSourceUtility.setSourcesOnContact(NewContact, oldContact);
        Appl_ContactTriggerHandler.updateContactSource(oldContactMap, newContactList);
        System.assertEquals('google', NewContact.Primary_Source__c);
        oldContact.Primary_Source__c = 'bing';
        update oldContact;
        PardotSourceUtility.setSourcesOnContact(NewContact, oldContact);
        Appl_ContactTriggerHandler.updateContactSource(oldContactMap, newContactList);
        System.assertEquals('google', NewContact.Secondary_Source__c);
        oldContact.Secondary_Source__c = 'yahoo';
        update oldContact;
        PardotSourceUtility.setSourcesOnContact(NewContact, oldContact);
        Appl_ContactTriggerHandler.updateContactSource(oldContactMap, newContactList);
        System.assertEquals('google', NewContact.Tertiary_Source__c);
        
        
    }
}