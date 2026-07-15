@isTest
public class rve_FinalYearWiseResultTest {

    @testSetup
    static void setupTestData() {
        //Create Account record
          Account acc = new Account(Name = 'Acc1');
         insert acc;
        
        // Create Active_Semester__c records
        hed__Term__c activeSemester = new hed__Term__c(Name = 'Sem 8' , hed__Account__c= acc.id);
        insert activeSemester;
        
        // Create Program_Batch__c records
        hed__Program_Plan__c programBatchBTechAfter2023 = new hed__Program_Plan__c(
            Name = 'B. Tech (2023-2027)'
        );
        hed__Program_Plan__c programBatchBTechBefore2023 = new hed__Program_Plan__c(
            Name = 'B. Tech (2015-2019)'
        );
        insert new List<hed__Program_Plan__c> { programBatchBTechAfter2023, programBatchBTechBefore2023 };
            
            hed__Course__c course = new hed__Course__c (Name = 'Course 1', hed__Account__c=acc.id);
        insert course;
        
        hed__Course_Offering__c courseOffering = new hed__Course_Offering__c(Name = 'CO1', hed__Course__c = course.id ,hed__Term__c=activeSemester.id);
        insert courseOffering;
            

        // Create Contact records
        
            Contact contact1 = new Contact(
                FirstName = 'Test1',
                LastName = 'User1',
                SRN_Number__c = 'SRN1',
                Program_Batch__c =  programBatchBTechAfter2023.Id,
                Active_Semester__c = activeSemester.id
            );
           
        insert contact1;
        
        hed__Course_Enrollment__c courseConn = new hed__Course_Enrollment__c (hed__Course_Offering__c =courseOffering.id , hed__Contact__c =contact1.id );
        insert courseConn;

        // Create hed__Term_Grade__c records
        List<hed__Term_Grade__c> termGrades = new List<hed__Term_Grade__c>();
        
            for (Integer j = 0; j < 5; j++) {
                hed__Term_Grade__c termGrade = new hed__Term_Grade__c(
                    hed__Contact__c = contact1.Id,
                    hed__Term__c = activeSemester.id,
                    hed__Result__c = 'Fail', // One fail per contact
                    No_of_Credits__c = 4,
                    hed__Course_Offering__c = courseOffering.Id,
                    hed__Course_Connection__c = courseConn.id
                );
                termGrades.add(termGrade);
            
        }
        insert termGrades;
        
        
        Contact contact2 = new Contact(
                FirstName = 'Test2',
                LastName = 'User2',
                SRN_Number__c = 'SRN2',
                Program_Batch__c =  programBatchBTechBefore2023.Id,
                Active_Semester__c = activeSemester.id
            );
           
        insert contact2;
        
        hed__Course_Enrollment__c courseConn2 = new hed__Course_Enrollment__c (hed__Course_Offering__c =courseOffering.id , hed__Contact__c =contact2.id );
        insert courseConn2;

        // Create hed__Term_Grade__c records
        List<hed__Term_Grade__c> termGrades2 = new List<hed__Term_Grade__c>();
        
            for (Integer j = 0; j < 5; j++) {
                hed__Term_Grade__c termGrade2 = new hed__Term_Grade__c(
                    hed__Contact__c = contact2.Id,
                    hed__Term__c = activeSemester.id,
                    hed__Result__c = 'Fail', // One fail per contact
                    No_of_Credits__c = 4,
                    hed__Course_Offering__c = courseOffering.Id,
                    hed__Course_Connection__c = courseConn2.id
                );
                termGrades2.add(termGrade2);
            
        }
        insert termGrades2;
    }

    @isTest
    static void testForEngineeringAfter2023() {
        // Retrieve the created term grades
        List<hed__Term_Grade__c> termGrades = [SELECT Id, hed__Contact__c, hed__Result__c, No_of_Credits__c FROM hed__Term_Grade__c];

        // Update term grades to trigger the logic
        for (hed__Term_Grade__c termGrade : termGrades) {
            termGrade.No_of_Credits__c += 1;
        }

        Test.startTest();
        update termGrades;
        Test.stopTest();

        // Retrieve updated contacts
        List<Contact> updatedContacts = [SELECT Id, Student_Status__c FROM Contact WHERE Student_Status__c != null];
        
        // Assert that some contacts have been marked as detained
        Boolean hasDetainedContacts = false;
        for (Contact con : updatedContacts) {
            if (con.Student_Status__c == 'Detained') {
                hasDetainedContacts = true;
                break;
            }
        }
        System.assert(hasDetainedContacts, 'There should be detained contacts based on the logic.');
    }
}