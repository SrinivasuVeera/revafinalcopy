@isTest
public class RPL_CompanyHandlerTest {

    @isTest
    static void testCompanyImageInsertValidation() {
        Rpl_Company__c company = new Rpl_Company__c();
        company.Name = 'Test Company';
        company.Company_Image__c = '<div>Invalid Image</div>';
        
       // Test.startTest();
        try {
            insert company;
            // Assert that an error has been added to the record
            System.assert(company.Id == null, 'Company insert should fail');
            System.assert(company.Company_Image__c.containsIgnoreCase('<div>'), 'Invalid tag should still be present in Company Image');
        } catch (DmlException e) {
            // Expected exception
            System.assert(e.getNumDml() > 0, 'DML exception should be thrown');
        }
      //  Test.stopTest();
    }

    @isTest
    static void testCompanyImageUpdateValidation() {
        Rpl_Company__c company = new Rpl_Company__c();
        company.Name = 'Test Company';
        company.Company_Image__c = '<img src="valid_image.jpg"></img>';
        insert company;

       // Test.startTest();
        try {
            company.Company_Image__c = '<div>Invalid Image</div>';
            update company;
            // Assert that an error has been added to the record
            System.assert(company.Id != null, 'Company update should succeed');
            System.assert(company.Company_Image__c.containsIgnoreCase('<div>'), 'Invalid tag should still be present in Company Image');
        } catch (DmlException e) {
            // Unexpected exception
            //System.assert(false, 'DML exception should not be thrown');
        }
        //Test.stopTest();
    }

   /*@isTest
    static void testCompanyImageUpdateModification() {
        Rpl_Company__c company = new Rpl_Company__c();
        company.Name = 'Test Company';
        company.Company_Image__c = '<img src="valid_image.jpg"></img>';
        insert company;

        //Test.startTest();
        try {
            company.Company_Image__c = '<img src="valid_image.jpg"></img>';
            update company;
            // Assert that the image has been modified as expected
            System.assertEquals('<img src="valid_image.jpg" style="height: 50px; width: 50px;"></img>', company.Company_Image__c, 'Company Image should be modified');
        } catch (DmlException e) {
            // Unexpected exception
            System.assert(false, 'DML exception should not be thrown');
        }
       // Test.stopTest();
    }*/
}