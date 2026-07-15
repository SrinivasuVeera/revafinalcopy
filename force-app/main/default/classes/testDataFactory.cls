@isTest
public class testDataFactory {
    
    public static hed__Term__c createSemester(){
        hed__Term__c semester = new hed__Term__c(Name='Rve_Semester__c1');
        
        return semester;
    }
    
    public static Account createAccount(){
      
        Id UniversityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
       
        Account ObjAcc= new Account(name='TestAccount',
                                    recordTypeId=UniversityRecordTypeId,
                                    Program_Alias__c='Kmnb123',
                                    Program_Type__c='UG',
                                    Program_Code__c='0123',
                                    Intake__c=12,
                                    Intake_Per_Section__c=40
                                   ); 
        insert ObjAcc;
        return ObjAcc;
    }
    
    public static Contact createContact(){
         Id StudentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
          hed__Term__c sem =createSemester();
        Contact cons = new Contact(FirstName= 'test name',
                                  LastName='Name',
                                  Active_Semester__c = sem.Id,
                                  Application_Number__c = '1223467',
                                  Select_Category__c ='	Karnataka',
                                  //Father_Name__c= 'rahul',
                                  MobilePhone = '9878675432',
                                  recordTypeId=StudentRecordTypeId,
                                  Mother_Name__c='sobha',
                                  Email='TestContact01@gmail.co'
                                  // File_Passport_Size_Photo__c='data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBwgHBgkIBwgKCgkLDRYPDQwMDRsUFRAWIB0iIiAdHx8kKDQsJCYxJx8fLT0tMTU3Ojo6Iys/RD84QzQ5OjcBCgoKDQwNGg8PGjclHyU3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3N//AABEIAKwAtwMBIgACEQEDEQH/xAAcAAEAAgIDAQAAAAAAAAAAAAAABQYEBwECAwj/xABBEAABAwMABQcKBQMDBQEAAAACAAEDBAUSBhETIjIhMUFCUWFxBxRSYnKBkaGxwRUjJEPwM1PRJTSyY4KiwuEW/8QAGQEBAAMBAQAAAAAAAAAAAAAAAAEDBAIF/8QAIREBAQACAgICAwEAAAAAAAAAAAECEQMhEjEiQQQTUZH/2gAMAwEAAhEDEQA/AN4oiICIiAiIgIiICIuHQcrhRlff7TQf7yvp4+4jbX8FEvp/oznj+JCXsiTt9FG4nVWpcKMtt/td1/2FbFN7JcvwUmpQ5REQEREBERAREQEREBERAREQEREBEWt/KF5RIbLlb7SQyV3MZtytF3N2uot0mTa0aS6VW3R6H9XJlOTflwAW8/j2N3utQaR6e3a8mY+clSU3VigfVyd787/JUmuuVVWzFPVSFJKXKREWtYu0z6yrttWySJQtnLx5EXpEWtdwpx6ijYiUlB+UGRkpkidpC2TSUVSMlPPjKPralvXQy9ld7UJVGO3HkLv71851FXmf/t0q76C6aR2DKOoj2gyetytqSdVGU3G+EUNYtIrbfAyoph2mrejLkJvcphWKXKIiAiIgIiICIiAiIgIiICIsS41cdBQz1cnDEDkgonlT0y/BqP8AC6CTGsmH8yQeeIX+7rQ8xkZkRcRb29z+Lqb0jrJK+5T1dQWUshuXf4dyhhiKomxiHIiL3Km3a7GMd13COSXgFXKyaJxmAyVW96vQrbSWChi4KYVXeWRfjw291rajtxAGUoll6KyGt9ZL/SpixW0AtNP/AGxUhBRQxBiAp+3+J/TJ9tO/glVn+ojIV3r7SVPCMgdVbbqqKMwxIVWr3a4/NpcB9ZR+3t3+qa6VWwXSagmGppSxljJnH/C39ozfKe/WuOsg4uaQOkC6WXzeOVLU4mKvPk00g8wvYwSl+mqtw/a6H8dfydX41kzxbvRcLlWKRERAREQEREBERAREQFVfKKcw6MTjAJE5OLEXQza+V3VqWFdYY57bUxS44FEWvX4KKmPl+5sQHuelxdLqf0dtAiG3l4i+SiazH8V2Yb298GVyt4bg+ysvLdTUa+Kbu0pRRqZpxElG0YqUhHBUyNVr3xwXvGy6OC7Au5FddpBUbW04yhwqTJY0oqLEy6a10otWyMZA4cuL6P8AZV+hqfN6yIsuEvmz6/utnX+lGoo5YjHqutQzAUVSUXWy+n/xXcd3NKeWd7fVFmqhrbXSVIlltIhf5LOWv/I/cCqLDJSSkRFTnya+Zmfs7lsBaIx0REUoEREBERAREQEREBQemFY1Fo5WSZY5BgPv5PprU4qB5W6nZWSKPLiPh7eTnUX06xm60ftilupF6R/LmV1E6wwGC2iO1x3pC5g7vFUe2PndcfRV6GujtVHtC3ceUu1Zc/emvj9brocmk1BvHBT1A+qTs7LLtWm1PLNsK+CSnl9YeRQk2mVYEIyeaSebSFhHzaz1PqfUz8/ivf8AJrwGcqaSMiMmxniZn1s+p2Z25Hdn5114XXcdeU31WyYaqOUBIC4kOoGLeNVay1e+NMY4kPV7lOVofk8PEK4WaV+v0xqqqYqa0UhSbziRlzfJZNDbL1WhtK26bH/pQAz/ABd1FV01RTmVNbabKXFzLEWZmZuV3d+hQlp0kvlVMMFKMckm+5BtSyZm187O2rlZtbKyY2zqKsrMb3V4OCqpfyKiTziIt0ZcdRB3O3S3etb6UUBUF49WTlEvervo9pEV3AhqBxljLEslF6ewYVNvkEct527vB1zj1lo5O8drd5Ho5j87nxIYNkIFl0nr1/TX8Vs1VLyZ05U+jEec0chSSFLiHNGz6tQ8zczN81bVpjFfblERSgREQEREBERAREQFqTyzVf5sUH9uJy97uttLRXlnqMrrKOXYPwZcZrOP2ouiobW6kX851fp7KNfD6voqgaIlheNn6Qv8lt2yYrNyX5NXFPirFTo1NVUw01QWUUf9PIdTtr5+VuhWeltgjZ4raAiMEe8OIcrE/Tr59asA04mvKrxGEurirJndJ8JtWggELwOHVFhJWabgFVmkmjlqcg9L4qwEZGCp2tuLAuFtkzKelyEi6wly6uxR1HozCB5HAWRa8t7Vr18/NqdWaCaMw4llwxZq2ZXXSuz+xCQ2SjpwyCCMS9UeX4qJ0qofPaODDiGVsfeyuNSIgGKhpwzx9UmdcW6prcSXk+iKnaqgKQixx4ujk6Fc1C6N0Y08Jz9aZ/kymlo45rFk5rLndOURFYqEREBERAREQEREHHQvnnyrGRX6p9p/qvoboXz15SmzvdYXruq8/pbx/an6MFhe6YvWcfizrbdsmEFpi2zjS3KIpSxHNi+a2jDKQGPrKjOdtXDetL1TVG5xKKv88ktBKNLvFjuiseSaaKmHPIRx1kQqNC+W/PHzkd3q9KjtZ1KjYbuVLWRDLTSRjiw5EPIrTHcpKqH9LBtMf5zqPG8W2Xjj2g+sKkKW50dOGUWIiXVFTMXdmV+nvHDJUBtCiKEseHpXrQXPA9hKWMo9UudYsuktGG9KJD/2rBluFHegyp4JMR/fxxdu9u1NWObv7iw1NWJqPlqRihnnPhjBzL3MseCGbzaLalvY73eq/plcZKeGK3xFj5wJPJ24tqZm97/RcyeVc52Y4tqaE1RVujFvnMsiIHyfvZ3Z1OqheR+4+d6PSUxcVPL/AOJNrb5s6vq2T087L25REUoEREBERAREQEREHC+fNNm2tyrvbJb+nPGGQvRF/otAaQFtZqwvH7qnkvpdxT21vXDvrZOjlxG5WeIv3RFsvabn+P3WvqwNwl3sN1ktFZl+xJ/UH6O3eyZY+Ud4ZeOTfVvmjrbbj1hFUu42qn85KeKARl5RLHk19697JeBDGSKTKIvR7HUhWx51O0i4S3lTLpqxrytM1twGOoot7LLLuU3FPaYgLzekyLLLhUVHTCfGO96qy6amLPrKzHKfa2zjvff+sOaOa5VJCEQxwZdUejsU3FTx08IxiO6KyIIMd3Fedc4hurjLLbnPkmXUmpHBzDvdXd+C1Tfbp5/pDLOJZQCDBD7La+X3vrdTOm1+kACttLkOUWUh9OL9DePL8FTtRBsJPEfu3zdd8eOmTky22N5Frjsr7LSEW7NE/wAW5WW718x6C15UGk9vm9GZhLwd9S+m9auxZ8525REXTgREQEREBERAREQRt8l2Vtlx6zalo28sPn88cRZZRPvd63PpVJ+geMeKTUA+Lvqb7rT2mUg0+kMUeIjs4sCER8Fn5O8mni6xUCoDfIVHzxYQ5dXJTVZGIVMvrF/PqsI6cqoJYw6usyLn1C3K/wBWXePbnJk6PVclKGI70eT7v+FfbNdhIBEyVGtNPmG4pUIZIuHdVOc7X4XpsunmjPeBSdPNCtZ0lfXRcA5Keoqi4VHVxURbtb6muhiBRTbSqMiPdiXFHbiPelLL2lLFFgGIJXDUWmwF+PTiA/tCI9nMok9+2j6o5fPU6smlkJf/AKqITIRimEW3ubWzO3L3KLqqGSlmKCUcedvc/M/zf5LRJ8dqL7YVtcgqYi9GUX+f8+K+pqE9pRwH6QD9F8s0Q4BifFGbCXg38ZfS+i1R5xYaGTthH5cn2TH2rznSYREVioREQEREBERAXDuuViV1R5vTEfW5hbtdRaIO+ZV5lgWMVOYkRdvLq1N9VprTaojqNJ64oi3YzwH+fBbO0suJWiyFGJCNTUC5yD08vNq71pS4z4bp8Ra3kLpd37Vnyu6049Ri3Q/zslMaEUA1oXWTqjSuw+Ls7/ZV2VyqD3PR4lsfyVUn+lVMv9wzbxZuT/K1cGPy7VcuXSv2Oh2VNF7DZfVWMLcJhwr1goNkGPo7qlaAOqs2Xtqx9I+gtY574qw0lIIBwrvBEPorLjYfRXOi1zFGuZl6Cy8pGTSFM0utscs1DVl+zVgxd4E7C/1Z/cl7sRRAIy70X7cvZ2M/d9PpK6Vx/wClEPpSxt78mViaKOqoNmY5bvWWz8fHyxsrNz5eNlaZnopKKv8AzR4uTLodlufyZXGOosI02RZwk46i7OxnVQvuj5FTEMQ7QeIR6WduxYWgWkUdlr5aatL9JMW8XTGTPyPq7lxlhcMk+UyxbwRY1LOMoCQEMgkOsTHmdlkqVQiIgIiICLhdSfF21IOSLFQN/u1vtUJVNynES/bDnf4KL8omkFdY6Rnt5AJE3EQ63bwWk7hU1FwnkkrJ5JScus65stdYprTTTKO5HjTjjjrci6xv0e7uVJ/MqDy/5KSjgjbqrqDNlrTHB3cni8eyhL2d5bY8nVH5lo9QiQ4kUTGXi/L91qu5Nqoz1dbkdbytMYxwQRi260Ys3wWninyUcl6RdRTbKYh9Zd6eHCZZtzARrMhbVrF/quAZn6Fj5cfHOxs475Y7ZYQbgkuzRr3g4F6SsuEvARXVgXo/AsaWUh5nTpOlf0xLCmgH0qqP/kysVA+G74/FVXS8ykpIyJ+UJgJvHWys1A7vAz9L72vvW38S9Vl/LmtMt4hPdNa004s/4beNuA4wVHLu8zF0t9/itnvxv3NrZQmmsAVGjc5yM7lGwkL9j61fnj5Rmwy1VFsmlN0sYbOnk2kAl/SPW7N4di2JYvKPb6vGK5AVLJ6fOHx6Fp2aQgMRbmJtTrsLrNcWje30rT1ENREMkEgyAXMQPrZeutfPVsvFwtZMdDVSQ6+dhfk+HMtq6E6RV14AWrdk7+kI6n+q50aXFF1bi1IoQ//Z'
                                 );
        insert cons;     // Create the Academic Program.
   
        system.debug('con==>'+cons);
        return cons;
    }
    
