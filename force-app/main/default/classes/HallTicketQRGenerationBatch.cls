global class HallTicketQRGenerationBatch
    implements Database.Batchable<SObject>, Database.Stateful {

    /* =========================
       Static / Cached Variables
       ========================= */
    private static Blob cachedKey;
    private static final String KEY_NAME = 'DefaultKey';

    /* =========================
       START
       ========================= */
    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id,
                   SRN_Number__c,
                   Program_Batch__c,
                   Active_Semester__r.Name
            FROM Contact
            WHERE Student_Status__c = 'Pursuing'
              AND Record_Type_Name__c = 'Student'
              AND Active_Semester__r.Name != null
              AND Program_Batch__c != null
        ]);
    }

    /* =========================
       EXECUTE
       ========================= */
    global void execute(Database.BatchableContext bc, List<Contact> scope) {

        /* ---- Collect Program Batches ---- */
        Set<Id> programBatchIds = new Set<Id>();
        for (Contact con : scope) {
            programBatchIds.add(con.Program_Batch__c);
        }

        /* ---- Get Record Type ---- */
        Id recordTypeId = Schema.SObjectType.Rve_Exam_Notification__c
            .getRecordTypeInfosByDeveloperName()
            .get('hed_IA_Notification')
            .getRecordTypeId();

        /* ---- Query Exam Notifications ONCE ---- */
        Map<Id, Rve_Exam_Notification__c> notificationByBatch = new Map<Id, Rve_Exam_Notification__c>();

        for (Rve_Exam_Notification__c notif : [
            SELECT Id,
                   hed_Program_Batch__c,
                   Rve_Semester__r.Name,
                   hed_IA_Type__c
            FROM Rve_Exam_Notification__c
            WHERE Rve_Publish__c = true
              AND RecordTypeId = :recordTypeId
              AND hed_Program_Batch__c IN :programBatchIds
        ]) {
            notificationByBatch.put(notif.hed_Program_Batch__c, notif);
        }

        /* ---- Process Contacts ---- */
        List<Contact> contactsToUpdate = new List<Contact>();

        for (Contact con : scope) {

            Rve_Exam_Notification__c examNotification =
                notificationByBatch.get(con.Program_Batch__c);

            if (examNotification == null) {
                continue;
            }

            String encryptedQR = encryptJSON(con, examNotification);

            if (encryptedQR != null) {
                con.HallTicket_QR_Data__c = encryptedQR;
                contactsToUpdate.add(con);
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }

    /* =========================
       FINISH
       ========================= */
    global void finish(Database.BatchableContext bc) {
        System.debug('HallTicket QR Batch finished successfully');
    }

    /* =========================
       ENCRYPTION
       ========================= */
    private static String encryptJSON(
        Contact con,
        Rve_Exam_Notification__c examNotification
    ) {

        Map<String, Object> data = new Map<String, Object>{
            'SRN'      => con.SRN_Number__c,
            'SemName'  => examNotification.Rve_Semester__r.Name,
            'ExamType' => examNotification.hed_IA_Type__c
        };

        String jsonStr = JSON.serialize(data);

        Blob key = getKey();
        Blob iv  = Crypto.generateAesKey(128);

        Blob cipherText = Crypto.encrypt(
            'AES256',
            key,
            iv,
            Blob.valueOf(jsonStr)
        );

        String macInput =
            EncodingUtil.base64Encode(iv) +
            EncodingUtil.base64Encode(cipherText);

        Blob hmac = Crypto.generateMac(
            'HmacSHA256',
            Blob.valueOf(macInput),
            key
        );

        return String.join(new List<String>{
            EncodingUtil.base64Encode(iv),
            EncodingUtil.base64Encode(cipherText),
            EncodingUtil.base64Encode(hmac)
        }, ':');
    }

    /* =========================
       KEY CACHE
       ========================= */
    private static Blob getKey() {

        if (cachedKey == null) {
            QR_Key_Store__mdt rec = [
                SELECT AES_Key__c
                FROM QR_Key_Store__mdt
                WHERE DeveloperName = :KEY_NAME
                  AND Is_Active__c = true
                LIMIT 1
            ];
            cachedKey = EncodingUtil.base64Decode(rec.AES_Key__c);
        }
        return cachedKey;
    }
}