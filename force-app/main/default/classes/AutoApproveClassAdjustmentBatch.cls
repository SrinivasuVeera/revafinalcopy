public class AutoApproveClassAdjustmentBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    public List<Class_Adjustment__c> approvedRecords = new List<Class_Adjustment__c>();
    public Map<Id, List<User>> recordApproverMap = new Map<Id, List<User>>();

    // START
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name,
                   Professor__r.Name,
                   Course_Offering_Schedule__r.hed__Course_Offering__r.Name,
                   Course_Offering_Schedule__r.Date__c,
                   Course_Offering_Schedule__r.hed__Start_Time__c,
                   (SELECT Id FROM ProcessSteps)
            FROM Class_Adjustment__c
            WHERE Id IN (
                SELECT TargetObjectId
                FROM ProcessInstance
                WHERE Status = 'Pending'
            )  AND (CreatedDate = Today OR CreatedDate = Yesterday )
        ]);
    }

    // EXECUTE
    public void execute(Database.BatchableContext bc, List<Class_Adjustment__c> records) {
        
        if (records.isEmpty()) return;

        // 1️⃣ Collect all record IDs
        Set<Id> recordIds = new Set<Id>();
        for (Class_Adjustment__c rec : records) {
            recordIds.add(rec.Id);
        }

        // 2️⃣ Query Workitems in ONE SOQL
        Map<Id, List<ProcessInstanceWorkitem>> workitemMap = new Map<Id, List<ProcessInstanceWorkitem>>();
        
        for (ProcessInstanceWorkitem wi : [
            SELECT Id, ActorId, ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId IN :recordIds
        ]) {
            Id recId = wi.ProcessInstance.TargetObjectId;
            if (!workitemMap.containsKey(recId)) {
                workitemMap.put(recId, new List<ProcessInstanceWorkitem>());
            }
            workitemMap.get(recId).add(wi);
        }

        // 3️⃣ Collect ALL userIds from ALL workitems
        Set<Id> allUserIds = new Set<Id>();

        for (Id recId : workitemMap.keySet()) {
            for (ProcessInstanceWorkitem w : workitemMap.get(recId)) {
                allUserIds.add(w.ActorId);
            }
        }

        // 4️⃣ Query ALL Users at once
        Map<Id, User> userMap = new Map<Id, User>();
        if (!allUserIds.isEmpty()) {
            for (User u : [
                SELECT Id, Name, Email
                FROM User
                WHERE Id IN :allUserIds AND Email != null
            ]) {
                userMap.put(u.Id, u);
            }
        }

        List<Approval.ProcessWorkitemRequest> approvalRequests = new List<Approval.ProcessWorkitemRequest>();

        // 5️⃣ Loop through records WITHOUT SOQL
        for (Class_Adjustment__c rec : records) {
            
            List<ProcessInstanceWorkitem> items = workitemMap.get(rec.Id);
            if (items == null) continue;

            List<User> approvers = new List<User>();

            for (ProcessInstanceWorkitem item : items) {
                if (userMap.containsKey(item.ActorId)) {
                    approvers.add(userMap.get(item.ActorId));
                }

                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(item.Id);
                req.setAction('Approve');
                req.setComments('Automatically approved by system');
                approvalRequests.add(req);
            }

            recordApproverMap.put(rec.Id, approvers);
            approvedRecords.add(rec);
        }

        // 6️⃣ Approve all work items
        if (!approvalRequests.isEmpty()) {
            Approval.process(approvalRequests);
        }
    }

    // FINISH (Email sending)
    public void finish(Database.BatchableContext bc) {

        if (approvedRecords.isEmpty()) return;

        List<OrgWideEmailAddress> lstEmailAddress = [
            SELECT Id, DisplayName 
            FROM OrgWideEmailAddress 
            WHERE DisplayName = 'REVA Alerts'
            LIMIT 1
        ];

        Id orgWideId = lstEmailAddress.isEmpty() ? null : lstEmailAddress[0].Id;

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (Class_Adjustment__c rec : approvedRecords) {

            List<User> approvers = recordApproverMap.get(rec.Id);
            if (approvers == null || approvers.isEmpty()) continue;

            for (User u : approvers) {

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{ u.Email });
                if (orgWideId != null) mail.setOrgWideEmailAddressId(orgWideId);

                mail.setSubject('Class Adjustment Approved - ' + rec.Name);

                String body = '';
                body += 'Dear ' + u.Name + ',<br/><br/>';
                body += 'This is to inform you that Prof. ' + rec.Professor__r.Name;
                body += ' has adjusted the class for the course <b>' + 
                        rec.Course_Offering_Schedule__r.hed__Course_Offering__r.Name + '</b>';
                body += ' on ' + rec.Course_Offering_Schedule__r.Date__c;
                body += ' at ' + rec.Course_Offering_Schedule__r.hed__Start_Time__c + '.<br/><br/>';
                body += 'Kindly take note of the same and proceed as per the revised schedule.<br/><br/>';
                body += 'Regards,<br/>REVA University';

                mail.setHtmlBody(body);
                emailList.add(mail);
            }
        }

        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }
    }
}