    public static Rve_Exam_Notification__c createExamNotification(){
        
        hed__Term__c sem =createSemester();
        Id recordTypeId 	= Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByDeveloperName().get('hed_Semester_Notification').getRecordTypeId();
        
        Rve_Exam_Notification__c examNotification = new Rve_Exam_Notification__c(Name ='testnotification',
                                                                                 Rve_Publish__c= true,
                                                                                 recordTypeId=recordTypeId,
                                                                                 Rve_Semester__c = sem.Id
                                                                                );
        insert examNotification;                                                                                       
        return examNotification;
    }
    
    public static Rve_Exam_Application__c createExamApplications(){
        
        Contact con = [select Id, name,FirstName, LastName,Active_Semester__c,Select_Category__c,Mother_Name__c from contact where LastName='Name'];
        Rve_Exam_Notification__c revExams =createExamNotification();//[select Id,name,Rve_Publish__c,Rve_Semester__c from Rve_Exam_Notification__c where name='testnotification'];
        
        Rve_Exam_Application__c revExam = new Rve_Exam_Application__c( Name='testExam', 
                                                                      Rve_Amount__c=12000,
                                                                      Rve_Applied_Date__c=System.today(),
                                                                      Rve_Exam_Notification__c=revExams.Id,
                                                                      Rve_Logisys_Field_Check__c=true,
                                                                      Rve_Payment_Date__c=System.today(),
                                                                      Rve_Payment_Status__c='Success',
                                                                      Rve_Payment_Type__c='Online',
                                                                      Rve_Registration_Number__c='1234tyu', 
                                                                      Rve_Status__c='Active', 
                                                                      Rve_Student__c=con.Id);
        insert revExam;
        
        Rve_Exam_Application_Line_Item__c lineItem = new Rve_Exam_Application_Line_Item__c(//Name = 'testLineItem' ,
            Rve_QP_Code__c='abbb223',
            Rve_Semester__c='semester',
            Rve_Subject__c='salesforce',
            Rve_Exam_Application__c= revExam.ID);
        
        insert lineItem;
        return revExam;
    }
    
