global class OwnerUpdateForProfessor_batch implements DataBase.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        string prof_RecordTypeId = Utility.Contact_RecType_Professor;
        return Database.getQueryLocator([Select Id,Employee_Number__c, RecordTypeId from Contact where createdDate >= TODAY and RecordType.Name =: prof_RecordTypeId]); 
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> lstContact)
    {
        set<string> set_Empno = new set<string>();
        map<string,Contact> map_con = new map<string,Contact>(); 	 		
        for(contact objCont : lstContact)
        {
            set_Empno.add(objCont.Employee_Number__c);
            map_con.put(objCont.Employee_Number__c, objCont);
        }
        
        if(set_Empno.size()>0)
        { 
            for(user objusr : [select Id,EmployeeNumber from user where EmployeeNumber IN: set_Empno])
            {                
                if(map_con.get(objusr.EmployeeNumber) != null)
                {
                    map_con.get(objusr.EmployeeNumber).Ownerid = objusr.id;
                }
            }
        } 
        if(map_con.size()>0)
        {
            Utility.ContactOwnerUpdate = false;
            update map_con.values();                 
        } 
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}