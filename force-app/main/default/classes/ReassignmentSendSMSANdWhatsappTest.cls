@isTest
public class ReassignmentSendSMSANdWhatsappTest {
 private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = ' {"submitResponses":[{"transactionId":23937971773,"state":"INVALID_MSISDN","description":"4005:Invalid Msisdn [1234132] for country [IN]","pdu":4,"corelationId":null}]}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(202);
            return res;
        }
    }   
   Public class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        String fullJson = '{"unicode":"False","sender":"REVAUN","message":{"text":"Dear Applicant\r\n\r\nMake a payment of Rs. 8000.00 to confirm your Provisional Admission at https:/\r\neva-university--couat1908.sandbox.my.site.com/Admissions/s/payment-page?contactId=0030T00000VQx7FQAT&isPAF=true&stupayid=a1P0T000001WIxSUAW.\r\nIn case of confusion connect with your admission counsellor.\r\n\r\nRegards\r\nREVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007028137269399166","corelationId":null}}';
        HttpResponse res = new HttpResponse();
       res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
        return res;
    }
   }
        
   /*@IsTest(SeeAllData=true)
    public static void WhatsAppTest() {
        
        List<Contact> conList = new List<Contact>(); // Create test contacts and necessary related data
            List<Id> conIds = new List<Id>();
         Contact testContact1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'jun1@gmail.com',
          MobilePhone = '1234567890',
         Check_OwnerChnage__c = False,// Assuming this is the format you use for WhatsApp numbers
              Assigned__c = True
        );
        conList.add(testContact1);

           
         List<Contact> testContacts = new List<Contact>();
        for(Integer i=0; i<5; i++) {
            testContacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + i,
                MobilePhone = '123456789' + i,
                OwnerId = UserInfo.getUserId(),
                Check_OwnerChnage__c = false,
                Application_Number__c = 'APP' + i,
                 Assigned__c = True
            ));
        }
        insert testContacts;
        conIds.add(testContact1.id);

         Test.setMock(HttpCalloutMock.class, new RestMock());
        
        //Call the handler
        Test.startTest();
        
        ReassignmentSendSMSANdWhatsapp.SendWhatsApptoApplicant(conList, 'lead_reassignment');
        ReassignmentSendSMSANdWhatsapp.SendWhatsApptoOwner(testContacts, 'counselor_reassignment');
         Test.stopTest();
    }*/
    
    @IsTest
