@isTest
public class rve_InvigilatorAttendenceControllerTest {
    
    @testSetup
    static void setup() {
        // Create test data
        
        // Create a User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standardjehiuereibuser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='Asia/Kolkata', UserName='standarduswebvvvvber@testorg.com');
        
        insert u;
        
        // Create a rve_Exam_Time__c custom setting record
        rve_Exam_Time__c examTimeSetting = new rve_Exam_Time__c();
        examTimeSetting.rve_Exam_End_Time_Hours__c = 2;
        insert examTimeSetting;
        
        // Create a Contact
        Contact c = new Contact(LastName = 'Test Contact', Email = 'testcontact@test.com', SRN_Number__c = 'SRN001', Active__c = true);
        insert c;
        
        // Create test data for profiles
        Profile professorProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        
        // Create test users with 'Professor' profile
        User prof1 = new User(
            Alias = 'prof1',
            Email = 'prof1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Professor1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = professorProfile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'prof1@test.com'
        );
        insert prof1;
        
        User prof2 = new User(
            Alias = 'prof2',
            Email = 'prof2@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Professor2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = professorProfile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'prof2@test.com'
        );
        insert prof2;
        
        // Create test School and Parent School
        Account parentSchool = new Account(Name = 'Parent School');
        insert parentSchool;
        
        Account school = new Account(Name = 'School', ParentId = parentSchool.Id);
        insert school;
        
         hed__Facility__c Facility = new hed__Facility__c(
            name = 'Test Facility',
            hed__Capacity__c = 50,
            Facility_Booked__c = false,
            Room_Name__c = 'TESLA LAB',
            Room__c = '301',
            Floor__c = '1st floor',
            Block__c = 'C.V. Raman Block',
            IA_Type__c = 'IA 1',
            hed__Account__c = school.Id // Replace with a valid Account Id
        );
        insert Facility;
        
          DateTime currentTimestamp = System.now();
        
        // Extract the time component
        Time currentTimeOnly = Time.newInstance(
            currentTimestamp.hour(), 
            currentTimestamp.minute(), 
            0,0
        );
        
        // Output the current time
        System.debug('Current time>test: ' + currentTimeOnly);
        
        // Subtract 30 minutes from the current time
        Time startTime = currentTimeOnly;
        
        Time EndTime = currentTimeOnly;
        
        // Create test Room Allotments
      IA_Seating_Room_Allotment__c SeatingRoom = new IA_Seating_Room_Allotment__c(
            Name = facility.Room__c,
            Facility_Type__c = facility.Id,
            Capacity__c = facility.hed__Capacity__c,
            IA_Type__c = facility.IA_Type__c,
            School__c = school.Id,
            Room__c = facility.Room__c,
            Active__c = true,
            rve_Date_of_Exam__c = Date.today(),
            rveShift__c = 'Morning',
            Exam_Time__c = StartTime,
            End_Time__c = EndTime,
            Students__c = 'SA001,SA002',
         //   InEligible_SRN__c = 'SA003,SA004',
         //   Course_Name__c = 'Electronic Circuit',
          
            Total_Students__c = 4
        ); 
        
        insert seatingroom;
        
        IA_Seating_Room_Allotment__c room2 = new IA_Seating_Room_Allotment__c(
            Name = 'Room 2',
            Room__c = 'R2',
            Active__c = true,
            rve_Date_of_Exam__c = Date.today(),
            School__c = school.Id
        );
        insert room2;
        
        // Create test Invigilator Assignments
        rve_Invigilator_Assignment__c assignment1 = new rve_Invigilator_Assignment__c(
            Name = '301',
            rve_Room_Allotment__c = seatingroom.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Professor__c = prof1.Id,
            rve_Exam_End_Time__c  = EndTime.addHours(2),
            rve_Exam_Time__c  = StartTime.addMinutes(-30),
            rve_Attendance_Submitted__c = false
        );
        insert assignment1;
        
        // Create a Program Batch
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name = 'Batch 1');
        insert programBatch;
        
