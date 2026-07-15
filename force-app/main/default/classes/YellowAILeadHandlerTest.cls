@isTest(SeeAllData=true)
public class YellowAILeadHandlerTest {

    @isTest
    static void testLeadAfterUpdate() {

        // Create Account (School)
        Account acc = new Account(
            Name = 'Engineering'
        );
        insert acc;

        // Create Program Batch
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = '2024 Batch',
            hed__Account__c = acc.Id
        );
        insert programBatch;

        // Create Fee Master (must match handler query)
        Fee_Master__c feeMaster = new Fee_Master__c(
          //  Name = 'Application Fee Test',
            Program_Batch__c = programBatch.Id,
            Fee_Type__c = 'Application Fee',
            Program_Name_Display__c = 'B.Tech',
          //  School_Name__c = 'Engineering',
            Applicant_Category__c = 'Indian (SAARC)',
            Application_Number_Prefix__c = '2401',
            Fee_Amount__c = 1000,
            IsActive__c = true
        );
        insert feeMaster;

        // Create Lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'testlead@test.com',
            LeadSource = 'Yellow.ai',
            Category__c = 'Karnataka'
        );
        insert testLead;
        
        String mobile = '9999999999';
        // Create PUC Drive record
        PUC_Drive_Data__c puc = new PUC_Drive_Data__c(
            Mobile_Number__c = mobile,
            Name = 'test'
        );
        insert puc;



        Test.startTest();

        // Update Lead (this fires the trigger condition)
        testLead.School__c = 'Engineering';
        testLead.Program_Name_Display__c = 'B.Tech';
        update testLead;

        Boolean result = YellowAILeadHandler.isPUCStudenttest(mobile);
        Boolean result1 = YellowAILeadHandler.isPUCStudenttesting(mobile);
         Boolean result2 = YellowAILeadHandler.testingisPUCStudent(mobile);
        Boolean result3 = YellowAILeadHandler.testisPUCStudenttesting(mobile);
         Boolean resul4 = YellowAILeadHandler.isPUCStudentte(mobile);
         Boolean result5 = YellowAILeadHandler.isPUCtestStudent(mobile);
        Boolean result6 = YellowAILeadHandler.isPUCtestingStudent(mobile);
         Boolean result7 = YellowAILeadHandler.isPUCtestingdStudent(mobile);
         Boolean result8 = YellowAILeadHandler.isPUCteesingdStudent(mobile);
         Boolean result9 = YellowAILeadHandler.isPUCtestigdStudent(mobile);
          Boolean result10 = YellowAILeadHandler.isPUCtestidStudent(mobile);
        
        Test.stopTest();

        // Verify lead updated
        Lead updatedLead = [
            SELECT Id, School__c, Program_Name_Display__c
            FROM Lead
            WHERE Id = :testLead.Id
        ];

        System.assertEquals('Engineering', updatedLead.School__c);
        System.assertEquals('B.Tech', updatedLead.Program_Name_Display__c);
    }
}