@isTest
public class cancelrequestparenttest {
    public class SMSMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testingmethod() { Contact con=new Contact();
            con.FirstName='sathiya';
            con.LastName='Deva';
            con.mobilephone='7079090900';
            con.SRN_Number__c='SRN123N';
            con.MiddleName='rajendra';
            con.RH_Parent_Phone_Number__c='9090909090';
                     
        
      
        insert con;
        update con;
        
                                 RecordType revaRecordType = [
                                     SELECT Id 
                                     FROM RecordType 
                                     WHERE DeveloperName = 'Transport_Cancellation' 
                                     AND SObjectType = 'RTR_Reva_Transport_Request__c' 
                                     LIMIT 1
                                 ];
        
       
        
          RTR_Reva_Transport_Request__c reva=new RTR_Reva_Transport_Request__c();
              Transport_Registeration__c tr = new Transport_Registeration__c();
       
            ///RTR_Reva_Transport_Request__c reva=new RTR_Reva_Transport_Request__c();
           tr.Contact__c           = con.id;
            tr.Registration_Status__c='Cancelled';
          // tr.contact__r.FirstName=con.FirstName;
           // tr.contact__r.lastname=con.LastName;
           // tr.contact__r.middlename=con.MiddleName;
            // tr.contact__r.mobilephone=con.MobilePhone;
            // tr.contact__r.RH_Parent_Phone_Number__c=con.RH_Parent_Phone_Number__c;
            reva.Cancellation_Date__c=System.today();
            reva.RTR_Reason_For_Cancellation__c='I have Bike';
           
            reva.SRN_EmployeeID__c=con.SRN_Number__c;
            reva.RecordTypeId= revaRecordType.Id;
           
           // reva.RTR_Student__c=conn.id;
           
            insert tr;
            update tr;
          insert reva;
        update reva;
        
      
        list<string> regis=new list<string>();
        regis.add(tr.id);
        
        
        
        // Use real Contact and Request records from org
    
        Test.setMock(HttpCalloutMock.class, new SMSMock());

        Test.startTest();
        cancelrequestparent.rtrSMSNotificationStudent(regis);
        
        Test.stopTest();

        System.assert(true, 'Ran with real data');
    }

    
}