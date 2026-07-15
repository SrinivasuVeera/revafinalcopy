global class ASM_AttendRollUpToProgEnrollment implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select Id from hed__Program_Enrollment__c where Active__c =: true]); //and Id IN ('a0J0w000003bLewEAE','a0J0w000003bLeyEAE')
    }
    global void execute(Database.BatchableContext bc, List<hed__Program_Enrollment__c> lst_ProgramEnrol){
        
        map<Id,hed__Program_Enrollment__c> map_ProgramEnroll = new map<Id,hed__Program_Enrollment__c>();   
        set<Id> set_ProgEnrollment = new set<Id>();
        if(lst_ProgramEnrol.size() > 0)
        {
            for(hed__Program_Enrollment__c objProgramEnrol : lst_ProgramEnrol)
            {                 
                set_ProgEnrollment.add(objProgramEnrol.Id);
            }
            
            if(set_ProgEnrollment.size() > 0)
            {
                for(Id objId : set_ProgEnrollment)
                {
                    map_ProgramEnroll.put(objId,new hed__Program_Enrollment__c(Id=objId,Total_Classes_Attended__c=0,Total_Classes_Completed__c=0));
                }
                
                for(hed__Course_Enrollment__c objCoursConnect : [select Id,Total_Classes_Attended__c,Total_Classes_Completed__c,hed__Program_Enrollment__c 
                                                                 from hed__Course_Enrollment__c 
                                                                 where hed__Program_Enrollment__c IN: set_ProgEnrollment])
                {
                    system.debug('===Total Classes===>>>'+objCoursConnect.Total_Classes_Attended__c);
                    system.debug('===Total Completed===>>>'+objCoursConnect.Total_Classes_Completed__c);
                    if(map_ProgramEnroll.get(objCoursConnect.hed__Program_Enrollment__c) != null)
                    {
                        if(objCoursConnect.Total_Classes_Attended__c > 0)
                        {
                            map_ProgramEnroll.get(objCoursConnect.hed__Program_Enrollment__c).Total_Classes_Attended__c += objCoursConnect.Total_Classes_Attended__c;
                        }
                        if(objCoursConnect.Total_Classes_Completed__c > 0)
                        {
                            map_ProgramEnroll.get(objCoursConnect.hed__Program_Enrollment__c).Total_Classes_Completed__c += objCoursConnect.Total_Classes_Completed__c;
                        }
                    }
                }                 
                if(map_ProgramEnroll.size() > 0) update map_ProgramEnroll.values();
            }
        }
    }    
    global void finish(Database.BatchableContext bc){
        
    }    
}