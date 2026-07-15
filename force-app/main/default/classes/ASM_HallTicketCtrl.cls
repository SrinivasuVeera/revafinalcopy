public without sharing class ASM_HallTicketCtrl {
    
    @AuraEnabled(cacheable=true)
    public static List<contact> searchStudents(String searchTerm) {
        
        List<contact> conlst=[SELECT Id, Name FROM contact WHERE (Name LIKE :('%' +searchTerm + '%') OR SRN_Number__c = :searchTerm) AND Active__c=true];
        return conlst;
    }
    @AuraEnabled
    public static string updateContact(String conId, string comments,string approvalType) {
        Contact con = new contact();
        con.Id = conId;
        con.Description=comments;
        con.Exam_Approval__c=true;
        con.Date_of_Approval__c=Date.valueof(DateTime.now());
        update con;
        return 'sucess';
    }
    @AuraEnabled
    public static wrapperClass GetStudentDetails()
    {
        String usrId=userinfo.getUserId();
        decimal Eligibility_Percent = decimal.Valueof(System.Label.ASM_AttendancePercentage);
        wrapperClass objWrapper = new wrapperClass();        
        user usr =[select id,Name,ContactId from User where Id =:usrId]; //
        objWrapper.EnableIAHallTicket = false;
         objWrapper.EnableSemHallTicket = false;
        //objWrapper.EnableSemHallTicket = True;
        List<StudentFee> lst_StuFee = new List<StudentFee>();
        
        string ContactId;
        Contact objcon = new Contact();
        objcon =[select Id,Name,SRN_Number__c,Total_average_current_sem_attendance__c,Recordtype.Name,ReportsToId,Exam_Approval__c,Date_of_Approval__c,Active_Section__c,
                 Active_Semester__r.IA_1_End_date__c,Active_Semester__r.IA_2_End_date__c,Active_Semester__r.IA_1_Start_date__c,Active_Semester__r.IA_2_Start_date__c,Hall_Ticket_Blocked__c,
                 Active_Semester__r.Exam_Start_Date__c,Active_Semester__r.Exam_End_Date__c
                 from Contact where id=: usr.ContactId];

        objwrapper.SRNNumber = objcon.SRN_Number__c;
        if(objcon.Recordtype.Name == utility.Contact_RecType_Student) ContactId =objcon.id;
        else if(objcon.Recordtype.Name == utility.Contact_RecType_Parent) ContactId =objcon.ReportsToId;
        
        Map<Integer, String> semesterToYearMap = new Map<Integer, String>{
            1 => '1st year',
                2 => '1st year',
                3 => '2nd year',
                4 => '2nd year',
                5 => '3rd year',
                6 => '3rd year',
                7 => '4th year',
                8 => '4th year',
                9 => '5th year',
                10 => '5th year'
                };
                    
                   
        try
        {
             Date today_from_3days = system.Today().addDays(Integer.valueOf(System.label.HallTicketScheduleTime));
            for(Student_Fee__c objFee : [select Id,Contact__r.Checking_Eligibility_for_Exam__c,
                                         Name,Fee_Year__c,Contact__c,Contact__r.Total_average_current_sem_attendance__c,Amount_Pending__c,Due_Date__c,Contact__r.Active_Semester__r.Term_Number__c from Student_Fee__c where Contact__c =: ContactId and Due_Date__c !=null
                                        ])
            {
                Boolean allPendingAmountsZero = true;
                // Check if any of the student fees records have pending amount greater than zero
                if(objFee.Fee_Year__c == semesterToYearMap.get(Integer.valueof(objFee.Contact__r.Active_Semester__r.Term_Number__c)))
                {
                    if (Integer.valueOf(objFee.Amount_Pending__c) > 0) {
                        allPendingAmountsZero = false;
                        objWrapper.EnableIAHallTicket = false;
                        objWrapper.EnableSemHallTicket = false;
                        StudentFee objStuFee = new StudentFee();
                        objStuFee.FeeName = objFee.Name;
                        objStuFee.PendingAmount = objFee.Amount_Pending__c;
                        objStuFee.DueDate = objFee.Due_Date__c;
                        lst_StuFee.add(objStuFee);
                        
                        break;
                    }
                    else{
                            if((objfee.Contact__r.Total_average_current_sem_attendance__c>=75 && objcon.Hall_Ticket_Blocked__c == false)&&((objcon.Active_Semester__r.IA_1_Start_date__c<=today_from_3days &&objcon.Active_Semester__r.IA_1_End_date__c>=system.TODAY()) || (objcon.Active_Semester__r.IA_2_Start_date__c<=today_from_3days && objcon.Active_Semester__r.IA_2_End_date__c>=system.Today())))
                                {
                                    objWrapper.EnableIAHallTicket = true;                                   
                            }
                        else{
                                if((objfee.Contact__r.Total_average_current_sem_attendance__c>=75 && objcon.Hall_Ticket_Blocked__c == false)&&((objcon.Active_Semester__r.Exam_Start_Date__c<=today_from_3days &&objcon.Active_Semester__r.Exam_End_Date__c>=system.TODAY())))
                                {
                                    objWrapper.EnableSemHallTicket = true;                                   
                                }
                            }
                        }
                        if((objfee.Contact__r.Checking_Eligibility_for_Exam__c=='Eligible' && objcon.Hall_Ticket_Blocked__c == false)&&((objcon.Active_Semester__r.IA_1_Start_date__c<=today_from_3days &&objcon.Active_Semester__r.IA_1_End_date__c>=system.TODAY()) || (objcon.Active_Semester__r.IA_2_Start_date__c<=today_from_3days && objcon.Active_Semester__r.IA_2_End_date__c>=system.Today()))){
                           objWrapper.EnableIAHallTicket = true;                                   
                        } 
                        if((objfee.Contact__r.Checking_Eligibility_for_Exam__c=='Eligible' && objcon.Hall_Ticket_Blocked__c == false)&&((objcon.Active_Semester__r.Exam_Start_Date__c<=today_from_3days &&objcon.Active_Semester__r.Exam_End_Date__c>=system.TODAY()))){
                           objWrapper.EnableSemHallTicket = true;                                   
                        } 
                }
                
            }
            If((objcon.Exam_Approval__c == true && objcon.Hall_Ticket_Blocked__c == false) &&((objcon.Active_Semester__r.IA_1_Start_date__c<=today_from_3days &&objcon.Active_Semester__r.IA_1_End_date__c>=system.TODAY()) || (objcon.Active_Semester__r.IA_2_Start_date__c<=today_from_3days && objcon.Active_Semester__r.IA_2_End_date__c>=system.Today()))){
               objWrapper.EnableIAHallTicket = true;
           }
           If((objcon.Exam_Approval__c == true && objcon.Hall_Ticket_Blocked__c == false) &&((objcon.Active_Semester__r.Exam_Start_Date__c<=today_from_3days &&objcon.Active_Semester__r.Exam_End_Date__c>=system.TODAY()))){
               objWrapper.EnableSemHallTicket = true;
           }
        }
        catch(exception ex)
        {
        }
       
        
        Date Filterdate = System.today().adddays(Integer.valueOf(System.label.HallTicketScheduleTime));
        
        return objWrapper;
    }
    @AuraEnabled
    public static errorWrap DowloadHallTicket(string StudentSRN)
    {
        errorWrap objError = new errorWrap();
        //StudentSRN = 'R80SA321';
        Contact con = [SELECT Id ,name,SRN_No__c,SRN_Number__c,Checking_Eligibility_for_Exam__c FROM contact where  SRN_Number__c =:StudentSRN];
        If(con.Checking_Eligibility_for_Exam__c=='Eligible'){
                JsonSRN objJson = new JsonSRN();
                objJson.regno = StudentSRN;
                String jsonBody = Json.serialize(objJson);
                
                
                //Map Http Request
                HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_HallTicketCtrl',jsonBody);
                
                //Send Request
                Http http = new Http();
                HttpResponse hRsp = http.send(hReq);                
                string hallTicketURL;
                if(hRsp.getStatusCode() == 200)
                {                        
                    responseWrap objWrap = (responseWrap) Json.deserialize(hRsp.getBody(), responseWrap.class);             
                    if(objWrap.data.url != null && objWrap.status != 'Failure')
                    {
                        objError.url = objWrap.data.url;
                        return objError;                
                    }    
                    else
                    {
                        objError.error = 'error';
                        objError.message = objWrap.data.msg;
                        return objError;
                    }
                } 
                else
                {
                    objError.error = 'error';
                    objError.message = 'Please try after some time';
                    return objError;
                    
                }
        }else{
             throw new AuraHandledException('You Don\'t have access to downlaod the hall ticket.');
        }
    }
    
    public class JsonSRN
    {
        public string regno;
    }
    
    public class wrapperClass
    {
        @AuraEnabled public string SRNNumber {get;set;}
        @AuraEnabled public boolean EnableIAHallTicket {get;set;}
        @AuraEnabled public boolean EnableSemHallTicket {get;set;}
        @AuraEnabled public List<StudentFee> StudentFee {get;set;}
        
    }
    public class StudentFee
    {
        @AuraEnabled  public string FeeName {get;set;}
        @AuraEnabled  public decimal PendingAmount {get;set;}
        @AuraEnabled  public Date DueDate {get;set;}
    }
    
    public class responseWrap 
    {
        @AuraEnabled  public Integer error_code {get;set;}
        @AuraEnabled  public String status {get;set;}
        @AuraEnabled  public Data data {get;set;}
    }    
    public class Data 
    {
        @AuraEnabled  public String regno {get;set;}
        @AuraEnabled  public String url {get;set;}
        @AuraEnabled  public String msg {get;set;}
    }
    
    public class errorWrap
    {
        @AuraEnabled  public String error {get;set;}
        @AuraEnabled  public String message {get;set;}
        @AuraEnabled  public String url {get;set;}
    }
}