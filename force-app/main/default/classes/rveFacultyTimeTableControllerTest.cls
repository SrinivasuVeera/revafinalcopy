@isTest
public class rveFacultyTimeTableControllerTest {

    @TestSetup
    static void makeData() {
        Profile professorProfile = [SELECT Id FROM Profile WHERE Name = 'Examination Vertical Head' LIMIT 1];

        // Create test users with 'Professor' profile
        User prof1 = new User(
            Alias = 'prof1',
            Email = 'prof1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Professor1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = professorProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'prof1@test.com'
        );
        insert prof1;
		
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account accparent = new Account(Name = 'TestAccParent', Vertical_Head__c = prof1.Id,RecordTypeid = AcaRecId);
        insert accparent;        
		 
        Account acc = new Account(Name = 'TestAcc', parentId = accparent.Id);
        insert acc;

        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c(Name = 'TestIAProgramBatch', hed__Account__c = acc.Id);
        insert ProgramBatch;

        hed__Term__c Semester = new hed__Term__c(
            Name = 'TestSemester',
            hed__Account__c = acc.Id,
            hed__Start_Date__c = System.today(),
            hed__End_Date__c = System.today(),
            Term_Number__c = 1,
            Program_Batch__c = ProgramBatch.Id
        );
        insert Semester;

        RecordType ExamNotificationRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Rve_Exam_Notification__c' AND DeveloperName = 'hed_IA_Notification'];

        Rve_Exam_Notification__c TestNotification = new Rve_Exam_Notification__c(
            Name = 'TestExamNotification',
            rve_Exam_Start_Date__c = System.Today(),
            Rve_Publish__c = true,
            hed_Program_Batch__c = ProgramBatch.Id,
            hed_IA_Type__c = 'IA 1',
            RecordTypeId = ExamNotificationRecordType.Id
        );
        insert TestNotification;
        
        
        hed__Course__c Course = MSTR_TestDataFactory.CreateCourse('Test Course',accparent.id);
        Course.Category__c = 'Hardcore Course';
        Course.HardCore_Sub_Type__c = 'Theory';
        Course.Offered_By_School__c = accparent.Id;
        Course.Credit_Hours__c = 04.00;
        Course.Credits__c = 04.00;
        Course.Maximum_External_Marks__c = 50;
        Course.Total_Maximum_Marks_IA_External__c = 60;
        Course.No_of_IA_s__c = '1';
        Course.L_T_P__c='2:1:0';
        insert Course;

        hed_Time_Table_Line_Item__c TimeTableItem = new hed_Time_Table_Line_Item__c(
            Name = 'TestTimeTable',
            Reva_Exam_Notification__c = TestNotification.Id,
            hed_Date__c = System.today(),
            hed_Start_Time__c = Time.newInstance(11, 0, 0, 0),
            hed_End_Time__c = Time.newInstance(12, 0, 0, 0),
            Course__c = Course.Id
        );
        insert TimeTableItem;
    }

    @isTest
    public static void testGetExamScheduleItems() {
        Test.startTest();
        List<hed_Time_Table_Line_Item__c> result = rveFacultyTimeTableController.getExamScheduleItems();
        Test.stopTest();
        System.assertNotEquals(0, result.size(), 'Exam schedule items should not be empty');
    }

    @isTest
    public static void testGetIAExamTimeTable() {
        Test.startTest();
        List<hed_Time_Table_Line_Item__c> result = rveFacultyTimeTableController.getIAExamTimeTable();
        Test.stopTest();
    }

    @isTest
    public static void testSearchProgramBatch() {
        hed__Program_Plan__c programBatch = [SELECT Id, Name FROM hed__Program_Plan__c WHERE Name = 'TestIAProgramBatch' LIMIT 1];
        Test.startTest();
        List<hed__Program_Plan__c> result = rveFacultyTimeTableController.searchProgramBatch(programBatch.Name);
        Test.stopTest();
    }

    @isTest
    public static void testGetActiveSemester() {
        hed__Program_Plan__c programBatch = [SELECT Id, Name FROM hed__Program_Plan__c WHERE Name = 'TestIAProgramBatch' LIMIT 1];
        Test.startTest();
        List<hed__Term__c> result = rveFacultyTimeTableController.getActiveSemester(programBatch.Id);
        Test.stopTest();
        System.assertNotEquals(0, result.size(), 'Active semester search results should not be empty');
    }

    @isTest
    public static void testGetCourses() {
        hed__Term__c Semester = [SELECT Id FROM hed__Term__c LIMIT 1];
        Test.startTest();
        List<hed__Course_Offering__c> result = rveFacultyTimeTableController.getCourses(Semester.Id);
        Test.stopTest();
    }

    @isTest
    public static void testUpdateLineItem() {
        hed_Time_Table_Line_Item__c TimeTable = [SELECT Id FROM hed_Time_Table_Line_Item__c LIMIT 1];
        String JsonString = '[{"Id":"'+TimeTable.Id+'","StartTime":"12:45:00 PM","EndTime":"2:15:00 PM","LineItemDate":"2024-06-17"}]';
        Test.startTest();
        rveFacultyTimeTableController.updategetExamScheduleItems(JsonString);
        Test.stopTest();
        hed_Time_Table_Line_Item__c updatedItem = [SELECT hed_Start_Time__c, hed_End_Time__c, hed_Date__c FROM hed_Time_Table_Line_Item__c WHERE Id = :TimeTable.Id];
       
    }

    @isTest
    public static void testIATimeTableCreation() {
        hed__Term__c Semester = [SELECT Id FROM hed__Term__c LIMIT 1];
        hed__Program_Plan__c programBatch = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        String timeTableData = '[{"CourseId":"a0G1l000000pGDM","CourseName":"Test Course","ExamDate":"2024-06-17","StartTime":"12:45:00","EndTime":"2:15:00"}]';
        Test.startTest();
        String result = rveFacultyTimeTableController.IATimeTableCreation('TestNotification', Semester.Id, programBatch.Id, timeTableData, 'IA 1');
        Test.stopTest();
    }

    @isTest
    public static void testGetFormattedTime() {
        String timeString = '01:00:00 PM';
        Test.startTest();
        Time result = rveFacultyTimeTableController.getformattedtime(timeString);
        Test.stopTest();
    }
    @isTest
    Public static void testsemesterdata(){
        hed__Term__c semesterId = [SELECT Id FROM hed__Term__c LIMIT 1];
        Test.startTest();
        rveFacultyTimeTableController.getSemesterWithIADates(semesterId.Id);
        Test.stopTest();
    }
}