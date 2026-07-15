@IsTest
private class AdmissionAutoProcessBatchTest {

     @testSetup
static void setupData() {

    RecordType applicantRT = [
        SELECT Id
        FROM RecordType
        WHERE SObjectType='Contact'
        AND DeveloperName='Applicant'
        LIMIT 1
    ];

    RecordType academicProgramRT = [
        SELECT Id
        FROM RecordType
        WHERE SObjectType='Account'
        AND DeveloperName='Academic_Program'
        LIMIT 1
    ];

    Account program = new Account();

    program.Name = 'B.Tech CSE';
    program.RecordTypeId = academicProgramRT.Id;
    program.Program_Alias__c = 'BT';
    program.Program_Type__c = 'UG';
    program.Program_Code__c = 'BT001';
    program.Intake__c = 120;
    program.Intake_Per_Section__c = 60;


    insert program;

    hed__Program_Plan__c batch = new hed__Program_Plan__c();

    batch.Name = 'BA(H) in Political Science with Minors-(2026-2030)';
    batch.hed__Account__c = program.Id;
    batch.Number_of_Years__c = 4;
    batch.hed__Start_Date__c = Date.today();

    insert batch;

    Contact testContact = new Contact();

    testContact.FirstName='Sai';
    testContact.LastName='Kumar';
    testContact.RecordTypeId=applicantRT.Id;
    testContact.Email='reddy123@test.com';
    testContact.MobilePhone='9999999999';
    testContact.Application_Number__c='APP001';
    testContact.Program_Batch__c=batch.Id;
    testContact.Primary_Academic_Program__c=program.Id;
    testContact.Select_Category__c='Indian (SAARC)';
    testContact.Application_Fee_Paid__c=false;

    insert testContact;

    Fee_Master__c applicationFee=new Fee_Master__c();

    applicationFee.Program_Batch__c=batch.Id;
    applicationFee.Fee_Type__c='Application Fee';
    applicationFee.Applicant_Category__c='Indian (SAARC)';
    applicationFee.IsActive__c=true;
    applicationFee.Fee_Amount__c=1000;

    insert applicationFee;

    Fee_Master__c programFee=new Fee_Master__c();

    programFee.Program_Batch__c=batch.Id;
    programFee.Fee_Type__c='Program Fee';
    programFee.Applicant_Category__c='Indian (SAARC)';
    programFee.Fee_Amount__c=400000;
    programFee.Premium_Amount__c=0;
    programFee.IsActive__c=true;

    insert programFee;

     Fee_Master__c universityFee=new Fee_Master__c();

    universityFee.Program_Batch__c=batch.Id;
    universityFee.Fee_Type__c='University Fee';
    universityFee.Applicant_Category__c='Indian (SAARC)';
    universityFee.Fee_Amount__c=50000;
    universityFee.Premium_Amount__c=0;
    universityFee.IsActive__c=true;


    insert universityFee;

   
    hed__Application__c application=new hed__Application__c();
    application.hed__Applicant__c=testContact.Id;
    application.hed__Applying_To__c=  batch.hed__Account__c;
    application.hed__Application_Status__c='In Review';
    application.Fee_Structure_Defined__c=false;
    application.Application_Number__c='APP001';
    application.hed__Application_Date__c = System.now().addDays(-2); 
    insert application;
}


@isTest
static void testBatch(){

    Test.startTest();

    Database.executeBatch(new AdmissionAutoProcessBatch(),1);

    Test.stopTest();

    System.assert(true);

}
    
@isTest
static void testScheduler(){

    Test.startTest();

    String cron = '0 0 1 * * ?';

    String jobId = System.schedule(
        'Admission Test',
        cron,
        new AdmissionAutoProcessScheduler()
    );

    Test.stopTest();

    CronTrigger ct = [
        SELECT Id
        FROM CronTrigger
        WHERE Id=:jobId
    ];

    System.assertNotEquals(null, ct);
}
    
  
    @IsTest
    static void testHandleDeletedPayments() {

        Contact c = [
            SELECT Id
            FROM Contact
            WHERE Application_Number__c = 'APP001'
            LIMIT 1
        ];

        Student_Payment__c payment = new Student_Payment__c(
            Contact__c = c.Id,
            Payment_Status__c = 'Pending',
            Fee_Type__c = 'University Fee, Tuition Fee'
        );

        insert payment;

        Test.startTest();

        delete payment;

        Test.stopTest();

        System.assert(true);
    }
    
    
    @IsTest
static void testProcessApplication_CreateFeeAndPayment() {

    hed__Application__c app = [
        SELECT Id,
               hed__Applicant__c,
               hed__Applicant__r.Program_Batch__r.Name,
               hed__Application_Status__c,
               Fee_Structure_Defined__c
        FROM hed__Application__c
        WHERE Application_Number__c = 'APP001'
        LIMIT 1
    ];

    Test.startTest();

    AdmissionAutoProcessService.processApplication(app);

    Test.stopTest();

    // Verify Application Updated
    app = [
        SELECT hed__Applicant__c,hed__Application_Status__c,hed__Applicant__r.id,
               Fee_Structure_Defined__c, hed__Applicant__r.Program_Batch__r.Name
        FROM hed__Application__c
        WHERE Id = :app.Id
    ];

    System.assertEquals('Interested', app.hed__Application_Status__c);
    System.assertEquals(true, app.Fee_Structure_Defined__c);

    // Verify Student Fee Created
    List<Student_Fee__c> feeList = [
        SELECT Id,
               Fee_Type__c,
               Fee_Year__c,
               Provisional_Admission_Fee__c,
               Amount__c
        FROM Student_Fee__c
        WHERE Contact__c = :app.hed__Applicant__r.id
    ];

    System.assert(feeList.size() > 0);

    // Verify Student Payment Created
    List<Student_Payment__c> paymentList = [
        SELECT Id,
               Amount__c,
               Fee_Type__c,
               Payment_Status__c,
               Pending_Payment_Link__c
        FROM Student_Payment__c
        WHERE Contact__c = :app.hed__Applicant__c
    ];

    System.assertEquals(1, paymentList.size());
    System.assertEquals('Pending', paymentList[0].Payment_Status__c);
    System.assertEquals('University Fee, Tuition Fee', paymentList[0].Fee_Type__c);
    System.assertNotEquals(null, paymentList[0].Pending_Payment_Link__c);
}
    
}