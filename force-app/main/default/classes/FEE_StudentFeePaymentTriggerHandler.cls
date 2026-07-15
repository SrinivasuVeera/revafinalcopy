public class FEE_StudentFeePaymentTriggerHandler 
{
    public static void RollupAmount(List<Student_Fee_Payment__c> lst_stufeePay,Map<Id,Student_Fee_Payment__c> map_Oldstufeepay)
    {
        set<id> set_StuFeeid = new set<id>();
        set<id> set_StuFeePayid = new set<id>();
        map<id,Student_Fee__c> map_StuFee = new map<id,Student_Fee__c>();
        map<id,Student_Fee_Payment__c> map_StuFeePay = new map<id,Student_Fee_Payment__c>();
        
        for(Student_Fee_Payment__c objStufeepay : lst_stufeePay)
        {
            if(map_Oldstufeepay == null && objStufeepay.Student_Fee__c != null && objStufeepay.Line_Item_Payment_Status__c != null &&
               objStufeepay.Line_Item_Payment_Status__c == 'Success' && objStufeepay.Student_Payment__c !=null)               
            { 
                set_StuFeeid.add(objStufeepay.Student_Fee__c);
                set_StuFeePayid.add(objStufeepay.id);
                map_StuFeePay.put(objStufeepay.Student_Fee__c,objStufeepay);
            } 
            else if(map_Oldstufeepay != null && objStufeepay.Student_Fee__c != null && objStufeepay.Line_Item_Payment_Status__c != null 
                    &&( map_Oldstufeepay.get(objStufeepay.id).Line_Item_Payment_Status__c != objStufeepay.Line_Item_Payment_Status__c 
                       || map_Oldstufeepay.get(objStufeepay.id).Amount__c != objStufeepay.Amount__c)
                    && objStufeepay.Line_Item_Payment_Status__c == 'Success' && objStufeepay.Student_Payment__c !=null)
            {
                set_StuFeeid.add(objStufeepay.Student_Fee__c);
                set_StuFeePayid.add(objStufeepay.id);
                map_StuFeePay.put(objStufeepay.Student_Fee__c,objStufeepay);
            } 
        }
        if(!set_StuFeeid.isEmpty())
        { 
            for(Id objId : set_StuFeeid) 
            {
                map_StuFee.put(objId,new Student_Fee__c(Id=objId,Amount_Paid__c=0));
            }
            for(Student_Fee_Payment__c objStufeepay : [select id,name,Amount__c,Student_Fee__c,Transaction_Status__c from Student_Fee_Payment__c 
                                                       where Student_Fee__c in: set_StuFeeid and Line_Item_Payment_Status__c = 'Success'])
            {
                if(map_StuFee.get(objStufeepay.Student_Fee__c).Amount_Paid__c != null && objStufeepay.Amount__c > 0)
                {
                    map_StuFee.get(objStufeepay.Student_Fee__c).Amount_Paid__c+= objStufeepay.Amount__c;
                }            
            }
        } 
        if(map_StuFee.size()>0)
        {
            update map_StuFee.values();
        }
    }
    public static void InstallmentRollup(List<Student_Fee_Payment__c> lst_stufeePay,map<id,Student_Fee_Payment__c> oldmap_Stufee)
    {
        set<id> set_StuFeeid = new set<id>();
        set<id> set_StuFeePayid = new set<id>();
        map<id,Student_Fee__c> map_StuFee = new map<id,Student_Fee__c>();
        
        for(Student_Fee_Payment__c objStufeepay : lst_stufeePay)
        {
            if(oldmap_Stufee == null && objStufeepay.Student_Fee__c != null && objStufeepay.Line_Item_Payment_Status__c != null &&
               objStufeepay.Line_Item_Payment_Status__c == 'Success' && objStufeepay.Student_Payment__c !=null)               
            {                
                set_StuFeeid.add(objStufeepay.Student_Fee__c);
                set_StuFeePayid.add(objStufeepay.id);
            }   
            else if(oldmap_Stufee != null && objStufeepay.Student_Fee__c != null && objStufeepay.Line_Item_Payment_Status__c != null && 
                    (oldmap_Stufee .get(objStufeepay.id).Line_Item_Payment_Status__c != objStufeepay.Line_Item_Payment_Status__c 
                     || oldmap_Stufee .get(objStufeepay.id).Amount__c != objStufeepay.Amount__c) && 
                    objStufeepay.Line_Item_Payment_Status__c == 'Success' && objStufeepay.Student_Payment__c !=null)  
            {                
                set_StuFeeid.add(objStufeepay.Student_Fee__c);
                set_StuFeePayid.add(objStufeepay.id);
            }     
        }
        if(!set_StuFeeid.isEmpty())
        {
            for(Student_Fee__c objStufeeId :[select id,Name,Amount_Paid__c,Amount_Pending__c,Paid_Installments__c,Number_of_Installments__c from 
                                             Student_Fee__c where id in: set_StuFeeid])
            {
                map_StuFee.put(objStufeeId.id,objStufeeId);
            }           
            for(Student_Fee_Payment__c objStufeepay : [select id,name,Amount__c,Student_Fee__c,Transaction_Status__c 
                                                       from Student_Fee_Payment__c where id in: set_StuFeePayid])
            {
                if(map_StuFee.get(objStufeepay.Student_Fee__c) != null)
                {    
                    if(map_StuFee.get(objStufeepay.Student_Fee__c).Number_of_Installments__c != null && map_StuFee.get(objStufeepay.Student_Fee__c).Number_of_Installments__c != 0)
                    {                        
                        map_StuFee.get(objStufeepay.Student_Fee__c).Number_of_Installments__c = map_StuFee.get(objStufeepay.Student_Fee__c).Number_of_Installments__c - 1;
                        map_StuFee.get(objStufeepay.Student_Fee__c).Paid_Installments__c += 1;
                    }
                }
            }
        } 
        if(map_StuFee.size()>0)
        {
            update map_StuFee.values();
        }
    }
    //This Method is used for pushing the Student Exam Fee Status to Logisys
    public static void PushExamFeeToLogisys(List<Student_Fee_Payment__c> lstStudFeePay, Map<Id,Student_Fee_Payment__c> oldMap)
    {
        
        Set<Id> set_StudPayFeeIds = new Set<Id>();
        for(Student_Fee_Payment__c objStudFeePay :lstStudFeePay)
        {
            system.debug(objStudFeePay.Line_Item_Payment_Status__c+' '+objStudFeePay.Exam_Application_Number__c+' '+objStudFeePay.Logisys_Integration__c);
            if(objStudFeePay.Line_Item_Payment_Status__c == 'Success' 
               && objStudFeePay.Exam_Application_Number__c != Null && objStudFeePay.Logisys_Integration__c == false)  //objStudFeePay.Exam_Application_Number__c != Null
                set_StudPayFeeIds.add(objStudFeePay.Id);
            system.debug('set_StudPayFeeIds-->'+set_StudPayFeeIds);
        }
        if(!set_StudPayFeeIds.isEmpty())  {   
            system.debug('inside if');
            // FEE_StudentExamPayment_API.sendStudExamFee(set_StudPayFeeIds);
            //AddedbyRajashekar
            if(RecursiveTriggerHandler.isFirstTimeQueue)
            {
                RecursiveTriggerHandler.isFirstTimeQueue = false;
                system.debug('StudPayFeeIds==>'+set_StudPayFeeIds);
                FEE_StudentExamPaymentQueue queueableJob = new FEE_StudentExamPaymentQueue(set_StudPayFeeIds);
                System.enqueueJob(queueableJob);
            }
        }
    }
    
    public static void HostelRoomRequestUpdate(List<Student_Fee_Payment__c> studentFeePaymentList){
        
        
    }
    //*******Adding new method for sending notifications********//
    /*public static void sendPaymentNotifications(List<Student_Fee_Payment__c> payments) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        
        for (Student_Fee_Payment__c payment : payments) {
             // if (payment.Line_Item_Payment_Status__c == 'Success' && payment.Student_Fee__c != null && payment.Student_Fee__r.Fee_Type__c=='Hostel Fee') {
                if (payment.Line_Item_Payment_Status__c == 'Success' && payment.Student_Fee__c != null ) { 
                // Call the asynchronous PDF generation method from the PDFGenerator class
                RHStudentFeePaymentReceiptPDFGenerator.generateReceiptPDFAsync(payment.Id);
                
            }
        }
        
        // Send emails
        if (!emailMessages.isEmpty()) {
            Messaging.sendEmail(emailMessages);
        }
    }*/
    
    //*ending of changes*//
}