global class SLCM_updateEmpSalaryInQuarterBatch implements Database.batchable<SObject> {
    Map<String,Decimal> empRentMap=new Map<String,Decimal>();
    
    global SLCM_updateEmpSalaryInQuarterBatch(Map<String,Decimal>  empRentMap){
        this.empRentMap = empRentMap;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return database.getQueryLocator([
            SELECT Id ,Employee_Salary__c,Salary_Last_Revised_Date__c,Type__c
            FROM Staff_Quarters_Request__c 
            WHERE Type__c =: empRentMap.keySet()
            AND (Quarters_Request_Type__c = 'NonTeachingStaff' OR Quarters_Request_Type__c = 'TeachingStaff' OR Quarters_Request_Type__c = 'SchoolDirector')
            AND Quarter_Request_For__r.Employee_Number__c != null  
            AND Employee_Salary__c != null 
            AND Staff_Quarters_Joining_Date__c != null 
            AND Status__c !=null
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Staff_Quarters_Request__c> staffList) {  
        List<Staff_Quarters_Request__c>  updateStaff = new List<Staff_Quarters_Request__c>();
        for(Staff_Quarters_Request__c staffReq : staffList){
            if(staffReq.Type__c != null && staffReq.Employee_Salary__c !=null && empRentMap.containsKey(staffReq.Type__c)){
                staffReq.Employee_Salary__c = empRentMap.get(staffReq.Type__c);
                staffReq.Salary_Last_Revised_Date__c = System.today();
                 updateStaff.add(staffReq);
            }
            
        }
        
        if(!updateStaff.isEmpty()){
            update updateStaff; 
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
}