@isTest
private class RPL_PDFViewerController_Test {
    @testSetup
    private static void createNewContentVersion() {
        Rpl_Student_Registration__c std = new Rpl_Student_Registration__c();
        std.Name = 'Test Data1';
        std.Rpl_Personal_Mail_ID__c = 'test@gmail.com';
        std.Rpl_Interested_in_placement__c = 'Yes';
        std.Rpl_University_Mail_ID__c = '123123123@reva.edu.in';
        insert std;

        ContentVersion newContentVersion = new ContentVersion();
        newContentVersion.Title = '123 - TestDocument';
        newContentVersion.VersionData = EncodingUtil.base64Decode('Test File Data');
        newContentVersion.PathOnClient = '123 - TestDocument.pdf'; // Set this to the desired file name
        newContentVersion.FirstPublishLocationId = std.Id; // Link to the record
        insert newContentVersion;
    }

    @isTest
    private static void getRelatedFilesByRecordId() {
        Rpl_Student_Registration__c std = [Select Id From Rpl_Student_Registration__c Limit 1];
        System.debug('Student Registration ' + std);

        Map<ID, String> mapIdTitle = RPL_PDFViewerController.getRelatedFilesByRecordId(std.Id);
        System.debug('Map Id Title ' + mapIdTitle);

        // Check if there is at least one entry in the map
        System.assertEquals(1, mapIdTitle.size(), 'No Content document found');

        // If there is an entry, check the values
        if (mapIdTitle.size() == 1) {
            String docTitle = mapIdTitle.values()[0];
            // Add any additional assertions related to the docTitle if needed
        }
    }
}