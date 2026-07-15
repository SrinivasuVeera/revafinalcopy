@isTest
public class ASM_IAMarksFomSfAPISchTest {
	public static testmethod Void exe(){
        Test.startTest();
        String Sch = '0 0 * * * ?';
        system.schedule('ASM_IAMarksFomSfAPISch',Sch, new ASM_IAMarksFomSfAPISch());
        Test.stopTest(); 
    }  
}