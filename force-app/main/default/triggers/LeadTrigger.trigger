trigger LeadTrigger on Lead (before insert, before update,after insert,after Update) {

    switch on Trigger.OperationType{
      when BEFORE_INSERT{
          system.debug('Inside Before insert');
          //Combined method for Leads created by Publishers / Counselor / Data upload
          LeadTriggerHandler.insertPrimarySource(Trigger.new);
          LeadTriggerHandler.validateDailyLeadLimit(Trigger.new);
          LeadTriggerHandler.validateDuplicateLeads(null,Trigger.new);
          //LeadTriggerHandler.populateProgramBatch(Trigger.new);

         PublisherLeadValidationTriggerHandler.validatePublisherLeads(Trigger.new);
      }
      when BEFORE_UPDATE{
          system.debug('Inside Before Update');
          LeadTriggerHandler.updateCCAndMobilePhone(Trigger.oldMap, Trigger.new);
          LeadTriggerHandler.updateLeadSource(Trigger.oldMap, Trigger.new);
          LeadTriggerHandler.validateDuplicateLeads(Trigger.oldMap,Trigger.new);
          //LeadTriggerHandler.populateProgramBatch(Trigger.new);
      }
        when AFTER_INSERT {
            System.debug('Inside After Insert');

            LeadTriggerHandler.handleAfterInsertProgram(Trigger.new);
        }
        when AFTER_UPDATE{
          system.debug('Inside After Update');
          ReassignmentSendSMSANdWhatsapp.handleOwnerChangeLead(Trigger.new, Trigger.oldMap);
          LeadTriggerHandler.handleAfterUpdateProgram(Trigger.oldMap,Trigger.new);
          
          /*List<Id> leadIds = new List<Id>();
          
          for(Lead ld : Trigger.new){
              
              Lead oldLead = Trigger.oldMap.get(ld.Id);
              
              if(ld.LeadSource == 'Yellow.ai' && ld.School__c != null && ld.Program_Name_Display__c != null && (oldLead.School__c == null || oldLead.Program_Name_Display__c == null)){
                    leadIds.add(ld.Id);
                }
          }
          
          if(!leadIds.isEmpty()){
              YellowAILeadHandler.processLeadConversion(leadIds);
          }*/
      }
    }
}