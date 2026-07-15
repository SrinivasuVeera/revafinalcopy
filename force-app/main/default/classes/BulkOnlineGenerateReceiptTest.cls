@isTest
public class BulkOnlineGenerateReceiptTest {
    @isTest
    static void applicationfeePaidMethod(){
        list<Student_Payment__c> stpList = new  list<Student_Payment__c>();
          Contact testContact = new Contact();
        testContact.FirstName = 'John';
        testContact.LastName='Test Contact' ;
        testContact.Email='test@test.com';
        testContact.Application_Number__c = '2211001120';
        insert testContact;

        
        Student_Payment__c stpy = new Student_Payment__c();
        stpy.Mode_of_Payment__c ='online'; 
        stpy.Payment_Status__c = 'Success';
        stpy.Fee_Type__c = 'Application Fee';
        stpy.Payment_Gateway__c = 'Paytm';
        stpy.Transaction_ID__c = '123644';
        stpy.Contact__c= testContact.id;
        insert stpy;
       stpList.add(stpy);
               
        //test content version 
        ContentVersion testcontent=new ContentVersion(); 
        testcontent.Title='Test Receipt';
        Blob bodyBlob=Blob.valueOf('Test Content'); 
        testcontent.FirstPublishLocationId=stpy.Id;
        testcontent.PathOnClient = 'Test Receipt';
        testcontent.VersionData = bodyBlob;
        insert testcontent;
        
      stpList = [select id,Payment_Status__c,Fee_Type__c,contact__r.Email,contact__c,
                                          Contact__r.Application_Number__c,contact__r.Name,Transaction_Id__c,
                                          Payment_Gateway__c FROM Student_Payment__c WHERE Id IN : stpList];

        BulkOnlineGenerateReceipt.generateReceipt(stpList);
    }
    
    @isTest
    static void PAFfeePaidMethod(){
        list<Student_Payment__c> stpList = new  list<Student_Payment__c>();
          Contact testContact = new Contact();
        testContact.FirstName = 'John';
        testContact.LastName='Test Contact' ;
        testContact.Email='test@test.com';
        testContact.Application_Number__c = '2211001120';
        insert testContact;

        
        Student_Payment__c stpy = new Student_Payment__c();
        stpy.Mode_of_Payment__c ='online'; 
        stpy.Payment_Status__c = 'Success';
        stpy.Fee_Type__c = 'University Fee';
        stpy.Payment_Gateway__c = 'Paytm';
        stpy.Transaction_ID__c = '123644';
        stpy.Contact__c= testContact.id;
        insert stpy;
       stpList.add(stpy);
               
        //test content version 
        ContentVersion testcontent=new ContentVersion(); 
        testcontent.Title='Test Receipt';
        Blob bodyBlob=Blob.valueOf('Test Content'); 
        testcontent.FirstPublishLocationId=stpy.Id;
        testcontent.PathOnClient = 'Test Receipt';
        testcontent.VersionData = bodyBlob;
        insert testcontent;
        
      stpList = [select id,Payment_Status__c,Fee_Type__c,contact__r.Email,contact__c,
                                          Contact__r.Application_Number__c,contact__r.Name,Transaction_Id__c,
                                          Payment_Gateway__c FROM Student_Payment__c WHERE Id IN : stpList];

        BulkOnlineGenerateReceipt.generatePAFReceipt(stpList);
    }

}