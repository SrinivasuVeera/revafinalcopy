public without sharing class RTR_routePickupPointController {
    @AuraEnabled(cacheable=true)
    public static List<RTR_Route_Pick_Up_Point__c> getPickUpPoints(String selectedValue) {
        // Query and return the related pick-up points based on the selected route path
        return [SELECT Id, Name,Amount__c,rtr_If_Short_Distance__c,RTR_Payment_Amount__c,RTR_Faculty_Fee__c FROM RTR_Route_Pick_Up_Point__c WHERE RTR_Route_Master__c = :selectedValue];
    }
}