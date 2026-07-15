/*
Use Case: This rest API is used to create the Application in salesforce from NPF
How : No Paper Forms will push the data to salesforce once the 1st payment is completed
What : All the application Details will be pusehed to salesforce and created in the contact object, parent details will be created in the 
contact object has a child object for student record
Along with this education history, Student Fee and Student payment deatils also capturing in the respective objects
Created By : Manjunatha Y C
Created Date For POC : 24/02/2022
Modified Date For POC : 15/06/2022 add Savepoint
*/

@RestResource(urlMapping='/CreateApplication/*')
global class NPF_ApplicationAPI {
    
    @HttpPost
    global static ResponseWrapper CreateApplication() 
    {
        ResponseWrapper objResp = new ResponseWrapper();
        List<Contact> lst_ContactsToUpsert = new List<Contact>();
        responseApplicant objWrapper = new responseApplicant();   
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        string JsonBody = req.requestBody.toString().trim();         
        responseApplicant applObject = (responseApplicant)system.JSON.deserialize(JsonBody, responseApplicant.class);
        set<string> set_ApplicationNumber = new set<string>();     
        set<string> set_City = new set<string>();   
        set<string> set_Faculty = new set<string>();   
        set<string> set_Program = new set<string>(); 
        set<string> set_ProgramPlan = new set<string>();
        map<string,Contact> map_Contact = new map<string,Contact>();
        map<string,Contact> map_ParentContact = new map<string,Contact>();
        List<hed__Education_History__c> lst_hedEducationHist = new List<hed__Education_History__c>();
        List<contact> lst_ParentContact = new List<contact>();
        List<Student_Fee__c> lst_StudentFee = new List<Student_Fee__c>();
        List<Student_Payment__c> lst_StudentPay = new List<Student_Payment__c>();
        Account objAccount = new Account();
        map<Id,University_Fee_Masters__c> map_UniversityFee = new map<Id,University_Fee_Masters__c>();
        map<string,Account> map_Faculty = new map<string,Account>();
        map<string,account> map_Program = new map<string,account>();
        map<string,hed__Program_Plan__c> map_ProgPlan = new map<string,hed__Program_Plan__c>();        
        map<string,string> map_City = new map<string,string>();
        
        string programPlan;
        string admissionSession;
        string program_str;
        string schoolId;
        string programType;
        string str_Quota;
        
        Debug_Log__c objDebug = new Debug_Log__c();
        objDebug.Class_Name__c = 'NPF_ApplicationAPI';
        objDebug.Object_Name__c = 'Multiple Objects (Contact, Educa Histry)';
        objDebug.Processing_API_Name__c = 'CreateApplication';
        objDebug.Status__c = 'Success';
        objDebug.Data_Received__c = JsonBody;
        insert objDebug;
        Savepoint sp = Database.setSavepoint();
        boolean bool_StudentFee = false;
        for(ApplicantDetails objData : applObject.ApplicantDetails)
        {
            if(objData.Student_Fee != null)
            {
                for(Student_Fee objStudFee : objData.Student_Fee)
                {
                    if(string.isNotBlank(objStudFee.Amount))
                    {
                        bool_StudentFee = true;
                    }
                }
            }
            else
            {
                bool_StudentFee = false;
            }
        }
        if(bool_StudentFee == false)
        {
            objResp.Errormessage = 'Incorrect Student Fee Data/Not Exists';
            objResp.status = 'Failed';            
            objDebug.Status__c = 'Failure';
            objDebug.Error_Message__c = objResp.Errormessage;
            Database.rollback( sp );  
            update objDebug;
            
            return objResp;
        }
        
        for(ApplicantDetails objData : applObject.ApplicantDetails)
        {
            if(string.IsNotBlank(objData.ApplicationNumber)) set_ApplicationNumber.add(objData.ApplicationNumber);             
            if(string.IsNotBlank(objData.school)) set_Faculty.add(objData.school);            
            if(string.IsNotBlank(objData.permanent_city)) set_City.add(objData.permanent_city);
            if(string.IsNotBlank(objData.program)) set_Program.add(objData.program);  
            if(string.IsNotBlank(objData.Admission_Mode)) str_Quota = objData.Admission_Mode; 
            else str_Quota = 'UQ';
            admissionSession = objData.admission_session;
            program_str = objData.program;             
        }
        
        for(University_Fee_Masters__c objUnivFee : [select Id,Academic_Program__c,Amount__c,Quota__c from University_Fee_Masters__c 
                                                    where Academic_Program__c =: program_str and Quota__c =: str_Quota and Amount__c > 0])
        {
            map_UniversityFee.put(objUnivFee.Academic_Program__c,objUnivFee);
        }
        if(set_Program.size() > 0) {
            string acadamicRecdTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
            for(Account objProgram : [select Id,Name,NPF_Program_ID_Regular__c,NPF_Program_ID_Lateral__c,ParentId,Program_Type__c from 
                                      Account where Id IN: set_Program and RecordTypeId =: acadamicRecdTypId ])  {                
                                          
                                          map_Program.put(objProgram.Id,objProgram);   
                                          if(string.IsnotBlank(objProgram.ParentId)) schoolId = objProgram.ParentId;
                                          integer endYear = integer.Valueof(admissionSession)+4;
                                          if(string.IsNotBlank(program_str)) set_ProgramPlan.add(map_Program.get(program_str).Name+'-'+admissionSession);
                                          programPlan = map_Program.get(program_str).Name+'-'+admissionSession;
                                          if(string.isNotBlank(objProgram.Program_Type__c)) programType = objProgram.Program_Type__c;
                                      }
        }
        
        if(set_ProgramPlan.size() > 0) {
            for(hed__Program_Plan__c objProgPlan : [select Id,Name,Program_Batch_Name__c from hed__Program_Plan__c 
                                                    where Program_Batch_Name__c IN: set_ProgramPlan])         {
                                                        map_ProgPlan.put(objProgPlan.Program_Batch_Name__c,objProgPlan);
                                                    }
        }        
        
        map<String,string> map_Citylist = getPickListValuesIntoList();
        
        for(contact objContact : [select Id,Application_Number__c,AccountId from Contact where Application_Number__c IN: set_ApplicationNumber])         {
            map_Contact.put(objContact.Application_Number__c,objContact);
        }
        
        if(map_Contact.size() == 0 || map_Contact == null) {            
            for(ApplicantDetails objData : applObject.ApplicantDetails)
            {
                string strName;
                if(string.isNotBlank(objData.first_name)) strName = objData.first_name;
                if(string.isNotBlank(objData.middle_name)) strName = strName + ' ' +objData.middle_name;
                if(string.isNotBlank(objData.last_name)) strName = strName + ' ' +objData.last_name;
                
                objAccount.Name = objData.ApplicationNumber+'-'+strName;
                // objAccount.Phone = string.isNotBlank(objData.Mobile) ? objData.Mobile : null;               
                objAccount.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
            }            
        } 
        if(objAccount != null && map_Contact.size() == 0) Insert objAccount;
        
        // system.debug('=====>>>>objAccount ' + objAccount.Id);
        for(ApplicantDetails objData : applObject.ApplicantDetails)
        {                
            Contact objContact = new Contact();
            //if(map_City.size() > 0 && map_City.ContainsKey(objData.permanent_City))  objContact.City__c = map_City.get(objData.permanent_city).Id;
            objContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
            if(objAccount != null) objContact.AccountId = objAccount.Id;
            if(map_Contact.size() > 0 && map_Contact.containskey(objData.ApplicationNumber) ) objContact.AccountId = map_Contact.get(objData.ApplicationNumber).Id;
            objContact.Select_Category__c = string.isNotBlank(objData.Category) ? objData.Category : null;
            objContact.Quota__c = string.isNotBlank(objData.Quota) ? objData.Quota : null;
            objContact.Enrollment_Type__c = string.isNotBlank(objData.Enrollment_Type) ? objData.Enrollment_Type : null;            
            if(string.isNotBlank(schoolId)) {
                objContact.School__c = schoolId; // School__c replaced to accountId                
            }
            
            if(map_Program.size() > 0 && map_Program.containsKey(objData.program)) {
                objContact.Primary_Academic_Program__c = map_Program.get(objData.program).Id;
            }            
            if(string.isNotBlank(programPlan) && map_ProgPlan.containsKey(programPlan)) {
                objContact.Program_Batch__c = map_ProgPlan.get(programPlan).Id;
            }             
            
            objContact.Admission_Session__c = string.isNotBlank(objData.admission_session) ? objData.admission_session : null;
            objContact.Applying_For_REVA_CET__c = string.isNotBlank(objData.applying_for_reva_cet) ? objData.applying_for_reva_cet : null;
            if(string.isNotBlank(objData.Reva_CET_Date)){
                Map <String, Integer> monthsMap = new Map <String, Integer> {'january'=>1, 'febuary'=>2, 'march'=>3, 'april'=>4, 'may'=>5, 'june'=>6, 'july'=>7, 'august'=>8, 'september'=>9, 'october'=>10, 'november'=>11, 'december'=>12};                
                    string[] dateParts =  objData.Reva_CET_Date.split(',');                
                string[] strDateSplit = dateParts[0].Split(' ');               
                integer mnt = monthsMap.get(strDateSplit[1].toLowercase());                
                Date dt = date.newInstance(integer.Valueof(strDateSplit[2]), mnt, integer.Valueof(strDateSplit[0]));
                objContact.Exam_Date__c = dt;
            }
            objContact.Exam_Type__c = string.isNotBlank(objData.exam_type) ? objData.exam_type : null;
            objContact.FirstName = string.isNotBlank(objData.first_name) ? objData.first_name : null;
            if(string.isNotBlank(objData.middle_name)) objContact.MiddleName = objData.middle_name;            
            objContact.LastName = string.isNotBlank(objData.last_name) ? objData.last_name : null;            
            objContact.Personal_Email__c = string.isNotBlank(objData.Personal_Email) ? objData.Personal_Email : null;
            objContact.MobilePhone = string.isNotBlank(objData.Mobile) ? objData.Mobile : null;
            objContact.Marital_Status__c = string.isNotBlank(objData.Martial_Status) ? objData.Martial_Status : null;
            if(string.isNotBlank(objData.Birthdate)) {                
                objContact.Birthdate = date.parse(objData.Birthdate);
            }
            objContact.hed__Gender__c = string.isNotBlank(objData.gender) ? objData.gender : null; 
            if(objContact.hed__Gender__c == 'Male') objContact.Salutation = 'Mr.';
            if(objContact.hed__Gender__c == 'Female') objContact.Salutation = 'Ms.';
            //if(objContact.hed__Gender__c == 'Transgender') objContact.Salutation = 'Mx.';                
            objContact.hed__Disability_Status__c = string.isNotBlank(objData.PH_Handicapped) ? boolean.Valueof(objData.PH_Handicapped) : null;          
            objContact.Nationality__c = string.isNotBlank(objData.nationality) ? objData.nationality : null;
            objContact.Aadhar_Card_Number__c = string.isNotBlank(objData.Aadhaar_Card_Number) ? objData.Aadhaar_Card_Number : null;
            objContact.Select_Whichever_Is_Applicable__c = string.isNotBlank(objData.Nationality_Type) ? objData.Nationality_Type : null;            
            objContact.Are_You_A_REVA_Student__c = string.isNotBlank(objData.Are_You_A_Reva_Student) ? objData.Are_You_A_Reva_Student : null;
            objContact.hed__Religion__c = string.isNotBlank(objData.Religion) ? objData.Religion : null;
            objContact.Caste_Category__c = string.isNotBlank(objData.Caste_Category) ? objData.Caste_Category : null;
            if(objContact.Caste_Category__c == 'General Merit') objContact.Caste_Category__c = 'GM';
            if(objContact.Caste_Category__c == 'OBC - 2A') objContact.Caste_Category__c = '2A';
            if(objContact.Caste_Category__c == 'OBC - 2B') objContact.Caste_Category__c = '2B';
            if(objContact.Caste_Category__c == 'OBC - 3A') objContact.Caste_Category__c = '3A';
            if(objContact.Caste_Category__c == 'OBC - 3B') objContact.Caste_Category__c = '3B';
            objContact.Blood_Group__c = string.isNotBlank(objData.Blood_Group) ? objData.Blood_Group : null;
            objContact.Passport_Number__c = string.isNotBlank(objData.passport_number) ? objData.passport_number : null;
            objContact.Passport_Issued_Country__c = string.isNotBlank(objData.Passport_Issued_Country) ? objData.Passport_Issued_Country : null;
            objContact.Passport_Place_Of_Issue__c= string.isNotBlank(objData.Passport_Place_Of_Issue) ? objData.Passport_Place_Of_Issue : null;
            objContact.Passport_Date_Of_Issue__c = string.isNotBlank(objData.Passport_Date_of_Issue) ? Date.parse(objData.Passport_Date_of_Issue) : null;
            objContact.Passport_Date_Of_Expiry__c = string.isNotBlank(objData.Passport_Date_of_Expiry) ? Date.parse(objData.Passport_Date_of_Expiry) : null;
            
            objContact.MailingCountry = string.isNotBlank(objData.correspondence_country) ? objData.correspondence_country : null;
            objContact.MailingState = string.isNotBlank(objData.correspondence_state) ? objData.correspondence_state : null;   
            objContact.hed__Preferred_Email__c = 'Alert Email';
            objContact.MailingCity = string.isNotBlank(objData.correspondence_city) ? objData.correspondence_city : null;
            if(map_Citylist.size() > 0 && !map_Citylist.ContainsKey(objContact.MailingCity)) {
                objContact.City__c = 'Others';
            }
            objContact.MailingStreet = string.isNotBlank(objData.correspondence_address_line_1) ? objData.correspondence_address_line_1 : null;
            if(objContact.MailingStreet != null)
                objContact.MailingStreet = string.isNotBlank(objData.correspondence_address_line_2) ? objContact.MailingStreet + ' ' + objData.correspondence_address_line_2 : objContact.MailingStreet;
            else 
                objContact.MailingStreet = string.isNotBlank(objData.correspondence_address_line_2) ? objData.correspondence_address_line_2 : null;
            
            objContact.District__c = string.isNotBlank(objData.correspondence_district) ? objData.correspondence_district : null;
            //objContact.District__c = string.isNotBlank(objData.permanent_district) ? objData.permanent_district : null;
            objContact.Other_District__c = string.isNotBlank(objData.permanent_district) ? objData.permanent_district : null;
            
            objContact.MailingPostalCode = string.isNotBlank(objData.correspondence_pincode) ? objData.correspondence_pincode : null; 
            objContact.Is_perm_add_same_as_communication_add__c = string.isNotBlank(objData.Is_perm_add_same_as_commu_add) ? objData.Is_perm_add_same_as_commu_add : null;
            objContact.OtherCountry = string.isNotBlank(objData.permanent_country) ? objData.permanent_country : null;
            objContact.OtherState = string.isNotBlank(objData.permanent_state) ? objData.permanent_state : null;
            
            objContact.OtherCity = string.isNotBlank(objData.permanent_city) ? objData.permanent_city : null;
            if(map_Citylist.size() > 0 && !map_Citylist.ContainsKey(objContact.OtherCity)) 
            {
                objContact.City__c = 'Others';
            }
            objContact.OtherStreet = string.isNotBlank(objData.permanent_address_line_1) ? objData.permanent_address_line_1 : null;
            objContact.OtherStreet = string.isNotBlank(objData.permanent_address_line_2) ? objContact.OtherStreet + ' ' +objData.permanent_address_line_2 : objContact.OtherStreet;
            objContact.OtherPostalCode = string.isNotBlank(objData.permanent_pincode) ? objData.permanent_pincode : null; 
            
            objContact.File_Passport_Size_Photo__c = string.isNotBlank(objData.file_passport_size_photo) ? objData.file_passport_size_photo : null;
            objContact.Referral_Code__c = string.isNotBlank(objData.referral_code) ? objData.referral_code : null;
            objContact.Transportation_Facility__c = string.isNotBlank(objData.Transporatation_Facility) ? objData.Transporatation_Facility : null;
            objContact.Hostel_Facility__c = string.isNotBlank(objData.Hostel_Facility) ? objData.Hostel_Facility : null;
            //objContact.Applicant_Name__c = string.isNotBlank(objData.applicant_name) ? objData.applicant_name : null;
            //objContact.Parent_Name__c = string.isNotBlank(objData.parent_name) ? objData.parent_name : null;
            objContact.Application_Submission_Date__c = string.isNotBlank(objData.Application_Submission_Date) ? Date.parse(objData.Application_Submission_Date) : null;
            objContact.I_Agree__c = string.isNotBlank(objData.I_Agree) ? objData.I_Agree : null;
            if(map_Contact.size() > 0 && map_Contact.ContainsKey(objData.ApplicationNumber)) { 
                objContact.Id = map_Contact.get(objData.ApplicationNumber).Id;  
                objContact.AccountId = map_Contact.get(objData.ApplicationNumber).AccountId; 
            }
            objContact.NPF_External_ID__c = objData.ApplicationNumber; 
            objContact.Application_Number__c = objData.ApplicationNumber;
            objContact.hed__WorkEmail__c = objContact.Application_Number__c+'@reva.edu.in';
            objContact.Email = objContact.Application_Number__c+'@reva.edu.in';
            objContact.Personal_Email__c = string.isNotBlank(objData.Personal_Email) ? objData.Personal_Email : null;
            objContact.NPF__c = true;
            if(string.isNotBlank(objData.Admission_Mode)) objContact.Admission_Mode__c =  objData.Admission_Mode;
            else objContact.Admission_Mode__c = 'UQ';
            objContact.CET_COMEDK_Number__c = string.isNotBlank(objData.Cet_Comedk_TAT_No) ? objData.Cet_Comedk_TAT_No : null; 
            objContact.CET_COMEDK_Rank__c = string.isNotBlank(objData.Cet_Comedk_Rank) ? objData.Cet_Comedk_Rank : null;
            objContact.Admission_Order_No__c = string.isNotBlank(objData.Addmission_Order_No) ? objData.Addmission_Order_No : null;
            if(objData.Addmission_Order_Date != null && string.isNotBlank(objData.Addmission_Order_Date))
            {
                Date dt = Date.parse(objData.Addmission_Order_Date);
                //Date dtDate = Date.newInstance(dt.year(), dt.month(), dt.day());
                objContact.Admission_Order_Date__c = dt;
            }
            objContact.Claimed_Caste_Category__c = string.isNotBlank(objData.Claimed_Category) ? objData.Claimed_Category : null;  
            objContact.Alloted_Caste_Category__c = string.isNotBlank(objData.Alloted_Category) ? objData.Alloted_Category : null;  
            objContact.Sports_Person__c = string.isNotBlank(objData.Sports_Person) ? objData.Sports_Person : null; 
            objContact.Defence_Ex_Serviceman__c = string.isNotBlank(objData.Defence_Ex_Serviceman) ? objData.Defence_Ex_Serviceman : null;  
            objContact.State_of_Domicile__c = string.isNotBlank(objData.State_of_Domicile) ? objData.State_of_Domicile : null;   
            objContact.Mother_Tongue__c = string.isNotBlank(objData.Mother_Tongue) ? objData.Mother_Tongue : null;  
            objContact.Alternate_Mobile_Number_1__c = string.isNotBlank(objData.Alternate_Phone_Number) ? Decimal.valueof(objData.Alternate_Phone_Number) : null;   
            objContact.City_Type__c = string.isNotBlank(objData.Belongs_To) ? objData.Belongs_To : null;  
            objContact.Anti_Ragging_undertaking_Reference_No__c = string.isNotBlank(objData.Anti_Ragging_undertaking_Reference_No) ? objData.Anti_Ragging_undertaking_Reference_No : null;  
            objContact.Local_Guardian_Address__c = string.isNotBlank(objData.Local_Guardian_Address) ? objData.Local_Guardian_Address : null;   
            //objContact = Local_Guardian_City;
            objContact.Local_Guardian_District__c = string.isNotBlank(objData.Local_Guardian_District) ? objData.Local_Guardian_District : null;
            objContact.Local_Guardian_State__c = string.isNotBlank(objData.Local_Guardian_State) ? objData.Local_Guardian_State : null;
            objContact.Local_Guardian_Country__c = string.isNotBlank(objData.Local_Guardian_Country) ? objData.Local_Guardian_Country : null; 
            objContact.Local_Guardian_Pin_Code__c = string.isNotBlank(objData.Local_Guardian_Pin_Code) ? objData.Local_Guardian_Pin_Code : null; 
            objContact.Student_Status__c = 'Pursuing';
            objContact.User_Creation_in_AD__c = 'AD User Not Created';
            
            if(objData.Student_Payment != null) {
                for(Student_Payment objStudPay : objData.Student_Payment)
                {
                    objContact.Online_Order_Id__c = string.isNotBlank(objStudPay.online_order_id) ? objStudPay.online_order_id : null; 
                    objContact.Online_Transaction_Id__c = string.isNotBlank(objStudPay.online_transaction_id) ? objStudPay.online_transaction_id : null; 
                    
                    if(string.isNotBlank(objStudPay.online_payment_date)) 
                    {                       
                        DateTime dt = DateTime.valueOf(objStudPay.online_payment_date);
                        objContact.online_payment_date__c =  dt;                              
                    }
                    
                    if(string.isNotBlank(objStudPay.offline_payment_date)){
                        objContact.Offline_Payment_Date__c =  DateTime.valueof(objStudPay.offline_payment_date);   
                    }
                    if(string.isNotBlank(objStudPay.offline_transaction_id))  objContact.Offline_Transaction_Id__c =  string.valueof(objStudPay.offline_transaction_id);     
                    objContact.Offline_Receipt_Number__c = string.isNotBlank(objStudPay.offline_receipt_number) ? string.valueof(objStudPay.offline_receipt_number) : null;      
                    decimal recordAmount = string.isNotBlank(objStudPay.Amount) ? decimal.valueof(objStudPay.Amount) : 0;                     
                    objContact.Amount__c = recordAmount;  

                    objContact.Fee_Paid_at_University__c =  string.isNotBlank(objStudPay.fee_paid_at_university_rs) ? decimal.valueof(objStudPay.fee_paid_at_university_rs) : 0; 
                    objContact.Univeristy_Fee_Receipt_Challan_No__c =  string.isNotBlank(objStudPay.receipt_challan_no) ? string.valueof(objStudPay.receipt_challan_no) : null; 
                    objContact.University_Fee_Receipt_Date__c =  string.isNotBlank(objStudPay.receipt_date) ? DateTime.valueof(objStudPay.receipt_date) : null; 
                    
                    objContact.Fee_Paid_at_KEA__c =  string.isNotBlank(objStudPay.paid_at_kea) ? decimal.valueof(objStudPay.paid_at_kea) : 0; 
                    objContact.KEA_Challan_No_Reference_No__c =  string.isNotBlank(objStudPay.kea_challan_no_refer_no) ? string.valueof(objStudPay.kea_challan_no_refer_no) : null; 
                    objContact.KEA_Fee_Receipt_Date__c =  string.isNotBlank(objStudPay.paid_date) ? DateTime.valueof(objStudPay.paid_date) : null; 
                }
            }
             
            objContact.Caste__c = string.isNotBlank(objData.caste) ? objData.caste : null; 
            objContact.File_Study_Certificate__c = string.isNotBlank(objData.file_study_certificate) ? objData.file_study_certificate : null; 
            objContact.File_Transfer_Certificate__c = string.isNotBlank(objData.file_transfer_certificate) ? objData.file_transfer_certificate : null; 
            objContact.File_Migration_Certificate__c = string.isNotBlank(objData.file_migration_certificate) ? objData.file_migration_certificate : null; 
            objContact.File_Caste_Certificate__c = string.isNotBlank(objData.file_caste_certificate) ? objData.file_caste_certificate : null; 
            objContact.File_Income_Certificate__c = string.isNotBlank(objData.file_income_certificate) ? objData.file_income_certificate : null; 
            objContact.File_Rural_Certificate__c = string.isNotBlank(objData.file_rural_certificate) ? objData.file_rural_certificate : null; 
            objContact.File_Kannada_Medium_Certificate__c = string.isNotBlank(objData.file_kannada_medium_certificate) ? objData.file_kannada_medium_certificate : null; 
            objContact.File_Copy_of_Hydr_Kar_Certificate__c = string.isNotBlank(objData.file_copy_of_hydr_kar_certificate) ? objData.file_copy_of_hydr_kar_certificate : null; 
            objContact.File_Defence_Karnataka_Capf_Others__c = string.isNotBlank(objData.file_defence_karnataka_capf_others) ? objData.file_defence_karnataka_capf_others : null; 
            objContact.File_Copy_of_Aadhar_Card__c = string.isNotBlank(objData.file_copy_of_aadhar_card) ? objData.file_copy_of_aadhar_card : null; 
			
            
            lst_ContactsToUpsert.add(objContact);
        }               
        
        if(lst_ContactsToUpsert.size() > 0)
        {   
            try
            {
                List<Database.upsertResult> srList = Database.Upsert(lst_ContactsToUpsert,Contact.NPF_External_ID__c,false); 
                 
                for (integer i=0; i < srList.size(); i++) {
                    if (srList[i].isSuccess()) {
                        objResp.status = 'Success';                   
                        if(map_Contact.size() == 0) { 
                            if(string.IsNotBlank(applObject.ApplicantDetails[i].file_passport_size_photo))  utility.FileCreation(applObject.ApplicantDetails[i].file_passport_size_photo,lst_ContactsToUpsert[i].Id,'ProfilePic');
                            if(string.IsNotBlank(applObject.ApplicantDetails[i].file_study_certificate))  utility.FileCreation(applObject.ApplicantDetails[i].file_study_certificate,lst_ContactsToUpsert[i].Id,'StudyCertificate');
                            if(string.IsNotBlank(applObject.ApplicantDetails[i].file_transfer_certificate))   utility.FileCreation(applObject.ApplicantDetails[i].file_transfer_certificate,lst_ContactsToUpsert[i].Id,'TransferCertificate');
                            if(string.IsNotBlank(applObject.ApplicantDetails[i].file_migration_certificate))  utility.FileCreation(applObject.ApplicantDetails[i].file_migration_certificate,lst_ContactsToUpsert[i].Id,'MigrationCertificate');
                            if(string.IsNotBlank(applObject.ApplicantDetails[i].file_caste_certificate))   utility.FileCreation(applObject.ApplicantDetails[i].file_caste_certificate,lst_ContactsToUpsert[i].Id,'CasteCertificate');
                            if(string.IsNotBlank(applObject.ApplicantDetails[i].file_income_certificate))   utility.FileCreation(applObject.ApplicantDetails[i].file_income_certificate,lst_ContactsToUpsert[i].Id,'IncomeCertificate');
                            if(string.IsNotBlank(applObject.ApplicantDetails[i].file_rural_certificate))  utility.FileCreation(applObject.ApplicantDetails[i].file_rural_certificate,lst_ContactsToUpsert[i].Id,'RuralCertificate');                            
                            if(string.IsNotBlank(applObject.ApplicantDetails[i].file_kannada_medium_certificate))  utility.FileCreation(applObject.ApplicantDetails[i].file_kannada_medium_certificate,lst_ContactsToUpsert[i].Id,'RuralCertificate');                            
                            if(string.IsNotBlank(applObject.ApplicantDetails[i].file_copy_of_hydr_kar_certificate))  utility.FileCreation(applObject.ApplicantDetails[i].file_copy_of_hydr_kar_certificate,lst_ContactsToUpsert[i].Id,'HydKarnataka');                            
                            if(string.IsNotBlank(applObject.ApplicantDetails[i].file_defence_karnataka_capf_others))  utility.FileCreation(applObject.ApplicantDetails[i].file_defence_karnataka_capf_others,lst_ContactsToUpsert[i].Id,'Defencekarnataka');                            
                            if(string.IsNotBlank(applObject.ApplicantDetails[i].file_copy_of_aadhar_card))  utility.FileCreation(applObject.ApplicantDetails[i].file_copy_of_aadhar_card,lst_ContactsToUpsert[i].Id,'AdharCard');                            
                        }
                    }
                    else if (!srList[i].isSuccess())
                    {
                        objResp.status = 'Failed';                    
                        objResp.Errormessage = string.valueOf(srList[i].getErrors()[0].getMessage() + ' ' + srList[i].getErrors()[0].getStatusCode() + ' '+ srList[i].getErrors()[0].getFields());
                        objDebug.Status__c = 'Failure';
                        objDebug.Error_Message__c = objResp.Errormessage;
                        Database.rollback( sp );
                        system.debug('==== Errormessage==='+ objResp.Errormessage);   
                        update objDebug;
                        return objResp;
                    }
                }    
            }
            catch(exception ex)
            {
                objResp.status = 'Failed';                    
                objResp.Errormessage = string.valueOf(ex.getStackTraceString() +' '+ ex.getMessage()+' '+ ex.getLineNumber());
                objDebug.Status__c = 'Failure';
                objDebug.Error_Message__c = objResp.Errormessage;
                Database.rollback( sp );
                //system.debug('==== Errormessage==='+ objResp.Errormessage);   
                update objDebug;
                return objResp;
            }
        }
        
        
        
        for(ApplicantDetails objData : applObject.ApplicantDetails)
        { 
            if(objData.Education_History != null && map_Contact.size() == 0) 
            {
                
                for(Education_History objEduHist : objData.Education_History)
                {
                    hed__Education_History__c objEdu = new hed__Education_History__c();
                    objEdu.RecordTypeId =  Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get(Utility.Educ_History_Object_RecType_Edu_Details).getRecordTypeId();                  
                   // objEdu.Year_of_Passing__c = string.isNotBlank(objEduHist.Year_of_Passing) ? Date.parse(objEduHist.Year_of_Passing) : null; 
                    objEdu.Year_passing__c = string.isNotBlank(objEduHist.Year_of_Passing) ?  objEduHist.Year_of_Passing : null; 
                    objEdu.Institution_Name__c = string.isNotBlank(objEduHist.Institution_Name) ? string.ValueOf(objEduHist.Institution_Name) : null;
                    objEdu.hed__Educational_Institution_Name__c  = string.isNotBlank(objEduHist.Institution_Name) ? string.ValueOf(objEduHist.Institution_Name) : null;
                  //  system.debug('====='+objEduHist.Marks_Obtained);
                   // objEdu.Marks_Obtained__c = string.isNotBlank(objEduHist.Marks_Obtained) ? string.ValueOf(objEduHist.Marks_Obtained) : null;
                    objEdu.Max_Marks__c = string.isNotBlank(objEduHist.max_marks) ? string.ValueOf(objEduHist.max_marks) : null;
                    objEdu.Percentage__c = string.isNotBlank(objEduHist.Percentage) ? string.ValueOf(objEduHist.Percentage) : null;
                    objEdu.Type_of_Course__c  = string.isNotBlank(objEduHist.type_of_course) ? string.ValueOf(objEduHist.type_of_course) : null;
                    objEdu.PG_Result_Status__c = string.isNotBlank(objEduHist.PG_Result_Status) ? string.ValueOf(objEduHist.PG_Result_Status) : null; 
                    objEdu.City__c = string.isNotBlank(objEduHist.city) ? string.ValueOf(objEduHist.city) : null; 
                    if(map_Citylist.size() > 0 && !map_Citylist.ContainsKey(objEdu.City__c)) {
                        objEdu.Cities__c = 'Others';                        
                    }
                    else 
                    {
                        objEdu.Cities__c = objEdu.City__c; 
                    }
                    // if(map_Citylist.size() > 0 && map_Citylist.ContainsKey(objEdu.City__c)) objEdu.City1__c = objEdu.City__c;
                    objEdu.Course__c = string.isNotBlank(objEduHist.Course) ? string.ValueOf(objEduHist.Course) : null;  
                    objEdu.Type_of_Course__c = string.isNotBlank(objEduHist.Type_of_Course) ? string.ValueOf(objEduHist.Type_of_Course) : null;  
                    if(programType == 'PG' && objEdu.Type_of_Course__c == 'UG') { objEdu.University_UG__c = string.isNotBlank(objEduHist.Board_OR_University) ? string.ValueOf(objEduHist.Board_OR_University) : null; } 
                    else { objEdu.Board__c = string.isNotBlank(objEduHist.Board_OR_University) ? string.ValueOf(objEduHist.Board_OR_University) : null;  }
                    objEdu.State__c = string.isNotBlank(objEduHist.State) ? string.ValueOf(objEduHist.State) : null; 
                    objEdu.Stream__c = string.isNotBlank(objEduHist.Stream) ? string.ValueOf(objEduHist.Stream) : null; 
                    
                    
                    objEdu.hed__Contact__c = lst_ContactsToUpsert[0].Id;
                    objEdu.File_Url__c = string.isNotBlank(objEduHist.file_document) ? string.ValueOf(objEduHist.file_document) : null;                    
                    objEdu.Country__c =  string.isNotBlank(objEduHist.Country) ? string.ValueOf(objEduHist.Country) : null;
                    objEdu.Second_Language_Studied__c = string.isNotBlank(objEduHist.Second_Language_Studied) ? string.ValueOf(objEduHist.Second_Language_Studied) : null; 
                    objEdu.Physics_Marks_Obtained__c = string.isNotBlank(objEduHist.Physics) ? Decimal.ValueOf(objEduHist.Physics) : null; 
                    objEdu.Chemistry_Marks_Obtained__c = string.isNotBlank(objEduHist.Chemistry) ? Decimal.ValueOf(objEduHist.Chemistry) : null; 
                    objEdu.Mathematics_Marks_Obtained__c = string.isNotBlank(objEduHist.Maths) ? Decimal.ValueOf(objEduHist.Maths) : null; 
                    objEdu.P_M_C_B_CS_EC__c =  string.isNotBlank(objEduHist.P_M_C_B_CS_EC_Perc) ? Decimal.ValueOf(objEduHist.P_M_C_B_CS_EC_Perc) : null;  
                    objEdu.Other_Marks__c = string.isNotBlank(objEduHist.Others) ? Decimal.ValueOf(objEduHist.Others) : null;  
                    objEdu.Register_No__c = string.isNotBlank(objEduHist.Register_No) ? string.ValueOf(objEduHist.Register_No) : null; 
                    
                    //ComedK/PgCET
                    objEdu.District__c = string.isNotBlank(objEduHist.district) ? string.ValueOf(objEduHist.district) : null; 
                    objEdu.Marking_Scheme__c = string.isNotBlank(objEduHist.marking_scheme) ? string.ValueOf(objEduHist.marking_scheme) : null; 
                    objEdu.Other_Marking_Scheme__c = string.isNotBlank(objEduHist.Other_Marking_Scheme) ? string.ValueOf(objEduHist.Other_Marking_Scheme) : null; 
                    objEdu.First_Language_Marks_Obtained__c = string.isNotBlank(objEduHist.marks_obtained_first_lang) ? Decimal.ValueOf(objEduHist.marks_obtained_first_lang) : null; 
                    objEdu.Marks_Obtained__c = string.isNotBlank(objEduHist.marks_obtained_total) ? string.ValueOf(objEduHist.marks_obtained_total) : null; 
                    objEdu.Physics_Total_Marks__c = string.isNotBlank(objEduHist.maxmarks_physics) ? Decimal.ValueOf(objEduHist.maxmarks_physics) : null; 
                    objEdu.Mathematics_Total_Marks__c = string.isNotBlank(objEduHist.maxmarks_maths) ? Decimal.ValueOf(objEduHist.maxmarks_maths) : null; 
                    objEdu.Chemistry_Total_Marks__c = string.isNotBlank(objEduHist.maxmarks_chemistry) ? Decimal.ValueOf(objEduHist.maxmarks_chemistry) : null; 
                    objEdu.First_Language_Total_Marks__c = string.isNotBlank(objEduHist.maxmarks_first_lang) ? Decimal.ValueOf(objEduHist.maxmarks_first_lang) : null; 
                    objEdu.Second_Language_Total_Marks__c = string.isNotBlank(objEduHist.maxmarks_second_lang) ? Decimal.ValueOf(objEduHist.maxmarks_second_lang) : null; 
                    objEdu.Other_Total_Marks__c = string.isNotBlank(objEduHist.maxmarks_bio_cs_ec_oth) ? Decimal.ValueOf(objEduHist.maxmarks_bio_cs_ec_oth) : null; 
                    
                    objEdu.Sem_1_Total_Marks__c = string.isNotBlank(objEduHist.max_marks_sem1) ? Decimal.ValueOf(objEduHist.max_marks_sem1) : null; 
                    objEdu.Sem_2_Total_Marks__c = string.isNotBlank(objEduHist.max_marks_sem2) ? Decimal.ValueOf(objEduHist.max_marks_sem2) : null; 
                    objEdu.Sem_3_Total_Marks__c = string.isNotBlank(objEduHist.max_marks_sem3) ? Decimal.ValueOf(objEduHist.max_marks_sem3) : null; 
                    objEdu.Sem_4_Total_Marks__c = string.isNotBlank(objEduHist.max_marks_sem4) ? Decimal.ValueOf(objEduHist.max_marks_sem4) : null; 
                    objEdu.Sem_5_Total_Marks__c = string.isNotBlank(objEduHist.max_marks_sem5) ? Decimal.ValueOf(objEduHist.max_marks_sem5) : null; 
                    objEdu.Sem_6_Total_Marks__c = string.isNotBlank(objEduHist.max_marks_sem6) ? Decimal.ValueOf(objEduHist.max_marks_sem6) : null; 
                    objEdu.Sem_7_Total_Marks__c = string.isNotBlank(objEduHist.max_marks_sem7) ? Decimal.ValueOf(objEduHist.max_marks_sem7) : null; 
                    objEdu.Sem_8_Total_Marks__c = string.isNotBlank(objEduHist.max_marks_sem8) ? Decimal.ValueOf(objEduHist.max_marks_sem8) : null; 
                    objEdu.Sem_9_Total_Marks__c = string.isNotBlank(objEduHist.max_marks_sem9) ? Decimal.ValueOf(objEduHist.max_marks_sem9) : null; 
                    objEdu.Sem_10_Total_Marks__c = string.isNotBlank(objEduHist.max_marks_sem10) ? Decimal.ValueOf(objEduHist.max_marks_sem10) : null; 
                    
                    objEdu.Sem_1_Marks_Obtained__c = string.isNotBlank(objEduHist.max_obtained_sem1) ? Decimal.ValueOf(objEduHist.max_obtained_sem1) : null; 
                    objEdu.Sem_2_Marks_Obtained__c = string.isNotBlank(objEduHist.max_obtained_sem2) ? Decimal.ValueOf(objEduHist.max_obtained_sem2) : null; 
                    objEdu.Sem_3_Marks_Obtained__c = string.isNotBlank(objEduHist.max_obtained_sem3) ? Decimal.ValueOf(objEduHist.max_obtained_sem3) : null; 
                    objEdu.Sem_4_Marks_Obtained__c = string.isNotBlank(objEduHist.max_obtained_sem4) ? Decimal.ValueOf(objEduHist.max_obtained_sem4) : null; 
                    objEdu.Sem_5_Marks_Obtained__c = string.isNotBlank(objEduHist.max_obtained_sem5) ? Decimal.ValueOf(objEduHist.max_obtained_sem5) : null; 
                    objEdu.Sem_6_Marks_Obtained__c = string.isNotBlank(objEduHist.max_obtained_sem6) ? Decimal.ValueOf(objEduHist.max_obtained_sem6) : null; 
                    objEdu.Sem_7_Marks_Obtained__c = string.isNotBlank(objEduHist.max_obtained_sem7) ? Decimal.ValueOf(objEduHist.max_obtained_sem7) : null; 
                    objEdu.Sem_8_Marks_Obtained__c = string.isNotBlank(objEduHist.max_obtained_sem8) ? Decimal.ValueOf(objEduHist.max_obtained_sem8) : null; 
                    objEdu.Sem_9_Marks_Obtained__c = string.isNotBlank(objEduHist.max_obtained_sem9) ? Decimal.ValueOf(objEduHist.max_obtained_sem9) : null; 
                    objEdu.Sem_10_Marks_Obtained__c = string.isNotBlank(objEduHist.max_obtained_sem10) ? Decimal.ValueOf(objEduHist.max_obtained_sem10) : null; 

                    
                    lst_hedEducationHist.add(objEdu);
                }
            }
            
            if(objData.Parent_Information != null) {
                for(Parent_Information objParentInfo : objData.Parent_Information)
                {                    
                    contact objParentContact = new contact();
                    objParentContact.Type_of_Relationship__c = string.isNotBlank(objParentInfo.relation_ship_type) ? string.ValueOf(objParentInfo.relation_ship_type) : null;
                    if(string.IsNotBlank(objParentContact.Type_of_Relationship__c))
                    {                        
                        objParentContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Parent).getRecordTypeId(); 
                        objParentContact.FirstName = string.isNotBlank(objParentInfo.First_Name) ? string.ValueOf(objParentInfo.first_name) : null;
                        objParentContact.LastName = string.isNotBlank(objParentInfo.Last_Name) ? string.ValueOf(objParentInfo.Last_Name) : null;
                        objParentContact.MiddleName = string.isNotBlank(objParentInfo.Middle_Name) ? string.ValueOf(objParentInfo.Middle_Name) : null;
                        objParentContact.MobilePhone = string.isNotBlank(objParentInfo.Mobile) ? string.ValueOf(objParentInfo.Mobile) : null;
                        objParentContact.Email = string.isNotBlank(objParentInfo.Personal_Email) ? string.ValueOf(objParentInfo.Personal_Email) : null;
                        objParentContact.ReportsToId = lst_ContactsToUpsert[0].Id;
                        objParentContact.AccountId = lst_ContactsToUpsert[0].AccountId;                         
                        objParentContact.Annual_Income__c = string.isNotBlank(objParentInfo.Annual_Income) ? decimal.Valueof(objParentInfo.Annual_Income) : 0;                                    
                        objParentContact.PAN_Number__c = string.isNotBlank(objParentInfo.PAN_Number) ? objParentInfo.PAN_Number : null;
                        if(string.isNotBlank(objParentInfo.Occupation))
                        {                            
                            if(objParentInfo.Occupation.Contains('Other|'))
                            {
                                string strReplace = objParentInfo.Occupation.replace('|', '@');                                
                                string[] strSplit = strReplace.split('@');                                 
                                string stringOther = strSplit[0];
                                objParentContact.Occupation__c = stringOther;
                                objParentContact.Occupation_Remarks__c = strSplit[1];                                
                            }
                            else
                            {
                                objParentContact.Occupation__c = string.isNotBlank(objParentInfo.Occupation) ? objParentInfo.Occupation : null;
                            }
                        }
                        
                        objParentContact.Parent_Contact_External_Id__c = lst_ContactsToUpsert[0].Id+'_'+objParentContact.Type_of_Relationship__c;                        
                        lst_ParentContact.add(objParentContact);
                    }
                }
            }
            system.debug('=====>>>>>objData.Student_Fee>>>>>'+objData.Student_Fee);
            if(objData.Student_Fee != null && map_Contact.size() == 0) 
            {
                
                for(Student_Fee objStudFee : objData.Student_Fee)
                {                    
                    decimal TutionFee = 0;
                    decimal TutionFeePaid = 0;
                    //system.debug('======>>>map_UniversityFee=='+map_UniversityFee);
                    // system.debug('======>>>objStudFee.Amount=='+objStudFee.Amount);
                    if(map_UniversityFee.size() > 0 && string.IsNotBlank(objStudFee.Amount))
                    {
                        Student_Fee__c objStudentFee = new Student_Fee__c();
                        if(map_UniversityFee.containsKey(program_str) && map_UniversityFee.get(program_str).Quota__c != null && map_UniversityFee.get(program_str).Amount__c > 0)
                        {
                            objStudentFee.Actual_Program_Fee__c = map_UniversityFee.get(program_str).Amount__c;
                            objStudentFee.Amount__c = map_UniversityFee.get(program_str).Amount__c;
                            /* if(string.IsNotBlank(objStudFee.Amount_Paid) && decimal.ValueOf(objStudFee.Amount_Paid) >= map_UniversityFee.get(program_str).Amount__c)
{
objStudentFee.Fee_Type__c = 'University Fee';
objStudentFee.Amount_Paid__c = map_UniversityFee.get(program_str).Amount__c;
TutionFee = decimal.ValueOf(objStudFee.Amount) -  map_UniversityFee.get(program_str).Amount__c;
TutionFeePaid =  decimal.ValueOf(objStudFee.Amount_Paid) - map_UniversityFee.get(program_str).Amount__c;

}
else if( string.IsNotBlank(objStudFee.Amount_Paid) && decimal.ValueOf(objStudFee.Amount_Paid) <= map_UniversityFee.get(program_str).Amount__c)
{
objStudentFee.Fee_Type__c = 'University Fee';
objStudentFee.Amount_Paid__c = decimal.ValueOf(objStudFee.Amount_Paid);    
TutionFeePaid = decimal.ValueOf(objStudFee.Amount_Paid);   
objStudentFee.Amount_Pending__c = map_UniversityFee.get(program_str).Amount__c -  decimal.ValueOf(objStudFee.Amount_Paid);
TutionFee = decimal.valueof(objStudFee.Amount) - (objStudentFee.Amount_Pending__c + decimal.ValueOf(objStudFee.Amount_Paid));
}
else */
                            if(string.IsNotBlank(objStudFee.Amount))
                            {
                                objStudentFee.Fee_Type__c = 'University Fee';                                   
                                objStudentFee.Amount_Pending__c = map_UniversityFee.get(program_str).Amount__c;   
                                TutionFee = decimal.valueof(objStudFee.Amount) - objStudentFee.Amount_Pending__c;
                            }
                        }    
                        
                        objStudentFee.Name = string.isNotBlank(objStudFee.Session) ? 'University Fee '+objStudFee.Session : null;  
                        objStudentFee.Contact__c = lst_ContactsToUpsert[0].Id;
                        objStudentFee.Session__c = objStudFee.Session;
                        objStudentFee.Received_Source__c = 'NPF';
                        objStudentFee.Academic_Fee__c = true;
                        if(objStudentFee.Actual_Program_Fee__c > 0 && string.IsNotBlank(objStudFee.Amount) && integer.ValueOf(objStudFee.Amount) > 0)
                        {
                            lst_StudentFee.add(objStudentFee);
                        }                            
                    }                    
                    else if (map_UniversityFee.size() == 0 && string.IsNotBlank(objStudFee.Amount) && decimal.Valueof(objStudFee.Amount) > 0)
                    {
                        Student_Fee__c objStudentFee = new Student_Fee__c();
                        objStudentFee.Name = string.isNotBlank(objStudFee.Session) ? 'University Fee '+objStudFee.Session : null;
                        objStudentFee.Fee_Type__c = 'University Fee';                        
                        objStudentFee.Actual_Program_Fee__c = 0;
                        objStudentFee.Amount__c = 0;
                        objStudentFee.Amount_Pending__c = 0;                         
                        objStudentFee.Academic_Fee__c = true;
                        objStudentFee.Contact__c = lst_ContactsToUpsert[0].Id;
                        objStudentFee.Session__c = objStudFee.Session;
                        objStudentFee.Received_Source__c = 'NPF';
                        lst_StudentFee.add(objStudentFee);
                    }
                    
                    if(TutionFee > 0 || map_UniversityFee.size() == 0)
                    {                           
                        
                        Student_Fee__c objStudentFee = new Student_Fee__c();
                        objStudentFee.Name = string.isNotBlank(objStudFee.Session) ? 'Tuition Fee '+objStudFee.Session : null; 
                        objStudentFee.Fee_Type__c = 'Tuition Fee';
                        objStudentFee.Seat_Blocking_Payment_Option__c = string.isNotBlank(objStudFee.Seat_Blocking_Payment_Option) ? objStudFee.Seat_Blocking_Payment_Option : null;
                        objStudentFee.Fee_Category__c = string.isNotBlank(objStudFee.Fee_Category) ? objStudFee.Fee_Category : null;
                        //  objStudentFee.Actual_Program_Fee__c = string.isNotBlank(objStudFee.Actual_Program_Fee) ? decimal.ValueOf(objStudFee.Actual_Program_Fee) : 0;
                        objStudentFee.Scholarship_Category__c = string.isNotBlank(objStudFee.Scholarship_Category) ?  objStudFee.Scholarship_Category : null;
                        objStudentFee.Premium__c = string.isNotBlank(objStudFee.Premium) ?  decimal.ValueOf(objStudFee.Premium) : 0;
                        objStudentFee.Concession__c = string.isNotBlank(objStudFee.Concession) ?  decimal.ValueOf(objStudFee.Concession) : 0;
                        objStudentFee.Scholarship__c = string.isNotBlank(objStudFee.Scholarship) ?  decimal.ValueOf(objStudFee.Scholarship) : 0;
                        
                        if(TutionFee > 0)
                        {
                            objStudentFee.Amount__c = TutionFee;
                            //  objStudentFee.Amount_Paid__c = TutionFeePaid;
                            objStudentFee.Amount_Pending__c = TutionFee;//string.isNotBlank(objStudFee.Amount_Pending) ?  decimal.ValueOf(objStudFee.Amount_Pending) : 0;
                            //objStudentFee.Amount_Pending__c =  TutionFeePaid - objStudentFee.Amount_Pending__c;
                            /* IF(objStudentFee.Amount_Pending__c < 0)
{
objStudentFee.Amount_Pending__c = objStudentFee.Amount_Pending__c * -1;
objStudentFee.Amount_Pending__c = objStudentFee.Amount_Pending__c - TutionFeePaid;
}*/
                            system.debug('==objStudentFee.Amount_Pending__c==>>>'+objStudentFee.Amount_Pending__c);
                            objStudentFee.Actual_Program_Fee__c = TutionFee +  objStudentFee.Concession__c + objStudentFee.Scholarship__c + objStudentFee.Premium__c;                           
                        }                        
                        else
                        {        
                            system.debug('==Else==>>>');
                            //objStudentFee.Actual_Program_Fee__c = TutionFee +  objStudentFee.Concession__c + objStudentFee.Scholarship__c;
                            objStudentFee.Amount__c = string.isNotBlank(objStudFee.Amount) ?  decimal.ValueOf(objStudFee.Amount) : 0;
                            // objStudentFee.Amount_Paid__c = string.isNotBlank(objStudFee.Amount_Paid) ?  decimal.ValueOf(objStudFee.Amount_Paid) : 0;
                            objStudentFee.Actual_Program_Fee__c = string.isNotBlank(objStudFee.Actual_Program_Fee) ? decimal.ValueOf(objStudFee.Actual_Program_Fee) : 0;
                            
                            objStudentFee.Amount_Pending__c = objStudentFee.Amount__c;//string.isNotBlank(objStudFee.Amount_Pending) ?  decimal.ValueOf(objStudFee.Amount_Pending) : 0;
                        }
                        
                        objStudentFee.Academic_Fee__c = true;
                        objStudentFee.Contact__c = lst_ContactsToUpsert[0].Id;
                        objStudentFee.Session__c = objStudFee.Session;
                        objStudentFee.Received_Source__c = 'NPF';
                        
                        /* if(string.IsNotBlank(objStudFee.Due_Date))
{
// objStudentFee.Due_Date__c = date.parse(objStudFee.Due_Date);
}*/
                        if(objStudentFee.Actual_Program_Fee__c > 0 &&  objStudentFee.Amount__c > 0)
                        {
                            lst_StudentFee.add(objStudentFee);
                            system.debug('=====Inside Loop===>'+lst_StudentFee);
                        }
                    }
                }
            }
            
            system.debug('=====lst_StudentFee===>'+lst_StudentFee);
            /* if(objData.Student_Payment != null && map_Contact.size() == 0) {
decimal total_Amount=0;
for(Student_Payment objStudPay : objData.Student_Payment)
{
Student_Payment__c objStudentPay = new Student_Payment__c();
objStudentPay.Contact__c = lst_ContactsToUpsert[0].Id;
if(string.isNotBlank(objStudPay.online_payment_date)) 
{                       
DateTime dt = DateTime.valueOf(objStudPay.online_payment_date);
objStudentPay.Payment_Date_Time__c =  dt; 
objStudentPay.Mode_of_Payment__c = 'Online';
}
if(string.isNotBlank(objStudPay.online_transaction_id) )  objStudentPay.Transaction_ID__c = string.valueof(objStudPay.online_transaction_id);       
if(string.isNotBlank(objStudPay.online_order_id)) objStudentPay.Order_ID__c = string.valueof(objStudPay.online_order_id);   
if(string.isNotBlank(objStudPay.offline_payment_date)){
objStudentPay.Payment_Date_Time__c =  DateTime.valueof(objStudPay.offline_payment_date);    
objStudentPay.Mode_of_Payment__c = 'Offline';
}
if(string.isNotBlank(objStudPay.offline_transaction_id))  objStudentPay.Transaction_ID__c =  string.valueof(objStudPay.offline_transaction_id);     
objStudentPay.Offline_Receipt_Number__c = string.isNotBlank(objStudPay.offline_receipt_number) ? string.valueof(objStudPay.offline_receipt_number) : null;      
decimal recordAmount = string.isNotBlank(objStudPay.Amount) ? decimal.valueof(objStudPay.Amount) : 0;
total_Amount = total_Amount+recordAmount;
objStudentPay.Amount__c = total_Amount; 
objStudentPay.Payment_Status__c = 'Success';
if(objStudentPay.Mode_of_Payment__c == 'Online')  objStudentPay.Payment_Gateway__c = 'Razorpay';
lst_StudentPay.add(objStudentPay);
}
}*/
            
        }
        if(lst_ParentContact.size() > 0) 
        {
            try
            {
                List<Database.upsertResult> srList = Database.Upsert(lst_ParentContact,Contact.Parent_Contact_External_Id__c,false); 
                for (integer i=0; i < srList.size(); i++) {
                    if (srList[i].isSuccess()) {
                        objResp.status = 'Success';
                    }
                    else if (!srList[i].isSuccess())
                    {
                        objResp.status = 'Failed';
                        objResp.Errormessage = string.valueOf(srList[i].getErrors()[0].getMessage());
                        objDebug.Status__c = 'Failure';
                        objDebug.Error_Message__c = objResp.Errormessage;
                        update objDebug;
                        Database.rollback( sp );
                        return objResp;
                    }
                }  
            }
            catch(exception ex)
            {
                objResp.status = 'Failed';
                objResp.Errormessage = string.valueOf(ex.getMessage() +' '+ex.getStackTraceString() );
                objDebug.Status__c = 'Failure';
                objDebug.Error_Message__c = objResp.Errormessage;
                
                Database.rollback( sp );
                update objDebug;
                return objResp;
            }
            // system.debug('==== Errormessage==='+ objResp.Errormessage);
        }
        
        
        if(lst_hedEducationHist.size() > 0) 
        {
            try
            {
                Insert lst_hedEducationHist;
            }
            catch(exception ex)
            {
                objResp.status = 'Failed';
                objResp.Errormessage = string.valueOf(ex.getMessage()+' '+ex.getStackTraceString());
                objDebug.Status__c = 'Failure';
                objDebug.Error_Message__c = objResp.Errormessage;
                update objDebug;
                Database.rollback( sp );
                return objResp;
            }                
        } 
        if(lst_StudentFee.size() > 0)
        {
            try
            {
                Insert lst_StudentFee;
            }
            catch(exception ex)
            {
                objResp.status = 'Failed';
                objResp.Errormessage = string.valueOf(ex.getMessage() + ' ' +ex.getStackTraceString());
                objDebug.Status__c = 'Failure';
                objDebug.Error_Message__c = objResp.Errormessage;
                update objDebug;
                Database.rollback( sp );
                return objResp;
            }
        }
        
        /*  if(lst_StudentPay.size() > 0)
{
try
{
//  Insert lst_StudentPay;
}
catch(exception ex)
{
system.debug('=====>>>>'+ex.getMessage());
objResp.status = 'Failed';
objResp.Errormessage = string.valueOf(ex.getMessage()+' '+ex.getStackTraceString());
objDebug.Status__c = 'Failure';
objDebug.Error_Message__c = objResp.Errormessage;
update objDebug;
Database.rollback( sp );
return objResp;
}            
}*/
        /*   List<Student_Fee_Payment__c> lst_StudentFeePay = new List<Student_Fee_Payment__c>();
for(Student_Fee__c objStudent : lst_StudentFee)
{
Student_Fee_Payment__c objFeePay = new Student_Fee_Payment__c();
if(objStudent.Amount_Paid__c > 0 || map_UniversityFee.size() == 0) {
if(objStudent.Amount_Paid__c > 0) objFeePay.Amount__c = objStudent.Amount_Paid__c;
else objFeePay.Amount__c = 0;
objFeePay.Student_Fee__c = objStudent.Id;
objFeePay.Student_Payment__c = lst_StudentPay[0].Id;
objFeePay.Mode_of_Payment__c = lst_StudentPay[0].Mode_of_Payment__c;
objFeePay.Transaction_Date_Time__c = lst_StudentPay[0].Payment_Date_Time__c;   
objFeePay.Line_Item_Payment_Status__c = 'Success';
lst_StudentFeePay.add(objFeePay);
}
}
if(lst_StudentFeePay.size() > 0)
{
try
{
// Utility.NPF_API_To_Stop_Rollup = true;
// Insert lst_StudentFeePay;
}
catch(exception ex)
{
objResp.status = 'Failed';
objResp.Errormessage = string.valueOf(ex.getMessage()+' '+ex.getStackTraceString());
objDebug.Status__c = 'Failure';
objDebug.Error_Message__c = objResp.Errormessage;
update objDebug;
Database.rollback(sp);
return objResp;
}                
}*/
        
        return objResp;
    }
    
    
    global class responseApplicant
    {
        public List<ApplicantDetails> Applicantdetails;
    }
    
    global class ApplicantDetails
    {
        public List<Education_History> Education_History;
        public List<Parent_Information> Parent_Information;
        public List<Student_Fee> Student_Fee;
        public List<Student_Payment> Student_Payment;
        
        public String Category; //Karnataka
        public String School;   //School of Computer Science and Engineering
        public String Program;  //B.Tech. Computer Science and Engineering
        public String Admission_Session;    //2022
        public String Applying_For_Reva_CET;    //Yes
        public String Reva_CET_Date;    //30 April 2022
        public String Exam_Type;    //Centre Based
        public String First_Name;   //Rajesh
        public String Middle_Name;  //N
        public String Last_Name;    //M
        public String Personal_Email;   //nf@gmail.com
        public String Mobile;   //7777777777
        public String Martial_Status;   //Single
        public String Birthdate;    //25/10/2000
        public String Gender;   //Male
        public String PH_Handicapped;   //false
        public String Nationality;  //Indian
        public String Aadhaar_Card_Number;  //124535461254
        public String Nationality_Type; //
        public String Are_You_A_Reva_Student;   //No
        public String Religion; //Hindu
        public String Caste_Category;   //OBC
        public String Blood_Group;  //B+
        public String Passport_Number;  //12445878
        public String Passport_Issued_Country;  //India
        public String Passport_Place_Of_Issue;  //Banagalore
        public String Passport_Date_of_Issue;   //25/10/2016
        public String Passport_Date_of_Expiry;  //25/10/2032
        public String correspondence_country;   //India
        public String correspondence_state; //Karnataka
        public String correspondence_district;  //Bangalore Urben
        public String correspondence_city;  //bangalore
        public String correspondence_address_line_1;    //Jayanagar
        public String correspondence_address_line_2;    //Jayanagar
        public String correspondence_pincode;   //560011
        public String Is_perm_add_same_as_commu_add;    //true
        public String permanent_country;    //India
        public String permanent_state;  //Karnataka
        public String permanent_district;   //Banagalore north
        public String permanent_city;   //Bangalore
        public String permanent_address_line_1; //Jayanagar
        public String permanent_address_line_2; //
        public String permanent_pincode;    //560011
        public String Referral_Code;    //
        public String Transporatation_Facility; //Yes
        public String Hostel_Facility;  //No
        public String Application_Submission_Date;  //25/04/2022
        public String Quota;    //Government Quota
        public String Enrollment_Type;  //Regular Entry
        public String ApplicationNumber;    //1BY0124545
        public String I_Agree;  //Yes
        public String file_passport_size_photo; //     
        
        public String Admission_Mode;
        public String Cet_Comedk_TAT_No;
        public String Cet_Comedk_Rank;
        public String Addmission_Order_No;
        public String Addmission_Order_Date;
        public String Claimed_Category;
        public String Alloted_Category;
        public String Sports_Person;
        public String Defence_Ex_Serviceman;
        public String State_of_Domicile;
        public String Mother_Tongue;
        public String Alternate_Phone_Number;
        public String Belongs_To;
        public String Anti_Ragging_undertaking_Reference_No;
        public String Local_Guardian_Address;
        public String Local_Guardian_City;
        public String Local_Guardian_District;
        public String Local_Guardian_State;
        public String Local_Guardian_Country;
        public String Local_Guardian_Pin_Code;
        
        public String Caste;        
        public String file_study_certificate;
        public String file_transfer_certificate;
        public String file_migration_certificate;
        public String file_caste_certificate;
        public String file_income_certificate;
        public String file_rural_certificate;
        public String file_kannada_medium_certificate;
        public String file_copy_of_hydr_kar_certificate;
        public String file_defence_karnataka_capf_others;
        public String file_copy_of_aadhar_card;      
        
        
    }
    
    global class  Education_History {
        public String Type_of_course;       
        public String Institution_Name; //REVA
        public String City; //Bangalore
        public String State;    //Karnataka
        public String Board_OR_University;  //REVA
        public String Year_of_Passing;  //2016
        public String Max_Marks;    //600
        public String Marks_Obtained;   //555
        public String Percentage;   //80
        public String Stream;   //
        public String file_document;    //https://reva-university.nopaperforms.com//uploads//student//document//97//2162//2022//01//31//61f7830c4b745497654803_Image.jpg
        public string PG_Result_Status;
        public string Course;
        
        public string Country;
        public string Second_Language_Studied;
        public string Physics;
        public string Chemistry;
        public string Maths;
        public string P_M_C_B_CS_EC_Perc;
        public string Others;
        public string Register_No;
        
        public string district;
        public string marking_scheme;
        public string Other_Marking_Scheme;
        public string marks_obtained_first_lang;
        public string marks_obtained_total;
        public string maxmarks_physics;
        public string maxmarks_maths;
        public string maxmarks_chemistry;
        public string maxmarks_first_lang;
        public string maxmarks_second_lang;
        public string maxmarks_bio_cs_ec_oth;
        public string max_marks_sem1;
        public string max_marks_sem2;
        public string max_marks_sem3;
        public string max_marks_sem4;
        public string max_marks_sem5;
        public string max_marks_sem6;
        public string max_marks_sem7;
        public string max_marks_sem8;
        public string max_marks_sem9;
        public string max_marks_sem10;
        public string max_obtained_sem1;
        public string max_obtained_sem2;
        public string max_obtained_sem3;
        public string max_obtained_sem4;
        public string max_obtained_sem5;
        public string max_obtained_sem6;
        public string max_obtained_sem7;
        public string max_obtained_sem8;
        public string max_obtained_sem9;
        public string max_obtained_sem10;
    }
    global class Parent_Information {
        public String First_Name;   //Ram
        public String Middle_Name;  //M
        public String Last_Name;    //Prasad
        public String Mobile;   //8888888888
        public String Occupation;   //Software Engineer
        public String Personal_Email;   //EM@gmail.com
        public String Annual_Income;    //1500000
        public String PAN_Number;   //BRFDE1254M
        public String relation_ship_type;   //Father
    }
    global class Student_Fee {
        public String Seat_Blocking_Payment_Option; //
        public String Fee_Category; //
        public String Actual_Program_Fee;   //
        public String Scholarship_Category; //
        public String Premium;  //
        public String Concession;   //
        public String Scholarship;  //
        public String Amount;   //
        public String Amount_Paid;  //
        public String Amount_Pending;   //
        public String Session;
        public String Due_Date;
    }
    global class Student_Payment {
        public String online_payment_date;   
        public String online_transaction_id;     
        public String online_order_id;   
        public String offline_payment_date;  
        public String offline_transaction_id;    
        public String offline_receipt_number;    
        public String Amount;  
        
        public String fee_paid_at_university_rs;
        public String receipt_challan_no;
        public String receipt_date;
        public String paid_at_kea;
        public String kea_challan_no_refer_no;
        public String paid_date;        
    }
    
    global  class ResponseWrapper
    {
        public string status;        
        public string Errormessage;
    }
    
    public static map<String,string> getPickListValuesIntoList(){
        map<String,string> pickListValuesList= new map<String,string>();
        Schema.DescribeFieldResult fieldResult = Contact.City__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.put(pickListVal.getValue(),pickListVal.getValue());
        }     
        return pickListValuesList;
    }
}