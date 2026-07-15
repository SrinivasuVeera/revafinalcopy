public with sharing class RveExamPhotocopyFileUploadController {
    
    public class ResultPhotocopyWrapper {
        @AuraEnabled public Id resultId;
        @AuraEnabled public String courseName;
        @AuraEnabled public Boolean appliedForPhotocopy;
        @AuraEnabled public Boolean feePaid;
        @AuraEnabled public Boolean fileUploaded;
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public String previewUrl;
        @AuraEnabled public Date seeResultDate;
        @AuraEnabled public Boolean showUpload;
        @AuraEnabled public Boolean showRemove;
        
    }
    
    @AuraEnabled
    public static void uploadFile(String base64, String filename, Id recordId) {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Photocopy_' + filename; // Unique prefix to identify our file
        cv.PathOnClient = filename;
        cv.VersionData = EncodingUtil.base64Decode(base64);
        insert cv;
        
        ContentDocument cd = [
            SELECT Id FROM ContentDocument
            WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id)
            LIMIT 1
        ];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cd.Id;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        update new hed__Term_Grade__c(Id = recordId, Photocopy_Uploaded__c = true);
    }
    
    @AuraEnabled
    public static void deleteFile(Id recordId) {
        List<ContentDocumentLink> allLinks = [
            SELECT Id, ContentDocumentId, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ];
        
        List<ContentDocumentLink> photocopyLinks = new List<ContentDocumentLink>();
        Set<Id> docIdsToDelete = new Set<Id>();
        
        for (ContentDocumentLink link : allLinks) {
            if (link.ContentDocument.Title != null && link.ContentDocument.Title.startsWith('Photocopy_')) {
                photocopyLinks.add(link);
                docIdsToDelete.add(link.ContentDocumentId);
            }
        }
        
        if (!photocopyLinks.isEmpty()) {
            delete photocopyLinks;
        }
        
        if (!docIdsToDelete.isEmpty()) {
            List<ContentDocument> docs = [
                SELECT Id FROM ContentDocument WHERE Id IN :docIdsToDelete
            ];
            delete docs;
        }
        
        update new hed__Term_Grade__c(Id = recordId, Photocopy_Uploaded__c = false);
    }
    
    /* @AuraEnabled(cacheable=true)
public static List<ResultPhotocopyWrapper> getPhotocopyRecordsWithFiles(List<Id> resultIds) {
List<ResultPhotocopyWrapper> wrapperList = new List<ResultPhotocopyWrapper>();

if (resultIds == null || resultIds.isEmpty()) {
return wrapperList;
}

List<hed__Term_Grade__c> results = [
SELECT Id,
Course__r.Name,
AppliedForPhotoCopy__c,
Fee_Paid_For_Photocopy__c,
Photocopy_Uploaded__c,
hed__Term__r.Rve_SEE_Result_Date__c
FROM hed__Term_Grade__c
WHERE Id IN :resultIds
AND AppliedForPhotoCopy__c = TRUE
AND Fee_Paid_For_Photocopy__c = TRUE
AND Photocopy_Uploaded__c = TRUE
];

Map<Id, Id> resultToDocMap = new Map<Id, Id>();

List<ContentDocumentLink> links = [
SELECT ContentDocumentId, LinkedEntityId, ContentDocument.Title
FROM ContentDocumentLink
WHERE LinkedEntityId IN :resultIds
];

for (ContentDocumentLink link : links) {
if (link.ContentDocument.Title != null && link.ContentDocument.Title.startsWith('Photocopy_')) {
resultToDocMap.put(link.LinkedEntityId, link.ContentDocumentId);
}
}

for (hed__Term_Grade__c res : results) {
ResultPhotocopyWrapper wrap = new ResultPhotocopyWrapper();
wrap.resultId = res.Id;
wrap.courseName = res.Course__r != null ? res.Course__r.Name : 'N/A';
wrap.appliedForPhotocopy = res.AppliedForPhotoCopy__c;
wrap.feePaid = res.Fee_Paid_For_Photocopy__c;
wrap.fileUploaded = res.Photocopy_Uploaded__c;
wrap.seeResultDate = res.hed__Term__r.Rve_SEE_Result_Date__c;

if (resultToDocMap.containsKey(res.Id)) {
wrap.contentDocumentId = resultToDocMap.get(res.Id);
wrap.previewUrl = Site.getBaseUrl() + '/sfc/servlet.shepherd/document/download/' + wrap.contentDocumentId;
}

wrapperList.add(wrap);
}

return wrapperList;
}*/
    
    @AuraEnabled(cacheable=true)
    public static List<ResultPhotocopyWrapper> getPhotocopyRecordsWithFiles(List<Id> resultIds) {
        List<ResultPhotocopyWrapper> wrapperList = new List<ResultPhotocopyWrapper>();
        
        if (resultIds == null || resultIds.isEmpty()) {
            return wrapperList;
        }
        
        List<hed__Term_Grade__c> results = [
            SELECT Id,
            Course__r.Name,
            AppliedForPhotoCopy__c,
            Fee_Paid_For_Photocopy__c,
            Photocopy_Uploaded__c,
            hed__Term__r.Rve_SEE_Result_Date__c
            FROM hed__Term_Grade__c
            WHERE Id IN :resultIds
        ];
        
        Map<Id, Id> resultToDocMap = new Map<Id, Id>();
        
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, LinkedEntityId, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :resultIds
        ];
        
        for (ContentDocumentLink link : links) {
            if (link.ContentDocument.Title != null && link.ContentDocument.Title.startsWith('Photocopy_')) {
                resultToDocMap.put(link.LinkedEntityId, link.ContentDocumentId);
            }
        }
        
        for (hed__Term_Grade__c res : results) {
            ResultPhotocopyWrapper wrap = new ResultPhotocopyWrapper();
            wrap.resultId = res.Id;
            wrap.courseName = res.Course__r != null ? res.Course__r.Name : 'N/A';
            wrap.appliedForPhotocopy = res.AppliedForPhotoCopy__c;
            wrap.feePaid = res.Fee_Paid_For_Photocopy__c;
            wrap.fileUploaded = res.Photocopy_Uploaded__c;
            wrap.seeResultDate = res.hed__Term__r.Rve_SEE_Result_Date__c;
            
          //  Boolean isPhotocopyAppliedAndPaid = res.AppliedForPhotoCopy__c && res.Fee_Paid_For_Photocopy__c;
            
            // Upload button visible if applied + paid + not uploaded
           // wrap.showUpload = isPhotocopyAppliedAndPaid && !res.Photocopy_Uploaded__c;
            wrap.showUpload = res.AppliedForPhotoCopy__c && res.Fee_Paid_For_Photocopy__c && !res.Photocopy_Uploaded__c;

            
            // Remove button visible only if uploaded & doc exists
            wrap.showRemove = false;
            
            if (res.AppliedForPhotoCopy__c && res.Photocopy_Uploaded__c && resultToDocMap.containsKey(res.Id)) {
                wrap.contentDocumentId = resultToDocMap.get(res.Id);
                wrap.previewUrl = Site.getBaseUrl() + '/sfc/servlet.shepherd/document/download/' + wrap.contentDocumentId;
                wrap.showRemove = true;
            }
            
            /*if (resultToDocMap.containsKey(res.Id)) {
wrap.contentDocumentId = resultToDocMap.get(res.Id);
wrap.previewUrl = Site.getBaseUrl() + '/sfc/servlet.shepherd/document/download/' + wrap.contentDocumentId;
wrap.showRemove = true;
} else {
wrap.showRemove = false;
}*/
            
            wrapperList.add(wrap);
        }
        
        return wrapperList;
    }
    
    
}