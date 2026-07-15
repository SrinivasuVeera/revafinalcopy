public class LeadAssignment_Batch implements Database.Batchable<sObject>, Database.Stateful {
    //Post deployment steps
    /*LeadAssignment_Scheduler sch = new LeadAssignment_Scheduler();
System.schedule('Lead assignment schedule - I', '0 00 * * * ? ' , sch);
System.schedule('Lead assignment schedule - II', '0 15 * * * ? ' , sch);
System.schedule('Lead assignment schedule - III', '0 30 * * * ? ' , sch);
System.schedule('Lead assignment schedule - IV', '0 45 * * * ? ' , sch);*/
    //PERFORMING_ARTS_COUNSELOR assignemet Removed temporavery in fuctre want uncomment these lines
    // Line 22, 25,42-43
    public string query;
    private Integer initialIndex;
    private Integer finalIndex;
    private Integer noOfRecordsProcessed = 0;
    private Integer timeDelay = (Integer) Batch_Config__mdt.getInstance('Lead_Assignment_Time_Delay_in_minutes').Time__c; //Get delay time 
    private dateTime presentTime = System.now();  //Get present time 
    public List<GroupMember> counselors = new List<GroupMember>();
    private List<Fee_Master__c> feeMasterProgramList;
    List<String> SPECIFIC_CATEGORY = new List<String>{'Foreign Nationals','Indian (SAARC)','SAARC','Non-Resident Indian(NRI)'}; //Lead/Contact Category 
       // private static final String SPECIFIC_SCHOOL = 'School of Performing Arts and Indic Studies'; //Lead/Contact School 
    private static final String SPECIFIC_PROGRAM_TYPE = 'Ph.D'; //Lead/Contact Program type
    private static String foreignerCounselorFedId = (String) General_Setting__mdt.getInstance('FOREIGNER_COUNSELOR').Text_Value__c; //Get Foreign nationals counselor mail Id
    //private static String perArtsCounselorFedId = (String) General_Setting__mdt.getInstance('PERFORMING_ARTS_COUNSELOR').Text_Value__c; //Get Performing arts counselor maild Id
    private static String phdProgramCounselorFedId = (String) General_Setting__mdt.getInstance('PHD_COUNSELOR').Text_Value__c; //Get Ph.d counselor maild Id
    private Id foreignerCounselorId = null;
    //private Id performingArtsCounselorId = null;
    private Id PhdCounselorId = null;
    private Id ruUniversityUserId = null;
    private Map<String, String> leadProgramTypeMap = New Map<String, String>();
    private Map<String, String> contactProgramTypeMap = New Map<String, String>();
    private Integer initialCount;
    private Integer finalCount;
    
    public Map<String,GroupMember> userIds = new Map<String,GroupMember>();  
    Map<String, List<GroupMember>> groupMembersMap = new Map<String, List<GroupMember>>();
    Map<Id, String> programBatchGroupMap = new Map<Id, String>();
    Set<Id> programBatchIds = new Set<Id>();
    Map<String, String> programPlanMap = new Map<String, String>(); 
    private Map<Id, hed__Program_Plan__c> programBatchByIdMap = new Map<Id, hed__Program_Plan__c>();
    private Map<String, hed__Program_Plan__c> programBatchByKeyMap = new Map<String, hed__Program_Plan__c>();
    private Map<Id, Id> recordIdToResolvedBatchIdMap = new Map<Id, Id>(); // Lead/Contact Id -> Program_Batch__c Id, resolved via Fee_Master__c
    private Map<String, Id> counselorFedIdToUserIdMap = new Map<String, Id>();
    private Map<String, LeadAssignmentSetting__c> pbSettingsToUpsert = new Map<String, LeadAssignmentSetting__c>();
    private static final String FEE_TYPE_APPLICATION = 'Application Fee';


    private  void getSpecificCounselor() {
        //Get User Id from users by matching FederationIdentifier
        List<User> foreignerCounselor = [SELECT Id, FederationIdentifier, isactive FROM User 
                                         Where FederationIdentifier = :foreignerCounselorFedId and isactive = true Limit 1];
        /*List<User> perArtsCounselor = [SELECT Id, FederationIdentifier, isactive FROM User 
                                       Where FederationIdentifier = :perArtsCounselorFedId and isactive = true  Limit 1];*/
        List<User> phdProgramCounselor = [SELECT Id, FederationIdentifier, isactive FROM User 
                                          Where FederationIdentifier = :phdProgramCounselorFedId and isactive = true Limit 1];
        if(!foreignerCounselor.isEmpty()){
            foreignerCounselorId = foreignerCounselor[0].Id;
        } 
        /*if (!perArtsCounselor.isEmpty()){
            performingArtsCounselorId = perArtsCounselor[0].Id;
        } */
        if (!phdProgramCounselor.isEmpty()){
            PhdCounselorId = phdProgramCounselor[0].Id;
        }
        
      /*  List<GroupMember> groupMembers = [
            SELECT UserOrGroupId, Group.DeveloperName 
            FROM GroupMember 
            WHERE Group.DeveloperName like '%Group_%'
        ];
        
       
        for (GroupMember gm : groupMembers) {
            if (!groupMembersMap.containsKey(gm.Group.DeveloperName)) {
                groupMembersMap.put(gm.Group.DeveloperName, new List<GroupMember>());
            }
            groupMembersMap.get(gm.Group.DeveloperName).add(gm);
        }
        
         List<User> ruUser = [SELECT Id FROM User WHERE Name = 'Reva university RU' AND IsActive = true LIMIT 1];
        
        if(!ruUser.isEmpty()){
            ruUniversityUserId = ruUser[0].Id;
            system.debug('ruUniversityUserId:'+ruUniversityUserId);
        }
        */
    }
    
    private String resolveFeeMasterCategory(String selectCategory) {
        if (selectCategory == 'Karnataka' || selectCategory == 'Non-Karnataka') {
            return 'Indian (SAARC)';
        }
        return selectCategory;
    }
    
    //Start method
    public Iterable<SObject> Start(Database.BatchableContext bc) {
        System.debug('****** Inside Start ******');
        getSpecificCounselor(); //Method to get Dedicated counselore user Ids
        initialIndex = RegistrationProcessUtility.getCounselorIndex();
        //Get Counselors from public group
        
        
      for(GroupMember gm:[SELECT id,GroupId, UserOrGroupId, Group.Name FROM GroupMember WHERE Group.DeveloperName = 'Admission_Counselor' ORDER BY UserOrGroupId ]){
            userIds.put(gm.UserOrGroupId, gm);
        }
        initialCount = userIds.size();
        System.debug('initial count is '+initialCount);
        for(User u: [SELECT id from USER Where id in :userIds.keySet() and isactive = false]){
            if(userIds.containsKey(u.id)){
                userIds.remove(u.id);
            }
        }
        finalCount =  userIds.size();
        System.debug('after removing inactive counselors count is '+finalCount);
        
        for(GroupMember gm1: userIds.values()){
            counselors.add(gm1);
      
        }
        // counselors = userIds.values();
        
                    /* counselors = [SELECT GroupId, UserOrGroupId, Group.Name 
            FROM GroupMember 
            WHERE Group.DeveloperName = 'Admission_Counselor' 
            ORDER BY UserOrGroupId ];*/
                
        feeMasterProgramList =  [SELECT Program_Name_Display__c, Program_Name__c, Program_Type__c
                                 FROM Fee_Master__c
                                 WHERE Program_Type__c = :SPECIFIC_PROGRAM_TYPE];
        for(Fee_Master__c feeMasterProgram : feeMasterProgramList) {
            leadProgramTypeMap.put(feeMasterProgram.Program_Name_Display__c, feeMasterProgram.Program_Type__c);
            contactProgramTypeMap.put(feeMasterProgram.Program_Name__c, feeMasterProgram.Program_Type__c);
        }
        
        //Get Leads and Contacts to be assigned to counselors
        List<sObject> unassignedRecs = new List<sObject>();
        unassignedRecs.addAll([Select id, utm_campaign__c,utm_source__c, utm_medium__c, Name, Phone, Assigned__c, OwnerId, CreatedDate, Select_Category__c, 
                               School_Name__c, Program_Name_Display__c, Assigned_Users__c,Program_Batch__r.Group__c,Owner.Profile.Name,
                               Program_Name__c, Status From Lead 
                               Where 
                               Assigned__c = False
                               And (Status = 'Verified' OR Status = 'UnVerified') AND (Program_Batch__c != Null or Program_Name_Display__c != Null)
                               //((Status != 'Unqualified') or (Status != 'Payment Pending')) And utm_campaign__c !='Third_Party_Admissions'
                               AND  utm_source__c!='Referrals'  AND utm_medium__c!='Consultancy_2025' Limit 30000]);
        unassignedRecs.addAll([Select id, Name, Phone, Assigned__c, OwnerId, CreatedDate, Select_Category__c, School_Name__c, 
                               Program_Name__c, Assigned_Users__c,Program_Batch__r.Group__c
                               From Contact 
                               Where Assigned__c= False AND Program_Batch__c != Null
                               AND Record_Type_Name__c = 'Applicant' AND  utm_source__c!='Referrals'
                               //And utm_campaign__c !='Third_Party_Admissions' 
                               AND utm_medium__c!='Consultancy_2025' ]);
      Set<String> programNameKeys = new Set<String>();
        for (SObject rec : unassignedRecs) {
            if (rec.getSObjectType() == Lead.sObjectType || rec.getSObjectType() == Contact.sObjectType) {
                Id programBatchId = (Id) rec.get('Program_Batch__c');
                if (programBatchId != null) {
                    programBatchIds.add(programBatchId);

                }
            }
                if (rec.getSObjectType() == Lead.sObjectType){
                String programNameDisplay = (String) rec.get('Program_Name_Display__c');
                if ( programNameDisplay != null) {
                    programNameKeys.add(programNameDisplay);
                }
            }
        }
        
        // Step 2: Query Program_Batch__c to get Group__c values
        if (!programBatchIds.isEmpty()) {
            for (hed__Program_Plan__c	 programBatch : [
                SELECT Id, Group__c,Select_Counselors__c, Active__c
                FROM hed__Program_Plan__c	
                WHERE Id IN :programBatchIds
            ]) {
                programBatchGroupMap.put(programBatch.Id, programBatch.Group__c);
                programBatchByIdMap.put(programBatch.Id, programBatch); 
            }
        }
     
       // ===== NEW: resolve Program_Batch__c for records missing it, via Fee_Master__c =====
        // Mirrors production site-registration logic exactly:
        //   Fee_Master__c WHERE Program_Name_Display__c = :program AND School_Name__c LIKE '%school%'
        //   AND Applicant_Category__c = :category AND IsActive__c = true AND Fee_Type__c = 'Application Fee'
        //   ORDER BY Application_Number_Prefix__c DESC
        Set<String> programNameKeysForFallback = new Set<String>();
        for (SObject rec : unassignedRecs) {
            Id existingBatchId = (Id) rec.get('Program_Batch__c');
            if (existingBatchId != null) continue;
            Boolean isLeadRec = (rec.getSObjectType() == Lead.sObjectType);
            String pNameForKey = isLeadRec ? (String) rec.get('Program_Name_Display__c') : (String) rec.get('Program_Name__c');
            if (pNameForKey != null) {
                programNameKeysForFallback.add(pNameForKey);
            }
        }
 
        if (!programNameKeysForFallback.isEmpty()) {
            List<Fee_Master__c> feeMasterCandidates = [
                SELECT Id, Program_Batch__c, Program_Name_Display__c, School_Name__c,
                       Applicant_Category__c, Application_Number_Prefix__c
                FROM Fee_Master__c
                WHERE Program_Name_Display__c IN :programNameKeysForFallback
                AND Fee_Type__c = :FEE_TYPE_APPLICATION
                AND IsActive__c = true
                ORDER BY Application_Number_Prefix__c DESC
            ];
 
            for (SObject rec : unassignedRecs) {
                Id existingBatchId2 = (Id) rec.get('Program_Batch__c');
                if (existingBatchId2 != null) continue;
 
                Boolean isLead2 = (rec.getSObjectType() == Lead.sObjectType);
                String pName = isLead2 ? (String) rec.get('Program_Name_Display__c') : (String) rec.get('Program_Name__c');
                String sName = (String) rec.get('School_Name__c');
                String selCategory = (String) rec.get('Select_Category__c');
                if (String.isBlank(pName)) continue;
 
                String feeMasterCategory = resolveFeeMasterCategory(selCategory);
                String sNameLower = sName != null ? sName.trim().toLowerCase() : '';
 
                for (Fee_Master__c fm : feeMasterCandidates) {
                    if (fm.Program_Name_Display__c != pName) continue;
                    if (fm.Applicant_Category__c != feeMasterCategory) continue;
                    String fmSchoolLower = fm.School_Name__c != null ? fm.School_Name__c.toLowerCase() : '';
                    if (String.isNotBlank(sNameLower) && !fmSchoolLower.contains(sNameLower)) continue;
                    if (fm.Program_Batch__c == null) continue;
 
                    recordIdToResolvedBatchIdMap.put((Id) rec.get('Id'), fm.Program_Batch__c);
                    programBatchIds.add(fm.Program_Batch__c);
                    break;
                }
            }
        }
 
        // Step 2: Query Program_Batch__c to get Group__c, School__c and Select_Counselors__c
        // (now includes both directly-referenced Ids AND Ids resolved via Fee_Master__c above)
        if (!programBatchIds.isEmpty()) {
            for (hed__Program_Plan__c	 programBatch : [
                SELECT Id, Name, Group__c, School__c, Select_Counselors__c, Active__c
                FROM hed__Program_Plan__c
                WHERE Id IN :programBatchIds
            ]) {
                programBatchGroupMap.put(programBatch.Id, programBatch.Group__c);
                programBatchByIdMap.put(programBatch.Id, programBatch);
            }
        }
 
        // Collect FederationIdentifiers from ALL matched batches
        Set<String> allCounselorFedIds = new Set<String>();
        for (hed__Program_Plan__c pb : programBatchByIdMap.values()) {
            if (pb.Select_Counselors__c != null) {
                for (String fid : pb.Select_Counselors__c.split(';')) {
                    if (String.isNotBlank(fid)) allCounselorFedIds.add(fid.trim());
                }
            }
        }
 
        if (!allCounselorFedIds.isEmpty()) {
            for (User u : [SELECT Id, FederationIdentifier FROM User
                            WHERE FederationIdentifier IN :allCounselorFedIds AND IsActive = true]) {
                counselorFedIdToUserIdMap.put(u.FederationIdentifier, u.Id);
            }
        }
        // ===== END NEW =====
        
        // Step 2: Query hed__Program_Plan__c records matching those keys and current year
        String currentYear = String.valueOf(Date.today().year());
       
        
        if (!programNameKeys.isEmpty()) {
            
            for (Fee_Master__c plan : [
                SELECT Id, Name,Program_Name__c,Program_Batch__r.Group__c,Program_Name_Display__c
                FROM Fee_Master__c                
                WHERE Enrolment_Year__c = :currentYear AND Program_Name_Display__c  = :programNameKeys and Fee_Type__c ='Application Fee' and Applicant_Category__c ='Indian (SAARC)'
            ]) {
                programPlanMap.put(plan.Program_Name_Display__c, plan.Program_Batch__r.Group__c);
            }
        }
        
        
        return unassignedRecs;  
    }
    
    //Execute method
    public void Execute(Database.BatchableContext bContext, List<sObject> unassignedRecs) {
        System.debug('****** Inside Execute ******');
        System.debug('unassignedRecs' + unassignedRecs);
        //List<lead> leadsList  = unassignedRecs[0];
        for(Sobject s : unassignedRecs){
            System.debug('\n1Leads:'+ s);//+ '-' + l.Name + '-' + l.utm_campaign__c + '-' + l.utm_medium__c);
        }
        System.debug('Total unassign records size:'+ unassignedRecs.size());
        //Integer index = initialIndex;  //Set next counselor index to initial index
         
       // System.debug('initialIndex:'+ index);
        List<sObject> recsToBeAssigned = new List<sObject>(); //Collection of all comon records   
        LeadAssignmentSetting__c setting = LeadAssignmentSetting__c.getValues('Admission_Counselor');
        
        Integer index = -1;
        if (setting != null && setting.Last_Assigned_Index__c != null) {
            index = setting.Last_Assigned_Index__c.intValue();
        }
        Set<Id> assignedUserIds = new Set<Id>();
        for(SObject rec : unassignedRecs){
            String assignedUsers = (String)rec.get('Assigned_Users__c');
            if(assignedUsers != null && assignedUsers.length() >= 18){
                assignedUserIds.add((Id)assignedUsers.left(18));
            }
        }

        Map<Id,User> userMap = new Map<Id,User>();
        if(!assignedUserIds.isEmpty()){
            userMap = new Map<Id,User>(
                [SELECT Id, IsActive FROM User WHERE Id IN :assignedUserIds]
            );
        }

        for (sObject unassignedRec : unassignedRecs) {
            string objectType= string.ValueOf(unassignedRec.getsObjectType()); //Get Object type from current record
            
            // 🔥 HANDLE REVA PUBLISHER LEADS FIRST
           /* if (objectType == 'Lead') {
                
                String createdByProfile = ((Lead)unassignedRec).Owner.Profile.Name;
                
                if (createdByProfile == 'REVA Publisher') {
                    
                    // unassignedRec.put(Lead.ownerId, ruUniversityUserId);
                    // unassignedRec.put(Lead.Assigned__c, true);
                    // unassignedRec.put(Lead.Check_OwnerChnage__c, true);
                    unassignedRec.put(Lead.Status, 'Unverified');
                    recsToBeAssigned.add(unassignedRec);
                    
                  //  continue; 
                }
            }*/

            DateTime createDate = (dateTime)unassignedRec.get('CreatedDate'); //Get created date from current record
            String selectCategory = (String)unassignedRec.get('Select_Category__c'); //Get Category from current record 
            String schoolName = (String)unassignedRec.get('School_Name__c'); //Get school name from current record
            String ProgramBatch = (String)unassignedRec.get('Program_Batch__c');
            Id currentOwnerId = (Id)unassignedRec.get('OwnerId');
            String programNameDisplay;
            String  programName;
            if (objectType=='Lead') {
                programNameDisplay = (String)unassignedRec.get('Program_Name_Display__c'); //Get program name from current lead record
            } else {
                programName= (String)unassignedRec.get('Program_Name__c'); //Get Program name from current contact record
            }
            String assignedUsers = (String)unassignedRec.get('Assigned_Users__c'); //Get assigned users for the current record
            
            
            system.debug('record username '+unassignedRec);
            system.debug('assignedUsers '+assignedUsers);
            DateTime comparisonDate = createDate.addMinutes(timeDelay); //Adding delay time to the CreatDate field
            
            if (SPECIFIC_CATEGORY.contains(selectCategory) || 
                //schoolName == SPECIFIC_SCHOOL || 
                ( leadProgramTypeMap.get(programNameDisplay)==SPECIFIC_PROGRAM_TYPE || 
                 contactProgramTypeMap.get(programName)==SPECIFIC_PROGRAM_TYPE ) || assignedUsers != null) {
                     String newOwner;
                     if ((objectType=='Contact' || objectType=='Lead') && SPECIFIC_CATEGORY.contains(selectCategory)) {
                         newOwner = foreignerCounselorId != null ? foreignerCounselorId : null;
                         assignedUsers = assignedUsers == null ? newOwner : assignedUsers + ',' + newOwner;
                         System.debug('inside if');
                     /*} else if ((objectType=='Contact' || objectType=='Lead') && schoolName == SPECIFIC_SCHOOL) {
                         newOwner = performingArtsCounselorId != null ? performingArtsCounselorId : null;
                         assignedUsers = assignedUsers == null ? newOwner : assignedUsers + ',' + newOwner;
                         System.debug('inside else if 1');*/
                     } else if ((objectType=='Lead' && leadProgramTypeMap.get(programNameDisplay)==SPECIFIC_PROGRAM_TYPE) ||
                                (objectType =='Contact' && contactProgramTypeMap.get(programName)==SPECIFIC_PROGRAM_TYPE)) {
                                    newOwner = PhdCounselorId != null ? PhdCounselorId : null;
                                    assignedUsers = assignedUsers == null ? newOwner : assignedUsers + ',' + newOwner;
                                    System.debug('inside else if 2');
                                } else if ((objectType=='Contact' || objectType=='Lead') && assignedUsers != null) {
                                    Id uid = (assignedUsers.length() >= 18)
                                         ? (Id)assignedUsers.left(18)
                                         : null;
                            
                                User us = userMap.get(uid);
                                    
                                    if(us != null && us.IsActive){
                                        newOwner =  uid;
                                    }
                                    System.debug('inside final else if');
                                }
                     System.debug(newOwner);
                     if(newOwner != null){
                         if (objectType=='Lead') {
                             unassignedRec.put(Lead.Assigned__c, True);
                             unassignedRec.put(Lead.Last_Assigned_Date__c, presentTime);
                             if (currentOwnerId != newOwner) {
                             unassignedRec.put(Lead.ownerId, newOwner);
                             unassignedRec.put(Lead.Assigned_Users__c, assignedUsers);
                             }
                             system.debug('inside if lead assigned user not null '+newOwner);
                             recsToBeAssigned.add(unassignedRec); 
                             System.debug('unassignedRec::'+unassignedRec);
                         } else {
                             unassignedRec.put(Contact.Assigned__c, True);
                             unassignedRec.put(Contact.Last_Assigned_Date__c, presentTime);
                             if (currentOwnerId != newOwner) {
                             unassignedRec.put(Contact.ownerId, newOwner);
                             unassignedRec.put(Contact.Assigned_Users__c, assignedUsers);
                             }
                             system.debug('inside else contact assigned user not null '+newOwner);
                             recsToBeAssigned.add(unassignedRec); 
                             System.debug('unassignedRec::'+unassignedRec);
                         }
                     }
                 }
            
            
             // program batch(A,B,C,D) group round robin below
              /* else{ 
                     String groupPicklistValue = null;
                    if (ProgramBatch != null) {
                        groupPicklistValue = programBatchGroupMap.get((Id)unassignedRec.get('Program_Batch__c'));
                    } else if (programNameDisplay != null) {
                        groupPicklistValue = programPlanMap.get(programNameDisplay);
                    }
                     if (groupPicklistValue != null) {
                List<GroupMember> groupMembersList = groupMembersMap.get(groupPicklistValue);
                
                if (groupMembersList != null && !groupMembersList.isEmpty()) {
                    
                    // NEW CHECK: Is current owner already a member of this group?
                    Boolean isOwnerAlreadyInGroup = false;
                    for (GroupMember gm : groupMembersList) {
                        if (gm.UserOrGroupId == currentOwnerId) {
                            isOwnerAlreadyInGroup = true;
                            break;
                        }
                    }

                    if (isOwnerAlreadyInGroup) {
                        // If same group person is already owner, just mark as assigned
                        unassignedRec.put('Assigned__c', true);
                        unassignedRec.put('Last_Assigned_Date__c', presentTime);
                        recsToBeAssigned.add(unassignedRec);
                        System.debug('Manual Assignment detected. Owner already in group. Skipping Round-Robin.');
                    } else {
                        // Proceed with Round-Robin if owner is not in group
                        LeadAssignmentSetting__c assignmentSetting = LeadAssignmentSetting__c.getValues(groupPicklistValue);
                        Integer lastIndex = (assignmentSetting != null && assignmentSetting.Last_Assigned_Index__c != null) 
                            ? assignmentSetting.Last_Assigned_Index__c.intValue() : -1;

                        Integer nextIndex = lastIndex + 1;
                        if (nextIndex >= groupMembersList.size()) {
                            nextIndex = 0; 
                        }
                        
                        Id assignedUserId = groupMembersList[nextIndex].UserOrGroupId;

                        unassignedRec.put('Assigned__c', true);
                        unassignedRec.put('Last_Assigned_Date__c', presentTime);
                        unassignedRec.put('OwnerId', assignedUserId);
                        unassignedRec.put('Assigned_Users__c', String.valueOf(assignedUserId));
                        
                        recsToBeAssigned.add(unassignedRec); 

                        // Update Round-Robin Custom Setting
                        if (assignmentSetting == null) {
                            assignmentSetting = new LeadAssignmentSetting__c(
                                Name = groupPicklistValue
                            );
                        }
                        
                        assignmentSetting.Last_Assigned_Index__c = nextIndex;
                        settingsToUpsert.put(groupPicklistValue, assignmentSetting);
                    }
                }
            }
         }*/
           
            
         // All counselor group round robin  below        
          /*  else {
                    //Check if index needs to be reset 
                    if (index >= counselors.Size() || index == -1) {
                        index = 0;
                    } 
                    //if (comparisonDate < presentTime) {
                if (objectType=='Lead') {
                    String createdByProfile = ((Lead)unassignedRec).Owner.Profile.Name;
                    
                    if (createdByProfile == 'REVA Publisher') {     
                        unassignedRec.put(Lead.Status, 'Unverified');
                    }
                            unassignedRec.put(Lead.Assigned__c, True);
                            unassignedRec.put(Lead.Last_Assigned_Date__c, presentTime);
                            unassignedRec.put(Lead.ownerId, counselors[index].UserOrGroupId);
                            unassignedRec.put(Lead.Assigned_Users__c, counselors[index].UserOrGroupId);
                            system.debug('inside if lead assigned user null index calculation'+counselors[index].UserOrGroupId);
                            recsToBeAssigned.add(unassignedRec); 
                            System.debug('unassignedRec::'+unassignedRec);
                        } else {
                            unassignedRec.put(Contact.Assigned__c, True);
                            unassignedRec.put(Contact.Last_Assigned_Date__c, presentTime);
                            unassignedRec.put(Contact.ownerId, counselors[index].UserOrGroupId);
                            unassignedRec.put(Contact.Assigned_Users__c, counselors[index].UserOrGroupId);
                            system.debug('inside else contact assigned user null index calculation'+counselors[index].UserOrGroupId);
                            recsToBeAssigned.add(unassignedRec);
                           System.debug('unassignedRec::'+unassignedRec);
                        }
                        index++;
                    //} 
                }
            
      }
        
        finalIndex = index; 
        if (!recsToBeAssigned.isEmpty()) {
            Database.update(recsToBeAssigned, false);
            noOfRecordsProcessed += recsToBeAssigned.size();
        }
        
    if (setting == null) {
        setting = new LeadAssignmentSetting__c(Name = 'Admission_Counselor');
    }

    setting.Last_Assigned_Index__c = index;

    upsert setting Name;*/

            // ===================================================================
            // NEW LOGIC: Program Batch (hed__Program_Plan__c.Select_Counselors__c) -> Counselor
            // ===================================================================
            else {
                Id pbId = (Id) unassignedRec.get('Program_Batch__c');
                hed__Program_Plan__c matchedBatch = null;
                
                if (pbId != null) {
                    matchedBatch = programBatchByIdMap.get(pbId);
                } else {
                    Id resolvedBatchId = recordIdToResolvedBatchIdMap.get((Id) unassignedRec.get('Id'));
                    if (resolvedBatchId != null) {
                        matchedBatch = programBatchByIdMap.get(resolvedBatchId);
                    }
                    System.debug('No Program_Batch__c on record ' + unassignedRec.get('Id')
                        + ', resolved via Fee_Master__c to batch: ' + (matchedBatch != null ? String.valueOf(matchedBatch.Id) : 'none'));
                }
 
                Id ownerToAssign = null;
 
                if (matchedBatch != null && String.isNotBlank(matchedBatch.Select_Counselors__c)) {
                    List<Id> mappedCounselorIds = new List<Id>();
                    for (String fid : matchedBatch.Select_Counselors__c.split(';')) {
                        if (String.isNotBlank(fid)) {
                            Id uId = counselorFedIdToUserIdMap.get(fid.trim());
                            if (uId != null) {
                                mappedCounselorIds.add(uId);
                            }
                        }
                    }
 
                    if (!mappedCounselorIds.isEmpty()) {
                        if (mappedCounselorIds.size() == 1) {
                            // Only ONE counselor mapped -> direct assignment, no round robin
                            ownerToAssign = mappedCounselorIds[0];
                            System.debug('Direct assign (single counselor) for batch ' + matchedBatch.Id + ': ' + ownerToAssign);
                        } else {
                            // MULTIPLE counselors mapped -> round robin, scoped per Program Batch
                            String pbSettingKey = 'PB_' + matchedBatch.Id;
                            LeadAssignmentSetting__c pbSetting = pbSettingsToUpsert.get(pbSettingKey);
                            if (pbSetting == null) {
                                pbSetting = LeadAssignmentSetting__c.getValues(pbSettingKey);
                            }
                            Integer lastIndex = (pbSetting != null && pbSetting.Last_Assigned_Index__c != null)
                                ? pbSetting.Last_Assigned_Index__c.intValue() : -1;
                            Integer nextIndex = lastIndex + 1;
                            if (nextIndex >= mappedCounselorIds.size()) {
                                nextIndex = 0;
                            }
                            ownerToAssign = mappedCounselorIds[nextIndex];
                            System.debug('Round robin for batch ' + matchedBatch.Id + ', index ' + nextIndex + ': ' + ownerToAssign);
 
                            if (pbSetting == null) {
                                pbSetting = new LeadAssignmentSetting__c(Name = pbSettingKey);
                            }
                            pbSetting.Last_Assigned_Index__c = nextIndex;
                            pbSettingsToUpsert.put(pbSettingKey, pbSetting);
                        }
                    }
                }
              system.debug('ownerToAssign'+ownerToAssign);
                if (ownerToAssign == null) {
                    // No Program Batch match, or no counselor resolved -> fallback to Admission_Counselor group round robin
                    if (index >= counselors.size() || index == -1) {
                        index = 0;
                    }
                    if (!counselors.isEmpty()) {
                        ownerToAssign = counselors[index].UserOrGroupId;
                        System.debug('No Program Batch counselor found, using group fallback: ' + ownerToAssign);
                        index++;
                    } else {
                        System.debug('WARNING: Admission_Counselor group empty - record remains unassigned!');
                    }
                }
 
                if (ownerToAssign != null) {
                    if (objectType == 'Lead') {
                        String createdByProfile = ((Lead)unassignedRec).Owner.Profile.Name;
                        if (createdByProfile == 'REVA Publisher') {
                            unassignedRec.put(Lead.Status, 'Unverified');
                        }
                        unassignedRec.put(Lead.Assigned__c, True);
                        unassignedRec.put(Lead.Last_Assigned_Date__c, presentTime);
                        unassignedRec.put(Lead.ownerId, ownerToAssign);
                        unassignedRec.put(Lead.Assigned_Users__c, ownerToAssign);
                        recsToBeAssigned.add(unassignedRec);
                    } else {
                        unassignedRec.put(Contact.Assigned__c, True);
                        unassignedRec.put(Contact.Last_Assigned_Date__c, presentTime);
                        unassignedRec.put(Contact.ownerId, ownerToAssign);
                        unassignedRec.put(Contact.Assigned_Users__c, ownerToAssign);
                        recsToBeAssigned.add(unassignedRec);
                    }
                }
            }
 
      } // closes for(sObject unassignedRec : unassignedRecs)
 
        finalIndex = index;
        System.debug('recsToBeAssigned: ' + recsToBeAssigned);
 
        // ===== Save all computed assignments, with per-record success/failure logging =====
        if (!recsToBeAssigned.isEmpty()) {
            List<Database.SaveResult> results = Database.update(recsToBeAssigned, false);
            noOfRecordsProcessed += recsToBeAssigned.size();
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    System.debug('UPDATE SUCCESS: ' + recsToBeAssigned[i].Id);
                } else {
                    for (Database.Error err : results[i].getErrors()) {
                        System.debug('UPDATE FAILED for ' + recsToBeAssigned[i].Id
                            + ' | StatusCode: ' + err.getStatusCode()
                            + ' | Message: ' + err.getMessage());
                    }
                }
            }
        }
 
    if (setting == null) {
        setting = new LeadAssignmentSetting__c(Name = 'Admission_Counselor');
    }
 
    setting.Last_Assigned_Index__c = index;
 
    upsert setting Name;
 
        // Persist Program Batch specific round-robin pointers
        if (!pbSettingsToUpsert.isEmpty()) {
            upsert pbSettingsToUpsert.values() Name;
        }
    }
    
    //Finish method
    public void Finish(Database.BatchableContext leadContext) {
         System.debug('****** Inside Finish ******');
       
    }
}