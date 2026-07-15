global class UpdateTATBusinessDaysBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        String enrollmentyearStr = [
            SELECT Text_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'Enrolment_Year'
            LIMIT 1
        ].Text_Value__c;

        Decimal enrollmentyear = Decimal.valueOf(enrollmentyearStr);

        return Database.getQueryLocator([
            SELECT Id,
                   hed__Applicant__c,hed__Applicant__r.name
            FROM hed__Application__c
            WHERE hed__Applicant__c != null
            AND hed__Applicant__r.Application_Fee_Paid__c = TRUE
           // AND hed__Applicant__r.Application_Fee_Paid_Date__c != null
            AND (
                hed__Applicant__r.Disposition__c = ''
                OR hed__Applicant__r.Description1__c = ''
            )
            AND Partial_Paid__c = FALSE
            AND hed__Applicant__r.Program_Batch__r.smt_Start_Year__c = :enrollmentyear
            AND hed__Applicant__r.Record_Type_Name__c = 'Applicant'
        ]);
    }

    global void execute(Database.BatchableContext bc,
                        List<hed__Application__c> scope) {

        Set<Id> contactIds = new Set<Id>();

        for(hed__Application__c app : scope) {
            if(app.hed__Applicant__c != null) {
                contactIds.add(app.hed__Applicant__c);
            }
        }

        if(contactIds.isEmpty()) {
            return;
        }

        // CHANGE OBJECT/FIELDS IF NEEDED
        Map<Id, Datetime> paymentDateMap = new Map<Id, Datetime>();

        for(Student_Payment__c fee : [
            SELECT Id,
                   Contact__c,
                   Payment_Date_Time__c
            FROM Student_Payment__c WHERE Contact__c IN :contactIds
            AND Fee_Type__c = 'Application Fee' and Payment_Status__c = 'Success'
            AND Payment_Date_Time__c != NULL 
        ]) {

            // Keep latest payment datetime if multiple records exist
            if(!paymentDateMap.containsKey(fee.Contact__c) ||
               paymentDateMap.get(fee.Contact__c) < fee.Payment_Date_Time__c) {

                paymentDateMap.put(
                    fee.Contact__c,
                    fee.Payment_Date_Time__c
                );
            }
        }

        if(paymentDateMap.isEmpty()) {
            return;
        }

        BusinessHours bh = [
            SELECT Id
            FROM BusinessHours
            WHERE IsDefault = TRUE
            LIMIT 1
        ];
                             system.debug('paymentDateMapbh:'+bh);

        List<Contact> contactsToUpdate = new List<Contact>();

        for(Id contactId : paymentDateMap.keySet()) {

            Datetime paymentDT = paymentDateMap.get(contactId);

            Long businessMs = BusinessHours.diff(
                bh.Id,
                paymentDT,
                System.now()
            );
            system.debug('paymentDateMapbusinessMs :'+ businessMs );
            Decimal businessHours = businessMs / (1000.0 * 60 * 60);
            system.debug('paymentDateMapbusinessHours:'+ businessHours );
            Integer tatDays = Integer.valueOf(Math.floor(businessHours / 8));
            system.debug('paymentDateMaptatDays:'+ tatDays);
            contactsToUpdate.add(
                new Contact(
                    Id = contactId,
                    TAT_Business_Days__c = tatDays
                )
            );
        }

        if(!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {
    }
}