        // Create a related Exam Notification
        Rve_Exam_Notification__c examNotification = new Rve_Exam_Notification__c();
        examNotification.Name = 'Notification 1';
       // examNotification.rve_Active__c = true;
        examNotification.rve_Exam_Start_Date__c = Date.Today();
        examNotification.Rve_Publish__c = true;
        examNotification.hed_Program_Batch__c = programBatch.Id;
        insert examNotification;
        
        // Create a related Time Table Line Item
        hed_Time_Table_Line_Item__c timeTableLineItem = new hed_Time_Table_Line_Item__c();
        timeTableLineItem.Name = 'Test Course Offering';
        timeTableLineItem.hed_Date__c = Date.today();
        timeTableLineItem.Reva_Exam_Notification__c = examNotification.Id;
        insert timeTableLineItem;
        
          Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            SRN_Number__c = 'SA001',
            Program_Batch__c = ProgramBatch.Id,
            Active__c=true
        );
        insert testContact;
        
        // Create a test record
        // Ensure the field names match your actual object 'HallTicketQR__c'
        HallTicketQR__c testTicket = new HallTicketQR__c(
            SRN__c = 'SRN12345',
            Attendance_Type__c = true,
            Room__c = '101',
            Date__c = Date.newInstance(2026, 4, 6),
            Start_time__c = Time.newInstance(14, 0, 0, 0), // 2:00 PM
            End_time__c = Time.newInstance(15, 30, 0, 0)   // 3:30 PM
        );
        insert testTicket;
    }
    
    @isTest
    static void testGetRoomNumbers() {
        Test.startTest();
        User user = [SELECT Id FROM User WHERE Email = 'prof1@test.com' LIMIT 1];
       list<rve_Invigilator_Assignment__c>Invigilator = [Select Id,name,rve_Professor__c,rve_Date__c from rve_Invigilator_Assignment__c where rve_Professor__r.Id = :user.Id];

        System.runAs(user) {
            rve_InvigilatorAttendenceController.getRoomNumbers(Date.today());
            //System.assert(result.size() == 1, 'Expected one room number assignment.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetRoomDetails() {
        Test.startTest();
        // Get the current timestamp
        DateTime currentTimestamp = System.now();
        
        // Extract the time component
        Time currentTimeOnly = Time.newInstance(
            currentTimestamp.hour(), 
            currentTimestamp.minute(), 
            currentTimestamp.second(),0
        );
        
        // Output the current time
        System.debug('Current time>test: ' + currentTimeOnly);
        
        // Subtract 30 minutes from the current time
        Time startTime = currentTimeOnly;
        
        // Extract hours and minutes
        Integer hours = startTime.hour();
        Integer minutes = startTime.minute();
        Integer seconds = startTime.second();
        
        // Determine the meridiem (AM or PM)
        String meridiem = 'AM';
        if (hours >= 12) {
            meridiem = 'PM';
            if (hours > 12) {
                hours -= 12;
            }
        }
        if (hours == 0) {
            hours = 12;
        }
        system.debug('start time test>'+startTime);
        
        // Construct the formatted start time string
        String formattedStartTimeString = String.valueOf(hours).leftPad(2, '0') + ':' + String.valueOf(minutes).leftPad(2, '0') +':0'+ ' ' + meridiem;
        
		system.debug('formattedStartTimeString test>'+formattedStartTimeString);
        // Add 2 hours to the current time
        Time endTime = currentTimeOnly;
        
        // Extract hours and minutes
        Integer hours1 = endTime.hour();
        Integer minutes1 = endTime.minute();
        
        // Determine the meridiem (AM or PM)
        String meridiem1 = 'AM';
        if (hours1 >= 12) {
            meridiem1 = 'PM';
            if (hours1 > 12) {
                hours1 -= 12;
            }
        }
        if (hours1 == 0) {
            hours1= 12;
        }
        system.debug('end time test>'+endTime);
        
        // Construct the formatted start time string
        String formattedEndTimeString = String.valueOf(hours1).leftPad(2, '0') + ':' + String.valueOf(minutes1).leftPad(2, '0') +':0'+ ' ' + meridiem1;
        
        system.debug('formattedEndTimeString test>'+formattedEndTimeString);
        
        User user = [SELECT Id FROM User WHERE Email = 'prof1@test.com' LIMIT 1];
       list<rve_Invigilator_Assignment__c>Invigilator = [Select Id,name,rve_Professor__c,rve_Date__c from rve_Invigilator_Assignment__c where rve_Professor__r.Id = :user.Id];
        System.runAs(user) {
            Date examDate = Date.today();
            String shift = 'Morning';
            String roomName = '301';
            
            List<Contact> result = rve_InvigilatorAttendenceController.getRoomDetails(examDate, shift, roomName, formattedStartTimeString, formattedEndTimeString);
            //System.assert(result.size() > 0, 'Expected one contact for the room details.');
        }
        Test.stopTest();
    }

    
    @isTest
    static void testGetCustomSettings() {
        rve_Exam_Time__c ExamTime = [Select Id from rve_Exam_Time__c where rve_Exam_End_Time_Hours__c=2 limit 1];
        Test.startTest();
        Decimal result = rve_InvigilatorAttendenceController.getCustomSettings();
        //System.assert(result == 2, 'Expected custom setting value of 2.');
        Test.stopTest();
    }
    
     @isTest
    static void testgetProgramBatchTimetableMap() {
        Test.startTest();
        // Get the current timestamp
        DateTime currentTimestamp = System.now();
        
        // Extract the time component
        Time currentTimeOnly = Time.newInstance(
            currentTimestamp.hour(), 
            currentTimestamp.minute(), 
            currentTimestamp.second(),0
        );
        
        // Output the current time
        System.debug('Current time>test: ' + currentTimeOnly);
        
        // Subtract 30 minutes from the current time
        Time startTime = currentTimeOnly;
        
        // Extract hours and minutes
        Integer hours = startTime.hour();
        Integer minutes = startTime.minute();
        Integer seconds = startTime.second();
        
        // Determine the meridiem (AM or PM)
        String meridiem = 'AM';
        if (hours >= 12) {
            meridiem = 'PM';
            if (hours > 12) {
                hours -= 12;
            }
        }
        if (hours == 0) {
            hours = 12;
        }
        system.debug('start time test>'+startTime);
        
        // Construct the formatted start time string
        String formattedStartTimeString = String.valueOf(hours).leftPad(2, '0') + ':' + String.valueOf(minutes).leftPad(2, '0') +':0'+ ' ' + meridiem;
        
		system.debug('formattedStartTimeString test>'+formattedStartTimeString);
        // Add 2 hours to the current time
        Time endTime = currentTimeOnly;
        
        // Extract hours and minutes
        Integer hours1 = endTime.hour();
        Integer minutes1 = endTime.minute();
        
        // Determine the meridiem (AM or PM)
        String meridiem1 = 'AM';
        if (hours1 >= 12) {
            meridiem1 = 'PM';
            if (hours1 > 12) {
                hours1 -= 12;
            }
        }
        if (hours1 == 0) {
            hours1= 12;
        }
        system.debug('end time test>'+endTime);
        
        // Construct the formatted start time string
        String formattedEndTimeString = String.valueOf(hours1).leftPad(2, '0') + ':' + String.valueOf(minutes1).leftPad(2, '0') +':0'+ ' ' + meridiem1;
        
        system.debug('formattedEndTimeString test>'+formattedEndTimeString);
        
        RecordType Rt = [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType WHERE Name = 'University Department'];

        Account acc = new Account(
        Name = 'Test Acc',RecordTypeId = Rt.Id);
        insert acc;
        
        hed__Course__c Course = new hed__Course__c(
        hed__Account__c = acc.Id,
        Name = 'Test Course',
        hed__Course_ID__c = '123456',
        HardCore_Sub_Type__c = 'Theory',
        Maximum_Internal_Marks_Logisys__c = 0,
        Credits__c=0, 
        Offered_By_School__c=acc.id,
        Credit_Hours__c=0,
        L_T_P__c='0', 
        Maximum_External_Marks__c=0,
      //  Maximum_Internal_Marks__c=0,
        Total_Maximum_Marks_IA_External__c=0,
        SEE_Conducted_Marks__c = 100,
            No_of_IA_s__c = '0'
        );
        insert Course;
        
        hed__Term__c Semester = new hed__Term__c(
         Name = 'Test Semester',
         hed__Account__c = acc.Id
        );
        insert Semester;
        
        hed__Course_Offering__c CourseOffering = new hed__Course_Offering__c(
        hed__Course__c = Course.Id,
        Name = 'Test Course Offering',
        hed__Term__c = Semester.Id
        
        );
        insert CourseOffering;
        
        Contact con = [Select Id from contact where lastname = 'Contact'];
        
        hed__Course_Enrollment__c CourseConnection = new hed__Course_Enrollment__c(
        hed__Contact__c = con.Id,
        hed__Course_Offering__c = CourseOffering.Id,
        External_Id__c='0',
        Semester_ID__c='0', 
        Logisys_External_Id__c='0'
        );
        
        insert CourseConnection;
        
        User user = [SELECT Id FROM User WHERE Email = 'prof1@test.com' LIMIT 1];
                list<contact> clist = [select id, name from contact where LastName = 'Contact'];

        list<IA_Seating_Room_Allotment__c>seating =[select id ,name from IA_Seating_Room_Allotment__c where name = 'Room 2'];
        list<hed_Time_Table_Line_Item__c> lineitems = [select id, name from hed_Time_Table_Line_Item__c where name = 'Test Course Offering'];
       list<rve_Invigilator_Assignment__c>Invigilator = [Select Id,name,rve_Professor__c,rve_Date__c from rve_Invigilator_Assignment__c where rve_Professor__r.Id = :user.Id];
        System.runAs(user) {
            Date examDate = Date.today();
            String shift = 'Morning';
            String roomName = '301';
            
            rve_InvigilatorAttendenceController.getProgramBatchTimetableMap(examDate, shift, roomName, formattedStartTimeString, formattedEndTimeString);
            //System.assert(result.size() > 0, 'Expected one contact for the room details.');
        }
        Test.stopTest();
    }
    
    @isTest
    Static void InsertAttendanceEvent(){
        
        Contact con = [Select Id,name from contact where lastname = 'Contact'];
        hed__Attendance_Event__c AttendanceEvent = new hed__Attendance_Event__c(
        hed__Contact__c = con.Id
        
        );
        rve_InvigilatorAttendenceController.insertAttendenceEvent(new list<hed__Attendance_Event__c>{AttendanceEvent});
        
    }
    
     @isTest
    static void testcontactdetails() {
        Test.startTest();
        // Get the current timestamp
        DateTime currentTimestamp = System.now();
        
        // Extract the time component
        Time currentTimeOnly = Time.newInstance(
            currentTimestamp.hour(), 
            currentTimestamp.minute(), 
            currentTimestamp.second(),0
        );
        
        // Output the current time
        System.debug('Current time>test: ' + currentTimeOnly);
        
        // Subtract 30 minutes from the current time
        Time startTime = currentTimeOnly;
        
        // Extract hours and minutes
        Integer hours = startTime.hour();
        Integer minutes = startTime.minute();
        Integer seconds = startTime.second();
        
        // Determine the meridiem (AM or PM)
        String meridiem = 'AM';
        if (hours >= 12) {
            meridiem = 'PM';
            if (hours > 12) {
                hours -= 12;
            }
        }
        if (hours == 0) {
            hours = 12;
        }
        system.debug('start time test>'+startTime);
        
        // Construct the formatted start time string
        String formattedStartTimeString = String.valueOf(hours).leftPad(2, '0') + ':' + String.valueOf(minutes).leftPad(2, '0') +':0'+ ' ' + meridiem;
        
system.debug('formattedStartTimeString test>'+formattedStartTimeString);
        // Add 2 hours to the current time
        Time endTime = currentTimeOnly;
        
        // Extract hours and minutes
        Integer hours1 = endTime.hour();
        Integer minutes1 = endTime.minute();
        
        // Determine the meridiem (AM or PM)
        String meridiem1 = 'AM';
        if (hours1 >= 12) {
            meridiem1 = 'PM';
            if (hours1 > 12) {
                hours1 -= 12;
            }
        }
        if (hours1 == 0) {
            hours1= 12;
        }
        system.debug('end time test>'+endTime);
        
        // Construct the formatted start time string
        String formattedEndTimeString = String.valueOf(hours1).leftPad(2, '0') + ':' + String.valueOf(minutes1).leftPad(2, '0') +':0'+ ' ' + meridiem1;
        
        system.debug('formattedEndTimeString test>'+formattedEndTimeString);
        
           Profile professorProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        
        // Create test users with 'Professor' profile
        User prof1 = new User(
            Alias = 'prof1',
            Email = 'prof1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Professor1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = professorProfile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'prof78@test.com'
        );
        insert prof1;
        
        Account accparent = new Account(Name='TestAccParent');
        insert accparent;
        
        Account acc = new Account(Name='TestAcc',parentId=accparent.Id);
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
          hed__Facility__c Facility = new hed__Facility__c(
            name = 'Test Facility',
            hed__Capacity__c = 50,
            Facility_Booked__c = false,
            Room_Name__c = 'TESLA LAB',
            Room__c = '301',
            Floor__c = '1st floor',
            Block__c = 'C.V. Raman Block',
            IA_Type__c = 'IA 1',
            hed__Account__c = acc.Id // Replace with a valid Account Id
        );
        insert Facility;
        
      IA_Seating_Room_Allotment__c SeatingRoom = new IA_Seating_Room_Allotment__c(
            Name = facility.Room__c,
            Facility_Type__c = facility.Id,
            Capacity__c = facility.hed__Capacity__c,
            IA_Type__c = facility.IA_Type__c,
            School__c = acc.Id,
            Room__c = facility.Room__c,
            Active__c = true,
            rve_Date_of_Exam__c = Date.today(),
            rveShift__c = 'Morning',
            Exam_Time__c = StartTime,
            End_Time__c = EndTime,
            Alloted_Students__c = 'SA001,SA002',
            InEligible_SRN__c = 'SA003,Sa004',
            Course_Name__c = 'Electronic Circuit',
          
            Total_Students__c = 4
        ); 
        
        insert seatingroom;
        
         rve_Invigilator_Assignment__c assignment1 = new rve_Invigilator_Assignment__c(
            Name = '301',
            rve_Room_Allotment__c = seatingroom.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Professor__c = prof1.Id,
            rve_Exam_End_Time__c  = EndTime,
            rve_Exam_Time__c  = StartTime,
            rve_Attendance_Submitted__c = false
        );
        insert assignment1;
        
        
            Date examDate = Date.today();
            String shift = 'Morning';
            String roomName = '301';
            
            rve_InvigilatorAttendenceController.contactdetails(examDate, shift, roomName, startTime, EndTime,prof1.Id);
            //System.assert(result.size() > 0, 'Expected one contact for the room details.');
        
        Test.stopTest();
    }
    
    @isTest
    static void timeconvertion(){
        rve_InvigilatorAttendenceController.timeconvertion('11:00:00 AM');
    }
    
    @isTest
    static void updateAttendanceCheckbox(){
        rve_Invigilator_Assignment__c InvigilatorAssignment = [Select Id from rve_Invigilator_Assignment__c where Name = '301'];
        rve_InvigilatorAttendenceController.updateAttendanceCheckbox(InvigilatorAssignment.Id);
    }
    
    @isTest
    static void testGetRoomQRAttendance() {
        Test.startTest();
        // Get the current timestamp
        DateTime currentTimestamp = System.now();
        
        // Extract the time component
        Time currentTimeOnly = Time.newInstance(
            currentTimestamp.hour(), 
            currentTimestamp.minute(), 
            currentTimestamp.second(),0
        );
        
        // Output the current time
        System.debug('Current time>test: ' + currentTimeOnly);
        
        // Subtract 30 minutes from the current time
        Time startTime = currentTimeOnly;
        
        // Extract hours and minutes
        Integer hours = startTime.hour();
        Integer minutes = startTime.minute();
        Integer seconds = startTime.second();
        
        // Determine the meridiem (AM or PM)
        String meridiem = 'AM';
        if (hours >= 12) {
            meridiem = 'PM';
            if (hours > 12) {
                hours -= 12;
            }
        }
        if (hours == 0) {
            hours = 12;
        }
        system.debug('start time test>'+startTime);
        
        // Construct the formatted start time string
        String formattedStartTimeString = String.valueOf(hours).leftPad(2, '0') + ':' + String.valueOf(minutes).leftPad(2, '0') +':0'+ ' ' + meridiem;
        
		system.debug('formattedStartTimeString test>'+formattedStartTimeString);
        // Add 2 hours to the current time
        Time endTime = currentTimeOnly;
        
        // Extract hours and minutes
        Integer hours1 = endTime.hour();
        Integer minutes1 = endTime.minute();
        
        // Determine the meridiem (AM or PM)
        String meridiem1 = 'AM';
        if (hours1 >= 12) {
            meridiem1 = 'PM';
            if (hours1 > 12) {
                hours1 -= 12;
            }
        }
        if (hours1 == 0) {
            hours1= 12;
        }
        system.debug('end time test>'+endTime);
        
        // Construct the formatted start time string
        String formattedEndTimeString = String.valueOf(hours1).leftPad(2, '0') + ':' + String.valueOf(minutes1).leftPad(2, '0') +':0'+ ' ' + meridiem1;
        
        system.debug('formattedEndTimeString test>'+formattedEndTimeString);
        
        User user = [SELECT Id FROM User WHERE Email = 'prof1@test.com' LIMIT 1];
       list<rve_Invigilator_Assignment__c>Invigilator = [Select Id,name,rve_Professor__c,rve_Date__c from rve_Invigilator_Assignment__c where rve_Professor__r.Id = :user.Id];
        System.runAs(user) {
            Date examDate = Date.today();
            String shift = 'Morning';
            String roomName = '301';
            
            Map<String, Boolean> result = rve_InvigilatorAttendenceController.getRoomQRAttendance(examDate, roomName, formattedStartTimeString, formattedEndTimeString);
            //System.assert(result.size() > 0, 'Expected one contact for the room details.');
        }
        Test.stopTest();
    }
    
   
    @isTest
    static void testGetRoomQRAttendanceDetails_Success() {
        // 1. Prepare Date and Room
        Date examDate = Date.newInstance(2026, 4, 6);
        String room = '101';
        
        // 2. Prepare Strings (Matches the new Apex signature)
        String startStr = '14:00'; 
        String endStr = '15:30';
    
        Test.startTest();
        // 3. Call with Strings
        Map<String, Boolean> result = rve_InvigilatorAttendenceController.getRoomQRAttendanceDetails(
            examDate, 
            room, 
            startStr, 
            endStr
        );
        Test.stopTest();
    
        // Assertions
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
    }
    @isTest
    static void testGetRoomQRAttendanceDetails_NoResults() {
        // Query for a room that doesn't exist
        Date examDate = Date.newInstance(2026, 4, 6);
        String startStr = '10:00'; 
        String endStr = '11:30';

        Test.startTest();
        Map<String, Boolean> result = rve_InvigilatorAttendenceController.getRoomQRAttendanceDetails(
            examDate, '999', startStr, endStr
        );
        Test.stopTest();

        // Assertions
        System.assertEquals(0, result.size(), 'Map should be empty for non-existent room');
    }
    
}