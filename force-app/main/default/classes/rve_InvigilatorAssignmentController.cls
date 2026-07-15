// InvigilatorAssignmentController.cls
public without sharing class rve_InvigilatorAssignmentController {

    // Fetch room numbers from Room Allotment object
    @AuraEnabled(cacheable=true)
    public static list<IA_Seating_Room_Allotment__c> getRoomNumbers() {
      //  List<String> roomNumbers = new List<String>();
        list<IA_Seating_Room_Allotment__c> room = [SELECT Id, Name,rve_Date_of_Exam__c,rveShift__c,Room__c
                                                   FROM IA_Seating_Room_Allotment__c WHERE 
                                                   Room__c !=null AND Active__c = true AND rve_Date_of_Exam__c >= TODAY AND 
                                        
                                                   (School__r.Examination_Vertical_Head__c=:userinfo.getUserId() 
                                                     OR School__r.Parent.Examination_Vertical_Head__c=:userinfo.getuserId())];	
        set<Id> RoomAllotmentSetall = new set<Id>();
        for(IA_Seating_Room_Allotment__c roomallot : room){
            RoomAllotmentSetall.add(roomallot.Id);
        }
        list<rve_Invigilator_Assignment__c> Invigilatorlist = [SELECT rve_Room_Allotment__c FROM rve_Invigilator_Assignment__c WHERE rve_Room_Allotment__c  IN :RoomAllotmentSetall];
        set<Id> RoomAllotmentSetwithchild = new set<Id>();
        for(rve_Invigilator_Assignment__c invigilator : Invigilatorlist){
            RoomAllotmentSetwithchild.add(invigilator.rve_Room_Allotment__c);
        }
        
        list<IA_Seating_Room_Allotment__c> finalroom = [SELECT Id, Name,rve_Date_of_Exam__c,rveShift__c,Room__c,Exam_Time__c,End_Time__c
                                                   FROM IA_Seating_Room_Allotment__c WHERE 
                                                   Room__c !=null AND Active__c = true AND rve_Date_of_Exam__c >= TODAY AND 
                                                   (School__r.Examination_Vertical_Head__c=:userinfo.getUserId() 
                                                    OR  School__r.Parent.Examination_Vertical_Head__c=:userinfo.getuserId()) AND ID Not IN : RoomAllotmentSetwithchild];	
      system.debug('finalroom'+finalroom);
        system.debug('finalroom'+finalroom.size());
        return finalroom;	
         
    }
    // Fetch existing invigilator assignments based on date, shift, room name, and room ID
    @AuraEnabled(cacheable=true)
    public static List<rve_Invigilator_Assignment__c> getExistingInvigilatorAssignments(string professors, string dates, string shifts, time Times) {
        system.debug('professors'+professors);
        system.debug('dates'+dates);
        system.debug('shifts'+shifts);
        system.debug('times'+times);
        list<rve_Invigilator_Assignment__c> existingassignments = [SELECT Id, rve_Date__c,  rve_Shift__c, rve_Professor__c, rve_Room_Allotment__r.Name FROM rve_Invigilator_Assignment__c WHERE 
                rve_Date__c =:Date.Valueof(dates) AND rve_Shift__c = :shifts AND rve_Exam_Time__c =:Times AND rve_Professor__c  =:professors];
     
        system.debug('existingassignments'+existingassignments);
        system.debug('existingassignments'+existingassignments.size());
        return existingassignments;
    }
    @AuraEnabled(cacheable=true)
    public static List<User> getProfessors(string searchKeyWord) {
        system.debug('keyword-->'+searchKeyWord);
        List<String> profileNames = new List<String>{'Professor','Vertical Head'};
        List<ID> profileIds = new List<ID>();
        for(Profile p:[select id from Profile where Name IN :profileNames])
        {
            profileIds.add(p.Id);
        }
            
        //String professorProfileName = 'Professor'; // Adjust based on your profile name
        //Id professorProfileId = [SELECT Id FROM Profile WHERE Name = :professorProfileName LIMIT 1].Id;
        list<User> userList =  [SELECT Id, Name,EmployeeNumber, IsActive  FROM User WHERE IsActive  = true AND ProfileId IN :profileIds AND (Name like :(searchKeyWord+'%') OR EmployeeNumber LIKE :(searchKeyWord+'%'))];
        system.debug('userlist'+ userList.size());
        return userList;
    }


    // Insert invigilator assignment records
    @AuraEnabled
    public static List<rve_Invigilator_Assignment__c> insertInvigilatorAssignments(List<rve_Invigilator_Assignment__c> invigilatorAssigned) {
        try {
            
            system.debug('inserted data'+invigilatorAssigned+' '+invigilatorAssigned.size());
            insert invigilatorAssigned;
        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException('Error occurred while inserting invigilator assignments: ' + e.getMessage());
        }
        return invigilatorAssigned;
    }
    
}