public class GuestHouseNotificationsSMS {

    public static String GeneralAdminNumber;
    public static String DptHeadNumber;
    public static String GuestPhoneNumber;
    public static String ManagerPhoneNumber;
    public static String GuestName;
    public static String RoomType;
    public static String ShareType;
    public static String RoomNumber;
    public static String StartDateTime;
    public static String EndDateTime;
    public static String BookingId;
    public static String PurposeOfVisit;
    public static String DptHeadNAme;
    public static String GeneralAdminName;
    public static String GuestHouseManger; 
    public static String StartTime;
    public static String EndTime; 
    public static String StartDate;
    public static String EndDate; 
    
    @Future(callout=true)
    public static void makeCalloutAsync(List<Id> RecordId,String TemplateType) {
        
        List<Reva_Guest_House_Booking__c> Revaguestre = [Select id, Name,Sharing_Type__c,Room_Details__c,Room_Type__c, Email__c, Mobile_Number__c,Guest_House_Room__c, Approved_by_Department_Head__c, Approved_By_General_Admin__c, 
                                                         Check_In__c, Check_Out__c,Department_Head__r.Name,General_Admin__r.Name,Department_Head__r.MobilePhone,General_Admin__r.MobilePhone,Purpose_of_Visit__c, Start_Time__c,End_Time__c,ContactLookUp__c, ContactLookUp__r.Name,  Citizenship__c,Guest_Coordinator__c,
                                                         (select id,Name,Guest_Name__c from Persons__r limit 1) From Reva_Guest_House_Booking__c
                                                         WHERE id =: RecordId]; 
        User US = [SELECT  id, Name,MobilePhone From User Where Profile.Name = 'Guest House Manager' limit 1 ];
        GuestHouseManger= US.Name;
        ManagerPhoneNumber= US.MobilePhone;
        for(Reva_Guest_House_Booking__c Rgus:Revaguestre){
            //Modifiedby Rajashekar 23sept2024
            // GuestName = Rgus.ContactLookUp__r.Name;
            //  RoomType = Rgus.Room_Type__c;
            GuestName = Rgus.Persons__r[0].Guest_Name__c;
            RoomType = Rgus.Room_Type__c + ' Room';
            //endshere
            ShareType = Rgus.Sharing_Type__c;
            RoomNumber =  Rgus.Room_Details__c;
            BookingId = Rgus.Name;
            PurposeOfVisit = Rgus.Purpose_of_Visit__c;
            DptHeadNAme =Rgus.Department_Head__r.Name;
            GeneralAdminName = Rgus.General_Admin__r.Name;
            
            DateTime currentStartDateTime = Rgus.Start_Time__c;
            StartDateTime = currentStartDateTime.format('dd-MM-yyyy HH:mm:ss');
            
            DateTime currentEndDateTime = Rgus.End_Time__c;
            EndDateTime = currentEndDateTime.format('dd-MM-yyyy HH:mm:ss');
            
             DateTime currentStartDate = Rgus.Start_Time__c;
             StartDate = currentStartDate.format('dd-MM-yyyy');
            
            DateTime currentEndDate = Rgus.End_Time__c;
             EndDate = currentEndDate.format('dd-MM-yyyy');
            
             DateTime currentstartTime = Rgus.Start_Time__c;
             StartTime = currentstartTime.format('HH:mm:ss');
            
             DateTime currentendTime = Rgus.End_Time__c;
             EndTime = currentendTime.format('HH:mm:ss');
            
            if(Rgus.Mobile_Number__c != null){
                String plusRemoved = Rgus.Mobile_Number__c.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                GuestPhoneNumber = correctedWhatsappNumber;
            } if(Rgus.Department_Head__r.MobilePhone != null){
                String plusRemoved = Rgus.Department_Head__r.MobilePhone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                DptHeadNumber = correctedWhatsappNumber;
            } if(Rgus.General_Admin__r.MobilePhone != null){
                String plusRemoved = Rgus.General_Admin__r.MobilePhone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                GeneralAdminNumber = correctedWhatsappNumber;
            }
            
            if (!Revaguestre.isEmpty()) {
                List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>(); 
                if (TemplateType == 'Booking') {
                    GuestBooking(messageList);
                } else if (TemplateType == 'Allocation') {
                    RoomAllocationForguest(messageList);
                } else if (TemplateType == 'Check In') {
                    CheckInNotify(messageList);
                } else if (TemplateType == 'Check Out') {
                    CheckOutNotify(messageList);
                } else if (TemplateType == 'Cancellation') {
                    CancellationNotify(messageList);
                    CancellationNotifyGuestManager(messageList);
                } else if (TemplateType == 'General Admin') {
                    GeneralAdminApproval(messageList);
                } else if (TemplateType == 'Department Head') {
                    DepartmentHeadApproval(messageList);
                } else if (TemplateType == 'Guest Manger') {
                    ConfirmationGuestManger(messageList);
                }
                
                if (!messageList.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('Room_Booking_Confirmation', messageList);
                    SMS_API_Utility.SendSMSOneToMany('Room_Allocation_Confirmation', messageList);
                    SMS_API_Utility.SendSMSOneToMany('Check_in_Confirmation', messageList);
                    SMS_API_Utility.SendSMSOneToMany('Check_Out_Confirmation', messageList);
                    SMS_API_Utility.SendSMSOneToMany('Booking_Cancellation', messageList);
                    SMS_API_Utility.SendSMSOneToMany('Approval_Request_to_General_Admin', messageList);
                    SMS_API_Utility.SendSMSOneToMany('Approval_Request_DeptHead', messageList);
                    SMS_API_Utility.SendSMSOneToMany('Room_allocation_request_to_GH_manager', messageList);
                    SMS_API_Utility.SendSMSOneToMany('Booking_cancellation_to_GH_manager', messageList);
                }
            } else {
                System.debug('No related records found for the provided IDs');
            }
        }
    }
    
    
    public static void GuestBooking( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();
        string phnNumber=GuestPhoneNumber;
        String message = 'Dear '+GuestName+ ', \nYou have successfully booked a '+RoomType+' at REVA Guest House. Your allocated room will be notified to you soon.\nRegards,\nREVA University.';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007678168165584964';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
    public static void RoomAllocationForguest( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();
        string phnNumber=GuestPhoneNumber;
        String message = 'Dear '+GuestName+ ', \nYour room at REVA Guest House has been successfully allocated. Room Number: '+RoomNumber+' Check -In : '+StartDateTime+ ' Check- Out: '+EndDateTime+ '\nRegards,\nREVA University.';
      
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007294879048415922';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
    public static void CheckInNotify( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();
        string phnNumber=GuestPhoneNumber;
        String message = 'Dear '+GuestName+ ', \n You have checked in on '+StartDate+' at '+StartTime+'. Your check-out will be on ' +EndDate +' at '+EndTime+'.\nRegards,\nREVA University.';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007195432771912094';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
    public static void CheckOutNotify( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();
        string phnNumber=GuestPhoneNumber;
        String message = 'Dear '+GuestName+ ', \nYou have successfully checked out on '+EndDate+' at '+EndTime+'. we hope you had a pleasant stay.\nRegards,\nREVA University.';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007299199992900694';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
    public static void CancellationNotify( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();
        string phnNumber=GuestPhoneNumber;
        String message = 'Dear '+GuestName+ ', \nYour booking for REVA Guest House has been successfully cancelled.\nRegards,\nREVA University.';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007933615456225926';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
    public static void GeneralAdminApproval( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();
        string phnNumber=GeneralAdminNumber;
        String message = 'Dear '+GeneralAdminName+', \nYou have a guest approval request. Check the details in the system. Booking Id :'+BookingId+' \nRegards, \nREVA University.';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007059063884044128';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
    public static void DepartmentHeadApproval( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();
        string phnNumber=DptHeadNumber;
        String message = 'Dear '+DptHeadNAme+', \nYou have a guest approval request.The details are given below. Guest Name: '+GuestName+' Purpose of Visit:'+PurposeOfVisit+' Date:'+StartDateTime+' \nRegards \nREVA University';
        				  //Dear Swamy, You have a guest approval request.The details are given below. Guest Name: Rohit Purpose of Visit:Address Students Date:12/12/24 Regards REVA University
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007515994250397062';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
    public static void ConfirmationGuestManger( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();
        string phnNumber=ManagerPhoneNumber;
        String message = 'Dear '+GuestHouseManger+ ', \nGuest booking confirmed. Allocate room for '+GuestName+' From '+StartDateTime+' to'+EndDateTime+'. Check details in the system.\nRegards,\nREVA University.';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007501693404282210';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
    public static void CancellationNotifyGuestManager( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();
        string phnNumber=ManagerPhoneNumber;
        String message = 'Dear '+GuestHouseManger+ ', \nOne of the guest bookings has been cancelled. Please check the details in the system. Booking Id: '+BookingId+'.\nRegards,\nREVA University.';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007635623645338074';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
}