@isTest
public class HostelNotificationTest {

    static String getValidMaximumOccupancy() {
        Schema.DescribeFieldResult fieldResult = Reva_Hostel_Room__c.Maximum_Occupancy__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        return values.isEmpty() ? null : values[0].getValue();
    }

    static String getValidRoomType() {
        return 'Student';
    }

    static String getValidRoomCategory() {
        return 'Eng CS';
    }

    static Map<String, String> getValidDormitoryAndBlock() {
        Map<String, String> result = new Map<String, String>();
        result.put('Dormitory_Type__c', 'Girls');
        result.put('Block__c', 'G1'); // make sure this is a valid picklist value
        return result;
    }

    static testMethod void testCreateAndSendAnnouncementWithFile() {
        Map<String, String> values = getValidDormitoryAndBlock();
        String block = values.get('Block__c');
        String maxOccupancy = getValidMaximumOccupancy();

        // Create a student
        Contact student = new Contact(FirstName='File', LastName='Test', Email='file@test.com');
        insert student;

        // Create a room
        Reva_Hostel_Room__c room = new Reva_Hostel_Room__c(
            Name='F001',
            Block__c=block,
            Dormitory_Type__c=values.get('Dormitory_Type__c'),
            Room_Type__c=getValidRoomType(),
            Room_Category__c=getValidRoomCategory(),
            Maximum_Occupancy__c=maxOccupancy
        );
        insert room;

        // Create hostel request
        insert new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c=student.Id,
            Reva_Hostel_Room__c=room.Id,
            Status__c='Room Allotted',
            Type__c=maxOccupancy
        );

        // Insert dummy file
        ContentVersion cv = new ContentVersion(
            Title='Test File',
            PathOnClient='Test.pdf',
            VersionData=Blob.valueOf('Test content')
        );
        insert cv;

        ContentVersion insertedCv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        String uploadedFileId = insertedCv.ContentDocumentId;

        Test.startTest();
        HostelNotification.createAndSendAnnouncement(
            'Announcement with File',
            'Test file announcement',
            new List<String>{block},
            uploadedFileId,
            System.now().addHours(-1),
            System.now().addDays(1)
        );
        Test.stopTest();

        List<Notification__c> notifications = [SELECT Id FROM Notification__c];
        System.assert(notifications.size() > 0, 'Notification not created with file.');
    }

    static testMethod void testCreateAndSendAnnouncementWithoutFile() {
        Map<String, String> values = getValidDormitoryAndBlock();
        String block = values.get('Block__c');
        String maxOccupancy = getValidMaximumOccupancy();

        Contact student = new Contact(FirstName='Test', LastName='Student', Email='test@student.com');
        insert student;

        Reva_Hostel_Room__c room = new Reva_Hostel_Room__c(
            Name='101',
            Block__c=block,
            Dormitory_Type__c=values.get('Dormitory_Type__c'),
            Room_Type__c=getValidRoomType(),
            Room_Category__c=getValidRoomCategory(),
            Maximum_Occupancy__c=maxOccupancy
        );
        insert room;

        insert new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c=student.Id,
            Reva_Hostel_Room__c=room.Id,
            Status__c='Room Allotted',
            Type__c=maxOccupancy
        );

        Test.startTest();
        HostelNotification.createAndSendAnnouncement(
            'Test Announcement',
            'This is a test message',
            new List<String>{block},
            null,
            System.now().addHours(-2),
            System.now().addDays(1)
        );
        Test.stopTest();

        List<Notification__c> notifs = [SELECT Id FROM Notification__c];
        System.assert(notifs.size() > 0, 'Notification not created.');
    }

   static testMethod void testGetUnreadActiveNotifications() {
    // Step 1: Create Account
    Account portalAccount = new Account(Name = 'Portal Account');
    insert portalAccount;

    // Step 2: Create Contact linked to Account
    Contact portalContact = new Contact(
        FirstName = 'Portal',
        LastName = 'hanu',
        Email = 'portaluser@example.com',
        AccountId = portalAccount.Id
    );
    insert portalContact;

 List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name LIKE '%Community%' OR Name LIKE '%Partner%' OR Name LIKE '%Customer%' LIMIT 1];
System.assert(profiles.size() > 0, '⚠️ No community profile found. Check profile names in your org.');
Profile communityProfile = profiles[0];
       
    // Step 4: Create portal user (Experience Cloud User)
    User portalUser = new User(
        Username = 'portaluser-' + System.currentTimeMillis() + '@example.com',
        Alias = 'ptuser',
        Email = 'portaluser@example.com',
        LastName ='hanu',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = communityProfile.Id,
        TimeZoneSidKey = 'Asia/Kolkata',
        ContactId = portalContact.Id
    );
    insert portalUser;

    // Step 5: Insert Announcement & Notification for the contact
    Announcement__c ann = new Announcement__c(
        Name = 'Portal Announcement',
        Message_Body__c = 'Portal message',
        Selected_Blocks__c = 'G1',
        Is_Sent__c = true,
        Sent_Date__c = System.today(),
        Display_Start_Time__c = System.now().addHours(-1),
        Display_End_Time__c = System.now().addHours(2)
    );
    insert ann;

    Notification__c notif = new Notification__c(
        record_name__c = portalContact.Id,
        Message__c = 'Portal notification',
        Announcement__c = ann.Id,
        Is_Read__c = false,
        Start_Date_Time__c = System.now().addHours(-1),
        End_Date_Time__c = System.now().addHours(2)
    );
    insert notif;

    // Step 6: Call method as portal user
    System.runAs(portalUser) {
        Test.startTest();
        Map<String, Object> result = HostelNotification.getUnreadActiveNotifications();
        Test.stopTest();

        System.assert(result.containsKey('notification'), 'Notification key missing');
        System.assert(result.containsKey('title'), 'Title key missing');
        System.assert(result.containsKey('fileUrl'), 'File URL missing');
    }
}


    static testMethod void testGetBlockPicklistValues() {
        Test.startTest();
        List<String> blocks = HostelNotification.getBlockPicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, blocks, 'Block picklist should not be null');
    }

    static testMethod void testGetCurrentUserName() {
        Test.startTest();
        String name = HostelNotification.getCurrentUserName();
        Test.stopTest();

        System.assertNotEquals(null, name, 'User name should not be null');
    }

    static testMethod void testMarkNotificationAsRead() {
        Contact c = new Contact(FirstName='Read', LastName='Tester', Email='read@test.com');
        insert c;

        Announcement__c ann = new Announcement__c(
            Name='Read Test',
            Message_Body__c='To mark read',
            Is_Sent__c=true,
            Sent_Date__c=System.today(),
            Display_Start_Time__c=System.now().addHours(-1),
            Display_End_Time__c=System.now().addDays(1)
        );
        insert ann;

        Notification__c notif = new Notification__c(
            record_name__c=c.Id,
            Message__c='Mark read',
            Announcement__c=ann.Id,
            Is_Read__c=false,
            Start_Date_Time__c=System.now().addHours(-1),
            End_Date_Time__c=System.now().addDays(1)
        );
        insert notif;

        Test.startTest();
        HostelNotification.markNotificationAsRead(notif.Id);
        Test.stopTest();

        Notification__c updated = [SELECT Is_Read__c FROM Notification__c WHERE Id = :notif.Id];
        System.assertEquals(true, updated.Is_Read__c, 'Notification should be marked as read');
    }
}