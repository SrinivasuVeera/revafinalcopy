public with sharing class rveInvigilatorAssignment325Controller {
    
    public virtual class BaseException extends Exception {}
    public class InvigilatorException extends BaseException {}
    
    public class InvigilatorWrapper{
        @AuraEnabled public String profName {get; set;}
        @AuraEnabled public Id profId {get; set;}
        @AuraEnabled public String room {get; set;}
        @AuraEnabled public Time examTime {get; set;}
        @AuraEnabled public Time examEndTime {get; set;}
        @AuraEnabled public String allotmentId {get; set;}
        @AuraEnabled public Map<Id,Decimal> contactMap {get;set;}
    }
    
    // This method retrieve dates from seating room allotment based on IA Type
    @AuraEnabled
    public static list<IA_Seating_Room_Allotment__c> getAllotmentDates(String IAType){
        try {
            return [SELECT id,  rve_Date_of_Exam__c
                    FROM IA_Seating_Room_Allotment__c 
                    WHERE IA_Type__c = :IAType and (School__r.Examination_Vertical_Head__c = :UserInfo.getUserId()
                                                    or School__r.parent.Examination_Vertical_Head__c = :UserInfo.getUserId())
                                                    AND rve_Date_of_Exam__c >= :Date.today()];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static list<rve_Invigilator_Assignment__c> getInvigilatorDates(String IAType){
        try {
            return [SELECT id,  rve_Date__c
                    FROM rve_Invigilator_Assignment__c
                    WHERE rve_Room_Allotment__r.IA_Type__c  = :IAType and (rve_Room_Allotment__r.School__r.Examination_Vertical_Head__c = :UserInfo.getUserId()
                                                                           or rve_Room_Allotment__r.School__r.parent.Examination_Vertical_Head__c = :UserInfo.getUserId())
                                                                           AND rve_Date__c >= :Date.today()];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<time>getSlots(String IAType, String AllotmentDate, String Session){
        try{
          
            // Validate input parameters
            if (String.isBlank(IAType) || String.isBlank(AllotmentDate) || String.isBlank(Session)) {
                throw new AuraHandledException('Invalid input parameters.');
            }
            
            // Convert string date to Date object
           Date AllotmentDate1 = Date.valueOf(AllotmentDate);
            // Step 1: Fetch Room Allotment Records
            
            Time morningStart = Time.newInstance(8, 0, 0, 0);
            Time morningEnd = Time.newInstance(11, 59, 0, 0);
            
            List<Time> timeSlots = new List<Time>();
            List<hed_Time_Table_Line_Item__c>timeTableList = new List<hed_Time_Table_Line_Item__c>();
            set<time> timeTableSlots = new set<time>();
            
            if(Session == 'Morning'){
                
                timeTableList = [Select Id,Reva_Exam_Notification__r.hed_Program_Batch__c,hed_Start_Time__c,hed_End_Time__c
                             from hed_Time_Table_Line_Item__c where Reva_Exam_Notification__r.Rve_Publish__c=true 
                             AND Reva_Exam_Notification__r.hed_IA_Type__c=:IAType
                             AND Reva_Exam_Notification__r.hed_Program_Batch__c != null 
                             AND hed_Date__c=:AllotmentDate1 
                             AND hed_Start_Time__c>=:morningStart
                             AND hed_Start_Time__c<=:morningEnd
                             AND CreatedById =: UserInfo.getUserId()];
                
                
            }
            
            else{
                Time afternoonStart = Time.newInstance(12, 0, 0, 0);  
                timeTableList = [Select Id,Reva_Exam_Notification__r.hed_Program_Batch__c,hed_Start_Time__c,hed_End_Time__c
                             from hed_Time_Table_Line_Item__c where Reva_Exam_Notification__r.Rve_Publish__c=true 
                             AND Reva_Exam_Notification__r.hed_IA_Type__c=:IAType
                             AND Reva_Exam_Notification__r.hed_Program_Batch__c != null 
                             AND hed_Date__c=:AllotmentDate1 
                             AND hed_Start_Time__c>=:afternoonStart
                             AND CreatedById =: UserInfo.getUserId()
                            ];  
            }

            if(!timeTableList.isEmpty()){
                for(hed_Time_Table_Line_Item__c timeTable : timeTableList){
                   if(timeTable.hed_Start_Time__c!=null){
                    timeTableSlots.add(timeTable.hed_Start_Time__c);
                   }
                }
            }

            if(!timeTableSlots.isEmpty()){
                timeSlots.addAll(timeTableSlots);
            }
            
            return timeSlots;
        }
        catch(Exception e){
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

    }
    
    @AuraEnabled
    public static list<IA_Seating_Room_Allotment__c> checkAllotments(String IAType, String AllotmentDate,String Session,String ExamTime) {
        try {
            Date AllotmentDate1 = Date.valueOf(AllotmentDate);
            Time examTime1 = convertToTime(examTime);
            // Step 1: Fetch Room Allotment Records
            List<IA_Seating_Room_Allotment__c> roomAllotments = [
                SELECT Id,Name, Room__c, rveShift__c, IA_Type__c, rve_Date_of_Exam__c, School__c,
                Exam_Time__c, End_Time__c
                FROM IA_Seating_Room_Allotment__c
                WHERE IA_Type__c = :iaType AND rve_Date_of_Exam__c = :AllotmentDate1 AND rveShift__c = :session
                AND Exam_Time__c = :examTime1
                AND (School__r.Examination_Vertical_Head__c = :UserInfo.getUserId() OR
                     School__r.parent.Examination_Vertical_Head__c = :UserInfo.getUserId())
                Order by Name ASC
            ];
            
           
            
            if(roomAllotments.isEmpty()) return new List<IA_Seating_Room_Allotment__c>();
            return roomAllotments;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<rve_Invigilator_Assignment__c> checkExistingInvigilatorAssignment(String iaType, String allotmentDate, String session, String examTime) {
        try {
           
            Date allotmentDate1 = Date.valueOf(allotmentDate);
            Time examTime1 = convertToTime(examTime);
        //    Time examTime1 = examTime != null ? Time(examTime) : Time.newInstance(0, 0, 0, 0);
            List<rve_Invigilator_Assignment__c> existingAssignments = [
                SELECT Id,rve_Professor__c,Name,rve_Exam_Time__c,rve_Exam_End_Time__c
                FROM rve_Invigilator_Assignment__c 
                WHERE rve_Room_Allotment__r.IA_Type__c = :iaType 
                AND rve_Date__c = :allotmentDate1 
                AND rve_Shift__c = :session AND rve_Exam_Time__c=: examTime1
                AND (rve_Room_Allotment__r.School__r.Examination_Vertical_Head__c = :UserInfo.getUserId() OR
                     rve_Room_Allotment__r.School__r.parent.Examination_Vertical_Head__c = :UserInfo.getUserId())
                order by Name ASC
            ];

            
            
            if (!existingAssignments.isEmpty()) {
                return existingAssignments;
            }
            return new list<rve_Invigilator_Assignment__c>();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<InvigilatorWrapper> assignInvigilator (String IAType, String AllotmentDate,String Session, String ExamTime) {
        try{
            Date AllotmentDate1 = Date.valueOf(AllotmentDate);
            // Step 1: Fetch Room Allotment Records
            
            Time morningStart = Time.newInstance(8, 0, 0, 0);
            Time morningEnd = Time.newInstance(11, 59, 0, 0);
            
            List<hed_Time_Table_Line_Item__c>timeTable = new List<hed_Time_Table_Line_Item__c>();
            
            if(Session == 'Morning'){
                
                timeTable = [Select Id,Reva_Exam_Notification__r.hed_Program_Batch__c,hed_Start_Time__c,hed_End_Time__c
                             from hed_Time_Table_Line_Item__c where Reva_Exam_Notification__r.Rve_Publish__c=true 
                             AND Reva_Exam_Notification__r.hed_IA_Type__c=:IAType
                             AND Reva_Exam_Notification__r.hed_Program_Batch__c != null and hed_Date__c=:AllotmentDate1 and hed_Start_Time__c>=:morningStart
                             AND hed_Start_Time__c<=:morningEnd
                             AND CreatedById =: UserInfo.getUserId()];
                
               
            }
            
            else{
                Time afternoonStart = Time.newInstance(12, 0, 0, 0);  
                timeTable = [Select Id,Reva_Exam_Notification__r.hed_Program_Batch__c,hed_Start_Time__c,hed_End_Time__c
                             from hed_Time_Table_Line_Item__c where Reva_Exam_Notification__r.Rve_Publish__c=true 
                             AND Reva_Exam_Notification__r.hed_IA_Type__c=:IAType
                             AND Reva_Exam_Notification__r.hed_Program_Batch__c != null 
                             AND hed_Date__c=:AllotmentDate1 
                             AND hed_Start_Time__c>=:afternoonStart
                             AND CreatedById =: UserInfo.getUserId()
                            ];  
            }
            
            set<id>ProgramBatchIds = new set<id>();
            set<time>startTime = new set<time>();
            set<time>endTime = new set<time>();
            List<Map<String, Time>> timeWindows = new List<Map<String, Time>>();
            
            if(timeTable.isEmpty()){
                return new List<InvigilatorWrapper>();
            }
            
            for(hed_Time_Table_Line_Item__c t : timeTable){
                ProgramBatchIds.add(t.Reva_Exam_Notification__r.hed_Program_Batch__c);
                startTime.add(t.hed_Start_Time__c);
                endTime.add(t.hed_End_Time__c);
                
                Time bufferStart = t.hed_Start_Time__c.addMinutes(-30);
                Time bufferEnd = t.hed_End_Time__c.addMinutes(60);
                timeWindows.add(new Map<String, Time>{ 'start' => bufferStart, 'end' => bufferEnd });
            }
            
           
            Set<Id> courseConnections = new Set<Id>();
            
            
            //Aditya Changes ended
            //Aditya New changes started
            Map<ID,Decimal> contactMaxSlots = new Map<ID,Decimal>();
            Map<string,Id> contactEmailMap = new Map<string,Id>();
            Map<Id,String> contactNames = new Map<Id,String>();
            Map<Id, Decimal> remainingSlotsMap = new Map<Id, Decimal>();
            Map<Id,Id> contactToOwnerMap = new Map<Id,Id>();
            Set<Id> contactIds = new Set<Id>();
            Set<string> conEmails = new set<string>();
            Set<Id> userIds = new Set<Id>();
            //Scenario 1 : Faculty should be selected from the same batch
            List<hed__Course_Enrollment__c> facultyConnections = [
                SELECT Id, hed__Contact__c,hed__Contact__r.hed__WorkEmail__c, hed__Contact__r.Max_Slot__c,hed__Contact__r.Remaining_Slot__c,hed__Contact__r.Name
                FROM hed__Course_Enrollment__c 
                WHERE recordtype.Name = 'Faculty' 
                AND
               (Section__r.hed__Parent_Term__r.Program_Batch__c In: ProgramBatchIds OR Section__r.Program_Batch__c In: ProgramBatchIds
                    ) 
                AND Active_Connection__c=true AND hed__Contact__r.remaining_Slot__c > 0
                ORDER BY hed__Contact__r.remaining_Slot__c DESC
            ];
            
            if(facultyConnections.isEmpty()){
                throw new InvigilatorException('Didnt find Faculty Connections for the given criteria.');
            }else{
                for(hed__Course_Enrollment__c cs: facultyConnections){
                     contactNames.put(cs.hed__Contact__c, cs.hed__Contact__r.Name);
                    contactIds.add(cs.hed__contact__c);
                    conEmails.add(cs.hed__contact__r.hed__WorkEmail__c);
                    contactEmailMap.put(cs.hed__contact__r.hed__WorkEmail__c,cs.hed__contact__c);
                    ContactMaxSlots.put(cs.hed__Contact__c,cs.hed__Contact__r.Max_Slot__c);
                    remainingSlotsMap.put(cs.hed__Contact__c, cs.hed__Contact__r.Remaining_Slot__c);
                }
            }
            if(remainingSlotsMap.isEmpty()){
                throw new InvigilatorException('No remaining slots available for the contacts.');
            }
            //Scneario 2 : Faculty should not be selected from other batches
            List<hed__Course_Enrollment__c> otherFacultyConnections = [ 
                SELECT Id, hed__Contact__c,hed__Contact__r.OwnerId, hed__Contact__r.Max_Slot__c,hed__Contact__r.Remaining_Slot__c,hed__Contact__r.Name
                FROM hed__Course_Enrollment__c 
                WHERE Section__r.hed__Parent_Term__r.Program_Batch__c NOT In: ProgramBatchIds  
                AND recordtype.Name = 'Faculty' 
                AND Active_Connection__c=true 
                AND hed__Contact__r.remaining_Slot__c > 0 
                AND hed__Contact__c IN :contactIds];
            
            if(!otherFacultyConnections.isEmpty()){
                for(hed__Course_Enrollment__c cs: otherFacultyConnections){
                    If(contactIds.contains(cs.hed__contact__c)){
                        courseConnections.add(cs.id);
                    }
                }
            }
            //scenario 3 : Should not have any conflict Schedules
            List<hed__Course_Offering_Schedule__c> conflictSchedules = [SELECT Faculty_Course_Connection__c,Faculty_Course_Connection__r.hed__Contact__c,Faculty_Course_Connection__r.hed__Contact__r.hed__WorkEmail__c,hed__Start_Time__c, hed__End_Time__c
                                                                        FROM hed__Course_Offering_Schedule__c 
                                                                        WHERE Date__c = :AllotmentDate1
                                                                        AND Faculty_Course_Connection__c In: courseConnections];
            
            if(!conflictSchedules.isEmpty()){
                for (hed__Course_Offering_Schedule__c s : conflictSchedules) {
                    for (Map<String, Time> window : timeWindows) {
                        Time windowStart = window.get('start');
                        Time windowEnd = window.get('end');
                        
                        // Check if course schedule overlaps with buffer window
                        if (s.hed__Start_Time__c < windowEnd && s.hed__End_Time__c > windowStart) {
                            
                            contactIds.remove(s.Faculty_Course_Connection__r.hed__Contact__c);
                            conEmails.remove(s.Faculty_Course_Connection__r.hed__Contact__r.hed__WorkEmail__c);
                            break;
                        }
                    }
                }
            }
            //Get the user records based on emails
            List<User> users = [SELECT Id,Email FROM User WHERE Email In: conEmails];
            if(users.isEmpty()){
                throw new InvigilatorException('Didnt find Users for the given criteria.');
            }else{
                   for(User u: users){
                       contactToOwnerMap.put(contactEmailMap.get(u.email),u.id);
                   }
            }
            //Scenario 4 : check faculty leaves
               List<Leave_Request__c> leaves = [  Select Id,Leave_Request_Status__c,From_Date__c,To_Date__c,OwnerId,Owner.name,Owner.email from Leave_Request__c WHERE Leave_Request_Status__c ='Approved by Professors' AND From_Date__c <= :AllotmentDate1 AND To_Date__c >= :AllotmentDate1 AND OwnerId In: contactToOwnerMap.values()];
               if(!leaves.isEmpty()){
                   for(Leave_Request__c l: leaves){
                       contactToOwnerMap.remove(l.Owner.email);
                   }
               }
            //Aditya New changes ended
            set<id>facultyids = new set<id>();
            Map<ID,Integer> userWithSlots = new Map<ID,Integer>();
           
            
            
            
            
            Integer roomIndex = 0;
            List<Id> assignedContactIds = new List<Id>();
            List<InvigilatorWrapper> updatedAllotments = new List<InvigilatorWrapper>();
            List<IA_Seating_Room_Allotment__c> roomAllotments = checkAllotments(IAType, AllotmentDate, Session, ExamTime);
            
            
            for (IA_Seating_Room_Allotment__c room : roomAllotments) {
                Boolean isAssigned = false;
                
                for (Id contactId : remainingSlotsMap.keySet()) {
                    if (assignedContactIds.contains(contactId)) {
                        continue; // Skip already assigned contacts
                    }
                    
                    Decimal slotsLeft = remainingSlotsMap.get(contactId);
                    
                    // Try to assign only if slot > 0 and contact is valid
                    if (slotsLeft != null && slotsLeft > 0 && contactNames.containsKey(contactId) && contactNames.get(contactId)!=NULL && contactToOwnerMap.containsKey(contactId) && contactToOwnerMap.get(contactId)!=NULL) {
                        InvigilatorWrapper iw = new InvigilatorWrapper();
                        iw.profName = contactNames.get(contactId);
                        iw.profId = contactToOwnerMap.get(contactId);
                        iw.room = room.Name;
                        iw.examTime = room.Exam_Time__c;
                        iw.examEndTime = room.End_Time__c;
                        iw.allotmentId = room.Id;
                        iw.contactMap = remainingSlotsMap;
                        
                        // Update slot and tracking
                        remainingSlotsMap.put(contactId, slotsLeft - 1);
                        assignedContactIds.add(contactId);
                        updatedAllotments.add(iw);
                        isAssigned = true;
                        break;
                    }
                }
                
                // If no contact was assigned, still create the wrapper with default/null values
                if (!isAssigned) {
                    InvigilatorWrapper iw = new InvigilatorWrapper();
                    iw.profName = 'No Contact Available';
                    iw.profId = null;
                    iw.room = room.Name;
                    iw.examTime = room.Exam_Time__c;
                    iw.examEndTime = room.End_Time__c;
                    iw.allotmentId = room.Id;
                    iw.contactMap = remainingSlotsMap;
                    
                    updatedAllotments.add(iw);
                }
            }
            
            
            
            return updatedAllotments;
        }
        
        catch(Exception e){
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string createInvigilatorAssignments(list<rve_Invigilator_Assignment__c>invigilatorList,Map<Id,Decimal>userContactMap){
        try {
           
            
            List<Contact>conlist = [Select Id,Remaining_Slot__c,Max_Slot__c from contact where Id IN :userContactMap.keySet()];
            List<contact>updatedConlist = new List<Contact>();
            for(Contact con : conlist){
                if(con.Remaining_Slot__c == null || con.Remaining_Slot__c <= 0) {
                    throw new AuraHandledException('No remaining slots available for contact: ' + con.Id);
                }
                else{
                    con.Remaining_Slot__c = con.Remaining_Slot__c - 1;
                    updatedConlist.add(con);
                }
            }
            
            update updatedConlist;
           
            DataBase.SaveResult[] results  = Database.insert(invigilatorList,false);
            for(Database.SaveResult result : results) {
                if(result.isSuccess()) {
                   
                } else {
                    // iterate over the failed ones
                    for(Database.Error error : result.getErrors()) {
                        System.debug('Error Status : ' + error.getStatusCode() + ' : ' + 'Error Fields : ' + error.getFields());
                    }
                }
            }
            return 'Invigilator Assignments created successfully';
            
            // }else{
            //     return 'No valid invigilators found for assignment.';
            // }
            
        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string checkExistingInvigilatorRecord(string profId,string examtime,string examdate,string recordid,string examendtime) { //rve_Invigilator_Assignment__c invigilator
         Date allotmentDate1 = Date.valueOf(examdate);
            Time examTime1 = convertToTime(examTime);
            Time examEnd = convertToTime(examendtime);
            
             List<Map<String, Time>> timeWindows = new List<Map<String, Time>>();
             
        try {
            Time bufferStart = examTime1.addMinutes(-30);
            Time bufferEnd = examEnd.addMinutes(60);
            timeWindows.add(new Map<String, Time>{ 'start' => bufferStart, 'end' => bufferEnd });
            List<rve_Invigilator_Assignment__c>existingInvigilator = 
                [Select Id,rve_Professor__c,rve_Exam_Time__c,rve_Exam_End_Time__c from rve_Invigilator_Assignment__c where (rve_Professor__c=:profId OR Id=:recordid)/*invigilator.rve_Professor__c*/
                 and rve_Date__c=:allotmentDate1 /*invigilator.rve_Date__c*/ and rve_Exam_Time__c=:examTime1/*invigilator.rve_Exam_Time__c*/];
            //For(rve_Invigilator_Assignment__c t : existingInvigilator){
                
                
           // }
            if(existingInvigilator.size()>0 && existingInvigilator[0].rve_Professor__c==profId){
                
                    return 'Invigilator already assigned for this date and time.';
            
                
            } else {
                set<id> courseConnections = new set<id>();
                set<Id> contactIds = new set<Id>();
                    User usr = [Select Id,Email from user where id = :profId];
                List<hed__Course_Enrollment__c> otherFacultyConnections = [ 
                        SELECT Id, hed__Contact__c,hed__Contact__r.OwnerId, hed__Contact__r.Max_Slot__c,hed__Contact__r.Remaining_Slot__c,hed__Contact__r.Name
                        FROM hed__Course_Enrollment__c 
                        WHERE  recordtype.Name = 'Faculty' 
                        AND Active_Connection__c=true  
                        AND hed__Contact__r.hed__WorkEmail__c = :usr.Email];
                    
                    if(!otherFacultyConnections.isEmpty()){
                        for(hed__Course_Enrollment__c cs: otherFacultyConnections){
                            If(!contactIds.contains(cs.hed__contact__c)){
                                courseConnections.add(cs.id);
                            }
                        }
                    }
                    //scenario 3 : Should not have any conflict Schedules
                    List<hed__Course_Offering_Schedule__c> conflictSchedules = [SELECT Faculty_Course_Connection__c,Faculty_Course_Connection__r.hed__Contact__c,Faculty_Course_Connection__r.hed__Contact__r.hed__WorkEmail__c,hed__Start_Time__c, hed__End_Time__c
                                                                                FROM hed__Course_Offering_Schedule__c 
                                                                                WHERE Date__c = :AllotmentDate1
                                                                                AND Faculty_Course_Connection__c In: courseConnections];
                    
                    if(!conflictSchedules.isEmpty()){
                        for(hed__Course_Offering_Schedule__c s :conflictSchedules){
                            for (Map<String, Time> window : timeWindows) {
                                Time windowStart = window.get('start');
                                Time windowEnd = window.get('end');
                                
                               
                                // Check if course schedule overlaps with buffer window
                                if (s.hed__Start_Time__c < windowEnd && s.hed__End_Time__c > windowStart) {
                                   return 'Schedule is existed for the user for program batch';
                                }
                            }
                        }
                        return 'test';
                    }else{
                        return 'test';
                    }
            }
        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        
        
    }
    
    @AuraEnabled
    public static string updateAllotment(List<rve_Invigilator_Assignment__c> invigilatorList) {
        try {
            List<rve_Invigilator_Assignment__c> assignmntsToUpdate = new List<rve_Invigilator_Assignment__c>();
            Set<Id> assignmentIds = new Set<Id>();
            String newProfEmail;
            for (rve_Invigilator_Assignment__c inv : invigilatorList) {
                assignmentIds.add(inv.Id);
            }
            
            // Fetch existing assignments
            Map<Id, Id> existingAssignmentProfessors = new Map<Id, Id>();
            Map<Id, string> existingprofwithEmail = new Map<Id, string>();
            for (rve_Invigilator_Assignment__c existing : [
                SELECT Id, rve_Professor__c,rve_Professor__r.email
                FROM rve_Invigilator_Assignment__c
                WHERE Id IN :assignmentIds
            ]) {
                existingAssignmentProfessors.put(existing.Id, existing.rve_Professor__c);
                existingprofwithEmail.put(existing.Id, existing.rve_Professor__r.Email);
            }
            
            // Collect old & new professor IDs
            Set<Id> allProfessorIds = new Set<Id>();
            set<string> allprofEmail = new set<string>();
            for (rve_Invigilator_Assignment__c inv : invigilatorList) {
                
                allProfessorIds.add(inv.rve_Professor__c);
                
                If(inv.rve_Professor__r.email!=NULL)allprofEmail.add(inv.rve_Professor__r.email);
                
            }
            for(user usr : [Select Id,Name,email from user where Id IN :allProfessorIds]){
                If(!allprofEmail.contains(usr.email)){
                    allprofEmail.add(usr.email);
                    newProfEmail = usr.email;
                }
            }
            allprofEmail.addAll(existingprofwithEmail.values());
           
            // Fetch contacts
            Map<string, Contact> professorContacts = new Map<string, Contact>();
            for (Contact con : [
                SELECT Id, Max_Slot__c, remaining_Slot__c, hed__WorkEmail__c
                FROM Contact
                WHERE hed__WorkEmail__c IN :allprofEmail
            ]) {
                professorContacts.put(con.hed__WorkEmail__c, con);
            }
            
            // Track contacts to update
            Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
            
            for (rve_Invigilator_Assignment__c inv : invigilatorList) {
                String oldProfEmail = existingprofwithEmail.get(inv.Id);
                //String newProfEmail = inv.rve_Professor__r.email;
                
                
                if (oldProfEmail != null && oldProfEmail != newProfEmail) {
                    assignmntsToUpdate.add(inv);
                    // Increase old professor slot
                    if (professorContacts.containsKey(oldProfEmail)) {
                        Contact oldContact = professorContacts.get(oldProfEmail);
                        oldContact.remaining_Slot__c += 1;
                        contactsToUpdate.put(oldContact.Id, oldContact);
                    }
                    
                    // Decrease new professor slot
                    if (professorContacts.containsKey(newProfEmail)) {
                        Contact newContact = professorContacts.get(newProfEmail);
                        if (newContact.remaining_Slot__c > 0) {
                            newContact.remaining_Slot__c -= 1;
                            contactsToUpdate.put(newContact.Id, newContact);
                        }
                    }
                }
            }
            
            // Perform updates
            update assignmntsToUpdate;
            if (!contactsToUpdate.isEmpty()) {
                
                update contactsToUpdate.values();
            }
            
            return 'Invigilator updated successfully';
        } catch (Exception ex) {
            System.debug('Error in updateAllotment: ' + ex.getMessage());
            return 'Error: ' + ex.getMessage();
        }
    }
    
    
    @AuraEnabled
    public static list<rve_Invigilator_Assignment__c>getInvigilatorAssignments(String IAType, String AllotmentDate, String Session) {
        try {
            Date AllotmentDate1 = Date.valueOf(AllotmentDate);
            return [SELECT Id, Name,rve_Exam_Time__c, rve_Professor__r.Name, rve_Date__c, rve_Shift__c,rve_Room_Allotment__r.Name
                    FROM rve_Invigilator_Assignment__c
                    WHERE rve_Room_Allotment__r.IA_Type__c = :IAType AND rve_Date__c = :AllotmentDate1 AND rve_Shift__c = :Session
                    AND (rve_Room_Allotment__r.School__r.Examination_Vertical_Head__c = :UserInfo.getUserId() OR
                         rve_Room_Allotment__r.School__r.parent.Examination_Vertical_Head__c = :UserInfo.getUserId())];
        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static time convertToTime(String timeString) {
        if (String.isBlank(timeString)) {
            return null;
        }
        try {
            String[] parts = timeString.split(':');
           
            Integer hours = Integer.valueOf(parts[0]);
            Integer minutes = Integer.valueOf(parts[1]);
            return Time.newInstance(hours, minutes, 0, 0);
        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException('Error converting string to Time: ' + e.getMessage());
        }

    }
    
    //Newly added by veera 11-10-2025//
    // NEW METHOD ADDED HERE
    @AuraEnabled
    public static List<Id> getCurrentUserSchoolIds() {
        try {
            List<Account> schools = [
                SELECT Id 
                FROM Account 
                WHERE Examination_Vertical_Head__c = :UserInfo.getUserId() 
                   OR parent.Examination_Vertical_Head__c = :UserInfo.getUserId()
            ];
            List<Id> schoolIds = new List<Id>();
            for (Account school : schools) {
                schoolIds.add(school.Id);
            }
            return schoolIds;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching school IDs: ' + e.getMessage());
        }
    }
}