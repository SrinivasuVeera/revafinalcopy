global class FEE_UpdateDueDateBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        return Database.getQueryLocator([SELECT Id,Name,Fee_Type__c,Due_Date__c,Contact__r.RecordTypeId,Actual_Program_Fee__c,Contact__r.Student_Status__c,Contact__c,Session__c,Amount_Pending__c,Program_Enrollment__c,Program_Enrollment__r.hed__Program_Plan__c,Contact__r.Enrollment_Type__c 
                                         FROM Student_Fee__c WHERE Contact__c != null AND Amount_Pending__c > 0 AND (Fee_Type__c ='University Fee' or Fee_Type__c ='Tuition Fee')
                                         AND Contact__r.Student_Status__c = 'Pursuing' 
                                         AND Contact__r.RecordTypeId = :ContactRecTypeId]);
    }
    global void execute(Database.BatchableContext BC, List<Student_Fee__c> lst_StuFee)
    {
        set<id> set_ConIds = new set<id>();
        set<id> set_BatchIds = new set<id>();
        List<Student_Fee__c> lst_UpStuFee = new List<Student_Fee__c>();
        map<id,list<hed__Term__c>> map_term = new map<id,list<hed__Term__c>>();
        for(Student_Fee__c objStu : lst_StuFee)
        {
            set_ConIds.add(objStu.Contact__c);
        }  
        if(!set_ConIds.isEmpty())
        {
            for(hed__Program_Enrollment__c objProgEnroll : [Select Id,Active__c,hed__Program_Plan__c,hed__Contact__c from 
                                                            hed__Program_Enrollment__c where hed__Contact__c in: set_ConIds and Active__c=true])
            {
                set_BatchIds.add(objProgEnroll.hed__Program_Plan__c);
            }
        }
        if(!set_BatchIds.isEmpty())
        {
            for(hed__Term__c objTerm : [Select Id,Name,hed__Start_Date__c,IA_1_Start_date__c,IA_2_Start_date__c,Program_Batch__c,Term_Number__c from hed__Term__c 
                                        where Program_Batch__c in: set_BatchIds])
            {
                if(map_term.get(objTerm.Program_Batch__c) == null)
                {
                    list<hed__Term__c> lst_term = new list<hed__Term__c>();
                    lst_term.add(objTerm);
                    map_term.put(objTerm.Program_Batch__c,lst_term);
                }
                else
                {
                    map_term.get(objTerm.Program_Batch__c).add(objTerm);
                }
            }
            for(Student_Fee__c objStu : lst_StuFee)
            {
                if(map_term.get(objStu.Program_Enrollment__r.hed__Program_Plan__c) != null)
                {
                    List<String> strList = new list<String>();
                    if(objStu.Session__c != null)
                    {
                        strList = objStu.Session__c.split('');
                    }
                    for(hed__Term__c objTerm : map_term.get(objStu.Program_Enrollment__r.hed__Program_Plan__c))
                    {
                        if(!strList.isEmpty() && strList[0] =='1' &&  objTerm.Term_Number__c ==1)
                        {
                            Student_Fee__c objNewStuFee = new Student_Fee__c();
                            objNewStuFee.Id = objStu.Id;
                            If(objStu.Fee_Type__c == 'University Fee' && objTerm.hed__Start_Date__c != null)
                                objNewStuFee.Due_Date__c =  objTerm.hed__Start_Date__c.adddays(59);
                            else if(objStu.Fee_Type__c == 'Tuition Fee' && objTerm.hed__Start_Date__c != null)
                                objNewStuFee.Due_Date__c =  objTerm.hed__Start_Date__c.adddays(60);
                            lst_UpStuFee.add(objNewStuFee);
                        }
                        if (!strList.isEmpty() && strList[0] == '2' && objTerm.Term_Number__c == 3) {
                            Student_Fee__c objNewStuFee = new Student_Fee__c();
                            objNewStuFee.Id = objStu.Id;
                            
                            if (objStu.Contact__r.Enrollment_Type__c == 'Regular Entry') {
                                // Regular Entry logic
                                if (objStu.Fee_Type__c == 'University Fee' && objTerm.hed__Start_Date__c != null) {
                                    objNewStuFee.Due_Date__c = objTerm.hed__Start_Date__c.addDays(59);
                                } else if (objStu.Fee_Type__c == 'Tuition Fee' && objTerm.hed__Start_Date__c != null) {
                                    objNewStuFee.Due_Date__c = objTerm.hed__Start_Date__c.addDays(60);
                                }
                            } else if (objStu.Contact__r.Enrollment_Type__c == 'Lateral Entry') {
                                // Lateral Entry logic
                                if (objStu.Fee_Type__c == 'University Fee' && objTerm.IA_1_Start_date__c != null) {
                                    objNewStuFee.Due_Date__c = objTerm.IA_1_Start_date__c.addDays(-1);
                                } else if (objStu.Fee_Type__c == 'Tuition Fee' && objTerm.IA_1_Start_date__c != null) {
                                    objNewStuFee.Due_Date__c = objTerm.IA_1_Start_date__c;
                                }
                            }
                            
                            lst_UpStuFee.add(objNewStuFee);
                        }
                        if(!strList.isEmpty() && strList[0] =='3' &&  objTerm.Term_Number__c ==5)
                        {
                            Student_Fee__c objNewStuFee = new Student_Fee__c();
                            objNewStuFee.Id = objStu.Id;
                            If(objStu.Fee_Type__c == 'University Fee' && objTerm.hed__Start_Date__c != null)
                                objNewStuFee.Due_Date__c =  objTerm.hed__Start_Date__c.adddays(59);
                            else if(objStu.Fee_Type__c == 'Tuition Fee' && objTerm.hed__Start_Date__c != null)
                                objNewStuFee.Due_Date__c =  objTerm.hed__Start_Date__c.adddays(60);
                            lst_UpStuFee.add(objNewStuFee);
                        }
                        if(!strList.isEmpty() && strList[0] =='4' &&  objTerm.Term_Number__c ==7)
                        {
                            Student_Fee__c objNewStuFee = new Student_Fee__c();
                            objNewStuFee.Id = objStu.Id;
                            If(objStu.Fee_Type__c == 'University Fee' && objTerm.hed__Start_Date__c != null)
                                objNewStuFee.Due_Date__c =  objTerm.hed__Start_Date__c.adddays(59);
                            else if(objStu.Fee_Type__c == 'Tuition Fee' && objTerm.hed__Start_Date__c != null)
                                objNewStuFee.Due_Date__c =  objTerm.hed__Start_Date__c.adddays(60);
                            lst_UpStuFee.add(objNewStuFee);
                        }
                        if(!strList.isEmpty() && strList[0] =='5' &&  objTerm.Term_Number__c ==9)
                        {
                            Student_Fee__c objNewStuFee = new Student_Fee__c();
                            objNewStuFee.Id = objStu.Id;
                            If(objStu.Fee_Type__c == 'University Fee' && objTerm.hed__Start_Date__c != null)
                                objNewStuFee.Due_Date__c =  objTerm.hed__Start_Date__c.adddays(59);
                            else if(objStu.Fee_Type__c == 'Tuition Fee' && objTerm.hed__Start_Date__c != null)
                                objNewStuFee.Due_Date__c =  objTerm.hed__Start_Date__c.adddays(60);
                            lst_UpStuFee.add(objNewStuFee);
                        }
                    }
                }
            }
        }
        if(lst_UpStuFee.size() >0) update lst_UpStuFee;
    }
    global void finish(Database.BatchableContext BC){
        
    }
}