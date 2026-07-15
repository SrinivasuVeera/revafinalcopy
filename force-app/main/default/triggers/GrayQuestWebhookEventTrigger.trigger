trigger GrayQuestWebhookEventTrigger on GrayQuest_Webhook_Event__e (after insert) {
    Set<String> refIds = new Set<String>();
    for(GrayQuest_Webhook_Event__e evt : Trigger.New) {
        if(evt.Reference_Id__c != null) refIds.add(evt.Reference_Id__c);
    }

    if(refIds.isEmpty()) return;

    Map<String, Student_Payment__c> paymentMap = new Map<String, Student_Payment__c>();
    for(Student_Payment__c sp : [SELECT Id, Reference_Id__c, Payment_Status__c FROM Student_Payment__c WHERE Reference_Id__c IN :refIds]){
        paymentMap.put(sp.Reference_Id__c, sp);
    }

    List<Student_Payment__c> paymentsToUpdate = new List<Student_Payment__c>();
    
    for(GrayQuest_Webhook_Event__e evt : Trigger.New){
        if(!paymentMap.containsKey(evt.Reference_Id__c)) continue;

        Student_Payment__c sp = paymentMap.get(evt.Reference_Id__c);
        String event = evt.Event_Name__c;
       
        if(event == 'emi.process.completed'){
            sp.Payment_Status__c = 'Payment Awaiting';
            if(String.isNotBlank(evt.Transaction_Id__c)) sp.Transaction_ID__c = evt.Transaction_Id__c;
            if(String.isNotBlank(evt.GQ_ID__c)) sp.Payment_Link_Id__c = evt.GQ_ID__c;
        }        
        else if(event == 'dt.payment.captured' || event == 'emi.disbursed') {
            sp.Payment_Status__c = 'Success';
            sp.Transaction_ID__c = evt.Transaction_Id__c;
            sp.Payment_Date_Time__c = System.now();
            sp.Payment_Mode_Type__c = evt.Payment_Method__c;
            sp.Payment_Link_Id__c = evt.GQ_ID__c;
            //sp.Payment_Gateway__c = 'GrayQuest';
            //sp.Mode_of_Payment__c = 'Online';
        }
        else if(event == 'dt.payment.failed' || event == 'emi.rejected' || event == 'emi.backout') {
            sp.Payment_Status__c = 'Failed';
            sp.Transaction_ID__c = evt.Transaction_Id__c;
            sp.Payment_Date_Time__c = System.now();
            sp.Payment_Mode_Type__c = evt.Payment_Method__c;
            sp.Payment_Link_Id__c = evt.GQ_ID__c;
        }

        paymentsToUpdate.add(sp);
    }

    if(!paymentsToUpdate.isEmpty()) {       
        update paymentsToUpdate;        
        
        List<Student_Fee_Payment__c> lineItems = [SELECT Id, Student_Payment__c FROM Student_Fee_Payment__c WHERE Student_Payment__c IN :paymentsToUpdate];
        Map<Id, Student_Payment__c> updatedPays = new Map<Id, Student_Payment__c>(paymentsToUpdate);
        
        for(Student_Fee_Payment__c li : lineItems) {
            Student_Payment__c parent = updatedPays.get(li.Student_Payment__c);
            li.Line_Item_Payment_Status__c = parent.Payment_Status__c;
            li.SF_Transaction_ID__c = parent.Transaction_ID__c;
            li.Transaction_Date_Time__c = parent.Payment_Date_Time__c;
            li.Payment_Mode_Type__c = parent.Payment_Mode_Type__c;
            //li.Line_Item_Payment_Gateway__c = 'GrayQuest';
        }
        update lineItems;
    }
}