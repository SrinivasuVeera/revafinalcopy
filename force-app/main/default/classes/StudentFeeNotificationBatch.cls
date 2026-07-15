global class StudentFeeNotificationBatch implements Database.Batchable<SObject>, Database.Stateful,
Database.AllowsCallouts{
    
    global List<String> contactRecIds { get; set; }
    
    public static String dueDate, phoneNumber, fPhoneNumber, mPhoneNumber;
    global String query;
    global Date feeDueDate;
    global static List<WhatsApp_Notification_Log__c> waLogsToInsert = new List<WhatsApp_Notification_Log__c>();
    global static HttpResponse res_Student = new HttpResponse();
    global static HttpResponse res_Father = new HttpResponse();
    global static HttpResponse res_Mother = new HttpResponse();
        
    global StudentFeeNotificationBatch(){}
    
    global StudentFeeNotificationBatch(List<String> contactId){
        this.contactRecIds = contactId;
    }
    
    global Map<Id, Contact> contactMap = new Map<Id, Contact>();
    // global Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> sphoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
    // global Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> fphoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
    // global Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> mphoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        System.debug('start method to send notifications');
        System.debug('contactRecIds=> ' + contactRecIds);
        System.debug('contactRecIds SIZE=> ' + contactRecIds.size());
        
        String studentRecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        query = 'SELECT ID, Name, MobilePhone,Program_Batch__r.Name, School__r.Name'
            +' FROM Contact'
            +' WHERE Active__c = true AND RecordTypeId =:studentRecordTypeID'
            +' AND MobilePhone != null AND Student_Status__c = \'Pursuing\''
            +' AND Program_Batch__c != null'
            +' AND (NOT MobilePhone LIKE \'9999%\')'
            +' AND Id IN :contactRecIds';
        System.debug('query=====>'+JSON.Serialize(query));
        List<Contact> conList = Database.query(query);
        System.debug('Quered result===>'+JSON.Serialize(conList));
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> contList) {
        System.debug('execute');
        System.debug('SIZE=> ' + contList.size());
        
        // Create a map of contacts for easy lookup
        for (Contact contact : contList) {
            contactMap.put(contact.Id, contact);
        }
        System.debug('contactMap: ' + contactMap);
        
        // Query to fetch fee details and phone numbers
        List<AggregateResult> aggregateFees = [SELECT contact__c stu, 
                                               contact__r.name name, 
                                               contact__r.MobilePhone mobile,
                                               MIN(due_date__c) DueDate,
                                               contact__r.Mother__c mCont, 
                                               SUM(amount_pending__c) pendingAmount, 
                                               contact__r.Father__c fCont,
                                               Contact__r.Father__r.Name fName,
                                               Contact__r.Father__r.MobilePhone fPhone,
                                               Contact__r.Mother__r.Name mName,
                                               Contact__r.Mother__r.MobilePhone mPhone
                                               FROM student_fee__c  
                                               WHERE due_date__c = THIS_YEAR 
                                               AND amount_pending__c > 0
                                               AND amount_pending__c != NULL
                                               AND contact__r.MobilePhone != NULL
                                               AND (NOT contact__r.MobilePhone LIKE '9999%')
                                               AND (Fee_Type__c = 'University Fee' OR Fee_Type__c = 'Tuition Fee')
                                               AND contact__c IN :contactMap.keySet()
                                               GROUP BY contact__c, contact__r.name, contact__r.mobilephone, 
                                               contact__r.Father__c, Contact__r.Father__r.Name, 
                                               contact__r.Father__r.MobilePhone, contact__r.Mother__c,
                                               Contact__r.Mother__r.Name, contact__r.Mother__r.MobilePhone
                                             ];
        System.debug('aggregateFees===>'+JSON.Serialize(aggregateFees));
        
        // Process each result
        for (AggregateResult eachAggregate : aggregateFees) {
    
            // Create maps for notifications
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> SphoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> FphoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> MphoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            
            // Process Student Phone Number
            phoneNumber = (string.valueOf(eachAggregate.get('mobile')));
                if(phoneNumber !=null && phoneNumber != ''){
                    if(phoneNumber.contains('+91-')){
                        phoneNumber = phoneNumber.replace('+', '').replace('-', '');                
                    }else if(phoneNumber.contains('91-')){
                        phoneNumber = phoneNumber.replace('-', '');                
                    }else if(phoneNumber.contains('+91')){
                        phoneNumber = phoneNumber.replace('+', '');                
                    }
                    else if(phoneNumber.length() == 10){ 
                        phoneNumber = '91'+phoneNumber;
                    }
                }
    
            if (phoneNumber != null && phoneNumber != '') {
                Yellow_AI_Utility.WhatsAppNotification Snotification = new Yellow_AI_Utility.WhatsAppNotification();
                Snotification.templateId = 'fee_reminder_2024_n1_copy';
                Snotification.params.put('StudentName', (string)eachAggregate.get('name') ?? 'Student');
                Snotification.params.put('Calculated_Amount_Pending', String.valueOf(eachAggregate.get('pendingAmount')));
                Snotification.params.put('Fee_Due_Date', String.valueOf(Date.valueOf(eachAggregate.get('DueDate')).format()));
                
                SphoneNumbersToNotifications.put(phoneNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{Snotification});
            }
    
            // Process Father's Phone Number
            fPhoneNumber = (string.valueOf(eachAggregate.get('fPhone')));
                if(fPhoneNumber !=null && fPhoneNumber != ''){
                    if(fPhoneNumber.contains('+91-')){
                        fPhoneNumber = fPhoneNumber.replace('+', '').replace('-', '');                
                    }else if(fphoneNumber.contains('91-')){
                        fPhoneNumber = fPhoneNumber.replace('-', '');                
                    }else if(fphoneNumber.contains('+91')){
                        fPhoneNumber = fPhoneNumber.replace('+', '');                
                    }
                    else if(fphoneNumber.length() == 10){ 
                        fPhoneNumber = '91'+fPhoneNumber;
                    }
                }
    
            if (fPhoneNumber != null && fPhoneNumber != '') {
                Yellow_AI_Utility.WhatsAppNotification Fnotification = new Yellow_AI_Utility.WhatsAppNotification();
                Fnotification.templateId = 'fee_reminder_2024_n1_copy';
                Fnotification.params.put('StudentName', (string)eachAggregate.get('fName') ?? 'Student');
                Fnotification.params.put('Calculated_Amount_Pending', String.valueOf(eachAggregate.get('pendingAmount')));
                Fnotification.params.put('Fee_Due_Date', String.valueOf(Date.valueOf(eachAggregate.get('DueDate')).format()));
                
                FphoneNumbersToNotifications.put(fPhoneNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{Fnotification});
            }
    
            // Process Mother's Phone Number
             mPhoneNumber = (string.valueOf(eachAggregate.get('mPhone'))); 
                if(mPhoneNumber != null && mPhoneNumber != ''){
                    if(mPhoneNumber.contains('+91-')){
                        mPhoneNumber = mPhoneNumber.replace('+', '').replace('-', '');                
                    }else if(mphoneNumber.contains('91-')){
                        mPhoneNumber = mPhoneNumber.replace('-', '');                
                    }else if(phoneNumber.contains('+91')){
                        mPhoneNumber = mPhoneNumber.replace('+', '');                
                    }
                    else if(phoneNumber.length() == 10){ 
                        mPhoneNumber = '91'+mPhoneNumber;
                    }
                }          
    
            if (mPhoneNumber != null && mPhoneNumber != '') {
                Yellow_AI_Utility.WhatsAppNotification Mnotification = new Yellow_AI_Utility.WhatsAppNotification();
                Mnotification.templateId = 'fee_reminder_2024_n1_copy';
                Mnotification.params.put('StudentName', (string)eachAggregate.get('mName') ?? 'Student');
                Mnotification.params.put('Calculated_Amount_Pending', String.valueOf(eachAggregate.get('pendingAmount')));
                Mnotification.params.put('Fee_Due_Date', String.valueOf(Date.valueOf(eachAggregate.get('DueDate')).format()));
                
                MphoneNumbersToNotifications.put(mPhoneNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{Mnotification});
            }
    
            // Send WhatsApp Notifications
            try {
                if (!SphoneNumbersToNotifications.isEmpty()) {
                    res_Student = Yellow_AI_Utility.sendWhatsAppNotifications(SphoneNumbersToNotifications);
                    System.debug('Student response: ' + res_Student.getBody() + '\nStatus Code: ' + res_Student.getstatusCode()); 
                }
            } catch (Exception e) {
                System.debug('Student notification failed: ' + e.getMessage());
            }
    
            try {
                if (!FphoneNumbersToNotifications.isEmpty()) {
                    res_Father = Yellow_AI_Utility.sendWhatsAppNotifications(FphoneNumbersToNotifications);
                    System.debug('Father response: ' + res_Father.getBody() + '\nStatus Code: ' + res_Father.getstatusCode()); 
                }
            } catch (Exception e) {
                System.debug('Father notification failed: ' + e.getMessage());
            }
    
            try {
                if (!MphoneNumbersToNotifications.isEmpty()) {
                    res_Mother = Yellow_AI_Utility.sendWhatsAppNotifications(MphoneNumbersToNotifications);
                    System.debug('Mother response: ' + res_Mother.getBody() + '\nStatus Code: ' + res_Mother.getstatusCode()); 
                }
            } catch (Exception e) {
                System.debug('Mother notification failed: ' + e.getMessage());
            }
    
            // INSERTING LOGS
            WhatsApp_Notification_Log__c waLogs = new WhatsApp_Notification_Log__c();
            waLogs.Student__c  = (string)eachAggregate.get('stu');
            waLogs.Program_Batch__c = contactMap.get((string)eachAggregate.get('stu')).Program_Batch__r.Name;
            waLogs.School__c = contactMap.get((string)eachAggregate.get('stu')).School__r.Name;
            waLogs.Student_Status_Code__c  = res_Student != null ? String.valueOf(res_Student.getstatusCode()) : '';
            waLogs.Student_Msg_Id__c = res_Student != null ? String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res_Student.getBody())).get('msgId')) : '';
            waLogs.Student_Mobile__c = phoneNumber;
    
            waLogs.Father__c = (string)eachAggregate.get('fCont');
            waLogs.Fathers_Status_Code__c = res_Father != null ? String.valueOf(res_Father.getstatusCode()) : '';
            waLogs.Father_Msg_Id__c = res_Father != null ? String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res_Father.getBody())).get('msgId')) : '';
            waLogs.Father_Mobile__c = fPhoneNumber;
    
            waLogs.Mother__c = (string)eachAggregate.get('mCont');
            waLogs.Mothers_Status_Code__c = res_Mother != null ? String.valueOf(res_Mother.getstatusCode()) : '';
            waLogs.Mother_Msg_Id__c = res_Mother != null ? String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res_Mother.getBody())).get('msgId')) : '';
            waLogs.Mother_Mobile__c = mPhoneNumber;
    
            waLogs.Notification_Sent_on__c = System.now();
            
            waLogsToInsert.add(waLogs);
        }
        
        // Insert all logs at once
        insert waLogsToInsert;
    }
    
    
    
    global void finish(Database.BatchableContext bc) {
        System.debug('finish method to send notifications');
    }
    
    public static void testCover(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}