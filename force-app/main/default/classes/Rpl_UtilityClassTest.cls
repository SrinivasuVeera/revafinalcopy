@isTest
public class Rpl_UtilityClassTest {
    
    // Mock class for HTTP callouts
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // You can customize the response as needed for testing
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    @isTest
    static void testSendEmailWithPlainTextBody() {
        // Create test data
        Map<String, Map<String, String>> toAddressToValues = new Map<String, Map<String, String>>();
        Map<String, String> emailValues = new Map<String, String>();
        emailValues.put('subject', 'Test Subject');
        emailValues.put('body', 'Test Body');
        toAddressToValues.put('test@example.com', emailValues);
        
        // Set up mock HTTP callout
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        // Call the method to test
        Rpl_UtilityClass.sendEmailWithPlainTextBody(toAddressToValues);
        Test.stopTest();
        
        // Add assertions as needed
        // Check if emails were sent successfully, maybe by querying EmailMessage objects
    }
    
    @isTest
    static void testSendEmailWithAttachment() {
        // Create test data
        String emailSubject = 'Test Subject';
        String emailBody = 'Test Body';
        String[] toAddresses = new String[]{'test@example.com'};
            Blob attachmentBody = Blob.valueOf('Test Attachment');
        String attachmentName = 'TestAttachment.txt';
        
        // Set up mock HTTP callout
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        // Call the method to test
        Rpl_UtilityClass.sendEmailWithAttachment(emailSubject, emailBody, toAddresses, attachmentBody, attachmentName);
        Test.stopTest();
        
        // Add assertions as needed
        // Check if emails were sent successfully, maybe by querying EmailMessage objects
    }
    
    @isTest(SeeALLData = true)
    static void testSendEmailsUsingTemplate() {
        String templateId = Label.RPL_Final_Round_Offered_Email_Template_ID;
        
        
        List<Rpl_Student_Registration_Drive__c> srdList = [SELECT Id, Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c, Rpl_Student_Registration__r.Contact__c FROM Rpl_Student_Registration_Drive__c 
                                                       Where Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c = 'test@gmail.com' Limit 1];
        
        if(srdList.isEmpty()){            
            Contact eCon = new Contact();
            eCon.lastName = 'LastNameTest';
            eCon.Email = 'test@gmail.com';
            eCon.SRN_Number__c = '12345123';
            eCon.Phone = '8980293839';
            insert eCon;
            
            Rpl_Student_Registration__c std = new Rpl_Student_Registration__c();
            std.Name = 'Student Name 1';
            std.Rpl_Personal_Mail_ID__c = 'test@gmail.com';
            std.Rpl_Interested_in_placement__c = 'Yes';
            std.Rpl_University_Mail_ID__c = '123123123@reva.edu.in';
            std.Contact__c = eCon.Id;
            std.Rpl_Contact_No__c = '7820911232';
            insert std;
            
            Date startDate = Date.today();
            startDate.addDays(2);        
            Date endDate = Date.today();
            endDate.addDays(7);
            Rpl_Reva_Placement__c rpl = new Rpl_Reva_Placement__c();
            rpl.Rpl_Registration_Start_Date__c = startDate;
            rpl.Rpl_Registration_End_Date__c = endDate;
            rpl.Name = 'Test Reva Placement-01';
            insert rpl;
            
            Rpl_Company__c  cmp1 = new Rpl_Company__c();
            cmp1.Name = 'Cloud Odyssey';
            insert cmp1;
            
            
            Rpl_Placement_Drive__c plc = new Rpl_Placement_Drive__c();
            plc.Name = 'Cloud Odyssey Drive A';
            plc.Reva_Placement__c = rpl.Id;
            plc.Rpl_Event_Date_Time__c = DateTime.Now().addDays(20); 
            plc.Rpl_Event_End_Date__c = Date.today().addDays(3);
            plc.Rpl_Event_Date__c = Date.today();
            plc.Rpl_Company_Name__c = cmp1.Id;
            plc.Rpl_CTC__c = 500000;
            insert plc; 
            
            Rpl_Student_Registration_Drive__c stdr = new Rpl_Student_Registration_Drive__c();
            stdr.Rpl_Placement_Drive__c =  plc.Id;
            stdr.Rpl_Student_Registration__c = std.Id;
            stdr.Rpl_Is_Failed__c = false;
            insert stdr;            
        }
        
        List<Rpl_Student_Registration_Drive__c> srdList2 = [SELECT Id, Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c, Rpl_Student_Registration__r.Contact__c FROM Rpl_Student_Registration_Drive__c 
                                                       Where Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c = 'test@gmail.com' Limit 1];
        
        Rpl_Student_Registration_Drive__c srd = srdList2[0];
        
        Map<String, Map<string,string>> toAddressToValues = new Map<String, Map<string,string>>();
        Map<String, String> emailValues = new Map<String, String>();
        emailValues.put('whatId' , srd.Id);
        emailValues.put('targetObjectId',srd.Rpl_Student_Registration__r.Contact__c);
        emailValues.put('emailTemplateId', templateId);
        toAddressToValues.put(srd.Rpl_Student_Registration__r.Rpl_Personal_Mail_ID__c, emailValues);
        Test.startTest();
        Rpl_UtilityClass.sendEmailsUsingTemplate(toAddressToValues);
        Test.stopTest();
    }
    
