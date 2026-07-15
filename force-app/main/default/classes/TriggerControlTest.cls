@IsTest
public class TriggerControlTest {

    @IsTest
    static void testTriggerControlFlags() {
        // Start test
        Test.startTest();

        // Assert the default values of the static variables
        System.assertEquals(true, TriggerControl.isFirstRun, 'isFirstRun should be true by default.');
        System.assertEquals(true, TriggerControl.isHCMQueueableRun, 'isHCMQueueableRun should be true by default.');
        System.assertEquals(false, TriggerControl.isHCMTrggerDisable, 'isHCMTrggerDisable should be false by default.');

        // Modify the static variables to test if they behave as expected
        TriggerControl.isFirstRun = false;
        TriggerControl.isHCMQueueableRun = false;
        TriggerControl.isHCMTrggerDisable = true;

        // Assert the modified values
        System.assertEquals(false, TriggerControl.isFirstRun, 'isFirstRun should now be false.');
        System.assertEquals(false, TriggerControl.isHCMQueueableRun, 'isHCMQueueableRun should now be false.');
        System.assertEquals(true, TriggerControl.isHCMTrggerDisable, 'isHCMTrggerDisable should now be true.');

        Test.stopTest();
    }
}