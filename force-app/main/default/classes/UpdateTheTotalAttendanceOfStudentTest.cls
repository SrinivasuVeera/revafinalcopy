/**
* @File Name : UpdateTheTotalAttendanceOfStudentTest.cls
* @Description : 
* @Author : Mahesh Gundaboina
* @Last Modified By :
* @Last Modified On : August 27, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 23, 2024 |   | Initial Version
**/
@IsTest
public class UpdateTheTotalAttendanceOfStudentTest {
    @TestSetup
    static void setupTestData() {
        // Create parent Term with Active set to true
        Account accparent = new Account(Name='TestAccParent');
        insert accparent;
        
        Account acc = new Account(Name='TestAcc',parentId=accparent.Id);
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        hed__Term__c term = new hed__Term__c(
            Name = 'Fall 2024',
            Program_Batch__c = ProgramBatch.Id,
            hed__Start_Date__c = Date.today().addMonths(-1),
            hed__End_Date__c = Date.today().addMonths(5),
            IA_1_Start_date__c = Date.today().addMonths(1),
            Exam_Start_Date__c = Date.today().addMonths(2),
            IA_1_End_date__c = Date.today().addMonths(3),
            IA_2_Start_date__c = Date.today().addMonths(4),
            IA_2_End_date__c = Date.today().addMonths(5),
            hed__Account__c = acc.Id
        );
        insert term;
        
        // Create test Contacts
        Contact contact1 = new Contact(LastName = 'Test Contact 1');
        Contact contact2 = new Contact(LastName = 'Test Contact 2');
        insert new List<Contact>{ contact1, contact2 };
            
            // Create hed__Course_Enrollment__c records with reference to Sections
            hed__Course_Enrollment__c enrollment1 = new hed__Course_Enrollment__c(
                hed__Contact__c = contact1.Id,
                Total_Classes_Completed__c = 10,
                Total_Classes_Attended__c = 8,
                Section__c = term.Id
           // LastModifiedDate= system.today()-1,
            //CreatedDate=system.today()-1
            );
        hed__Course_Enrollment__c enrollment2 = new hed__Course_Enrollment__c(
            hed__Contact__c = contact1.Id,
            Total_Classes_Completed__c = 15,
            Total_Classes_Attended__c = 10,
            Section__c = term.Id
           // LastModifiedDate= system.today()-1,
           // CreatedDate=system.today()-1
        );
        hed__Course_Enrollment__c enrollment3 = new hed__Course_Enrollment__c(
            hed__Contact__c = contact2.Id,
            Total_Classes_Completed__c = 5,
            Total_Classes_Attended__c = 5,
            Section__c = term.Id
           // LastModifiedDate= system.today()-1,
           // CreatedDate=system.today()-1
        );
        insert new List<hed__Course_Enrollment__c>{ enrollment1, enrollment2, enrollment3 };
            }    
    
    @IsTest
    static void testBatchClass() {
        // Execute the batch class
        Test.startTest();
        UpdateTheTotalAttendanceOfStudent batch = new UpdateTheTotalAttendanceOfStudent();
        Database.executeBatch(batch);
        Test.stopTest();       
    }
}