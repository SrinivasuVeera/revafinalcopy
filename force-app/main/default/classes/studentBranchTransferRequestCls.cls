public without sharing class studentBranchTransferRequestCls{
    
    @AuraEnabled
    public static WrapperClass getRecordDetail(){
        WrapperClass wrp = new WrapperClass();
        wrp.schoolPicklist = new map<string,string>();
        wrp.branchPicklist = new map<string,string>();
        wrp.ErrorMsg = 'Success';
        //string currentUser = '0050w000004OA1A';
        string currentUser = UserInfo.getUserId();        
        user usr = [SELECT id,contactId FROM USER WHERE id =: currentUser];
        integer beforeStartDays = integer.valueof(label.BranchTransferDays);
        list<hed__Term_Grade__c> lstResult = new list<hed__Term_Grade__c>();
        
        if(string.isNotBlank(usr.contactId)){
            list<account> lstSchools = new list<account>();
            contact objCon = [SELECT id,Name,School__c,School__r.Name,School__r.ParentId,School__r.Parent.Name,SRN_Number__c, 
                                School__r.Parent.UG_Start_date__c,School__r.Parent.UG_End_Date__c,School__r.Parent.PG_Start_Date__c,
                                School__r.Parent.PG_End_Date__c,Application_Number__c FROM Contact WHERE id =: usr.contactId];
                                
            for(hed__Term_Grade__c tg : [SELECT id FROM hed__Term_Grade__c WHERE hed__Contact__c =: usr.contactId AND 
                                          hed__Result__c != 'Pass' AND Result_Summary__c != Null]){
                lstResult.add(tg);                              
            }                    
            
            hed__Program_Enrollment__c objPe = [SELECT id,Semester__c,Semester__r.Name,Branch_Transfer_Flag__c,Branch_Transfer_Status__c, 
                                                 Semester__r.Term_Number__c,Semester__r.hed__Start_Date__c,Semester__r.IA_1_Start_date__c, 
                                                 hed__Account__c,hed__Account__r.Name,Requested_School__c,Requested_School__r.Name,
                                                 Requested_Program__c,Requested_Program__r.Name,Program_Type__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: objCon.id];
                                                 
            for(account acc : [SELECT id,Name FROM Account WHERE parentId =: objCon.School__r.ParentId AND id !=: objCon.School__c]){
                lstSchools.add(acc);
            }                                      
            
            wrp.Name = objCon.Name;
            wrp.currentSchool = objCon.School__r.Name;
            wrp.currentProgram = objPe.hed__Account__r.Name;
            wrp.currentSemester = objPe.Semester__r.Name; 
            wrp.srn = objCon.SRN_Number__c;
            wrp.applicationNo = objCon.Application_Number__c;
            
                              //  if(objPe.Branch_Transfer_Status__c == 'Rejected' || string.isBlank(objPe.Branch_Transfer_Status__c)){

            date dt = system.today();
            if(objCon.School__r.Parent.Name == 'Faculty of Engineering & Technology'){
            system.debug('++++++test1');
                if((objPe.Program_Type__c == 'UG' && objCon.School__r.Parent.UG_Start_date__c <= dt && objCon.School__r.Parent.UG_End_Date__c >= dt) || 
                    (objPe.Program_Type__c == 'PG' && objCon.School__r.Parent.PG_Start_date__c <= dt && objCon.School__r.Parent.PG_End_Date__c >= dt) ){
                    system.debug('++++++test2');
                    if(objPe.Semester__r.Term_Number__c == 1 || objPe.Semester__r.Term_Number__c == 3){
                        system.debug('++++++test3');
                        if(lstResult.size() == 0){
                            system.debug('++++++test4');
                            if(objPe.Semester__r.hed__Start_Date__c != Null && objPe.Semester__r.IA_1_Start_date__c != Null){
                                system.debug('++++++test5');
                                if(objPe.Semester__r.hed__Start_Date__c <= dt && objPe.Semester__r.IA_1_Start_date__c >= dt){
                                    system.debug('++++++test6');
                                    integer days = dt.daysBetween(objPe.Semester__r.IA_1_Start_date__c);
                                    if(days > beforeStartDays){
                                    system.debug('++++++test7');
                                        wrp.contactId = objCon.id;
                                        wrp.programEnrollmentId = objPe.Id; 
                                        wrp.Name = objCon.Name;
                                        wrp.currentSchool = objCon.School__r.Name;
                                        wrp.currentProgram = objPe.hed__Account__r.Name;
                                        wrp.currentSemester = objPe.Semester__r.Name; 
                                        wrp.srn = objCon.SRN_Number__c;
                                        wrp.applicationNo = objCon.Application_Number__c;
                                        wrp.programType = objPe.Program_Type__c;
                                        for(account acc : lstSchools){
                                            wrp.schoolPicklist.put(acc.id,acc.Name);
                                        }
                                        if(objPe.Requested_School__c != Null){
                                            wrp.schoolPicklist.put(objPe.Requested_School__c,objPe.Requested_School__r.Name);
                                            wrp.selectedSchool = objPe.Requested_School__c;
                                        }
                                        if(objPe.Requested_Program__c != Null){
                                            wrp.branchPicklist.put(objPe.Requested_Program__c,objPe.Requested_Program__r.Name);
                                            wrp.selectedBranch = objPe.Requested_Program__c;
                                        }
                                        wrp.branchStatus = objPe.Branch_Transfer_Status__c;
                                    }
                                    else{
                                        wrp.ErrorMsg = 'More than 5 days';    
                                    }
                                }
                                else{
                                
                                    wrp.ErrorMsg = 'Date not Between Today';
                                }
                            }  
                            else{
                                wrp.ErrorMsg = 'Date is Blank';
                            } 
                        }
                        else{
                            wrp.ErrorMsg = 'Result Not Matched';
                        }     
                    }
                    else{
                        wrp.ErrorMsg = 'Term Number Not Matched';
                    }
                }
                else{
                    wrp.ErrorMsg = 'You are not authorized for this feature..!!';
                }
            }
            else{
                wrp.ErrorMsg = 'Parent Account Not Matched';
            }                       
        }
        else{
            wrp.ErrorMsg = 'Portal account not available for this user';        
        }
        
        
        return wrp;
    }    
    
    @AuraEnabled
    public static WrapperClass getBranchDetail(string schoolId,string type){
        WrapperClass wrp = new WrapperClass();
        wrp.branchPicklist = new map<string,string>();
        wrp.ErrorMsg = 'Success';
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        for(account acc : [SELECT id,Name,Program_Type__c FROM Account WHERE parentId =: schoolId AND RecordTypeId =: rtId AND Program_Type__c =: type]){
            wrp.branchPicklist.put(acc.id,acc.Name);
        }
        
        return wrp;
    }
    
    @AuraEnabled
    public static WrapperClass getUpdateEnrollment(WrapperClass wrp){
    
        hed__Program_Enrollment__c pErl = [SELECT id,hed__Program_Plan__r.hed__Start_Date__c,hed__Program_Plan__r.hed__End_Date__c FROM 
                                         hed__Program_Enrollment__c WHERE id =: wrp.programEnrollmentId];
                                         
        integer syear =  pErl.hed__Program_Plan__r.hed__Start_Date__c.year();
        integer eyear =  pErl.hed__Program_Plan__r.hed__End_Date__c.year();                                 
                                         
        hed__Program_Plan__c ppl = [SELECT id FROM hed__Program_Plan__c WHERE hed__Account__c =: wrp.selectedBranch AND Active__c = true 
                                    AND CALENDAR_YEAR(hed__Start_Date__c) =: syear AND CALENDAR_YEAR(hed__End_Date__c) =: eyear];                                  
        system.debug('++++++++'+ppl);
    
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c();
        pe.id = wrp.programEnrollmentId;
        pe.Branch_Transfer_Status__c = 'Submitted';
        pe.Requested_School__c = wrp.selectedSchool;
        pe.Requested_Program__c = wrp.selectedBranch;
        pe.Requested_Date__c = system.today();
        pe.Branch_Transfer_Flag__c = true;
        pe.Requesting_Program_Batch__c = ppl.id;
        update pe;        
        wrp.branchStatus = 'Submitted';
        return wrp;
    }
    
    public class WrapperClass
    {
        @AuraEnabled public string contactId {get;set;}
        @AuraEnabled public string programEnrollmentId {get;set;}
        @AuraEnabled public string Name {get;set;}
        @AuraEnabled public string currentSchool {get;set;}
        @AuraEnabled public string currentProgram {get;set;}
        @AuraEnabled public string currentSemester {get;set;}
        @AuraEnabled public string srn {get;set;}
        @AuraEnabled public string applicationNo {get;set;}
        @AuraEnabled public Map<string,string> schoolPicklist {get;set;}
        @AuraEnabled public string selectedSchool {get;set;}
        @AuraEnabled public Map<string,string> branchPicklist {get;set;}
        @AuraEnabled public string selectedBranch {get;set;}
        @AuraEnabled public string ErrorMsg {get;set;} 
        @AuraEnabled public string branchStatus {get;set;} 
        @AuraEnabled public string programType{get;set;}
    }
   
}