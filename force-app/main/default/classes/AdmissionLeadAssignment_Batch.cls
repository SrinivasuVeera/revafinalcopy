public class AdmissionLeadAssignment_Batch implements Database.Batchable<sObject>, Database.Stateful {
    //Post deployment steps
    /*AdmissionLeadAssignment_Batch sch = new AdmissionLeadAssignment_Batch();
    System.schedule('Lead assignment schedule - I', '0 00 * * * ? ' , sch);
    System.schedule('Lead assignment schedule - II', '0 15 * * * ? ' , sch);
    System.schedule('Lead assignment schedule - III', '0 30 * * * ? ' , sch);
    System.schedule('Lead assignment schedule - IV', '0 45 * * * ? ' , sch);*/
    public string query;
    private Integer initialIndex;
    private Integer finalIndex;
    private Integer noOfRecordsProcessed = 0;
    private Integer timeDelay = (Integer) Batch_Config__mdt.getInstance('Lead_Assignment_Time_Delay_in_minutes').Time__c; //Get delay time 
    private dateTime presentTime = System.now();  //Get present time 
    public List<GroupMember> counselors = new List<GroupMember>();
    private List<Fee_Master__c> feeMasterProgramList;
    List<String> SPECIFIC_CATEGORY = new List<String>{'Foreign Nationals','Indian (SAARC)','SAARC','Non-Resident Indian(NRI)'}; //Lead/Contact Category 
    private static final String SPECIFIC_SCHOOL = 'School of Performing Arts and Indic Studies'; //Lead/Contact School 
    private static final String SPECIFIC_PROGRAM_TYPE = 'Ph.D'; //Lead/Contact Program type
    private static String foreignerCounselorFedId = (String) General_Setting__mdt.getInstance('FOREIGNER_COUNSELOR').Text_Value__c; //Get Foreign nationals counselor mail Id
    private static String perArtsCounselorFedId = (String) General_Setting__mdt.getInstance('PERFORMING_ARTS_COUNSELOR').Text_Value__c; //Get Performing arts counselor maild Id
    private static String phdProgramCounselorFedId = (String) General_Setting__mdt.getInstance('PHD_COUNSELOR').Text_Value__c; //Get Ph.d counselor maild Id
    private Id foreignerCounselorId = null;
    private Id performingArtsCounselorId = null;
    private Id PhdCounselorId = null;
    private Map<String, String> leadProgramTypeMap = New Map<String, String>();
    private Map<String, String> contactProgramTypeMap = New Map<String, String>();
    public Map<String,GroupMember> userIds = new Map<String,GroupMember>();
    private Integer initialCount;
    private Integer finalCount;

    private  void getSpecificCounselor() {
        //Get User Id from users by matching FederationIdentifier
        List<User> foreignerCounselor = [SELECT Id, FederationIdentifier, isactive FROM User 
                                    Where FederationIdentifier = :foreignerCounselorFedId and isactive = true Limit 1];
        List<User> perArtsCounselor = [SELECT Id, FederationIdentifier, isactive FROM User 
                                    Where FederationIdentifier = :perArtsCounselorFedId and isactive = true  Limit 1];
        List<User> phdProgramCounselor = [SELECT Id, FederationIdentifier, isactive FROM User 
                                    Where FederationIdentifier = :phdProgramCounselorFedId and isactive = true Limit 1];
        if(!foreignerCounselor.isEmpty()){
            foreignerCounselorId = foreignerCounselor[0].Id;
        } 
        if (!perArtsCounselor.isEmpty()){
            performingArtsCounselorId = perArtsCounselor[0].Id;
        } 
        if (!phdProgramCounselor.isEmpty()){
            PhdCounselorId = phdProgramCounselor[0].Id;
        }
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
    System.debug('gm1 '+gm1.UserOrGroupId);
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
        unassignedRecs.addAll([Select id, utm_campaign__c, utm_medium__c, Name, Phone, Assigned__c, OwnerId, CreatedDate, Select_Category__c, 
                                School_Name__c, Program_Name_Display__c, Assigned_Users__c, 
                                Program_Name__c, Status From Lead 
                                Where Assigned__c = False
                               		And Status IN ('Unverified', 'Verified')
                              		And utm_campaign__c !='Third_Party_Admissions'  AND utm_medium__c!='Consultancy_2024' AND CreatedDate >= 2025-11-15T00:00:00Z ]);
       
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
        Integer index = initialIndex;  //Set next counselor index to initial index
        System.debug('initialIndex:'+ index);
        List<sObject> recsToBeAssigned = new List<sObject>(); //Collection of all comon records         
        for (sObject unassignedRec : unassignedRecs) {
            string objectType= string.ValueOf(unassignedRec.getsObjectType()); //Get Object type from current record
            DateTime createDate = (dateTime)unassignedRec.get('CreatedDate'); //Get created date from current record
            String selectCategory = (String)unassignedRec.get('Select_Category__c'); //Get Category from current record 
            String schoolName = (String)unassignedRec.get('School_Name__c'); //Get school name from current record
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
            
            if (SPECIFIC_CATEGORY.contains(selectCategory) || schoolName == SPECIFIC_SCHOOL || 
                   ( leadProgramTypeMap.get(programNameDisplay)==SPECIFIC_PROGRAM_TYPE || 
                   contactProgramTypeMap.get(programName)==SPECIFIC_PROGRAM_TYPE ) || assignedUsers != null) {
                String newOwner;
                if ((objectType=='Contact' || objectType=='Lead') && SPECIFIC_CATEGORY.contains(selectCategory)) {
                    newOwner = foreignerCounselorId != null ? foreignerCounselorId : null;
                     assignedUsers = assignedUsers == null ? newOwner : assignedUsers + ',' + newOwner;
                     System.debug('inside if');
                } else if ((objectType=='Contact' || objectType=='Lead') && schoolName == SPECIFIC_SCHOOL) {
                    newOwner = performingArtsCounselorId != null ? performingArtsCounselorId : null;
                     assignedUsers = assignedUsers == null ? newOwner : assignedUsers + ',' + newOwner;
                     System.debug('inside else if 1');
                } else if ((objectType=='Lead' && leadProgramTypeMap.get(programNameDisplay)==SPECIFIC_PROGRAM_TYPE) ||
                            (objectType =='Contact' && contactProgramTypeMap.get(programName)==SPECIFIC_PROGRAM_TYPE)) {
                    newOwner = PhdCounselorId != null ? PhdCounselorId : null;
                     assignedUsers = assignedUsers == null ? newOwner : assignedUsers + ',' + newOwner;
                     System.debug('inside else if 2');
                } else if ((objectType=='Contact' || objectType=='Lead') && assignedUsers != null) {
                    String uid = assignedUsers?.left(18);
                    User us = [Select id, name, isactive FROM User where id =: uid];
                    if(us != null){
                        newOwner =  assignedUsers?.left(18);
                    }
                    System.debug('inside final else if');
                }
                    System.debug(newOwner);
                    if(newOwner != null){
                        if (objectType=='Lead') {
                            unassignedRec.put(Lead.Assigned__c, True);
                            unassignedRec.put(Lead.Last_Assigned_Date__c, presentTime);
                            unassignedRec.put(Lead.ownerId, newOwner);
                            unassignedRec.put(Lead.Assigned_Users__c, assignedUsers);
                            system.debug('inside if lead assigned user not null '+newOwner);
                            recsToBeAssigned.add(unassignedRec); 
                             System.debug('unassignedRec::'+unassignedRec);
                        }
                    }
            } else {
                    //Check if index needs to be reset 
                    if (index >= counselors.Size() || index == -1) {
                        index = 0;
                    } 
                    //if (comparisonDate < presentTime) {
                        if (objectType=='Lead') {
                            unassignedRec.put(Lead.Assigned__c, True);
                            unassignedRec.put(Lead.Last_Assigned_Date__c, presentTime);
                            unassignedRec.put(Lead.ownerId, counselors[index].UserOrGroupId);
                            unassignedRec.put(Lead.Assigned_Users__c, counselors[index].UserOrGroupId);
                            system.debug('inside if lead assigned user null index calculation'+counselors[index].UserOrGroupId);
                            recsToBeAssigned.add(unassignedRec); 
                            System.debug('unassignedRec::'+unassignedRec);
                        } 
                        index++;
                    //} 
                }
        }
    
        finalIndex = index; 
        if (!recsToBeAssigned.isEmpty()) {
            // update recsToBeAssigned;
            Database.update(recsToBeAssigned, false);
            System.debug('Update');          
            noOfRecordsProcessed += recsToBeAssigned.size();
        }
    }
    //Finish method
    public void Finish(Database.BatchableContext leadContext) {
        // System.debug('****** Inside Finish ******');
        // System.debug('Intial index is: ' + initialIndex);
        // System.debug('Final index is: ' + finalIndex);
        // System.debug('Total records processed are: ' + noOfRecordsProcessed);
        if (noOfRecordsProcessed > 0) {
            RegistrationProcessUtility.setCounselorIndex(finalIndex);
        }
        System.debug('batch apex has been finished');
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage usermail = new Messaging.SingleEmailMessage();   
        List<OrgWideEmailAddress> EmailAddress=[SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts']; 
        usermail.setOrgWideEmailAddressId(EmailAddress[0].Id);
        List<String> sendToAdd = new List<String>();
        sendToAdd.add('lalkumar.baburao@cloudodyssey.co');
        usermail.setToAddresses(sendToAdd);   
        usermail.setSubject('Lead ownership assignment ' + System.now());
        String body1='' ;        
        body1 = 'Lead ownership assignment  done '  + System.now();
        // body1 += 'Intial index is: ' + initialIndex;
        // body1 += 'Final index is: ' + finalIndex;
        usermail.setHtmlBody(body1);
        mails.add(usermail);  
        // Messaging.sendEmail(mails);
    }
}