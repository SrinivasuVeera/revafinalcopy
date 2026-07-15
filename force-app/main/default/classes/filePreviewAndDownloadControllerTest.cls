@isTest
public class filePreviewAndDownloadControllerTest {
    @isTest
    static void testGetRelatedFilesByRecordId() {
        // Step 1: Create a test Account record to link files
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Step 2: Create test Content Version records
        ContentVersion testContentVersion1 = new ContentVersion(
            Title = 'Test File 1',
            PathOnClient = 'testfile1.txt',
            VersionData = Blob.valueOf('This is a test file content 1'),
            ContentLocation = 'S'
        );
        insert testContentVersion1;
        
        ContentVersion testContentVersion2 = new ContentVersion(
            Title = 'Test File 2',
            PathOnClient = 'testfile2.txt',
            VersionData = Blob.valueOf('This is a test file content 2'),
            ContentLocation = 'S'
        );
        insert testContentVersion2;
        
        // Ensure the ContentVersions have been inserted and have ContentDocumentIds
        ContentVersion insertedContentVersion1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion1.Id LIMIT 1];
        ContentVersion insertedContentVersion2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion2.Id LIMIT 1];
        
        // Step 4: Create ContentDocumentLink records linking the files to the Account
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        contentDocumentLinks.add(new ContentDocumentLink(
            ContentDocumentId = insertedContentVersion1.ContentDocumentId,
            LinkedEntityId = testAccount.Id,
            ShareType = 'V'
        ));
        contentDocumentLinks.add(new ContentDocumentLink(
            ContentDocumentId = insertedContentVersion2.ContentDocumentId,
            LinkedEntityId = testAccount.Id,
            ShareType = 'V'
        ));
        insert contentDocumentLinks;

        // Step 5: Test the getRelatedFilesByRecordId method with valid Account Id
        Test.startTest();
        Map<String, String> result = filePreviewAndDownloadController.getRelatedFilesByRecordId(testAccount.Id);
        Test.stopTest();
        
        // Step 6: Assertions
        System.assertNotEquals(null, result, 'Result map should not be null.');
        System.assertEquals(2, result.size(), 'There should be two files in the result.');
        
        // Verify that both files are present in the result
        System.assert(result.containsKey('Test File 1'), 'Result should contain Test File 1.');
        System.assert(result.containsKey('Test File 2'), 'Result should contain Test File 2.');

        // Verify the content of the file is correctly base64 encoded
        String expectedBase64File1 = EncodingUtil.base64Encode(Blob.valueOf('This is a test file content 1'));
        String expectedBase64File2 = EncodingUtil.base64Encode(Blob.valueOf('This is a test file content 2'));
        
        System.assertEquals(expectedBase64File1, result.get('Test File 1'), 'Base64 content for Test File 1 should match.');
        System.assertEquals(expectedBase64File2, result.get('Test File 2'), 'Base64 content for Test File 2 should match.');
        
        // Test case with no files
        Account emptyAccount = new Account(Name = 'Empty Account');
        insert emptyAccount;
        
        //Test.startTest();
        Map<String, String> resultNoFiles = filePreviewAndDownloadController.getRelatedFilesByRecordId(emptyAccount.Id);
        //Test.stopTest();
        
        // Assertions for no files found
        System.assertNotEquals(null, resultNoFiles, 'Result map should not be null.');
        System.assertEquals(0, resultNoFiles.size(), 'There should be no files in the result for an empty account.');
    }
}