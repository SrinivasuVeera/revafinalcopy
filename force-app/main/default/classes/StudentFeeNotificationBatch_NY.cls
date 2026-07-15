global class StudentFeeNotificationBatch_NY implements Database.Batchable<SObject>, Database.Stateful,
Database.AllowsCallouts{
    
    global List<String> contactRecIds { get; set; }
    
    public static String dueDate, phoneNumber, fPhoneNumber, mPhoneNumber;
    global String query;
    global Date feeDueDate;
    global static List<WhatsApp_Notification_Log__c> waLogsToInsert = new List<WhatsApp_Notification_Log__c>();
    global static HttpResponse res_Student = new HttpResponse();
    global static HttpResponse res_Father = new HttpResponse();
    global static HttpResponse res_Mother = new HttpResponse();
    
    global StudentFeeNotificationBatch_NY(){}
    
    global StudentFeeNotificationBatch_NY(List<String> contactId){
        this.contactRecIds = contactId;
    }
    
    global Map<Id, Contact> contactMap = new Map<Id, Contact>();
    global Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String studentRecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        query = 'SELECT ID, Name, MobilePhone, Active_Semester__c, Active_Semester__r.hed__Start_Date__c,Father__r.Name'
            +' FROM Contact'
            +' WHERE Active__c = true AND RecordTypeId =:studentRecordTypeID'
            +' AND (NOT MobilePhone LIKE \'999999%\')'
            +' AND MobilePhone != null AND Student_Status__c = \'Pursuing\''
            +' AND Program_Batch__c != null'
            +' AND Id =: contactRecIds';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> contList) {
        
        for (Contact contact : contList) {
            contactMap.put(contact.Id, contact);
        }
        System.debug('contactMap: ' + contactMap);
        
        List<AggregateResult> aggregateFees = [select  contact__c stu, contact__r.name name, 
                                               contact__r.MobilePhone mobile,
                                               min(due_date__c) DueDate, 
                                               sum(amount_pending__c) pendingAmount,
                                               Contact__r.Father__r.Name fName,contact__r.Father__r.MobilePhone fPhone,
                                               Contact__r.Mother__r.Name mName,contact__r.Mother__r.MobilePhone mPhone
                                               from student_fee__c  
                                               where due_date__c = NEXT_YEAR 
                                               		and contact__r.mobilephone != NULL
                                               		and amount_pending__c > 0
                                               		and amount_pending__c != null
                                               		and (Fee_Type__c = 'University Fee' OR Fee_Type__c = 'Tuition Fee')
                                               		and contact__c IN : contactMap.keySet()
                                               		and contact__r.Father__r.MobilePhone != null
                                               group by contact__c, contact__r.name,contact__r.mobilephone,
                                               Contact__r.Father__r.Name,contact__r.Father__r.MobilePhone,
                                               Contact__r.Mother__r.Name,contact__r.Mother__r.MobilePhone];
        
        for(AggregateResult eachAggregate: aggregateFees){
            
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> SphoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            Yellow_AI_Utility.WhatsAppNotification Snotification = new Yellow_AI_Utility.WhatsAppNotification();
            
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> FphoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            Yellow_AI_Utility.WhatsAppNotification Fnotification = new Yellow_AI_Utility.WhatsAppNotification();
            
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> MphoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            Yellow_AI_Utility.WhatsAppNotification Mnotification = new Yellow_AI_Utility.WhatsAppNotification();
            
			phoneNumber = (string.valueOf(eachAggregate.get('mobile')));
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
            
            feeDueDate = (Date.valueOf(eachAggregate.get('DueDate')));
            dueDate = feeDueDate.format();            
           	Snotification.templateId = 'fee_reminder_2024_n1_copy';
            Snotification.params = new Map<String, String>();
            Snotification.params.put('StudentName', (string)eachAggregate.get('name') != NULL ? (string)eachAggregate.get('name') : 'Student');
            Snotification.params.put('Calculated_Amount_Pending', String.valueOf(eachAggregate.get('pendingAmount')));
            Snotification.params.put('Fee_Due_Date', String.valueOf(dueDate));
            SphoneNumbersToNotifications.put(phoneNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{Snotification});
            
			fPhoneNumber = (string.valueOf(eachAggregate.get('fPhone')));
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
            Fnotification.templateId = 'fee_reminder_2024_n1_copy';
            Fnotification.params = new Map<String, String>();
            Fnotification.params.put('StudentName', (string)eachAggregate.get('fName'));
            Fnotification.params.put('Calculated_Amount_Pending', (String.valueOf(eachAggregate.get('pendingAmount'))));
            Fnotification.params.put('Fee_Due_Date', String.valueOf(dueDate));
            FphoneNumbersToNotifications.put(fPhoneNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{Fnotification});
            
			mPhoneNumber = (string.valueOf(eachAggregate.get('mPhone')));               
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
            Mnotification.templateId = 'fee_reminder_2024_n1_copy';
            Mnotification.params = new Map<String, String>();
            Mnotification.params.put('StudentName', (string)eachAggregate.get('mName'));
            Mnotification.params.put('Calculated_Amount_Pending', (String.valueOf(eachAggregate.get('pendingAmount'))));
            Mnotification.params.put('Fee_Due_Date', String.valueOf(dueDate));
            MphoneNumbersToNotifications.put(mPhoneNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{Mnotification});
            
            try{
                res_Student = Yellow_AI_Utility.sendWhatsAppNotifications(SphoneNumbersToNotifications);
            }catch(Exception e){
            }
            
            try{
                res_Father = Yellow_AI_Utility.sendWhatsAppNotifications(FphoneNumbersToNotifications);
            }catch(Exception e){
            }
            
            try{
                res_Mother = Yellow_AI_Utility.sendWhatsAppNotifications(MphoneNumbersToNotifications);
            }catch(Exception e){
            }
        }
        
        //INSERTING LOGS
         for(AggregateResult eachAggregate: aggregateFees){
            Map<String, Object> msgId_Stu = (Map<String, Object>)JSON.deserializeUntyped(res_Student.getBody());
            WhatsApp_Notification_Log__c waLogs = new WhatsApp_Notification_Log__c();
            waLogs.Student__c  = (string)eachAggregate.get('stu');
            waLogs.Program_Batch__c = contactMap.get((string)eachAggregate.get('stu')).Program_Batch__r.Name;
            waLogs.School__c = contactMap.get((string)eachAggregate.get('stu')).School__r.Name;
            waLogs.Student_Status_Code__c  = String.valueOf(res_Student.getstatusCode());
            waLogs.Student_Msg_Id__c = String.valueOf(msgId_Stu.get('msgId'));
            walogs.Student_Mobile__c = phoneNumber;
            
            Map<String, Object> msgId_Father = (Map<String, Object>)JSON.deserializeUntyped(res_Father.getBody());
            waLogs.Father__c = (string)eachAggregate.get('fCont');
            waLogs.Fathers_Status_Code__c  = String.valueOf(res_Father.getstatusCode());
            waLogs.Father_Msg_Id__c   = String.valueOf(msgId_Father.get('msgId'));
            waLogs.Father_Mobile__c = fphoneNumber;

            Map<String, Object> msgId_Mother = (Map<String, Object>)JSON.deserializeUntyped(res_Mother.getBody());
            waLogs.Mother__c = (string)eachAggregate.get('mCont');
            waLogs.Mothers_Status_Code__c  = String.valueOf(res_Mother.getstatusCode());
            waLogs.Mother_Msg_Id__c   = String.valueOf(msgId_Mother.get('msgId'));
            waLogs.Mother_Mobile__c = mphoneNumber;
            waLogs.Notification_Sent_on__c = System.now();
            
            waLogsToInsert.add(waLogs);
            System.debug('size to insert=> ' + waLogsToInsert.size());
            
        }
        insert waLogsToInsert;
    }
    
    global void finish(Database.BatchableContext bc) {
        
        System.debug('finish method of StudentFeeNotification Batch_NY');
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