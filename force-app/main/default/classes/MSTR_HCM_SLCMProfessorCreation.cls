@RestResource(urlMapping='/ProfessorDetails/*')
global class MSTR_HCM_SLCMProfessorCreation {
    @HttpPost
    global static void getProfessorDetails() {
        RestRequest objRestRequest = RestContext.request;
        RestResponse objRestResponse = RestContext.response;
        String jsonBody = objRestRequest.requestBody.toString().trim();
        
        Debug_Log__c objDbLog = new Debug_Log__c(
            Processing_API_Name__c = 'Professor API',
            Object_Name__c = 'Contact - Professor',
            Status__c = 'Failure',
            Class_Name__c = 'MSTR_HCM_SLCMProfessorCreation'
        );
        Insert objDbLog;
        
        responseWrapper objRespWrp = new responseWrapper();
        List<Contact> lstContact = new List<Contact>();
        
        try {
            if (String.isNotBlank(jsonBody)) {
                objDbLog.Request__c = jsonBody;
                RequestWrapper objReqWrp = (RequestWrapper) JSON.deserialize(jsonBody, RequestWrapper.class);
                
                if (!objReqWrp.employeeData.isEmpty()) {
                    Map<String, EmployeeData> empResMap = new Map<String, EmployeeData>();
                    Map<String, Contact> contactMap = new Map<String, Contact>();
                    
                    // Prepare record type IDs
                    String professor = utility.Contact_RecType_Professor;
                    String nonTeaching = utility.Contact_RecType_Non_Teaching;
                    Id professorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(professor).getRecordTypeId();
                    Id nonTeachingRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(nonTeaching).getRecordTypeId();
                    
                    for (EmployeeData empData : objReqWrp.employeeData) {
                        empResMap.put(empData.Emp_Number, empData);
                    }
                    
                    // Query existing contacts
                    List<Contact> existingContacts = [
                        SELECT Id, Employee_Number__c,Salary_Revised_Date__c, AccountId 
                        FROM Contact 
                        WHERE Employee_Number__c IN :empResMap.keySet()
                    ];
                    
                    for (Contact con : existingContacts) {
                        contactMap.put(con.Employee_Number__c, con);
                    }
                    
                    for (EmployeeData objEmpData : objReqWrp.employeeData) {
                        Contact objCon = contactMap.containsKey(objEmpData.Emp_Number) ? contactMap.get(objEmpData.Emp_Number) : new Contact();
                        
                        objCon.Salutation = String.isNotBlank(objEmpData.Emp_Salutation) ? objEmpData.Emp_Salutation : null;
                        objCon.FirstName = String.isNotBlank(objEmpData.Emp_FirstName) ? objEmpData.Emp_FirstName : null;
                        objCon.MiddleName = String.isNotBlank(objEmpData.Emp_MiddleName) ? objEmpData.Emp_MiddleName : null;
                        objCon.LastName = String.isNotBlank(objEmpData.Emp_LastName) ? objEmpData.Emp_LastName : null;
                        objCon.Employee_Number__c = String.isNotBlank(objEmpData.Emp_Number) ? objEmpData.Emp_Number : null;
                        
                        // Assigns the reporting manager as a Contact reference if available
                        objCon.ReportsTo = String.isNotBlank(objEmpData.Emp_ReportingMngr) ? new Contact(Employee_Number__c = objEmpData.Emp_ReportingMngr) : null;
                        
                        objCon.Employment_Type__c = String.isNotBlank(objEmpData.Emp_EmploymentType) ? objEmpData.Emp_EmploymentType : null;
                        objCon.Work_Location__c = String.isNotBlank(objEmpData.Emp_WorkLocation) ? objEmpData.Emp_WorkLocation : null;
                        objCon.Designation__c = String.isNotBlank(objEmpData.Emp_Designation) ? objEmpData.Emp_Designation : null;
                        objCon.hed__WorkEmail__c = String.isNotBlank(objEmpData.Emp_OfficialEmail) ? objEmpData.Emp_OfficialEmail : null;
                        objCon.Email = String.isNotBlank(objEmpData.Emp_OfficialEmail) ? objEmpData.Emp_OfficialEmail : null;
                        objCon.hed__Preferred_Email__c = 'Personal Email' ;
                        objCon.Personal_Email__c = String.isNotBlank(objEmpData.Emp_PersonalEmail) ? objEmpData.Emp_PersonalEmail : null;
                        objCon.MobilePhone = String.isNotBlank(objEmpData.Emp_Mobile) ? objEmpData.Emp_Mobile : null;
                        
                        objCon.Date_of_Joining__c = String.isNotBlank(objEmpData.Emp_DateofJoining) ? Date.valueOf(objEmpData.Emp_DateofJoining) : null;
                        objCon.Birthdate = String.isNotBlank(objEmpData.Emp_RecordDateofBirth) ? Date.valueOf(objEmpData.Emp_RecordDateofBirth) : null;
                        
                        objCon.Aadhar_Card_Number__c = String.isNotBlank(objEmpData.Emp_AadharCardNumber) ? objEmpData.Emp_AadharCardNumber : null;
                        objCon.hed__Gender__c = String.isNotBlank(objEmpData.Emp_Gender) ? objEmpData.Emp_Gender : null;
                        objCon.Blood_Group__c = String.isNotBlank(objEmpData.Emp_BloodGroup) ? objEmpData.Emp_BloodGroup : null;
                        
                        // Placeholder logic for Salary_Revised_Date__c, to be updated based on specific revision conditions from HCM
                        objCon.Salary_Revised_Date__c = String.isNotBlank(objEmpData.Emp_SalaryRevisedDate) 
                            ? Date.valueOf(objEmpData.Emp_SalaryRevisedDate) 
                            : objCon.Salary_Revised_Date__c; 
                        
                        objCon.Active__c = objEmpData.Emp_Active;
                        objCon.RecordTypeId = objEmpData.Emp_Section == 'Academic' ? professorRecordTypeId : nonTeachingRecordTypeId;
                        
                        if (contactMap.containsKey(objEmpData.Emp_Number) && objEmpData.Emp_Department != null) {
                            System.debug('Inside existing');
                            objCon.AccountId = objCon.AccountId == null ? new Account(SLCM_HCM_ID__c = objEmpData.Emp_Department).Id : objCon.AccountId;
                        } else if (objEmpData.Emp_Department != null) {
                            System.debug('Inside new Account' );
                            objCon.Account = new Account(SLCM_HCM_ID__c = objEmpData.Emp_Department);
                        }
                        
                        lstContact.add(objCon);
                    }
                    
                    // Upsert and handle results
                    Integer successCount = 0;
                    Integer errorCount = 0;
                    String status = '';
                    
                    List<resultWpr> list_resultWpr = new List<resultWpr>();
                    if(lstContact.size() > 0)
                    {
                        Database.UpsertResult[] result = Database.upsert(lstContact, Contact.Employee_Number__c, false);
                        system.debug('=====>>>'+result);
                        for(Integer i=0;i<result.size();i++)
                        {
                            if(result[i].isSuccess())
                            {
                                successCount++;
                                resultWpr rw = new resultWpr();
                                rw.status = 'Success';
                                rw.empNumber = lstContact[i].Employee_Number__c;
                                rw.error = '';
                                list_resultWpr.add(rw);
                            }
                            else
                            {
                                errorCount++;
                                resultWpr rw = new resultWpr();
                                rw.status = 'Failure';
                                rw.empNumber = lstContact[i].Employee_Number__c;
                                rw.error = result[i].getErrors()[0].getMessage();
                                list_resultWpr.add(rw);
                            }
                        }
                        objrespWrp.result = list_resultWpr;
                        if(successCount == lstContact.size())
                        {
                            status = 'Success';
                        }
                        else if(successCount > 0 && errorCount > 0)
                        {
                            status = 'Partial';
                        }
                        else
                        {
                            status = 'Failure';
                        }
                        objrespWrp.status = status;
                        objrespWrp.message = '';
                        objDbLog.Status__c = status;
                    }
                }
                else
                {
                    objrespWrp.Status = 'Failure';
                    objrespWrp.message = 'Error - Professor/Non_teaching Data is Empty';
                    objDbLog.Error_Message__c = 'Professor/Non_teaching Data is Empty';
                }
            }
            else
            {
                objrespWrp.Status = 'Failure';
                objrespWrp.message = 'Error - Professor/Non_teaching Data is Empty';
                objDbLog.Error_Message__c = 'Professor/Non_teaching Data is Empty';
            }
            update objDbLog;
        }
        Catch(Exception ex)
        {
            objrespWrp.Status = 'Failure';
            objrespWrp.message = 'Error - '+ex.getMessage();
            objDbLog.Response__c = 'Failure - '+ex.getMessage();
            update objDbLog;
        }
        objRestResponse.addHeader('Content-Type', 'application/json');
        objRestResponse.responseBody = Blob.valueof(Json.serialize(objrespWrp));
    }
    
    global class RequestWrapper {
        public List<EmployeeData> employeeData;
    }
    
    global class EmployeeData {
        public String Emp_Salutation, Emp_FirstName, Emp_MiddleName, Emp_LastName, Emp_Number, Emp_Department, Emp_ReportingMngr, Emp_EmploymentType, Emp_WorkLocation, Emp_Designation, Emp_OfficialEmail, Emp_Mobile, Emp_PersonalEmail, Emp_DateofJoining, Emp_RecordDateofBirth, Emp_AadharCardNumber, Emp_Gender, Emp_BloodGroup, Emp_Section;
        public Boolean Emp_Active;
        public String Emp_SalaryRevisedDate;
    }
    
    global class responseWrapper {
        public String status;
        public String message;
        public List<resultWpr> result;
    }
    
    public class resultWpr {
        public String status;
        public String empNumber;
        public String error;
    }
}