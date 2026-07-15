global class UpdateTotalAmountInPenaltyFeeBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Hostel_Late_Fee__c, Amount__c,Amount_Paid__c, Amount_Pending__c,Student_Hostel_Fee__c
            FROM Student_Fee__c 
            WHERE Fee_Type__c = 'Hostel Fee' 
            AND Name = 'Hostel Penalty Fees']);
    }
    
    global void execute(Database.BatchableContext BC, List<Student_Fee__c> scope) {
        
        List<Student_Fee__c> penaRecordsToUpdate = new List<Student_Fee__c>();
        List<Student_Fee__c> FinalPenaRecordsToUpdate = new List<Student_Fee__c>();
        Map<Id,List<Student_Fee__c>> parentHstlFeeMap = new Map<Id,List<Student_Fee__c>>();
        
        System.debug('penalty Fee Records-->'+scope);
        
        if (scope.isEmpty()) {
            return; // No records to process
        }
        
        for (Student_Fee__c stuFee : scope) {
            if(!parentHstlFeeMap.containsKey(stuFee.Student_Hostel_Fee__c)){
                parentHstlFeeMap.put(stuFee.Student_Hostel_Fee__c, new List<Student_Fee__c>());      
            }
            parentHstlFeeMap.get(stuFee.Student_Hostel_Fee__c).add(stuFee) ; 
        }
        
        List<Student_Fee__c> parentHostelFees =[
            SELECT Id ,Name ,Fee_Type__c,Amount_Pending__c 
            FROM Student_Fee__c 
            WHERE Id IN:parentHstlFeeMap.KeySet() 
            AND Fee_Type__c = 'Hostel Fee' 
            AND Name LIKE 'Hostel Fee%' 
            AND Amount_Pending__c > 0];
        
        if (parentHostelFees.isEmpty()) {
            return;           
        }
        
        for(Student_Fee__c parentFee :parentHostelFees){
            if(parentFee.Amount_Pending__c > 0){
                penaRecordsToUpdate.addAll(parentHstlFeeMap.get(parentFee.Id)) ;
            }  
        }
        
        if (penaRecordsToUpdate.isEmpty()) {
            return; 
        }
         
        for(Student_Fee__c penaltyFee : penaRecordsToUpdate){
            if(penaltyFee.Hostel_Late_Fee__c > 0)  {
                System.debug('formula field: '+ penaltyFee.Hostel_Late_Fee__c);
                penaltyFee.Amount__c = penaltyFee.Amount_Paid__c == 0 ? penaltyFee.Hostel_Late_Fee__c : penaltyFee.Hostel_Late_Fee__c;
                penaltyFee.Amount_Pending__c =  penaltyFee.Hostel_Late_Fee__c - penaltyFee.Amount_Paid__c ;
                System.debug('amount field: '+ penaltyFee.Amount__c);
                penaltyFee.Number_of_Installments__c = 1;
                penaltyFee.Paid_Installments__c = 0;
                FinalPenaRecordsToUpdate.add(penaltyFee);
            }     
             
                      
        }
         if(!FinalPenaRecordsToUpdate.isEmpty()){
                update FinalPenaRecordsToUpdate;
            }
    }
    
    
    global void finish(Database.BatchableContext BC) {
        // Execute any post-processing logic here
    }
}