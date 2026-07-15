@isTest
public class NPF_ApplicationAPI_Test 
{
    static testMethod void testParse() {
        
        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        insert objProgPlan;
        
        University_Fee_Masters__c objUniv = new University_Fee_Masters__c();
        objUniv.Academic_Program__c = objAccount.Id;
        objUniv.Amount__c = 20000;         
        objUniv.Quota__c = 'ComedK';
        Insert objUniv;
       // system.debug('==objUniv===>>>>'+objUniv);
        
        String json =		'{'+
            '  "ApplicantDetails": ['+
            '    {'+
            '      "Category": "Indian (SAARC)",'+
            '      "School": "",'+
            '      "Program": "'+objAccount.Id+'",'+
            '      "Admission_Session": "2022",'+
            '      "Applying_For_Reva_CET": "",'+
            '      "Reva_CET_Date": "30 April 2022",'+
            '      "Exam_Type": "",'+
            '      "First_Name": "TANYA",'+
            '      "Middle_Name": "",'+
            '      "Last_Name": "aggarwal",'+
            '      "Personal_Email": "t9254_13718051@reva.edu.in",'+
            '      "Mobile": "8888888888",'+
            '      "Martial_Status": "Single",'+
            '      "Birthdate": "24/12/2001",'+
            '      "Gender": "Female",'+
            '      "PH_Handicapped": "false",'+
            '      "Nationality": "Indian",'+
            '      "Aadhaar_Card_Number": "241102378288",'+
            '      "Nationality_Type": "Indian National",'+
            '      "Are_You_A_Reva_Student": "No",'+
            '      "Religion": "HINDUISM",'+
            '      "Caste_Category": "General Merit",'+
            '      "Blood_Group": "B+",'+
            '      "Passport_Number": "",'+
            '      "Passport_Issued_Country": "",'+
            '      "Passport_Place_Of_Issue": "",'+
            '      "Passport_Date_of_Issue": "",'+
            '      "Passport_Date_of_Expiry": "",'+
            '      "correspondence_country": "",'+
            '      "correspondence_state": "Delhi",'+
            '      "correspondence_district": "North West Delhi",'+
            '      "correspondence_city": "North West Delhi",'+
            '      "correspondence_address_line_1": "C-17 BUDH VIHAR PHASE-1",'+
            '      "correspondence_address_line_2": "",'+
            '      "correspondence_pincode": "110086",'+
            '      "Is_perm_add_same_as_commu_add": "Yes",'+
            '      "permanent_country": "India",'+
            '      "permanent_state": "Delhi",'+
            '      "permanent_district": "North West Delhi",'+
            '      "permanent_city": "North West Delhi",'+
            '      "permanent_address_line_1": "C-17 BUDH VIHAR PHASE-1",'+
            '      "permanent_address_line_2": "",'+
            '      "permanent_pincode": "110086",'+
            '      "Referral_Code": "",'+
            '      "Transporatation_Facility": "No",'+
            '      "Hostel_Facility": "Yes",'+
            '      "Application_Submission_Date": "08/06/2022",'+
            '      "Quota": "Management Quota",'+
            '      "Enrollment_Type": "REGULAR ENTRY",'+
            '      "ApplicationNumber": "22130621090",'+
            '      "I_Agree": "Yes",'+
            '      "file_passport_size_photo": "https://97-s16.nopaperforms.in/uploads/student/document/97/2162/2022/06/08/62a05f49b214a668431231_3AD69047C1A44773B8C5A5015B7F3E81.JPEG",'+
            '      "Admission_Mode": "ComedK",'+
            '      "Cet_Comedk_TAT_No": "",'+
            '      "Cet_Comedk_Rank": "",'+
            '      "Addmission_Order_No": "",'+
            '      "Addmission_Order_Date": "01/04/2022",'+
            '      "Claimed_Category": "",'+
            '      "Alloted_Category": "",'+
            '      "Sports_Person": "",'+
            '      "Defence_Ex_Serviceman": "",'+
            '      "State_of_Domicile": "",'+
            '      "Mother_Tongue": "",'+
            '      "Alternate_Phone_Number": "",'+
            '      "Belongs_To": "",'+
            '      "Anti_Ragging_undertaking_Reference_No": "",'+
            '      "Local_Guardian_Address": "",'+
            '      "Local_Guardian_City": "",'+
            '      "Local_Guardian_District": "",'+
            '      "Local_Guardian_State": "",'+
            '      "Local_Guardian_Country": "",'+
            '      "Local_Guardian_Pin_Code": "",'+
            '      "Education_History": ['+
            '        {'+
            '          "Institution_Name": "PRESTIGE CONVENT SCHOOL",'+
            '          "City": "New Delhi",'+
            '          "State": "Delhi",'+
            '          "Board_OR_University": "Central Board Of Secondary Education (CBSE)",'+
            '          "Year_of_Passing": "24/12/2001",'+
            '          "Max_Marks": "500",'+
            '          "Marks_Obtained": "465.5",'+
            '          "Percentage": "93.1",'+
            '          "Stream": "",'+
            '          "Course": "",'+
            '          "Type_of_course": "10th",'+
            '          "PG_Result_Status": "",'+
            '          "file_document": "",'+
            '          "Country": "",'+
            '          "Second_Language_Studied": "",'+
            '          "Physics": "",'+
            '          "Chemistry": "",'+
            '          "Maths": "",'+
            '          "P_M_C_B_CS_EC_Perc": "",'+
            '          "Others": "",'+
            '          "Register_No": ""'+
            '        },'+
            '        {'+
            '          "Institution_Name": "PRESTIGE CONVENT SCHOOL",'+
            '          "City": "New Delhi",'+
            '          "State": "Delhi",'+
            '          "Board_OR_University": "Central Board Of Secondary Education (CBSE)",'+
            '          "Year_of_Passing": "24/12/2001",'+
            '          "Max_Marks": "600",'+
            '          "Marks_Obtained": "535",'+
            '          "Percentage": "89.1",'+
            '          "Stream": "Commerce",'+
            '          "Course": "",'+
            '          "Type_of_course": "12th",'+
            '          "PG_Result_Status": "",'+
            '          "file_document": "",'+
            '          "Country": "",'+
            '          "Second_Language_Studied": "",'+
            '          "Physics": "",'+
            '          "Chemistry": "",'+
            '          "Maths": "",'+
            '          "P_M_C_B_CS_EC_Perc": "",'+
            '          "Others": "",'+
            '          "Register_No": ""'+
            '        }'+
            '      ],'+
            '      "Parent_Information": ['+
            '        {'+
            '          "First_Name": "rakesh",'+
            '          "Middle_Name": "",'+
            '          "Last_Name": "aggarwal",'+
            '          "Mobile": "8888888888",'+
            '          "Occupation": "Other|Business",'+
            '          "Personal_Email": "t9058_13718051@yopmail.com",'+
            '          "Annual_Income": "500000",'+
            '          "PAN_Number": "AAEPA8128R",'+
            '          "relation_ship_type": "Father"'+
            '        },'+
            '        {'+
            '          "First_Name": "dolly",'+
            '          "Middle_Name": "",'+
            '          "Last_Name": "aggarwal",'+
            '          "Mobile": "8888888888",'+
            '          "Occupation": "Other|Home Maker",'+
            '          "Personal_Email": "t6804_13718051@yopmail.com",'+
            '          "Annual_Income": "",'+
            '          "PAN_Number": "",'+
            '          "relation_ship_type": "Mother"'+
            '        }'+
            '      ],'+
            '      "Student_Fee": ['+
            '        {'+
            '          "Session": "1st Year",'+
            '          "Seat_Blocking_Payment_Option": "",'+
            '          "Fee_Category": "",'+
            '          "Actual_Program_Fee": "150000",'+
            '          "Scholarship_Category": "",'+
            '          "Premium": "",'+
            '          "Concession": "5000",'+
            '          "Scholarship": "",'+
            '          "Amount": "125000",'+
            '          "Amount_Paid": "100000",'+
            '          "Amount_Pending": "45000",'+
            '          "Due_Date": ""'+
            '        },'+
            '        {'+
            '          "Session": "2nd Year",'+
            '          "Seat_Blocking_Payment_Option": "",'+
            '          "Fee_Category": "",'+
            '          "Actual_Program_Fee": "150000",'+
            '          "Scholarship_Category": "",'+
            '          "Premium": "",'+
            '          "Concession": "5000",'+
            '          "Scholarship": "",'+
            '          "Amount": "145000",'+
            '          "Amount_Paid": "15000",'+
            '          "Amount_Pending": "130000",'+
            '          "Due_Date": ""'+
            '        }'+
            '      ],'+
            '      "Student_Payment": ['+
            '        {'+
            '          "online_payment_date": "2022-06-06 10:00:00",'+
            '          "online_transaction_id": "TEST13",'+
            '          "online_order_id": "TEST1234",'+
            '          "offline_payment_date": "2022-06-06 10:00:00",'+
            '          "offline_transaction_id": "",'+
            '          "offline_receipt_number": "",'+
            '          "Amount": "115000"'+
            '        }'+
            '      ]'+
            '    }'+
            '  ]'+
            '}';
        
        
        
        
        // String myJSON = JSON.serialize(json);     
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/CreateApplication';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);
        
        RestContext.request = request;
        
        Test.startTest();
        NPF_ApplicationAPI.CreateApplication();
        Test.stopTest();
        //System.assert(obj != null);
        
    }  
      static testMethod void testParseKEA() {
        
        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        insert objProgPlan;
        
        University_Fee_Masters__c objUniv = new University_Fee_Masters__c();
        objUniv.Academic_Program__c = objAccount.Id;
        objUniv.Amount__c = 20000;         
        objUniv.Quota__c = 'ComedK';
        Insert objUniv;
       // system.debug('==objUniv===>>>>'+objUniv);
        
        String json =		'{'+
            '  "ApplicantDetails": ['+
            '    {'+
            '      "Category": "Indian (SAARC)",'+
            '      "School": "",'+
            '      "Program": "'+objAccount.Id+'",'+
            '      "Admission_Session": "2022",'+
            '      "Applying_For_Reva_CET": "",'+
            '      "Reva_CET_Date": "30 April 2022",'+
            '      "Exam_Type": "",'+
            '      "First_Name": "TANYA",'+
            '      "Middle_Name": "",'+
            '      "Last_Name": "aggarwal",'+
            '      "Personal_Email": "t9254_13718051@reva.edu.in",'+
            '      "Mobile": "8888888888",'+
            '      "Martial_Status": "Single",'+
            '      "Birthdate": "24/12/2001",'+
            '      "Gender": "Female",'+
            '      "PH_Handicapped": "false",'+
            '      "Nationality": "Indian",'+
            '      "Aadhaar_Card_Number": "241102378288",'+
            '      "Nationality_Type": "Indian National",'+
            '      "Are_You_A_Reva_Student": "No",'+
            '      "Religion": "HINDUISM",'+
            '      "Caste_Category": "General Merit",'+
            '      "Blood_Group": "B+",'+
            '      "Passport_Number": "",'+
            '      "Passport_Issued_Country": "",'+
            '      "Passport_Place_Of_Issue": "",'+
            '      "Passport_Date_of_Issue": "",'+
            '      "Passport_Date_of_Expiry": "",'+
            '      "correspondence_country": "",'+
            '      "correspondence_state": "Delhi",'+
            '      "correspondence_district": "North West Delhi",'+
            '      "correspondence_city": "North West Delhi",'+
            '      "correspondence_address_line_1": "C-17 BUDH VIHAR PHASE-1",'+
            '      "correspondence_address_line_2": "",'+
            '      "correspondence_pincode": "110086",'+
            '      "Is_perm_add_same_as_commu_add": "Yes",'+
            '      "permanent_country": "India",'+
            '      "permanent_state": "Delhi",'+
            '      "permanent_district": "North West Delhi",'+
            '      "permanent_city": "North West Delhi",'+
            '      "permanent_address_line_1": "C-17 BUDH VIHAR PHASE-1",'+
            '      "permanent_address_line_2": "",'+
            '      "permanent_pincode": "110086",'+
            '      "Referral_Code": "",'+
            '      "Transporatation_Facility": "No",'+
            '      "Hostel_Facility": "Yes",'+
            '      "Application_Submission_Date": "08/06/2022",'+
            '      "Quota": "Management Quota",'+
            '      "Enrollment_Type": "REGULAR ENTRY",'+
            '      "ApplicationNumber": "22130621090",'+
            '      "I_Agree": "Yes",'+
            '      "file_passport_size_photo": "https://97-s16.nopaperforms.in/uploads/student/document/97/2162/2022/06/08/62a05f49b214a668431231_3AD69047C1A44773B8C5A5015B7F3E81.JPEG",'+
            '      "Admission_Mode": "KEA",'+
            '      "Cet_Comedk_TAT_No": "",'+
            '      "Cet_Comedk_Rank": "",'+
            '      "Addmission_Order_No": "",'+
            '      "Addmission_Order_Date": "01/04/2022",'+
            '      "Claimed_Category": "",'+
            '      "Alloted_Category": "",'+
            '      "Sports_Person": "",'+
            '      "Defence_Ex_Serviceman": "",'+
            '      "State_of_Domicile": "",'+
            '      "Mother_Tongue": "",'+
            '      "Alternate_Phone_Number": "",'+
            '      "Belongs_To": "",'+
            '      "Anti_Ragging_undertaking_Reference_No": "",'+
            '      "Local_Guardian_Address": "",'+
            '      "Local_Guardian_City": "",'+
            '      "Local_Guardian_District": "",'+
            '      "Local_Guardian_State": "",'+
            '      "Local_Guardian_Country": "",'+
            '      "Local_Guardian_Pin_Code": "",'+
            '      "Education_History": ['+
            '        {'+
            '          "Institution_Name": "PRESTIGE CONVENT SCHOOL",'+
            '          "City": "New Delhi",'+
            '          "State": "Delhi",'+
            '          "Board_OR_University": "Central Board Of Secondary Education (CBSE)",'+
            '          "Year_of_Passing": "24/12/2001",'+
            '          "Max_Marks": "500",'+
            '          "Marks_Obtained": "465.5",'+
            '          "Percentage": "93.1",'+
            '          "Stream": "",'+
            '          "Course": "",'+
            '          "Type_of_course": "10th",'+
            '          "PG_Result_Status": "",'+
            '          "file_document": "",'+
            '          "Country": "",'+
            '          "Second_Language_Studied": "",'+
            '          "Physics": "",'+
            '          "Chemistry": "",'+
            '          "Maths": "",'+
            '          "P_M_C_B_CS_EC_Perc": "",'+
            '          "Others": "",'+
            '          "Register_No": ""'+
            '        },'+
            '        {'+
            '          "Institution_Name": "PRESTIGE CONVENT SCHOOL",'+
            '          "City": "New Delhi",'+
            '          "State": "Delhi",'+
            '          "Board_OR_University": "Central Board Of Secondary Education (CBSE)",'+
            '          "Year_of_Passing": "24/12/2001",'+
            '          "Max_Marks": "600",'+
            '          "Marks_Obtained": "535",'+
            '          "Percentage": "89.1",'+
            '          "Stream": "Commerce",'+
            '          "Course": "",'+
            '          "Type_of_course": "12th",'+
            '          "PG_Result_Status": "",'+
            '          "file_document": "",'+
            '          "Country": "",'+
            '          "Second_Language_Studied": "",'+
            '          "Physics": "",'+
            '          "Chemistry": "",'+
            '          "Maths": "",'+
            '          "P_M_C_B_CS_EC_Perc": "",'+
            '          "Others": "",'+
            '          "Register_No": ""'+
            '        }'+
            '      ],'+
            '      "Parent_Information": ['+
            '        {'+
            '          "First_Name": "rakesh",'+
            '          "Middle_Name": "",'+
            '          "Last_Name": "aggarwal",'+
            '          "Mobile": "8888888888",'+
            '          "Occupation": "Other|Business",'+
            '          "Personal_Email": "t9058_13718051@yopmail.com",'+
            '          "Annual_Income": "500000",'+
            '          "PAN_Number": "AAEPA8128R",'+
            '          "relation_ship_type": "Father"'+
            '        },'+
            '        {'+
            '          "First_Name": "dolly",'+
            '          "Middle_Name": "",'+
            '          "Last_Name": "aggarwal",'+
            '          "Mobile": "8888888888",'+
            '          "Occupation": "Other|Home Maker",'+
            '          "Personal_Email": "t6804_13718051@yopmail.com",'+
            '          "Annual_Income": "",'+
            '          "PAN_Number": "",'+
            '          "relation_ship_type": "Mother"'+
            '        }'+
            '      ],'+
            '      "Student_Fee": ['+
            '        {'+
            '          "Session": "1st Year",'+
            '          "Seat_Blocking_Payment_Option": "",'+
            '          "Fee_Category": "",'+
            '          "Actual_Program_Fee": "150000",'+
            '          "Scholarship_Category": "",'+
            '          "Premium": "",'+
            '          "Concession": "5000",'+
            '          "Scholarship": "",'+
            '          "Amount": "125000",'+
            '          "Amount_Paid": "100000",'+
            '          "Amount_Pending": "45000",'+
            '          "Due_Date": ""'+
            '        },'+
            '        {'+
            '          "Session": "2nd Year",'+
            '          "Seat_Blocking_Payment_Option": "",'+
            '          "Fee_Category": "",'+
            '          "Actual_Program_Fee": "150000",'+
            '          "Scholarship_Category": "",'+
            '          "Premium": "",'+
            '          "Concession": "5000",'+
            '          "Scholarship": "",'+
            '          "Amount": "145000",'+
            '          "Amount_Paid": "15000",'+
            '          "Amount_Pending": "130000",'+
            '          "Due_Date": ""'+
            '        }'+
            '      ],'+
            '      "Student_Payment": ['+
            '        {'+
            '          "online_payment_date": "2022-06-06 10:00:00",'+
            '          "online_transaction_id": "TEST13",'+
            '          "online_order_id": "TEST1234",'+
            '          "offline_payment_date": "2022-06-06 10:00:00",'+
            '          "offline_transaction_id": "",'+
            '          "offline_receipt_number": "",'+
            '          "Amount": "115000"'+
            '        }'+
            '      ]'+
            '    }'+
            '  ]'+
            '}';
        
        
        
        
        // String myJSON = JSON.serialize(json);     
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/CreateApplication';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);
        
        RestContext.request = request;
        
        Test.startTest();
        NPF_ApplicationAPI.CreateApplication();
        Test.stopTest();
        //System.assert(obj != null);
        
    }  
     static testMethod void WithOutFeeDetails() {
        
        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        insert objProgPlan;
        
        University_Fee_Masters__c objUniv = new University_Fee_Masters__c();
        objUniv.Academic_Program__c = objAccount.Id;
        objUniv.Amount__c = 20000;         
        objUniv.Quota__c = 'ComedK';
        Insert objUniv;
        system.debug('==objUniv===>>>>'+objUniv);
        
        String json =		'{'+
            '  "ApplicantDetails": ['+
            '    {'+
            '      "Category": "Indian (SAARC)",'+
            '      "School": "",'+
            '      "Program": "'+objAccount.Id+'",'+
            '      "Admission_Session": "2022",'+
            '      "Applying_For_Reva_CET": "",'+
            '      "Reva_CET_Date": "30 April 2022",'+
            '      "Exam_Type": "",'+
            '      "First_Name": "TANYA",'+
            '      "Middle_Name": "",'+
            '      "Last_Name": "aggarwal",'+
            '      "Personal_Email": "t9254_13718051@yopmail.com",'+
            '      "Mobile": "8888888888",'+
            '      "Martial_Status": "Single",'+
            '      "Birthdate": "24/12/2001",'+
            '      "Gender": "Female",'+
            '      "PH_Handicapped": "false",'+
            '      "Nationality": "Indian",'+
            '      "Aadhaar_Card_Number": "241102378288",'+
            '      "Nationality_Type": "Indian National",'+
            '      "Are_You_A_Reva_Student": "No",'+
            '      "Religion": "HINDUISM",'+
            '      "Caste_Category": "General Merit",'+
            '      "Blood_Group": "B+",'+
            '      "Passport_Number": "",'+
            '      "Passport_Issued_Country": "",'+
            '      "Passport_Place_Of_Issue": "",'+
            '      "Passport_Date_of_Issue": "",'+
            '      "Passport_Date_of_Expiry": "",'+
            '      "correspondence_country": "",'+
            '      "correspondence_state": "Delhi",'+
            '      "correspondence_district": "North West Delhi",'+
            '      "correspondence_city": "North West Delhi",'+
            '      "correspondence_address_line_1": "C-17 BUDH VIHAR PHASE-1",'+
            '      "correspondence_address_line_2": "",'+
            '      "correspondence_pincode": "110086",'+
            '      "Is_perm_add_same_as_commu_add": "Yes",'+
            '      "permanent_country": "India",'+
            '      "permanent_state": "Delhi",'+
            '      "permanent_district": "North West Delhi",'+
            '      "permanent_city": "North West Delhi",'+
            '      "permanent_address_line_1": "C-17 BUDH VIHAR PHASE-1",'+
            '      "permanent_address_line_2": "",'+
            '      "permanent_pincode": "110086",'+
            '      "Referral_Code": "",'+
            '      "Transporatation_Facility": "No",'+
            '      "Hostel_Facility": "Yes",'+
            '      "Application_Submission_Date": "08/06/2022",'+
            '      "Quota": "Management Quota",'+
            '      "Enrollment_Type": "REGULAR ENTRY",'+
            '      "ApplicationNumber": "22130621090",'+
            '      "I_Agree": "Yes",'+
            '      "file_passport_size_photo": "https://97-s16.nopaperforms.in/uploads/student/document/97/2162/2022/06/08/62a05f49b214a668431231_3AD69047C1A44773B8C5A5015B7F3E81.JPEG",'+
            '      "Admission_Mode": "ComedK",'+
            '      "Cet_Comedk_TAT_No": "",'+
            '      "Cet_Comedk_Rank": "",'+
            '      "Addmission_Order_No": "",'+
            '      "Addmission_Order_Date": "01/04/2022",'+
            '      "Claimed_Category": "",'+
            '      "Alloted_Category": "",'+
            '      "Sports_Person": "",'+
            '      "Defence_Ex_Serviceman": "",'+
            '      "State_of_Domicile": "",'+
            '      "Mother_Tongue": "",'+
            '      "Alternate_Phone_Number": "",'+
            '      "Belongs_To": "",'+
            '      "Anti_Ragging_undertaking_Reference_No": "",'+
            '      "Local_Guardian_Address": "",'+
            '      "Local_Guardian_City": "",'+
            '      "Local_Guardian_District": "",'+
            '      "Local_Guardian_State": "",'+
            '      "Local_Guardian_Country": "",'+
            '      "Local_Guardian_Pin_Code": "",'+
            '      "Education_History": ['+
            '        {'+
            '          "Institution_Name": "PRESTIGE CONVENT SCHOOL",'+
            '          "City": "New Delhi",'+
            '          "State": "Delhi",'+
            '          "Board_OR_University": "Central Board Of Secondary Education (CBSE)",'+
            '          "Year_of_Passing": "24/12/2001",'+
            '          "Max_Marks": "500",'+
            '          "Marks_Obtained": "465.5",'+
            '          "Percentage": "93.1",'+
            '          "Stream": "",'+
            '          "Course": "",'+
            '          "Type_of_course": "10th",'+
            '          "PG_Result_Status": "",'+
            '          "file_document": "",'+
            '          "Country": "",'+
            '          "Second_Language_Studied": "",'+
            '          "Physics": "",'+
            '          "Chemistry": "",'+
            '          "Maths": "",'+
            '          "P_M_C_B_CS_EC_Perc": "",'+
            '          "Others": "",'+
            '          "Register_No": ""'+
            '        },'+
            '        {'+
            '          "Institution_Name": "PRESTIGE CONVENT SCHOOL",'+
            '          "City": "New Delhi",'+
            '          "State": "Delhi",'+
            '          "Board_OR_University": "Central Board Of Secondary Education (CBSE)",'+
            '          "Year_of_Passing": "24/12/2001",'+
            '          "Max_Marks": "600",'+
            '          "Marks_Obtained": "535",'+
            '          "Percentage": "89.1",'+
            '          "Stream": "Commerce",'+
            '          "Course": "",'+
            '          "Type_of_course": "12th",'+
            '          "PG_Result_Status": "",'+
            '          "file_document": "",'+
            '          "Country": "",'+
            '          "Second_Language_Studied": "",'+
            '          "Physics": "",'+
            '          "Chemistry": "",'+
            '          "Maths": "",'+
            '          "P_M_C_B_CS_EC_Perc": "",'+
            '          "Others": "",'+
            '          "Register_No": ""'+
            '        }'+
            '      ],'+
            '      "Parent_Information": ['+
            '        {'+
            '          "First_Name": "rakesh",'+
            '          "Middle_Name": "",'+
            '          "Last_Name": "aggarwal",'+
            '          "Mobile": "8888888888",'+
            '          "Occupation": "Business",'+
            '          "Personal_Email": "t9058_13718051@yopmail.com",'+
            '          "Annual_Income": "sdadas",'+
            '          "PAN_Number": "AAEPA8128R",'+
            '          "relation_ship_type": "Father"'+
            '        },'+
            '        {'+
            '          "First_Name": "dolly",'+
            '          "Middle_Name": "",'+
            '          "Last_Name": "aggarwal",'+
            '          "Mobile": "8888888888",'+
            '          "Occupation": "Other|Home Maker",'+
            '          "Personal_Email": "t6804_13718051@yopmail.com",'+
            '          "Annual_Income": "",'+
            '          "PAN_Number": "",'+
            '          "relation_ship_type": "Mother"'+
            '        }'+
            '      ],'+
            '      "Student_Fee": ['+
             
             
            '      ],'+
            '      "Student_Payment": ['+
            '        {'+
            
            '        }'+
            '      ]'+
            '    }'+
            '  ]'+
            '}';
        
        
        
        
        // String myJSON = JSON.serialize(json);     
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/CreateApplication';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);
        
        RestContext.request = request;
        
        Test.startTest();
        NPF_ApplicationAPI.CreateApplication();
        Test.stopTest();
        //System.assert(obj != null);
        
    }  
    static testMethod void exceptionMathod() {
        
        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        insert objProgPlan;
        
        String json =		'{'+
            '  "ApplicantDetails": ['+
            '    {'+
            '      "Category": "Indian (SAARC)",'+
            '      "School": "",'+
            '      "Program": "'+objAccount.Id+'",'+
            '      "Admission_Session": "2022",'+
            '      "Applying_For_Reva_CET": "",'+
            '      "Reva_CET_Date": "30 April 2022",'+
            '      "Exam_Type": "",'+
            '      "First_Name": "TANYA",'+
            '      "Middle_Name": "",'+
            '      "Last_Name": "aggarwal",'+
            '      "Personal_Email": "t9254_13718051@yopmail.com",'+
            '      "Mobile": "8888888888",'+
            '      "Martial_Status": "Single",'+
            '      "Birthdate": "24/12/2001",'+
            '      "Gender": "Female",'+
            '      "PH_Handicapped": "false",'+
            '      "Nationality": "Indian",'+
            '      "Aadhaar_Card_Number": "241102378288",'+
            '      "Nationality_Type": "Indian National",'+
            '      "Are_You_A_Reva_Student": "No",'+
            '      "Religion": "HINDUISM",'+
            '      "Caste_Category": "General Merit",'+
            '      "Blood_Group": "B+",'+
            '      "Passport_Number": "",'+
            '      "Passport_Issued_Country": "",'+
            '      "Passport_Place_Of_Issue": "",'+
            '      "Passport_Date_of_Issue": "",'+
            '      "Passport_Date_of_Expiry": "",'+
            '      "correspondence_country": "",'+
            '      "correspondence_state": "Delhi",'+
            '      "correspondence_district": "North West Delhi",'+
            '      "correspondence_city": "North West Delhi",'+
            '      "correspondence_address_line_1": "C-17 BUDH VIHAR PHASE-1",'+
            '      "correspondence_address_line_2": "",'+
            '      "correspondence_pincode": "110086",'+
            '      "Is_perm_add_same_as_commu_add": "Yes",'+
            '      "permanent_country": "India",'+
            '      "permanent_state": "Delhi",'+
            '      "permanent_district": "North West Delhi",'+
            '      "permanent_city": "North West Delhi",'+
            '      "permanent_address_line_1": "C-17 BUDH VIHAR PHASE-1",'+
            '      "permanent_address_line_2": "",'+
            '      "permanent_pincode": "110086",'+
            '      "Referral_Code": "",'+
            '      "Transporatation_Facility": "No",'+
            '      "Hostel_Facility": "Yes",'+
            '      "Application_Submission_Date": "08/06/2022",'+
            '      "Quota": "Management Quota",'+
            '      "Enrollment_Type": "REGULAR ENTRY",'+
            '      "ApplicationNumber": "22130621090",'+
            '      "I_Agree": "Yes",'+
            '      "file_passport_size_photo": "https://97-s16.nopaperforms.in/uploads/student/document/97/2162/2022/06/08/62a05f49b214a668431231_3AD69047C1A44773B8C5A5015B7F3E81.JPEG",'+
            '      "Admission_Mode": "",'+
            '      "Cet_Comedk_TAT_No": "",'+
            '      "Cet_Comedk_Rank": "",'+
            '      "Addmission_Order_No": "",'+
            '      "Addmission_Order_Date": "01/04/2022",'+
            '      "Claimed_Category": "",'+
            '      "Alloted_Category": "",'+
            '      "Sports_Person": "",'+
            '      "Defence_Ex_Serviceman": "",'+
            '      "State_of_Domicile": "",'+
            '      "Mother_Tongue": "",'+
            '      "Alternate_Phone_Number": "",'+
            '      "Belongs_To": "",'+
            '      "Anti_Ragging_undertaking_Reference_No": "",'+
            '      "Local_Guardian_Address": "",'+
            '      "Local_Guardian_City": "",'+
            '      "Local_Guardian_District": "",'+
            '      "Local_Guardian_State": "",'+
            '      "Local_Guardian_Country": "",'+
            '      "Local_Guardian_Pin_Code": "",'+
            '      "Education_History": ['+
            '        {'+
            '          "Institution_Name": "PRESTIGE CONVENT SCHOOL",'+
            '          "City": "New Delhi",'+
            '          "State": "Delhi",'+
            '          "Board_OR_University": "Central Board Of Secondary Education (CBSE)",'+
            '          "Year_of_Passing": "24/12/2001",'+
            '          "Max_Marks": "500",'+
            '          "Marks_Obtained": "465.5",'+
            '          "Percentage": "93.1",'+
            '          "Stream": "",'+
            '          "Course": "",'+
            '          "Type_of_course": "10th",'+
            '          "PG_Result_Status": "",'+
            '          "file_document": "",'+
            '          "Country": "",'+
            '          "Second_Language_Studied": "",'+
            '          "Physics": "",'+
            '          "Chemistry": "",'+
            '          "Maths": "",'+
            '          "P_M_C_B_CS_EC_Perc": "",'+
            '          "Others": "",'+
            '          "Register_No": ""'+
            '        },'+
            '        {'+
            '          "Institution_Name": "PRESTIGE CONVENT SCHOOL",'+
            '          "City": "New Delhi",'+
            '          "State": "Delhi",'+
            '          "Board_OR_University": "Central Board Of Secondary Education (CBSE)",'+
            '          "Year_of_Passing": "24/12/2001",'+
            '          "Max_Marks": "600",'+
            '          "Marks_Obtained": "535",'+
            '          "Percentage": "89.1",'+
            '          "Stream": "Commerce",'+
            '          "Course": "",'+
            '          "Type_of_course": "12th",'+
            '          "PG_Result_Status": "",'+
            '          "file_document": "",'+
            '          "Country": "",'+
            '          "Second_Language_Studied": "",'+
            '          "Physics": "",'+
            '          "Chemistry": "",'+
            '          "Maths": "",'+
            '          "P_M_C_B_CS_EC_Perc": "",'+
            '          "Others": "",'+
            '          "Register_No": ""'+
            '        }'+
            '      ],'+
            '      "Parent_Information": ['+
            '        {'+
            '          "First_Name": "rakesh",'+
            '          "Middle_Name": "",'+
            '          "Last_Name": "aggarwalsdsadasdsadsadasdsadsadsadasdsadasdsadsadsadsadsadsadasdsadsadsadsaaggarwalsdsadasdsadsadasdsadsadsadasdsadasdsadsadsadsadsadsadasdsadsadsadsaaggarwalsdsadasdsadsadasdsadsadsadasdsadasdsadsadsadsadsadsadasdsadsadsadsaaggarwalsdsadasdsadsadasdsadsadsadasdsadasdsadsadsadsadsadsadasdsadsadsadsaaggarwalsdsadasdsadsadasdsadsadsadasdsadasdsadsadsadsadsadsadasdsadsadsadsaaggarwalsdsadasdsadsadasdsadsadsadasdsadasdsadsadsadsadsadsadasdsadsadsadsaaggarwalsdsadasdsadsadasdsadsadsadasdsadasdsadsadsadsadsadsadasdsadsadsadsaaggarwalsdsadasdsadsadasdsadsadsadasdsadasdsadsadsadsadsadsadasdsadsadsadsaaggarwalsdsadasdsadsadasdsadsadsadasdsadasdsadsadsadsadsadsadasdsadsadsadsa",'+
            '          "Mobile": "8888888888",'+
            '          "Occupation": "Business",'+
            '          "Personal_Email": "t9058_13718051@yopmail.com",'+
            '          "Annual_Income": "500000",'+
            '          "PAN_Number": "AAEPA8128R",'+
            '          "relation_ship_type": "Father"'+
            '        },'+
            '        {'+
            '          "First_Name": "dolly",'+
            '          "Middle_Name": "",'+
            '          "Last_Name": "aggarwal",'+
            '          "Mobile": "8888888888",'+
            '          "Occupation": "Home Maker",'+
            '          "Personal_Email": "t6804_13718051@yopmail.com",'+
            '          "Annual_Income": "",'+
            '          "PAN_Number": "",'+
            '          "relation_ship_type": "Mother"'+
            '        }'+
            '      ],'+
            '      "Student_Fee": ['+
            '        {'+
            '          "Session": "1st Year",'+
            '          "Seat_Blocking_Payment_Option": "",'+
            '          "Fee_Category": "",'+
            '          "Actual_Program_Fee": "",'+
            '          "Scholarship_Category": "",'+
            '          "Premium": "",'+
            '          "Concession": "",'+
            '          "Scholarship": "",'+
            '          "Amount": "10000",'+
            '          "Amount_Paid": "10000",'+
            '          "Amount_Pending": "0",'+
            '          "Due_Date": ""'+
            '        },'+
            '        {'+
            '          "Session": "2nd Year",'+
            '          "Seat_Blocking_Payment_Option": "",'+
            '          "Fee_Category": "",'+
            '          "Actual_Program_Fee": "",'+
            '          "Scholarship_Category": "",'+
            '          "Premium": "",'+
            '          "Concession": "",'+
            '          "Scholarship": "",'+
            '          "Amount": "10000",'+
            '          "Amount_Paid": "10000",'+
            '          "Amount_Pending": "0",'+
            '          "Due_Date": ""'+
            '        }'+
            '      ],'+
            '      "Student_Payment": ['+
            '        {'+
            '          "online_payment_date": "06-06-2022 10:00:00",'+
            '          "online_transaction_id": "TEST13",'+
            '          "online_order_id": "TEST1234",'+
            '          "offline_payment_date": "2022-06-06 10:00:00",'+
            '          "offline_transaction_id": "",'+
            '          "offline_receipt_number": "",'+
            '          "Amount": ""'+
            '        }'+
            '      ]'+
            '    }'+
            '  ]'+
            '}';
        
        
        
        
        // String myJSON = JSON.serialize(json);     
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/CreateApplication';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);
        
        RestContext.request = request;
        
        Test.startTest();
        NPF_ApplicationAPI.CreateApplication();
        Test.stopTest();
        //System.assert(obj != null);
        
    }   
}