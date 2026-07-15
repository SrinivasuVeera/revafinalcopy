global class Fee_SendingEmailAlert_Batch implements Database.Batchable<sObject> 
{
    global database.QueryLocator start(Database.BatchableContext bc)
    {
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        date todayDt = system.today();
        integer yr = Integer.Valueof( system.Label.Due_Date_Email_Alert_Year_Filter);
        System.debug('Start method executed');
       
        Integer currentYear = System.Today().year();
        String year ='%(' + currentYear + '%'; 
       system.debug('year==='+year);        
        return DataBase.getQueryLocator([Select id,Name,Active__c,SRN_Number__c,School_Name__c,Program_Type__c,Quota__c,Program_Batch__c,ReportsToid,Email,Program_Batch_Name__c,Program_Batch__r.hed__Start_Date__c,hed__WorkEmail__c,
                                         (select id,Name,Session__c,Due_Date__c,Fee_Year__c,Fee_Type__c,Amount_Paid__c,Amount__c,Amount_Pending__c,Contact__r.RecordTypeId
                                          FROM Student_Fees__r where Session__c !=: '1st Year' and Fee_Year__c !=: '1st Year' and Due_Date__c = THIS_YEAR and   Amount_Pending__c >:0 )
                                         FROM Contact where Student_Status__c =: 'Pursuing' and Program_Batch_Name__c IN (
                                             'B.Sc in Bioinformatics, Statistics and Computer Science-(2021-2024)',
                                             'B.Sc in Biotechnology, Biochemistry, and Genetics-(2021-2024)',
                                             'B.Sc in Mathematics, Statistics, and Computer Science-(2021-2024)',
                                             'B.Sc in Microbiology, Chemistry, and Genetics-(2021-2024)',
                                             'B.Sc in Physics, Chemistry, and Mathematics-(2021-2024)')
                                          and Program_Type__c =: 'UG' and RecordTypeId=:ContactRecTypeId and School_Name__c =:'School of Applied Sciences' 
                                         and Program_Batch__r.hed__Start_Date__c != null and CALENDAR_YEAR(Program_Batch__r.hed__Start_Date__c) !=: yr]);
          
    }
     global void execute(Database.BatchableContext Bc,List<Contact> lstCon)
    {           
        for(Contact con : lstCon)
        {    
            if (con.Student_Fees__r != null && con.Student_Fees__r.size() > 0)
            {
                Id ConParentTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
                string strDateOfconf; 
                set<id> set_Reportid = new set<id>();
                list<string> lst_CCEmail = new list<string>();
                list<string> lst_ToEmail = new list<string>();
                List<Messaging.SingleEmailMessage> lst_Email = new List<Messaging.SingleEmailMessage>();
                String programBatchName = con.Program_Batch_Name__c;
                //String session = '';
                string TextBody='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><html><head><META http-equiv="Content-Type" content="text/html; charset=utf-8"></head><body>'+
                    'Dear '+Con.Name+' '+'('+Con.SRN_Number__c+')'+','+'<br>'+
                    '<p> Greetings from REVA University!!! '+'<br>'+'<br>'
                    +'This is to inform you to pay your Outstanding Fees for the '+con.Student_Fees__r[0].Session__c+', '+programBatchName+' before the mentioned due date.</p>'+
                    '<table border="1" cellpadding="0" cellspacing="0" width="800px"  >'+
                    '<tr><td style="color:#f57f26;"> <center><b>Fee Name</b></center></td>'+'<td style="color:#f57f26;"><center><b>Due Date</b></center></td>'+'<td style="color:#f57f26;"><center><b>Total Amount</b></center></td>'+'<td style="color:#f57f26;"><center><b>Amount Paid</b></center></td>'+'<td style="color:#f57f26;"><center><b>Amount Pending</b></center></td>';
                
                set_Reportid.add(con.id);
                System.debug('111111');
                if(con.Email != null)  lst_ToEmail.add(con.Email); //
                if(con.hed__WorkEmail__c != null) lst_ToEmail.add(con.hed__WorkEmail__c);
                
                for(Student_Fee__c objstu : con.Student_Fees__r)
                {
                    if (objstu.Due_Date__c != null || objstu.Due_Date__c == null) {
                        if (objstu.Due_Date__c != null) {
                            strDateOfconf = Datetime.newInstance(objstu.Due_Date__c.Year(),
                                                                 objstu.Due_Date__c.Month(),
                                                                 objstu.Due_Date__c.day()).format('dd/MM/yyyy');
                            system.debug('year of due date==='+objstu.Due_Date__c.Year());
                        } else {
                            strDateOfconf = ''; // Set an empty string for null Due_Date__c
                        }
                        
                        
                        Textbody = Textbody + '<tr>' +
                            '<td style="padding: 5px;text-align: center;">' + objstu.Name + '</td>' +
                            '<td style="padding: 5px;text-align: center;">' + strDateOfconf + '</td>' +
                            '<td style="padding: 5px; text-align: center;">' + objstu.Amount__c + '</td>' +
                            '<td style="padding: 5px; text-align: center;">' + objstu.Amount_Paid__c + '</td>' +
                            '<td style="padding: 5px; text-align: center;">' + objstu.Amount_Pending__c + '</td>' +
                            '</tr>';
                        
                        system.debug('strDateOfconf==='+strDateOfconf);
                        system.debug('objstu=='+objstu);
                    }
                }
                
                Textbody = Textbody +'</tr></table><br>'+'<p>Please login to your Student Portal to make the payment or ' +'<a href="https://reva-university.force.com/StudentPortal/s/student-fee"' +
                    'style="color:#f57f26;margin-top:0pt;margin-bottom:0pt;text-align:center;">Click here to make the Payment...</a></p>'
                    +'If not paid within the due date, your registration process will not be completed.'+'<br>'
                     +'<br>'+'For any fee related queries, please raise your concern through '+'<a href="https://reva-university.force.com/StudentPortal/s/support-request-page"' +
                    'style="color:#f57f26;margin-top:0pt;margin-bottom:0pt;text-align:center;">Support Request</a> from your Student Portal. '+
                    +'<br>'+'<br>'+'Kindly ignore if already paid.'+
                     +'<br>'+'<br>'+'Warm regards,'+'<br>'+'Office of Finance and Accounts,'+'<br>'+'REVA University, Bengaluru</p>'+
                    '</body></html>';
                if(set_Reportid.size()>0)
                {     
                    for(Contact objcon : [Select Id,Name,Email,ReportsToid from contact where ReportsToid in:set_Reportid and RecordTypeId=:ConParentTypeId])
                    {
                        if(objcon.Email != null) lst_CCEmail.add(objcon.Email);                
                    }
                }
                OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress where DisplayName = 'REVA Alerts'];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
                if ( owea.size() > 0 ) 
                {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                
                if(lst_ToEmail.size()>0) email.SetToAddresses(lst_ToEmail);                    
                if(lst_CCEmail.size()>0) email.setCCAddresses(lst_CCEmail);
                
                email.setSubject('Fee Payment Reminder: 2023 - 2024'); 
                email.setHtmlBody(TextBody);
                lst_Email.add(email);
                if(lst_Email.size()> 0 && lst_ToEmail.size() > 0 )
                {
                    Messaging.sendEmail(lst_Email);
                }
            }
        }
    }   
    global void finish(DataBase.BatchableContext bc)
    {
        //BatchClass_Utility.sendBatchClassFailureMail('Fee Module', bc.getJobId(), 'Fee Due Date','Student Fees');
    }
}