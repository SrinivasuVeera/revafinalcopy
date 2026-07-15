trigger RevaGuestHouseBookingTrigger on Reva_Guest_House_Booking__c (before update, After insert, After Update) {
    if(trigger.isBefore){
        if(trigger.isUpdate){
           // RevaGuestHouseBookingTriggerHandler.handleBookingAvailability(Trigger.new, Trigger.oldMap);
        }
    }if(trigger.isAfter){
        if(trigger.IsInsert){
            For(Reva_Guest_House_Booking__c sr:Trigger.new){
                If(sr.Type_of_Guest__c == 'Parents' || sr.Type_of_Guest__c == 'Others' || sr.Type_of_Guest__c == 'Alumini'  ){
                    //RevaGuestHouseBookingTriggerHandler.handleBookingPayments(Trigger.new);
                }
            }    
        }
        if(trigger.isUpdate){
            //Addedby Rajashekar 23sept2024
             For(Reva_Guest_House_Booking__c sr:Trigger.new){
                If(sr.Fee_Paid_Paid_Guest__c != true && (sr.Type_of_Guest__c == 'Parents' || sr.Type_of_Guest__c == 'Others' || sr.Type_of_Guest__c == 'Alumini') ){
                    RevaGuestHouseBookingTriggerHandler.handleBookingPayments(Trigger.new);
                }
            }
            //endshere
            For(Reva_Guest_House_Booking__c sr:Trigger.new){
                
                Reva_Guest_House_Booking__c oldguestduration = Trigger.oldMap.get(sr.Id);
                if(oldguestduration.End_Time__c != sr.End_Time__c  && (sr.Type_of_Guest__c == 'Parents' || sr.Type_of_Guest__c == 'Others' || sr.Type_of_Guest__c == 'Alumini')){
                    
                    RevaGuestHouseBookingTriggerHandler.handleExatandPayments(Trigger.new, Trigger.oldMap);
                }
            }
        }
    }
}