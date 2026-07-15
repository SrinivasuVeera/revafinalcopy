public class PAFPaymentEmailQueueable implements Queueable, Database.AllowsCallouts {
    
    Map<Id,Map<String,String>> conEmailSourceMap;
    
    public PAFPaymentEmailQueueable(Map<Id,Map<String,String>> conEmailSourceMap){
        this.conEmailSourceMap = conEmailSourceMap;
    }
    
    public void execute(QueueableContext context){
        
        List<Contact> conList = [SELECT Id, Name, Email,Application_Number__c,Primary_Academic_Program_Name__c FROM Contact
            WHERE Id IN :conEmailSourceMap.keySet()];
        
        Map<Id,hed__Application__c> appMap = new Map<Id,hed__Application__c>();
        
        for(hed__Application__c app : [SELECT Id,hed__Applicant__c,hed__Application_Status__c,Application_Number__c,hed__Applicant__r.Admission_Mode__c FROM hed__Application__c
             WHERE hed__Applicant__c IN :conEmailSourceMap.keySet()]
           ){
               appMap.put(app.hed__Applicant__c, app);
           }
        
        Decimal totalAnnualFee = 0;
        for(Student_Fee__c fee : [SELECT Id, Contact__c, Actual_Program_Fee__c FROM Student_Fee__c
            WHERE Contact__c IN :conEmailSourceMap.keySet() AND Fee_Type__c IN ('University Fee','Tuition Fee') AND Fee_Year__c = '1st Year'
        ]){
            if(fee.Actual_Program_Fee__c != null){
                totalAnnualFee += fee.Actual_Program_Fee__c;
            }
        }
        
        Decimal totalFeePaidSucess = 0;
        for(Student_Payment__c PayFee : [SELECT Amount__c FROM Student_Payment__c WHERE Contact__c IN :conEmailSourceMap.keySet() and (Fee_Type__c LIKE '%University fee%' OR Fee_Type__c LIKE '%Tuition fee%') AND Payment_Status__c = 'Success']){
           if(PayFee.Amount__c !=null)
           {
               totalFeePaidSucess += PayFee.Amount__c;
           }
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts' LIMIT 1];
        
        for(Contact con : conList){
            
            hed__Application__c app = appMap.get(con.Id);
            if(app == null) continue;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(owea.Id);
            mail.setToAddresses(new List<String>{con.Email});
            
            String body = '';
            
            if(
                app.hed__Applicant__r.Admission_Mode__c == 'UQ' && 
               app.hed__Application_Status__c == 'Provisionally Offered'){
                
                mail.setSubject('REVA - Admission Payment Link');
                
                body += 'Dear '+ con.Name + ',<br/>';
                body += '<br/> Kindly make a payment of Rs. '
                    + conEmailSourceMap.get(con.Id).get('Amount')
                    + ' to confirm your Provisional Admission Online at '
                    + conEmailSourceMap.get(con.Id).get('URL') + '.<br/>';
                body += '<br/> In case of any confusion, kindly connect with your admission counsellor '+ (conEmailSourceMap.get(con.Id)).get('CounsellorName') + ' on ' + (conEmailSourceMap.get(con.Id)).get('CounsellorMobileNo') +'<br/>';
                body += '<br/> Regards, <br/> Office of Admissions <br/> REVA University';
                
                mail.setHtmlBody(body);
                
                PageReference pdfPage = Page.PAOLetterPDF;
                pdfPage.getParameters().put('id', con.Id);
                pdfPage.getParameters().put('payUrl', conEmailSourceMap.get(con.Id).get('URL'));
                
                Blob pdfBlob;

                if(Test.isRunningTest()){
                    pdfBlob = Blob.valueOf('Test PDF');
                }else{
                    pdfBlob = pdfPage.getContentAsPDF();
                }
                
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Provisional_Admission_Offer.pdf');
                attachment.setBody(pdfBlob);
                attachment.setContentType('application/pdf');
                
                mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            }
            else if(
    app.hed__Applicant__r.Admission_Mode__c != 'UQ'
    
){
    mail.setSubject('REVA - Admission Payment Link');

    body += 'Dear ' + con.Name + ',<br/>';
    body += '<br/> Kindly make a payment of Rs. '
        + conEmailSourceMap.get(con.Id).get('Amount')
        + ' to confirm your Provisional Admission Online at '
        + conEmailSourceMap.get(con.Id).get('URL') + '.<br/>';

    body += '<br/> In case of any confusion, kindly connect with your admission counsellor '
        + conEmailSourceMap.get(con.Id).get('CounsellorName')
        + ' on '
        + conEmailSourceMap.get(con.Id).get('CounsellorMobileNo')
        + '<br/>';

    body += '<br/> Regards,<br/>Office of Admissions<br/>REVA University';

    mail.setHtmlBody(body);
}
            
            else {
                
                mail.setSubject('REVA - Admission Payment Link');
                
                body += 'Dear '+ con.Name + ',<br/>';
                body += '<br/> Kindly make a payment of Rs. '
                    + conEmailSourceMap.get(con.Id).get('Amount')
                    + ' to confirm your Provisional Admission Online at '
                    + conEmailSourceMap.get(con.Id).get('URL') + '.<br/>';
                body += '<br/> In case of any confusion, kindly connect with your admission counsellor '+ (conEmailSourceMap.get(con.Id)).get('CounsellorName') + ' on ' + (conEmailSourceMap.get(con.Id)).get('CounsellorMobileNo') +'<br/>';
                body += '<br/> Regards, <br/> Office of Admissions <br/> REVA University';
                
                mail.setHtmlBody(body);
               
            }
            
            mails.add(mail);
        }
        
        if(!mails.isEmpty()){
            Messaging.sendEmail(mails);
        }
    }
}