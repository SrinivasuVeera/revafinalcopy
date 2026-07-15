public without sharing class ExecuteBatch_Ctrl 
{
    @AuraEnabled
    public static WrapperClass ExecuteBatchClass()
    {
        WrapperClass objwrp = new WrapperClass();
        list<AsyncApexJob> lst_ApexJob = [SELECT ApexClassId,ApexClass.Name,JobType,Status FROM AsyncApexJob WHERE JobType = 'BatchApex' and 
                                          ApexClass.Name ='FEE_AutoPayment_Batch' and (Status='Processing' or Status='Queued' or Status='Preparing')];
        
        system.debug('+++++++++'+lst_ApexJob.size());
        if(lst_ApexJob.size() > 0)
        {
         //   for(AsyncApexJob objJob : lst_ApexJob)
         //   { 
                objwrp.Message ='Batch is Already Executed';
         //   }
        }
        else if(lst_ApexJob.size() == 0)
        {
           // objwrp.Message='Batch is Already Executed';
           Id batchJobId = Database.executeBatch(new FEE_AutoPayment_Batch(),10);
           objwrp.Message ='Fee Allocation Batch Executed';
        }
        return objwrp;
    }
    
    public class WrapperClass
    {
        @AuraEnabled public string Message{get;set;}
    }  
}