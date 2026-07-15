public without sharing class RevaExamPhotocopyRevaluationController {
    
    @AuraEnabled
    public static String getLoggedInUserContactId() {
        try {
            User currentUser = [
                SELECT ContactId  
                FROM User  
                WHERE Id = :UserInfo.getUserId()  
                AND (Profile.Name = 'Student Profile' OR Profile.Name = 'Student Portal Profile')  
                AND Contact.RecordType.Name = 'Student'  
                LIMIT 1
            ];
            
            return String.isBlank(currentUser.ContactId) ? '' : currentUser.ContactId;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Contact ID: ' + e.getMessage());
        }
    }
    
   
     @AuraEnabled
public static void processStudentApplications(List<Map<String, String>> applications) {
    if (applications == null || applications.isEmpty()) {
        throw new AuraHandledException('No valid application data received.');
    }

    try {
        List<Student_Fee__c> studentFees = new List<Student_Fee__c>();
        Map<Id, hed__Term_Grade__c> resultRecordMap = new Map<Id, hed__Term_Grade__c>();
        Set<Id> resultRecordIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        // Step 1: Collect Result record IDs
        for (Map<String, String> application : applications) {
            resultRecordIds.add(Id.valueOf(application.get('resultRecordId')));
        }

        // Step 2: Query existing Result records
        List<hed__Term_Grade__c> existingResults = [
            SELECT Id, AppliedForRevaluation__c, AppliedForPhotoCopy__c,
                   Course__c, Course__r.hed__Course_ID__c,Course__r.Name,
                   hed__Contact__c, hed__Term__r.Rve_SEE_Result_Date__c,Results_Announced_Date__c,Revaluation_End_Date__c, Photocopy_End_Date__c
            FROM hed__Term_Grade__c
            WHERE Id IN :resultRecordIds
        ];
        for (hed__Term_Grade__c result : existingResults) {
            resultRecordMap.put(result.Id, result);
            contactIds.add(result.hed__Contact__c);
        }

        // Step 3: Fetch Fee Criteria records
        Map<String, Id> feePaymentCriteriaMap = new Map<String, Id>();
        for (Fee_Payment_Criteria__c feeCriteria : [
            SELECT Id, Name FROM Fee_Payment_Criteria__c
            WHERE Name IN ('Revaluation Fee', 'Photocopy Fee')
        ]) {
            feePaymentCriteriaMap.put(feeCriteria.Name, feeCriteria.Id);
        }

        // Step 4: Prepare fee records and mapping
        Map<Id, Map<String, Student_Fee__c>> resultToFeeMap = new Map<Id, Map<String, Student_Fee__c>>();

        for (Map<String, String> application : applications) {
            try {
                Id resultRecordId = Id.valueOf(application.get('resultRecordId'));
                Id contactId = Id.valueOf(application.get('contactId'));
                String feeType = application.get('feeType'); // 'RV Fee' or 'PC Fee'
                Decimal amount = Decimal.valueOf(application.get('amount'));

                hed__Term_Grade__c resultRecord = resultRecordMap.get(resultRecordId);

                if (resultRecord == null || resultRecord.hed__Term__r.Rve_SEE_Result_Date__c == null) {
                    throw new AuraHandledException('Semester result date missing for record ID: ' + resultRecordId);
                }

                Date semesterResultDate = resultRecord.hed__Term__r.Rve_SEE_Result_Date__c;
                //Date dueDate = feeType == 'PC Fee' ? semesterResultDate.addDays(5) : semesterResultDate.addDays(10);
                Date dueDate = feeType == 'PC Fee' ? semesterResultDate.addDays(4) : semesterResultDate.addDays(9);

                // Create Student Fee
                Student_Fee__c studentFee = new Student_Fee__c();
               // studentFee.Name = feeType + ' ' + resultRecord.Course__r.hed__Course_ID__c + ' ' + Date.today().year();
               studentFee.Name = feeType + '-' + resultRecord.Course__r.Name + '-' + resultRecord.Course__r.hed__Course_ID__c + ' ' + Date.today().year();
                studentFee.Contact__c = contactId;
                studentFee.Fee_Type__c = feeType;
                studentFee.Amount__c = amount;
                studentFee.Actual_Program_Fee__c = amount;
               // studentFee.Due_Date__c = dueDate;
                studentFee.Due_Date__c = System.today(); 
                studentFee.Fee_Payment_Criteria__c = feePaymentCriteriaMap.get(
                    feeType == 'RV Fee' ? 'Revaluation Fee' : 'Photocopy Fee'
                );

                studentFees.add(studentFee);

                // Track mapping of this fee to result + type
                if (!resultToFeeMap.containsKey(resultRecordId)) {
                    resultToFeeMap.put(resultRecordId, new Map<String, Student_Fee__c>());
                }
                resultToFeeMap.get(resultRecordId).put(feeType, studentFee);

                // Update result flags
                if (feeType == 'RV Fee') {
                    resultRecord.AppliedForRevaluation__c = true;
                } else if (feeType == 'PC Fee') {
                    resultRecord.AppliedForPhotoCopy__c = true;
                }

            } catch (Exception e) {
                System.debug('Error processing application: ' + JSON.serialize(application) + ' | ' + e.getMessage());
                continue;
            }
        }

        // Step 5: Insert all Student Fee records
        if (!studentFees.isEmpty()) {
            insert studentFees;

            // Step 6: Assign inserted fee record IDs to Result records
            for (Id resultId : resultToFeeMap.keySet()) {
                hed__Term_Grade__c resultRecord = resultRecordMap.get(resultId);
                Map<String, Student_Fee__c> feeMap = resultToFeeMap.get(resultId);

                if (feeMap.containsKey('RV Fee')) {
                    resultRecord.Revaluation_Fee__c = feeMap.get('RV Fee').Id;
                }
                if (feeMap.containsKey('PC Fee')) {
                    resultRecord.Photocopy_Fee__c = feeMap.get('PC Fee').Id;
                }
            }

            // Step 7: Update Result records with lookup references
            update resultRecordMap.values();
        }

    } catch (DmlException e) {
        throw new AuraHandledException('Failed to process applications: ' + e.getMessage());
    }
}

    
    }