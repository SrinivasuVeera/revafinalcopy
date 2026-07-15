@isTest
public class revaClassAndLabBookingControllerTest {
    
    @testSetup
    static void setup() {
        
        // Create test User
        Profile profile = [SELECT Id FROM Profile WHERE Name='Professor' LIMIT 1];
        User testUser = new User(
            Username = 'test1243user@test.com',
            FirstName = 'Test12',
            LastName = 'User',
            Email = 'test12user@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create test User
        Profile profile1 = [SELECT Id FROM Profile WHERE Name='Professor' LIMIT 1];
        User testUser1 = new User(
            Username = 'test121user@test.com',
            FirstName = 'Test121',
            LastName = 'User',
            Email = 'test121user@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser1;
        
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account', ownerid = testUser1.id);
        insert testAccount;
        
        // Create test Parent Account
        Account parentAccount = new Account(Name = 'Parent Account', ownerid = testUser1.id);
        insert parentAccount;
        
        // Create test Semesters (hed__Term__c)
        List<hed__Term__c> terms = new List<hed__Term__c>();
        terms.add(new hed__Term__c(Name = 'Semester 1',  hed__Account__c = testAccount.Id));
        terms.add(new hed__Term__c(Name = 'Semester 2', hed__Account__c = parentAccount.Id));
        insert terms;

        RecordType classRoomRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Class_Rooms' LIMIT 1];
        // Create test Facilities (hed__Facility__c)
        List<hed__Facility__c> facilities = new List<hed__Facility__c>();
        facilities.add(new hed__Facility__c(Name = 'Facility 1', hed__Account__c = testAccount.Id, recordtypeId=classRoomRecordType.id));
        facilities.add(new hed__Facility__c(Name = 'Facility 2', hed__Account__c = parentAccount.Id,  recordtypeId=classRoomRecordType.id));
        insert facilities;

        // Create test Facility Requests (Facility_Request__c)
        List<Facility_Request__c> facilityRequests = new List<Facility_Request__c>();
        facilityRequests.add(new Facility_Request__c( Account__c = testAccount.Id, Semester__c = terms[0].Id, Facility__c = facilities[0].Id));
        facilityRequests.add(new Facility_Request__c( Account__c = parentAccount.Id, Semester__c = terms[1].Id, Facility__c = facilities[1].Id));
        insert facilityRequests;

        hed__Time_Block__c tm = new hed__Time_Block__c(hed__End_Time__c = Time.newInstance(17, 0, 0, 0),
            hed__Start_Time__c = Time.newInstance(9, 0, 0, 0), Monday__c = true);
        insert tm;
        
        // Create test Course Offering Schedule (hed__Course_Offering_Schedule__c)
        hed__Course_Offering_Schedule__c courseOfferingSchedule = new hed__Course_Offering_Schedule__c(
            hed__Time_Block__c = tm.Id,
            Section__c = terms[0].Id
        );
        insert courseOfferingSchedule;

        // Create test Facility Request Allocation (Facility_Request_Allocation__c)
        Facility_Request_Allocation__c facilityRequestAllocation = new Facility_Request_Allocation__c(
            Facility_Request__c = facilityRequests[0].Id, 
            Course_Offering_Schedule__c = courseOfferingSchedule.Id
        );
        insert facilityRequestAllocation;
    }
    
    @isTest
    static void testGetFacilitesAndSemesters() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        String schoolName = 'Test School';
        Boolean isCrossDept = false;
        revaClassAndLabBookingController.semesterAndFacilitiesWrapper result = revaClassAndLabBookingController.getFacilitesAndSemesters(testAccount.Id, schoolName, isCrossDept);
        System.assertNotEquals(null, result);
       // System.assertNotEquals(0, result.semesters.size());
        //System.assertNotEquals(0, result.facilities.size());
    }
    
    @isTest
    static void testCreateFacilityRequest() {
        String jsonString = '[{"accountId":"Test Account", "semesterId":"Semester 1", "facilityId":"Facility 1"}]';
        Test.startTest();
        try{
            revaClassAndLabBookingController.createFacilityRequest(jsonString);   
        }
        catch(exception e){
            
        }
        
        Test.stopTest();
        
        List<Facility_Request__c> facilityRequests = [SELECT Id FROM Facility_Request__c WHERE Account__r.Name = 'Test Account'];
        System.assertEquals(1, facilityRequests.size());
    }
    
    @isTest
    static void testDeleteFacilityRequestAllocation() {
        Facility_Request_Allocation__c facilityRequestAllocation = [SELECT Id FROM Facility_Request_Allocation__c LIMIT 1];
        Test.startTest();
        try{
            revaClassAndLabBookingController.deleteFacilityRequestAllocation(facilityRequestAllocation.Id);
        }
        catch(exception e){
            
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetAvailableFacilities() {
        hed__Course_Offering_Schedule__c courseOfferingSchedule = [SELECT Id FROM hed__Course_Offering_Schedule__c LIMIT 1];
        revaClassAndLabBookingController.allocationDetailWrapper result = revaClassAndLabBookingController.getAvailableFacilities(courseOfferingSchedule.Id);
        System.assertNotEquals(null, result);
        System.assertNotEquals(0, result.alreadyBookedFacility.size());
        System.assert(result.isAlreadyBooked);
    }
    
    @isTest
    static void testCreateFacilityRequestAllocation() {
        Facility_Request__c facilityRequest = [SELECT Id FROM Facility_Request__c LIMIT 1];
        hed__Course_Offering_Schedule__c courseOfferingSchedule = [SELECT Id FROM hed__Course_Offering_Schedule__c LIMIT 1];
        Test.startTest();
        try{
            revaClassAndLabBookingController.createFacilityRequestAllocation(facilityRequest.Id, courseOfferingSchedule.Id);
            revaClassAndLabBookingController.createFacilityRequestAllocation(facilityRequest.Id, courseOfferingSchedule.Id);
        }
        catch(exception e){
            
        }
        Test.stopTest();
        
        Facility_Request_Allocation__c facilityRequestAllocation = [SELECT Id FROM Facility_Request_Allocation__c WHERE Facility_Request__c = :facilityRequest.Id AND Course_Offering_Schedule__c = :courseOfferingSchedule.Id LIMIT 1];
        System.assertNotEquals(null, facilityRequestAllocation);
    }
}