public with sharing class PincodeDetails {

    @AuraEnabled(cacheable = true)
    public static List < Pincode_Master__c > getPincodeDetails(String pincode) {
        System.debug('Got accStrName: ' + pincode);
        List < Pincode_Master__c > pincodeAddresses = [SELECT Id, State__c, Post_Office__c, Pincode__c, District__c, City__c
            FROM Pincode_Master__c
            WHERE Pincode__c =: pincode
        ];
        return (pincodeAddresses);
    }
    @AuraEnabled(cacheable = true)
    public static Pincode_Master__c selectedPincodeDetails(string selectedPincodeId) {
        return [select Id, State__c, Post_Office__c, Pincode__c, City__c
                From Pincode_Master__c 
                WHERE Id =: selectedPincodeId 
                limit 1
                ];
    }
}