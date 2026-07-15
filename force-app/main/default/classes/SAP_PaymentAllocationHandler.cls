public class SAP_PaymentAllocationHandler {
    public static void handlePaymentAllocation(List<Student_Payment__c> newPayments, Map<Id, Student_Payment__c> oldPaymentsMap) {
        List<Student_Payment__c> addStdPayments = new List<Student_Payment__c>();
        Map<Id, Student_Payment__c> relevantOldPaymentsMap = new Map<Id, Student_Payment__c>();
        list<Student_Payment__c> refundPayments =  new list<Student_Payment__c>();
        for (Student_Payment__c sp : newPayments) {   
            if (sp.Payment_Status__c != 'Adjusted' && sp.Payment_Status__c != 'Refunded') {
                if(oldPaymentsMap != null && !oldPaymentsMap.isEmpty()  ){
                    if (oldPaymentsMap.containsKey(sp.Id) && !oldPaymentsMap.keyset().isEmpty()) {
                        relevantOldPaymentsMap.put(sp.Id, oldPaymentsMap.get(sp.Id));
                    } 
                }
                
                addStdPayments.add(sp);
            } 
           
        }  
        if (!addStdPayments.isEmpty()) {    
            
            SAP_PaymentAllocationHelper.handlePaymentAllocation(addStdPayments, relevantOldPaymentsMap);
        }
       
        
    }
}