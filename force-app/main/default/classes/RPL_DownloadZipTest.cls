@isTest
private class RPL_DownloadZipTest {
    
    @isTest
    static void testFetchRelatedFiles() {
        // Create test data - Replace with your actual objects and relationships
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };
        insert accounts;

        List<ContentVersion> contentVersions = new List<ContentVersion>{
            new ContentVersion(
                VersionData = Blob.valueOf('Test Content 1'),
                Title = 'Test Document 1',
                PathOnClient = 'TestDocument1.txt'
            ),
            new ContentVersion(
                VersionData = Blob.valueOf('Test Content 2'),
                Title = 'Test Document 2',
                PathOnClient = 'TestDocument2.txt'
            )
        };
        insert contentVersions;

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>{
            new ContentDocumentLink(
                ContentDocumentId = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersions[0].Id].Id,
                LinkedEntityId = accounts[0].Id
            ),
            new ContentDocumentLink(
                ContentDocumentId = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersions[1].Id].Id,
                LinkedEntityId = accounts[1].Id
            )
        };
        insert contentDocumentLinks;

        // Test the fetchRelatedFiles method
        Test.startTest();

        List<String> recordIds = new List<String>{accounts[0].Id, accounts[1].Id};
        String fileNames = 'Test Document';
        List<Id> result = RPL_DownloadZip.fetchRelatedFiles(recordIds, fileNames);
        System.assertEquals(2, result.size(), 'Expected only one ContentVersion Id');

        Test.stopTest();
    }
}