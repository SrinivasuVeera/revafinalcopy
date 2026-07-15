/* This Batch is for Updating the Primary Faculty of Course Connections*/

global class MSTR_UpdateCourseConnectionFaculty_Batch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
       return Database.getQueryLocator([Select Id,Name,SRN_Number__c,RecordType.Name,Student_Status__c  from Contact where 
                                        RecordType.Name =: Utility.Contact_RecType_Student and Student_Status__c IN ('Pursuing','Year Back')
                                       ]); 
    } 
    
    global void execute(Database.BatchableContext bc, List<Contact> lst_Students)
    {
      set<Id> set_ConIds = new set<Id>();
      set<Id> set_SectionIds = new set<Id>();
      set<Id> set_CourseOfferingIds = new set<Id>();
      Id CourseConnectionRecType = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
      Id FacultyRecType = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
      Map<string,List<hed__Course_Enrollment__c>> Map_studntcon = new Map<string,List<hed__Course_Enrollment__c>>();
      List<hed__Course_Enrollment__c> lst_CourseEnroll = new List<hed__Course_Enrollment__c>();
      Id secRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();
      
      for(Contact objCon : lst_Students)
      {
          set_ConIds.add(objCon.Id);
      }  
      
      for(hed__Course_Enrollment__c objStudntConnection :[select Id,Name,hed__Contact__c,Section__c,hed__Course_Offering__c,Faculty__c,Secondary_Faculty__c,RecordTypeId,Section__r.hed__Parent_Term__r.Active__c,Section__r.RecordTypeId  from hed__Course_Enrollment__c  where 
                                                          RecordTypeId =: CourseConnectionRecType and hed__Contact__c In : set_ConIds and Section__r.hed__Parent_Term__r.Active__c =: true and Section__r.RecordTypeId =: secRecTypeId 
                                                          and Faculty__c = null])
      {      
              if(Map_studntcon.get(objStudntConnection.Section__c+'_'+objStudntConnection.hed__Course_Offering__c) == null)
              {
                  Map_studntcon.put(objStudntConnection.Section__c+'_'+objStudntConnection.hed__Course_Offering__c,new List<hed__Course_Enrollment__c>());
              }           
             Map_studntcon.get(objStudntConnection.Section__c+'_'+objStudntConnection.hed__Course_Offering__c).add(objStudntConnection);
          
          set_SectionIds.add(objStudntConnection.Section__c);
          set_CourseOfferingIds.add(objStudntConnection.hed__Course_Offering__c);
      }
      
      
      for(hed__Course_Enrollment__c objFacltyConnection :[select Id,Name,hed__Contact__c,Section__c,Secondary_Faculty__c ,RecordTypeId,Faculty__c,hed__Primary__c,hed__Course_Offering__c from hed__Course_Enrollment__c  where 
                                                         RecordTypeId =: FacultyRecType and Section__c In : set_SectionIds and hed__Course_Offering__c In : set_CourseOfferingIds and Faculty__c = null
                                                         and hed__Primary__c = true])
      {
          if(Map_studntcon.ContainsKey(objFacltyConnection.Section__c+'_'+objFacltyConnection.hed__Course_Offering__c))
          {              
              for(hed__Course_Enrollment__c objCOff : Map_studntcon.get(objFacltyConnection.Section__c+'_'+objFacltyConnection.hed__Course_Offering__c))
              {
                      objCOff.Faculty__c = objFacltyConnection.hed__Contact__c;
                      lst_CourseEnroll.add(objCOff);
              }
          }
      }
      
      if(!lst_CourseEnroll.IsEmpty())
      {
          Update lst_CourseEnroll;
      }
      
    }
    
    global void finish(Database.BatchableContext bc)
    {
    
    }
    
}