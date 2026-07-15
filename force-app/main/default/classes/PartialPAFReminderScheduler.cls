global class PartialPAFReminderScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        // Date tenDaysAgo     = Date.today().addDays(-10);
        // DateTime startOfDay = DateTime.newInstance(tenDaysAgo, Time.newInstance(0,0,0,0));
        // DateTime endOfDay   = DateTime.newInstance(tenDaysAgo, Time.newInstance(23,59,59,999));
        
        List<Student_Payment__c> pendingPayments = [
            SELECT Id,
                   Contact__c,
                   Contact__r.Name,
                   Contact__r.Email,
                   Contact__r.MobilePhone,
                   Contact__r.Owner.Name,
				   Contact__r.Owner.Phone,
                   Contact__r.Program_Batch__r.Name,
                   Amount__c
            FROM Student_Payment__c
            WHERE Payment_Status__c = 'Pending'
            AND Duplication_PAF__c = true
            AND Contact__r.MobilePhone != null limit 2
            // AND CreatedDate >= :startOfDay
            // AND CreatedDate <= :endOfDay
        ];
        
        if(pendingPayments.isEmpty()) {
            System.debug('No Pending PAF Payments Found For Reminder');
            return;
        }
        
        List<PartialPAFNotificationService.NotificationData> notificationList =
            new List<PartialPAFNotificationService.NotificationData>();
        
        for(Student_Payment__c payment : pendingPayments) {
            notificationList.add(
                new PartialPAFNotificationService.NotificationData(
                    String.valueOf(payment.Contact__c),
                    payment.Contact__r.Name,
                    payment.Contact__r.Email,
                    payment.Contact__r.MobilePhone,
                    String.valueOf(payment.Id),
                    payment.Amount__c,
                    payment.Contact__r.Program_Batch__r.Name != null ? payment.Contact__r.Program_Batch__r.Name : '',
                    payment.Contact__r.Owner.Name != null ? payment.Contact__r.Owner.Name : '',
					payment.Contact__r.Owner.Phone != null ? payment.Contact__r.Owner.Phone : ''
                )
            );
        }
        
        System.enqueueJob(
            new PartialPAFNotificationService(
                notificationList,
                'pending_tuition_fee_reminder'
            )
        );
        
        System.debug('Reminder Notifications Enqueued For : ' + notificationList.size() + ' Contacts');
    }
}