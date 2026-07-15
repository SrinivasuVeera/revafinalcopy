public without sharing class RPL_PDFViewerController {
    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
        // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }

        // Filter PDF files 
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
            FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND FileExtension='pdf' ORDER BY Title];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            List<String> docTitleArray = docLink.Title.split(' - ');
            String docTitle = docTitleArray[1].trim();
            mapIdTitle.put(docLink.ContentDocumentId, docTitle);
        }

        return mapIdTitle;
    }
}