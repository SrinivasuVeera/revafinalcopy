@isTest
private class RTR_routePickupPointControllerTest {

    @isTest
    static void testGetPickUpPoints() {
        // Test data setup
        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(
           // Name = 'Test Route',
            RTR_Capacity__c=100
        );
        insert routeMaster;

        List<RTR_Route_Pick_Up_Point__c> pickupPoints = new List<RTR_Route_Pick_Up_Point__c>();
        for (Integer i = 0; i < 5; i++) {
            pickupPoints.add(new RTR_Route_Pick_Up_Point__c(
                Name = 'Pickup Point ' + i,
                Amount__c = 20.0 * i,
                RTR_If_Short_Distance__c = true,
                RTR_Payment_Amount__c = 15.0 * i,
                RTR_Faculty_Fee__c = 25.0 * i,
                RTR_Route_Master__c = routeMaster.Id
                // Add other necessary field values
            ));
        }
        insert pickupPoints;

        // Call the getPickUpPoints method
        List<RTR_Route_Pick_Up_Point__c> result = RTR_routePickupPointController.getPickUpPoints(routeMaster.Id);

        // Verify the results
        System.assertEquals(pickupPoints.size(), result.size(), 'Incorrect number of records returned.');

        // Additional assertions based on specific requirements
        for (Integer i = 0; i < result.size(); i++) {
            RTR_Route_Pick_Up_Point__c pickupPoint = result[i];
            System.assertEquals('Pickup Point ' + i, pickupPoint.Name, 'Incorrect Pickup Point Name');
            //System.assertEquals(20.0 * i, pickupPoint.Amount__c, 0.01, 'Incorrect Amount');
            System.assertEquals(true, pickupPoint.RTR_If_Short_Distance__c, 'Incorrect Short Distance Flag');
            //System.assertEquals(15.0 * i, pickupPoint.RTR_Payment_Amount__c, 0.01, 'Incorrect Payment Amount');
            //System.assertEquals(25.0 * i, pickupPoint.RTR_Faculty_Fee__c, 0.01, 'Incorrect Faculty Fee');
            //System.assertEquals(routeMaster.Id, pickupPoint.RTR_Route_Master__c, 'Incorrect Route Master');
        }
    }
}