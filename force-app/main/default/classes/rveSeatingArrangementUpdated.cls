public class rveSeatingArrangementUpdated {
    
    public static Set<Id> uniquecontactIds { get; set; }
    
    public class IASeatingArrangementDetails{
        @AuraEnabled public list<contact> ContactList {get;set;}
        @AuraEnabled public set<string> Students {get;set;}
        @AuraEnabled public Integer SizeOfStudents{get;set;}
        @AuraEnabled public Map<String,Integer> CourseWiseStudentsCount {get;set;}
        @AuraEnabled public Map<String,List<String>> CourseWithStudentSrns {get;set;}
    }
    
    public class FacilityWithAllotments {
        @AuraEnabled public String RoomNo {get;set;}
        @AuraEnabled public String Block {get;set;}
        @AuraEnabled public String Floor {get;set;}
        @AuraEnabled public Integer Capacity {get;set;}
        @AuraEnabled public Id FacilityId {get;set;}
        @AuraEnabled public Integer RemainingCapacity {get;set;}
        @AuraEnabled public String SchoolName {get;set;}
        @AuraEnabled public Id SchoolId {get;set;}
    }
     @AuraEnabled(cacheable=true)
    public static List<Account> getSchoolsForSelection() {
        Id ContactRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        // Fetch Accounts where the current user is School Head or Examination Vertical Head
        // Assuming 'School' is the Account record type DeveloperName for school accounts
        return [SELECT Id, Name FROM Account  WHERE RecordTypeId = :ContactRecTypeId ORDER BY Name ASC];
    }
    
    @AuraEnabled(cacheable=true)
    public static list<hed__Program_Plan__c> getActivePrograms(){
        
        List<Rve_Exam_Notification__c>ActiveExamNotifications = [Select Id,hed_Program_Batch__c from Rve_Exam_Notification__c where rve_Active__c = true and Rve_Publish__c= true];
        
        Set<Id>ActivePrograms = new set<Id>();
        
        if(!ActiveExamNotifications.isEmpty())
        {
            for(Rve_Exam_Notification__c ProgramInstance: ActiveExamNotifications)
            {
                ActivePrograms.add(ProgramInstance.hed_Program_Batch__c);
            }
        }
        
        List<hed__Program_Plan__c> ProgramPlans = [select Id,name,hed__Account__c
                                                   from hed__Program_Plan__c where Id In:ActivePrograms
                                                   and( hed__Account__r.School_Head__c=:UserInfo.getUserId() OR hed__Account__r.Examination_Vertical_Head__c=:UserInfo.getUserId() OR hed__Account__r.Parent.Examination_Vertical_Head__c=:UserInfo.getUserId())];
        return ProgramPlans;
    }
    
    @AuraEnabled
    public static string updateFacilities(Map<String,Integer> FacilityWithUpdatedCapacity,String ProgramBatchId){
        
        String status = '';
        try {
            list<hed__Facility__c>UpdatedFacility = new list<hed__Facility__c>();
            String AccountId = getAccountId(ProgramBatchId);
            list<hed__Facility__c>ExistingFacility = [SELECT Id, name, hed__Capacity__c, Facility_Booked__c, Room_Name__c, Room__c, Floor__c, Block__c
                                                      FROM hed__Facility__c 
                                                      WHERE hed__Account__c = :AccountId];
            
            if(!ExistingFacility.isEmpty())
            {
                for(hed__Facility__c ht: ExistingFacility)
                {
                    if(FacilityWithUpdatedCapacity.containskey(ht.Id))
                    {
                        ht.hed__Capacity__c = FacilityWithUpdatedCapacity.get(ht.Id);
                        UpdatedFacility.add(ht);
                    }
                }
            }
            if(UpdatedFacility.size() >0 )
            {
                update UpdatedFacility;
                status = 'successful';
            }
            
        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            status = e.getMessage();
        }
        return status;
    }
    
    public static Time parseTime(String timeString) {
        Time formattedTime;
        try {
            // Split the string to extract hours, minutes, and seconds
            List<String> parts = timeString.split(':');
            Integer hours = Integer.valueOf(parts[0]);
            Integer minutes = Integer.valueOf(parts[1]);
            Integer seconds = Integer.valueOf(parts[2].substring(0, 2)); // Remove ' AM' or ' PM'
            
            // Adjust hours if it's PM
            if (timeString.endsWith(' PM') && hours != 12) {
                hours += 12;
            } else if (timeString.endsWith(' AM') && hours == 12) {
                hours = 0;
            }
            
            // Construct a Time instance
            formattedTime = Time.newInstance(hours, minutes, seconds, 0);
        } catch (Exception e) {
            formattedTime = null;
            System.debug('Error parsing time: ' + e.getMessage());
        }
        return formattedTime;
    }    

    @AuraEnabled(cacheable=true)
    public static Account getSchoolByProgramBatch(Id programBatchId) {
       
        List<hed__Program_Plan__c> programPlans = [
            SELECT Id, hed__Account__r.ParentId, hed__Account__r.Parent.Name
            FROM hed__Program_Plan__c 
            WHERE Id = :programBatchId 
            LIMIT 1
        ];

        if (programPlans.isEmpty() || programPlans[0].hed__Account__r.ParentId == null) {
            return null;
        }
        Account school = new Account(
            Id = programPlans[0].hed__Account__r.ParentId,
            Name = programPlans[0].hed__Account__r.Parent.Name
        );
        
        return school;
    }    
    @AuraEnabled
    public static List<FacilityWithAllotments> getRelatedSchool(String ProgramBatchId,String IAType,String Session,Date DateOfExam,String ExamTime, List<String> SchoolIds){
        // Construct a Time instance
        Time timeValue = parseTime(ExamTime);
        Set<String> uniqueSchoolIds = new Set<String>();
        try {
            hed__Program_Plan__c Ht = [Select Id,hed__Account__r.parentId from hed__Program_Plan__c where Id=:ProgramBatchId];
            String defaultSchoolId = Ht.hed__Account__r.parentId;

        if (String.isNotBlank(defaultSchoolId)) {
            uniqueSchoolIds.add(defaultSchoolId);
        } else {             
             System.debug('Error: Program Batch Parent Account not found.');
        }
        if (SchoolIds != null && !SchoolIds.isEmpty()) {
            uniqueSchoolIds.addAll(SchoolIds);
        }
        if (uniqueSchoolIds.isEmpty()) {
            return new List<FacilityWithAllotments>();
        }
            list<FacilityWithAllotments>AllFacilities = getFacilitiesDetails(IAType, Session, DateOfExam, timeValue, new List<String>(uniqueSchoolIds));
            return AllFacilities;
        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            return new List<FacilityWithAllotments>();
            //  throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<FacilityWithAllotments> getFacilitiesDetails(String IAType,String Session,Date DateOfExam,Time ExamTime,List<String> SchoolIds){
        List<FacilityWithAllotments> FacilityList = new List<FacilityWithAllotments>();
        
        // Query existing allotments for the given account
        List<IA_Seating_Room_Allotment__c> existingAllotments = [SELECT Id, Name, Facility_Type__c, Facility_Type__r.Block__c, Facility_Type__r.Floor__c, Remaining_Capacity__c,Capacity__c, School__r.Name, School__c 
                                                                 FROM IA_Seating_Room_Allotment__c 
                                                                 WHERE School__c IN :SchoolIds and IA_Type__c=:IAType and rveShift__c=:Session and rve_Date_of_Exam__c=:DateOfExam
                                                                 and Exam_Time__c=:ExamTime Order By Name ASC];
        
        // Populate FacilityList with existing allotments
        if(!existingAllotments.isEmpty())
        {
            for(IA_Seating_Room_Allotment__c allotment : existingAllotments) {
                if(allotment.Remaining_Capacity__c!=0 && allotment.Remaining_Capacity__c>0)
                {
                    FacilityWithAllotments allotDetails = new FacilityWithAllotments();
                    allotDetails.RoomNo = allotment.Name;
                    allotDetails.Block = allotment.Facility_Type__r.Block__c;
                    allotDetails.Floor = allotment.Facility_Type__r.Floor__c;
                    allotDetails.Capacity = Integer.valueOf(allotment.Capacity__c);
                    allotDetails.RemainingCapacity = Integer.valueOf(allotment.Remaining_Capacity__c);
                    allotDetails.FacilityId = allotment.Facility_Type__c;
                    allotDetails.SchoolName = allotment.School__r.Name;
                    allotDetails.SchoolId = allotment.School__c;
                    FacilityList.add(allotDetails);
                }
            }
            
        }
        // Create a set of existing allotment IDs
        Set<Id> existingFacilityIds = new Set<Id>();
        
        if(!existingAllotments.isEmpty())
        {
            for(IA_Seating_Room_Allotment__c Allotment : existingAllotments) {
                existingFacilityIds.add(Allotment.Facility_Type__c);
            }
        }
        
        // Query related facilities not already included in existing allotments
        List<hed__Facility__c> relatedFacilities = [SELECT Id, name, hed__Capacity__c, Facility_Booked__c, Room_Name__c, Room__c, Floor__c, Block__c,hed__Account__r.Name, hed__Account__c 
                                                    FROM hed__Facility__c 
                                                    WHERE hed__Account__c IN :SchoolIds AND Id NOT IN :existingFacilityIds Order By Room__c ASC];
        
        
        // Populate FacilityList with related facilities
        if(!relatedFacilities.isEmpty())
        {
            for(hed__Facility__c facility : relatedFacilities) {
                FacilityWithAllotments allotDetails = new FacilityWithAllotments();
                allotDetails.RoomNo = facility.Room__c;
                allotDetails.Block = facility.Block__c;
                allotDetails.Floor = facility.Floor__c;
                allotDetails.Capacity = Integer.valueOf(facility.hed__Capacity__c);
                allotDetails.RemainingCapacity = Integer.valueOf(facility.hed__Capacity__c);
                allotDetails.FacilityId = facility.Id;
                allotDetails.SchoolName = facility.hed__Account__r.Name;
                allotDetails.SchoolId = facility.hed__Account__c;
                FacilityList.add(allotDetails);
            }
        }
        
     /*   List<FacilityWithAllotments>SortedFacilityList = new List<FacilityWithAllotments>();
        
        // Create two separate lists
        List<FacilityWithAllotments> usedCapacityList = new List<FacilityWithAllotments>();
        List<FacilityWithAllotments> fullCapacityList = new List<FacilityWithAllotments>();
        
        // Step 1: Divide FacilityList into two separate lists
        for (FacilityWithAllotments facility : FacilityList) {
            if (facility.RemainingCapacity != null && facility.Capacity != null && facility.RemainingCapacity < facility.Capacity) {
                usedCapacityList.add(facility);
            } else {
                fullCapacityList.add(facility);
            }
        }
        
        // Step 2: Sort usedCapacityList using Bubble Sort in descending order of RemainingCapacity
        Integer n = usedCapacityList.size();
        for (Integer i = 0; i < n - 1; i++) {
            for (Integer j = 0; j < n - i - 1; j++) {
                FacilityWithAllotments current = usedCapacityList[j];
                FacilityWithAllotments next = usedCapacityList[j + 1];
                
                // Handle null values safely
                Integer currentRemaining = (current.RemainingCapacity != null) ? current.RemainingCapacity : 0;
                Integer nextRemaining = (next.RemainingCapacity != null) ? next.RemainingCapacity : 0;
                
                // Swap if next has a larger RemainingCapacity
                if (currentRemaining < nextRemaining) {
                    FacilityWithAllotments temp = usedCapacityList[j];
                    usedCapacityList[j] = usedCapacityList[j + 1];
                    usedCapacityList[j + 1] = temp;
                }
            }
        }
        System.debug('UsedCapacityList=> '+usedCapacityList);
        System.debug('FullCapacityList=> '+fullCapacityList);
        // Step 3: Merge usedCapacityList first, then fullCapacityList
        FacilityList.clear();
        FacilityList.addAll(usedCapacityList);
        FacilityList.addAll(fullCapacityList);
        
        
        // FacilityList.sort();
        System.debug('FacilityList=> '+FacilityList);*/
        return FacilityList;
    }
    
    @AuraEnabled
    public static List<hed_Time_Table_Line_Item__c> getRevaExamNotifications(String IAType,String Session,Id ProgramId){
        try {
            List<hed_Time_Table_Line_Item__c>TimeTableItems = new List<hed_Time_Table_Line_Item__c>();
            
            if(Session== 'Morning')
            {
                TimeTableItems = 
                    [Select Id,name,Reva_Exam_Notification__r.hed_program_Batch__c,hed_Date__c,hed_Start_Time__c,hed_End_Time__c from hed_Time_Table_Line_Item__c
                     where Reva_Exam_Notification__r.rve_Active__c=true AND Reva_Exam_Notification__r.Rve_Publish__c=true
                     AND Reva_Exam_Notification__r.hed_IA_Type__c =: IAType AND Reva_Exam_Notification__r.hed_Program_Batch__c=:ProgramId
                     AND HOUR_IN_DAY(hed_Start_Time__c) >= 8 
                     AND HOUR_IN_DAY(hed_Start_Time__c) < 12 Order By hed_Date__c];
            }
            else{
                TimeTableItems = 
                    [Select Id,name,Reva_Exam_Notification__r.hed_program_Batch__c,hed_Date__c,hed_Start_Time__c,hed_End_Time__c from hed_Time_Table_Line_Item__c
                     where Reva_Exam_Notification__r.rve_Active__c=true and Reva_Exam_Notification__r.Rve_Publish__c=true
                     and Reva_Exam_Notification__r.hed_IA_Type__c =: IAType AND Reva_Exam_Notification__r.hed_Program_Batch__c=:ProgramId
                     AND HOUR_IN_DAY(hed_Start_Time__c) >= 12 Order By hed_Date__c];
            }
            
            if(!TimeTableItems.isEmpty())
            {
                return TimeTableItems;
            }
            else{
                return new List<hed_Time_Table_Line_Item__c>();
            }
            
        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string checkProgramBatchAllotment(String ActiveProgramBatch,Date dateOfExam, String shift, String examTime){
        try {
            String status = '';
            
            Time FormattedTime = parseTime(ExamTime);
            
            List<IA_Seating_Room_Allotment__c> existingAllotments = [SELECT Id, Name, Remaining_Capacity__c,Students__c,InEligible_SRN__c,Total_Students__c,Facility_Type__c,Capacity__c,Assigned_Program_Batches__c
                                                                     FROM IA_Seating_Room_Allotment__c
                                                                     WHERE rve_Date_of_Exam__c = :dateOfExam AND rveShift__c = :shift AND Exam_Time__c=:formattedTime and Assigned_Program_Batches__c LIKE :('%' + ActiveProgramBatch + '%')];
            
            if(!existingAllotments.isEmpty())
                status = 'found';
            
            return status;
        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static String createOrUpdateAllotment(String ActiveProgramBatch,List<Object> UpdateExistingCapacity, List<hed__Facility__c> facilityList,Map<String,List<String>>courseToSrnsMap, Date dateOfExam, String shift, String examTime) {
        try{
            //   System.debug('Students=> '+Students);
            Time timeValue = parseTime(ExamTime);
            
            List<hed_Time_Table_Line_Item__c> TimeTable = [Select Id,name,hed_End_Time__c,Course__r.Name,Reva_Exam_Notification__r.Name,Reva_Exam_Notification__r.hed_program_Batch__c,hed_Date__c,hed_Start_Time__c from hed_Time_Table_Line_Item__c
                                                           where Reva_Exam_Notification__r.Rve_Publish__c=true
                                                           AND hed_Start_Time__c=:timeValue AND hed_Date__c=:dateOfExam AND Reva_Exam_Notification__r.hed_Program_Batch__c=:ActiveProgramBatch];
            
            Time EndTime = TimeTable[0].hed_End_Time__c;
            
            String coursenames = '';
            if(!TimeTable.isEmpty())
            {
                for(hed_Time_Table_Line_Item__c Timetab : TimeTable)
                {
                    coursenames+= TimeTab.Course__r.Name+',';
                }
            }
            System.debug('CourseNames=> '+coursenames);
            
            Map<String, Integer> facilityMap = new Map<String, Integer>();
            for (Object obj : UpdateExistingCapacity) {
                List<Object> entry = (List<Object>)obj;
                String key = (String)entry[0];
                Integer value = Integer.valueOf(entry[1]);
                facilityMap.put(key, value);
            }
            
            set<ID>FacilityIds = new set<Id>();
            for(hed__Facility__c facility : facilityList)
            {
                //   System.debug('facility=> '+facility);
                FacilityIds.add(facility.Id);
            }
            Map<Id,hed__Facility__c>RemoveExistingFacility = new Map<Id,hed__Facility__c>();
            for(hed__Facility__c ht: facilityList)
            {
                System.debug('facilityId=> '+ht.Id+' facility=> '+ht);
            }
            set<String>StudentSRNS = new set<String>();
            
            List<IA_Seating_Room_Allotment__c> allotmentsToInsert = new List<IA_Seating_Room_Allotment__c>();
            
            // Parse exam time string to Time instance
            Time formattedTime = parseTime(examTime);
            
            hed__Program_Plan__c Ht = [Select Id,hed__Account__r.parentId from hed__Program_Plan__c where Id=:ActiveProgramBatch];
            
            
            // Query for existing seating room allotments based on date, shift, and account
            List<IA_Seating_Room_Allotment__c> existingAllotments = [SELECT Id, Name, Remaining_Capacity__c,Students__c,InEligible_SRN__c,Total_Students__c,Facility_Type__c,Capacity__c,Assigned_Program_Batches__c
                                                                     FROM IA_Seating_Room_Allotment__c
                                                                     WHERE rve_Date_of_Exam__c = :dateOfExam AND rveShift__c = :shift AND School__c = :Ht.hed__Account__r.parentId AND Exam_Time__c=:formattedTime and Facility_Type__c In:FacilityIds];
            
            set<ID>RemoveExistingAllotmentFacility = new set<ID>();
            Map<ID,IA_Seating_Room_Allotment__c>AllotmentMap = new Map<Id,IA_Seating_Room_Allotment__c>();
            Map<Id, Integer> remainingCapacityMap = new Map<Id, Integer>();
            
            if (!existingAllotments.isEmpty()) {
                
                for (IA_Seating_Room_Allotment__c allotment : existingAllotments) {
                    AllotmentMap.put(allotment.Id,allotment);
                    RemoveExistingAllotmentFacility.add(allotment.facility_type__c);
                    Integer remainingCapacity = Integer.valueOf(facilityMap.get(allotment.Facility_Type__c));
                    if (remainingCapacity > 0) {
                        remainingCapacityMap.put(allotment.Id, remainingCapacity);
                    }
                }
            }

            else if(existingAllotments.isEmpty()) {
                createAllotments(activeProgramBatch,facilityMap, facilityList,courseToSrnsMap, dateOfExam, shift, formattedTime,EndTime,coursenames,TimeTable[0].Reva_Exam_Notification__r.Name);
            }
            // If existing allotments found, update them
            for (String courseName : courseToSrnsMap.keySet()) {
                //   System.debug('allotment=> '+allotment);
                Boolean isCourseFullyAssigned = false;  // Flag to track if the course is fully assigned
                
                List<String> srns = courseToSrnsMap.get(courseName);
                System.debug('srnsize=> '+srns.size());
                
                // Assign SRNs to existing allotments first
                for (Id allotmentId : remainingCapacityMap.keySet()) {
                    if (srns.isEmpty()) break;
                    
                    IA_Seating_Room_Allotment__c allotment = AllotmentMap.get(allotmentId);
                    Integer remainingCapacity = remainingCapacityMap.get(allotmentId);
                    List<String> assignedSrns = new List<String>();
                    Set<String> assignedEligibleContacts = new Set<String>(); // Contacts assigned to this room
                    
                    while (remainingCapacity > 0 && !srns.isEmpty()) {
                        assignedEligibleContacts.add(srns[0]);
                        assignedSrns.add(srns.remove(0));
                        remainingCapacity--;
                    }
                    
                    if (!srns.isEmpty()) {
                        // If there are remaining students in the current course, update the map
                        courseToSrnsMap.put(courseName, srns);
                    } else {
                        // If all students for this course have been assigned, mark it as fully assigned
                        isCourseFullyAssigned = true;
                    }
                    
                    //   RemoveExistingAllotmentFacility.add(allotment.facility_type__c);
                    String EligibleContacts = '';
                    
                   // System.debug('remainingCapacity=> '+remainingCapacity);
                    
                    System.debug('EligibleContacts=> '+assignedEligibleContacts.size());
                    List<String> sortedEligibleContacts = new List<String>(assignedEligibleContacts);
                    sortedEligibleContacts.sort();
                    
                    //  Integer countStudentSRNS = 0;
                    System.debug('assignedEligibleContacts=> ' + sortedEligibleContacts.size());
                   /* for(String s : sortedEligibleContacts)
                    {
                        EligibleContacts=EligibleContacts+','+s;
                    }*/

                    EligibleContacts = String.join(sortedEligibleContacts, ',');
                    
                    // System.debug('EligibleContacts=> '+EligibleContacts);
                    List<string>countsrn = EligibleContacts.split(',');
                    
                    if (!String.isBlank(EligibleContacts)) {
                        // Initialize a set to combine all unique student SRNs
                        Set<String> uniqueStudents = new Set<String>();
                        
                        // Add existing Students__c values if they are not blank
                        if (!String.isBlank(allotment.Students__c)) {
                            List<String> existingStudents = allotment.Students__c.split(',');
                            uniqueStudents.addAll(existingStudents);
                        }
                        
                        // Add new EligibleContacts values
                        List<String> newEligibleStudents = EligibleContacts.split(',');
                        uniqueStudents.addAll(newEligibleStudents);
                        
                        // Convert the set to a list and sort alphabetically
                        List<String> sortedStudents = new List<String>(uniqueStudents);
                        sortedStudents.sort();
                        
                        // Join the sorted list into a comma-separated string
                        allotment.Students__c = String.join(sortedStudents, ',');
                        
                        // Debug the result
                        // System.debug('Sorted and Cleaned Students__c: ' + allotment.Students__c);
                    }
                    
                    allotment.Assigned_Program_Batches__c = (String.isNotBlank(ActiveProgramBatch)) ? allotment.Assigned_Program_Batches__c + ',' + ActiveProgramBatch : ActiveProgramBatch;
                    //    System.debug('before=> '+allotment.Total_Students__c);
                    allotment.Total_Students__c += assignedEligibleContacts.size();
                    //    System.debug('after=> '+allotment.Total_Students__c);
                    allotment.End_Time__c = EndTime;
                    
                 //   allotment.Course_Name__c = coursenames;
                    allotment.Exam_Name__c = TimeTable[0].Reva_Exam_Notification__r.Name!=null?TimeTable[0].Reva_Exam_Notification__r.Name:'';
                    if(!allotmentsToInsert.contains(allotment)){
                    allotmentsToInsert.add(allotment);
                    }
                    
                    remainingCapacityMap.put(allotmentId, remainingCapacity);
                    
                }
            }
            if (!allotmentsToInsert.isEmpty()) {
                for(IA_Seating_Room_Allotment__c ia: allotmentsToInsert)
                {
                    System.debug('ia=> '+ia);
                }
                // Perform the update using Database.update with allOrNone = false
                Database.SaveResult[] updateResults = Database.update(allotmentsToInsert, false);
                
                // Lists to track successful and failed updates
                List<IA_Seating_Room_Allotment__c> successfullyUpdatedAllotments = new List<IA_Seating_Room_Allotment__c>();
                List<IA_Seating_Room_Allotment__c> failedAllotments = new List<IA_Seating_Room_Allotment__c>();
                List<String> errorMessages = new List<String>();
                
                // Loop through the updateResults to check for success or failure
                for (Integer i = 0; i < updateResults.size(); i++) {
                    if (updateResults[i].isSuccess()) {
                        successfullyUpdatedAllotments.add(allotmentsToInsert[i]);
                    } else {
                        failedAllotments.add(allotmentsToInsert[i]);
                        // Capture the error messages for the failed update
                        for (Database.Error error : updateResults[i].getErrors()) {
                            errorMessages.add('Record failed to update - Id: ' + allotmentsToInsert[i].Id + 
                                              ', Error: ' + error.getMessage());
                        }
                    }
                }
                
                // Log the successful and failed updates
                System.debug('Successfully Updated Allotments: ' + successfullyUpdatedAllotments.size());
                System.debug('Failed Allotments: ' + failedAllotments.size());
                
                // Log the error messages for failed records
                if (!errorMessages.isEmpty()) {
                    for (String errorMsg : errorMessages) {
                        System.debug('Update Error: ' + errorMsg);
                    }
                }
            }
            
            System.debug('facility=> '+facilityList.size());
         //   if(!StudentSRNS.isEmpty()) {
                for (Integer i = facilityList.size() - 1; i >= 0; i--) {
                    // System.debug('facilityI=> ' + facilityList[i].Id);
                     System.debug('RemoveExistingAllotmentFacility=> ' + RemoveExistingAllotmentFacility.contains(facilityList[i].Id));
                    if (RemoveExistingAllotmentFacility.contains(facilityList[i].Id)) {
                        facilityList.remove(i);
                    }
                }
               
                if (!facilityList.isEmpty()){
                System.debug('facilityList=> '+facilityList);
                createAllotments(activeProgramBatch,facilityMap, facilityList,courseToSrnsMap, dateOfExam, shift, formattedTime,EndTime,coursenames,TimeTable[0].Reva_Exam_Notification__r.Name);
                }
            
            return 'Allotments created or updated successfully';
            
        }
        catch (Exception e) {
            
            System.debug('Line=> '+e.getLineNumber()+ ' Exception: ' + e.getMessage());
            // throw new AuraHandledException(e.getMessage());
            return e.getMessage();
        }
    }
    
    public static String createAllotments(String ActiveProgramBatch,Map<String,Integer>FacilityMap, List<hed__Facility__c> facilityList, Map<String,List<String>> courseToSrnsMap, Date dateOfExam, String shift, Time examTime,Time EndTime,String CourseName, String ExamName) {
        try {
            //  System.debug('StudentSRNS=> '+StudentSRNS);
            List<IA_Seating_Room_Allotment__c> allotmentsToInsert = new List<IA_Seating_Room_Allotment__c>();
            Set<String> allottedSRNs = new Set<String>(); // To track allotted SRN numbers
            Integer remainingStudentsCount = 0; // Total number of students to allot
            // Map to store contacts assigned to each room
            Map<hed__Facility__c, Set<Contact>> assignedContactsMap = new Map<hed__Facility__c, Set<Contact>>();
            
            // Collection to hold remaining SRNs for the next room assignment
            Set<String> remainingSRNs = new Set<String>();
            
            for (hed__Facility__c facility : facilityList) {
                String EligibleContacts = '';
                Integer remainingCapacity = Integer.valueOf(facilityMap.get(facility.Id));
                List<String> assignedSrns = new List<String>();
                Set<String> assignedEligibleContacts = new Set<String>(); // Contacts assigned to this room
                
                // Assign eligible students to the current room
                
                for (String course : courseToSrnsMap.keySet()) {
                    
                    if (remainingCapacity <= 0) break; // Stop assigning if room is full
                    
                    //   System.debug('allotment=> '+allotment);
                    
                    List<String> srns = courseToSrnsMap.get(course);
                    List<String>DuplicateSrn = new List<String>();
                    DuplicateSrn.addAll(srns);
                    System.debug('course=> '+course+' srns=> '+srns.size());
                    remainingStudentsCount = srns.size();
                    
                    for (Integer i = 0; i < srns.size() && remainingCapacity > 0;) {
                        if(!assignedEligibleContacts.contains(srns[i])){
                            assignedEligibleContacts.add(srns[i]); // Add to assigned list
                            srns.remove(i); // Remove the assigned element
                            remainingCapacity--; // Reduce capacity
                        }
                        // **DO NOT increment i**, because after removal, the next element automatically shifts to index i.
                    }  
                    
                    if (!srns.isEmpty()) {
                        courseToSrnsMap.put(course, srns);
                    } else {
                        courseToSrnsMap.remove(course); // Remove if fully assigned
                    }                               
                    
                    // Add new EligibleContacts values
                    Set<String> uniqueStudents = new Set<String>();
                    
                }
                
                // Create allotment record if there are eligible or ineligible students assigned to this room
                if (!assignedEligibleContacts.isEmpty()) {
                    IA_Seating_Room_Allotment__c allotment = new IA_Seating_Room_Allotment__c(
                        Name = facility.Room__c,
                        Facility_Type__c = facility.Id,
                        Capacity__c = facility.hed__Capacity__c,
                        IA_Type__c = facility.IA_Type__c,
                        School__c = getAccountId(ActiveProgramBatch),
                        Room__c = facility.Room__c,
                        Active__c = true,
                        rve_Date_of_Exam__c = dateOfExam,
                        rveShift__c = shift,
                        Exam_Time__c = examTime,
                        End_Time__c = EndTime,
                        Students__c = String.join(new List<String>(assignedEligibleContacts), ','),
                      //  Course_Name__c = CourseName!=null?CourseName:'',
                        Exam_Name__c = ExamName!=null?ExamName:'',
                        Assigned_Program_Batches__c = ActiveProgramBatch,
                        Total_Students__c = assignedEligibleContacts.size()
                    );
                    allotmentsToInsert.add(allotment);
                    assignedEligibleContacts.clear();
                    EligibleContacts = '';
                    
                    // Check if all students are allotted
                    if (remainingStudentsCount <= 0) break;
                    
                    if (!allotmentsToInsert.isEmpty()) {
                        // Perform the insert using Database.insert with allOrNone = false
                        for(IA_Seating_Room_Allotment__c ia: allotmentsToInsert)
                        {
                            System.debug('ia=> '+ia);
                        }
                        Database.SaveResult[] saveResults = Database.insert(allotmentsToInsert, false);
                        
                        // Lists to track successful and failed inserts
                        List<IA_Seating_Room_Allotment__c> successfullyInsertedAllotments = new List<IA_Seating_Room_Allotment__c>();
                        List<IA_Seating_Room_Allotment__c> failedAllotments = new List<IA_Seating_Room_Allotment__c>();
                        List<String> errorMessages = new List<String>();
                        
                        // Loop through the saveResults to check for success or failure
                        for (Integer i = 0; i < saveResults.size(); i++) {
                            if (saveResults[i].isSuccess()) {
                                successfullyInsertedAllotments.add(allotmentsToInsert[i]);
                            } else {
                                failedAllotments.add(allotmentsToInsert[i]);
                                // Capture the error messages for the failed record
                                for (Database.Error error : saveResults[i].getErrors()) {
                                    errorMessages.add('Record failed to insert - Id: ' + allotmentsToInsert[i].Id + 
                                                      ', Error: ' + error.getMessage());
                                }
                            }
                        }
                        
                        // Log the successful and failed inserts
                        System.debug('Successfully Inserted Allotments: ' + successfullyInsertedAllotments.size());
                        System.debug('Failed Allotments: ' + failedAllotments.size());
                        
                        // Log the error messages for failed records
                        if (!errorMessages.isEmpty()) {
                            for (String errorMsg : errorMessages) {
                                System.debug('Insert Error: ' + errorMsg);
                            }
                        }
                    }        
                }
            }
            return 'Allotments created or updated successfully';
            
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
            // return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static list<contact>getInEligiblestudents(String ProgramBatch){
        return [Select Id,name from contact where Program_Batch__c=:ProgramBatch];
        
    }
    
    @AuraEnabled
    public static IASeatingArrangementDetails getStudents(String ActiveProgramBatch,Date dateOfExam, String shift, String examTime){
        IASeatingArrangementDetails NewInstance = new IASeatingArrangementDetails();
        List<hed__Course_Enrollment__c>CourseConnections = new List<hed__Course_Enrollment__c>();
        try{
            Time timeValue = parseTime(examTime);
            list<hed_time_table_line_item__c>TimeTableList = [Select Id,name,Course__c,Reva_Exam_Notification__r.hed_Program_Batch__c from hed_time_table_line_item__c
                                                              where Reva_Exam_Notification__r.hed_Program_Batch__c=:ActiveProgramBatch and hed_Date__c=:dateOfExam and hed_Start_Time__c=:timeValue];
            
            System.debug('TimeTableList=> '+TimeTableList);
            
            set<Id>CourseIds = new set<Id>();
            set<Id>programIds = new Set<Id>();
            for(hed_time_table_line_item__c TimeTable: TimeTableList)
            {
                CourseIds.add(TimeTable.Course__c);
                programIds.add(TimeTable.Reva_Exam_Notification__r.hed_Program_Batch__c);
            }
            
            System.debug('CourseIds=> '+CourseIds);
            if(!TimeTableList.isEmpty()){
                CourseConnections = [Select Id,Section__c,hed__Course_Offering__r.hed__Course__c,hed__Contact__r.SRN_Number__c,hed__Contact__r.Application_Number__c,
                                     hed__Course_Offering__r.Name
                                     from 	hed__Course_Enrollment__c where Active_Connection__c=true and hed__Course_Offering__r.hed__Course__c In:CourseIds
                                     AND hed__Contact__r.Student_Status__c = 'Pursuing' AND hed__Contact__r.SRN_Number__c !=null
                                     AND hed__Contact__r.Record_Type_Name__c ='Student' and hed__Contact__r.Active__c=true and hed__Contact__r.Program_Batch__c In:programIds order by Section__c,hed__Contact__r.SRN_Number__c];
                
                System.debug('CourseConnections=> '+CourseConnections.size());
                System.debug('CourseConnections=> '+CourseConnections);
                
            } 
            Map<String,Integer>CourseWiseStudentsCount = new Map<String,Integer>();
            
            Set<String>StudentSRNS = new set<string>();
            Map<String,List<String>>CourseWithStudentSrns = new Map<String,List<String>>();
            if(!CourseConnections.isEmpty())
                for(hed__Course_Enrollment__c courseConnection : CourseConnections){
                    String CourseName = courseConnection.hed__Course_Offering__r.Name;
                    String srn = courseConnection.hed__Contact__r.SRN_Number__c;
                    // Check if the course already exists in the map
                    if (!CourseWithStudentSrns.containsKey(courseName)) {
                        // Initialize a new list if the course does not exist
                        CourseWithStudentSrns.put(courseName, new List<String>());
                    }
                    
                    // Get the list of SRNs for the current course
                    List<String> srnList = CourseWithStudentSrns.get(courseName);
                    
                    // Add the SRN to the list only if it does not already exist
                    if (!srnList.contains(srn)) {
                        srnList.add(srn);
                    }
                    if(CourseWiseStudentsCount.containskey(courseConnection.hed__Course_Offering__r.Name))
                    {
                        Integer count = CourseWiseStudentsCount.get(courseConnection.hed__Course_Offering__r.Name);
                        count++;
                        CourseWiseStudentsCount.put(courseConnection.hed__Course_Offering__r.Name,count);
                    }
                    else{
                        CourseWiseStudentsCount.put(courseConnection.hed__Course_Offering__r.Name,1);
                    }
                    if(courseConnection.hed__Contact__r.SRN_Number__c!=null)
                    {
                        StudentSRNS.add(courseConnection.hed__Contact__r.SRN_Number__c);
                    }else if(courseConnection.hed__Contact__r.Application_Number__c!=null){
                        StudentSRNS.add(courseConnection.hed__Contact__r.Application_Number__c);
                    }
                    
                }
            System.debug('StudentSRNS=> '+StudentSRNS);
            NewInstance.Students = StudentSRNS;
            NewInstance.SizeOfStudents = StudentSRNS.size();
            NewInstance.CourseWiseStudentsCount = CourseWiseStudentsCount;
            NewInstance.CourseWithStudentSrns = CourseWithStudentSrns;
            
            for(String course:CourseWithStudentSrns.keySet())
            {
                System.debug('course=> '+course+' Students=> '+CourseWithStudentSrns.get(course));
            }
            
            return NewInstance;
        }catch(Exception e){
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getAccountId(String ProgramBatch){
        String AccountId;
        try {
            hed__Program_Plan__c ht = [SELECT hed__Account__r.parentId FROM hed__Program_Plan__c where Id=:ProgramBatch limit 1];
            AccountId = ht.hed__Account__r.parentId;
        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
        }
        return AccountId;
    }
}