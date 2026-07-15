public with sharing class HostelRegistrationPage {

    public Contact contactRecord { get; set; }
    public Reva_Hostel_Request__c hostelRecord { get; set; }
    public Reva_Hostel_Room__c hostelRoomRecord { get; set; }
    public hed__Address__c mailingAddress { get; set; }
    public hed__Address__c permanentAddress { get; set; }
    public Student_Fee__c hostelFeeRecord { get; set; }
    public Boolean hasHostelFeeRecord { get; set; }

    public List<Schema.FieldSetMember> contactFields { get; private set; }
    public List<Schema.FieldSetMember> hostelFields { get; private set; }
    public List<Schema.FieldSetMember> hostelRoomFields { get; private set; }

    public List<List<Schema.FieldSetMember>> contactFieldRows { get; private set; }
    public List<List<Schema.FieldSetMember>> hostelFieldRows { get; private set; }
    public List<List<Schema.FieldSetMember>> hostelRoomFieldRows { get; private set; }

    public String passportPhotoURL { get; set; }
    public String logoURL { get; set; }

    private static final String PHOTO_URL_BASE = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=';

    public HostelRegistrationPage() {
        String hostelRequestIdParam = ApexPages.currentPage().getParameters().get('id');

        if (String.isNotBlank(hostelRequestIdParam)) {
            try {
                Id hostelRequestId = Id.valueOf(hostelRequestIdParam);

                hostelRecord = [
                    SELECT Id, Name, Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.Email, Hostel_Room_Request_For__r.MobilePhone,
                           Hostel_Room_Request_For__r.Application_Number__c, Hostel_Room_Request_For__r.SRN_Number__c, Hostel_Room_Request_For__r.hed__Gender__c,
                           Hostel_Room_Request_For__r.Father_Name__c, Hostel_Room_Request_For__r.rve_Father_s_Name__c, Hostel_Room_Request_For__r.Father_Email_ID__c,
                           Hostel_Room_Request_For__r.Father_Mobile_Number__c, Hostel_Room_Request_For__r.Mother_Name__c, Hostel_Room_Request_For__r.Mother_Name1__c,
                           Hostel_Room_Request_For__r.Mother_Mobile_Number__c, Hostel_Room_Request_For__r.Mother_Email_ID__c, Hostel_Room_Request_For__r.Program_Batch1__c,
                           Hostel_Room_Request_For__r.School_Name__c, Hostel_Room_Request_For__r.State__c, Hostel_Room_Request_For__r.City__c,
                           Type__c, Status__c, Reva_Hostel_Premium_Room__c, Reva_Hostel_JoiningDate__c, Warden__c, ChiefWarden__c,
                           Hostel_Room_Request_For__r.Birthdate, Hostel_Room_Request_For__r.hed__Current_Address__c, Hostel_Room_Request_For__r.hed__Mailing_Address_Inactive__c,
                           Reva_Hostel_Room__c, Reva_Hostel_Room__r.Block__c, Reva_Hostel_Room__r.Floor__c,Room_Number__c
                    FROM Reva_Hostel_Request__c
                    WHERE Id = :hostelRequestId
                    LIMIT 1
                ];

                contactRecord = hostelRecord.Hostel_Room_Request_For__r;

                loadPassportPhoto(contactRecord.Id);
                loadAddressData(contactRecord.Id);
                loadFeeData(contactRecord.Id);

                if (hostelRecord.Reva_Hostel_Room__c != null) {
                    hostelRoomRecord = [
                        SELECT Id, Block__c, Floor__c
                        FROM Reva_Hostel_Room__c
                        WHERE Id = :hostelRecord.Reva_Hostel_Room__c
                        LIMIT 1
                    ];
                }
            } catch (Exception e) {
                contactRecord = new Contact();
                hostelRecord = new Reva_Hostel_Request__c();
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Invalid Hostel Request Id or data not found.'
                ));
            }
        } else {
            contactRecord = new Contact();
            hostelRecord = new Reva_Hostel_Request__c();
        }

        loadFieldSets();
        loadRoomFieldSet();
        logoURL = URL.getOrgDomainUrl().toExternalForm() + '/resource/REVA_LOGO';
    }

    private void loadPassportPhoto(String contactId) {
        List<ContentDocumentLink> cdls = [
            SELECT ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :contactId
              AND ContentDocument.Title IN ('Passport Photo', 'Applicant Photo')
            LIMIT 1
        ];
        if (!cdls.isEmpty()) {
            passportPhotoURL = PHOTO_URL_BASE + cdls[0].ContentDocument.LatestPublishedVersionId;
        }
    }

    private void loadHostelData() {
        List<Reva_Hostel_Request__c> reqs = [
            SELECT Id, Type__c, Status__c, Name, Reva_Hostel_JoiningDate__c,
                   Reva_Hostel_Premium_Room__c, Warden__c, ChiefWarden__c,
                   Room_Number__c, Reva_Hostel_Room__r.Block__c, Reva_Hostel_Room__r.Floor__c
            FROM Reva_Hostel_Request__c
            WHERE Hostel_Room_Request_For__c = :contactRecord.Id
            LIMIT 1
        ];

        if (!reqs.isEmpty()) {
            hostelRecord = reqs[0];
            if (hostelRecord.Room_Number__c != null) {
                try {
                    hostelRoomRecord = [
                        SELECT Id, Name, Block__c, Floor__c
                        FROM Reva_Hostel_Room__c
                        WHERE Id = :hostelRecord.Room_Number__c
                        LIMIT 1
                    ];
                } catch (Exception e) {
                    hostelRoomRecord = new Reva_Hostel_Room__c();
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.WARNING,
                        'Unable to load hostel room details.'
                    ));
                }
            } else {
                hostelRoomRecord = new Reva_Hostel_Room__c();
            }
        } else {
            hostelRecord = null;
            hostelRoomRecord = new Reva_Hostel_Room__c();
        }
    }

    private void loadRoomFieldSet() {
        hostelRoomFields = SObjectType.Reva_Hostel_Room__c.FieldSets.Hostel_Room.getFields();
        hostelRoomFieldRows = toRowsOfTwo(hostelRoomFields);
    }

    private void loadAddressData(String contactId) {
        List<hed__Address__c> addresses = [
            SELECT Id,Name, hed__Address_Type__c,
                   hed__MailingStreet__c,hed__MailingState__c, hed__MailingCity__c, hed__MailingCountry__c, Post_Office_Name__c,hed__MailingPostalCode__c
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :contactId
        ];

        for (hed__Address__c ad : addresses) {
            if (ad.hed__Address_Type__c == 'Mailing Address') {
                mailingAddress = ad;
            } else if (ad.hed__Address_Type__c == 'Permanent Address') {
                permanentAddress = ad;
            }
            if (mailingAddress != null && permanentAddress != null) {
            break;
        }
        }
    }
        private void loadFeeData(String contactId) {
           List<Student_Fee__c> fees = [
            SELECT Name, Amount__c, Amount_Paid__c, Amount_Pending__c
            FROM Student_Fee__c
            WHERE Contact__c = :contactId
            ];

           hasHostelFeeRecord = false;

      for (Student_Fee__c fee : fees) {
         if (fee.Name == 'Hostel Fee 2025-26') {
            hostelFeeRecord = fee;
            hasHostelFeeRecord = true;
            break;
            }
         }
   }
    private void loadFieldSets() {
        contactFields = orderFields(
            SObjectType.Contact.FieldSets.Hostel_Detailes.getFields(),
            new List<String>{
                'Application_Number__c', 'SRN_Number__c', 'FirstName', 'LastName',
                'MobilePhone', 'Email', 'hed__Gender__c', 'rve_Father_s_Name__c',
                'Father_Mobile_Number__c', 'Father_Email_ID__c', 'Mother_Name__c',
                'Mother_Mobile_Number__c', 'Mother_Email_ID__c', 'Program_Batch1__c',
                'School_Name__c', 'State__c', 'City__c', 'hed__Current_Address__c',
                'hed__Mailing_Address_Inactive__c'
            }
        );

        hostelFields = orderFields(
            SObjectType.Reva_Hostel_Request__c.FieldSets.Hostel_Registration.getFields(),
            new List<String>{
                'Reva_Hostel_Request_Number__c', 'Type__c', 'Status__c',
                'Reva_Hostel_Premium_Room__c', 'Reva_Hostel_JoiningDate__c',
                'Warden__c', 'ChiefWarden__c'
            }
        );

        hostelRoomFields = orderFields(
            SObjectType.Reva_Hostel_Room__c.FieldSets.Hostel_Room.getFields(),
            new List<String>{ 'Block__c', 'Floor__c' }
        );

        contactFieldRows = toRowsOfTwo(contactFields);
        hostelFieldRows = toRowsOfTwo(hostelFields);
        hostelRoomFieldRows = toRowsOfTwo(hostelRoomFields);
    }

    private List<Schema.FieldSetMember> orderFields(List<Schema.FieldSetMember> original, List<String> desiredOrder) {
        Map<String, Schema.FieldSetMember> byApi = new Map<String, Schema.FieldSetMember>();
        for (Schema.FieldSetMember f : original) byApi.put(f.getFieldPath(), f);

        List<Schema.FieldSetMember> ordered = new List<Schema.FieldSetMember>();
        for (String api : desiredOrder)
            if (byApi.containsKey(api)) ordered.add(byApi.get(api));

        for (Schema.FieldSetMember f : original)
            if (!ordered.contains(f)) ordered.add(f);

        return ordered;
    }

    private List<List<Schema.FieldSetMember>> toRowsOfTwo(List<Schema.FieldSetMember> fields) {
        List<List<Schema.FieldSetMember>> rows = new List<List<Schema.FieldSetMember>>();
        for (Integer i = 0; i < fields.size(); i += 2) {
            List<Schema.FieldSetMember> row = new List<Schema.FieldSetMember>{ fields[i] };
            if (i + 1 < fields.size()) row.add(fields[i + 1]);
            rows.add(row);
        }
        return rows;
    }

    public PageReference saveData() {
        try {
            if (contactRecord.Id == null) {
                insert contactRecord;
            }
            hostelRecord.Hostel_Room_Request_For__c = contactRecord.Id;
            insert hostelRecord;

            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.CONFIRM,
                'Hostel Registration Saved Successfully.'
            ));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                e.getMessage()
            ));
        }
        return null;
    }
}