public class LeadAssignmentTriggerHandler {
    
    private static final List<String> SPECIFIC_CATEGORY = new List<String>{'Foreign Nationals','Indian (SAARC)','SAARC','Non-Resident Indian(NRI)'};
        
    private static final String SPECIFIC_PROGRAM_TYPE = 'Ph.D';
    private static final String FEE_TYPE_APPLICATION = 'Application Fee';
    public static String ApplicantName;
    public static String ApplicationNumber;
    public static String CounselorName;
    public static String StudentMobile;
    public static String CounselorMobile;

    public static void assignCounselor(Set<Id> leadIds){

    List<Lead> leads = [
        SELECT Id, OwnerId, Select_Category__c,Program_Batch__c,School_Name__c,
               Program_Name_Display__c,
               Assigned__c, Assigned_Users__c
        FROM Lead
        WHERE Id = :leadIds
    ];

    if (leads.isEmpty()) return;

    // -------- Dedicated Counselors --------
    String foreignerFedId = (String) General_Setting__mdt.getInstance('FOREIGNER_COUNSELOR').Text_Value__c;
    String phdFedId = (String) General_Setting__mdt.getInstance('PHD_COUNSELOR').Text_Value__c;

    Id foreignerCounselorId;
    Id phdCounselorId;

    for (User u : [
        SELECT Id, FederationIdentifier
        FROM User
        WHERE FederationIdentifier IN :new List<String>{foreignerFedId, phdFedId}
        AND IsActive = true
    ]) {
        if (u.FederationIdentifier == foreignerFedId)
            foreignerCounselorId = u.Id;
        if (u.FederationIdentifier == phdFedId)
            phdCounselorId = u.Id;
    }

    // -------- Program Type Map (PhD) --------
   Map<String,String> programTypeMap = new Map<String,String>();
    for (Fee_Master__c fee : [
        SELECT Program_Name_Display__c, Program_Type__c
        FROM Fee_Master__c
        WHERE Program_Type__c = :SPECIFIC_PROGRAM_TYPE
    ]) {
        programTypeMap.put(fee.Program_Name_Display__c, fee.Program_Type__c);
    }

  /*   // -------- Get Admission Counselor Members --------
    List<GroupMember> members = [
        SELECT UserOrGroupId
        FROM GroupMember
        WHERE Group.DeveloperName = 'Admission_Counselor'
        AND UserOrGroup.IsActive = true
        ORDER BY UserOrGroupId
    ];

    if (members.isEmpty()) return;

    // 🔥 -------- USE SAME SETTING AS BATCH --------
    LeadAssignmentSetting__c setting = LeadAssignmentSetting__c.getValues('Admission_Counselor');

    Integer lastIndex = -1;
    if (setting != null && setting.Last_Assigned_Index__c != null) {
        lastIndex = setting.Last_Assigned_Index__c.intValue();
    }

    List<Lead> leadsToUpdate = new List<Lead>();

    for (Lead l : leads) {

        Id newOwner;

        // -------- 1️⃣ Foreign --------
        if (SPECIFIC_CATEGORY.contains(l.Select_Category__c)) {
            newOwner = foreignerCounselorId;
        }

        // -------- 2️⃣ PhD --------
        else if (programTypeMap.get(l.Program_Name_Display__c) == SPECIFIC_PROGRAM_TYPE) {
            newOwner = phdCounselorId;
        }

        // -------- 3️⃣ Round Robin --------
        else {
            lastIndex++;

            if (lastIndex >= members.size()) {
                lastIndex = 0;
            }

            newOwner = members[lastIndex].UserOrGroupId;
        }

        if (newOwner != null && newOwner != l.OwnerId) {
            l.OwnerId = newOwner;
            l.Assigned__c = true;
            l.Last_Assigned_Date__c = System.now();
            l.Assigned_Users__c = String.valueOf(newOwner);
            leadsToUpdate.add(l);
        }
    }

    // -------- Update Leads --------
    if (!leadsToUpdate.isEmpty()) {
        update leadsToUpdate;
    }

    // 🔥 -------- UPDATE SAME SETTING --------
    if (setting == null) {
        setting = new LeadAssignmentSetting__c(Name = 'Admission_Counselor');
    }

    setting.Last_Assigned_Index__c = lastIndex;

    upsert setting Name;*/

    // ===================================================================
    // NEW LOGIC: Program Batch (hed__Program_Plan__c.Select_Counselors__c) -> Counselor
    // Matches the logic used in LeadAssignment_Batch: Id-first, then Name+School fallback
    // ==================================================================
        
        
  
    Set<Id> programBatchIds = new Set<Id>();
    for (Lead l : leads) {
        if (l.Program_Batch__c != null) {
            programBatchIds.add(l.Program_Batch__c);
        }
    }
 system.debug('programBatchIds'+programBatchIds);
    Map<Id, hed__Program_Plan__c> programBatchByIdMap = new Map<Id, hed__Program_Plan__c>();
    if (!programBatchIds.isEmpty()) {
        for (hed__Program_Plan__c pb : [
            SELECT Id, Name, School__c, Select_Counselors__c, Active__c
            FROM hed__Program_Plan__c
            WHERE Id IN :programBatchIds
        ]) {
            programBatchByIdMap.put(pb.Id, pb);
        }
    }
 
    // Collect FederationIdentifiers from ALL matched batches, resolve to active User Ids
    Set<String> allCounselorFedIds = new Set<String>();
    for (hed__Program_Plan__c pb : programBatchByIdMap.values()) {
        if (pb.Select_Counselors__c != null) {
            for (String fid : pb.Select_Counselors__c.split(';')) {
                if (String.isNotBlank(fid)) allCounselorFedIds.add(fid.trim());
            }
        }
    }
 
    Map<String, Id> counselorFedIdToUserIdMap = new Map<String, Id>();
    if (!allCounselorFedIds.isEmpty()) {
        for (User u : [SELECT Id, FederationIdentifier FROM User
                        WHERE FederationIdentifier IN :allCounselorFedIds AND IsActive = true]) {
            counselorFedIdToUserIdMap.put(u.FederationIdentifier, u.Id);
        }
    }
 
    // -------- Get Admission Counselor Members (fallback pool) --------
    List<GroupMember> members = [
        SELECT UserOrGroupId
        FROM GroupMember
        WHERE Group.DeveloperName = 'Admission_Counselor'
        AND UserOrGroup.IsActive = true
        ORDER BY UserOrGroupId
    ];
 
    // 🔥 -------- USE SAME SETTING AS BATCH (fallback group round robin) --------
    LeadAssignmentSetting__c setting = LeadAssignmentSetting__c.getValues('Admission_Counselor');
    Integer lastIndex = -1;
    if (setting != null && setting.Last_Assigned_Index__c != null) {
        lastIndex = setting.Last_Assigned_Index__c.intValue();
    }
 
    // Settings for Program-Batch-specific round robin pointers (scoped by Program Batch Id)
    Map<String, LeadAssignmentSetting__c> pbSettingsToUpsert = new Map<String, LeadAssignmentSetting__c>();
 
    List<Lead> leadsToUpdate = new List<Lead>();
    for (Lead l : leads) {
        Id newOwner;
 
        // -------- 1️⃣ Foreign --------
        if (SPECIFIC_CATEGORY.contains(l.Select_Category__c)) {
            newOwner = foreignerCounselorId;
        }
        // -------- 2️⃣ PhD --------
        else if (programTypeMap.get(l.Program_Name_Display__c) == SPECIFIC_PROGRAM_TYPE) {
            newOwner = phdCounselorId;
        }
        // -------- 3️⃣ NEW: Program Batch mapping (direct assign or round robin) --------
        else {
            hed__Program_Plan__c matchedBatch = (l.Program_Batch__c != null)? programBatchByIdMap.get(l.Program_Batch__c) : null;
 
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
                        // Only ONE counselor mapped to this Program Batch -> direct assignment
                        newOwner = mappedCounselorIds[0];
                        System.debug('Direct assign (single counselor) for batch ' + matchedBatch.Id + ': ' + newOwner);
                    } else {
                        // MULTIPLE counselors mapped -> round robin, scoped per Program Batch
                        String pbSettingKey = 'PB_' + matchedBatch.Id;
                        LeadAssignmentSetting__c pbSetting = pbSettingsToUpsert.get(pbSettingKey);
                        if (pbSetting == null) {
                            pbSetting = LeadAssignmentSetting__c.getValues(pbSettingKey);
                        }
                        Integer pbLastIndex = (pbSetting != null && pbSetting.Last_Assigned_Index__c != null)
                            ? pbSetting.Last_Assigned_Index__c.intValue() : -1;
 
                        Integer pbNextIndex = pbLastIndex + 1;
                        if (pbNextIndex >= mappedCounselorIds.size()) {
                            pbNextIndex = 0;
                        }
                        newOwner = mappedCounselorIds[pbNextIndex];
                        System.debug('Round robin for batch ' + matchedBatch.Id + ', index ' + pbNextIndex + ': ' + newOwner);
 
                        if (pbSetting == null) {
                            pbSetting = new LeadAssignmentSetting__c(Name = pbSettingKey);
                        }
                        pbSetting.Last_Assigned_Index__c = pbNextIndex;
                        pbSettingsToUpsert.put(pbSettingKey, pbSetting);
                    }
                }
            }
 
