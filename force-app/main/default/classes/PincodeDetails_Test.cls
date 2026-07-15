@isTest
public class PincodeDetails_Test {
    @TestSetup
    static void createTestData() {
        Pincode_Master__c recWithPincode = new Pincode_Master__c();
        recWithPincode.State__c =  'Tamil Nadu';
        recWithPincode.City__c =  'CBE';
        recWithPincode.Pincode__c = '641062';
        recWithPincode.District__c = 'Coimbatore';
        recWithPincode.Post_Office__c = 'Neelambur';
        recWithPincode.Circle__c = 'Test Circle';
        recWithPincode.Region__c = 'Test Regio';
        recWithPincode.Division__c = 'Test Division';
        recWithPincode.Office_Type__c = 'Type';
        recWithPincode.Delivery_Non_Delivery__c = 'Test Delivery';
        insert recWithPincode;
    }

    @isTest 
    static void testPincodeDetails() {
        List<Pincode_Master__c> getPicodeRecId = [SELECT Id FROM Pincode_Master__c Where Pincode__c = '641062' limit 1 ];
        PincodeDetails.getPincodeDetails('641062');
        PincodeDetails.selectedPincodeDetails(getPicodeRecId[0].Id);
        System.assertEquals(1, getPicodeRecId.size());
    }
}