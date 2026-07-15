@isTest
public class ASM_StdSubjectAPISchTest {
    public static testmethod Void exe(){
        Test.startTest();
        String Sch = '0 0 * * * ?';
        system.schedule('ASM_StdSubjectAPISch',Sch, new ASM_StdSubjectAPISch());
        Test.stopTest(); 
    }  
}