            // -------- 4️⃣ Fallback: Admission_Counselor group round robin --------
            if (newOwner == null) {
                if (!members.isEmpty()) {
                    lastIndex++;
                    if (lastIndex >= members.size()) {
                        lastIndex = 0;
                    }
                    newOwner = members[lastIndex].UserOrGroupId;
                    System.debug('No Program Batch counselor found for Lead ' + l.Id + ', using group fallback: ' + newOwner);
                } else {
                    System.debug('WARNING: No Program Batch mapping AND Admission_Counselor group is empty - lead ' + l.Id + ' will remain unassigned!');
                }
            }
        }
 
        if (newOwner != null && newOwner != l.OwnerId) {
            l.OwnerId = newOwner;
            l.Assigned__c = true;
            l.Last_Assigned_Date__c = System.now();
            l.Assigned_Users__c = String.valueOf(newOwner);
            leadsToUpdate.add(l);
        }
    }
 
    // -------- Update Leads --------
    if (!leadsToUpdate.isEmpty()) {
        update leadsToUpdate;
    }
 
    // 🔥 -------- UPDATE SAME SETTING (group fallback pointer) --------
    if (setting == null) {
        setting = new LeadAssignmentSetting__c(Name = 'Admission_Counselor');
    }
    setting.Last_Assigned_Index__c = lastIndex;
    upsert setting Name;
 
    // -------- Persist Program Batch specific round-robin pointers --------
    if (!pbSettingsToUpsert.isEmpty()) {
        upsert pbSettingsToUpsert.values() Name;
    }
 

}
 

    


    
     public static void sendNotification(Id contactId) {

        if(contactId == null) return;

        // WhatsApp
       // sendWhatsAppStudent(contactId);
       // sendWhatsAppCounselor(contactId);

      // SMS
       // sendSMSAsync(contactId);
         
         //email
       // sendAssignmentEmail(contactId);
    }

    /* =========================================
       WHATSAPP METHOD
       ========================================= */
   /* @future(callout=true)
    public static void sendWhatsAppStudent(Id contactId) {

        Contact con = [
            SELECT Id, Name, MobilePhone,Phone,Program_Batch__r.Name,Application_Number__c, OwnerId
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];

        User counselor = [
            SELECT Id, Name,MobilePhone
            FROM User
            WHERE Id = :con.OwnerId
            LIMIT 1
        ];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();


        if(con.MobilePhone != null) {
            Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
            notification.templateId = 'walkin_applicant';
            notification.params = new Map<String, String>();
            
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :notification.templateId
            ];
             system.debug('helloo:'+templateMetadata);
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                  system.debug('helloo:'+keys);
                for (String key : keys) {
                   
                        if (key == 'appliacnt_name') {
                            notification.params.put(key, con.Name);
                        } else if (key == 'application_number') {
                            notification.params.put(key, con.Application_Number__c);
                        } else if (key == 'counselor_name') {
                            notification.params.put(key, counselor.Name);
                        }        
        }
                
                     List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                    
                   
                        String plusRemoved = con.MobilePhone.replace('+', '');
                        String correctedWhatsappNumber = plusRemoved.replace('-', '');
                        
                        if (!phoneNumbersToNotifications.containsKey(correctedWhatsappNumber)) {
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                        }
                  
            }
            
            }
          
       
            if (!phoneNumbersToNotifications.isEmpty()) {
                
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                
            }
    }

 @future(callout=true)
    public static void sendWhatsAppCounselor(Id contactId) {

        Contact con = [
            SELECT Id, Name, MobilePhone,Phone,Program_Batch__r.Name,Application_Number__c, OwnerId
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];

        User counselor = [
            SELECT Id, Name,MobilePhone
            FROM User
            WHERE Id = :con.OwnerId
            LIMIT 1
        ];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
          

        if(counselor.MobilePhone != null) {
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'walkin_counselor';
        notification.params = new Map<String, String>();
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [
            SELECT Template_Field__c, Template_ID__c 
            FROM WhatsApp_Notification_Template__mdt 
            WHERE Template_ID__c = :notification.templateId
        ];
        system.debug('helloo:'+templateMetadata);
        for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
            String[] keys = metadata.Template_Field__c.split(',');
            
            system.debug('helloo:'+keys);
            for (String key : keys) {
                
                if (key == 'counselor_name') {
                    notification.params.put(key, counselor.Name);
                } else if (key == 'applicant_name') {
                    notification.params.put(key, con.Name);
                } else if (key == 'application_number') {
                    notification.params.put(key, con.Application_Number__c);
                } else if (key == 'program_name') { 
                    notification.params.put(key,con.Program_Batch__r.Name);
                }        
                
            }
            
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                
                
                String plusRemoved = counselor.MobilePhone.replace('+', '');
            String correctedWhatsappNumber = plusRemoved.replace('-', '');
            
            if (!phoneNumbersToNotifications.containsKey(correctedWhatsappNumber)) {
                phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
            }
            
            
            
        }  
            
        }
            if (!phoneNumbersToNotifications.isEmpty()) {
                
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                
            }
    }

*/


