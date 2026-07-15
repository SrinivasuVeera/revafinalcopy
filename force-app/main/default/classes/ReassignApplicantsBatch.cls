global class ReassignApplicantsBatch implements Database.Batchable<SObject>,Database.Stateful  {
    
    private List<Id> allContactIds = new List<Id>();
    private Map<Id,String> previousOwnerMap = new Map<Id,String>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
         System.debug('Start Method : ' );
        String enrollmentyearStr = [SELECT Text_Value__c FROM General_Setting__mdt WHERE DeveloperName = 'Enrolment_Year'LIMIT 1].Text_Value__c;

        Decimal enrollmentyear = Decimal.valueOf(enrollmentyearStr);
        Date threeDaysAgo = Date.today().addDays(-3);
        
        return Database.getQueryLocator([
            SELECT Id,
            hed__Applicant__c,hed__Applicant__r.Name,hed__Applicant__r.Application_Number__c,
            hed__Applicant__r.Application_Fee_Paid__c,
            hed__Applicant__r.Program_Batch__r.Program_Batch_Name__c,
            hed__Applicant__r.Application_Fee_Paid_Date__c,
            hed__Applicant__r.Disposition__c,
            hed__Applicant__r.Description1__c,
            Partial_Paid__c
            FROM hed__Application__c
            WHERE hed__Applicant__c != null
            AND hed__Applicant__r.Application_Fee_Paid__c = TRUE
            AND hed__Applicant__r.TAT_Business_Days__c >= 3
            AND (
                hed__Applicant__r.Disposition__c = ''
                OR hed__Applicant__r.Description1__c = ''
            )
            AND Partial_Paid__c = FALSE 
            AND hed__Applicant__r.TAT_Status__c = ''
            AND hed__Applicant__r.Program_Batch__r.smt_Start_Year__c =: enrollmentyear
        ]);
    }
  global void execute(Database.BatchableContext bc,List<hed__Application__c> scope) {
      System.debug('Execute Method : ' );
        User counselor = [
            SELECT Id, Name, Email
            FROM User
            WHERE Email = 'fariha.tabassumf@reva.edu.in'
            AND IsActive = TRUE
            LIMIT 1
        ];

        Set<Id> contactIdSet = new Set<Id>();

        for(hed__Application__c app : scope) {
            if(app.hed__Applicant__c != null){
                contactIdSet.add(app.hed__Applicant__c);
            }
        }

        Map<Id, Contact> existingContacts = new Map<Id, Contact>(
            [SELECT Id, Name,OwnerId,Owner.Name FROM Contact WHERE Id IN :contactIdSet]
        );

        List<Contact> contactsToUpdate = new List<Contact>();
        List<Id> contactIds = new List<Id>();
        List<hed__Application__c> applicationsToUpdate = new List<hed__Application__c>();
        for(hed__Application__c app : scope) {

            if(app.hed__Applicant__c != null &&
               existingContacts.containsKey(app.hed__Applicant__c)) {

                Contact oldContact = existingContacts.get(app.hed__Applicant__c);

                previousOwnerMap.put(
                    oldContact.Id,
                    oldContact.Owner.Name
                );

                contactsToUpdate.add(
                    new Contact(
                        Id = oldContact.Id,
                        OwnerId = counselor.Id,
                        Assigned_Users__c = counselor.Id,
                        TAT_Status__c = 'TAT 1',
                        Counselor_Reassigned_date__c = System.today()
                    )
                );
                   // Update Application Owner also
                   applicationsToUpdate.add(
                       new hed__Application__c(
                           Id = app.Id,
                           OwnerId = counselor.Id
                       )
                   );

                contactIds.add(oldContact.Id);
                allContactIds.add(oldContact.Id);
            }
        }

        if(!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
      
      if(!applicationsToUpdate.isEmpty()){
    update applicationsToUpdate;
}
    }

    global void finish(Database.BatchableContext bc) {
     System.debug('Finish Method : ' );
     System.debug('===== CONTACT COUNT : ' + allContactIds.size());
        if(allContactIds.isEmpty()) {
            return;
        }

        List<Contact> updatedContacts = [SELECT Id, Name, MobilePhone, Application_Number__c,
                                         Application_Fee_Paid_Date__c,OwnerId,Owner.Name, Owner.MobilePhone,Check_OwnerChnage__c,Program_Batch__r.Name 
                                         FROM Contact WHERE Id IN :allContactIds];

        // Counselor WhatsApp
        ReassignmentSendSMSANdWhatsapp.SendWhatsApptoReassignedOwner( updatedContacts,'tat' );
        System.debug('===== CONTACT COUNT : ' + allContactIds.size());
        OrgWideEmailAddress orgWide = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts' LIMIT 1 ];
        
        String htmlBody = '';

        htmlBody += 'Dear Farhia,<br/><br/>';
        htmlBody += 'An applicant has been automatically reassigned to you because no counsellor follow-up activity was recorded within 3 days of the Application Fee payment. The defined turnaround time (TAT) has been exceeded.<br/><br/>';

        htmlBody += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse:collapse;">';
        htmlBody += '<tr>';
        htmlBody += '<th>Applicant Name</th>';
        htmlBody += '<th>Application Number</th>';
        htmlBody += '<th>Program Applied</th>';
        htmlBody += '<th>Application Fee Paid Date</th>';
        htmlBody += '<th>Previous Contact Owner</th>';
        htmlBody += '</tr>';

        for(Contact con : updatedContacts){

            htmlBody += '<tr>';
            htmlBody += '<td>' + con.Name + '</td>';
            htmlBody += '<td>' + con.Application_Number__c + '</td>';
            htmlBody += '<td>' + con.Program_Batch__r.Name + '</td>';
            htmlBody += '<td>' + String.valueOf(con.Application_Fee_Paid_Date__c) + '</td>';
            htmlBody += '<td>' + previousOwnerMap.get(con.Id) + '</td>';
            htmlBody += '</tr>';
        }

        htmlBody += '</table>';

        htmlBody += '<br/><br/>As per the defined process, these applicants have now been assigned to you for further follow-up and counselling.';
        htmlBody += '<br/><br/>Please review the applicant details and initiate contact at the earliest.';
        htmlBody += '<br/><br/>Thank you.';
        htmlBody += '<br/><br/>Regards,<br/>REVA University';

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(orgWide.Id);
        mail.setToAddresses(
            new List<String>{
                'fariha.tabassumf@reva.edu.in'
            }
        );

        mail.setSubject('Applicant Auto Reassignment Notification');

        mail.setHtmlBody(htmlBody);

        Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] { mail }
        );
    }
}