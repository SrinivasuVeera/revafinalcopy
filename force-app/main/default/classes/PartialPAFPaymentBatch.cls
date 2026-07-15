global class PartialPAFPaymentBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    global List<PartialPAFNotificationService.NotificationData> allNotificationDataList =
    new List<PartialPAFNotificationService.NotificationData>();
    global Set<Id> contactsToFlag = new Set<Id>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id,
                   hed__Applicant__c,
                   Partial_Paid__c,
                   Provisional_Admission_Fee_Paid__c,
                   First_Payment_Date__c
            FROM hed__Application__c
            WHERE Partial_Paid__c = true
            AND Provisional_Admission_Fee_Paid__c = false
            AND First_Payment_Date__c > 2026-06-14
            AND hed__Applicant__c != null
            AND hed__Applicant__r.Record_Type_Name__c = 'Applicant'
            AND hed__Applicant__r.Partial_PAF_Reminder_Sent__c = false
            
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<hed__Application__c> scope) {
        
        Set<Id> contactIds = new Set<Id>();
        for(hed__Application__c app : scope) {
            if(app.hed__Applicant__c != null) {
                contactIds.add(app.hed__Applicant__c);
            }
        }
        
        if(contactIds.isEmpty()) return;
        
        List<Student_Fee__c> feeList = [
            SELECT Id,
                   Contact__c,
                   Contact__r.Id,
                   Contact__r.Name,
                   Contact__r.Email,
                   Contact__r.MobilePhone,
                   Contact__r.Owner.Name,
                   Contact__r.Owner.MobilePhone,
                   Contact__r.Program_Batch__r.Name,
                   Fee_Year__c,
                   Fee_Type__c,
                   Provisional_Admission_Fee__c
            FROM Student_Fee__c
            WHERE Contact__c IN :contactIds
            AND Fee_Year__c = '1st year'
            AND Fee_Type__c = 'Tuition Fee'
            AND Amount__c > 0
        ];
        
        if(feeList.isEmpty()) return;
        
      
        Map<Id, Id> contactIdToFeeIdMap = new Map<Id, Id>();
        
        Set<Id> feeIds = new Set<Id>();
        for(Student_Fee__c fee : feeList) {
            feeIds.add(fee.Id);
            contactIdToFeeIdMap.put(fee.Contact__c, fee.Id);
            
            System.debug('Fee Mapping — ContactId: ' + fee.Contact__c + 
                         ' FeeId: '                  + fee.Id);
        }
        
        List<Student_Fee_Payment__c> allExistingFeePayments = [
            SELECT Id, Student_Fee__c
            FROM Student_Fee_Payment__c
            WHERE Student_Fee__c IN :feeIds
        ];
        
        Set<Id> feeIdsWithExistingFeePayment = new Set<Id>();
        for(Student_Fee_Payment__c sfp : allExistingFeePayments) {
            feeIdsWithExistingFeePayment.add(sfp.Student_Fee__c);
        }
        
        List<Student_Fee_Payment__c> existingPendingFeePayments = [
            SELECT Id, Student_Fee__c, Amount__c, Line_Item_Payment_Status__c
            FROM Student_Fee_Payment__c
            WHERE Student_Fee__c IN :feeIds
            AND Line_Item_Payment_Status__c = 'Pending'
        ];
        
        Map<String, Student_Fee_Payment__c> existingPendingFeePaymentMap =
            new Map<String, Student_Fee_Payment__c>();
        for(Student_Fee_Payment__c sfp : existingPendingFeePayments) {
            String key = sfp.Student_Fee__c + '_' + sfp.Amount__c;
            existingPendingFeePaymentMap.put(key, sfp);
        }
        
        List<Student_Fee_Payment__c> successPayments = [
            SELECT Id, Student_Fee__c, Amount__c, Line_Item_Payment_Status__c,Student_Fee__r.Contact__c
            FROM Student_Fee_Payment__c
            WHERE  Student_Fee__r.Contact__c IN :contactIds 
            AND  (
                Student_Payment__r.Fee_Type__c = 'Tuition Fee'
                OR
                Student_Payment__r.Fee_Type__c = 'University Fee'
                OR
                Student_Payment__r.Fee_Type__c = 'University Fee, Tuition Fee'
            )
            AND (Line_Item_Payment_Status__c = 'Success' OR (Line_Item_Payment_Status__c = 'Pending'
                                                             AND  Student_Payment__c != null))
                 
                 ];

                /*
TOTAL PAID AMOUNT BY CONTACT
*/
        
        Map<Id, Decimal> contactPaidAmountMap = new Map<Id, Decimal>();
        
        for(Student_Fee_Payment__c sfp : successPayments) {
            
            Id contactId = sfp.Student_Fee__r.Contact__c;
            
            Decimal existingAmount = 0;
            
            if(contactPaidAmountMap.containsKey(contactId)) {
                existingAmount = contactPaidAmountMap.get(contactId);
            }
            
            Decimal paymentAmount = 0;
            
            if(sfp.Amount__c != null) {
                paymentAmount = sfp.Amount__c;
            }
            
            contactPaidAmountMap.put(
                contactId,
                existingAmount + paymentAmount
            );
        }
        
        List<Student_Payment__c> existingPendingPayments = [
            SELECT Id, Contact__c, Amount__c, Payment_Status__c
            FROM Student_Payment__c
            WHERE Contact__c IN :contactIds
            AND Payment_Status__c = 'Pending'
        ];
        
        Map<String, Student_Payment__c> pendingPaymentMap =
            new Map<String, Student_Payment__c>();
        for(Student_Payment__c sp : existingPendingPayments) {
            String key = sp.Contact__c + '_' + sp.Amount__c;
            pendingPaymentMap.put(key, sp);
        }
        
        List<Student_Payment__c>    paymentsToInsert  = new List<Student_Payment__c>();
        Map<Id, Student_Fee__c>     feeIdToFeeDataMap = new Map<Id, Student_Fee__c>();
        
        /*
✅ contactId → payment object
After insert, payment.Id available via same reference
Then use contactIdToFeeIdMap to get correct feeId for that contact
*/
        Map<Id, Student_Payment__c> contactIdToPaymentMap = new Map<Id, Student_Payment__c>();
        
        for(Student_Fee__c fee : feeList) {
                    
            Decimal paidAmount = 0;
            
            if(contactPaidAmountMap.containsKey(fee.Contact__c)) {
                
                paidAmount = contactPaidAmountMap.get(fee.Contact__c);
            }
                
            Decimal pafAmount = fee.Provisional_Admission_Fee__c;
            Decimal remainingAmount = pafAmount - paidAmount;
            
            System.debug('Contact : ' + fee.Contact__c);
            System.debug('PAF Amount : ' + pafAmount);
            System.debug('Paid Amount : ' + paidAmount);
            System.debug('Remaining Amount : ' + remainingAmount);
            
            if(remainingAmount <= 0) continue;
            
            String paymentKey    = fee.Contact__c + '_' + remainingAmount;
            String feePaymentKey = fee.Id + '_' + remainingAmount;
            
            Student_Payment__c payment   = new Student_Payment__c();
            payment.Contact__c           = fee.Contact__c;
            payment.Amount__c            = remainingAmount;
            payment.Payment_Status__c    = 'Pending';
            payment.Payment_Mode_Type__c = 'Online';
            payment.Mode_of_Payment__c   = 'Online';
            payment.Fee_Type__c          = 'University Fee, Tuition Fee';
            payment.Duplication_PAF__c   = true;
            paymentsToInsert.add(payment);
            
            feeIdToFeeDataMap.put(fee.Id, fee);
            
            /*
            ✅ Store payment by contactId
            contactId is the bridge between
            Student_Payment and Student_Fee
            */
            contactIdToPaymentMap.put(fee.Contact__c, payment);
            
            System.debug('Created Payment — ContactId: ' + fee.Contact__c +
                         ' FeeId: '                      + fee.Id +
                         ' Amount: '                     + remainingAmount);
        }
        
        if(paymentsToInsert.isEmpty()) {
            System.debug('No Payments To Insert');
            return;
        }
        
        insert paymentsToInsert;
        
        // Update Payment URL after Student Payment records are inserted
        List<Student_Payment__c> paymentsToUpdate = new List<Student_Payment__c>();
        
        // Get Community Domain
        String domain = '';
        List<Domain> domainList = [
            SELECT Domain
            FROM Domain
            WHERE HttpsOption = 'CommunityAlt'
            LIMIT 1
        ];
        
        if(!domainList.isEmpty()) {
            domain = 'https://' + domainList[0].Domain;
        }
        
        for(Student_Payment__c payment : paymentsToInsert) {
            
            String paymentUrl = domain +
                '/Admissions/s/payment-page?contactId=' + payment.Contact__c +
                '&isPAF=true' +
                '&stupayid=' + payment.Id;
            
            paymentsToUpdate.add(
                new Student_Payment__c(
                    Id = payment.Id,
                    Pending_Payment_Link__c = paymentUrl
                )
            );
        }
        
        if(!paymentsToUpdate.isEmpty()) {
            update paymentsToUpdate;
        }
        
        // Notifications
        
        List<PartialPAFNotificationService.NotificationData> chunkNotificationList =
            new List<PartialPAFNotificationService.NotificationData>();
        
        for(Id contactId : contactIdToPaymentMap.keySet()) {
            
            Id feeId = contactIdToFeeIdMap.get(contactId);
            if(feeId == null) continue;
            
            Student_Fee__c     feeData         = feeIdToFeeDataMap.get(feeId);
            Student_Payment__c insertedPayment = contactIdToPaymentMap.get(contactId);
            
            if(feeData == null || insertedPayment == null || insertedPayment.Id == null) {
                System.debug('Skipping notification — null data for contactId: ' + contactId);
                continue;
            }
            
            chunkNotificationList.add(
                new PartialPAFNotificationService.NotificationData(
                    String.valueOf(feeData.Contact__r.Id),
                    feeData.Contact__r.Name,
                    feeData.Contact__r.Email,
                    feeData.Contact__r.MobilePhone,
                    String.valueOf(insertedPayment.Id),
                    insertedPayment.Amount__c,
                    feeData.Contact__r.Program_Batch__r.Name != null ? feeData.Contact__r.Program_Batch__r.Name : '',  // ✅ programName
                    feeData.Contact__r.Owner.Name != null ? feeData.Contact__r.Owner.Name : '',
                    feeData.Contact__r.Owner.MobilePhone != null ? feeData.Contact__r.Owner.MobilePhone : ''  
                )
            );
            contactsToFlag.add(contactId);
        }
        
        allNotificationDataList.addAll(chunkNotificationList);
        
        System.debug('Student Payments Created : '     + paymentsToInsert.size());
        System.debug('Chunk Notifications Built : '    + chunkNotificationList.size());
        System.debug('Total Notifications So Far : '   + allNotificationDataList.size());
    }
    
    global void finish(Database.BatchableContext bc) {
        
        System.debug('allNotificationDataList final size : ' + allNotificationDataList.size());
        
        if(!allNotificationDataList.isEmpty()) {
            System.enqueueJob(
                new PartialPAFNotificationService(
                    allNotificationDataList,
                    'pending_tuition_fee_reminder'
                )
            );
            System.debug(
                'Notification Job Enqueued For : ' +
                allNotificationDataList.size() + ' Contacts'
            );
        }
         if(!contactsToFlag.isEmpty()) {

        List<Contact> contactsToUpdate = new List<Contact>();

        for(Id contactId : contactsToFlag) {

            contactsToUpdate.add(
                new Contact(
                    Id = contactId,
                    Partial_PAF_Reminder_Sent__c = true
                )
            );
        }

        update contactsToUpdate;

        System.debug('Contacts Flagged : ' + contactsToUpdate.size());
    }
        System.debug('Partial PAF Payment Batch Completed');
    }
}