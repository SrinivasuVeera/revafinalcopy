public class NPF_DocumentCreationUsingURL {
        
    public static void CreateFile(List<hed__Education_History__c> lst_EducHstry)
    {
        set<Id> set_EduHstryIds = new set<Id>();       
        for(hed__Education_History__c objEducation : lst_EducHstry)
        {            
            string recordTpId =  Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get(Utility.Educ_History_Object_RecType_Edu_Details).getRecordTypeId(); 
            if(string.isNotBlank(objEducation.File_Url__c) && recordTpId == objEducation.RecordTypeId) set_EduHstryIds.add(objEducation.Id);           
        }      
        if(set_EduHstryIds.size() > 0) {
            FutureMethodCreateFile(set_EduHstryIds);
        }
    }    
    
    public static void FutureMethodCreateFile(set<Id> setEduHstry)
    {        
        if(setEduHstry.size() > 0) 
        {
            for(hed__Education_History__c objEduHstry : [select Id,File_Url__c,Board__c from hed__Education_History__c where Id IN: setEduHstry])
            {
                utility.FileCreation(objEduHstry.File_Url__c,objEduHstry.Id,objEduHstry.Board__c);
            }
        }        
    }    
}