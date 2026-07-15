public class SchoolheadNotificationsBatch implements Database.Batchable<SObject>, Database.Stateful {

    // To store grouped data for email creation
    public Map<String, List<Class_Adjustment__c>> schoolHeadEmailToAdjustments = new Map<String, List<Class_Adjustment__c>>();

    // START
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name,
                   Professor__r.Name,Status__c,
                   Requested_Professor__r.Name,
                   Course_Offering_Schedule__r.School_Head__r.Email,
                   Course_Offering_Schedule__r.School_Head__r.Name,
                   Course_Offering_Schedule__r.hed__Course_Offering__r.Name,
                   Course_Offering_Schedule__r.Date__c,
                   Course_Offering_Schedule__r.hed__Start_Time__c,
                   Course_Offering_Schedule__r.hed__End_Time__c
                   FROM Class_Adjustment__c 
                   WHERE Course_Offering_Schedule__r.Date__c = Today
                   AND Course_Offering_Schedule__r.Class_adjusted_schedule__c = TRUE
                   AND Course_Offering_Schedule__r.School_Head__r.Email != NULL
        ]);
    }

    // EXECUTE — build grouping map
    public void execute(Database.BatchableContext bc, List<Class_Adjustment__c> records) {

        for (Class_Adjustment__c rec : records) {
            String email = rec.Course_Offering_Schedule__r.School_Head__r.Email;

            if (!schoolHeadEmailToAdjustments.containsKey(email)) {
                schoolHeadEmailToAdjustments.put(email, new List<Class_Adjustment__c>());
            }
            schoolHeadEmailToAdjustments.get(email).add(rec);
        }
    }

    // FINISH — send email to each School Head
    public void finish(Database.BatchableContext bc) {
     system.debug('Finish');
         List<OrgWideEmailAddress> lstEmailAddress = [
            SELECT Id, DisplayName 
            FROM OrgWideEmailAddress 
            WHERE DisplayName = 'REVA Alerts'
            LIMIT 1
        ];
        Id orgWideId = lstEmailAddress.isEmpty() ? null : lstEmailAddress[0].Id;
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        // Collect all Adjustment IDs for approval date fetch
        Set<Id> adjIds = new Set<Id>();
        for (List<Class_Adjustment__c> lst : schoolHeadEmailToAdjustments.values()) {
            for (Class_Adjustment__c rec : lst) {
                adjIds.add(rec.Id);
            }
        }

        // Get APPROVED DATES
        Map<Id, Datetime> approvedDates = getApprovedDates(adjIds);
        
        for (String email : schoolHeadEmailToAdjustments.keySet()) {

            List<Class_Adjustment__c> adjList = schoolHeadEmailToAdjustments.get(email);
            system.debug('email::'+ email);
            // Build HTML email body with table
            String htmlBody = '';
            htmlBody += '<p>Dear Sir/Ma’am,</p>';
            htmlBody += '<p>This is to inform you that the following classes have been adjusted for today. The '+
                        'details of the adjusted slots are provided below for your reference.</p>';

            htmlBody += '<table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse;">';
            htmlBody += '<tr style="background:#f2f2f2;font-weight:bold;">' +
                        '<th>Class Date</th>' +
                        '<th>Approved Date</th>' +   
                        '<th>Requested Professor</th>' +
                        '<th>Approved Professor</th>' +
                        '<th>Course</th>' +
                        '<th>From Time</th>' +
                        '<th>To Time</th>' +
                        '<th>Status</th>' +
                        '</tr>';

            for (Class_Adjustment__c rec : adjList) {

                String dateVal = String.valueOf(rec.Course_Offering_Schedule__r.Date__c);
                String courseName = rec.Course_Offering_Schedule__r.hed__Course_Offering__r.Name;
                String adjProf = rec.Professor__r != null ? rec.Professor__r.Name : '';
                String reqProf = rec.Requested_Professor__r != null ? rec.Requested_Professor__r.Name : '';
                String startTime = formatTimeTo12(rec.Course_Offering_Schedule__r.hed__Start_Time__c);
                String endTime   = formatTimeTo12(rec.Course_Offering_Schedule__r.hed__End_Time__c);
                String statusVal = rec.Status__c != null ? rec.Status__c : '';
                // NEW: Approved Date
                Datetime approvedDt = approvedDates.containsKey(rec.Id) ? approvedDates.get(rec.Id) : null;
                String approvedDtStr = approvedDt != null ? String.valueOf(approvedDt.date()) : '';

                htmlBody += '<tr>' +
                            '<td>' + dateVal + '</td>' +
                            '<td>' + approvedDtStr + '</td>' +
                            '<td>' + adjProf + '</td>' +
                            '<td>' + reqProf + '</td>' +
                            '<td>' + courseName + '</td>' +
                            '<td>' + startTime + '</td>' +
                            '<td>' + endTime + '</td>' +
                            '<td>' + statusVal + '</td>' +
                            '</tr>';
            }
            htmlBody += '</table>';

            htmlBody += '<br/><p>Regards,<br/><br/>REVA University</p>';

            // Prepare mail
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses( new List<String>{email} );
            if (orgWideId != null) mail.setOrgWideEmailAddressId(orgWideId);
            mail.setBccAddresses(new List<String>{'naveenchandra.g@reva.edu.in'});
            mail.setSubject('Class Adjustment Notification');
            mail.setHtmlBody(htmlBody);
 
            emails.add(mail);
        }
         system.debug('emails::'+ emails);
        // Send all emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
              system.debug('emails::'+ emails);
        }
    }
    
     // ➤ Helper: Fetch Latest Approval Dates
 public static Map<Id, Datetime> getApprovedDates(Set<Id> adjIds) {

    Map<Id, Datetime> approvedDateMap = new Map<Id, Datetime>();

    List<ProcessInstanceStep> steps = [
        SELECT ProcessInstance.TargetObjectId,
               CreatedDate,
               StepStatus
        FROM ProcessInstanceStep
        WHERE ProcessInstance.TargetObjectId IN :adjIds
        AND StepStatus = 'Approved'
        ORDER BY CreatedDate DESC
    ];

    for (ProcessInstanceStep st : steps) {

        Id adjId = st.ProcessInstance.TargetObjectId;

        // Store only first (latest) approved date
        if (!approvedDateMap.containsKey(adjId)) {
            approvedDateMap.put(adjId, st.CreatedDate);
        }
    }

    return approvedDateMap;
}

    
   public static String formatTimeTo12(Time t) {
    if (t == null) return '';

    Integer hour = t.hour();
    Integer minute = t.minute();

    String ampm = (hour >= 12) ? 'PM' : 'AM';

    // Convert hour to 12-hour format
    if (hour == 0) hour = 12;
    else if (hour > 12) hour -= 12;

    // Format minute to 2 digits
    String minuteStr = (minute < 10) ? '0' + minute : String.valueOf(minute);

    return hour + ':' + minuteStr + ' ' + ampm;
}

}