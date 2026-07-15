@isTest
public class ApplicationHandlerTest {
    @isTest
    static void testPAFPaidDateUpdate() {
        
        
        // Create test data
        hed__Application__c app = new hed__Application__c(
            //Applicants_Name__c = objCon.id,
            Provisional_Admission_Fee_Paid__c = false
        );
        insert app;

        // Verify that PAF_Paid_Date__c is not set initially
        System.assertEquals(null, app.PAF_Paid_Date__c);

        // Update the application to set Provisional_Admission_Fee_Paid__c to true
        app.Provisional_Admission_Fee_Paid__c = true;
        update app;

        // Verify that PAF_Paid_Date__c is set to today's date after the update
        System.assertEquals(Date.today(), [SELECT PAF_Paid_Date__c FROM hed__Application__c WHERE Id = :app.Id].PAF_Paid_Date__c);
    }
}