    //******************revaTransport**********************************//
    
      public static Transport_Registeration__c createTransport(){
          Contact con = createContact();
          RTR_Route_Pick_Up_Point__c pickupPoint= createPickUpPoint();
          Reva_Transport__c revaTransport = createRevaTransport();
          RTR_Route_Master__c routeMaster = createRouteMaster();
          
        Transport_Registeration__c createtransport= new Transport_Registeration__c(//Name='Testing',
                                                   Route_Pick_Up_Point__C= pickupPoint.Id ,
                                                   Reva_Transport__C=revaTransport.Id,
                                                   Route_Master__C= routeMaster.Id,
            									  // Route_Master__r.RTR_Route_Path__c= routeMaster.RTR_Route_Path__c,
                                                   Contact__C=con.Id, 
                                                   Registration_Status__c='Active');
          insert createtransport;
          return createtransport;
    }
    
    public static hed__Program_Plan__c createProgramBatch(){
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name ='bachelors of Pathalogy',
                                                                    Bus_Validity__c = Date.today(),
                                                                    busValidity1__c = Date.today());
        insert programBatch;
        return programBatch;
    }
    
    
    public static RTR_Route_Pick_Up_Point__c createPickUpPoint(){
        
        RTR_Route_Pick_Up_Point__c pickupPoint = new RTR_Route_Pick_Up_Point__c(Name='testing');
        
        insert pickupPoint;
        return pickupPoint;
        
    }
    
    public static Reva_Transport__c createRevaTransport(){
        
        Reva_Transport__c revaTransport = new Reva_Transport__c(Name='reva2023',
                                                               Active__c=true);
        
        insert revaTransport;
        return revaTransport;
    }
    
    public static RTR_Route_Master__c createRouteMaster(){
        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'testing',
                                                                 RTR_Capacity__c=100,
            													
        														 RTR_Route_Path__c='mekhri circle');
        
        insert routeMaster;
        return routeMaster;
    }
     
    
    public static contact createProfessorCon(){
         Id ProfessorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
        Contact con = new Contact(FirstName= 'test',
                                   LastName='Dhawan',
                                   Employee_Number__c = 'REV3478',
                                   //Select_Category__c ='Karnataka',
                                   recordTypeId= ProfessorRecordTypeId,
                                  Salary__c = 15000,
                                   Mother_Name__c='sobha',        
                                  Email='testusers1234@example.com');
        
        insert con;
        return con;         
    }
    
    public static contact createNonTeachingCon(){
         Id NonTeachingRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Non Teaching').getRecordTypeId();
        Contact con = new Contact(FirstName= 'test',
                                   LastName='DhawnTR01',
                                   Employee_Number__c = 'REV6823',
                                   recordTypeId= NonTeachingRecordTypeId,
                                  Salary__c = 15000,
                                   Mother_Name__c='sobha',
                                   Email='testusers431@example.com');
        insert con;
        return con;        
    }
    
    public static contact createApplicantCon(){
         Id ApplicantRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact con = new Contact(FirstName= 'test',
                                   LastName='DhawnTRS01',
                                   Application_Number__c = 'REV68234578',
                                   recordTypeId= ApplicantRecordTypeId,
                                   Mother_Name__c='sobha',
                                   Personal_Email__c='testusers4312@example.com');
        insert con;
        return con;        
    }
     // Method to create test RTR_Reva_Transport_Request__c records
    public static RTR_Reva_Transport_Request__c createTestTransportRequests() {       
            RTR_Reva_Transport_Request__c request = new RTR_Reva_Transport_Request__c(
                RTR_Number_of_Minutes__c = 10,
                RTR_Start_Date__c = Date.today(),
            RTR_End_Date__c = Date.Today().addDays(5),
                RTR_Date__c = Date.today(),
                RTR_Descriptions__c = 'Test Description '
            );
        
        
        
        insert request;
        return request;
    }    
    
    //****************revaHostelrequestController*******************************//
    
    public static Account createHouseholdAccount() {
        Account householdAccount = new Account(Name = 'TestHouseholdAccount', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId());
        insert householdAccount;
        return householdAccount;
    }
    
    public static Account createUniversityDepartment() {
        Account universityDepartment = new Account(Name = 'TestUniversityDepartment', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId());
        insert universityDepartment;
        return universityDepartment;
    }
    
    public static Account createAcademicProgram() {
        Account academicProgram = new Account(Name = 'TestAcademicProgram', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId(),
                                              Program_Alias__c = 'MT-CSE(F)',
                                              Program_Type__c = 'PG',
                                              Program_Code__c = 'TC',
                                              Number_of_Semesters__c = 4,
                                              No_of_Years__c = 2);
        insert academicProgram;
        return academicProgram;
    }
    
    public static hed__Program_Plan__c createProgramPlan(Account academicProgram) {
        hed__Program_Plan__c programPlan = new hed__Program_Plan__c(hed__Account__c = academicProgram.Id,
                                                                    hed__Start_Date__c = Date.today(),
                                                                    hed__End_Date__c = Date.today().addYears(2),
                                                                    No_of_Semesters__c = 4,
                                                                    Number_of_Years__c = 2);
        insert programPlan;
        return programPlan;
    }
    
    public static hed__Term__c createActiveSemester(hed__Program_Plan__c programPlan) {
        hed__Term__c activeSemester = new hed__Term__c(Name = 'TestActiveSemester', Program_Batch__c = programPlan.Id, RecordTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('semester').getRecordTypeId());
        insert activeSemester;
        return activeSemester;
    }
    
    public static hed__Term__c createActiveSection(hed__Term__c activeSemester, Account academicProgram) {
        hed__Term__c activeSection = new hed__Term__c(Name = 'TestActiveSection', hed__Account__c = academicProgram.Id, RecordTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('section').getRecordTypeId());
        insert activeSection;
        return activeSection;
    }
    public static Contact createTestContact(Id userId, String userType) {
        hed__Term__c sem = createSemester();
        Id UniversityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Id StudentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        // Create the Academic Program.
        Account ObjAcc = new Account(
            name = 'TestAccount',
            recordTypeId = UniversityRecordTypeId,
            Program_Alias__c = 'Kmnbv123',
            Program_Type__c = 'UG',
            Program_Code__c = '0123',
            Intake__c = 12,
            Intake_Per_Section__c = 40
        );
        insert ObjAcc;
        
        Contact con = new Contact(
            FirstName = 'test name',
            LastName = 'Name',
            Active_Semester__c = sem.Id,
            Application_Number__c = '1223467',
            Select_Category__c = 'Karnataka',
            recordTypeId = StudentRecordTypeId,
            Mother_Name__c = 'sobha',
            Email = 'TestContact01@gmail.co',
            School__c = ObjAcc.Id // Assign the created Account Id
            //User__c = userId  // Assign the provided User Id
        );
        insert con;
        system.debug('con==>' + con);
        return con;
    }
    public static Reva_Hostel_Request__c createTestHostelRequest(Id contactId) {
        Reva_Hostel_Request__c testHostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = contactId,
            Status__c = 'Approved',
            Type__c = '1',
            //Room_Number__c = '101',
            Reva_Hostel_Room__c = 'a2x1e000000lmunAAA'
            // Add other required fields
        );
        insert testHostelRequest;
        System.debug('Test Hostel Request ID: ' + testHostelRequest.Id);
        return testHostelRequest;
    }
    public static User createTestUser(String userType) {
        Profile profile;
        if (userType == 'Student') {
            profile = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile'    LIMIT 1];
        } else if (userType == 'Non Teaching') {
            profile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
        } else {
            // Handle other user types or throw an exception
            // based on your specific requirements
            return null;
        }
        
        // Create a Contact record
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testcontact@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male'
            // Add other required fields
        );
        insert testContact;
        
        User testUser = new User(
            Alias = 'testU',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'testuser@example.com',
            ContactId = testContact.Id  // Associate the User with the Contact
        );
        insert testUser;
        
        return testUser;
    }
    
    public static User createNonTeachingUser() {
        Profile nonTeachingProfile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
        
        // Create a Contact record
        Contact testContact = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female'
            // Add other required fields
        );
        insert testContact;
        
        User nonTeachingUser = new User(
            Alias = 'nontea',
            Email = 'nonteachinguser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'NonTeachingUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = nonTeachingProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'nonteachinguser@example.com',
            ContactId = testContact.Id  // Associate the User with the Contact
        );
        insert nonTeachingUser;
        
        return nonTeachingUser;
    }
    
    
}