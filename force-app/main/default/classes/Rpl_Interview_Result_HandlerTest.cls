@isTest
public class Rpl_Interview_Result_HandlerTest {
    
    private class WhatsappNotificationMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    @testSetup
    private static void createDummyData(){
        Contact Father = new Contact();
        Father.lastName = 'Test Data';
        Father.Email = 'testfather@gmail.com';
        Father.MobilePhone = '8234823428';
        insert Father;
        
        Contact Mother = new Contact();
        Mother.lastName = 'Test Data';
        Mother.Email = 'testmother@gmail.com';
        Mother.MobilePhone = '9233492348';
        insert Mother;
        
        Contact eCon = new Contact();
        eCon.lastName = 'LastNameTest';
        eCon.Email = 'test@gmail.com';
        eCon.Mother__c = Mother.Id;
        eCon.Father__c = Father.Id;
        eCon.SRN_Number__c = '12345';
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
        cmp1.Name = 'Amozan';
        insert cmp1;
        
        Rpl_Company__c  cmp2 = new Rpl_Company__c();
        cmp2.Name = 'Amozan';
        insert cmp2;
        
        Rpl_Placement_Drive__c plc = new Rpl_Placement_Drive__c();
        plc.Name = 'Cloud Odyssey Drive';
        plc.Reva_Placement__c = rpl.Id;
        plc.Rpl_Event_Date_Time__c = DateTime.Now().addDays(20); 
        plc.Rpl_Event_End_Date__c = Date.today().addDays(3);
        plc.Rpl_Event_Date__c = Date.today();
        plc.Rpl_Company_Name__c = cmp1.Id;
        plc.Rpl_CTC__c = 500000;
        insert plc; 
        
        Rpl_Placement_Drive__c pd = new Rpl_Placement_Drive__c();
        pd.Name = 'JP Morgan Chase Drive';
        pd.Reva_Placement__c = rpl.Id;
        pd.Rpl_Event_Date_Time__c = DateTime.Now().addDays(20); 
        pd.Rpl_Event_End_Date__c = Date.today().addDays(3);
        pd.Rpl_Event_Date__c = Date.today();
        pd.Rpl_Company_Name__c = cmp2.Id;
        pd.Rpl_CTC__c = 500000;
        insert pd; 
        
        Rpl_Interview__c JPMround1 = new Rpl_Interview__c();
        JPMround1.Name = 'Aptitude';
        JPMround1.Rpl_Round_Number__c = 1;
        JPMround1.Placement_Drive__c = pd.Id;
        JPMround1.Rpl_Is_Final_Round__c = true;
        insert JPMround1;
        
        Rpl_Interview__c rs1 = new Rpl_Interview__c();
        rs1.Name = 'Aptitude';
        rs1.Rpl_Round_Number__c = 1;
        rs1.Placement_Drive__c = plc.Id;
        insert rs1;
        
        Rpl_Interview__c rs2 = new Rpl_Interview__c();
        rs2.Name = 'Technical';
        rs2.Rpl_Round_Number__c = 2;
        rs2.Placement_Drive__c = plc.Id;
        rs2.Rpl_Is_Final_Round__c = true;
        insert rs2;
        
        Rpl_Student_Registration_Drive__c stdr = new Rpl_Student_Registration_Drive__c();
        stdr.Rpl_Placement_Drive__c =  plc.Id;
        stdr.Rpl_Student_Registration__c = std.Id;
        stdr.Rpl_Interview__c = rs1.Id;
        stdr.Rpl_Is_Failed__c = false;
        insert stdr;
    }
    
    @isTest
    private static void checkForShortlisted(){
        Test.setMock(HttpCalloutMock.class, new WhatsappNotificationMockCallout());
        Rpl_Interview_Result__c result = new Rpl_Interview_Result__c();
        result.Name = 'Aptitude';
        result.Rpl_SRN__c = '12345';
        result.Rpl_Round_Number__c = 1;
        result.Rpl_Result__c = 'Shortlisted';
        result.Rpl_Drive_Name__c = 'Cloud Odyssey Drive';
        
        Test.startTest();
        insert result;
        Test.stopTest();
        
        Rpl_Placement_Drive__c placementDrive = [Select Id From Rpl_Placement_Drive__c Where Name = 'Cloud Odyssey Drive'];
        Rpl_Interview__c secondRound = [Select Id From Rpl_Interview__c Where Rpl_Round_Number__c = 2 And Placement_Drive__c=:placementDrive.Id Limit 1];
        Rpl_Student_Registration_Drive__c srd = [Select Id ,  Rpl_Interview__c, Rpl_Interview__r.Name,  Rpl_Interview__r.Rpl_Round_Number__c , Rpl_Is_Offered__c, Rpl_Is_Result_Out__c, Rpl_Is_Failed__c From Rpl_Student_Registration_Drive__c Where Rpl_Placement_Drive__c =: placementDrive.Id Limit 1];
        System.debug('SRD 1 ' + srd);
        System.assertEquals(srd.Rpl_Interview__c, secondRound.Id, 'Result Update Failed');
        
    }
    
