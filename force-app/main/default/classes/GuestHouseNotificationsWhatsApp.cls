public class GuestHouseNotificationsWhatsApp {
    Public Static Decimal Amount =0;
    Public static Void HandlePaymentMethod(List<Student_Fee_Payment__c> stuPay) {
        List<Id> conRecs = new List<ID>();
        List<Id> StupayId = new List<ID>();
        Student_Fee__c sf= [Select Id,Name,Fee_Type__c From Student_Fee__c WHERE id =: stuPay[0].Student_Fee__c Limit 1];
        Student_Payment__c sp = [SELECT id, Name,Contact__c,Amount__c From Student_Payment__c Where id =: stuPay[0].Student_Payment__c limit 1];
        if(sf.Name == 'Guest House Fee') {
            conRecs.add(sp.Contact__c);
            Amount = sp.Amount__c;
            StupayId.add(sp.Id); 
        }
        If(Amount > 0 && conRecs.size() >0){
            PaymentMethod(conRecs,StupayId);
        }
    }
    
    
    Public static Void PaymentMethod(List<Id> conRecs, List<Id> StupayId) {
        System.debug('Hello:');
        List<Reva_Guest_House_Booking__c> Revaguestre = [Select id, Name,Sharing_Type__c,No_of_Rooms__c,Room_Type__c, Email__c, Mobile_Number__c,Guest_House_Room__c,Guest_House_Room__r.Name, Approved_by_Department_Head__c, Approved_By_General_Admin__c, 
                                                         Check_In__c, Check_Out__c, ContactLookUp__c,Start_Time__c,End_Time__c, ContactLookUp__r.Name,  Citizenship__c,Guest_Coordinator__c,
                                                         (select id,Name,Guest_Name__c from Persons__r limit 1) From Reva_Guest_House_Booking__c
                                                         WHERE ContactLookUp__c =: conRecs  ORDER by CreatedDate DESC Limit 1];
        System.debug('Hello:'+Revaguestre[0].Id);
        List<Domain> domainList = [SELECT Id, DomainType, Domain, HttpsOption FROM Domain WHERE HttpsOption ='CommunityAlt'];
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'guest_house_payment_link_final';
        List<Id> conStuPayIdMap = new List<Id>();
        List<Id> StudentPayId = new List<Id>();
        List<Student_payment__c> stuPayList=[SELECT Id, Name,Mode_of_Payment__c,Payment_Mode_Type__c, Amount__c, Contact__c, Billdesk_Url__c,Fee_Type__c, payment_status__c FROM Student_payment__c WHERE Contact__c =:conRecs and Id =:StupayId];
        System.debug('Hello:'+stuPayList[0].Id);
        for(Student_payment__c stupay : stuPayList){
            conStuPayIdMap.add(stupay.Contact__c);
            StudentPayId.add(stupay.Id);
        }
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Reva_Guest_House_Booking__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'guest_house_payment_link_final') {
                    for (String key : keys) {
                        if (key == 'Guest_name') {
                            //Modifiedby Rajashekar 23sept2024
                            //notification1.params.put(key, stu.ContactLookUp__r.Name);
                             System.debug('guestname==> : '+stu.Persons__r[0].Guest_Name__c);
                            notification1.params.put(key, stu.Persons__r[0].Guest_Name__c); 
                            //endshere
                        }else if (key == 'type_of_room') {
                            notification1.params.put(key.trim(), stu.Room_Type__c);
                        }else if (key == 'Check_in_Date') {
                            DateTime currentDateTime = stu.Start_Time__c;
                            String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                            notification1.params.put(key.trim(), formattedDateTime);
                        }else if (key == 'Check_out_date') {
                            DateTime currentDateTime = stu.End_Time__c;
                            String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                            notification1.params.put(key.trim(), formattedDateTime);
                        }else if (key == 'amount') {
                            notification1.params.put(key.trim(), String.ValueOf(Amount));
                            
                        }  else if (key == 'payment_link') {
                            //Modifiedby Rajashekar 23sept2024
                            string contactId = conStuPayIdMap[0];
                            string stufeepayId = StudentPayId[0];
                            notification1.params.put(key.trim(), 'https://' + domainList[0].Domain + '/Admissions/s/payment-page?contactId='+ contactId + '&isPAF=true&isGuest=true&stupayid='+stufeepayId);
                            // https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/payment-page?contactId=0035j00000Pu8i6AAB&isPAF=true&isGuest=true&stupayid=a1PIl000000GvASMA0
                            system.debug('domain==> '+ domainList[0].Domain + ' conStuPayIdMap==> '+ contactId + '  StudentPayId==> '+ stufeepayId);
                            //endshere
                        }      
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Mobile_Number__c !=null){
                            String plusRemoved = stu.Mobile_Number__c.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
    
    
    public class InputParameters {
        @InvocableVariable(required=true)
        public List<String> recordIds;
        
        @InvocableVariable(required=true)
        public String TemplateTypeList; 
        
    }
    
    @InvocableMethod(label='Guest House Notifications')
    Public static Void HandleMethod(List<InputParameters> inputs){
        List<Id> RecordId =inputs[0].recordIds ;
        String TemplateType=inputs[0].TemplateTypeList;
        System.debug('RecordId:'+RecordId);
        GuestHouseNotificationsSMS.makeCalloutAsync(RecordId,TemplateType);
        if(TemplateType == 'Booking'){
            GuestBooking(RecordId);
        }
        else if(TemplateType == 'Allocation'){
            RoomAllocationForguest(RecordId);  
        }else if(TemplateType == 'Department Allocation'){
            RoomAllocationForDptHead(RecordId);
        }
        else if(TemplateType == 'Check In'){
            CheckInNotify(RecordId);
        }
        else if(TemplateType == 'Check Out'){
            CheckOutNotify(RecordId);
        }
        else if(TemplateType == 'Cancellation'){
            CancellationNotify(RecordId);
            CancellationNotifyGuestManager(RecordId);
        }
        else if(TemplateType == 'General Admin'){
            GeneralAdminApproval(RecordId);
        } 
        else if(TemplateType == 'Department Head'){
            DepartmentHeadApproval(RecordId);
        } 
        else if(TemplateType == 'Guest Manger'){
            ConfirmationGuestManger(RecordId);
        }        
    }
    
    Public static Void GuestBooking(List<Id> RecordId){
        System.debug('Phone Number -->'+RecordId);
        List<Reva_Guest_House_Booking__c> Revaguestre = [Select id, Name,Sharing_Type__c,Room_Type__c, Email__c, Mobile_Number__c,Guest_House_Room__c, Approved_by_Department_Head__c, Approved_By_General_Admin__c, 
                                                         Check_In__c, Check_Out__c, ContactLookUp__c, ContactLookUp__r.Name,  Citizenship__c,Guest_Coordinator__c
                                                          From Reva_Guest_House_Booking__c 
                                                         WHERE id =: RecordId];

         System.debug('Revaguestre -->'+Revaguestre);
        
        String templateId = 'guest_house_booking_confirmation';
        
        WhatsApp_Notification_Template__mdt metadata = [
            SELECT Template_Field__c 
            FROM WhatsApp_Notification_Template__mdt 
            WHERE Template_ID__c = :templateId 
            LIMIT 1
        ];
        
        // Map to store notifications for each contact's phone number
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for (Reva_Guest_House_Booking__c clist : Revaguestre) {
            List<Guest_Person__c> guestPersons =[SELECT Id ,Guest_Name__c ,Name FROM  Guest_Person__c WHERE REVA_Guest_House_Booking__c =: clist.Id LIMIT 1];    
            System.debug('guestPersons----'+guestPersons);       
             Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
            notification.templateId = templateId;
            notification.params = new Map<String, String>();
            //Modifiedby Rajashekar 23sept2024
            //notification.params.put('name', clist.ContactLookUp__r.Name); 
            //notification.params.put('room_type', clist.Room_Type__c);
            notification.params.put('name', guestPersons[0].Guest_Name__c != null ? guestPersons[0].Guest_Name__c :'' ); 
            notification.params.put('room_type', clist.Room_Type__c + 'Room');
            //endshere
            
            if(clist.Mobile_Number__c !=null){
                String plusRemoved = clist.Mobile_Number__c.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                phoneNumbersToNotifications.put(correctedWhatsappNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});                 
            }  
            
            System.debug('Phone Number -->'+clist.Mobile_Number__c);
            
            //  HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            
        }     
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
    
    Public static Void RoomAllocationForguest(List<Id> RecordId){
        List<Reva_Guest_House_Booking__c> Revaguestre = [Select id,Room_Details__c, Name,Sharing_Type__c,No_of_Rooms__c,Room_Type__c, Email__c, Mobile_Number__c,Guest_House_Room__c,Guest_House_Room__r.Name, Approved_by_Department_Head__c, Approved_By_General_Admin__c, 
                                                         Check_In__c, Check_Out__c,No_of_Guest__c, ContactLookUp__c,Start_Time__c,End_Time__c, ContactLookUp__r.Name,  Citizenship__c,Guest_Coordinator__c   From Reva_Guest_House_Booking__c
                                                         WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'guest_house_room_allocation';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Reva_Guest_House_Booking__c stu : Revaguestre ){
            List<Guest_Person__c> guestPersons =[SELECT Id ,Guest_Name__c ,Name FROM  Guest_Person__c WHERE REVA_Guest_House_Booking__c =: stu.Id LIMIT 1];    // added the query

            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'guest_house_room_allocation') {
                    for (String key : keys) {
                        if (key == 'name') {
                            notification1.params.put(key, stu.ContactLookUp__r.Name);
                        }else if (key == 'Guest_number') {
                            notification1.params.put(key.trim(), String.valueOf(stu.No_of_Guest__c));
                            
                        }else if (key == 'Room_Number') {
                            notification1.params.put(key.trim(), stu.Room_Details__c);
                            
                        }else if (key == 'Booking_id') {
                            notification1.params.put(key.trim(), stu.Name);
                            
                        }else if (key == 'Check_in_Date_and_time') {
                            DateTime currentDateTime = stu.Start_Time__c;
                            String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                            notification1.params.put(key.trim(), formattedDateTime);
                        }else if (key == 'Check_out_Date_and_time') {
                            DateTime currentDateTime = stu.End_Time__c;
                            String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                            notification1.params.put(key.trim(), formattedDateTime);
                        }        
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Mobile_Number__c !=null){
                            String plusRemoved = stu.Mobile_Number__c.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
        
    }
    
    
    Public static Void RoomAllocationForDptHead(List<Id> RecordId){
        List<Reva_Guest_House_Booking__c> Revaguestre = [Select id, Name,Sharing_Type__c,No_of_Rooms__c,Room_Type__c, Email__c, Mobile_Number__c,Guest_House_Room__c,Guest_House_Room__r.Name, Approved_by_Department_Head__c, Approved_By_General_Admin__c, 
                                                         Check_In__c, Check_Out__c, ContactLookUp__c,Start_Time__c,End_Time__c, ContactLookUp__r.Name,  Citizenship__c,Guest_Coordinator__c,Room_Details__c,
                                                         Department_Head__r.Phone , Department_Head__r.Name,Department_Head__r.MobilePhone From Reva_Guest_House_Booking__c
                                                         WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'guest_house_room_alloaction_confirmation_dept_head';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Reva_Guest_House_Booking__c stu : Revaguestre ){
            List<Guest_Person__c> guestPersons =[SELECT Id ,Guest_Name__c ,Name FROM  Guest_Person__c WHERE REVA_Guest_House_Booking__c =: stu.Id LIMIT 1];    // added the query

            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'guest_house_room_alloaction_confirmation_dept_head') {
                    for (String key : keys) {
                        if (key == 'Dept_head_name') {
                            notification1.params.put(key, stu.Department_Head__r.Name);
                        }else if (key == 'name_of_the_guest') {
                            notification1.params.put(key.trim(),guestPersons[0].Name );
                            
                        }else if (key == 'Room_Number') {
                            notification1.params.put(key.trim(), stu.Room_Details__c);
                        }
                        else if (key == 'Checkin_Date') {
                            DateTime currentDateTime = stu.Start_Time__c;
                            String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                            notification1.params.put(key.trim(), formattedDateTime);
                        }else if (key == 'Checkout_Date') {
                            DateTime currentDateTime = stu.End_Time__c;
                            String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                            notification1.params.put(key.trim(), formattedDateTime);
                        }else if (key == 'booking_id') {
                            notification1.params.put(key.trim(), stu.Name);
                        }        
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Mobile_Number__c !=null){
                            String plusRemoved = stu.Department_Head__r.Phone !=null ? stu.Department_Head__r.Phone.replace('+', '') : stu.Department_Head__r.MobilePhone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
        
    }
    
    
    
    Public static Void CheckInNotify(List<Id> RecordId){
        List<Reva_Guest_House_Booking__c> Revaguestre = [Select id, Name,Sharing_Type__c,No_of_Rooms__c,Room_Type__c, Email__c, Mobile_Number__c,Guest_House_Room__c,Guest_House_Room__r.Name, Approved_by_Department_Head__c, Approved_By_General_Admin__c, 
                                                         Check_In__c, Check_Out__c, ContactLookUp__c,Start_Time__c,End_Time__c, ContactLookUp__r.Name,  Citizenship__c,Guest_Coordinator__c   From Reva_Guest_House_Booking__c
                                                         WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'guest_house_checkin';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Reva_Guest_House_Booking__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'guest_house_checkin') {
                    for (String key : keys) {
                        if (key == 'name') {
                            notification1.params.put(key, stu.ContactLookUp__r.Name);
                        }else if (key == 'date') {
                            //  notification1.params.put(key.trim(), String.valueOf(stu.No_of_Guest__c));
                            DateTime currentDateTime = stu.Start_Time__c;
                            String formattedDate = currentDateTime.format('yyyy-MM-dd');
                            notification1.params.put(key.trim(), formattedDate);
                        }else if (key == 'time') {
                            DateTime currentDateTime = stu.Start_Time__c;
                            String formattedTime = currentDateTime.format('HH:mm:ss');
                            notification1.params.put(key.trim(), formattedTime);         
                        }
                        else if (key == 'date') {
                            //  notification1.params.put(key.trim(), String.valueOf(stu.No_of_Guest__c));
                            DateTime currentDateTime = stu.End_Time__c;
                            String formattedDate = currentDateTime.format('yyyy-MM-dd');
                            notification1.params.put(key.trim(), formattedDate);
                            
                        }else if (key == 'time') {
                            DateTime currentDateTime = stu.End_Time__c;
                            String formattedTime = currentDateTime.format('HH:mm:ss');
                            notification1.params.put(key.trim(), formattedTime);  
                        }                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Mobile_Number__c !=null){
                            String plusRemoved = stu.Mobile_Number__c.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));        
    }
    
    
    Public static Void CheckOutNotify(List<Id> RecordId){
        List<Reva_Guest_House_Booking__c> Revaguestre = [Select id, Name,Sharing_Type__c,No_of_Rooms__c,Room_Type__c, Email__c, Mobile_Number__c,Guest_House_Room__c,Guest_House_Room__r.Name, Approved_by_Department_Head__c, Approved_By_General_Admin__c, 
                                                         Check_In__c, Check_Out__c, ContactLookUp__c,Start_Time__c,End_Time__c, ContactLookUp__r.Name,  Citizenship__c,Guest_Coordinator__c   From Reva_Guest_House_Booking__c
                                                         WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'guest_house_checkout';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Reva_Guest_House_Booking__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'guest_house_checkout') {
                    for (String key : keys) {
                        if (key == 'name') {
                            notification1.params.put(key, stu.ContactLookUp__r.Name);
                        }else if (key == 'date') {
                            DateTime currentDateTime = stu.End_Time__c;
                            String formattedDate = currentDateTime.format('yyyy-MM-dd');
                            notification1.params.put(key.trim(), formattedDate);
                            
                        }else if (key == 'time') {
                            DateTime currentDateTime = stu.End_Time__c;
                            String formattedTime = currentDateTime.format('HH:mm:ss');
                            notification1.params.put(key.trim(), formattedTime);  
                        }                        
                    }       
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Mobile_Number__c !=null){
                            String plusRemoved = stu.Mobile_Number__c.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));  
    }
    
    
    Public static Void CancellationNotify(List<Id> RecordId){
        List<Reva_Guest_House_Booking__c> Revaguestre = [Select id, Name,Sharing_Type__c,No_of_Rooms__c,Room_Type__c, Email__c, Mobile_Number__c,Guest_House_Room__c,Guest_House_Room__r.Name, Approved_by_Department_Head__c, Approved_By_General_Admin__c, 
                                                         Check_In__c, Check_Out__c, ContactLookUp__c,Start_Time__c,End_Time__c, ContactLookUp__r.Name,  Citizenship__c,Guest_Coordinator__c   From Reva_Guest_House_Booking__c
                                                         WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'guest_house_booking_cancellation';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Reva_Guest_House_Booking__c stu : Revaguestre ){
         List<Guest_Person__c> guestPersons =[SELECT Id ,Guest_Name__c ,Name FROM  Guest_Person__c WHERE REVA_Guest_House_Booking__c =: stu.Id LIMIT 1];    // added the query

            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'guest_house_booking_cancellation') {
                    for (String key : keys) {
                        if (key == 'Guest_name') {
                            notification1.params.put(key, guestPersons[0].Guest_Name__c !=null ? guestPersons[0].Guest_Name__c : ''); 
                        }else if (key == 'booking_id') {
                            notification1.params.put(key, stu.Name);
                            
                        }else if (key == 'cancellation_ID') {
                            notification1.params.put(key, stu.Name); 
                        }                        
                    }       
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Mobile_Number__c !=null){
                            String plusRemoved = stu.Mobile_Number__c.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));  
        
    }
    
    Public static Void CancellationNotifyGuestManager(List<Id> RecordId){
        List<Reva_Guest_House_Booking__c> Revaguestre = [Select id, Name,Sharing_Type__c,No_of_Rooms__c,Room_Type__c, Email__c, Mobile_Number__c,Guest_House_Room__c,Guest_House_Room__r.Name, Approved_by_Department_Head__c, Approved_By_General_Admin__c, 
                                                         Check_In__c, Check_Out__c, ContactLookUp__c,Start_Time__c,End_Time__c, ContactLookUp__r.Name,  Citizenship__c,Guest_Coordinator__c   From Reva_Guest_House_Booking__c
                                                         WHERE id =: RecordId];

        User US = [SELECT  id, Name,MobilePhone From User Where Profile.Name = 'Guest House Manager' limit 1 ];
        string GuestHouseManger= US.Name;
        String ManagerPhoneNumber= US.MobilePhone;
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'gh_room_cancellation_manager_notif';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Reva_Guest_House_Booking__c stu : Revaguestre ){
        List<Guest_Person__c> guestPersons =[SELECT Id ,Guest_Name__c ,Name FROM  Guest_Person__c WHERE REVA_Guest_House_Booking__c =: stu.Id LIMIT 1];    // added the query

            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'gh_room_cancellation_manager_notif') {
                    for (String key : keys) {
                        if (key == 'GH_manager') {
                            notification1.params.put(key, GuestHouseManger);
                        }
                        else if (key == 'guest_name') {
                            notification1.params.put(key, guestPersons[0].Guest_Name__c !=null ? guestPersons[0].Guest_Name__c : ''); 
                        }else if (key == 'b_id') {
                            notification1.params.put(key, stu.Name); 
                            
                        }else if (key == 'c_Id') {
                            notification1.params.put(key, stu.Name); 
                        }                        
                    }       
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(ManagerPhoneNumber !=null){
                            String plusRemoved = ManagerPhoneNumber.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));  
    }
    
    Public static Void GeneralAdminApproval(List<Id> RecordId){
        List<Reva_Guest_House_Booking__c> Revaguestre = [Select id, Name,Sharing_Type__c,No_of_Rooms__c,Room_Type__c, Email__c, Mobile_Number__c,Guest_House_Room__c,Guest_House_Room__r.Name, Approved_by_Department_Head__c, Approved_By_General_Admin__c, 
                                                         Check_In__c, Check_Out__c,Type_of_Guest__c, ContactLookUp__c,Start_Time__c,Name_of_Dept_School__c,Purpose_of_Visit__c,End_Time__c, ContactLookUp__r.Name,  Citizenship__c,Guest_Coordinator__c ,
                                                         Department_Head__r.Name,General_Admin__r.Name,Department_Head__r.MobilePhone,General_Admin__r.MobilePhone
                                                         From Reva_Guest_House_Booking__c WHERE id =: RecordId];


        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'guest_house_approval_general_admin';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        
        String url = System.Url.getOrgDomainUrl().toExternalForm(); // Fetches the org domain URL
        String updatedUrl = url.replace('my.salesforce.com', 'lightning.force.com');
        System.debug('Updated URL: ' + updatedUrl);
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Reva_Guest_House_Booking__c stu : Revaguestre ){
            List<Guest_Person__c> guestPersons =[SELECT Id ,Guest_Name__c ,Name FROM  Guest_Person__c WHERE REVA_Guest_House_Booking__c =: stu.Id LIMIT 1];
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'guest_house_approval_general_admin') {
                    for (String key : keys) {
                        if (key == 'General_admin_name') {
                            notification1.params.put(key, stu.General_Admin__r.Name);
                        }
                        else if (key == 'University_or_Department') {
                            notification1.params.put(key, stu.Type_of_Guest__c);
                        }
                        else if (key == 'name_of_the_guest') {
                            //notification1.params.put(key, stu.ContactLookUp__r.Name!=Null ? stu.ContactLookUp__r.Name:'');
                            notification1.params.put(key, guestPersons[0].Guest_Name__c != Null ? guestPersons[0].Guest_Name__c :'');
                        }else if (key == 'Purpose_of_Visit') {
                            notification1.params.put(key, stu.Purpose_of_Visit__c);
                            
                        }else if (key == 'date_and_time_of_visit') {
                            DateTime currentDateTime = stu.Start_Time__c;
                            String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                            notification1.params.put(key.trim(), formattedDateTime);
                            
                        }else if (key == 'booking_id') {
                            notification1.params.put(key, stu.Name); 
                        }                  
                        else if (key == 'link') {
                            String dynamicLink = updatedUrl + '/' + stu.Id;
                            notification1.params.put(key.trim(), dynamicLink);
                            //  notification1.params.put(key.trim(), 'https://' + domainList[0].Domain +'/'+ stu.Id); 
                        } 
                    }       
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.General_Admin__r.MobilePhone !=null){
                            String plusRemoved = stu.General_Admin__r.MobilePhone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));  
    }
    
    Public static Void DepartmentHeadApproval(List<Id> RecordId){
        List<Reva_Guest_House_Booking__c> Revaguestre = [Select id, Name,Sharing_Type__c,No_of_Rooms__c,Room_Type__c, Email__c, Mobile_Number__c,Guest_House_Room__c,Guest_House_Room__r.Name, Approved_by_Department_Head__c, Approved_By_General_Admin__c, 
                                                         Check_In__c, Check_Out__c, ContactLookUp__c,Start_Time__c,Name_of_Dept_School__c,Purpose_of_Visit__c,End_Time__c, ContactLookUp__r.Name,  Citizenship__c,Guest_Coordinator__c,
                                                         Department_Head__r.Name,General_Admin__r.Name,Department_Head__r.MobilePhone,General_Admin__r.MobilePhone
                                                         From Reva_Guest_House_Booking__c WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'guest_house_room_approval_dept_head';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        
        String url = System.Url.getOrgDomainUrl().toExternalForm(); // Fetches the org domain URL
        String updatedUrl = url.replace('my.salesforce.com', 'lightning.force.com');
        System.debug('Updated URL: ' + updatedUrl);
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Reva_Guest_House_Booking__c stu : Revaguestre ){

            List<Guest_Person__c> guestPersons =[SELECT Id ,Guest_Name__c ,Name FROM  Guest_Person__c WHERE REVA_Guest_House_Booking__c =: stu.Id LIMIT 1];

            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'guest_house_room_approval_dept_head') {
                    for (String key : keys) {
                        if (key == 'Dept_Head_name') {
                            notification1.params.put(key, stu.Department_Head__r.Name);
                        }
                        else if (key == 'name_of_the_guest') {
                           // notification1.params.put(key, stu.ContactLookUp__r.Name!=Null ? stu.ContactLookUp__r.Name:'');
                           notification1.params.put(key, guestPersons[0].Guest_Name__c != Null ? guestPersons[0].Guest_Name__c :'');

                        }else if (key == 'Purpose_of_Visit') {
                            notification1.params.put(key, stu.Purpose_of_Visit__c);
                            
                        }else if (key == 'date_and_time_of_visit') {
                            DateTime currentDateTime = stu.Start_Time__c;
                            String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                            notification1.params.put(key.trim(), formattedDateTime);
                            
                        }else if (key == 'booking_id') {
                            notification1.params.put(key, stu.Name); 
                        }       
                        else if (key == 'link') {
                            String dynamicLink = updatedUrl + '/' + stu.Id;
                            notification1.params.put(key.trim(), dynamicLink);
                            //  notification1.params.put(key.trim(), 'https://' + domainList[0].Domain +'/'+ stu.Id); 
                        } 
                    }       
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Department_Head__r.MobilePhone !=null){
                            String plusRemoved = stu.Department_Head__r.MobilePhone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));  
    }
    Public static Void ConfirmationGuestManger(List<Id> RecordId){
        List<Reva_Guest_House_Booking__c> Revaguestre = [Select id, Name,Sharing_Type__c,No_of_Rooms__c,Room_Type__c, Email__c, Mobile_Number__c,Guest_House_Room__c,Guest_House_Room__r.Name, Approved_by_Department_Head__c, Approved_By_General_Admin__c, 
                                                         Check_In__c, Check_Out__c,CreatedDate, ContactLookUp__c,Start_Time__c,No_of_Guest__c,Type_of_Guest__c,Name_of_Dept_School__c,Purpose_of_Visit__c,End_Time__c, ContactLookUp__r.Name,  Citizenship__c,Guest_Coordinator__c   From Reva_Guest_House_Booking__c
                                                         WHERE id =: RecordId];
        User US = [SELECT  id, Name,MobilePhone From User Where Profile.Name = 'Guest House Manager' limit 1 ];
        string GuestHouseManger= US.Name;
        String ManagerPhoneNumber= US.MobilePhone;
        
        String url = System.Url.getOrgDomainUrl().toExternalForm(); // Fetches the org domain URL
        String updatedUrl = url.replace('my.salesforce.com', 'lightning.force.com');
        System.debug('Updated URL: ' + updatedUrl);
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId ='guest_house_room_alloc_req'; //'guest_house_room_allocation_request_gh_manager';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Reva_Guest_House_Booking__c stu : Revaguestre ){

            List<Guest_Person__c> guestPersons =[SELECT Id ,Guest_Name__c ,Name FROM  Guest_Person__c WHERE REVA_Guest_House_Booking__c =: stu.Id LIMIT 1];

            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'guest_house_room_alloc_req'){  //'guest_house_room_allocation_request_gh_manager') {
                    for (String key : keys) {
                        if (key == 'name_of_guest_house_manger') {
                            notification1.params.put(key, GuestHouseManger);
                        }
                        else if (key == 'name_of_the_guest') {
                           // notification1.params.put(key, stu.ContactLookUp__r.Name!=Null ? stu.ContactLookUp__r.Name:'');
                           notification1.params.put(key, guestPersons[0].Guest_Name__c != Null ? guestPersons[0].Guest_Name__c :'');

                        }else if (key == 'guest_number') {
                            notification1.params.put(key, string.valueof(stu.No_of_Guest__c));
                            
                        }else if (key == 'University_Guest_or_Department_guest_or_other') {
                            notification1.params.put(key, stu.Type_of_Guest__c);
                        }else if (key == 'Type_of_Room') {
                            notification1.params.put(key, stu.Room_Type__c);
                        }else if (key == 'Date_of_Booking') { 
                            DateTime currentDateTime = stu.CreatedDate;
                            String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                            notification1.params.put(key.trim(), formattedDateTime);
                        }else if (key == 'Check_in_date') {
                            DateTime currentDateTime = stu.Start_Time__c;
                            String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                            notification1.params.put(key.trim(), formattedDateTime);
                            
                        }else if (key == 'Check_out_Date') {
                            DateTime currentDateTime = stu.End_Time__c;
                            String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                            notification1.params.put(key.trim(), formattedDateTime);
                            
                        }
                        else if (key == 'link') {
                            String dynamicLink = updatedUrl + '/' + stu.Id;
                            notification1.params.put(key.trim(), dynamicLink);
                            //  notification1.params.put(key.trim(), 'https://' + domainList[0].Domain +'/'+ stu.Id); 
                        }                        
                    }       
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(ManagerPhoneNumber !=null){
                            String plusRemoved = ManagerPhoneNumber.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));  
    }
}