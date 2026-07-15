public without sharing class Rve_ViewHallTicketController {
   
    @AuraEnabled public boolean EnableHallTicket {get;set;}

    @AuraEnabled
    public static String getPdfFileAsBase64String(String StudentSRN) {
        String base64Pdf;
        if (!Test.isRunningTest()) {
            PageReference pdfPage = Page.HallTicketPDF;
            Blob pdfBlob = pdfPage.getContent();
            base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        } else {
            base64Pdf = StudentSRN;
        }
        return base64Pdf;
    }

     @AuraEnabled
    public static ContentVersion savePdfAsFile(String StudentSRN) {
        try{
            Contact con = [SELECT Id ,name,SRN_No__c,SRN_Number__c,Checking_Eligibility_for_Exam__c FROM contact where  SRN_Number__c =:StudentSRN];
            If(con.Checking_Eligibility_for_Exam__c=='Eligible'){
                 // Generate the Visualforce page as a PDF
                PageReference pdfPage = Page.HallTicketPDF;
              //  pdfPage.getParameters().put('id', recordId); // Pass the record ID to the VF page
                pdfPage.setRedirect(false);
                
                // Get the PDF content as a Blob (binary data)
                Blob pdfBlob;
                    if(Test.isRunningTest()){
                    pdfBlob = blob.valueOf('Unit.Test');
                }else{
                    pdfBlob = pdfPage.getContentAsPDF();}        
                // Create a new ContentVersion record to store the PDF in Salesforce Files
                ContentVersion file = new ContentVersion();
                file.Title = 'HallTicket' + StudentSRN; // Name of the file
                file.PathOnClient = '/HallTicket.pdf'; // File extension
                file.VersionData = pdfBlob; // Set the Blob data
               // file.FirstPublishLocationId = StudentSRN; // Link the file to the related record (Account, Contact, etc.)
                
                // Insert the file record into Salesforce
                insert file;
                return file;
            }else{
                throw new AuraHandledException('You Don\'t have access to downlaod the hall ticket.');
                
            }
            
       
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

      // Method to delete a file after download
        @AuraEnabled
    public static void deleteFile(String contentDocumentId) {
        try {
            // Query for all ContentVersion records related to the ContentDocument
            List<ContentDocument> contentVersions = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];
            
            // Delete all associated ContentVersion records
            if(!contentVersions.isEmpty())
            {
              delete contentVersions[0];
            }
            
            // Finally, delete the ContentDocument record
            ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId LIMIT 1];
            delete contentDocument;
            
        } catch (Exception e) {
        }
    }

    @AuraEnabled
    public static Rve_Exam_Notification__c getExamNotification(String recType) {
        try {
            List<Rve_Exam_Notification__c> examNotifications = new List<Rve_Exam_Notification__c>();
            List<User> lUsers = [SELECT Id, Contact.Id FROM User WHERE Id = :UserInfo.getUserId() AND ContactId != NULL];

            if (!lUsers.isEmpty()) {
                Contact currentStudent = [SELECT Id, Name, Program_Batch__c, Active_Semester__c 
                                          FROM Contact 
                                          WHERE Id = :lUsers[0].ContactId LIMIT 1];

                Id recordTypeId = Schema.SObjectType.Rve_Exam_Notification__c
                                  .getRecordTypeInfosByDeveloperName()
                                  .get(recType == 'hed_Semester_Notification' ? 'hed_Semester_Notification' : 'hed_IA_Notification')
                                  .getRecordTypeId();
                
                if (recType == 'hed_Semester_Notification') {
                    examNotifications = [SELECT Id, Name, Rve_Publish__c, Rve_Semester__c, rve_Exam_Start_Date__c, hed_IA_Type__c, RecordType.DeveloperName 
                                         FROM Rve_Exam_Notification__c 
                                         WHERE Rve_Publish__c = true 
                                         AND Rve_Semester__c = :currentStudent.Active_Semester__c];
                } else If (recType == 'hed_IA_Notification') {
                    examNotifications = [SELECT Id, Name, Rve_Publish__c, Rve_Semester__c, rve_Exam_Start_Date__c, hed_IA_Type__c, RecordType.DeveloperName 
                                         FROM Rve_Exam_Notification__c 
                                         WHERE Rve_Publish__c = true 
                                         AND hed_Program_Batch__c = :currentStudent.Program_Batch__c];
                }           
            
            }

            return examNotifications.isEmpty() ? null : examNotifications[0];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    
     // Method to check if hall ticket download is enabled based on custom label
    @AuraEnabled
    public static Boolean isHallTicketDownloadEnabled() {
        try {
            List<User> lUsers = [SELECT Id, Contact.Id FROM User WHERE Id = :UserInfo.getUserId() AND ContactId != NULL];

            if (!lUsers.isEmpty()) {
                Contact currentStudent = [SELECT Id, Program_Batch__c FROM Contact WHERE Id = :lUsers[0].ContactId LIMIT 1];

                List<Rve_Exam_Notification__c> examNotifications = [SELECT rve_Exam_Start_Date__c 
                                                                    FROM Rve_Exam_Notification__c 
                                                                    WHERE Rve_Publish__c = true 
                                                                    AND hed_Program_Batch__c = :currentStudent.Program_Batch__c LIMIT 1];

                if (!examNotifications.isEmpty()) {
                    Date examStartDate = examNotifications[0].rve_Exam_Start_Date__c;
                    Date hallTicketDownloadStartTime = examStartDate.addDays(-2); 
                    // If current date is after or on hall ticket download start time, enable the download button
                    if (Date.today() >= hallTicketDownloadStartTime) {
                        return true; 
                    } else {
                        return false; 
                    }
                }
            }
        } catch (Exception e) {
            return false; 
        }
        return false;
    }    
}