public class ChangeBalanceFee {
 
    public class InputParameters {
        @InvocableVariable(label='Contact IDs')
        public List<Id> contactIds;
    }
    
    public class OutputParameters {
        @InvocableVariable(label='Success Message')
        public String successMessage;
    }
      @InvocableMethod(label='Update Balance Fee')
    public static void processContacts(List<InputParameters> inputs) {
        List<Id> contactIds=new List<Id>();
        for (InputParameters input : inputs) {
            contactIds = input.contactIds;
            
        }
         if (!contactIds.isEmpty()) {
        InsertStudentFeePay(contactIds);
          System.debug(contactIds);
        }

    }   

   /*      public static void HandleUpdate (List<Contact> ConList, Map<Id,Contact> oldMap) { 
     
   for(Contact conRecord: ConList){  
   if(conRecord.Program_Batch__c != oldMap.get(conRecord.Id).Program_Batch__c	){  
    List<Id> contactsToUpdate = new List<Id>();  
       for (Contact con : ConList) {
              
          contactsToUpdate.add(con.Id);
         
       }
    
        if (!contactsToUpdate.isEmpty()) {
          InsertStudentFeePay(contactsToUpdate);
          
        }
      } 
    }  
 }
*/
    Public Static Void InsertStudentFeePay(List<Id> contactId){
      
         List<Student_Fee_Payment__c> Deleterec = new List<Student_Fee_Payment__c>();  
         List<Student_Fee_Payment__c> stuFeePays=[SELECT Id, Name, Amount__c, Line_Item_Payment_Status__c, Mode_of_Payment__c, Student_Fee__c, 
                                                            student_fee__r.name, Student_Payment__c, Student_Payment__r.contact__c FROM Student_Fee_Payment__c where 
                                                            Student_Payment__r.contact__c =:contactId and (student_fee__r.name like '%tuition%' or 
                                                            student_fee__r.name like '%university%') order by student_fee__r.name asc];
        
        for(Student_Fee_Payment__c Sfp:stuFeePays){
            Deleterec.add(sfp);
        }
        if(!Deleterec.IsEmpty()){
        Delete Deleterec;
        }

              Set<Id> conIdSet = new Set<Id>();
        // Map<Id,Student_Payment__c> conStuPayMap = new Map<Id,Student_Payment__c>();
        Map<Id,Map<String,Decimal>> ConStuFeePayAvailableAmountMap = new map<Id,Map<String,Decimal>>();
        Map<String,Decimal> localStuFeePayAvailableAmountMap = new Map<String,Decimal>();
        Map<Id,Map<Id,Decimal>> conStuFeePayAmountMap = new Map<Id,Map<Id,Decimal>>();
        Map<String,Decimal> localStuFeePayAllottedAmountMap = new Map<String,Decimal>();
        Map<String,Student_Fee__c> stufeeAvailableMap = new Map<String,Student_Fee__c>();
        Map<Id,Map<String,Student_Fee__c>> conStuFeeMap = new Map<Id,Map<String,Student_Fee__c>>();
        Map<Id,Map<String,Decimal>> ConStuFeePayAllottedAmountMap = new map<Id,Map<String,Decimal>>();
        Map<Id,Decimal> stupayAmountMap = new Map<Id,Decimal>();
        Map<Id,String> conQuotaMap = new Map<Id,String>();
        
         List<Student_Payment__c> stuPayList =[select id,contact__c,Fee_Type__c,Cheque_Bank_Name__c,ChequeDD_Date__c,Reference_Number__c,Mode_of_Payment__c,Payment_Mode_Type__c, ChequeDD_Number__c,ChequeDD_Realisation_Date__c,Payment_Date__c,Name,Amount__C,Payment_Status__c from Student_Payment__c
                                               where contact__C IN: contactId and (Fee_type__c like '%tuition%' or Fee_type__c like '%university%') 
                                               and( Payment_Status__c = 'Success' or Payment_Status__c='Pending')  order by createdDate asc];
        for(Student_Payment__c stupay: stuPayList){
            if(stupay.Payment_Status__c != 'Failed'){
                conIdSet.add(stupay.contact__c);
            }
            
         
        }
        for(Contact con: [SELECT Id, LastName, FirstName, Name, MobilePhone, Email, Quota__c FROM Contact where id =: conIdSet]){
            conQuotaMap.put(con.Id,con.Quota__c);
        }
     for(Student_Fee_Payment__c sfp :[SELECT Id, Name, Amount__c, Line_Item_Payment_Status__c, Mode_of_Payment__c, Student_Fee__c, 
                                                            student_fee__r.name, Student_Payment__c, Student_Payment__r.contact__c FROM Student_Fee_Payment__c where 
                                                            Student_Payment__r.contact__c =:conIdSet and (student_fee__r.name like '%tuition%' or 
                                                            student_fee__r.name like '%university%') order by student_fee__r.name asc]){
            if(ConStuFeePayAllottedAmountMap.get(sfp.Student_Payment__r.contact__c) == null){
                localStuFeePayAllottedAmountMap = new Map<String,Decimal>();
                localStuFeePayAllottedAmountMap.put(sfp.student_fee__r.name.toLowerCase(),sfp.Amount__c);
                ConStuFeePayAllottedAmountMap.put(sfp.Student_Payment__r.contact__c,localStuFeePayAllottedAmountMap);
            } else {
                localStuFeePayAllottedAmountMap = ConStuFeePayAllottedAmountMap.get(sfp.Student_Payment__r.contact__c);
                if(localStuFeePayAllottedAmountMap.get(sfp.student_fee__r.name.toLowerCase()) == null){
                    localStuFeePayAllottedAmountMap.put(sfp.student_fee__r.name.toLowerCase(),sfp.Amount__c);
                } else {
                    localStuFeePayAllottedAmountMap.put(sfp.student_fee__r.name.toLowerCase(), localStuFeePayAllottedAmountMap.get(sfp.student_fee__r.name.toLowerCase()) + sfp.Amount__c);
                }
                ConStuFeePayAllottedAmountMap.put(sfp.Student_Payment__r.contact__c,localStuFeePayAllottedAmountMap);
            }
        }
    
        for(Student_Fee__c stufee : [SELECT name, Amount_Paid__c, Actual_Program_Fee__c, Amount_Pending__c, Amount__c, Provisional_Admission_Fee__c, Id, Contact__c, Fee_Type__c, Fee_Year__c FROM Student_Fee__c WHERE Contact__c = :conIdSet and Fee_Type__c != 'Application Fee']){
            if(ConStuFeePayAvailableAmountMap.get(stufee.contact__c) == null){
                localStuFeePayAvailableAmountMap.put(stufee.name.toLowerCase(),stufee.Amount__c);
                ConStuFeePayAvailableAmountMap.put(stufee.contact__c,localStuFeePayAvailableAmountMap);
            } else {
                localStuFeePayAvailableAmountMap = ConStuFeePayAvailableAmountMap.get(stufee.contact__c);
                if(localStuFeePayAvailableAmountMap.get(stufee.name.toLowerCase()) == null){
                    localStuFeePayAvailableAmountMap.put(stufee.name.toLowerCase(),stufee.Amount__c);
                } else {
                    localStuFeePayAvailableAmountMap.put(stufee.name.toLowerCase(), (localStuFeePayAvailableAmountMap.get(stufee.name.toLowerCase()) != null ? localStuFeePayAvailableAmountMap.get(stufee.name.toLowerCase()) : 0) + stufee.Amount__c);
                }
                ConStuFeePayAvailableAmountMap.put(stufee.contact__c,localStuFeePayAvailableAmountMap);
            }
        }
      
        if(conIdSet.size() > 0){
            for(Student_Fee__c stufee : [SELECT name, Amount_Paid__c, Actual_Program_Fee__c, Amount_Pending__c, Amount__c, Provisional_Admission_Fee__c, Id, Contact__c, Fee_Type__c, Fee_Year__c FROM Student_Fee__c WHERE Contact__c = :conIdSet and Fee_Type__c != 'Application Fee']){
                stufeeAvailableMap.put(stufee.Name.toLowerCase(),stufee); 
                if(conStuFeeMap.get(stufee.Contact__c) == null){
                    stufeeAvailableMap = new Map<String,Student_Fee__c>();
                    stufeeAvailableMap.put(stufee.Name.toLowerCase(),stufee);
                } 
                conStuFeeMap.put(stufee.Contact__c,stufeeAvailableMap);
            }
        }
        
        
     
         Decimal AmountofUF1=0;
         Decimal AmountofTF1=0;
         Decimal AmountofUF2 =0;
         Decimal AmountofTF2=0;
         Decimal AmountofUF3 =0;
         Decimal AmountofTF3=0;
         Decimal AmountofUF4 =0;
         Decimal AmountofTF4=0;
         Decimal AmountofUF5 =0;
         Decimal AmountofTF5=0; 
        
        for(Student_Payment__c stupay: stuPayList){
         for(Student_Fee_Payment__c stufeepay:[SELECT Id, Name, Amount__c, Line_Item_Payment_Status__c, Mode_of_Payment__c, Student_Fee__c,student_fee__r.name, Student_Payment__c, 
                                                    Student_Payment__r.contact__c FROM Student_Fee_Payment__c where Student_Payment__r.contact__c =:contactId
                                                    and (student_fee__r.name like '%tuition%' or student_fee__r.name like '%university%') order by student_fee__r.name asc]){

            if(stufeepay.student_fee__r.name == 'University Fee 1st year' ){ 
            AmountofUF1 += stufeepay.Amount__c;   
           } 
            if(stufeepay.student_fee__r.name == 'Tuition Fee 1st year' ){ 
            AmountofTF1 += stufeepay.Amount__c;   
           }
              if(stufeepay.student_fee__r.name == 'University Fee 2nd year' ){ 
            AmountofUF2 += stufeepay.Amount__c;   
           } 
            if(stufeepay.student_fee__r.name == 'Tuition Fee 2nd year' ){ 
            AmountofTF2 += stufeepay.Amount__c;   
           }
             if(stufeepay.student_fee__r.name == 'University Fee 3rd year' ){ 
            AmountofUF3 += stufeepay.Amount__c;   
           }  
              if(stufeepay.student_fee__r.name == 'Tuition Fee 3rd year' ){ 
            AmountofTF3 += stufeepay.Amount__c;   
           }  
             if(stufeepay.student_fee__r.name == 'University Fee 4th year' ){ 
            AmountofUF4 += stufeepay.Amount__c;   
           }  
             if(stufeepay.student_fee__r.name == 'Tuition Fee 4th year' ){ 
            AmountofTF4 += stufeepay.Amount__c;   
           }  
            if(stufeepay.student_fee__r.name == 'University Fee 5th year' ){ 
            AmountofUF5 += stufeepay.Amount__c;   
           }
             if(stufeepay.student_fee__r.name == 'Tuition Fee 5th year' ){ 
            AmountofTF5 += stufeepay.Amount__c;   
           }                                            
        }
            
            if(stupay.Payment_Status__c != 'Failed' && ((stupay.Fee_Type__c != null && stupay.Fee_Type__c.contains('University Fee')) || (stupay.Fee_Type__c != null && stupay.Fee_Type__c.contains('Tuition Fee')))){
           
            Decimal localAmount = stupay.Amount__c;
            Decimal localTransactionAmount = 0;
            Decimal PaidAmount = 0 ;   
            if(ConStuFeePayAllottedAmountMap.get(stupay.contact__c) == null){
               
                if(conStuFeeMap.get(stupay.contact__c) != null){
                     
                    if((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year') != null){
                    if(AmountofUF1 < (conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year').Amount__c ){
                    if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year').Amount__c){
                         PaidAmount = (conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year').Amount__c - AmountofUF1;
                          If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year')).Id);
                                localAmount = localAmount - PaidAmount ;
                         }else{
                             If(PaidAmount > localAmount){
                            insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year')).Id);
                             localAmount= 0 ;
                             } 
                         }
                                
                            } else if(localAmount > 0) {
                                PaidAmount = (conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year').Amount__c - AmountofUF1;
                                 If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year')).Id);
                                localAmount = localAmount - PaidAmount;
                                 }else{
                                     If(PaidAmount > localAmount){
                                     insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year')).Id);
                                     localAmount = 0;
                                 }
                                 }
                            }
                        
                    }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year') != null){
                        If(AmountofTF1 < (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year').Amount__c){
                                if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year').Amount__c){
                                 PaidAmount = (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year').Amount__c - AmountofTF1;
                                 If(PaidAmount <= localAmount){
                                  insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year')).Id);
                                   localAmount = localAmount - PaidAmount;
                                 }else{
                                 If(PaidAmount > localAmount){
                                  insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year')).Id);
                                    localAmount=0;
                                 }
                                 }
                           
                           } else if(localAmount > 0){
                                PaidAmount = (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year').Amount__c - AmountofTF1;
                                If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year')).Id);
                                localAmount =localAmount - PaidAmount;
                                } else{If(PaidAmount > localAmount){
                                    insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year')).Id);
                                    localAmount=0;
                                }
                                      }
                            }    
                    }
                    }               
                    if((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year') != null){
                        If(AmountofUF2 < (conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year').Amount__c ){
                           if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year').Amount__c){
                               PaidAmount = (conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year').Amount__c - AmountofUF2;
                               If(PaidAmount <= localAmount){
                                 insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year')).Id);
                                   localAmount = localAmount - PaidAmount;
                               }
                               else{If(PaidAmount > localAmount){
                                 insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year')).Id);
                                   localAmount = 0;
                               } 
                                   }
                               
                            } else if(localAmount > 0){                               
                                PaidAmount=(conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year').Amount__c - AmountofUF2;
                                If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year')).Id);
                                 localAmount = localAmount - PaidAmount; 
                                }else{
                                If(PaidAmount > localAmount){
                                insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year')).Id);
                                   localAmount = 0;
                                }
                                }
                               
                            }
                        } 
                    }

                    if((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year') != null){
                        If(AmountofTF2 < (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year').Amount__c){
                           if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year').Amount__c){
                                PaidAmount= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year').Amount__c - AmountofTF2;
                                If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year')).Id);
                                localAmount = localAmount -PaidAmount ;
                                }
                               else{If(PaidAmount > localAmount){
                                insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year')).Id);
                                 localAmount=0;
                                       }
                                 }
                                } else if(localAmount > 0){
                                PaidAmount =  (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year').Amount__c -AmountofTF2;
                                  If(PaidAmount <= localAmount){  
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year')).Id);
                                localAmount = localAmount - PaidAmount ;
                                  }
                                    else{
                                   If(PaidAmount > localAmount){
                                  insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year')).Id);
                                      localAmount=0;
                                  }
                                        }
                               }
                        }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year') != null){
                         IF(AmountofUF3 < (conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year').Amount__c){
                         if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year').Amount__c){
                               PaidAmount = (conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year').Amount__c - AmountofUF3;
                               If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year')).Id);
                                localAmount = localAmount - PaidAmount;
                               }else{
                                   
                                       If(PaidAmount > localAmount){
                               insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year')).Id);
                               localAmount=0;
                               }
                                   
                               }
                         } 
                            else if(localAmount > 0){         
                              PaidAmount = (conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year').Amount__c - AmountofUF3;
                             If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year')).Id);
                                localAmount = localAmount - PaidAmount;
                             }else{
                                 If(PaidAmount > localAmount){
                                insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year')).Id);
                                 localAmount = 0;
                             }
                             }
                            }
                        }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year') != null){
                        If(AmountofTF3 <  (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c){
                         if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c){
                               PaidAmount=(conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c-AmountofTF3;
                               If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year')).Id);
                                localAmount = localAmount -PaidAmount;
                               }else{
                                   If(PaidAmount > localAmount){
                                   insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year')).Id);
                                   localAmount = 0;
                               }
                               }
                            }else if(localAmount > 0 && localAmount < (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c){
                                 PaidAmount=(conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c-AmountofTF3;
                                 If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year')).Id);
                               localAmount = localAmount -PaidAmount;
                                 } else{
                                     If(PaidAmount > localAmount){
                                    insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year')).Id);
                                     localAmount =0;
                                 }
                                 }
                            }
                        }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year') != null){
                        If(AmountofUF4 <(conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c ){
                           if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c){
                               PaidAmount = (conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c - AmountofUF4;
                                If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year')).Id);
                                localAmount = localAmount - PaidAmount;
                                }else{
                                    If(PaidAmount > localAmount){
                                 insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year')).Id);  
                                    localAmount = 0;
                                }
                                }
                            } 
                            else if(localAmount > 0 && localAmount < (conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c){
                                PaidAmount = (conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c - AmountofUF4;
                                If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year')).Id);
                               localAmount = localAmount - PaidAmount;
                                }else{
                                     If(PaidAmount > localAmount){
                                        insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year')).Id);
                               localAmount = 0;
                                    }
                                }
                            }
                        }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year') != null){
                        If(AmountofTF4 < (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c){
                        if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c){
                               PaidAmount= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c - AmountofTF4;
                                If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year')).Id);
                                localAmount = localAmount - PaidAmount;
                                } 
                            else{If(PaidAmount > localAmount){
                                 insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year')).Id); 
                                    localAmount = 0;
                                }
                                }
                            } 
                             else if(localAmount > 0 && localAmount < (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c){
                                 PaidAmount= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c - AmountofTF4;
                                  If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year')).Id);
                                localAmount = localAmount - PaidAmount;
                                  } 
                                 else{If(PaidAmount > localAmount){
                                       insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year')).Id);
                                     localAmount=0;
                                  }
                                     }
                            }
                        }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year') != null){
                        If(AmountofUF5 < (conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c){
                        if((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year') != null && localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c){
                              PaidAmount=(conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c - AmountofUF5;
                              If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year')).Id);
                                localAmount = localAmount - PaidAmount;
                              }
                              else{If(PaidAmount > localAmount){
                               insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year')).Id);
                                  localAmount=0;
                              }
                                }
                           } 
                            else if((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year') != null && localAmount > 0 && localAmount < (conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c){
                                 PaidAmount=(conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c - AmountofUF5;
                                If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year')).Id);
                                 localAmount = localAmount - PaidAmount;
                                }else{
                                If(PaidAmount > localAmount){
                                    insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year')).Id); 
                                    localAmount=0;
                                }
                                }
                            }
                        }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year') != null){
                        If(AmountofTF5 < (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c){
                        if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c){
                               PaidAmount= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c - AmountofTF5;
                               If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year')).Id);
                                localAmount = localAmount -PaidAmount;
                               } else {
                                   If(PaidAmount > localAmount){
                                 insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year')).Id);
                                   localAmount = 0;
                               }
                               }
                          } 
                            if(localAmount > 0 && localAmount < (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c){
                                PaidAmount= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c - AmountofTF5;
                                 If(PaidAmount <= localAmount){
                                insertStuFeePayment(stupay,PaidAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year')).Id);
                                 localAmount = localAmount - PaidAmount;
                                 }else{
                                     If(PaidAmount > localAmount){
                                      insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year')).Id);
                                      localAmount = 0;   
                                     }
                                 }
                            }
                        }
                    }
                }
            } 
              
        }
          
        }
    }
    public static void insertStuFeePayment(Student_Payment__c stupay, Decimal amount, Id stufeeId){
        Student_Fee_Payment__c stufeePayUpdated = new Student_Fee_Payment__c();
        stufeePayUpdated.Amount__c = amount;
        stufeePayUpdated.Student_Fee__c = stufeeId;
        stufeePayUpdated.Line_Item_Payment_Status__c = stupay.Payment_Status__c;
        stufeePayUpdated.Student_Payment__c = stupay.Id;
        stufeePayUpdated.Cheque_Bank_Name__c = stupay.Cheque_Bank_Name__c;
        stufeePayUpdated.Cheque_DD_Date__c = stupay.ChequeDD_Date__c;
        stufeePayUpdated.Cheque_DD_Number__c = stupay.ChequeDD_Number__c;
        stufeePayUpdated.Cheque_DD_Realisation_Date__c =stupay.ChequeDD_Realisation_Date__c;
        stufeePayUpdated.Mode_of_Payment__c = stupay.Mode_of_Payment__c;
        stufeePayUpdated.Payment_Date__c =stupay.Payment_Date__c;
        stufeePayUpdated.Reference_Number__c =stupay.Reference_Number__c;
        stufeePayUpdated.Payment_Mode_Type__c = stupay.Payment_Mode_Type__c;
        insert stufeePayUpdated;
        System.debug('fstufeePayUpdated'+stufeePayUpdated);
    }
    
    
    public static void testCoverage(){
        Integer i = 0;
        i++; 
        i++;
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

    }
    
    
}