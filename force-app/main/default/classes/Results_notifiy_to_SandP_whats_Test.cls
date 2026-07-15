@isTest
public class Results_notifiy_to_SandP_whats_Test {
  
    @testSetup
    static void setup() {
        try{
        Account acc = new Account(Name='TestAcc');
        insert acc;
         system.debug('acc'+acc);

        
           Contact father = new Contact(
        LastName = 'Father',
        MobilePhone = '7731030243',
        Email = 'revatransport@yopmail.com'
        
        );
        
        insert father;
                        system.debug('father'+father);

        
         Contact Mother = new Contact(
        LastName = 'Mother',
        MobilePhone = '7731030286',
        Email='shubhampanat@yopmail.com'
        
        );
        
        insert Mother;
                        system.debug('Mother'+Mother);

        
         Contact Guardian = new Contact(
        LastName = 'Guardian',
        MobilePhone = '7731030290',
        Email = 'salesforcetechbuddy513@gmail.com'
        
        );
            insert Guardian;
                        system.debug('Guardian'+Guardian);

        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
                    system.debug('ProgramBatch'+ProgramBatch);

            
           // Create Semester (hed__Term__c)
        hed__Term__c semester = new hed__Term__c();
        semester.Name = '3rd Semester';
        semester.Program_Batch__c =ProgramBatch.id;
        semester.hed__Account__c = acc.Id;
        semester.hed__Start_Date__c = Date.today().addDays(-30);
        semester.hed__End_Date__c = Date.today().addDays(30);        
        insert semester;
                    system.debug('semester'+semester);

        
        // Create test data
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            MobilePhone = '7731030243',
            Email = 'kruthika@yopmail.com',
            SRN_Number__c = 'SA001',
            Active_Semester__c = semester.Id,
            Active__c = true,
            Father__c = father.Id,
            Mother__c = Mother.Id,
            Guardian__c = Guardian.Id,
            Mentor__c = Guardian.Id
           // Father_Name__c = father.name,
           // Father_Mobile_Number__c = father.MobilePhone
        );
        insert testContact;
                    system.debug('testContact'+testContact);

        hed__Course__c objCourse = new hed__Course__c();
        objCourse.Name = 'Course';
        objCourse.hed__Account__c = acc.id;
       // objCourse.Category__c = cat;
       // objCourse.hed__Course_ID__c = 'CRS00'+i;
        insert objcourse;
                    system.debug('objCourse'+objCourse);

            hed__Course_Offering__c CourseOffering = new hed__Course_Offering__c(
            hed__Course__c = objcourse.Id,
            hed__Term__c = semester.Id,
            Name = 'test course offering'
            
            );
            
            insert CourseOffering;
                        system.debug('CourseOffering'+CourseOffering);

            hed__Course_Enrollment__c CourseEnrollment = new hed__Course_Enrollment__c(
            hed__Contact__c = testcontact.Id,
            hed__Course_Offering__c = CourseOffering.Id
      
            );
        
            insert CourseEnrollment;  
                        system.debug('CourseEnrollment'+CourseEnrollment);


              hed__Term_Grade__c resSmry = new hed__Term_Grade__c(
        hed__Term__c = semester.id,
        hed__Contact__c =testcontact.Id, 
        Secured_External_Marks__c = 10,
        Secured_Internal_Marks__c = 10,
        hed__Course_Connection__c = CourseEnrollment.id
);
        insert resSmry;
            
            system.debug('resSmry'+resSmry);
     
     
        // Call the method to test
        Test.startTest();
        Results_notifiy_to_SandP_whats.trsWhatsappNotification(new List<String> { resSmry.Id });
        Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('Line=> '+e.getLineNumber()+' Message=> '+e.getMessage());
        }
    }
        
    @isTest
    static void testBatch() {
     
        hed__Term_Grade__c termgrade = [Select Id,name,hed__Contact__c,hed__Contact__r.Name,hed__Contact__r.MobilePhone,hed__Contact__r.Father_Name__c,
            hed__Contact__r.Father_Email_ID__c, hed__Contact__r.Mother_Email_ID__c, hed__Contact__r.Guardian__r.Email,  
            hed__Term__r.Name,hed__Contact__r.Father_Mobile_Number__c,hed__Contact__r.Mother_Mobile_Number__c,hed__Contact__r.Mother_Name__c
            ,hed__Contact__r.Guardian__r.name,hed__Contact__r.Guardian__r.MobilePhone
            from hed__Term_Grade__c where hed__Course_Offering__c = null AND hed__Term__r.name = '3rd Semester'  ];
        
        
        
          // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Execute the batch
        Results_notifiy_to_SandP_whats_batch batch = new Results_notifiy_to_SandP_whats_batch(termgrade.Id);
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        
    }
        
             public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    }