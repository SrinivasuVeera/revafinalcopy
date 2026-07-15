trigger SLCM_EmployeeRentTrigger on SLCM_Employee_Rent_Detail__c (After update) {
    Map<String,Decimal> empRentMap=new Map<String,Decimal>();
    if(trigger.isAfter && trigger.isUpdate){
        for(SLCM_Employee_Rent_Detail__c rent : trigger.new){
            if(rent.Room_Type__c !=null && rent.Request_Type__c !=null && rent.Monthly_Deduction_Amount__c > 0 
               && rent.Monthly_Deduction_Amount__c != trigger.oldMap.get(rent.Id).Monthly_Deduction_Amount__c){
                   empRentMap.put(rent.Room_Type__c,rent.Monthly_Deduction_Amount__c);
               }
        }
        if(empRentMap.size() > 0){
            database.executeBatch(new SLCM_updateEmpSalaryInQuarterBatch(empRentMap) ,1); // Calling batch class. SLCM_updateEmpsalaryInReq
        }
    }
    
}