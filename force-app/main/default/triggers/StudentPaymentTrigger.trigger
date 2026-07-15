trigger StudentPaymentTrigger on Student_Payment__c (after insert,after update, After Delete) {
    List<Student_Payment__c> stupayList = new List<Student_Payment__c>();
    List<Student_Payment__c> stuPayPendingList = new List<Student_Payment__c>();
    List<Student_Payment__c> successPayments = new List<Student_Payment__c>();

   // if(Label.DeactivateStudentPaymentTrigger_c == 'false'){ 
    switch on Trigger.OperationType{
        when AFTER_UPDATE{
            
       /*       for (Student_Payment__c sp : Trigger.New) {
             if(sp.Fee_Type__c == 'Hostel Fee' && sp.Payment_Status__c == 'Payment Link Created' && sp.Name.contains('Guest House Fee') ){ 
                 GuestHouseNotificationsWhatsApp.HandlePaymentMethod(Trigger.New);
                 system.debug('check');
            }
               }*/
            
            StudentPaymentTriggerHandler.handlePaymentUpdates(Trigger.new, Trigger.oldMap);
            // SAP_PaymentAllocationHandler.handlePaymentAllocation(Trigger.new, Trigger.oldMap);
            OfflinePaymentIntiated.HandleUpdate(Trigger.new, Trigger.oldMap);
            
            Set<Id> paymentIds = new Set<Id>();
                for (Student_Payment__c objRec : Trigger.New) {
                    Student_Payment__c oldRec = Trigger.oldMap.containsKey(objRec.Id) ? Trigger.oldMap.get(objRec.Id) : new Student_Payment__c();
                    if (objRec.Payment_Status__c == 'Success' && objRec.Payment_Status__c != oldRec.Payment_Status__c) {
                        paymentIds.add(objRec.Id);
                        successPayments.add(objRec);
                    }
                }
                if(!Test.isRunningTest()){
                StudentPaymentTriggerEmailHandler.sendEmail(paymentIds);
            }
            	StudentPaymentTriggerHandler.sendPaymentNotifications(successPayments);
            
        }
         when AFTER_INSERT{ 
          SAP_PaymentAllocationHandler.handlePaymentAllocation(Trigger.new, Trigger.oldMap);
          for(Student_Payment__c sp : trigger.new){
            if(sp.Fee_Type__c != 'Application Fee'){
              stupayList.add(sp);
              if(sp.Payment_Status__c != null && sp.Fee_Type__c != null && sp.Split_Booking_Fee__c == false && sp.Payment_Status__c == 'Pending' && (sp.Fee_Type__c.toLowerCase().contains('university') || sp.Fee_Type__c.toLowerCase().contains('tuition'))){
                stuPayPendingList.add(sp);
              }
            }
          }
          if(stupayList.size() > 0){
            StudentPaymentTriggerHandler.handlePaymentUpdates(Trigger.new, null);
          }
          if(stuPayPendingList.size() > 0){
              if(!Test.isRunningTest()){
                OfflinePaymentIntiated.filterApplicantsOnly(stuPayPendingList);
              }         
            }             
             
               Set<Id> paymentIds = new Set<Id>();
                for (Student_Payment__c objRec : Trigger.New) {
                    if (objRec.Payment_Status__c == 'Success') {
                        paymentIds.add(objRec.Id);
                    }
                }
                if(!Test.isRunningTest()){
                StudentPaymentTriggerEmailHandler.sendEmail(paymentIds);
            }
            
         /*      for (Student_Payment__c sp : Trigger.New) {
             if(sp.Fee_Type__c == 'Hostel Fee' && sp.Payment_Status__c == 'Payment Link Created' && sp.Name.contains('Guest House Fee') ){
                 GuestHouseNotificationsWhatsApp.HandlePaymentMethod(Trigger.New);
            }
               }*/
            
        }

    //}
        
        when AFTER_DELETE{ 
            OfflinePaymentIntiated.handleDelete(Trigger.old);
            
            AdmissionAutoProcessService.handleDeletedPayments(Trigger.old);
        }
    }
   /* if(Trigger.isAfter && Trigger.isInsert)
    //      SAP_PaymentAllocationHandler.handlePaymentAllocation(Trigger.new, Trigger.oldMap);*/
    // if(Trigger.isAfter){
    //     if(Trigger.Isdelete){
    //         OfflinePaymentIntiated.handleDelete(Trigger.old);
    //     }
    // }
    
}