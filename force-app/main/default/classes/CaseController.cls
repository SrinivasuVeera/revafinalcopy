public without sharing class CaseController {
    //public with sharing class CaseController{
    
    @AuraEnabled
    public static Id createCase(String category, String subCategory, String urgency, String description, String severity, String contactId) {
        Case newCase = new Case();
        newCase.INFRA_Category__c = category;
        newCase.INFRA_Sub_Category__c = subCategory;
        newCase.Urgency__c = urgency;
        newCase.Description__c = description;
        newCase.Severity__c = severity;
        newCase.ContactId = contactId;
        
        insert newCase;
        System.debug('newcase.id: '+ newCase.Id);
        return newCase.Id;
    }
    
    // Method to fetch the REVA Hostel Support Request record type
    @AuraEnabled(cacheable=true)
    public static Id getRevaHostelSupportRecordTypeId() {
        Id recordTypeId;
        List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'REVA_Hostel_Support_Request' LIMIT 1];
        if (!rtList.isEmpty()) {
            recordTypeId = rtList[0].Id;
        }
        return recordTypeId;
    }
    
    // Method to create a new case for the REVA Hostel Support Request record type
    @AuraEnabled
    public static Id createRevaHostelSupportCase(String subject, String description, String priority, String supportCategory, String hostelSubCategory,List<String> generalComplaints,String filename, String base64) {
        Id recordTypeId = getRevaHostelSupportRecordTypeId();
        if (recordTypeId != null) {
            // Retrieve existing hostel request details
            Reva_Hostel_Request__c existingHostelRequest = getExistingHostelRequest();
            
            // Create a new Case with hostel block set to the existing hostel request's block
            Case newCase = new Case(
                RecordTypeId = recordTypeId,
                Priority = priority,
                Description = description,
                Status = 'New',
                Hostel_Category__c = supportCategory,
                Hostel_Block__c = existingHostelRequest.Block__c,
                Hostel_Sub_Category__c = hostelSubCategory,
                REVA_Hostel_Request__c = getExistingHostelRequest().id
                
            );
            if (generalComplaints != null && !generalComplaints.isEmpty()) {
                newCase.Support_Case_Complaints__c = String.join(generalComplaints, ';');
            }
            insert newCase;
            
            // Upload attachment
            if (String.isNotBlank(filename) && String.isNotBlank(base64)) {
                uploadFile(base64, filename, newCase.Id);
            }
            
            return newCase.Id;
        } else {
            // Handle case where no record type is found
            // You may want to log an error or handle it according to your requirements
            return null;
        }
    }
    
    
    
    // Method to get the existing hostel request for the current user
    /********************************************Working one******************************************************/
    /*@AuraEnabled(cacheable=true)
    public static Reva_Hostel_Request__c getExistingHostelRequest() {
        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        return [SELECT Id, Name, Room_Number__c, Type__c, Reva_Hostel_Premium_Room__c, Status__c, Block__c, Reva_Hostel_Room__c
                FROM Reva_Hostel_Request__c
                WHERE Hostel_Room_Request_For__c = :contactId 
                LIMIT 1];            
    }*/
    @AuraEnabled(cacheable=true)
    public static Reva_Hostel_Request__c getExistingHostelRequest() {
       User currentUser = [SELECT Id, ContactId, Email, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        Id contactId;
        if (currentUser.Profile.Name == 'Student Profile' || currentUser.Profile.Name == 'Non Teaching Profile' || currentUser.Profile.Name =='Student Portal Profile') {
            contactId = currentUser.ContactId;
        } else if (currentUser.Profile.Name == 'Professor') {
            Contact contact = [SELECT Id FROM Contact WHERE Email = :currentUser.Email LIMIT 1];
            contactId = contact.Id;
        } 
        return [SELECT Id, Name, Room_Number__c, Type__c, Reva_Hostel_Premium_Room__c, Status__c, Block__c, Reva_Hostel_Room__c
                FROM Reva_Hostel_Request__c
                WHERE Hostel_Room_Request_For__c = :contactId and Status__c =:'Room Allotted'
                LIMIT 1];
    
    }
    /******************************************************************************************/
    
    // Method to get a list of all REVA Hostel Support Request related case records for a particular user
    @AuraEnabled(cacheable=true)
    public static list<case> getRevaHostelSupportCasesForUser(Id userId) {
        casewrapper wrapper = new casewrapper();
        Id recordTypeId = getRevaHostelSupportRecordTypeId();
        if (recordTypeId != null) {
            return [SELECT Id, CaseNumber, Description,Status,Hostel_Category__c,Hostel_Sub_Category__c,Priority,Hostel_Block__c,CreatedDate 
                    FROM Case WHERE RecordTypeId = :recordTypeId AND CreatedById = :userId ORDER BY CreatedDate DESC];
            //wrapper.caseattachments =[Select Id,ContentDocument.Title from ContentDocumentLink  where  LinkedEntityId =:wrapper.studentCase[0].Id];
            //return wrapper;
        }
        return NULL;
    }
    @AuraEnabled(cacheable=true)
    public static list<case> getRevaHostelSupportCasesForNonTeachingUser(Id userId) {
        casewrapper wrapper = new casewrapper();
        Id recordTypeId = getRevaHostelSupportRecordTypeId();
        if (recordTypeId != null) {
            return [SELECT Id, CaseNumber, Description,Status,Hostel_Category__c,Hostel_Sub_Category__c,Priority,Hostel_Block__c,CreatedDate , CreatedBy.Name, Owner.Name
                    FROM Case WHERE RecordTypeId = :recordTypeId AND (CreatedById = :userId OR OwnerId =:userId) ORDER BY CreatedDate DESC];
            //wrapper.caseattachments =[Select Id,ContentDocument.Title from ContentDocumentLink  where  LinkedEntityId =:wrapper.studentCase[0].Id];
            //return wrapper;
        }
        return NULL;
    }
    @AuraEnabled
    public static void updateCase(String openedCaseId, String hostelBlock, String status, String priority, 
                                  String hostelCategory, String subCategory, String description,String remarks,String filename, String base64) {
                                      System.debug('recordid'+ openedCaseId);
                                      System.debug('hostelblock'+ hostelBlock);
                                      System.debug('status'+ status);
                                      System.debug('priority'+ priority);
                                      System.debug('hostelCategory'+ hostelCategory);
                                      System.debug('subCategory'+ subCategory);
                                      System.debug('description'+ description);
                                      try {
                                          // Query for the Case record
                                          Case caseRecord = [SELECT Id, Hostel_Block__c, Status, Priority, Hostel_Category__c, Hostel_Sub_Category__c, Description,Remarks__c 
                                                             FROM Case 
                                                             WHERE Id = :openedCaseId 
                                                             LIMIT 1];
                                          
                                          // Check if a record was found
                                          if(caseRecord != null) {
                                              // Update the Case fields
                                              //caseRecord.Hostel_Block__c = hostelBlock;
                                              caseRecord.Status = status;
                                              caseRecord.Remarks__c = remarks;
                                              //caseRecord.Priority = priority;
                                              //caseRecord.Hostel_Category__c = hostelCategory;
                                              //caseRecord.Hostel_Sub_Category__c = subCategory;
                                              //caseRecord.Description = description;
                                              
                                              if (String.isNotBlank(filename) && String.isNotBlank(base64)) {
                                                  uploadFile(base64, filename, caseRecord.Id);
                                              }
            
                                              // Perform the update
                                              update caseRecord;
                                          } else {
                                              throw new AuraHandledException('No Case found with Id: ' + openedCaseId);
                                          }
                                      } catch (Exception e) {
                                          throw new AuraHandledException('Error updating case: ' + e.getMessage());
                                      }
                                  }
    /*****************************************working one********************************************************************/
    // Fetch attachments related to a specific case
    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getCaseAttachments(String caseId) {
        System.debug('caseId--->' + caseId);
        return [SELECT Id, ContentDocument.Title, ContentDocument.FileExtension 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :caseId];
    }

    // Fetch the current user ID
    @AuraEnabled(cacheable=true)
    public static Id getCurrentUserId() {
        return UserInfo.getUserId();
    }

    // Upload a file
    @AuraEnabled(cacheable=false)
    public static String uploadFile(String base64, String filename, String recordId) {
        if (String.isBlank(base64) || String.isBlank(filename) || String.isBlank(recordId)) {
            System.debug('Missing parameters for file upload');
            return null;
        }
        
        ContentVersion cv = new ContentVersion(
            VersionData = EncodingUtil.base64Decode(base64),
            Title = filename,
            PathOnClient = filename
        );
        
        try {
            insert cv;
            
            // Create ContentDocumentLink
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
                LinkedEntityId = recordId,
                ShareType = 'V'
            );
            insert cdl;
            
            return cdl.Id;
        } catch (Exception e) {
            System.debug('Error uploading file: ' + e.getMessage());
            return null;
        }
    }

    // Fetch attachment content as Base64 encoded string
    @AuraEnabled(cacheable=true)
    public static String getAttachmentContent(String attachmentId) {
        String attachmentContent = null;
        
        try {
            List<ContentDocumentLink> documentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE Id = :attachmentId];
            
            if (!documentLinks.isEmpty()) {
                List<ContentVersion> contentVersions = [SELECT VersionData, FileType FROM ContentVersion WHERE ContentDocumentId = :documentLinks[0].ContentDocumentId LIMIT 1];
                
                if (!contentVersions.isEmpty()) {
                    Blob versionData = contentVersions[0].VersionData;
                    attachmentContent = EncodingUtil.base64Encode(versionData);
                }
            }
        } catch (Exception e) {
            System.debug('Error fetching attachment content: ' + e.getMessage());
        }
        
        return attachmentContent;
    }

    // Generate a URL for displaying the attachment
    @AuraEnabled(cacheable=true)
    public static String getContentVersionUrl(Id contentVersionId) {
        String url = '';
        
        try {
            ContentVersion contentVersion = [SELECT VersionData, FileType FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
            if (contentVersion != null && contentVersion.VersionData != null) {
                Blob versionData = contentVersion.VersionData;
                String base64Data = EncodingUtil.base64Encode(versionData);
                url = 'data:' + contentVersion.FileType + ';base64,' + base64Data;
            }
        } catch (Exception e) {
            System.debug('Error generating content version URL: ' + e.getMessage());
        }
        
        return url;
    }

    public class casewrapper {
        public List<Case> studentCase { get; set; }
        public List<ContentDocumentLink> caseattachments { get; set; }
    }
    /**********************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case> getCasesForUser(Id userId) {
        List<Case> cases = [SELECT Id, CaseNumber, Subject, Status FROM Case WHERE OwnerId = :userId];
        if (cases.isEmpty()) {
            System.debug('userid: '+ userid);
            System.debug('No cases found for user with Id: ' + userId);
        } else {
            System.debug('Cases found for user with Id: ' + userId);
        }        
        return cases;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Hostel_Support_Case_General_Complaints__mdt> getSupportCaseComplaintsBySubCategory(String subCategory) {
        // Query the custom metadata type records based on the Hostel_Sub_Category__c value
        List<Hostel_Support_Case_General_Complaints__mdt> complaintsMetadata = [
            SELECT MasterLabel, Hostel_Sub_Category__c, General_Complaints__c
            FROM Hostel_Support_Case_General_Complaints__mdt
            WHERE Hostel_Sub_Category__c = :subCategory
        ];
        
        // Return the list of metadata records
        return complaintsMetadata;
    }
    
    /****************for tiles controlling ************************/
    @AuraEnabled(cacheable=true)
    public static Boolean isCaseOwner() {
        Id userId = UserInfo.getUserId();
        Boolean isOwner = [SELECT Id FROM Case_Owner__c WHERE 
                  L4_Case_Owner__c = :userId
               OR L3_Case_Owner__c = :userId
               OR L2_Case_Owner__c = :userId
               OR L1_Case_Owner__c = :userId
        ].size() > 0;
        System.debug('Is logged-in user a case owner? ' + isOwner);
        return isOwner;
    }
    /*****************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<Case_Sharing_Users__mdt> fetchSharingMetadata(String sharingMethod) {
        return [
            SELECT Id, DeveloperName, MasterLabel, Email__c, Phone__c
            FROM Case_Sharing_Users__mdt
            WHERE MasterLabel = :sharingMethod
        ];
    }
    
    @AuraEnabled
    public static void updateCaseWithMetadata(Id caseId, Id metadataId,string selectedOption) {
        Case_Sharing_Users__mdt meta = [
            SELECT MasterLabel, Email__c, Phone__c,DeveloperName
            FROM Case_Sharing_Users__mdt
            WHERE Id = :metadataId
            LIMIT 1
        ];
        
        Case caseToUpdate = [
            SELECT Id, Email__c, Phone__c, Person_Name__c,Notification_Type__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
        
        // Assuming you want to store metadata info on standard Case fields
        caseToUpdate.Email__c = meta.Email__c;
        caseToUpdate.Phone__c = meta.Phone__c;
        caseToUpdate.Person_Name__c = meta.DeveloperName;
        caseToUpdate.Notification_Type__c= selectedOption;
        update caseToUpdate;

    }



 public class CustomMetadataWrapper {
    @AuraEnabled public String method;

    public CustomMetadataWrapper(String method) {
        this.method = method;
    }
}



}