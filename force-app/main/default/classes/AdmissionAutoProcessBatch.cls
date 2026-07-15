global class AdmissionAutoProcessBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
 
        Datetime before24Hours = System.now().addHours(-24);
        
        return Database.getQueryLocator([
            SELECT Id,
                   hed__Applicant__c,
                   hed__Applying_To__c,
                   hed__Application_Status__c,
                   hed__Application_Date__c,
                   Fee_Structure_Defined__c,
                   hed__Applicant__r.Program_Batch__r.Name
            FROM hed__Application__c
            WHERE hed__Application_Status__c = 'In Review'
            AND Fee_Structure_Defined__c = FALSE
            AND hed__Application_Date__c <= :before24Hours
        ]);

    }

    global void execute(Database.BatchableContext bc,
                        List<hed__Application__c> scope) {

        for(hed__Application__c app : scope){

            try{

                AdmissionAutoProcessService.processApplication(app);

            }catch(Exception ex){

                System.debug('Error : ' + ex.getMessage());

            }

        }

    }

    global void finish(Database.BatchableContext bc){

        System.debug('Admission Auto Process Batch Completed');

    }

}