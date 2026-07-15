public class rveInvigilatorAttendenceParent {

    @AuraEnabled(cacheable=true)
    public static List<rve_Invigilator_Assignment__c> getRoomNumbers() {
       // List<User> lUsers = [SELECT Id, Contact.Id, Name, ContactId, Email FROM User WHERE Id = :UserInfo.getUserId()];

        List<rve_Invigilator_Assignment__c> userlist =    [SELECT Id, Name, rve_Professor__r.Id,rve_Date__c, rve_Shift__c,rve_Exam_Time__c,
                                                           rve_Exam_End_Time__c,rve_Attendance_Submitted__c,QR_Attendance_Update__c FROM rve_Invigilator_Assignment__c 
                                                          WHERE rve_Professor__r.Id =:UserInfo.getUserId() AND rve_Date__c >= :Date.today().addDays(-15)
                                                          AND rve_Date__c <= :Date.today()];
        //'0055j000007i0dpAAA' LIMIT 1];
        //'0055j000007i0dpAAA' LIMIT 1 

        System.debug('userlist=> '+userlist);
        return userlist;
    }

    @AuraEnabled(cacheable=true)
    public static List<rve_Invigilator_Assignment__c> fetchInvigilatorDetails() {
        List<rve_Invigilator_Assignment__c> invigilatordetails = getRoomNumbers();
     /*   set<Id>InvigilatorId = new set<Id>();
        if(!invigilatordetails.isEmpty())
        {
            for(rve_Invigilator_Assignment__c Invig : invigilatordetails)
            {
               InvigilatorId.add(Invig.id); 
            }
        }
        List<rve_Invigilator_Assignment__c> roomAssignments = new List<rve_Invigilator_Assignment__c>();
        set<String> RoomName = new set<String>();
        
        for(rve_Invigilator_Assignment__c room : invigilatordetails){
            RoomName.add(room.Name);
        }

        try {
            if (invigilatordetails.size() > 0) {
                System.debug('invigilatordetails=> '+InvigilatorDetails);
                System.debug('RoomName=> '+RoomName);
                System.debug('InvigilatorDetails=> '+invigilatordetails[0].rve_Professor__r.Id);
                roomAssignments = [SELECT Id, Name, rve_Date__c, rve_Shift__c,rve_Exam_Time__c, rve_Exam_End_Time__c,rve_Attendance_Submitted__c
                                   FROM rve_Invigilator_Assignment__c
                                   WHERE rve_Date__c = :Date.today().addDays(-15)
                                   AND rve_Date__c <= :Date.today() AND Name IN : RoomName and ID In:InvigilatorId
                                   order by rve_Shift__c ASC                                
                                   ];
                System.debug('roomAssignments=> '+RoomAssignments);
            }
        } catch(Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }*/
        
        return invigilatordetails;
    }
}