public with sharing class WhatsAppMsgTriggeredSummery {
    
    // returns the integer list of batches Fee Not Paid, Fee Paid and Status - Started, Fee Paid and Status - Incomplete , PAF Pending
    @AuraEnabled(cacheable=true)
    public static List<Integer> getWhatsAppTriggerCount(){
        Integer currentYear = Date.today().year();
        String batchYearPrefix = String.valueOf(currentYear);

        List<Integer> batchData = new List<Integer>();
        
            Integer batch1Count = [SELECT Id, Name,Mobilephone, CreatedDate,Primary_Academic_Program__r.Name,Program_Batch_Name__c FROM Contact
            WHERE Program_Batch_Name__c  LIKE : '%'+batchYearPrefix+ '%' AND Application_Fee_Paid__c = False AND Primary_Academic_Program__c != null AND Record_Type_Name__c = 'Applicant'
            AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_MONTH(CreatedDate) = 12
            AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))].size();

            batchData.add(batch1Count);          

            Integer batch2Count = [select id, Application_Number__c,hed__Applicant__r.Mobilephone,hed__Applicant__r.name,hed__Application_Status__c,hed__Applicant__r.Application_Fee_Paid__c,hed__Applicant__r.Admission_Mode__c,hed__Applicant__r.Program_Batch__c from hed__Application__c 
            WHERE hed__Applicant__r.Application_Fee_Paid__c = true and hed__Applicant__r.Admission_Mode__c != null and hed__Applicant__r.Program_Batch__c !=null and hed__Applicant__r.Record_Type_Name__c='Applicant'  and hed__Applicant__r.Program_Batch__r.Name LIKE : '%'+batchYearPrefix+ '%' and hed__Application_Status__c='Started'
            AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_MONTH(CreatedDate) = 12 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))].Size();
             
            batchData.add(batch2Count);

            Integer batch3Count = [select id, Application_Number__c,hed__Applicant__r.Mobilephone,hed__Applicant__r.name,hed__Application_Status__c,hed__Applicant__r.Application_Fee_Paid__c,hed__Applicant__r.Admission_Mode__c,hed__Applicant__r.Program_Batch__c from hed__Application__c 
                                       where hed__Applicant__r.Application_Fee_Paid__c = true and hed__Applicant__r.Admission_Mode__c != null and hed__Applicant__r.Program_Batch__c !=null and hed__Applicant__r.Record_Type_Name__c='Applicant' and  hed__Applicant__r.Program_Batch__r.Name LIKE : '%'+batchYearPrefix+ '%' AND hed__Application_Status__c='Incomplete'
                                      AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_MONTH(CreatedDate) = 12 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))].size();
       
            batchData.add(batch3Count);
            
            Integer batchPAFPendingCount = [SELECT id, 
                                                    Application_Number__c,
                                                    hed__Applicant__r.Mobilephone,
                                                    hed__Applicant__r.name,
                                                    hed__Application_Status__c,
                                                    hed__Applicant__r.Application_Fee_Paid__c,
                                                    hed__Applicant__r.Admission_Mode__c,
                                                    hed__Applicant__r.Program_Batch__r.Name,
                                                    Provisional_Admission_Fee_Paid__c, 
                                                    hed__Applicant__r.Owner.Name, 
                                                    hed__Applicant__r.Owner.Phone
                                            FROM hed__Application__c 
                                            WHERE hed__Applicant__r.Application_Fee_Paid__c = true 
                                                AND  hed__Applicant__r.Program_Batch__r.Name LIKE : '%'+'('+batchYearPrefix+'%'
                                                AND hed__Applicant__r.Admission_Mode__c != null 
                                                AND hed__Applicant__r.Record_Type_Name__c='Applicant' 
                                                AND hed__Applicant__r.Program_Type__c != 'Ph.D'										    
                                                AND hed__Application_Status__c IN ('Interested', 'In Review','Awaiting Documents', 'Admit', 'Application Lost')
                                                AND Provisional_Admission_Fee_Paid__c = false].Size();
            
            batchData.add(batchPAFPendingCount);            
            return batchData;    
    }
    
    
    @AuraEnabled(cacheable=true)
    public static AsyncApexJob getWhatsAppTriggerDate(){         
        
            // This Query returns the completed date of WhatsAppFollowUpBatch1 batch
            AsyncApexJob feeNotPaidBatchDate = [SELECT CompletedDate
            FROM AsyncApexJob
            WHERE JobType = 'BatchApex'and ApexClass.Name = 'WhatsAppFollowUpBatch1' 	
           // WHERE JobType = 'BatchApex'and ApexClass.Name = 'EngageCampaignRecipientBatchDelete' 	
            AND Status = 'Completed'
            ORDER BY CompletedDate DESC
           // ORDER BY CompletedDate ASC
            LIMIT 1];
            
            return feeNotPaidBatchDate;        
    }

    // This method returns Fee paid count of WhatsAppMessage Triggered through batch apex
    @AuraEnabled(cacheable=true)
    public static Integer getApplicationFeePaidCount(DateTime lastBatchRanDateTime){    

            Integer feePaidCount = [SELECT Id,Transaction_ID__c,Fee_Type__c, Payment_Status__c, Payment_Date_Time__c 
            FROM Student_Payment__c 
            WHERE Fee_Type__c = 'Application Fee' AND Payment_Status__c = 'Success' AND Payment_Date_Time__c >=: lastBatchRanDateTime].size();

            return feePaidCount;
    }

    // This method returns Provisional Admission Feepaid count of WhatsAppMessage Triggered through batch apex
    @AuraEnabled(cacheable=true)
    public static Integer getProvisionalAdmissionFeePaid(DateTime lastBatchRanDateTime){    
        Integer currentYear = Date.today().year();
        String batchYearPrefix = String.valueOf(currentYear); 

            Integer PAFpaid = [SELECT id,
                    Application_Number__c,
                    hed__Applicant__r.Mobilephone,
                    hed__Applicant__r.name,
                    hed__Application_Status__c,
                    hed__Applicant__r.Application_Fee_Paid__c,
                    hed__Applicant__r.Admission_Mode__c,
                    hed__Applicant__r.Program_Batch__r.Name,
                    Provisional_Admission_Fee_Paid__c, 
                    hed__Applicant__r.Owner.Name, 
                    hed__Applicant__r.Owner.Phone
            FROM hed__Application__c 
            WHERE 
            hed__Applicant__r.Application_Fee_Paid__c = true 
                AND  hed__Applicant__r.Program_Batch__r.Name LIKE : '%'+'('+batchYearPrefix+'%'
                AND hed__Applicant__r.Admission_Mode__c != null 
                AND hed__Applicant__r.Record_Type_Name__c='Applicant' 
                AND hed__Applicant__r.Program_Type__c != 'Ph.D'
                AND hed__Application_Status__c IN ('Interested', 'In Review','Awaiting Documents', 'Admit', 'Application Lost')
                AND Provisional_Admission_Fee_Paid__c = true
                AND SystemModstamp >=: lastBatchRanDateTime].size();
           
            return PAFpaid;
    }

    @AuraEnabled(cacheable=true)
    public static List<hed__Application__History> getLatestStatusChangeList(DateTime lastBatchRanDateTime){
        List<hed__Application__History> listStatusChange = [SELECT Id,CreatedDate,Field,NewValue,OldValue,ParentId 
                                FROM hed__Application__History 
                                WHERE Field = 'hed__Application_Status__c' AND CreatedDate >=: lastBatchRanDateTime];
        return listStatusChange;
    }
}