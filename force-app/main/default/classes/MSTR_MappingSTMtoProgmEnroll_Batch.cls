global class MSTR_MappingSTMtoProgmEnroll_Batch implements Database.Batchable<sObject>
{
    global Set<Id> set_STMIds = new Set<Id>();
    
    global MSTR_MappingSTMtoProgmEnroll_Batch(Set<Id> set_StudTermIds)
    {
        set_STMIds = set_StudTermIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        Set<String> set_RecordTypeName = new Set<String>();
        set_RecordTypeName.add(Utility.STM_RecType_Section);
        set_RecordTypeName.add(Utility.STM_RecType_Batch);
        return Database.getQueryLocator([Select Id, RecordTypeId, Program_Enrollment__c, Active__c, Section__c, 
                                         Student_Batch__c, Recordtype.Name, Semester_ID__c from 
                                         Student_Semester_Mapping__c Where Active__c =: True AND 
                                         Program_Enrollment__c != Null AND Recordtype.Name IN: set_RecordTypeName 
                                         AND CreatedDate = Today AND Mapped_to_Program_Enrollment__c =: False
                                         AND ID IN:set_STMIds]); 
    }
    
    global void execute(Database.BatchableContext bc, List<Student_Semester_Mapping__c> lstStudSemMap)
    {
        Map<Id, hed__Program_Enrollment__c> map_PrgmEnroll = new Map<Id, hed__Program_Enrollment__c>();
        List<Student_Semester_Mapping__c> lstUpdateStudSem = new List<Student_Semester_Mapping__c>();
        for(Student_Semester_Mapping__c objSTM : lstStudSemMap)
        {
            Student_Semester_Mapping__c objUpdSTM =  new Student_Semester_Mapping__c();
            objUpdSTM.Id = objSTM.Id;
            if(objSTM.RecordType.Name == Utility.STM_RecType_Section && objSTM.Active__c == true 
               && objSTM.Section__c != null &&  objSTM.Program_Enrollment__c !=null)
            {
                if(map_PrgmEnroll.get(objSTM.Program_Enrollment__c) == Null)
                {
                    map_PrgmEnroll.put(objSTM.Program_Enrollment__c, new hed__Program_Enrollment__c(Id = objSTM.Program_Enrollment__c));
                }
                map_PrgmEnroll.get(objSTM.Program_Enrollment__c).Semester__c = objSTM.Semester_ID__c;
                map_PrgmEnroll.get(objSTM.Program_Enrollment__c).Section__c = objSTM.Section__c;
                map_PrgmEnroll.get(objSTM.Program_Enrollment__c).Batch__c = Null;
                map_PrgmEnroll.get(objSTM.Program_Enrollment__c).Section_Change_Date__c = System.Today();
                
                objSTM.Mapped_to_Program_Enrollment__c = true;
                lstUpdateStudSem.add(objSTM);
            }
            else if(objSTM.RecordType.Name == Utility.STM_RecType_Batch && objSTM.Active__c == true 
                    && objSTM.Student_Batch__c != null &&  objSTM.Program_Enrollment__c !=null)
            {
                if(map_PrgmEnroll.get(objSTM.Program_Enrollment__c) == Null)
                {
                    map_PrgmEnroll.put(objSTM.Program_Enrollment__c, new hed__Program_Enrollment__c(Id = objSTM.Program_Enrollment__c));
                }
                map_PrgmEnroll.get(objSTM.Program_Enrollment__c).Batch__c = objSTM.Student_Batch__c;
                map_PrgmEnroll.get(objSTM.Program_Enrollment__c).Section_Change_Date__c = System.Today();
                
                objSTM.Mapped_to_Program_Enrollment__c = true;
                lstUpdateStudSem.add(objSTM);
            }  
        }
        
        if(map_PrgmEnroll.size()>0)
            update map_PrgmEnroll.values();
        
        if(lstUpdateStudSem.size()>0)
            update lstUpdateStudSem;
    }
    
    global void finish(Database.BatchableContext bc)
    {
       // BatchClass_Utility.sendBatchClassFailureMail('Master Module', bc.getJobId(), 'Mapping STM to Program Enrollment','Student_Semester_Mapping__c');
    }
}