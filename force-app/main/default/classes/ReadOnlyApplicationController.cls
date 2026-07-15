public with sharing class ReadOnlyApplicationController {
    private static final String PHOTO_URL_BASE = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=';
    public Contact applicant {get; set;}
    public hed__Application__c application {get; set;}
    public Contact father {get; set;}
    public Contact mother {get; set;}
    public Contact guardian {get; set;}
    public hed__Education_History__c tenth {get; set;}
    public hed__Education_History__c twelfth {get; set;}
    public hed__Education_History__c ug {get; set;}
    public hed__Education_History__c pg {get; set;}
    public hed__Address__c mailingAddress {get; set;}
    public hed__Address__c permanentAddress {get; set;}
    public String primaryAcademicProgram {get; set;}
    public String passportPhotoURL {get; set;}
    public String passportNumber {get; set;}
    public String applicationNumber {get; set;}
    public String schoolName {get; set;} 
    public String applyCET {get; set;} 
    public String examType {get; set;}
    public DateTime applicationDate {get; set;}  
    public String cetAdmissionMode {get; set;}
    //public String admissionMode;
    public List<Entrance_Exam__c> entranceExams { get; set; }
    
    
    public Map<String, List<FieldInfo>> fieldsInfo  {get; set;} 
    
    public ReadOnlyApplicationController() {
        String applicationId = ApexPages.currentPage().getParameters().get('id');
        System.debug('applicationId-->> '+applicationId);
        this.fieldsInfo = new Map<String, List<FieldInfo>>();     
        
        setInfo(applicationId, 'application');
        
        
        String applicantId = [select hed__Applicant__c 
                              from hed__Application__c
                              where id = :applicationId].hed__Applicant__c;
        
        this.entranceExams = [SELECT Id, Name, Exam_Type__c, Scored_Marks__c, Rank__c, 
                         Allotted_Category__c, National_level__c, Roll_No__c, 
                         State__c, State_Level__c, Total_Marks__c
                         FROM Entrance_Exam__c
                         WHERE Application__c = :applicationId];
        
        system.debug('entranceExams-->' + this.entranceExams);
        
        setInfo(applicantId, 'applicant');
        setInfo(applicantId, 'parent');
        setInfo(applicantId, 'address');
        setInfo(applicantId, 'educationHistory');
        setInfo(applicantId, 'entranceExam');  
        
        //Get image information
        List<ContentDocumentLink> cdls = [select ContentDocument.LatestPublishedVersionId 
                                          from ContentDocumentLink
                                          where ContentDocument.title IN ('Passport Photo', 'Applicant Photo') and 
                                          LinkedEntityId = :applicantId];
        if (cdls.size() > 0) {
            ContentDocumentLink cdl = cdls[0];
            this.passportPhotoURL = PHOTO_URL_BASE + cdl.ContentDocument.LatestPublishedVersionId;
            System.debug('URL---->'+ this.passportPhotoURL);
        }
    }
    
    private Set<String> getFields(String infoType) {
        List<Schema.FieldSetMember> fields = new List<Schema.FieldSetMember>();
        Set<String> uniqueFields = new Set<String>();
        
        //system.debug('Am'+ admissionMode);
        switch on infoType {
            when 'applicant' {
                fields.addAll(SObjectType.Contact.FieldSets.Personal_Info.getFields());
                saveFieldInfo('personalInformation',SObjectType.Contact.FieldSets.Personal_Info.getFields());
                fields.addAll(SObjectType.Contact.FieldSets.Passport_Info.getFields());
                saveFieldInfo('passportInformation',SObjectType.Contact.FieldSets.Passport_Info.getFields());
                fields.addAll(SObjectType.Contact.FieldSets.CET_Info.getFields());
                saveFieldInfo('cetInformation',SObjectType.Contact.FieldSets.CET_Info.getFields());
            }
            when 'parent' {
                fields.addAll(SObjectType.Contact.FieldSets.Parent_Details.getFields());
                saveFieldInfo('parentInformation',SObjectType.Contact.FieldSets.Parent_Details.getFields());
                
            }
            when 'address' {
                fields.addAll(SObjectType.hed__Address__c.FieldSets.Address_Info.getFields());
                saveFieldInfo('addressInformation',SObjectType.hed__Address__c.FieldSets.Address_Info.getFields());
            }
            when 'application' {
                String applicationId = ApexPages.currentPage().getParameters().get('id');
                //this.fieldsInfo = new Map<String, List<FieldInfo>>();
                String admissionMode;
                //setInfo(applicationId, 'application');
                
                /*String applicantId = [select hed__Applicant__c 
from hed__Application__c
where id = :applicationId].hed__Applicant__c;*/
                List<hed__Application__c> Contacts = [Select hed__Applicant__r.Admission_Mode__c from hed__Application__c where Id=:applicationId limit 1 ];
                
                // List<Contact> contacts = [SELECT Admission_Mode__c FROM Contact WHERE Id = :applicantId LIMIT 1];
                system.debug('ContactId'+ contacts);
                if (!contacts.isEmpty()) {
                    // Contact contact = contacts[0];
                    admissionMode = Contacts[0].hed__Applicant__r.Admission_Mode__c;
                    
                    
                    system.debug('Am'+ admissionMode);
                }
                
                system.debug('application');
                if(admissionMode !='UQ'){
                    system.debug('Am'+ admissionMode);
                    system.debug('This is first');
                    fields.addAll(SObjectType.hed__Application__c.FieldSets.Non_CET_Application_info.getFields());
                    saveFieldInfo('application', SObjectType.hed__Application__c.FieldSets.Non_CET_Application_info.getFields());
                }else{
                    system.debug('This is 2');
                    fields.addAll(SObjectType.hed__Application__c.FieldSets.Application_Info.getFields());
                    saveFieldInfo('application', SObjectType.hed__Application__c.FieldSets.Application_Info.getFields());
                }
                
                fields.addAll(SObjectType.hed__Application__c.FieldSets.Document_Checklist_Info.getFields());
                saveFieldInfo('documentChecklist', SObjectType.hed__Application__c.FieldSets.Document_Checklist_Info.getFields());
            }
            when 'educationHistory' {      
                fields.addAll(SObjectType.hed__Education_History__c.FieldSets.Education_History_10th.getFields());
                saveFieldInfo('education10th', SObjectType.hed__Education_History__c.FieldSets.Education_History_10th.getFields());
                fields.addAll(SObjectType.hed__Education_History__c.FieldSets.Education_History_12th.getFields());
                saveFieldInfo('education12th', SObjectType.hed__Education_History__c.FieldSets.Education_History_12th.getFields());
                fields.addAll(SObjectType.hed__Education_History__c.FieldSets.Education_History_UG.getFields());
                saveFieldInfo('educationUG', SObjectType.hed__Education_History__c.FieldSets.Education_History_UG.getFields());
                fields.addAll(SObjectType.hed__Education_History__c.FieldSets.Education_History_PG.getFields());
                saveFieldInfo('educationPG', SObjectType.hed__Education_History__c.FieldSets.Education_History_PG.getFields());
                
            }
            when 'entranceExam'{
                fields.addAll(SObjectType.Entrance_Exam__c.FieldSets.Entrance_Exam_Info.getFields());
                saveFieldInfo('entranceExam', SObjectType.Entrance_Exam__c.FieldSets.Entrance_Exam_Info.getFields());
            }
            when else {
                //
            }
            
        }        
        
        
        for (Schema.FieldSetMember fsm: fields) {
            uniqueFields.add(fsm.getFieldPath());
        }
        
        return uniqueFields;
    }
    
    private void saveFieldInfo(String infoType, List<Schema.FieldSetMember> fields) {
        Integer index = 0;
        List<FieldInfo> fieldsData = new List<FieldInfo>(); 
        while (index < fields.size()) {
            FieldInfo fi = new FieldInfo();
            fi.label1 = fields[index].getLabel();
            fi.apiName1 = fields[index].getFieldPath();
            fi.fieldType1 = fields[index].getType().name();
            index++;
            if (index < fields.size()) {
                fi.label2 = fields[index].getLabel();
                fi.apiName2 = fields[index].getFieldPath();
                fi.fieldType2 = fields[index].getType().name();
            }
            index++;
            fieldsData.add(fi);
        }
        fieldsInfo.put(infoType, fieldsData);
    }
    
    private void setInfo(String Id, String infoType) {
        String obj;
        String whereClause;
        
        switch on infoType {
            when 'applicant' {
                obj = 'Contact';
                whereClause = ' WHERE Id = \'' + Id + '\'';
            }
            when 'parent' {
                obj = 'Contact';
                whereClause = ' WHERE ReportsToId = \'' + Id + '\'';
            }
            when 'address' {
                obj = 'hed__Address__c';
                whereClause = ' WHERE hed__Parent_Contact__c = \'' + Id + '\'';
            }
            when 'application' {
                obj = 'hed__Application__c';
                whereClause = ' WHERE Id = \'' + Id + '\'';
            }
            when 'educationHistory' {
                obj = 'hed__Education_History__c';
                whereClause = ' WHERE hed__Contact__c = \'' + Id + '\'';
            }
            when 'entranceExam'{
                obj ='Entrance_Exam__c';
                whereClause = ' WHERE Application__c = \'' + Id + '\'';
            }
            when else {
                //
            }
        }
        
        String query = 'SELECT ';
        for (String field : this.getFields(infoType)) {
            query += field + ', ';
        }
        
        if (infoType == 'applicant') {
            query += 'Primary_Academic_Program__r.Name , School__r.Name, Exam_Type__c, Applying_For_REVA_CET__c, Admission_Mode__c ' + ', ';
        } else if (infoType == 'parent') {
            query += 'Type_of_Relationship__c' + ', ';
        } else if (infoType == 'educationHistory') {
            query += 'Type_of_Course__c' + ', ';
        } else if(infoType == 'application'){
            query += 'hed__Application_Date__c' + ', ';
        }
        query += 'Id FROM ' + obj + whereClause;
        
        System.debug(query);
        List<SObject> sObjs = Database.query(query);
        System.debug(sObjs);
        switch on infoType {
            when 'application' {
                this.application = (hed__Application__c)sObjs[0];
                this.applicationNumber = this.application.Application_Number__c;
                this.applicationDate = this.application.hed__Application_Date__c;
            }
            when 'applicant' {
                this.applicant = (Contact)sObjs[0];
                this.primaryAcademicProgram = this.applicant.Primary_Academic_Program__r.Name;
                this.schoolName = this.applicant.School__r.Name;
                this.passportNumber = this.applicant.Passport_Number__c;
                this.examType = this.applicant.Exam_Type__c;
                this.applyCET = this.applicant.Applying_For_REVA_CET__c;
                this.cetAdmissionMode = this.applicant.Admission_Mode__c;
            }
            when 'parent' {
                for (SObject sObj : sObjs) {
                    Contact c = (Contact)sObj;
                    if (c.Type_of_Relationship__c == 'Father') {
                        this.father = c;
                    } else if (c.Type_of_Relationship__c == 'Mother') {
                        this.mother = c;
                    } else if (c.Type_of_Relationship__c == 'Guardian') {
                        this.guardian = c;
                    } 
                }
            }
            when 'address' {
                for (SObject sObj : sObjs) {
                    hed__Address__c ad = (hed__Address__c)sObj;
                    if (ad.hed__Address_Type__c == 'Mailing Address') {
                        this.mailingAddress = ad;
                    } else if (ad.hed__Address_Type__c == 'Permanent Address') {
                        this.permanentAddress = ad;
                    } 
                }
            }
            when 'educationHistory' {
                for (SObject sObj : sObjs) {
                    hed__Education_History__c eh = (hed__Education_History__c)sObj;
                    if (eh.Type_of_Course__c == '10th') {
                        this.tenth = eh;
                    } else if (eh.Type_of_Course__c == '12th') {
                        this.twelfth = eh;
                    } else if (eh.Type_of_Course__c == 'UG') {
                        this.ug = eh;
                    } else if (eh.Type_of_Course__c == 'PG') {
                        this.pg = eh;
                    } 
                }
            }
           /* when 'entranceExam'{
                this.entranceExams = new List<Entrance_Exam__c>();
                for (SObject sObj : sObjs) {
                    this.entranceExams.add((Entrance_Exam__c) sObj);
                }
            }*/
            when else {
                //
            }
        }
    }
    
    public static Pagereference save(){
        String applicationId = ApexPages.currentPage().getParameters().get('id');
        Pagereference redirectTo = new Pagereference('/apex/ReadOnlyApplicationPdf?id='+applicationId);
        redirectTo.setRedirect(true);
        return redirectTo;
        
    }
    
    
    
    
    public class FieldInfo {
        public String label1 {get; set;}
        public String apiName1 {get; set;}
        public String fieldType1 {get; set;}
        public String label2 {get; set;}
        public String apiName2 {get; set;}
        public String fieldType2 {get; set;}
    }
}