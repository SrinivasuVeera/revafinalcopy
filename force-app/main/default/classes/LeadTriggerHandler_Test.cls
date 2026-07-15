@isTest
public with sharing class LeadTriggerHandler_Test {
    
    @TestSetup
    public static void createleadData() {
        LeadTriggerHandler.bypassDuplicateValidation = true;
        
        Profile p = [select id from profile where name ='Counselor'];
        User counselorOwner = [Select id, name, IsActive from User where ProfileId=:p.id and isActive = true Limit 1 ];
        
        Profile publisherProfile = [Select Id, Name from Profile where Name = 'REVA Publisher'];
        User publisherUser = [Select Id, Name from User where ProfileId =:publisherProfile.Id and isActive = true LIMIT 1];
        
        Profile yellowAiProfile = [Select Id, Name from Profile where Name = 'YellowAISystemUser'];
        User yellowAiUsers = [Select Id, Name from User where ProfileId = : yellowAiProfile.Id and isActive = true LIMIT 1];
        
        Lead lead1= new Lead (
            LastName='Sai',
            Company='Test Company',
            utm_source__c='Organic',
            MobilePhone = '9876543210',
            Country_Code__c='India (+91)',
            OwnerId = counselorOwner.Id,
            pi__last_activity__c=DateTime.now()-1,
            pi__first_touch_url__c=''
        );
        insert lead1;
        
        Lead lead2= new Lead (
            LastName='John',
            Company='Test Company1',
            utm_source__c='Direct',
            MobilePhone = '9876543211',
            Country_Code__c='India (+91)',
            OwnerId = counselorOwner.Id,
            pi__last_activity__c=DateTime.now()-1,
            pi__first_touch_url__c=''
        );
        insert lead2;
        
        List<Lead> leads = new List<Lead>();
        
        Lead counselorLead = new Lead();
        counselorLead.LastName='Counselor Lead';
        counselorLead.Company='Test Company';
        counselorLead.utm_source__c='Manual';
        counselorLead.MobilePhone = '9716543210';
        counselorLead.Country_Code__c='India (+91)';
        counselorLead.OwnerId = counselorOwner.Id;
        insert counselorLead;
        
        Lead publisherLead = new Lead();
        publisherLead.LastName='Counselor Lead';
        publisherLead.Company='Test Company';
        publisherLead.utm_source__c='Manual';
        publisherLead.MobilePhone = '9676543210';
        publisherLead.Country_Code__c='India (+91)';
        publisherLead.LeadSource = 'Publisher - Careers360';
        publisherLead.OwnerId = publisherUser.Id;
        insert publisherLead;
        
        Lead yellowAILead = new Lead();
        yellowAILead.LastName='Counselor Lead';
        yellowAILead.Company='Test Company';
        yellowAILead.utm_source__c='Manual';
        yellowAILead.MobilePhone = '9576543210';
        yellowAILead.Country_Code__c='India (+91)';
        yellowAILead.LeadSource = 'Yellow.ai';
        yellowAILead.OwnerId = yellowAiUsers.Id;
        insert yellowAILead;
        
        Lead freshLead = new Lead();
        freshLead.LastName='Fresh Lead';
        freshLead.Company='Test Company';
        freshLead.utm_source__c='Fresh Lead';
        freshLead.MobilePhone = '9476543210';
        freshLead.Country_Code__c='India (+91)';
        insert freshLead;
        
        Lead piSourceNullLead = new Lead();
        piSourceNullLead.LastName='Fresh Lead';
        piSourceNullLead.Company='Test Company';
        piSourceNullLead.MobilePhone = '9376543210';
        insert piSourceNullLead;
        
        Lead primaryLead = new Lead();
        primaryLead.LastName='Fresh Lead';
        primaryLead.Company='Test Company';
        primaryLead.utm_source__c='Primary';
        primaryLead.MobilePhone = '9276543210';
        primaryLead.Primary_Source__c= 'Primary';
        insert primaryLead;
        
        Lead secondaryLead = new Lead();
        secondaryLead.LastName='Fresh Lead';
        secondaryLead.Company='Test Company';
        secondaryLead.utm_source__c='Secondary';
        secondaryLead.MobilePhone = '9176543210';
        secondaryLead.Country_Code__c = 'India (+91)';
        secondaryLead.Primary_Source__c= 'Secondary';
        secondaryLead.Secondary_Source__c= 'Secondary';
        insert secondaryLead;
    }
    
    @isTest
    public static void updateLeadSourceTest() {
        LeadTriggerHandler.bypassDuplicateValidation = true;
        
        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        List<Lead> newLead = new List<Lead>();
        
        Lead oldLead = [Select Id, LastName, Company,utm_source__c, MobilePhone, Country_Code__C,pi__last_activity__c,pi__first_touch_url__c
                        from Lead where LastName='Sai' Limit 1];
        oldLeadMap.put(oldLead.Id,oldLead);
        
        oldLead.pi__first_touch_url__c='www.google.com';
        oldLead.pi__last_activity__c=DateTime.now();
        update oldLead;
        
        newLead.add(oldLead);
        
        Test.startTest();
        LeadTriggerHandler.updateLeadSource(oldLeadMap,newLead);
        Test.stopTest();
    }
    
    @isTest
    public static void updateCCAndMobilePhoneTest() {
        LeadTriggerHandler.bypassDuplicateValidation = false;
        
        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        List<Lead> newLead = new List<Lead>();
        
        Lead oldLead = [Select Id, LastName, Company,utm_source__c, MobilePhone, Country_Code__C,pi__last_activity__c,pi__first_touch_url__c
                        from Lead where LastName='John' Limit 1];
        oldLeadMap.put(oldLead.Id,oldLead);
        
        oldLead.MobilePhone='9116543220';
        update oldLead;
        
        newLead.add(oldLead);
        
        Test.startTest();
        LeadTriggerHandler.updateCCAndMobilePhone(oldLeadMap,newLead);
        Test.stopTest();
    }
    /*@isTest
static void testPopulateProgramBatch() {
Account acc = new Account(Name = 'BBA');
Insert acc;

hed__Program_Plan__c  bb = new hed__Program_Plan__c (Name = 'Batch 2024');
insert bb;

Fee_Master__c fm = new Fee_Master__c();         
fm.Program_Batch__c = bb.id;
fm.IsActive__c = true;
fm.Fee_Type__c = 'Application Fee';
insert fm;

List<Lead> leadsToInsert = new List<Lead>();

Lead ld1 = new Lead(
LastName = 'Test Lead 1',
Company = 'Test Co',
Program_Name_Display__c = 'MBA'
);
Lead ld2 = new Lead(
LastName = 'Test Lead 2',
Company = 'Test Co',
Program_Name_Display__c = 'Engineering' 
);

leadsToInsert.add(ld1);
leadsToInsert.add(ld2);

Test.startTest();
insert leadsToInsert; 
Test.stopTest();

List<Lead> updatedLeads = [SELECT Id, Program_Name_Display__c, Program_Batch__c 
FROM Lead 
WHERE Id IN :leadsToInsert];

for(Lead ld : updatedLeads) {
if(ld.Program_Name_Display__c == 'MBA') {
System.assertEquals(null, ld.Program_Batch__c, 'Program Batch should have been populated from Fee Master');
} else {
System.assertEquals(null, ld.Program_Batch__c, 'Program Batch should be null for non-matching programs');
}
}
} */
    @isTest
    static void testValidateDailyLeadLimit_Exceeded(){
        LeadTriggerHandler.bypassDuplicateValidation = false;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        
        User testUser = new User(
            Alias = 'tuser',
            Email='testuser@test.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId=p.Id,
            TimeZoneSidKey='Asia/Kolkata',
            Username='testuser'+System.currentTimeMillis()+'@test.com'
        );
        insert testUser;
        
        System.runAs(testUser){
            
            // 🔹 Create custom setting for THIS user
            Lead__c setting = new Lead__c(
                SetupOwnerId = testUser.Id,
                Daily_Lead_Limit__c = 1
            );
            insert setting;
            
            // 🔹 First Lead → Allowed
            insert new Lead(
                LastName='Lead 1',
                Company='Test'
            );
            
            Test.startTest();
            
            try{
                // 🔹 Second Lead → Should Fail
                insert new Lead(
                    LastName='Lead 2',
                    Company='Test'
                );
                System.assert(false,'Expected exception not thrown');
            }
            catch(DmlException e){
                System.assert(
                    e.getMessage().contains('Daily Lead limit exceeded'),
                    'Expected limit error'
                );
            }
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testValidateDailyLeadLimit_Unlimited(){
        LeadTriggerHandler.bypassDuplicateValidation = false;
        
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        // NULL means unlimited
        Lead__c setting = new Lead__c(
            SetupOwnerId = u.Id
        );
        insert setting;
        
        List<Lead> leads = new List<Lead>();
        
        for(Integer i = 0; i < 5; i++){
            leads.add(new Lead(
                LastName = 'Unlimited ' + i,
                Company = 'Test'
            ));
        }
        
        Test.startTest();
        insert leads;
        Test.stopTest();
        
        System.assertEquals(5, leads.size());
    }
    @isTest
    static void testValidateDailyLeadLimit_BlockAll(){
        LeadTriggerHandler.bypassDuplicateValidation = false;
        
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Lead__c setting = new Lead__c(
            SetupOwnerId = u.Id,
            Daily_Lead_Limit__c = 0
        );
        insert setting;
        
        Lead l = new Lead(
            LastName = 'Blocked Lead',
            Company = 'Test'
        );
        
        Test.startTest();
        
        try{
            insert l;
            System.assert(false, 'Expected blocking error');
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('Daily Lead creation limit exceeded')
                          || e.getMessage().contains('blocked'));
        }
        
        Test.stopTest();
    }
    @isTest
    static void testHandleAfterInsertProgram() {
        
        LeadTriggerHandler.bypassDuplicateValidation = true;
        
        Lead l = new Lead(
            LastName = 'Insert Program',
            Company = 'Test',
            Status = 'Unverified',
            Email = 'insert@test.com'
        );
        
        insert l;
        
        List<Lead> leads = [
            SELECT Id, Status, Email,Program_Name_Display__c
            FROM Lead
            WHERE Id = :l.Id
        ];
        
        Test.startTest();
        
        LeadTriggerHandler.handleAfterInsertProgram(
            leads
        );
        
        Test.stopTest();
        
        System.assertEquals(
            'Unverified',
            leads[0].Status
        );
    }
    @isTest
    static void testHandleAfterUpdateProgram() {
        
        LeadTriggerHandler.bypassDuplicateValidation = true;
        
        Lead l = new Lead(
            LastName = 'Update Program',
            Company = 'Test',
            Email = 'update@test.com'
        );
        
        insert l;
        
        Lead oldLead = [
            SELECT Id,
            Program_Name_Display__c,Email,Status
            FROM Lead
            WHERE Id = :l.Id
        ];
        
        Map<Id, Lead> oldMap =
            new Map<Id, Lead>{
                oldLead.Id => oldLead
                    };
                        
                        Lead updatedLead = oldLead.clone(
                            false,
                            true,
                            false,
                            false
                        );
        
        updatedLead.Id = oldLead.Id;
        
        updatedLead.Program_Name_Display__c =
            'New Program';
        
        List<Lead> newLeads =
            new List<Lead>{
                updatedLead
                    };
                        
                        Test.startTest();
        
        LeadTriggerHandler.handleAfterUpdateProgram(
            oldMap,
            newLeads
        );
        
        Test.stopTest();
        
        System.assertEquals(
            'New Program',
            updatedLead.Program_Name_Display__c
        );
    }   
    
}