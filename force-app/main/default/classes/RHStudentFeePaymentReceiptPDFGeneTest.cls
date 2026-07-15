@isTest
private class RHStudentFeePaymentReceiptPDFGeneTest {
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }  

   @isTest
    static void testGenerateReceiptPDFAsync() {
        // Create test Contact records
        Contact father = new Contact(FirstName = 'Michael', LastName = 'Doe', Email = 'michael.doe@example.com');
        insert father;
        
        Contact mother = new Contact(FirstName = 'Sarah', LastName = 'Doe', Email = 'sarah.doe@example.com');
        insert mother;
        
        Contact student = new Contact(
            FirstName = 'John', 
            LastName = 'Doe', 
            Email = 'john.doe@example.com', 
            Father__c = father.Id, 
            Mother__c = mother.Id
        );
        insert student;
        
        Student_Fee__c studentFee = new Student_Fee__c(
            Contact__c = student.Id,
            Payment_Type__c = 'Full Payment'
        );
        insert studentFee;
        
        // Create test Student_Fee_Payment__c record
        Student_Fee_Payment__c payment = new Student_Fee_Payment__c(
            Amount__c = 100.00,
            Student_Fee__c = studentFee.Id,
            Transaction_Date_Time__c = System.now(),
            Line_Item_Payment_Status__c = 'Success'
        );
        insert payment;
        
        Reva_Hostel_Room__c hostelRoom = new Reva_Hostel_Room__c(
            Name = '100',
            Dormitory_Type__c = 'Boys',
            Block__c = 'A',
            Floor__c = 'SF', 
            Room_Type__c = 'Student',
            Room_Category__c = 'Eng CS',
            Maximum_Occupancy__c = '4'
        );
        insert hostelRoom;
        
        // Create test Reva_Hostel_Request__c record
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = student.Id,
            Reva_Hostel_Room__c = hostelRoom.Id, 
            Status__c = 'Room Alloted',
            Type__c = '1'
        );
        insert hostelRequest;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        RHStudentFeePaymentReceiptPDFGenerator.generateReceiptPDFAsync(payment.Id);
        Test.stopTest();
        
        // Verify Attachment record
        List<Attachment> attachments = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId = :payment.Id];
        System.assertEquals(1, attachments.size(), 'Attachment record should be created');
        
        // Verify ContentVersion record
        List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Title LIKE 'PaymentReceipt_%'];
     
    }
    
    
}