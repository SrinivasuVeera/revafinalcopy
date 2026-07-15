public Without Sharing  class getMealBookingRecord {
    
    @AuraEnabled
    public static Reva_Meal_Booking__c getRecord(Id recordId) {
        Reva_Meal_Booking__c record = [Select Id, Reva_Meal_Booking_Status__c,
                                       Booking_For__r.Name, Booking_For__r.SRN_Number__c, Booking_For__r.Phone, Booking_For__r.File_Passport_Size_Photo__c
                                       FROM Reva_Meal_Booking__c WHERE id =:recordId LIMIT 1];
        return record;
    }
    
    @AuraEnabled
    public static String getContactImage(Id recordId) {
        try {
            // Validate input
            if (recordId == null) {
                throw new IllegalArgumentException('Record ID cannot be null.');
            }
    
            // Retrieve the meal booking or hostel leave request record
            List<Reva_Meal_Booking__c> mealRecord = getMealBooking(recordId);
            List<REVA_Hostel_Leave_Request__c> leaveReq = getHostelLeaveReq(recordId);
    
            String contactId = null;
    
            // Determine contact ID based on the record type
            if (!mealRecord.isEmpty()) {
                contactId = mealRecord[0].Booking_For__c;
            } else if (!leaveReq.isEmpty()) {
                contactId = leaveReq[0].Contact__c;
            }
    
            if (String.isBlank(contactId)) {
                return 'Record ID does not map to a valid contact.';
            }
    
            // Retrieve contact details
            List<Contact> con = [SELECT Id, SRN_Number__c, Application_Number__c FROM Contact WHERE Id = :contactId];
            if (con.isEmpty()) {
                return 'No contact found for the provided ID.';
            }
    
            // Determine identifier (SRN or Application Number)
            String identifier = String.isNotBlank(con[0].SRN_Number__c)
                ? con[0].SRN_Number__c
                : con[0].Application_Number__c;
    
            // Fetch image URL from ContentDocumentLink or Document
            String passportPhotoURL = getImageUrl(contactId, identifier);
            return passportPhotoURL != null ? passportPhotoURL : '';
    
        } catch (Exception ex) {
            // Log the exception for debugging
            System.debug('Exception in getContactImage: ' + ex.getMessage());
            return '';
        }
    }
    
    /**
     * Retrieves the meal booking record.
     */
    private static List<Reva_Meal_Booking__c> getMealBooking(Id recordId) {
        return [
            SELECT Id, Reva_Meal_Booking_Status__c, Booking_For__c
            FROM Reva_Meal_Booking__c
            WHERE Id = :recordId
            LIMIT 1
        ];
    }
    
    /**
     * Retrieves the hostel leave request record.
     */
    private static List<REVA_Hostel_Leave_Request__c> getHostelLeaveReq(Id recordId) {
        return [
            SELECT Id, Contact__c
            FROM REVA_Hostel_Leave_Request__c
            WHERE Id = :recordId
            LIMIT 1
        ];
    }
    
    /**
     * Fetches the image URL from ContentDocumentLink or Document.
     */
    private static String getImageUrl(String contactId, String identifier) {
        if (String.isBlank(contactId) || String.isBlank(identifier)) {
            return null;
        }
    
        // Try fetching the image from ContentDocumentLink
        List<ContentDocumentLink> cdls = [
            SELECT ContentDocument.LatestPublishedVersionId,
                   ContentDocument.FileExtension,
                   ContentDocument.LatestPublishedVersion.VersionData
            FROM ContentDocumentLink
            WHERE (ContentDocument.LatestPublishedVersion.Title = 'Passport Photo'
                  OR ContentDocument.LatestPublishedVersion.Title = 'Applicant Photo')
              AND LinkedEntityId = :contactId
            LIMIT 1
        ];
    
        if (!cdls.isEmpty()) {
            ContentDocumentLink cdl = cdls[0];
            return 'data:image/' + cdl.ContentDocument.FileExtension + ';charset=utf-8;base64,' +
                   EncodingUtil.base64Encode(cdl.ContentDocument.LatestPublishedVersion.VersionData);
        } else {
            // Fallback to fetching the image from Document folder
            return getDocumentImageUrl(identifier);
        }
    }
    
    /**
     * Fetches the image URL from the Document folder.
     */
    private static String getDocumentImageUrl(String identifier) {
        String searchKey = '%' + identifier + '%';
        List<Document> documents = [
            SELECT Id, Name
            FROM Document
            WHERE Folder.Name = 'student images' AND Name LIKE :searchKey
            LIMIT 1
        ];
    
        if (!documents.isEmpty()) {
            Document doc = documents[0];
            return URL.getOrgDomainURL().toExternalForm() + '/servlet/servlet.ImageServer?id=' + doc.Id + '&oid=' + UserInfo.getOrganizationId();
        }
    
        return null;
    }
    
    /********Newly added by veera on 02122025*******************************/
    @AuraEnabled    
    public static long getServerTime(){ 
        return Datetime.now().getTime();     
    }
    /********Changed ended here******************************/
    
}