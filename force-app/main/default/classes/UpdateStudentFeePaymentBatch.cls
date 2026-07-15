global class UpdateStudentFeePaymentBatch implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Return a QueryLocator that retrieves up to 50 million records in batches
        String query = 'SELECT Id, Line_Item_Payment_Gateway__c, Transaction_Date_Time__c,Amount__c, SF_Transaction_ID__c, Student_Payment__c,Student_Payment__r.Transaction_ID__c ' + 
                       'FROM Student_Fee_Payment__c ' +
                       'WHERE Line_Item_Payment_Status__c = \'Success\' ' + 
                       'AND Student_Payment__r.Mode_of_Payment__c = \'Online\' ' + 
                       'AND Student_Payment__r.Payment_Date_Time__c > 2024-01-01T11:22:11.000+0000';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Student_Fee_Payment__c> scope) {
        Set<Id> studentPaymentIds = new Set<Id>();
        
        for(Student_Fee_Payment__c feePayment : scope) {
            studentPaymentIds.add(feePayment.Student_Payment__c);
        }
        
        Map<Id, Student_Payment__c> studentPaymentMap = new Map<Id, Student_Payment__c>([SELECT Id, Payment_Gateway__c, Payment_Date_Time__c, Transaction_ID__c,Amount__c 
                                                                                        FROM Student_Payment__c 
                                                                                        WHERE Id IN :studentPaymentIds]);

        List<Student_Fee_Payment__c> updatedFeePayments = new List<Student_Fee_Payment__c>();

        for(Student_Fee_Payment__c feePayment : scope) {
            Student_Payment__c studentPayment = studentPaymentMap.get(feePayment.Student_Payment__c);
            
            if(studentPayment != null) {
                if(feePayment.Line_Item_Payment_Gateway__c == null) {
                    feePayment.Line_Item_Payment_Gateway__c = studentPayment.Payment_Gateway__c;
                }
                if(feePayment.SF_Transaction_ID__c == null) {
                    feePayment.SF_Transaction_ID__c = studentPayment.Transaction_ID__c;
                }
                if(feePayment.Amount__c == null) {
                    feePayment.Amount__c = studentPayment.Amount__c;
                }
                if(feePayment.Transaction_Date_Time__c == null) {
                    feePayment.Transaction_Date_Time__c = studentPayment.Payment_Date_Time__c;
                }
                
                updatedFeePayments.add(feePayment);
            }
        }

        if(updatedFeePayments.size() > 0) {
            update updatedFeePayments;
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch processing completed.');
    }
}