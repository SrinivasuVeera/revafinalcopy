@isTest
public class STOB_GenerateSRN_Ctrl_Test 
{
    public static testmethod void Generate()
    {
        Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
        objAcc.Program_Code__c='IA';
        Insert objAcc;
        
        Contact objCon = STOB_TestDataFactory.createContact('Test');
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.Student_Status__c = 'Pursuing';
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;
        objcon.Nationality__c ='Indian';
        Insert objCon;
        
        hed__Program_Plan__c objProgramplan = STOB_TestDataFactory.createProgramPlan('Btech');
        objProgramplan.hed__Start_Date__c = system.today();
        objProgramplan.hed__Account__c = objAcc.Id;
        //objProgramplan.hed__Start_Date__c = System.today();
        objProgramplan.Total_Number_Of_Regular_Students__c =2;
       // objProgramplan.Number_of_University_Transferred_Student__c=2;
        Insert objProgramplan;
        
        hed__Program_Enrollment__c objProgramEnrollment = STOB_TestDataFactory.createprogramEnrollment(objProgramplan.Id);
        //objProgramEnrollment.hed__Program_Plan__c = objProgramplan.Id;
        objProgramEnrollment.Program_Enrollment_Status__c ='Confirmed';
        objProgramEnrollment.Type_Of_Enrollment__c ='Regular Entry';
        objProgramEnrollment.hed__Contact__c = objCon.Id;
        //objProgramEnrollment.University_Transferred_Student__c =true;
        Insert objProgramEnrollment;
        
        hed__Program_Plan__c objProgPlan = [Select Id, Name, SRN_Format__c, hed__Account__r.Program_Code__c, 
                                            Total_Number_Of_Lateral_Students__c, Total_Number_Of_Regular_Students__c,
                                            Number_of_University_Transferred_Student__c  
                                            from hed__Program_Plan__c where Id =: objProgramplan.Id];
        
        List<hed__Program_Enrollment__c> list_programEnrollments = new List<hed__Program_Enrollment__c>();
        list_programEnrollments.add(objProgramEnrollment);
        
        Test.startTest();
        STOB_GenerateSRN_Ctrl.getStudentType();
        STOB_GenerateSRN_Ctrl.getProgramPlanDetails(objProgPlan.Id);
        STOB_GenerateSRN_Ctrl.getProgEnrollNoGRN('Regular Entry',objProgPlan);
        STOB_GenerateSRN_Ctrl.getProgramEnrollment('Regular Entry',objProgPlan,list_programEnrollments);
        STOB_GenerateSRN_Ctrl.getProgramEnrollment('Lateral Entry',objProgPlan,list_programEnrollments);
        STOB_GenerateSRN_Ctrl.generatedSRN('Lateral Entry',objProgPlan);
        //STOB_GenerateSRN_Ctrl.updatePrgEnrollement(list_programEnrollments,objProgPlan,'Lateral Entry');
        //STOB_GenerateSRN_Ctrl.updatePrgEnrollement(list_programEnrollments,objProgPlan,'Regular Entry');
        STOB_GenerateSRN_Ctrl.updatePrgEnrollement(list_programEnrollments, objProgPlan, 'Lateral Entry',1 ,2); 
        Test.stopTest();   
        system.assertEquals(objProgPlan.Id,objProgramplan.Id);
    } 
    
    public static testmethod void GenerateSRNLateral()
    {
        Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
        objAcc.Program_Code__c='IA';
        Insert objAcc;
        
        Contact objCon = STOB_TestDataFactory.createContact('Test');
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objcon.Application_Number__c = '123';
        objCon.Student_Status__c = 'Pursuing';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;
        objcon.Nationality__c ='Indian';
        Insert objCon;
        
        hed__Program_Plan__c objProgramplan = STOB_TestDataFactory.createProgramPlan('Btech');
        objProgramplan.hed__Start_Date__c = system.today();
        objProgramplan.hed__Account__c = objAcc.Id;
        //objProgramplan.hed__Start_Date__c = System.today();
        objProgramplan.Total_Number_Of_Lateral_Students__c =2;
        objProgramplan.Number_of_University_Transferred_Student__c=2;
        Insert objProgramplan;
        
        hed__Program_Enrollment__c objProgramEnrollment = STOB_TestDataFactory.createprogramEnrollment(objProgramplan.Id);
        objProgramEnrollment.hed__Program_Plan__c = objProgramplan.Id;
        objProgramEnrollment.Program_Enrollment_Status__c ='Confirmed';
        objProgramEnrollment.Type_Of_Enrollment__c ='Lateral Entry';
        objProgramEnrollment.hed__Contact__c = objCon.Id;
        objProgramEnrollment.University_Transferred_Student__c = true;
        objProgramEnrollment.SRN_Number__c ='R21DE002';
        Insert objProgramEnrollment;
        
        hed__Program_Plan__c objProgPlan = [Select Id, Name, SRN_Format__c, hed__Account__r.Program_Code__c, 
                                            Total_Number_Of_Lateral_Students__c, Total_Number_Of_Regular_Students__c,
                                            Number_of_University_Transferred_Student__c from hed__Program_Plan__c where Id =: objProgramplan.Id];
        
        List<hed__Program_Enrollment__c> list_programEnrollments = new List<hed__Program_Enrollment__c>();
        list_programEnrollments.add(objProgramEnrollment);
        
        Test.startTest();
        STOB_GenerateSRN_Ctrl.getStudentType();
        STOB_GenerateSRN_Ctrl.getProgramPlanDetails(objProgPlan.Id);
        STOB_GenerateSRN_Ctrl.getProgEnrollNoGRN('Regular Entry',objProgPlan);
        STOB_GenerateSRN_Ctrl.getProgramEnrollment('Regular Entry',objProgPlan,list_programEnrollments);
        STOB_GenerateSRN_Ctrl.getProgramEnrollment('Lateral Entry',objProgPlan,list_programEnrollments);
        STOB_GenerateSRN_Ctrl.generatedSRN('Lateral Entry',objProgPlan);
        // STOB_GenerateSRN_Ctrl.updatePrgEnrollement(list_programEnrollments,objProgPlan,'Lateral Entry');
        // STOB_GenerateSRN_Ctrl.updatePrgEnrollement(Null,objProgPlan,'Regular Entry');
        STOB_GenerateSRN_Ctrl.updatePrgEnrollement(list_programEnrollments, objProgPlan, 'Lateral Entry',1 ,2); 
        STOB_GenerateSRN_Ctrl.updatePrgEnrollement(list_programEnrollments, objProgPlan, 'Regular Entry',1 ,2); 
        Test.stopTest();   
        system.assertEquals(objProgPlan.Id,objProgramplan.Id);
    }
        
}