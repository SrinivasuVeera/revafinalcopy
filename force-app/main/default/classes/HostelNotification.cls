public without sharing class HostelNotification {

    @AuraEnabled
    public static void createAndSendAnnouncement(
        String announcementTitle,
        String messageBody,
        List<String> selectedBlocks,
        String uploadedFileId,
        Datetime startDateTime,
        Datetime endDateTime
    ) {
        // Step 1: Create Announcement
        Announcement__c announcement = new Announcement__c(
            Name = announcementTitle,
            Message_Body__c = messageBody,
            Selected_Blocks__c = String.join(selectedBlocks, ';'),
            Is_Sent__c = true,
            Sent_Date__c = System.today(),
            Display_Start_Time__c = startDateTime,
            Display_End_Time__c = endDateTime
        );
        insert announcement;

if (String.isNotBlank(uploadedFileId)) {
    // Try to get the ContentVersion (uploadedFileId must be version Id)
    List<ContentVersion> versionList = [
    SELECT Id, Title, ContentDocumentId
    FROM ContentVersion
    WHERE ContentDocumentId = :uploadedFileId
    ORDER BY CreatedDate DESC
    LIMIT 1
];

    if (!versionList.isEmpty()) {
        ContentVersion ver = versionList[0];

        // Link the file to the Announcement
        insert new ContentDocumentLink(
            ContentDocumentId = ver.ContentDocumentId,
            LinkedEntityId = announcement.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        // Create or get public URL
        String fileUrl;
        List<ContentDistribution> existing = [
            SELECT Id, DistributionPublicUrl
            FROM ContentDistribution
            WHERE ContentVersionId = :ver.Id
            LIMIT 1
        ];

        if (existing.isEmpty()) {
            ContentDistribution dist = new ContentDistribution();
            dist.Name = ver.Title;
            dist.ContentVersionId = ver.Id;
            dist.PreferencesAllowViewInBrowser = true;
            dist.PreferencesAllowOriginalDownload = true;
            dist.PreferencesExpires = false;
            insert dist;
            dist = [
    SELECT DistributionPublicUrl
    FROM ContentDistribution
    WHERE Id = :dist.Id
    LIMIT 1
];
fileUrl = dist.DistributionPublicUrl;
        } else {
            fileUrl = existing[0].DistributionPublicUrl;
        }

        // Update announcement with public file URL
        announcement.File_Url__c = fileUrl;
        update announcement;
        System.debug('📎 File URL saved to announcement: ' + fileUrl);
    } else {
        System.debug('❗ No ContentVersion found for uploadedFileId: ' + uploadedFileId);
    }
}
	
        // Step 3: Fetch Students
        List<Reva_Hostel_Request__c> hostelRequests = [
            SELECT Hostel_Room_Request_For__r.Id
            FROM Reva_Hostel_Request__c
            WHERE Reva_Hostel_Room__r.Block__c IN :selectedBlocks
              AND Hostel_Room_Request_For__r.Id != null
              AND (Status__c = 'Room Allotted' OR Status__c = 'Vacating Initiated')
        ];

        Set<Id> studentContactIds = new Set<Id>();
        for (Reva_Hostel_Request__c req : hostelRequests) {
            studentContactIds.add(req.Hostel_Room_Request_For__r.Id);
        }

        // Step 4: Create Notifications
        List<Notification__c> notifications = new List<Notification__c>();
        for (Id contactId : studentContactIds) {
            notifications.add(new Notification__c(
                record_name__c = contactId,
                Message__c = messageBody,
                Announcement__c = announcement.Id,
                Is_Read__c = false,
                Start_Date_Time__c = startDateTime,
                End_Date_Time__c = endDateTime
            ));
        }

        if (!notifications.isEmpty()) {
            insert notifications;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getBlockPicklistValues() {
        List<String> values = new List<String>();
        for (Schema.PicklistEntry entry : Reva_Hostel_Room__c.Block__c.getDescribe().getPicklistValues()) {
            values.add(entry.getValue());
        }
        return values;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getUnreadActiveNotifications() {
        Map<String, Object> response = new Map<String, Object>();
        try {
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
            if (contactId == null) return response;

            Datetime now = Datetime.now();
            List<Notification__c> notifications = [
                SELECT Id, Message__c, Start_Date_Time__c, End_Date_Time__c,
                       Announcement__r.Name, Announcement__r.Message_Body__c, Announcement__r.File_Url__c
                FROM Notification__c
                WHERE record_name__c = :contactId
                  AND Is_Read__c = false
                  AND Start_Date_Time__c <= :now
                  AND End_Date_Time__c >= :now
                LIMIT 1
            ];

            if (!notifications.isEmpty()) {
                Notification__c notif = notifications[0];
                response.put('notification', notif);
                response.put('fileUrl', notif.Announcement__r.File_Url__c);
                response.put('title', notif.Announcement__r.Name);
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error fetching notification: ' + e.getMessage());
        }
        return response;
    }

    @AuraEnabled(cacheable=true)
    public static String getCurrentUserName() {
        return [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()].Name;
    }

    @AuraEnabled
    public static void markNotificationAsRead(Id notificationId) {
        Notification__c notif = [SELECT Id FROM Notification__c WHERE Id = :notificationId LIMIT 1];
        notif.Is_Read__c = true;
        update notif;
    }
}