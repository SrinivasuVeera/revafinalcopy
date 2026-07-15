public without sharing class ApplicantDocumentUpload {

    @AuraEnabled
    public static String updateFileName(Id contVerID, String fileName, String fileType) {
      System.debug('cvId =='  + contVerId);
      System.debug('filename ='  + fileName);
      System.debug('fileType ===' + fileType);
        try {
          List<ContentVersion> contentVersion = [SELECT Id, Title, Applicant_Document_Type__c
           FROM ContentVersion WHERE Id = :contVerID LIMIT 1];
          if(!contentVersion.isEmpty()) {
            for(ContentVersion cv : contentVersion) {
              cv.Title = fileName;
              cv.Applicant_Document_Type__c = fileType;
              //cv.Applicant_Document_Type__c = 'Applicant Photo';
            }
          }
          List<Database.SaveResult> srList = Database.update(contentVersion);	
          for (Database.SaveResult sr : srList) {
              if (!sr.isSuccess()) {
                return 'failure';
              }
          }
        } catch (Exception e) {
            return 'Error updating file name: ' + e.getMessage();
        }
        return 'success';
    }

    @AuraEnabled
    public static Integer deleteFile(String contactId, String fileName, String cvId){
      System.debug('contactId===========' + contactId);
      System.debug('contVerId-----------' + cvId);
      DateTime dt = DateTime.now();
      String cdlQuery = 'SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title,'+
      ' ContentDocument.CreatedDate FROM ContentDocumentLink WHERE LinkedEntityId =: contactId'+
      ' AND ContentDocument.Title =: fileName'+
      ' AND ContentDocument.LastModifiedDate <: dt' +
      ' AND ContentDocument.LatestPublishedVersionId !=: cvId ';
      System.debug('cdlQuery====>'  + cdlQuery);
      List<ContentDocumentLink> filesToDelete = database.query(cdlQuery);
      System.debug('filesToDelete===='+ filesToDelete);
      System.debug(filesToDelete.size());
      delete filesToDelete;
      return filesToDelete.size();
    }

  @AuraEnabled(cacheable=true)
  public static String getApplicantId(String applicationId) {
    
    hed__Application__c appId = [Select Id, hed__Applicant__c from hed__Application__c  where id = : applicationId Limit 1];
    String contactId = appId.hed__Applicant__c;
    
    return contactId;
  }

  @AuraEnabled(cacheable=true)
  public static List <String> getFileTypes(String contactId, String useLocation) {
    
    List <String> options = new list <String> ();
    List <String> scholarshipDocumentList= new List<String>();
    
    Schema.DescribeFieldResult fieldResult = ContentVersion.Applicant_Document_Type__c.getDescribe();
    List <Schema.PicklistEntry> documentList = fieldResult.getPicklistValues();
  
    //Get  document list from scholarship master
    Schema.DescribeFieldResult fieldList = Scholarship_Master__c.Documents_Required__c.getDescribe();
    List <Schema.PicklistEntry> scholDocList = fieldList.getPicklistValues();

    
    List<String> eduCerts = new List <String>{'12th/PUC Marks Card','Degree Marks Card'};
    List <String> poDocList = new List <String>{'PO Signed by Applicant','PO Fully Signed','Provisional Offer Letter'};
    //String poFullySigned = 'PO Fully Signed';

      for (Schema.PicklistEntry pickListVal : scholDocList) {
        scholarshipDocumentList.add(pickListVal.getLabel());
      }     
      
    List<hed__Application__c> applicationDocuments=[Select id, Additional_Documents__c	From hed__Application__c where hed__Applicant__c =:contactId limit 1];
      
      if (useLocation == 'primaryApplication') {

        for (string eduDoc: eduCerts) {
          options.add(eduDoc);
        }
        
        for (Schema.PicklistEntry docValues: documentList) {

          if (!scholarshipDocumentList.contains(docValues.getValue()) && !poDocList.contains(docValues.getValue())) {
            options.add(docValues.getLabel());
          }    
        }
      } else if (useLocation == 'Additional Documents') {
        User siteUser = [select id, ContactId,ProfileId from user where Id = :UserInfo.getUserId()];
        Profile counselorProfile = [SELECT Id, Name FROM Profile Where Name = 'Counselor'];
        system.debug('siteUser.ProfileId'+siteUser.ProfileId);
        system.debug('counselorProfile'+counselorProfile);
        //User counselorUsers = [SELECT Id, Name FROM User WHere ProfileId=:counselorProfile.id];
        for (hed__Application__c appDocuments: applicationDocuments) {
          options.addAll(appDocuments.Additional_Documents__c.split(';'));
        }

        for (Integer i = options.size() - 1; i >= 0; i--) {
          if (options[i] == 'PO Fully Signed' && siteUser.ProfileId!=counselorProfile.id) {
            options.remove(i);
            system.debug('siteUser.ProfileId'+siteUser.ProfileId);
            system.debug('counselorProfile'+counselorProfile);
          }
        }
      } else if (useLocation == 'CET') {
        options = new List <String>{'Passport Photo','CET Allotment Letter'};
      } else if (useLocation == 'ComedK') {
        options = new List <String>{'Passport Photo','COMEDK Allotment Letter'};
      } else if (useLocation == 'UQ') {
        options = new List <String>{'Passport Photo','10th/SSLC Marks Card','12th/PUC Marks Card','Study Certificate','Entrance Exam Rank Card'};
      } 
      else if (useLocation == 'Ph.D') {
        options = new List <String>{'Passport Photo','10th/SSLC Marks Card','12th/PUC Marks Card','Caste Certificate','Degree Certificate','Degree Marks Card','MPhil Certificate','NET','SET','KSET'};
      }
      else if (useLocation == 'DCET') {
        options = new List <String>{'Passport Photo','CET Allotment Letter'};
      }
      else if (useLocation == 'PGCET') {
        options = new List <String>{'Passport Photo','CET Allotment Letter'};
      }
    return options;
  }

  @AuraEnabled(cacheable=true)
  public static List<SavedFileInfo> getCurrentFiles(String contactId) {
    
    List<SavedFileInfo> currentFiles = new List<SavedFileInfo>();

    for (ContentDocumentLink cdl : [select ContentDocumentId, 
                                          ContentDocument.LatestPublishedVersion.Applicant_Document_Type__c
                                      from ContentDocumentLink
                                    where LinkedEntityId = :contactId
                                      and ContentDocument.LatestPublishedVersion.Applicant_Document_Type__c != null 
          ]) {
        currentFiles.add(new SavedFileInfo(
        cdl.ContentDocument.LatestPublishedVersion.Applicant_Document_Type__c,
        cdl.ContentDocumentId
        
      ));
    }
    return currentFiles;
  }

  @AuraEnabled(cacheable=true)
  public static String getProgramType(String applicationId) {   
    hed__Application__c app = [SELECT Id, hed__Applicant__c, hed__Applicant__r.Program_Type__c
                               FROM hed__Application__c WHERE Id = :applicationId LIMIT 1];     
    String programType = app.hed__Applicant__r.Program_Type__c;
    return programType;   
  }

  @AuraEnabled(cacheable=true)
  public static List<EducationHistory> getEducationHistories(String contactId) {
    List<EducationHistory> eduHistoryRecords = new List<EducationHistory>();
    for (hed__Education_History__c eh : [select Id, Type_of_Course__c
                                          from hed__Education_History__c
                                          where hed__Contact__c = :contactId]) {
      eduHistoryRecords.add(new EducationHistory(
        eh.Id,
        eh.Type_of_Course__c
      ));
    }
    return eduHistoryRecords;
  }

  @AuraEnabled
  public static List<String> uploadFiles(List<FileInfo> filesToUpload) {
    List<ContentVersion> cvs = createContentVersion(filesToUpload);
    System.debug('>>> Returned from createContentVersion: ' + cvs);
    List<String> cvIds = new List<String>();
    Map<String, String> cvIdEduHistIdMap = new Map<String, String>();
    Map<String, String> cvIdApplicationIdMap = new Map<String, String>();
    for (Integer i = 0; i < cvs.size(); i++) {
      cvIds.add(cvs[i].Id);
      
      //Set data for creating content document links for application record
      cvIdApplicationIdMap.put(cvs[i].Id, filesToUpload[i].recordIds[1]); //second id will be application id

      //Check if we need to create content document link to education history record
      if (filesToUpload[i].recordIds.size() > 2) {
        String eduHistId = filesToUpload[i].recordIds[2]; //third id will be education history id
        cvIdEduHistIdMap.put(cvs[i].Id, eduHistId);
      }
    }



    //Create Content Document Links for Application Record
    createContentDocumentLinks(cvIdApplicationIdMap);

    //Create Content Document Links to Education History Records
    if (cvIdEduHistIdMap.size() > 0) {
      createContentDocumentLinks(cvIdEduHistIdMap);
    }

    return cvIds;
  }

  // @AuraEnabled
  // public static List<String> uploadFiles1(String filesToUploadString) {
  //   // List<FileInfo> filesToUpload = JSON.deserialize(filesToUploadString,FileInfo1);
  //   List<FileInfo> filesToUpload = (List<FileInfo>) JSON.deserializeUntyped(filesToUploadString);
  //   List<ContentVersion> cvs = createContentVersion(filesToUpload);
  //   System.debug('>>> Returned from createContentVersion: ' + cvs);
  //   List<String> cvIds = new List<String>();
  //   Map<String, String> cvIdEduHistIdMap = new Map<String, String>();
  //   Map<String, String> cvIdApplicationIdMap = new Map<String, String>();
  //   for (Integer i = 0; i < cvs.size(); i++) {
  //     cvIds.add(cvs[i].Id);
      
  //     //Set data for creating content document links for application record
  //     cvIdApplicationIdMap.put(cvs[i].Id, filesToUpload[i].recordIds[1]); //second id will be application id

  //     //Check if we need to create content document link to education history record
  //     if (filesToUpload[i].recordIds.size() > 2) {
  //       String eduHistId = filesToUpload[i].recordIds[2]; //third id will be education history id
  //       cvIdEduHistIdMap.put(cvs[i].Id, eduHistId);
  //     }
  //   }



  //   //Create Content Document Links for Application Record
  //   createContentDocumentLinks(cvIdApplicationIdMap);

  //   //Create Content Document Links to Education History Records
  //   if (cvIdEduHistIdMap.size() > 0) {
  //     createContentDocumentLinks(cvIdEduHistIdMap);
  //   }

  //   return cvIds;
  // }

  @testVisible
  private static List<ContentVersion> createContentVersion(List<FileInfo> filesToUpload) {
    List<ContentVersion> cvs = new List<ContentVersion>();
    for (FileInfo file : filesToUpload) {
      ContentVersion cv = new ContentVersion(
        VersionData = EncodingUtil.base64Decode(file.base64),
        Title = 'Applicant Photo',
        Applicant_Document_Type__c = 'Applicant Photo',
        PathOnClient = file.filename, 
        Description = file.fileType
      );
      if (file.contentDocumentId != null) {
        System.debug('>>> Content Document Id: ' + file.contentDocumentId);
        cv.ContentDocumentId = file.contentDocumentId;
      } else {
        cv.FirstPublishLocationId = file.recordIds[0]; //This will be contact id
      }
      cvs.add(cv);
    }
      try {
          insert cvs;
          return cvs;
      } catch(DMLException e) {
          System.debug(e);
          return null;
      }
  }
  //Creates content document links for both education history and application records
  private static void createContentDocumentLinks(Map<String, String> cvIdParentIdMap) {
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
    
    //get content document ids
    List<ContentVersion> cvs = [select Id, ContentDocumentId
                                  from ContentVersion
                                  where Id in :cvIdParentIdMap.keySet()];

    for (ContentVersion cv : cvs) {
      cdlList.add(new ContentDocumentLink(
        ContentDocumentId = cv.ContentDocumentId,
        LinkedEntityId = cvIdParentIdMap.get(cv.Id),
        ShareType = 'V'

      ));
    }

    try {
      insert cdlList;
    } catch(DMLException e) {
      System.debug(e);
    }
  }

  public class FileInfo {
    @AuraEnabled
    public String base64 {get; set;}
    @AuraEnabled
    public String filename {get; set;}
    @AuraEnabled
    public String fileType {get; set;}
    //First index (0) of recordIds will always be contactId
    //Second index (1) of recordIds will be application id 
    //Third index (2) of recordIds will exist only if this file type 
    // has a mapped education history record
    @AuraEnabled
    public String[] recordIds {get; set;} 
    @AuraEnabled
    public String contentDocumentId {get; set;} //Will be set in case a document is previously loaded
    @AuraEnabled
    public Integer fileSize {get; set;}
  }

  public class FileInfo1 {
    public String base64;
    public String filename;
    public String fileType;
    public String[] recordIds;
    public String contentDocumentId;
    public Integer fileSize;
  }

  public class SavedFileInfo {
    @AuraEnabled
    public String fileType {get; set;}
    @AuraEnabled
    public String contentDocumentId {get; set;}

    public SavedFileInfo(String fileType, String contentDocumentId) {
      this.fileType = fileType;
      this.contentDocumentId = contentDocumentId;
    }
  }

  public class EducationHistory {
    @AuraEnabled
    public String eduHistoryId {get; set;}
    @AuraEnabled
    public String courseType {get; set;}

    public EducationHistory(String eduHistoryId, String courseType) {
      this.eduHistoryId = eduHistoryId;
      this.courseType = courseType;
    }
  }

 @AuraEnabled(cacheable=true)
public static Map<String, Object> contactCategory(String contactId) {
    Boolean isValidCategory = false;
    Contact con= [Select Id,name,Select_Category__c,Country__c From Contact where Id=: contactId ];
    If(con.Select_Category__c != null && (con.Select_Category__c == 'Indian (SAARC)' ||con.Select_Category__c == 'Non-Resident Indian(NRI)' || con.Select_Category__c == 'Foreign Nationals')){

    isValidCategory = true;
  }
   // Return Boolean + Country
    Map<String, Object> result = new Map<String, Object>();
    result.put('isValidCategory', isValidCategory);
    result.put('country', con.Country__c);
  return result;
  }


}