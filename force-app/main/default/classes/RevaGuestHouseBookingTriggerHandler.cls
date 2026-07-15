public class RevaGuestHouseBookingTriggerHandler {
   
    public static void handleBookingPayments(List<Reva_Guest_House_Booking__c> newBookings){
        
      Reva_Guest_House_Booking__c Guest = [SELECT id,Name,Room_Type__c,No_of_Rooms__c,Duration__c,ContactLookUp__c,Sharing_Type__c From Reva_Guest_House_Booking__c Where Id=:newBookings[0].Id ];
        Decimal amount = 0;
        Decimal durationInHours = guest.Duration__c;
     
/*
        Decimal totalDays =  durationInHours <= 13 ? 0 :
                            (durationInHours > 13 && durationInHours < 24) ? 1 :
                            (durationInHours >= 24 && durationInHours < 48) ? 2 :
                            Math.ceil(durationInHours / 24);
        
        System.debug('totalDays:'+durationInHours);
        System.debug('totalDays:'+totalDays);
        
        String sharingType;
        if (guest.Room_Type__c == 'Non A/C' && totalDays == 0 ) {
            sharingType = durationInHours <= 2 ? '2hours' :
            durationInHours > 2 && durationInHours <= 6 ? '6hours' :
            '12hours';
        } else if (guest.Room_Type__c == 'A/C'  && totalDays == 0) {
            sharingType = durationInHours <= 13 ? '12hours' : guest.Sharing_Type__c;
        } else {
            sharingType = guest.Sharing_Type__c;
        }
         
        System.debug('sharingType:'+sharingType);*/
        
         Decimal totalDays = durationInHours <= 24 ? 1 :
                            (durationInHours > 24 && durationInHours < 48) ? 2 :
                            Math.ceil(durationInHours / 24);
        String NoofRooms = Guest.No_of_Rooms__c;
        Decimal Rooms =  Decimal.valueOf(NoofRooms);
        Try{
            Guest_House_Booking__c Customsett=[SELECT id,Amount__c,Room_Type__c,Sharing__c FROM Guest_House_Booking__c WHERE Room_Type__c= : Guest.Room_Type__c AND Sharing__c =:guest.Sharing_Type__c];
            If(totalDays > 0 ){
                amount = (customSett.Amount__c * totalDays)*Rooms;
            }
            /*else{
               amount = customSett.Amount__c;
            }*/
        }Catch(Exception e){
            System.debug('No Sharing Type');
        }
        
        Student_Fee__c SF = New Student_Fee__c();
        //Modifiedby Rajashekar 23sept2024
        //SF.Fee_Type__c = 'Hostel Fee';
        SF.Fee_Type__c = 'Guest House Fee';	
        //endshere
        SF.Name ='Guest House Fee';
        SF.Contact__c = Guest.ContactLookUp__c; 
        SF.Amount_Pending__c = amount;
        SF.Amount__c = amount;
        SF.Actual_Program_Fee__c = amount;    
        SF.Amount_Paid__c = 0;
        SF.Premium__c = 0;
        SF.Concession__c = 0;
        SF.Scholarship__c = 0;
        SF.Payment_Type__c = 'Full Payment';
        SF.REVA_Guest_House_Booking__c = Guest.Id;
        Insert SF;
        
        //ModifiedByRajashekar for making test class pass
     /*   User user;
        if(test.isRunningTest()){
           
         Id userId = UserInfo.getUserId();
         user = [Select id,Name,ContactId,MobilePhone,Contact.Record_Type_Name__c,Profile.Name From User WHERE Id = :userId];
         user.profile.Name = 'Guest House Manager';
        
        }else{
            
         Id userId = UserInfo.getUserId();
             system.debug('user======>Id'+userId);
         user = [Select id,Name,ContactId,MobilePhone,Contact.Record_Type_Name__c,Profile.Name From User WHERE Id = :userId AND ContactId != NULL LIMIT 1 ];
        system.debug('user======>'+user);
        } */
      //ends here
        
       // If(user.Profile.Name == 'Guest House Manager' || user.Profile.Name == 'Non Teaching Profile'){
            student_Payment__c objStuFeePay1 = new Student_Payment__c();
                        objStuFeePay1.Amount__c = SF.Amount__c;
                       // objStuFeePay1.Billdesk_Url__c = ep;
                        objStuFeePay1.Contact__c =  SF.Contact__c;
                        objStuFeePay1.Payment_Status__c = 'Payment Link Created';
                        objStuFeePay1.Payment_Gateway__c = '';
                        objStuFeePay1.Mode_of_Payment__c = 'Online';
                        objStuFeePay1.Fee_Type__c =  SF.Fee_Type__c; 
                        objStuFeePay1.Program_Enrollment__c =  SF.Program_Enrollment__c;
                       
                        insert objStuFeePay1;
            
                  
                    Student_Fee_Payment__c studentFeePayment = new Student_Fee_Payment__c();
                    studentFeePayment.Student_Fee__c = SF.Id;
                    studentFeePayment.Student_Payment__c = objStuFeePay1.Id;
                    studentFeePayment.Line_Item_Payment_Status__c = objStuFeePay1.Payment_Status__c;
                    studentFeePayment.Mode_of_Payment__c = objStuFeePay1.Mode_of_Payment__c;
                    studentFeePayment.Line_Item_Payment_Gateway__c =  objStuFeePay1.Payment_Gateway__c;
                    studentFeePayment.Amount__c = objStuFeePay1.Amount__c;               
                    studentFeePayment.Transaction_Date_Time__c = system.now();
                    insert studentFeePayment;
            
       // }

    }
    
 public static void handleExatandPayments(List<Reva_Guest_House_Booking__c> newBookings, Map<Id, Reva_Guest_House_Booking__c> oldBookingsMa){
   
        Decimal oldDuration =0;
        
     for (Reva_Guest_House_Booking__c newBooking : newBookings) {
        Reva_Guest_House_Booking__c oldBooking = oldBookingsMa.get(newBooking.Id);
        if (oldBooking != null) {
           
           oldDuration = oldBooking.Duration__c;
    
            }
        }
      Reva_Guest_House_Booking__c Guest = [SELECT id,Name,Room_Type__c,No_of_Rooms__c,Duration__c,ContactLookUp__c,Sharing_Type__c From Reva_Guest_House_Booking__c Where Id=:newBookings[0].Id ];
        Student_Fee__c SF = new Student_Fee__c();
     system.debug('oldDuration==:'+oldDuration);
     system.debug('newDuration:'+guest.Duration__c);
        Decimal amount = 0;
        Decimal durationInHours =guest.Duration__c - oldDuration;
         
        Decimal totalDays = durationInHours <= 24 ? 1 :
                            (durationInHours > 24 && durationInHours < 48) ? 2 :
                            Math.ceil(durationInHours / 24);
     
           system.debug('Hello:'+totalDays);
     
       String NoofRooms = Guest.No_of_Rooms__c;
       Decimal Rooms =  Decimal.valueOf(NoofRooms);
     
        Try{
            Guest_House_Booking__c Customsett=[SELECT id,Amount__c,Room_Type__c,Sharing__c FROM Guest_House_Booking__c WHERE Room_Type__c= : Guest.Room_Type__c AND Sharing__c =:guest.Sharing_Type__c];
            SF =[SELECT Id,Name,Contact__c,Amount_Pending__c,Amount__c,Actual_Program_Fee__c FROM Student_Fee__c WHERE Contact__c =: Guest.ContactLookUp__c and Name Like '%Guest House Fee%' AND Fee_Type__c = 'Hostel Fee' Order by createdDate DESC LIMIT 1];

            If(totalDays > 0 ){
                amount = (customSett.Amount__c * totalDays)*Rooms;
            }
         
        }Catch(Exception e){
            System.debug('No Sharing Type');
        }
        
       Student_Fee__c SFees = New Student_Fee__c();
        SFees.Id = SF.id;
        SFees.Contact__c = Guest.ContactLookUp__c; 
        SFees.Amount_Pending__c = SF.Amount_Pending__c + amount;
        SFees.Amount__c =SF.Amount__c + amount;
        SFees.Actual_Program_Fee__c =SF.Actual_Program_Fee__c + amount;    
        Update SFees;


    }
  
}