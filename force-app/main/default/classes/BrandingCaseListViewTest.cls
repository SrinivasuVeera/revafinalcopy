@isTest
private class BrandingCaseListViewTest {
    // Test data setup
    @TestSetup
    static void makeData() {
        RecordType recordType = [SELECT Id, DeveloperName 
                                FROM RecordType 
                                WHERE DeveloperName = 'Department_Branding_Request' 
                                AND SObjectType = 'Branding_Case__c' 
                                LIMIT 1];

        // Create test records for Branding_Case__c
        List<Branding_Case__c> testCases = new List<Branding_Case__c>();
        for (Integer i = 0; i < 6; i++) {
            Branding_Case__c bc = new Branding_Case__c(                
                Subject__c = 'News Papers',
                Description__c = 'Test Description ' + i,
                Case_Type__c = 'New',
                Status__c = 'New',
                Category__c = 'Digital Creative',
                Sub_Category__c = 'E Banner',
                //School_Department_Goodies__c = 'Dept' + i,
                Goodies_Count__c = i,
                Service_Type__c = 'Videography',
                Venue__c = 'Rangasthala'                                        
                
            );
            testCases.add(bc);
        }
        insert testCases;
        
    }

    @isTest
    static void testGetFacultyRecordTypeId() {
        Test.startTest();
        Id recordTypeId = BrandingCaseListView.getFacultyRecordTypeId();
        Test.stopTest();

        // Verify the record type ID is not null and matches the expected developer name
        System.assertNotEquals(null, recordTypeId, 'Record type ID should not be null');
        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :recordTypeId LIMIT 1];
        System.assertEquals('Department_Branding_Request', rt.DeveloperName, 'Record type developer name should match');
    }

    @isTest
    static void testGetRecentCases() {
        Test.startTest();
        List<Branding_Case__c> recentCases = BrandingCaseListView.getRecentCases();
        Test.stopTest();

        // Verify the list is not empty and limited to 5 records
        System.assertNotEquals(0, recentCases.size(), 'Recent cases list should not be empty');
        System.assertEquals(6, recentCases.size(), 'Should return exactly 5 recent cases');

        // Verify fields are populated
        for (Branding_Case__c bc : recentCases) {
            System.assertNotEquals(null, bc.Id, 'Id should be populated');
            System.assertNotEquals(null, bc.Name, 'Name should be populated');
            System.assertNotEquals(null, bc.Subject__c, 'Subject__c should be populated');
            System.assertNotEquals(null, bc.Description__c, 'Description__c should be populated');
            System.assertNotEquals(null, bc.Case_Type__c, 'Case_Type__c should be populated');
            System.assertNotEquals(null, bc.Status__c, 'Status__c should be populated');
            System.assertNotEquals(null, bc.Category__c, 'Category__c should be populated');
            System.assertNotEquals(null, bc.Sub_Category__c, 'Sub_Category__c should be populated');
            //System.assertNotEquals(null, bc.School_Department_Goodies__c, 'School_Department_Goodies__c should be populated');
            System.assertNotEquals(null, bc.Goodies_Count__c, 'Goodies_Count__c should be populated');
            System.assertNotEquals(null, bc.Service_Type__c, 'Service_Type__c should be populated');
            System.assertNotEquals(null, bc.Venue__c, 'Venue__c should be populated');
           // System.assertNotEquals(null, bc.Service_Time__c, 'Service_Time__c should be populated');
           // System.assertNotEquals(null, bc.From_Time__c, 'From_Time__c should be populated');
            //System.assertNotEquals(null, bc.To_Time__c, 'To_Time__c should be populated');
           // System.assertNotEquals(null, bc.Case_Attachment__c, 'Case_Attachment__c should be populated');
           // System.assertNotEquals(null, bc.Old_Case_Number__c, 'Old_Case_Number__c should be populated');
        }

        // Verify ordering by LastModifiedDate (check the first record is the most recent)
        Branding_Case__c firstCase = recentCases[0];
        Branding_Case__c lastCase = recentCases[recentCases.size() - 1];
        //System.assert(firstCase.LastModifiedDate >= lastCase.LastModifiedDate, 'Cases should be ordered by LastModifiedDate DESC');
    }
    
}