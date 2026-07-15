public without sharing class OfflinePaymentIntiated {

    Public static void HandleUpdate(List<Student_Payment__c> newPayments, Map<Id, Student_Payment__c> oldMap){
         Set<Id> contactIdsToUpdate = new Set<Id>();
         List<Student_Payment__c> successStuPayList = new List<Student_Payment__c>();
         List<Student_Payment__c> pendingStuPayList = new List<Student_Payment__c>();
        for(Student_Payment__c newPayment: newPayments ){
            // Student_Payment__c Oldpayment= new Student_Payment__c();
            // if (newPayment.Amount__c != oldPayment.Amount__c) {
                contactIdsToUpdate.add(newPayment.Contact__c);
            // }
            if(newPayment.Payment_Status__c == 'Success'){
                successStuPayList.add(newPayment);
            } else if(newPayment.Payment_Status__c == 'Pending'){
                pendingStuPayList.add(newPayment);
            }
        }
        if (!contactIdsToUpdate.isEmpty()) {
            updatePAFApplicationCheckbox(contactIdsToUpdate);
        }
        if(successStuPayList.size() > 0){
            updateStudentFeePayments(successStuPayList);
        }
        if(pendingStuPayList.size() > 0){
             //createStudentFeePayments(pendingStuPayList);
        }
        
    }

    public static void updateStudentFeePayments(List<Student_Payment__c> stuPayList){
        Set<Id> conIdSet = new Set<Id>();
        List<Student_Fee_Payment__c> stuFeePayList = new List<Student_Fee_Payment__c>();
        for(Student_Payment__c stupay: stuPayList){
            conIdSet.add(stupay.contact__c);
        }
        for(Student_Fee_Payment__c stufeepay : [SELECT Id, Name, Amount__c, Mode_of_Payment__c, Student_Fee__c, Student_Fee__r.name, Student_Payment__c, Transaction_Status__c, Student_Fee__r.contact__c FROM Student_Fee_Payment__c where student_fee__r.contact__c IN :conIdSet]){
            stuFeePayList.add(stufeepay);
        }
        for(Student_Payment__c stupay : stuPayList){
            for(Student_Fee_Payment__c stufeepay : stuFeePayList){
                if(stupay.id == stufeepay.Student_Payment__c){
                    updateStuFeePayment(stupay.Id,stufeepay.Id);
                }
            }
            
        }
    }

    public static void filterApplicantsOnly(List<Student_Payment__c> stuPayList){
        List<Student_Payment__c> stuPayListUpdated = new List<Student_Payment__c>();
        Set<Id> applicantStuPayIdSet = new Set<Id>();
        Set<Id> conIdSet = new Set<Id>();
        List<hed__Application__c> appListToUpdate = new List<hed__Application__c>();
        // Map<Id,Student_Payment__c> stuPayMap = new Map<Id,Student_Payment__c>();
        for(Student_Payment__c stupay : stuPayList){
            conIdSet.add(stupay.contact__c);
        }
        // List<Contact> conList = ;
        List<Contact> conList = [
        SELECT Id, RecordType.Name
        FROM Contact
        WHERE Id IN :conIdSet
        AND RecordType.Name = 'Applicant'
    ];

    for(Contact con : conList){
        applicantStuPayIdSet.add(con.Id);
    }
        /*List<hed__Application__c> appList = [
        SELECT Id, hed__Applicant__c, hed__Application_Status__c,
               Offline_Payment_Initiated__c, Provisional_Admission_Fee_Paid__c
        FROM hed__Application__c
            WHERE hed__Applicant__c IN :applicantStuPayIdSet
        ];
    
        for(hed__Application__c app : appList){
            app.hed__Application_Status__c = 'Provisionally Offered';
            appListToUpdate.add(app);
        }
    
        if(!appListToUpdate.isEmpty()){
            update appListToUpdate;
        } 
*/
        if(applicantStuPayIdSet.size() > 0){
            updatePAFApplicationCheckbox(applicantStuPayIdSet);
        } 
        for(Student_Payment__c stupay : stuPayList){
            if(applicantStuPayIdSet.contains(stupay.contact__c)){
                stuPayListUpdated.add(stupay);
            }
        }
        if(stuPayListUpdated.size() > 0){
            createStudentFeePayments(stuPayListUpdated);
        }

    }

    public static void createStudentFeePayments(List<Student_Payment__c> stuPayList){
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
        for(Student_Payment__c stupay: stuPayList){
            if(stupay.Payment_Status__c != 'Success'){
                conIdSet.add(stupay.contact__c);
            }
            
            // conStuPayMap.put(stupay.contact__c,stupay);
        }
        for(Contact con: [SELECT Id, LastName, FirstName, Name, MobilePhone, Email, Quota__c FROM Contact where id IN :conIdSet]){
            conQuotaMap.put(con.Id,con.Quota__c);
        }
        for(Student_Fee_Payment__c sfp :[SELECT Id, Name, Amount__c, Line_Item_Payment_Status__c, Mode_of_Payment__c, Student_Fee__c, 
                                                            student_fee__r.name, Student_Payment__c, Student_Payment__r.contact__c FROM Student_Fee_Payment__c where 
                                                            Student_Payment__r.contact__c IN :conIdSet and (student_fee__r.name like '%tuition%' or 
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
        // System.debug('ConStuFeePayAllottedAmountMap '+ConStuFeePayAllottedAmountMap);
        for(Student_Fee__c stufee : [SELECT name, Amount_Paid__c, Actual_Program_Fee__c, Amount_Pending__c, Amount__c, Provisional_Admission_Fee__c, Id, Contact__c, Fee_Type__c, Fee_Year__c FROM Student_Fee__c WHERE Contact__c IN :conIdSet and Fee_Type__c != 'Application Fee']){
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
        // System.debug('ConStuFeePayAvailableAmountMap '+ConStuFeePayAvailableAmountMap);
        if(conIdSet.size() > 0){
            for(Student_Fee__c stufee : [SELECT name, Amount_Paid__c, Actual_Program_Fee__c, Amount_Pending__c, Amount__c, Provisional_Admission_Fee__c, Id, Contact__c, Fee_Type__c, Fee_Year__c FROM Student_Fee__c WHERE Contact__c IN :conIdSet and Fee_Type__c != 'Application Fee']){
                stufeeAvailableMap.put(stufee.Name.toLowerCase(),stufee); 
                if(conStuFeeMap.get(stufee.Contact__c) == null){
                    stufeeAvailableMap = new Map<String,Student_Fee__c>();
                    stufeeAvailableMap.put(stufee.Name.toLowerCase(),stufee);
                } 
                conStuFeeMap.put(stufee.Contact__c,stufeeAvailableMap);
            }
        }
        // System.debug('conStuFeeMap '+conStuFeeMap);
        for(Student_Payment__c stupay: stuPayList){
            // System.debug('inside student pay for loop '+stupay.contact__c);
            if(stupay.Payment_Status__c != 'Success' && ((stupay.Fee_Type__c != null && stupay.Fee_Type__c.contains('University Fee')) || (stupay.Fee_Type__c != null && stupay.Fee_Type__c.contains('Tuition Fee')))){

           
            Decimal localAmount = stupay.Amount__c;
            Decimal localTransactionAmount = 0;
            if(ConStuFeePayAllottedAmountMap.get(stupay.contact__c) == null){
                // System.debug('1');
                if(conStuFeeMap.get(stupay.contact__c) != null){
                    // System.debug('2 conStuFeeMap.get(stupay.contact__c) '+conStuFeeMap.get(stupay.contact__c));
                    // System.debug('2 conStuFeeMap.get(stupay.contact__c)).get(university fee 1st year)'+ (conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year'));
                    if((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year') != null){
                        // System.debug('3 '+ stupay.contact__r.Quota__c);
                        // System.debug('3 conQuotaMap.get(stupay.Contact__c)'+ conQuotaMap.get(stupay.Contact__c));
                        
                        // if(conQuotaMap.get(stupay.Contact__c) != 'Government Quota'){
                            if(stupay.Amount__c >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year').Amount__c){
                                insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year')).Id);
                                localAmount = stupay.Amount__c - (conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year').Amount__c;
                               System.debug('after university fee 1st year payment localAmount '+localAmount);
                            } else if(localAmount > 0) {
                                insertStuFeePayment(stupay,stupay.Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year')).Id);
                                localAmount = 0;
                                // System.debug('after university fee 1st year payment localAmount else '+localAmount);
                            }
                        // }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year') != null){
                        // System.debug('4 '+ stupay.contact__r.Quota__c);
                        // System.debug('4 conQuotaMap.get(stupay.Contact__c)'+ conQuotaMap.get(stupay.Contact__c));
                        // if(conQuotaMap.get(stupay.Contact__c) != 'Government Quota'){
                            if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year').Amount__c){
                                insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year')).Id);
                                localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year').Amount__c;
                                // System.debug('after tuition fee 1st year payment localAmount '+localAmount);
                            } else if(localAmount > 0){
                                insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year')).Id);
                                localAmount = 0;
                                // System.debug('after tuition fee 1st year payment localAmount else '+localAmount);
                            }       
                        // }         
                    }
                
                    if((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year') != null){
                        // System.debug('5');
                        // if(conQuotaMap.get(stupay.Contact__c) != 'Government Quota'){
                            if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year').Amount__c){
                                insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year')).Id);
                                localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year').Amount__c;
                                // System.debug('after university fee 2nd year payment localAmount '+localAmount);
                            } else if(localAmount > 0){
                                insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year')).Id);
                                localAmount = 0;
                                // System.debug('after university fee 2nd year payment localAmount else '+localAmount);
                            }
                        // }
                    }

                    if((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year') != null){
                        // System.debug('6');
                        // if(conQuotaMap.get(stupay.Contact__c) != 'Government Quota'){
                            if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year').Amount__c){
                                insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year')).Id);
                                localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year').Amount__c;
                                // System.debug('after tuition fee 2nd year payment localAmount '+localAmount);
                            } else if(localAmount > 0){
                                insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year')).Id);
                                localAmount = 0;
                                // System.debug('after tuition fee 2nd year payment localAmount else '+localAmount);
                            }
                        // }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year') != null){
                        // System.debug('7');
                        // if(conQuotaMap.get(stupay.Contact__c) != 'Government Quota'){
                            if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year').Amount__c){
                                insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year')).Id);
                                localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year').Amount__c;
                                // System.debug('after university fee 3rd year payment localAmount '+localAmount);
                            } else if(localAmount > 0){
                                insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year')).Id);
                                localAmount = 0;
                                // System.debug('after university fee 3rd year payment localAmount else '+localAmount);
                            }
                        // }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year') != null){
                        // System.debug('8');
                        // if(conQuotaMap.get(stupay.Contact__c) != 'Government Quota'){
                            if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c){
                                insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year')).Id);
                                localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c;
                                // System.debug('after tuition fee 3rd year payment localAmount '+localAmount);
                            } 
                            if(localAmount > 0 && localAmount < (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c){
                                insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year')).Id);
                                localAmount = 0;
                                // System.debug('after tuition fee 3rd year payment localAmount else '+localAmount);
                            }
                        // }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year') != null){
                        // System.debug('9');
                        // if(conQuotaMap.get(stupay.Contact__c) != 'Government Quota'){
                            if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c){
                                insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year')).Id);
                                localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c;
                                // System.debug('after university fee 4th year payment localAmount '+localAmount);
                            } 
                            if(localAmount > 0 && localAmount < (conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c){
                                insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year')).Id);
                                localAmount = 0;
                                // System.debug('after university fee 4th year payment localAmount else '+localAmount);
                            }
                        // }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year') != null){
                        // System.debug('10');
                        // if(conQuotaMap.get(stupay.Contact__c) != 'Government Quota'){
                            if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c){
                                insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year')).Id);
                                localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c;
                                // System.debug('after tuition fee 4th year payment localAmount '+localAmount);
                            } 
                            if(localAmount > 0 && localAmount < (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c){
                                insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year')).Id);
                                localAmount = 0;
                                // System.debug('after tuition fee 4th year payment localAmount else '+localAmount);
                            }
                        // }
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year') != null){
                        // System.debug('11');
                        // if(conQuotaMap.get(stupay.Contact__c) != 'Government Quota'){
                            if((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year') != null && localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c){
                                insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year')).Id);
                                localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c;
                                // System.debug('after university fee 5th year payment localAmount '+localAmount);
                            } 
                            if((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year') != null && localAmount > 0 && localAmount < (conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c){
                                insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year')).Id);
                                localAmount = 0;
                                // System.debug('after university fee 5th year payment localAmount else'+localAmount);
                            }
                        // }  
                    }
                    if((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year') != null){
                        // System.debug('12');
                        // if(conQuotaMap.get(stupay.Contact__c) != 'Government Quota'){
                            if(localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c){
                                insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year')).Id);
                                localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c;
                                // System.debug('after tuition fee 5th year payment localAmount '+localAmount);
                            } 
                            if(localAmount > 0 && localAmount < (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c){
                                insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year')).Id);
                                localAmount = 0;
                                // System.debug('after tuition fee 5th year payment localAmount else '+localAmount);
                            }
                        // }   
                    }
                }
            } else {
                // System.debug('data (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get(university fee 1st year )'+(ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 1st year'));
                // System.debug('data (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get(university fee 1st year )'+(ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 1st year'));
                if((ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 1st year') != null){
                    // System.debug('13');
                    if((ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).containsKey('university fee 1st year')){
                        // System.debug('should come here '+localAmount);
                        //   System.debug('should come here '+(conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year').Amount__c );
                        //  System.debug('should come here '+ (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 1st year'));
                        if((conStuFeeMap.get(stupay.contact__c)).containsKey('university fee 1st year') && (conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year').Amount__c > (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 1st year')){
                            localTransactionAmount = ((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year')).Amount__c - (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 1st year');
                            if(localTransactionAmount > 0){
                                if(stupay.Amount__c >= localTransactionAmount){
                                    insertStuFeePayment(stupay,localTransactionAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year')).Id);
                                    localAmount = stupay.Amount__c - localTransactionAmount;
                                    // System.debug('after university fee 1st year payment localAmount '+localAmount);
                                } else {
                                    insertStuFeePayment(stupay,stupay.Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year')).Id);
                                    localAmount = 0;
                                    // System.debug('after university fee 1st year payment localAmount '+localAmount);
                                }
                            }
                        }  else {
                            System.debug('inside else');
                        }
    
                    } else {
                        System.debug('14');
                        if((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year') != null){
                            if((conStuFeeMap.get(stupay.contact__c)).containsKey('university fee 1st year') && stupay.Amount__c >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year').Amount__c){
                                insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year')).Id);
                                localAmount = stupay.Amount__c - (conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year').Amount__c;
                                System.debug('after university fee 1st year payment localAmount '+localAmount);
                            } else if(localAmount > 0) {
                                insertStuFeePayment(stupay,stupay.Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 1st year')).Id);
                                localAmount = 0;
                            }
                        }
                    }
                }
                
                if((ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).containsKey('tuition fee 1st year')){
                    System.debug('15');
                    if((conStuFeeMap.get(stupay.contact__c)).containsKey('tuition fee 1st year') && (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year').Amount__c > (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('tuition fee 1st year')){
                        System.debug('16');
                        localTransactionAmount = ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year')).Amount__c - (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('tuition fee 1st year');
                        if(localTransactionAmount > 0){
                            if(stupay.Amount__c >= localTransactionAmount){
                                insertStuFeePayment(stupay,localTransactionAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year')).Id);
                                localAmount = stupay.Amount__c - localTransactionAmount;
                                System.debug('after tuition fee 1st year payment localAmount '+localAmount);
                            }  else {
                                insertStuFeePayment(stupay,stupay.Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year')).Id);
                                localAmount = 0;
                            }
                        }
                    } 
                } else {
                    System.debug('17');
                    if(conStuFeeMap.get(stupay.contact__c).get('tuition fee 1st year') !=null){
                        System.debug('18');
                        if(localAmount > 0 && localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year').Amount__c){
                            insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year')).Id);
                            localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year').Amount__c;
                            System.debug('after tuition fee 1st year payment localAmount '+localAmount);
                        } else if(localAmount > 0) {
                            insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 1st year')).Id);
                            localAmount = 0;
                            System.debug('after tuition fee 1st year payment localAmount '+localAmount);
                        }
                    }
                    
                }
                if((ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).containsKey('university fee 2nd year')){
                    System.debug('19');
                    if((conStuFeeMap.get(stupay.contact__c)).containsKey('university fee 2nd year') && (conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year').Amount__c > (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 2nd year')){
                        System.debug('20');
                        localTransactionAmount = ((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year')).Amount__c - (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 2nd year');
                        if(localTransactionAmount > 0){
                            if(stupay.Amount__c >= localTransactionAmount){
                                insertStuFeePayment(stupay,localTransactionAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year')).Id);
                                localAmount = stupay.Amount__c - localTransactionAmount;
                                System.debug('after university fee 2nd year payment localAmount '+localAmount);
                            }  else {
                                insertStuFeePayment(stupay,stupay.Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year')).Id);
                                localAmount = 0;
                            }
                        }
                    }
                } else {
                    System.debug('21');
                    if(conStuFeeMap.get(stupay.contact__c).get('university fee 2nd year') !=null){
                        System.debug('22');
                        if((conStuFeeMap.get(stupay.contact__c)).containsKey('university fee 2nd year') && localAmount > 0 && localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year').Amount__c){
                            insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year')).Id);
                            localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year').Amount__c;
                            System.debug('after university fee 2nd year payment localAmount '+localAmount);
                        } else if(localAmount > 0) {
                            insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 2nd year')).Id);
                            localAmount = 0;
                            System.debug('after university fee 2nd year payment localAmount '+localAmount);
                        }
                    }
                    
                }
                
                if((ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).containsKey('tuition fee 2nd year')){
                    System.debug('23');
                    if((conStuFeeMap.get(stupay.contact__c)).containsKey('tuition fee 2nd year') && (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year').Amount__c > (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('tuition fee 2nd year')){
                        localTransactionAmount = ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year')).Amount__c - (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('tuition fee 2nd year');
                        if(localTransactionAmount > 0){
                            if(stupay.Amount__c >= localTransactionAmount){
                                insertStuFeePayment(stupay,localTransactionAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year')).Id);
                                localAmount = stupay.Amount__c - localTransactionAmount;
                                System.debug('after tuition fee 2nd year payment localAmount '+localAmount);
                            }  else {
                                insertStuFeePayment(stupay,stupay.Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year')).Id);
                                localAmount = 0;
                            }
                        }
                    }
                } else {
                    System.debug('24');
                    if(conStuFeeMap.get(stupay.contact__c).get('tuition fee 2nd year') !=null){
                        System.debug('25');
                        if((conStuFeeMap.get(stupay.contact__c)).containsKey('tuition fee 2nd year') && localAmount > 0 && localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year').Amount__c){
                            insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year')).Id);
                            localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year').Amount__c;
                            // System.debug('after tuition fee 2nd year payment localAmount '+localAmount);
                        } else if(localAmount > 0) {
                            insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 2nd year')).Id);
                            localAmount = 0;
                            // System.debug('after tuition fee 2nd year payment localAmount '+localAmount);
                        }
                    }
                }
                if((ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).containsKey('university fee 3rd year')){
                    System.debug('26');
                    if((conStuFeeMap.get(stupay.contact__c)).containsKey('university fee 3rd year') && (conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year').Amount__c > (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 3rd year')){
                        System.debug('27');
                        localTransactionAmount = ((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year')).Amount__c - (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 3rd year');
                        if(localTransactionAmount > 0){
                            if(stupay.Amount__c >= localTransactionAmount){
                                insertStuFeePayment(stupay,localTransactionAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year')).Id);
                                localAmount = stupay.Amount__c - localTransactionAmount;
                                System.debug('after university fee 3rd year payment localAmount '+localAmount);
                            }  else {
                                insertStuFeePayment(stupay,stupay.Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year')).Id);
                                localAmount = 0;
                            }
                        }
                    }
                } else {
                    System.debug('28');
                    if(conStuFeeMap.get(stupay.contact__c).get('university fee 3rd year') !=null){
                        System.debug('29');
                        if(localAmount > 0 && localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year').Amount__c){
                            insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year')).Id);
                            localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year').Amount__c;
                            // System.debug('after university fee 3rd year payment localAmount '+localAmount);
                        } else if(localAmount > 0) {
                            insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 3rd year')).Id);
                            localAmount = 0;
                            // System.debug('after university fee 3rd year payment localAmount '+localAmount);
                        }
                    }
                }
                if((ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).containsKey('tuition fee 3rd year')){
                    System.debug('30');
                    if((conStuFeeMap.get(stupay.contact__c)).containsKey('university fee 3rd year') && (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c > (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('tuition fee 3rd year')){
                        System.debug('31');
                        localTransactionAmount = ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year')).Amount__c - (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('tuition fee 3rd year');
                        if(localTransactionAmount > 0){
                            if(stupay.Amount__c >= localTransactionAmount){
                                insertStuFeePayment(stupay,localTransactionAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year')).Id);
                                localAmount = stupay.Amount__c - localTransactionAmount;
                                System.debug('after tuition fee 3rd year payment localAmount '+localAmount);
                            }  else {
                                insertStuFeePayment(stupay,stupay.Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year')).Id);
                                localAmount = 0;
                            }
                        }
                    }
                } else {
                    System.debug('32');
                    if(conStuFeeMap.get(stupay.contact__c).get('tuition fee 3rd year') !=null){
                        System.debug('33');
                        if(localAmount > 0 && localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c){
                            insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year')).Id);
                            localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year').Amount__c;
                            // System.debug('after tuition fee 3rd year payment localAmount '+localAmount);
                        } else if(localAmount > 0) {
                            insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 3rd year')).Id);
                            localAmount = 0;
                            // System.debug('after tuition fee 3rd year payment localAmount '+localAmount);
                        }
                    }
                }
                if((ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).containsKey('university fee 4th year')){
                    System.debug('34');
                    if((conStuFeeMap.get(stupay.contact__c)).containsKey('university fee 4th year') && (conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c > (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 4th year')){
                        System.debug('35');
                        localTransactionAmount = ((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year')).Amount__c - (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 4th year');
                        if(localTransactionAmount > 0){
                            if(stupay.Amount__c >= localTransactionAmount){
                                insertStuFeePayment(stupay,localTransactionAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year')).Id);
                                localAmount = stupay.Amount__c - localTransactionAmount;
                                System.debug('after university fee 4th year payment localAmount '+localAmount);
                            }  else {
                                insertStuFeePayment(stupay,stupay.Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year')).Id);
                                localAmount = 0;
                            }
                        }
                    }
                } else {
                    System.debug('36');
                    if(conStuFeeMap.get(stupay.contact__c).get('university fee 4th year') !=null){
                        if((conStuFeeMap.get(stupay.contact__c)).containsKey('university fee 4th year') && localAmount > 0 && localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c){
                            insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year')).Id);
                            localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year').Amount__c;
                            // System.debug('after university fee 4th year payment localAmount '+localAmount);
                        } else if(localAmount > 0) {
                            insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 4th year')).Id);
                            localAmount = 0;
                            // System.debug('after university fee 4th year payment localAmount '+localAmount);
                        }
                    }
                }
                if((ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).containsKey('tuition fee 4th year')){
                    if((conStuFeeMap.get(stupay.contact__c)).containsKey('tuition fee 4th year') && (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c > (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('tuition fee 4th year')){
                        localTransactionAmount = ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year')).Amount__c - (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('tuition fee 4th year');
                        if(localTransactionAmount > 0){
                            if(stupay.Amount__c >= localTransactionAmount){
                                insertStuFeePayment(stupay,localTransactionAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year')).Id);
                                localAmount = stupay.Amount__c - localTransactionAmount;
                                System.debug('after tuition fee 4th year payment localAmount '+localAmount);
                            }  else {
                                insertStuFeePayment(stupay,stupay.Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year')).Id);
                                localAmount = 0;
                            }
                        }
                    }
                } else {
                    if(conStuFeeMap.get(stupay.contact__c).get('tuition fee 4th year') !=null){
                        if(localAmount > 0 && localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c){
                            insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year')).Id);
                            localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year').Amount__c;
                            // System.debug('after tuition fee 4th year payment localAmount '+localAmount);
                        } else if(localAmount > 0) {
                            insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 4th year')).Id);
                            localAmount = 0;
                            // System.debug('after tuition fee 4th year payment localAmount '+localAmount);
                        }
                    }
                }
                if((ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).containsKey('university fee 5th year')){
                    if((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c > (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 5th year')){
                        localTransactionAmount = ((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year')).Amount__c - (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('university fee 5th year');
                        if(localTransactionAmount > 0){
                            if(stupay.Amount__c >= localTransactionAmount){
                                insertStuFeePayment(stupay,localTransactionAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year')).Id);
                                localAmount = stupay.Amount__c - localTransactionAmount;
                                System.debug('after university fee 5th year payment localAmount '+localAmount);
                            }  else {
                                insertStuFeePayment(stupay,stupay.Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year')).Id);
                                localAmount = 0;
                            }
                        }
                    }
                } else {
                    if(conStuFeeMap.get(stupay.contact__c).get('university fee 5th year') !=null){
                        if(localAmount > 0 && localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c){
                            insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year')).Id);
                            localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year').Amount__c;
                            // System.debug('after university fee 5th year payment localAmount '+localAmount);
                        } else if(localAmount > 0) {
                            insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('university fee 5th year')).Id);
                            localAmount = 0;
                            // System.debug('after university fee 5th year payment localAmount '+localAmount);
                        }
                    }
                }
                if((ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).containsKey('tuition fee 5th year')){
                        if((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c > (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('tuition fee 5th year')){
                        localTransactionAmount = ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year')).Amount__c - (ConStuFeePayAllottedAmountMap.get(stupay.contact__c)).get('tuition fee 5th year');
                        if(localTransactionAmount > 0){
                            if(stupay.Amount__c >= localTransactionAmount){
                                insertStuFeePayment(stupay,localTransactionAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year')).Id);
                                localAmount = stupay.Amount__c - localTransactionAmount;
                                System.debug('after tuition fee 5th year payment localAmount '+localAmount);
                            }  else {
                                insertStuFeePayment(stupay,stupay.Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year')).Id);
                                localAmount = 0;
                            }
                        }
                    }
                }  else {
                    if(conStuFeeMap.get(stupay.contact__c).get('tuition fee 5th year') !=null){
                        if(localAmount > 0 && localAmount >= (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c){
                            insertStuFeePayment(stupay,(conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year')).Id);
                            localAmount = localAmount - (conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year').Amount__c;
                            // System.debug('after tuition fee 5th year payment localAmount '+localAmount);
                        } else if(localAmount > 0) {
                            insertStuFeePayment(stupay,localAmount, ((conStuFeeMap.get(stupay.contact__c)).get('tuition fee 5th year')).Id);
                            localAmount = 0;
                            // System.debug('after tuition fee 5th year payment localAmount '+localAmount);
                        }
                    }
                }
                
            }
        }
            // System.debug('final localAmount '+localAmount);
        }
        // Send Payment Link for Non-UQ Pending Payment
Set<Id> contactSet = new Set<Id>();
Set<Id> stuPaySet = new Set<Id>();

for(Student_Payment__c stupay : stuPayList){

    if(stupay.Contact__c != null
       && stupay.Payment_Status__c == 'Pending'
       && stupay.Mode_of_Payment__c == 'Online'){

        contactSet.add(stupay.Contact__c);
        stuPaySet.add(stupay.Id);
    }
}

if(!contactSet.isEmpty()){
    StudentPaymentTriggerHandler.callsendSMSAndWhatstapp(
        contactSet,
        stuPaySet,
        'Pending'
    );
}
    }

    public static void updateStuFeePayment(Id stpId, Id stufeepayId){
        Student_Fee_Payment__c stufeePayUpdated = new Student_Fee_Payment__c();
        stufeePayUpdated.Id = stufeepayId;
        stufeePayUpdated.Line_Item_Payment_Status__c = 'Success';
        stufeePayUpdated.Student_Payment__c = stpId;
        // System.debug('before update student fee payment');
        update stufeePayUpdated;
    }

    public static void insertStuFeePayment(Student_Payment__c stupay, Decimal amount, Id stufeeId){
        Student_Fee_Payment__c stufeePayUpdated = new Student_Fee_Payment__c();
        stufeePayUpdated.Amount__c = amount;
        stufeePayUpdated.Student_Fee__c = stufeeId;
        stufeePayUpdated.Line_Item_Payment_Status__c = 'Pending';
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
    }
    
    public static void handleDelete(List<Student_Payment__c> deletedPayments) {
        Set<Id> contactIdsToUpdate = new Set<Id>();

        for (Student_Payment__c deletedPayment : deletedPayments) {
            contactIdsToUpdate.add(deletedPayment.Contact__c);
        }

        if (!contactIdsToUpdate.isEmpty()) {
            updatePAFApplicationCheckbox(contactIdsToUpdate);
        }
    }

 //   @future
    public static void updatePAFApplicationCheckbox(Set<Id> contactIds) {
        /*Map<Id,Decimal> stufeepayAmountMap = new Map<Id,Decimal>();
        Map<Id,Decimal> stuPayMap = new Map<Id,Decimal>();
        Map<Id,Boolean> pafcheckboxMap = new Map<Id,Boolean>();
        List<Student_Payment__c> stupayList = new List<Student_Payment__c>();
        List<hed__Application__c> appList = new List<hed__Application__c>();
        for(Student_Fee_Payment__c stufeepay : [SELECT Id, Name, Amount__c, Line_Item_Payment_Status__c, Mode_of_Payment__c, Student_Fee__r.name, Student_Payment__c, Transaction_Status__c, Student_Payment__r.contact__c FROM Student_Fee_Payment__c where Student_Payment__r.contact__c =: contactIds  and (Student_Fee__r.name like '%UNIVERSITY fee%' OR Student_Fee__r.name like '%TUITION fee%')]){
            if(stufeepay.Line_Item_Payment_Status__c == 'Success'){
                if(stufeepayAmountMap.get(stufeepay.Student_Payment__r.contact__c) == null){
                    stufeepayAmountMap.put(stufeepay.Student_Payment__r.contact__c,stufeepay.Amount__c);
                } else  {
                    stufeepayAmountMap.put(stufeepay.Student_Payment__r.contact__c,stufeepayAmountMap.get(stufeepay.Student_Payment__r.contact__c) + stufeepay.Amount__c);
                }
            }
        }
        System.debug('stufeepayAmountMap '+stufeepayAmountMap);
        for(Student_Payment__c stupay : [SELECT Id, Name, Amount__c, Contact__c, Fee_Type__c, Mode_of_Payment__c, Payment_Status__c FROM Student_Payment__c where contact__c =: contactIds AND Fee_Type__c != 'Application Fee']){
            // if(stupay.Payment_Status__c == 'Success'){
                if(stuPayMap.get(stupay.contact__c) == null){
                    stuPayMap.put(stupay.contact__c,stupay.Amount__c);
                } else  {
                    stuPayMap.put(stupay.contact__c,stuPayMap.get(stupay.contact__c) + stupay.Amount__c);
                }
            // }
            stupayList.add(stupay);
        }
        System.debug('stuPayMap '+stuPayMap);
        for(Student_Payment__c stupayment : stupayList){
            if(stuPayMap.get(stupayment.contact__c) == stufeepayAmountMap.get(stupayment.contact__c)){
                pafcheckboxMap.put(stupayment.contact__c, true);
            } else {
                pafcheckboxMap.put(stupayment.contact__c, false);
            }
        }
        for(hed__Application__c app : [SELECT Id, hed__Applicant__c,Offline_Payment_Initiated__c,Provisional_Admission_Fee_Paid__c FROM hed__Application__c WHERE hed__Applicant__c = :contactIds]){
            app.Provisional_Admission_Fee_Paid__c = pafcheckboxMap.get(app.hed__Applicant__c);
            appList.add(app);
        }
        if(appList.size() > 0){
            update appList;
        }*/
        List<hed__Application__c> ApplicantToUpdate = new List<hed__Application__c>();
        Map<Id,hed__Application__c> appMap = new Map<Id,hed__Application__c>();
        list<Contact> con=[select id, Admission_Mode__c,Fee_Paid_at_University__c from contact where id IN :contactIds];
       
            List<hed__Application__c> Apps = [SELECT Id, hed__Applicant__c,hed__Application_Status__c,Offline_Payment_Initiated__c,First_Payment_Date__c,Partial_Paid__c,Provisional_Admission_Fee_Paid__c,hed__Applicant__r.Student_Status__c FROM hed__Application__c WHERE hed__Applicant__c IN :contactIds AND hed__Applicant__r.Student_Status__c = 'Pursuing' limit 1];
            if(Apps.size() > 0){
                hed__Application__c App = Apps[0];
                list<Student_Payment__c> SPA = [SELECT Amount__c,Payment_Date__c,Payment_Status__c FROM Student_Payment__c WHERE Contact__c IN :contactIds and (Fee_Type__c LIKE '%University fee%' OR Fee_Type__c LIKE '%Tuition fee%')];
                decimal totalPaymentAmount=0;
                for(Student_Payment__c SP:SPA){
                    if(SP.Amount__c != null){
                        totalPaymentAmount +=SP.Amount__c;
                    }
                }
                list<Student_Payment__c> SPAS = [SELECT Amount__c,Payment_Date_Time__c  FROM Student_Payment__c WHERE Contact__c IN :contactIds and (Fee_Type__c LIKE '%University fee%' OR Fee_Type__c LIKE '%Tuition fee%') AND Payment_Status__c = 'Success'AND (Payment_Mode_Type__c = NULL
           OR Payment_Mode_Type__c != 'Paid at KEA')];
                decimal totalSuccessAmount=0;
                Datetime firstPaymentDateTime;
                for(Student_Payment__c SP:SPAS){
                    if(SP.Amount__c != null){ 
                        totalSuccessAmount +=SP.Amount__c;
                    }
                    if(SP.Payment_Date_Time__c != null &&
                   (firstPaymentDateTime == null || SP.Payment_Date_Time__c < firstPaymentDateTime)){
                   firstPaymentDateTime = SP.Payment_Date_Time__c;
                     }
                    // system.debug('totalSuccessAmount::'+totalSuccessAmount);
                }
                if(firstPaymentDateTime != null){
               App.First_Payment_Date__c = firstPaymentDateTime.date();
                 }
                
                list<Student_Fee__c > SFA=[select Provisional_Admission_Fee__c from Student_Fee__c WHERE Contact__c IN :contactIds and Fee_Type__c like '%University Fee%'];
                list<Student_Fee__c > PF=[select Actual_Program_Fee__c,Amount__c,Fee_Year__c from Student_Fee__c WHERE Contact__c IN :contactIds and Fee_Year__c = '1st Year'];
               
                decimal totalPAFAmount=0;
                for(Student_Fee__c SF:SFA){
                    if(SF.Provisional_Admission_Fee__c != null){
                        totalPAFAmount += SF.Provisional_Admission_Fee__c;
                    }
                }
                
                decimal totalAPFAmount=0;
                for(Student_Fee__c SF:PF){
                    if(SF.Amount__c != null){
                        totalAPFAmount += SF.Amount__c;
                    }
                }
               // Decimal totalPaymentAmount = 0;
               Decimal pendingPaymentAmount = 0;
               for(Student_Payment__c SP : SPA){
               if(SP.Amount__c != null){
                totalPaymentAmount += SP.Amount__c;
                 }
               // Count only Pending payment link amount
              if(SP.Payment_Date__c == null){   // or use Payment_Status__c if you query it
              pendingPaymentAmount += SP.Amount__c;
                 }
                  }
                
                Decimal totalUniversityAmount=0;
                for(Contact Cons:con){
                    totalUniversityAmount =Cons.Fee_Paid_at_University__c;
                    if(Cons.Admission_Mode__c == 'UQ'&& totalPAFAmount > 0){
                        
                        if (totalPaymentAmount < totalPAFAmount) {
                            App.Offline_Payment_Initiated__c = false;
                            App.hed__Application_Status__c = 'Provisionally Offered';
                            ApplicantToUpdate.add(App);
                        }                       
                        else{
                            App.Offline_Payment_Initiated__c = True; 
                            App.hed__Application_Status__c = 'Provisionally Offered';
                            ApplicantToUpdate.add(App);
                        }
                        
                        
                         if(App.hed__Application_Status__c != 'Admit' && totalSuccessAmount > 0){

                            if(totalSuccessAmount < totalPAFAmount){
                                App.hed__Application_Status__c = 'Partial Paid';
                                App.Provisional_Admission_Fee_Paid__c = false;
                                App.Partial_Paid__c = true;
                            }
                            else if(totalSuccessAmount >= totalAPFAmount){
                                App.hed__Application_Status__c = 'Annual Fee Paid';
                                App.Provisional_Admission_Fee_Paid__c = true;
                                App.Partial_Paid__c = true;
                            }
                            else if(totalSuccessAmount >= totalPAFAmount){
                                App.hed__Application_Status__c = 'PAF Full Paid';
                                App.Provisional_Admission_Fee_Paid__c = true;
                                App.Partial_Paid__c = true;
                            }
                        
                            ApplicantToUpdate.add(App);
                        } 
                    }
                    /*else{
                        if(totalUniversityAmount > 0){
                        if(totalPaymentAmount < totalUniversityAmount ){
                            App.Offline_Payment_Initiated__c = false;
                            App.hed__Application_Status__c = 'Provisionally Offered';
                            ApplicantToUpdate.add(App);
                        }
                        else{
                           App.Offline_Payment_Initiated__c = True;
                           App.hed__Application_Status__c = 'Provisionally Offered';
                            ApplicantToUpdate.add(App);
                        }
                        
                       if (App.hed__Application_Status__c !='Admit' && totalSuccessAmount > 0) {
                            App.Partial_Paid__c = true;
                            if(totalSuccessAmount < totalUniversityAmount)
                            {
                                App.hed__Application_Status__c = 'Partial Paid';
                                App.Provisional_Admission_Fee_Paid__c=false;
                            }
                            else if(totalSuccessAmount >= totalAPFAmount){                        
                                App.hed__Application_Status__c = 'Annual Fee Paid';
                                App.Provisional_Admission_Fee_Paid__c = true;
                        
                            } 
                            else if(totalSuccessAmount >= totalUniversityAmount){
                                App.hed__Application_Status__c = 'PAF Full Paid';
                                App.Provisional_Admission_Fee_Paid__c = true;
                        
                            }
                            
                            ApplicantToUpdate.add(App);
                        }
                            
                    }
                    }*/
                    else {   
               // NON-UQ (CET / COMEDK / KEA) 13/7/2026
           if (App.hed__Application_Status__c != 'Admit') {
            App.hed__Application_Status__c = 'Started';
            App.Provisional_Admission_Fee_Paid__c = false;
        // Payment button clicked and payment record created.
           if (pendingPaymentAmount >= totalPAFAmount) {
          App.Offline_Payment_Initiated__c = true;
          }
         else {
         App.Offline_Payment_Initiated__c = false;
         }
        // Payment successful.
        if (totalSuccessAmount >= totalPAFAmount) {
            App.Provisional_Admission_Fee_Paid__c = true;
            App.hed__Application_Status__c = 'Incomplete';
         }
         ApplicantToUpdate.add(App);
         }
       }
                }
            }
            
        
        for(hed__Application__c appl : ApplicantToUpdate){
            appMap.put(appl.Id,appl);
        }

        if (!appMap.isEmpty()) {
            if(!Test.isRunningTest()){
        update appMap.values();
    }
        }
    }
    
}