/* =========================================
   MAIN METHOD (Similar to makeCalloutAsync)
   ========================================= */
/*@future(callout=true)
public static void sendSMSAsync(Id contactId) {

    System.debug('Contact Id => ' + contactId);

    Contact con = [
        SELECT Id, Name, Phone,mobilephone, OwnerId, Application_Number__c
        FROM Contact
        WHERE Id = :contactId
        LIMIT 1
    ];

    User counselor = [
        SELECT Id, Name, Phone,mobilephone
        FROM User
        WHERE Id = :con.OwnerId
        LIMIT 1
    ];

    // Assign Static Variables (Same style as your class)
    ApplicantName     = con.Name;
    ApplicationNumber = con.Application_Number__c;
    CounselorName     = counselor.Name;

      String PhoneNumbersmsStud;
        String plusRemoved = con.mobilephone.replace('+', '');
        String correctedWhatsappNumber = plusRemoved.replace('-', '');
        StudentMobile = correctedWhatsappNumber;
    
        String plusRemoved1 = counselor.mobilephone.replace('+', '');
        String correctedWhatsappNumber1 = plusRemoved1.replace('-', '');
        CounselorMobile = correctedWhatsappNumber1;

    List<SMS_API_Utility.shortMessageWrp> messageList =
        new List<SMS_API_Utility.shortMessageWrp>();


    if(StudentMobile != null){
        SmsToStudent(messageList);
          SMS_API_Utility.SendSMSOneToMany('walkin_applicant', messageList);
    }

    if(CounselorMobile != null){
        SmsToCounselor(messageList);
          SMS_API_Utility.SendSMSOneToMany('walkin_counselor', messageList);
    }

}

    */
