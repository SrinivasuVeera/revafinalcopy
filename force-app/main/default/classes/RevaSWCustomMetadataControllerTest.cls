@isTest
public class RevaSWCustomMetadataControllerTest {
    
    @isTest
    static void testCalculateHostelFee() {
        Test.startTest();
        
        // Create active academic year record
        REVA_Hostel_Academic_Year__c activeAcademicYear = new REVA_Hostel_Academic_Year__c(
            Name = '2024-2025', 
            Is_Active_Academic__c = false
        );
        insert activeAcademicYear;
        
        // Create test hostel fee structure records
        List<Hostel_Fee_Structure__c> hostelSettings = new List<Hostel_Fee_Structure__c>{
            new Hostel_Fee_Structure__c(
                Name = 'Single Premium Final Year Boys',
                REVA_Hostel_Academic_Year__c = activeAcademicYear.Id,
                Hostel_Room_Fees__c = 194000,
                Occupancy__c = 'Single',
                Is_Final_Year__c = true,
                Premium__c = true,
                Gender__c = 'Boys'
            ),
                new Hostel_Fee_Structure__c(
                    Name = 'Single Premium Non-Final Year Boys',
                    REVA_Hostel_Academic_Year__c = activeAcademicYear.Id,
                    Hostel_Room_Fees__c = 271000,
                    Occupancy__c = 'Single',
                    Is_Final_Year__c = false,
                    Premium__c = true,
                    Gender__c = 'Boys'
                )
                };
                    insert hostelSettings;
        activeAcademicYear.Is_Active_Academic__c = true;
         update activeAcademicYear;
        
        // Fetch an existing User with a Role (System Admin)
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true AND UserRoleId != NULL LIMIT 1];
        
        // Create test Account with the admin user as the Owner
        Account testAccount = new Account(
            Name = 'Test Student Account',
            OwnerId = adminUser.Id // Ensuring the account owner has a role
        );
        insert testAccount;
        
        // Create test Contact linked to Account
        Contact testContact = new Contact(
            FirstName = 'Test', 
            LastName = 'User', 
            hed__Gender__c = 'Male',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Fetch Student Profile for Community Users
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        
        // Create test Community User without UserRoleId
        User testUser = new User(
            FirstName = 'Test', 
            LastName = 'User',
            ContactId = testContact.Id,
            Username = 'testuser@example.com',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            ProfileId = studentProfile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        System.runAs(testUser) {
            // Test case 1: Final year student with matching setting
            revaSWCustomMetadataController.HostelFeeResponse result1 = revaSWCustomMetadataController.calculateHostelFee('Single', true, true);
            System.assertEquals(194000, result1.hostelFee, 'Expected hostelFee to be 194000');
            
            // Test case 2: Non-final year student with matching setting
            revaSWCustomMetadataController.HostelFeeResponse result2 = revaSWCustomMetadataController.calculateHostelFee('Single', true, false);
            System.assertEquals(271000, result2.hostelFee, 'Expected hostelFee to be 271000');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetAllRoomPrices() {
        Test.startTest();
        
        // Create active academic year record
        REVA_Hostel_Academic_Year__c activeAcademicYear = new REVA_Hostel_Academic_Year__c(
            Name = '2024-2025',
            Is_Active_Academic__c = false
        );
        insert activeAcademicYear;
        
       
        // Insert hostel fee structure records
        List<Hostel_Fee_Structure__c> hostelSettings = new List<Hostel_Fee_Structure__c>{
            new Hostel_Fee_Structure__c(
                Name = 'TestRoom1',
                REVA_Hostel_Academic_Year__c = activeAcademicYear.Id,
                Hostel_Room_Fees__c = 50000,
                Occupancy__c = '4',
                Gender__c = 'Boys'
            ),
                new Hostel_Fee_Structure__c(
                    Name = 'TestRoom2',
                    REVA_Hostel_Academic_Year__c = activeAcademicYear.Id,
                    Hostel_Room_Fees__c = 75000,
                    Occupancy__c = '3',
                    Gender__c = 'Boys'
                )
                };
                    insert hostelSettings;
        
         activeAcademicYear.Is_Active_Academic__c = true;
         update activeAcademicYear;
        
        
        // Call the method to test
        List<revaSWCustomMetadataController.RoomPriceResponse> result = revaSWCustomMetadataController.getAllRoomPrices();
        
        // Verify the result
        System.assertEquals(2, result.size(), 'Expected 2 room prices');
        System.assertEquals(50000, result[0].price, 'Expected price to be 50000');
        System.assertEquals(75000, result[1].price, 'Expected price to be 75000');
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetAllCustomMetadata() {
        Test.startTest();
        // Call the method
        List<RSW_Manodhaara_CMT__mdt> result = revaSWCustomMetadataController.getAllCustomMetadata();
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, result.size(), 'Unexpected number of records returned');
        // Add more assertions as needed to verify the returned data
    }
    
    @isTest
    static void testGetHostelCustomMetadata() {
        Test.startTest();
        // Call the method
        List<Reva_Hostel_Setting__mdt> result = revaSWCustomMetadataController.getHostelCustomMetadata();
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, result.size(), 'Unexpected number of records returned');
        // Add more assertions as needed to verify the returned data
    }
}