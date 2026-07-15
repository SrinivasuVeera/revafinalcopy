@isTest
public class ASM_StdResultListViewTest {
    
    @testSetup
    static void setupData() {
        // Create a Contact for the Student
        Account acc = new Account(Name='TestAcc');
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        // Create Semester (hed__Term__c)
        hed__Term__c semester = new hed__Term__c();
        semester.Name = '3rd Semester';
        semester.Program_Batch__c =ProgramBatch.id;
        semester.hed__Account__c = acc.Id;
        semester.hed__Start_Date__c = Date.today().addDays(-30);
        semester.hed__End_Date__c = Date.today().addDays(30);        
        insert semester;
        system.debug('test semester>>'+semester);
        
        Contact studentContact = new Contact(
            LastName = 'Test Student',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student'].Id,
            Active_Semester__c = semester.id
        );
        insert studentContact;
        
        // Create a Contact for the Parent
        Contact parentContact = new Contact(
            LastName = 'Test Parent',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Parent'].Id,
            ReportsToId = studentContact.Id
        );
        insert parentContact;
        
        // Create a User associated with the Student Contact
        User studentUser = new User(
            LastName = 'test@123',
            Username = 'teststudent@test.com',
            Email = 'teststudent@test.com',
            Alias = 'tstudent',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile'][0].Id,
            LanguageLocaleKey = 'en_US',
            ContactId = studentContact.Id
        );
        insert studentUser;
        
        // Create a User associated with the Parent Contact
        User parentUser = new User(
            LastName = 'testparent',
            Username = 'testparent@test.com',
            Email = 'testparent@test.com',
            Alias = 'tparent',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile'][0].Id,
            LanguageLocaleKey = 'en_US',
            ContactId = parentContact.Id
        );
        insert parentUser;
        
        
        hed__Course__c objCourse = new hed__Course__c(
            Name = 'Course123 ',
            hed__Account__c = acc.id,
            Category__c = 'Mandatory Course',
            hed__Course_ID__c = 'CRS00');
        insert objCourse;
        
        hed__Course_Offering__c objCourseOff = new hed__Course_Offering__c(
            Name = 'courseOffName',
            hed__Course__c = objCourse.id,
            hed__Term__c = semester.id );
        insert objCourseOff;
        
        
        hed__Course_Enrollment__c obj_Cour_Enroll = new hed__Course_Enrollment__c(
            hed__Contact__c = studentContact.Id,
            hed__Course_Offering__c = objCourseOff.id);
        insert obj_Cour_Enroll;
        
        // Create hed__Term_Grade__c records
        hed__Term_Grade__c termGrade1 = new hed__Term_Grade__c(
            hed__Contact__c = studentContact.Id,
            Recent_Result_Updated_Date__c = Date.today(),
            hed__Term__c = semester.Id,
            Total_Maximum_Marks_Semester__c = 100,
            Total_Secured_Marks_Semester__c = 80,
            Examination_Month_Year__c = 'May 2024',
            hed__Course_Connection__c = obj_Cour_Enroll.Id
            
        );
        insert termGrade1;
        
        hed__Term_Grade__c termGrade2 = new hed__Term_Grade__c(
            hed__Contact__c = studentContact.Id,
            Recent_Result_Updated_Date__c = Date.today(),
            hed__Term__c = semester.Id,
            Total_Maximum_Marks_Semester__c = 100,
            Total_Secured_Marks_Semester__c = 90,
            Examination_Month_Year__c = 'December 2024',
            hed__Course_Connection__c = obj_Cour_Enroll.Id
        );
        insert termGrade2;
    }
    
    @isTest
    static void testFetchData() {
        // Test fetchData method as Student
        User studentUser = [SELECT Id FROM User WHERE Alias = 'tstudent' LIMIT 1];
        System.runAs(studentUser) {
            Test.startTest();
            List<hed__Term_Grade__c> result = ASM_StdResultListView.fetchData();
            Test.stopTest();
            
            System.assertNotEquals(null, result);
          //  System.assertEquals(2, result.size());
        }
        
        
    }
    
    @isTest
    static void testFetchDataparent() {
        
        // Test fetchData method as Parent
        User parentUser = [SELECT Id FROM User WHERE Alias = 'tparent' LIMIT 1];
        System.runAs(parentUser) {
            Test.startTest();
            List<hed__Term_Grade__c> result = ASM_StdResultListView.fetchData();
            Test.stopTest();
            
            System.assertNotEquals(null, result);
         //   System.assertEquals(2, result.size());
        }
    }
    
    

}