public static void WhatsAppTest() {

    String uniqueStr = String.valueOf(System.currentTimeMillis());

    List<Contact> conList = new List<Contact>();

    Contact testContact1 = new Contact(
        FirstName = 'John',
        LastName = 'Doe',
        Email = 'jun1' + uniqueStr + '@gmail.com',
        MobilePhone = '1234567' + uniqueStr.substring(7),
        Check_OwnerChnage__c = false,
        Assigned__c = true
    );
    conList.add(testContact1);

    insert conList; // ✅ MISSING BEFORE

    List<Contact> testContacts = new List<Contact>();
    for(Integer i=0; i<5; i++) {
        testContacts.add(new Contact(
            FirstName = 'Test',
            LastName = 'Contact ' + i,
            Email = 'test' + i + uniqueStr + '@gmail.com',
            MobilePhone = '99999' + i + uniqueStr.substring(7),
            OwnerId = UserInfo.getUserId(),
            Check_OwnerChnage__c = false,
            Application_Number__c = 'APP' + i + uniqueStr,
            Assigned__c = true
        ));
    }
    insert testContacts;

    Test.setMock(HttpCalloutMock.class, new RestMock());

    Test.startTest();
    ReassignmentSendSMSANdWhatsapp.SendWhatsApptoApplicant(conList, 'lead_reassignment');
    ReassignmentSendSMSANdWhatsapp.SendWhatsApptoOwner(testContacts, 'counselor_reassignment');
    Test.stopTest();
}
      @IsTest(SeeAllData=true)
    public static void WhatsAppLead() {
            Profile pr = [SELECT Id, Name, Description FROM Profile where name ='System Administrator' LIMIT 1];
        User us = new User(
            firstName ='test',
            lastName ='User',
            Email='test@gmail.com',
            isActive = true,
            Username = 'test@gmail.com.reva.COUAT1908', 
            Alias ='lal',
            TimeZoneSidKey ='Asia/Kolkata', 
            LocaleSidKey='en_IN',
            EmailEncodingKey ='UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = pr.Id ,
            Phone = '9999999999',
            mobilePhone='9999999999'
        );
        insert us; 
        List<Lead> conList = new List<Lead>();
     
    Lead testContact1 = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'jun1@gmail.com',
          MobilePhone = '1234567890',
         Check_OwnerChnage__c = False,// Assuming this is the format you use for WhatsApp numbers
         Assigned__c = True
        );
        
        conList.add(testContact1);
       // conIds.add(testContact1.Id);
         List<Lead> testLeads = new List<Lead>();
        for(Integer i=0; i<5; i++) {
            testLeads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead ' + i,
                MobilePhone = '123456979' + i,
                 Check_OwnerChnage__c = false,
                Application_Number__c = 'APP' + i,
                ownerId = us.Id,
                 Assigned__c = True
            ));
        }
        insert testLeads;
        
         Test.setMock(HttpCalloutMock.class, new RestMock());
        
        //Call the handler
        Test.startTest(); 
       ReassignmentSendSMSANdWhatsapp.SendWhatsApptoLead(conList, 'lead_reassignment');
       ReassignmentSendSMSANdWhatsapp.SendWhatsApptoLeadOwner(testLeads, 'counselor_reassignment');
   
        Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    static void testMakeCalloutAsync() {
        // Create test data
        Profile pr = [SELECT Id, Name, Description FROM Profile where name ='System Administrator' LIMIT 1];
        User us = new User(
            firstName ='test',
            lastName ='User',
            Email='test@gmail.com',
            isActive = true,
            Username = 'test@gmail.com.reva.COUAT1908', 
            Alias ='lal',
            TimeZoneSidKey ='Asia/Kolkata', 
            LocaleSidKey='en_IN',
            EmailEncodingKey ='UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = pr.Id ,
            Phone = '9999999999',
            mobilePhone='9999999999'
        );
        insert us;       
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            MobilePhone = '1234567890', // Ensure MobilePhone is not null
            Check_OwnerChnage__c = False,
            OwnerId=us.id,
            Assigned__c = True
        );
        insert testContact;

        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            MobilePhone = '1234567865', // Ensure MobilePhone is not null
            Check_OwnerChnage__c = False,
            OwnerId=us.Id,
            Assigned__c = True
        );
        insert testLead;
    
        list<Id> testSet = new list<Id>();
        testSet.add(testContact.Id);
         list<Id> testSetLead = new list<Id>();
        testSetLead.add(testLead.Id);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        // Call the method under test
        ReassignmentSendSMSANdWhatsapp.makeCalloutAsyncContact(testSet);
         ReassignmentSendSMSANdWhatsapp.makeCalloutAsyncLead(testSetLead);
        Test.stopTest();
        
    }
     @isTest
    static void testExecute() {
        // Create test data
        List<Lead> testLeads = new List<Lead>();
        for(Integer i=0; i<5; i++) {
            testLeads.add(new Lead(FirstName = 'Test', LastName = 'Lead ' + i));
        }
        insert testLeads;
        
        List<Id> leadIds = new List<Id>();
        for(Lead l : testLeads) {
            leadIds.add(l.Id);
        }
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Start Test
        Test.startTest();
        // Enqueue the queueable job
        QueueableBulkLeadSMSNotification queueableJob = new QueueableBulkLeadSMSNotification(leadIds);
        System.enqueueJob(queueableJob);
        Test.stopTest();
        
      }
}