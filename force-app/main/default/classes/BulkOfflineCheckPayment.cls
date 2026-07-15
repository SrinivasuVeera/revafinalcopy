public with sharing class BulkOfflineCheckPayment {

    @AuraEnabled(cacheable=true)
    public static list<OfflinePaymentWrapperClass> getStudentFeePaymentRelatedRecords(){
        List<OfflinePaymentWrapperClass> StudentOfflinePaymnetDetailsList = new List<OfflinePaymentWrapperClass>();
        List<Student_Payment__C> fetchStudentPayment = new List<Student_Payment__C>();
        System.debug('Selected Records');

        for(Student_Payment__c StudentPaymentRecord:[Select Id, Amount__c, Contact__r.Name, Application_Number__c , 
                                                        (Select Id, Bank_Name__c, Cheque_Bank_Name__c, Cheque_DD_Date__c, Cheque_DD_Number__c, 
                                                            Cheque_DD_Realisation_Date__c From Student_Fee_Payments__r 
                                                            WHERE Cheque_Bank_Name__c != : null AND 
                                                            Mode_of_Payment__c = 'Offline' AND Line_Item_Payment_Status__c = 'Pending' 
                                                            AND Payment_Mode_Type__c = 'Cheque / DD' ORDER BY CreatedDate) 
                                                        From Student_Payment__c 
                                                        WHere Payment_Status__C = 'Pending' and Mode_of_Payment__c = 'Offline' LIMIT 50
                                                    ]){

            OfflinePaymentWrapperClass StudentOfflinePaymnetDetails = new OfflinePaymentWrapperClass();
            if(StudentPaymentRecord.Student_Fee_Payments__r.size() != 0){
                StudentOfflinePaymnetDetails.ChequeBankName = StudentPaymentRecord.Student_Fee_Payments__r[0].Cheque_Bank_Name__c;
                StudentOfflinePaymnetDetails.ChequeDDNumber = StudentPaymentRecord.Student_Fee_Payments__r[0].Cheque_DD_Number__c;
                StudentOfflinePaymnetDetails.ChequeDDDate = StudentPaymentRecord.Student_Fee_Payments__r[0].Cheque_DD_Date__c;
                StudentOfflinePaymnetDetails.StudentPaymentAmount = StudentPaymentRecord.Amount__c;
                StudentOfflinePaymnetDetails.ContactName = StudentPaymentRecord.Contact__r.Name;
                StudentOfflinePaymnetDetails.ApplicationNumber = StudentPaymentRecord.Application_Number__c;
                StudentOfflinePaymnetDetails.StudentpaymentIds = StudentPaymentRecord.Id;
                StudentOfflinePaymnetDetails.ChequeDDRealisationDate = StudentPaymentRecord.Student_Fee_Payments__r[0].Cheque_DD_Realisation_Date__c;
    
                StudentOfflinePaymnetDetailsList.add(StudentOfflinePaymnetDetails);
            }

        }

        return StudentOfflinePaymnetDetailsList;
    }


    @AuraEnabled(cacheable=true)
    public static List<String> getBankNames() {
        List<String> bankNames = new List<String>();
        Schema.DescribeFieldResult fieldResult = Student_Fee_Payment__c.Cheque_Bank_Name__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistValue : picklistValues) {
            bankNames.add(picklistValue.getValue());
        }
        return bankNames;
    }

    public class OfflinePaymentWrapperClass{

        @AuraEnabled public string ChequeBankName;
        @AuraEnabled public string ChequeDDNumber;
        @AuraEnabled public Date ChequeDDDate;
        @AuraEnabled public Decimal StudentPaymentAmount;
        @AuraEnabled public string  ContactName;
        @AuraEnabled public string ApplicationNumber;
        @AuraEnabled public Id StudentpaymentIds;
        @AuraEnabled public Date ChequeDDRealisationDate;
    }

}