    @isTest
    private static void checkForRejected(){
        Test.setMock(HttpCalloutMock.class, new WhatsappNotificationMockCallout());
        
        Rpl_Interview_Result__c result = new Rpl_Interview_Result__c();
        result.Name = 'Aptitude';
        result.Rpl_SRN__c = '12345';
        result.Rpl_Round_Number__c = 1;
        result.Rpl_Result__c = 'Rejected';
        result.Rpl_Drive_Name__c = 'Cloud Odyssey Drive';
        
        Test.startTest();
        insert result;
        Test.stopTest();
        
        Rpl_Placement_Drive__c placementDrive = [Select Id From Rpl_Placement_Drive__c Where Name = 'Cloud Odyssey Drive'];
        Rpl_Interview__c firstRound = [Select Id From Rpl_Interview__c Where Rpl_Round_Number__c = 1 And Placement_Drive__c=:placementDrive.Id Limit 1];
        Rpl_Student_Registration_Drive__c srd = [Select Id , Rpl_Interview__c From Rpl_Student_Registration_Drive__c Where Rpl_Placement_Drive__c =: placementDrive.Id Limit 1];
        
        System.assertEquals(srd.Rpl_Interview__c, firstRound.Id, 'Result Update Failed'); 
    }
    
    
    @isTest
    private static void checkForOffered(){
        Test.setMock(HttpCalloutMock.class, new WhatsappNotificationMockCallout());
        
        Rpl_Interview_Result__c result1 = new Rpl_Interview_Result__c();
        result1.Name = 'Aptitude';
        result1.Rpl_SRN__c = '12345';
        result1.Rpl_Round_Number__c = 1;
        result1.Rpl_Result__c = 'Shortlisted';
        result1.Rpl_Drive_Name__c = 'Cloud Odyssey Drive';
        
        insert result1;
        
        Rpl_Interview_Result__c result2 = new Rpl_Interview_Result__c();
        result2.Name = 'Technical';
        result2.Rpl_SRN__c = '12345';
        result2.Rpl_Round_Number__c = 2;
        result2.Rpl_Result__c = 'Offered';
        result2.Rpl_Drive_Name__c = 'Cloud Odyssey Drive';
        
        Test.startTest();
        insert result2;
        Test.stopTest();
        
        Rpl_Placement_Drive__c placementDrive = [Select Id From Rpl_Placement_Drive__c Where Name = 'Cloud Odyssey Drive'];
        Rpl_Interview__c secondRound = [Select Id From Rpl_Interview__c Where Rpl_Round_Number__c = 2 And Placement_Drive__c=:placementDrive.Id Limit 1];
        Rpl_Student_Registration_Drive__c srd = [Select Id , Rpl_Interview__c, Rpl_Interview__r.Name,  Rpl_Interview__r.Rpl_Round_Number__c , Rpl_Is_Offered__c, Rpl_Is_Result_Out__c, Rpl_Is_Failed__c From Rpl_Student_Registration_Drive__c Where Rpl_Placement_Drive__c =: placementDrive.Id Limit 1];
        
        System.debug('SRD 2' + srd);
        System.assertEquals(srd.Rpl_Interview__c, secondRound.Id, 'Result Update Failed');
        System.assertEquals(true, srd.Rpl_Is_Result_Out__c, 'Is Result Out Not Updated');
        System.assertEquals(true, srd.Rpl_Is_Offered__c, 'Result Update Failed, Is Offered Failed To Check');
        
    }
    
    @isTest
    private static void testByUploadingMultipleDriveResultAtOnce(){
        Test.setMock(HttpCalloutMock.class, new WhatsappNotificationMockCallout());
        
        Rpl_Interview_Result__c result1 = new Rpl_Interview_Result__c();
        result1.Name = 'Aptitude';
        result1.Rpl_SRN__c = '12345';
        result1.Rpl_Round_Number__c = 1;
        result1.Rpl_Result__c = 'Shortlisted';
        result1.Rpl_Drive_Name__c = 'Cloud Odyssey Drive';
        
        Rpl_Interview_Result__c result2 = new Rpl_Interview_Result__c();
        result2.Name = 'Aptitude';
        result2.Rpl_SRN__c = '12345';
        result2.Rpl_Round_Number__c = 1;
        result2.Rpl_Result__c = 'Shortlisted';
        result2.Rpl_Drive_Name__c = 'JP Morgan Chase Drive';
        
        List<Rpl_Interview_Result__c> resultList  = new List<Rpl_Interview_Result__c>{result1, result2};
            
            Test.startTest();
        insert resultList;
        Test.StopTest();
        
    }
    
}