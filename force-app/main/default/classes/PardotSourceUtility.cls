public with sharing class PardotSourceUtility {

    public static void setSourcesOnLead(Lead newLead, Lead oldLead){

        if (oldLead.Primary_Source__c == null) {
            newLead.Primary_Source__c = newLead.utm_source__c;
        }   
        else if (oldLead.Secondary_Source__c == null) {
            newLead.Secondary_Source__c = newLead.utm_source__c;
        }
        else if (oldLead.Tertiary_Source__c == null) {
            newLead.Tertiary_Source__c = newLead.utm_source__c;
        }
       
    }
    public static void setSourcesOnContact(Contact newContact, Contact oldContact){
       
        if (oldContact.Primary_Source__c == null) {
            newContact.Primary_Source__c = newContact.utm_source__c;
        }  
        else if (oldContact.Secondary_Source__c == null) {
            newContact.Secondary_Source__c = newContact.utm_source__c;
        }
        else if (oldContact.Tertiary_Source__c == null) {
            newContact.Tertiary_Source__c = newContact.utm_source__c;
        }
    }

}