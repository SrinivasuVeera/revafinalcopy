@isTest
public class CoveringSheetControllerTest {

    @isTest
    static void testCoveringSheetController() {

        Contact con = new Contact(
            LastName = 'Test Student',
            Email = 'test@test.com',
            MobilePhone = '9876543210',
            Admission_Mode__c = 'UQ',
            State__c = 'Karnataka',
            Application_Number__c = '25110200293'
        );
        insert con;

        hed__Education_History__c edu = new hed__Education_History__c(
            hed__Contact__c = con.Id,
            Board__c = 'CBSE',
            Percentage__c = '85',
            Type_of_Course__c = 'UG'
        );
        insert edu;

        Student_Fee__c tuitionFee = new Student_Fee__c(
            Contact__c = con.Id,
            Fee_Type__c = 'Tuition Fee',
            Fee_Year__c = '1st Year',
            Actual_Program_Fee__c = 100000,
            Scholarship__c = 5000,
            Concession__c = 1000,
            Provisional_Admission_Fee__c = 25000
        );
        insert tuitionFee;

        Student_Fee__c universityFee = new Student_Fee__c(
            Contact__c = con.Id,
            Fee_Type__c = 'University Fee',
            Fee_Year__c = '1st Year',
            Actual_Program_Fee__c = 10000,
            Scholarship__c = 1000,
            Provisional_Admission_Fee__c = 50000
        );
        insert universityFee;

        PageReference pageRef =
            new PageReference('/apex/CoveringSheetController');

        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put(
            'id',
            con.Id
        );

        Test.startTest();

        CoveringSheetController ctrl =
            new CoveringSheetController();

        String dt = ctrl.getFormattedDate();

        Test.stopTest();

        System.assertNotEquals(
            null,
            ctrl.con
        );

        System.assertNotEquals(
            null,
            ctrl.education
        );

        System.assertNotEquals(
            null,
            ctrl.fees
        );

        System.assert(
            ctrl.feeStructure >= 0
        );

        System.assert(
            ctrl.pafAmount >= 0
        );

        System.assertNotEquals(
            null,
            dt
        );
        
        System.assertNotEquals(null, ctrl.con);
        System.assertNotEquals(null, ctrl.education);
        System.assertNotEquals(null, ctrl.fees);

        System.assertEquals('85%',
    ctrl.getDisplayPercentage()
      );
    }

    @isTest
    static void testNoIdParameter() {

        PageReference pageRef =
            new PageReference('/apex/CoveringSheetController');

        Test.setCurrentPage(pageRef);

        Test.startTest();

        CoveringSheetController ctrl =
            new CoveringSheetController();

        Test.stopTest();

        System.assertNotEquals(
            null,
            ctrl
        );
        
    }
    @isTest
static void testDisplayPercentageAndState() {

    Contact con = new Contact(
        LastName = 'Test',
        State__c = 'Karnataka'
    );
    insert con;

    hed__Education_History__c edu = new hed__Education_History__c(
        hed__Contact__c = con.Id,
        Percentage__c = '0',
        hed__Status__c = 'Results Awaited',
        Type_of_Course__c = 'Diploma'
    );
    insert edu;

    Test.setCurrentPage(
        new PageReference('/apex/CoveringSheetController')
    );

    ApexPages.currentPage().getParameters().put(
        'id',
        con.Id
    );

    Test.startTest();

    CoveringSheetController ctrl =
        new CoveringSheetController();

    Test.stopTest();

    System.assertEquals(
        'Results Awaited',
        ctrl.getDisplayPercentage()
    );

    System.assertEquals(
        'Karnataka',
        ctrl.getDisplayState()
    );
}
    @isTest
static void testDiplomaSelectionAndStatus(){

    Contact con = new Contact(
        LastName='Diploma Test'
    );
    insert con;

    insert new hed__Education_History__c(
        hed__Contact__c = con.Id,
        Type_of_Course__c = '10th',
        Percentage__c = '90',
        Board__c = 'State Board'
    );

    insert new hed__Education_History__c(
        hed__Contact__c = con.Id,
        Type_of_Course__c = 'Diploma',
        Percentage__c = '0',
        hed__Status__c = 'Results Awaited'
    );

    Test.setCurrentPage(
        new PageReference('/apex/CoveringSheetController')
    );

    ApexPages.currentPage().getParameters().put('id',con.Id);

    CoveringSheetController ctrl =
        new CoveringSheetController();

    System.assertEquals(
        'Results Awaited',
        ctrl.getDisplayPercentage()
    );
}
    
    @isTest
static void testFeeWaiverNA(){

    Contact con = new Contact(
        LastName='Fee Waiver'
    );
    insert con;

    insert new Student_Fee__c(
        Contact__c = con.Id,
        Fee_Type__c='Tuition Fee',
        Fee_Year__c='1st Year',
        Actual_Program_Fee__c=1000
    );

    Test.setCurrentPage(
        new PageReference('/apex/CoveringSheetController')
    );

    ApexPages.currentPage().getParameters().put('id',con.Id);

    CoveringSheetController ctrl =
        new CoveringSheetController();

    System.assertEquals(
        'N/A',
        ctrl.feeWaiverDisplay
    );
}
    @isTest
static void testDisplayStateBlank(){

    Contact con = new Contact(
        LastName='State Test'
    );
    insert con;

    Test.setCurrentPage(
        new PageReference('/apex/CoveringSheetController')
    );

    ApexPages.currentPage().getParameters().put('id',con.Id);

    CoveringSheetController ctrl =
        new CoveringSheetController();

    System.assertEquals(
        '',
        ctrl.getDisplayState()
    );
}
    
    @isTest
static void testDisplayBoardOther() {

    Contact con = new Contact(
        LastName = 'Board Test'
    );
    insert con;

    hed__Education_History__c edu = new hed__Education_History__c(
        hed__Contact__c = con.Id,
        Type_of_Course__c = 'UG',
        Board__c = 'Other',
        Board_Others__c = 'Andhra Pradesh Board Of Secondary Education',
        Percentage__c = '80'
    );
    insert edu;

    Test.setCurrentPage(
        new PageReference('/apex/CoveringSheetController')
    );

    ApexPages.currentPage().getParameters().put(
        'id',
        con.Id
    );

    Test.startTest();

    CoveringSheetController ctrl =
        new CoveringSheetController();

    String boardName = ctrl.getDisplayBoard();

    Test.stopTest();

    System.assertEquals(
        'Andhra Pradesh Board Of Secondary Education',
        boardName
    );
}
    @isTest
static void testDisplayBoardNormal() {

    Contact con = new Contact(
        LastName = 'CBSE Test'
    );
    insert con;

    hed__Education_History__c edu = new hed__Education_History__c(
        hed__Contact__c = con.Id,
        Type_of_Course__c = 'UG',
        Board__c = 'CBSE',
        Percentage__c = '85'
    );
    insert edu;

    Test.setCurrentPage(
        new PageReference('/apex/CoveringSheetController')
    );

    ApexPages.currentPage().getParameters().put(
        'id',
        con.Id
    );

    Test.startTest();

    CoveringSheetController ctrl =
        new CoveringSheetController();

    Test.stopTest();

    System.assertEquals(
        'CBSE',
        ctrl.getDisplayBoard()
    );
}
}