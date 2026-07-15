/* public without sharing class filePreviewAndDownloadController {
    @AuraEnabled(cacheable=true)
        public static Map<String, Blob> getRelatedFilesByRecordId(String recordId) {
            // Get record file IDs        
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }
     
            List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title , VersionData
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
            Map<String, Blob> mapIdTitle = new Map<String, Blob>();
            for (ContentVersion docLink : docs) {
                mapIdTitle.put(docLink.Title, docLink.VersionData);
            }
            return mapIdTitle;
        }
}   */
public without sharing class filePreviewAndDownloadController {
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getRelatedFilesByRecordId(String recordId) {
        // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }

        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title, VersionData
            FROM ContentVersion WHERE ContentDocumentId IN :fileIDs];
        Map<String, String> mapIdTitle = new Map<String, String>();
        for (ContentVersion docLink : docs) {
            Blob test = docLink.VersionData;
            String base64Data = EncodingUtil.base64Encode(docLink.VersionData);
            mapIdTitle.put(docLink.Title, base64Data);
        }
        return mapIdTitle;
    }
}