    @isTest(seeAllData = true)
    static void testSendWhatsAppNotification() {
        // Create test data
        Map<String, Map<String, String>> toAddressToValues = new Map<String, Map<String, String>>();
        Map<String, String> whatsappValues = new Map<String, String>();
        whatsappValues.put('studentname', 'TestStudent');
        whatsappValues.put('date', '2022-01-31');
        whatsappValues.put('companyname', 'Cloud Odyssey');
        whatsappValues.put('registrationurl', 'www.test.salesforce.com');
        whatsappValues.put('time', '10:00 AM');
        whatsappValues.put('graduatingyear', '2024');
        whatsappValues.put('venue', 'bangalore');
        
        toAddressToValues.put('1234567890', whatsappValues);
        
        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        // Call the method to test
        Rpl_UtilityClass.sendWhatsAppNotification('placement_registration', toAddressToValues);
        Rpl_UtilityClass.sendWhatsAppNotification('drive_intimation_registration_copy1', toAddressToValues);
        Rpl_UtilityClass.sendWhatsAppNotification('final_selection', toAddressToValues);
        Rpl_UtilityClass.sendWhatsAppNotification('drive_confirmation_copy1', toAddressToValues);
        Test.stopTest();
        
    }
    
    @isTest(seeAllData= true)
    static void testSendWhatsAppNotificationAsync() {
        // Create test data
        String jsonString = '{"1234567890":{"studentname":"TestStudent","date":"2022-01-31","companyname":"TestCompany", "registrationurl" : "www.test.salesforce.com", "time" : "10:00 AM", "graduatingyear" : "2024", "venue": "bangalore"}}';
        
        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        // Call the method to test
        Rpl_UtilityClass.sendWhatsAppNotificationAsync('placement_registration', jsonString);
        Rpl_UtilityClass.sendWhatsAppNotificationAsync('drive_intimation_registration_copy1', jsonString);
        Rpl_UtilityClass.sendWhatsAppNotificationAsync('final_selection', jsonString);
        Rpl_UtilityClass.sendWhatsAppNotificationAsync('drive_confirmation_copy1', jsonString);
        
        Test.stopTest();
    }
     @isTest(seeAllData=true)
    static void testSendSMS() {
    	Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Map<String, String> testNumbersToMessages = new Map<String, String>{
            '1234567890' => 'Test message 1',
            '9876543210' => 'Test message 2'
        };
    
        Test.startTest();
        Rpl_UtilityClass.sendSMS('Placement registration', testNumbersToMessages);
        Test.stopTest();
    }
    
    @isTest(seeAllData=true)
    static void testSendSMSAsync() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        // Create test data
        Map<String, String> testNumbersToMessages = new Map<String, String>{
            '1234567890' => 'Test message 1',
            '9876543210' => 'Test message 2'
        };
        
        // Call the method
        Test.startTest();
        Rpl_UtilityClass.sendSMSAsync('Placement registration', testNumbersToMessages);
        Test.stopTest();
    }
}