/* =========================================
   STUDENT SMS METHOD
   ========================================= */
  /*  public static void SmsToStudent(List<SMS_API_Utility.shortMessageWrp> messageList){
        
        String message =
            'Hi ' + ApplicantName +', your walk-in registration at REVA University is confirmed. Application No: ' + ApplicationNumber +' Your counselor ' + CounselorName + ' has been assigned. Please contact to proceed with admission. Regards Team Admissions REVA University';
        
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007824254368030274';
        shrtMessage.message = message;
        shrtMessage.recipient = StudentMobile;
        
        messageList.add(shrtMessage);
    }
*/

/* =========================================
   COUNSELOR SMS METHOD
   ========================================= */
 /*   public static void SmsToCounselor(List<SMS_API_Utility.shortMessageWrp> messageList){
        
        String message =
           'Hi ' + CounselorName +', A new walk -in lead is assigned to you. Name: ' + ApplicantName + ' Application  No: ' + ApplicationNumber + ' Please contact the applicant to proceed. Regards Team Admissions REVA University';
        
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007737853149607469';
        shrtMessage.message = message;
        shrtMessage.recipient = CounselorMobile;
        
        messageList.add(shrtMessage);
        
    }
 
    

    public static void sendAssignmentEmail(Id contactId) {

        if(contactId == null) return;

        Contact con = [
            SELECT Id, Name, Email,Application_Number__c,Program_Batch__r.Name, OwnerId
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];

        User counselor = [
            SELECT Id, Name, Email
            FROM User
            WHERE Id = :con.OwnerId
            LIMIT 1
        ];
    OrgWideEmailAddress orgWide = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE DisplayName = 'REVA Alerts'
            LIMIT 1
        ];
        List<Messaging.SingleEmailMessage> emailList = 
            new List<Messaging.SingleEmailMessage>();

        if(con.Email != null){

            Messaging.SingleEmailMessage studentMail =
                new Messaging.SingleEmailMessage();

            studentMail.setToAddresses(new List<String>{con.Email});
            studentMail.setSubject('Counselor Assignment – REVA University');
             studentMail.setOrgWideEmailAddressId(orgWide.Id);
            String studentBody =
                'Dear ' + con.Name + ',\n\n' +
                'Greetings from REVA University!\n\n' +
                'Application No: ' + con.Application_Number__c + '\n' +
                'Assigned Counselor: ' + counselor.Name + '\n\n' +
                'Kindly contact your counselor to proceed with the application and admission process.\n\n' +
                'Regards,\n' +
                'Team Admissions\n' +
                'REVA University';

            studentMail.setPlainTextBody(studentBody);

            emailList.add(studentMail);
        }

         if(counselor.Email != null){

            Messaging.SingleEmailMessage counselorMail =
                new Messaging.SingleEmailMessage();

            counselorMail.setToAddresses(new List<String>{counselor.Email});
            counselorMail.setSubject('New Walk-in Lead Assigned – REVA University');
            counselorMail.setOrgWideEmailAddressId(orgWide.Id);
            String counselorBody =
                'Dear ' + counselor.Name + ',\n\n' +
                'Greetings from REVA University Admissions!\n\n' +
                'A new walk-in lead has been assigned to you. Please find the details below:\n\n' +
                'Applicant Details:\n' +
                '• Name: ' + con.Name + '\n' +
                '• Application Number: ' + con.Application_Number__c + '\n' +
                '• Programme: ' + con.Program_Batch__r.Name + '\n\n' +
                'Kindly reach out to the applicant at the earliest and proceed with the next steps in the application and admission process.\n\n' +
                'Regards,\n' +
                'Team Admissions\n' +
                'REVA University';

            counselorMail.setPlainTextBody(counselorBody);

            emailList.add(counselorMail);
        }

        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }
    }*/

}