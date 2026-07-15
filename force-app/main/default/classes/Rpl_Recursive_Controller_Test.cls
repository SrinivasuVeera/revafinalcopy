@isTest
public class Rpl_Recursive_Controller_Test {
	@isTest
    public static void test(){
        Test.startTest();
        Rpl_Recursive_Controller.isAlreadyExecuted = true;
        Test.stopTest();
        System.assertEquals(Rpl_Recursive_Controller.isAlreadyExecuted, true);
    }
}