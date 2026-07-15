public without sharing class revaClassAndLabBookingController {
    
    /* @AuraEnabled(cacheable=true)
public static List<Account> getSchools() {
return [SELECT Id, Name FROM Account WHERE RecordType.Name = 'University Department'];
}*/
    
    @AuraEnabled(cacheable=true)
    public static String getUserDepartment() {
        User currentUser = [SELECT Department , Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        string currentUserEmail = currentUser.Email;

        Contact currentUserContact = [SELECT Id , hed__WorkEmail__c, Account_Name__c FROM Contact WHERE hed__WorkEmail__c =: currentUserEmail LIMIT 1];
        system.debug('UserInfo.getUserId'+ UserInfo.getUserId());
        system.debug('currentUser.contact.Account_Name__c'+ currentUserContact.Account_Name__c);
        return currentUserContact.Account_Name__c;
    }
    
    @AuraEnabled(cacheable=true)
    public static semesterAndFacilitiesWrapper getFacilitesAndSemesters(String accountId , String schoolName, Boolean isCrossDept){
        List<string> schoolNames = new List<string>();
        schoolNames.add(schoolName);
        system.debug('schoolNames --->' + schoolNames);
        system.debug('schoolId --->' + schoolName);
        system.debug('accountId --->'+accountId);
        semesterAndFacilitiesWrapper wrapper = new semesterAndFacilitiesWrapper();
        /* wrapper.semesters = [SELECT Id, Name, Semester_Name_With_Date__c, Days_Remaining_To_Start__c
FROM  hed__Term__c 
WHERE (hed__Account__c=:accountId OR hed__Account__r.ParentId =:accountId)
AND Active__c = TRUE];*/
        
        
        wrapper.semesters = [SELECT Id, Name, School__c, Semester_Name_With_Date__c, Days_Remaining_To_Start__c
                             FROM  hed__Term__c 
                             WHERE  Active__c = TRUE AND School__c=: schoolName AND hed__Start_Date__c <= :Date.today().addDays(15) AND hed__Start_Date__c >= :Date.today().addDays(-120)];
        
        System.debug('wrapper.semesters ----->'+ wrapper.semesters);
        
        if(isCrossDept){
            wrapper.facilities = [SELECT Id, Display_Name__c,hed__Account__c, Name, hed__Account__r.ParentId FROM hed__Facility__c WHERE RecordType.Name != 'Event Venues' AND hed__Account__r.Name NOT IN :schoolNames];
            
        }else{
            wrapper.facilities = [SELECT Id, Display_Name__c,hed__Account__c, Name, hed__Account__r.ParentId FROM hed__Facility__c WHERE RecordType.Name != 'Event Venues' AND hed__Account__r.Name=: schoolName];
            
        }
        
        System.debug('wrapper.facilities ----->'+ wrapper.facilities);
        wrapper.alreadyBookedFacilites = [SELECT Id, Semester__c, Facility__c
                                          FROM Facility_Request__c
                                          WHERE (Account__c =: accountId OR Account__r.ParentId =:accountId)
                                          AND Semester__r.Active__c = TRUE ];
        System.debug('wrapper.alreadyBookedFacilites ----->'+ wrapper.alreadyBookedFacilites); 
        System.debug('wrapper ----->'+ wrapper);
        return wrapper;
    }
    
    
    /*@AuraEnabled(cacheable=true)
public static semesterAndFacilitiesWrapper getFacilitesAndSemestersDifferentDept(String accountId , String schoolName){
List<string> schoolNames = new List<string>();
schoolNames.add(schoolName);

system.debug('schoolId --->' + schoolName);
system.debug('accountId --->'+accountId);
semesterAndFacilitiesWrapper wrapper = new semesterAndFacilitiesWrapper();
wrapper.semesters = [SELECT Id, Name, Semester_Name_With_Date__c, Days_Remaining_To_Start__c
FROM  hed__Term__c 
WHERE (hed__Account__c=:accountId OR hed__Account__r.ParentId =:accountId)
AND Active__c = TRUE];

// List<Account> schoolAccounts = [SELECT Id, Name, Type FROM Account WHERE Id = :schoolId];

wrapper.semesters = [SELECT Id, Name, School__c, Semester_Name_With_Date__c, Days_Remaining_To_Start__c
FROM  hed__Term__c 
WHERE  Active__c = TRUE AND School__c=: schoolName AND hed__Start_Date__c= :Date.today().addDays(15)];

System.debug('wrapper.semesters ----->'+ wrapper.semesters);

wrapper.facilities = [SELECT Id, Display_Name__c,hed__Account__c, Name, hed__Account__r.ParentId FROM hed__Facility__c WHERE RecordType.Name != 'Event Venues' AND hed__Account__r.Name NOT IN :schoolNames];
System.debug('wrapper.facilities ----->'+ wrapper.facilities);
wrapper.alreadyBookedFacilites = [SELECT Id, Semester__c, Facility__c
FROM Facility_Request__c
WHERE (Account__c =: accountId OR Account__r.ParentId =:accountId)
AND Semester__r.Active__c = TRUE ];
System.debug('wrapper.alreadyBookedFacilites ----->'+ wrapper.alreadyBookedFacilites); 
System.debug('wrapper ----->'+ wrapper);
return wrapper;
}*/
    
    
    @AuraEnabled
    public static void createFacilityRequest(String jsonString){
        JSON2Apex obj  =  new JSON2Apex();
        List<JSON2Apex> jsonList = obj.parse(jsonString);
        List<Facility_Request__c> facilityRequests = new List<Facility_Request__c>();
        for(JSON2Apex eachObject : jsonList){
            Facility_Request__c facilityRequest = new Facility_Request__c();
            facilityRequest.Account__c = eachObject.accountId;
            facilityRequest.Semester__c = eachObject.semesterId; 
            facilityRequest.Facility__c = eachObject.facilityId;
            facilityRequests.add(facilityRequest); 
        }
        insert facilityRequests;
    }
    
    @AuraEnabled
    public static void deleteFacilityRequestAllocation(String facilityRequestAllocationId){
        delete [SELECT Id FROM Facility_Request_Allocation__c WHERE Id =: facilityRequestAllocationId];
    }
    
    /* @AuraEnabled(cacheable = true)
public static allocationDetailWrapper getAvailableFacilities(string courseOfferingScheduleId){
system.debug('courseOfferingScheduleId ---->'+ courseOfferingScheduleId);
allocationDetailWrapper wrapper = new allocationDetailWrapper();
List<Facility_Request_Allocation__c> alreadyBookedFacility = [SELECT Id, Name, Facility_Request__r.Facility__r.Display_Name__c
FROM Facility_Request_Allocation__c 
WHERE Course_Offering_Schedule__c=:courseOfferingScheduleId];
system.debug('alreadyBookedFacility ----->'+alreadyBookedFacility);

wrapper.isAlreadyBooked = alreadyBookedFacility.size() > 0;

wrapper.alreadyBookedFacility = alreadyBookedFacility;

System.debug('Wrapperrr ---->'+wrapper);

List<hed__Course_Offering_Schedule__c> courseOfferingSchedules = [
SELECT Section__c, 
hed__Time_Block__r.hed__End_Time__c,  
hed__Time_Block__r.hed__Start_Time__c,
hed__Time_Block__r.Monday__c,
hed__Time_Block__r.Tuesday__c,
hed__Time_Block__r.Wednesday__c,
hed__Time_Block__r.Thursday__c,
hed__Time_Block__r.Friday__c,
hed__Time_Block__r.Saturday__c,
hed__Time_Block__r.Sunday__c,
hed__Time_Block__r.Break__c,
hed__Course_Offering__r.Active_Elective_Course__c
FROM hed__Course_Offering_Schedule__c
WHERE Id = :courseOfferingScheduleId
];
system.debug('courseOfferingSchedules ------>'+ courseOfferingSchedules);

if(courseOfferingSchedules.isEmpty()){
return null;
}
hed__Course_Offering_Schedule__c courseOfferingSchedule = courseOfferingSchedules[0];
Boolean isElective =courseOfferingSchedules[0].hed__Course_Offering__r.Active_Elective_Course__c;
System.debug('iselective --->'+IsElective);

List<Facility_Request_Allocation__c> facilityReqAllocations = [
SELECT Facility_Request__r.Facility__c 
FROM Facility_Request_Allocation__c
WHERE Course_Offering_Schedule__r.hed__Time_Block__r.hed__End_Time__c = :courseOfferingSchedule.hed__Time_Block__r.hed__End_Time__c
AND Course_Offering_Schedule__r.hed__Time_Block__r.hed__Start_Time__c = :courseOfferingSchedule.hed__Time_Block__r.hed__Start_Time__c
AND Course_Offering_Schedule__r.hed__Time_Block__r.Monday__c = :courseOfferingSchedule.hed__Time_Block__r.Monday__c
AND Course_Offering_Schedule__r.hed__Time_Block__r.Tuesday__c = :courseOfferingSchedule.hed__Time_Block__r.Tuesday__c
AND Course_Offering_Schedule__r.hed__Time_Block__r.Wednesday__c = :courseOfferingSchedule.hed__Time_Block__r.Wednesday__c
AND Course_Offering_Schedule__r.hed__Time_Block__r.Thursday__c = :courseOfferingSchedule.hed__Time_Block__r.Thursday__c
AND Course_Offering_Schedule__r.hed__Time_Block__r.Friday__c = :courseOfferingSchedule.hed__Time_Block__r.Friday__c
AND Course_Offering_Schedule__r.hed__Time_Block__r.Saturday__c = :courseOfferingSchedule.hed__Time_Block__r.Saturday__c
AND Course_Offering_Schedule__r.hed__Time_Block__r.Sunday__c = :courseOfferingSchedule.hed__Time_Block__r.Sunday__c
AND Course_Offering_Schedule__r.hed__Time_Block__r.Break__c = :courseOfferingSchedule.hed__Time_Block__r.Break__c
AND Course_Offering_Schedule__r.Section__r.Active__c = TRUE
];
system.debug('facilityReqAllocations ---->'+ facilityReqAllocations);

Set<Id> facilityIds = new Set<Id>();

for(Facility_Request_Allocation__c facilityReqAllocation : facilityReqAllocations){
facilityIds.add(facilityReqAllocation.Facility_Request__r.Facility__c);
}
/*wrapper.facilityRequests =  [SELECT Id, Name , Facility__r.Display_Name__c
From Facility_Request__c 
WHERE Facility__c NOT IN:facilityIds
AND Semester__c=: courseOfferingSchedule.Section__c
];

wrapper.facilityRequests =  [SELECT Id, Name , Facility__r.Display_Name__c,ApprovalStatus__c 
From Facility_Request__c  
WHERE ApprovalStatus__c ='Approved' AND Facility__c NOT IN:facilityIds AND Facility_Type__c !='Event Venues'
];
system.debug('wrapper.facilityRequests ---->'+wrapper.facilityRequests);

System.debug('Wrapper before return ---->'+wrapper);
return wrapper;

}*/
    
    @AuraEnabled(cacheable = true)
    public static allocationDetailWrapper getAvailableFacilities(String courseOfferingScheduleId) {
        system.debug('courseOfferingScheduleId ---->' + courseOfferingScheduleId);
        allocationDetailWrapper wrapper = new allocationDetailWrapper();
        
        List<Facility_Request_Allocation__c> alreadyBookedFacility = [
            SELECT Id, Name, Facility_Request__r.Facility__r.Display_Name__c
            FROM Facility_Request_Allocation__c 
            WHERE Course_Offering_Schedule__c = :courseOfferingScheduleId
        ];
        system.debug('alreadyBookedFacility ----->' + alreadyBookedFacility);
        
        wrapper.isAlreadyBooked = alreadyBookedFacility.size() > 0;
        wrapper.alreadyBookedFacility = alreadyBookedFacility;
        
        System.debug('Wrapperrr ---->' + wrapper);
        
        List<hed__Course_Offering_Schedule__c> courseOfferingSchedules = [
            SELECT Section__c, 
            hed__Start_Time__c,
            hed__End_Time__c,
            hed__Monday__c,
            hed__Tuesday__c,hed__Wednesday__c,hed__Thursday__c,hed__Friday__c, hed__Saturday__c,hed__Sunday__c,
            hed__Time_Block__r.hed__End_Time__c,  
            hed__Time_Block__r.hed__Start_Time__c,
            hed__Time_Block__r.Monday__c,
            hed__Time_Block__r.Tuesday__c,
            hed__Time_Block__r.Wednesday__c,
            hed__Time_Block__r.Thursday__c,
            hed__Time_Block__r.Friday__c,
            hed__Time_Block__r.Saturday__c,
            hed__Time_Block__r.Sunday__c,
            hed__Time_Block__r.Break__c,
            hed__Course_Offering__r.Active__c,
            hed__Course_Offering__r.Category__c
            FROM hed__Course_Offering_Schedule__c
            WHERE Id = :courseOfferingScheduleId
        ];
        system.debug('courseOfferingSchedules ------>' + courseOfferingSchedules);
        
        if (courseOfferingSchedules.isEmpty()) {
            return null;
        }
        
        hed__Course_Offering_Schedule__c courseOfferingSchedule = courseOfferingSchedules[0];
        Boolean isElective = (courseOfferingSchedules[0].hed__Course_Offering__r.Category__c == 'Professional Elective' || courseOfferingSchedules[0].hed__Course_Offering__r.Category__c == 'Open Elective');
        System.debug('iselective --->' + isElective);
        
        List<Facility_Request_Allocation__c> facilityReqAllocations;
        if(!isElective){
         facilityReqAllocations = [
            SELECT Facility_Request__r.Facility__c 
            FROM Facility_Request_Allocation__c
            WHERE  ((Course_Offering_Schedule__r.hed__End_Time__c = :courseOfferingSchedule.hed__End_Time__c
            AND Course_Offering_Schedule__r.hed__Start_Time__c = :courseOfferingSchedule.hed__Start_Time__c)
            Or (Course_Offering_Schedule__r.hed__End_Time__c > :courseOfferingSchedule.hed__End_Time__c
            AND Course_Offering_Schedule__r.hed__Start_Time__c < :courseOfferingSchedule.hed__End_Time__c)
            Or (Course_Offering_Schedule__r.hed__End_Time__c > :courseOfferingSchedule.hed__Start_Time__c
            AND Course_Offering_Schedule__r.hed__Start_Time__c < :courseOfferingSchedule.hed__Start_Time__c))
            AND Course_Offering_Schedule__r.hed__Monday__c = :courseOfferingSchedule.hed__Monday__c
            AND Course_Offering_Schedule__r.hed__Tuesday__c = :courseOfferingSchedule.hed__Tuesday__c
            AND Course_Offering_Schedule__r.hed__Wednesday__c = :courseOfferingSchedule.hed__Wednesday__c
            AND Course_Offering_Schedule__r.hed__Thursday__c = :courseOfferingSchedule.hed__Thursday__c
            AND Course_Offering_Schedule__r.hed__Friday__c = :courseOfferingSchedule.hed__Friday__c
            AND Course_Offering_Schedule__r.hed__Saturday__c = :courseOfferingSchedule.hed__Saturday__c
            AND Course_Offering_Schedule__r.hed__Sunday__c = :courseOfferingSchedule.hed__Sunday__c
           // AND Course_Offering_Schedule__r.hed__Time_Block__r.Break__c = :courseOfferingSchedule.hed__Time_Block__r.Break__c
            AND Course_Offering_Schedule__r.Section__r.Active__c = TRUE
            AND Course_Offering_Schedule__r.hed__Course_Offering__r.Active__c = FALSE
        ];
        }
        system.debug('facilityReqAllocations ---->' + facilityReqAllocations);
        
        Set<Id> facilityIds = new Set<Id>();
        
        if(facilityReqAllocations != NULL){
        for (Facility_Request_Allocation__c facilityReqAllocation : facilityReqAllocations) {
            facilityIds.add(facilityReqAllocation.Facility_Request__r.Facility__c);
        }}
        
         /*wrapper.facilityRequests =  [SELECT Id, Name , Facility__r.Display_Name__c
                                     From Facility_Request__c 
                                     WHERE Facility__c NOT IN:facilityIds
                                     AND Semester__c=: courseOfferingSchedule.Section__c
                                     ];*/
            system.debug('facilityIds --->' + facilityIds);
        
          wrapper.facilityRequests = [
                SELECT Id, Name, Facility__r.Display_Name__c, ApprovalStatus__c 
                FROM Facility_Request__c  
                WHERE ApprovalStatus__c = 'Approved' AND Facility__c NOT IN :facilityIds AND Facility_Type__c != 'Event Venues'
            ];
        
        system.debug('wrapper.facilityRequests ---->' + wrapper.facilityRequests);
        System.debug('Wrapper before return ---->' + wrapper);
        
        return wrapper;
    }
    
    
 @AuraEnabled
public static void createFacilityRequestAllocation(String facilityRequestId, String courseOfferingScheduleId){
    // Query Facility Request to get Facility Id
    Facility_Request__c facilityRequest = [
        SELECT Facility__c 
        FROM Facility_Request__c 
        WHERE Id = :facilityRequestId
    ];
    
    if (facilityRequest != null) {
        // Create Facility Request Allocation
        Facility_Request_Allocation__c facilityRequestAllocation = new Facility_Request_Allocation__c();
        facilityRequestAllocation.Facility_Request__c = facilityRequestId;
        facilityRequestAllocation.Course_Offering_Schedule__c = courseOfferingScheduleId;
        insert facilityRequestAllocation;
        
        // Update Course Offering Schedule with Facility Id
        hed__Course_Offering_Schedule__c courseOfferingSchedule = new hed__Course_Offering_Schedule__c(
            Id = courseOfferingScheduleId,
            hed__Facility__c = facilityRequest.Facility__c
        );
        update courseOfferingSchedule;
    } else {
        // Handle error or appropriate response if facilityRequest is null
        throw new AuraHandledException('Facility Request not found');
    }
}

    
    public class allocationDetailWrapper{
        @AuraEnabled
        public Boolean isAlreadyBooked;
        @AuraEnabled
        public List<Facility_Request__c> facilityRequests;
        @AuraEnabled
        public List<Facility_Request_Allocation__c> alreadyBookedFacility;
    }
    
    @AuraEnabled(cacheable=true)
    public static hed__Course_Offering_Schedule__c getCourseOfferingRecord(Id recordId) {
        return [SELECT hed__Course_Offering__c,Id, hed__Course_Offering__r.Active_Elective_Course__c FROM hed__Course_Offering_Schedule__c WHERE Id = :recordId];
    }
    
    public class semesterAndFacilitiesWrapper{
        @AuraEnabled
        public List<hed__Term__c> semesters;
        @AuraEnabled
        public List<hed__Facility__c> facilities;
        @AuraEnabled
        public List<Facility_Request__c> alreadyBookedFacilites;
    }
    
    public class JSON2Apex {
        
        public String accountId;
        public String semesterId;
        public String facilityId;
        
        
        public List<JSON2Apex> parse(String json) {
            return (List<JSON2Apex>) System.JSON.deserialize(json, List<JSON2Apex>.class);
        }
    }
    
}