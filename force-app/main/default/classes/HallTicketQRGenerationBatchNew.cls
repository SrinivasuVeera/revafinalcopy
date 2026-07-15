global class HallTicketQRGenerationBatchNew implements Database.Batchable<SObject> {

    private static Blob cachedKey;
    private static final String KEY_NAME = 'DefaultKey';
	private Date examDate;
    
    // Constructor
    global HallTicketQRGenerationBatchNew(Date examDate) {
      //  this.room = room;
        this.examDate = examDate;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {

       //   Date targetDate = Date.today().addDays(16); 
       //  Date targetDate = Date.newInstance(2026, 7, 8);

        return Database.getQueryLocator([
            SELECT Id,
                   Name,
                   Program_Batch__c,
                   Program_Batch__r.Name,
                   IA_1_Start_date__c,
                   IA_2_Start_date__c
            FROM hed__Term__c
            WHERE Record_Type_Name__c = 'Semester'
            AND Active__c = true
            AND (
                    IA_1_Start_date__c = :examDate
                 OR IA_2_Start_date__c = :examDate
            )
        ]);
    }
	
	    global void execute(Database.BatchableContext bc, List<hed__Term__c> scope) {

        //	Date targetDate = Date.today().addDays(16); 
        //    Date targetDate = Date.newInstance(2026, 7, 8);

        Map<Id, String> activeProgramBatchMap = new Map<Id, String>();
        Set<Id> programBatchIds = new Set<Id>();

        for (hed__Term__c sem : scope) {

            String iaType;

            if (sem.IA_1_Start_date__c == examDate) {
                iaType = 'IA 1';
            }
            else if (sem.IA_2_Start_date__c == examDate) {
                iaType = 'IA 2';
            }

            if (String.isBlank(iaType)) {
                continue;
            }

            activeProgramBatchMap.put(sem.Program_Batch__c, iaType);
            programBatchIds.add(sem.Program_Batch__c);

            System.debug('Program Batch : ' + sem.Program_Batch__r.Name +' --> ' + iaType);
        }

        if (programBatchIds.isEmpty()) {
            return;
        }

        List<Contact> contacts = [
            SELECT Id,
                   SRN_Number__c,
                   Program_Batch__c,
                   Program_Batch__r.Name,
                   Active_Semester__r.Name,
                   HallTicket_QR_Data__c
            FROM Contact
            WHERE SRN_Number__c != null
            AND Student_Status__c = 'Pursuing'
            AND Record_Type_Name__c = 'Student'
            AND Active_Semester__r.Name != null
            AND Program_Batch__c IN :programBatchIds
        ];

        List<Contact> contactsToUpdate = new List<Contact>();
		List<String> qrData = new List<String>();
            
        for (Contact con : contacts) {

            String iaType = activeProgramBatchMap.get(con.Program_Batch__c);

            if (String.isBlank(iaType)) {
                continue;
            }

            try {

                String encryptedQR = encryptJSON(con, iaType);

                if (String.isNotBlank(encryptedQR)) {
                    con.HallTicket_QR_Data__c = encryptedQR;
                    contactsToUpdate.add(con);
                    qrData.add(con.HallTicket_QR_Data__c);
                }

            } catch (Exception ex) {

                System.debug(
                    LoggingLevel.ERROR,
                    'Failed for Contact ' + con.Id + ' : ' + ex.getMessage()
                );
            }
        }

        if (!contactsToUpdate.isEmpty()) {
			System.debug('Size of Contact Records : '+contactsToUpdate.size());
            System.debug('Size of QR Records : '+qrData.size());
            
           Database.SaveResult[] results =
                Database.update(contactsToUpdate, false); 

            for (Integer i = 0; i < results.size(); i++) {

                if (!results[i].isSuccess()) {

                    for (Database.Error err : results[i].getErrors()) {

                        System.debug(
                            LoggingLevel.ERROR,
                            'Update failed for Contact ' +
                            contactsToUpdate[i].Id +
                            ' : ' +
                            err.getMessage()
                        );
                    }
                }
            }   
        }
    }
	
	    global void finish(Database.BatchableContext bc) {

        System.debug('HallTicket QR Batch completed successfully.');
    }
    
    private static String encryptJSON(Contact con, String IAtype) {
        
				Map<String, Object> data = new Map<String, Object>{
					'SRN'      => con.SRN_Number__c,
					'SemName'  => con.Active_Semester__r.Name,
					'ExamType' => IAtype
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