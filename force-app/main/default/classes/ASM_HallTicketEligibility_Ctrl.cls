public class ASM_HallTicketEligibility_Ctrl 
{
    @AuraEnabled
    public static WrapperProgrmBtch getProgramBatchDetails()
    {
        WrapperProgrmBtch objPrgBtch = new WrapperProgrmBtch();
        set<Id> set_ConIds = new set<Id>();
        set<Id> set_SchoolIds = new set<Id>();
        set<Id> set_ProgramIds = new set<Id>();
        Map<Id,List<Account>> map_Acc = new Map<Id,List<Account>>();
        List<Account> list_Acc = new List<Account>();
        
        Id accRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        for(Account objAcc : [select Id,Name,School_Head__c from Account Where School_Head__c =: UserInfo.getUserId()    
                              and RecordTypeId =: accRecId]) // '0050w000003PMSt'   
        {
            set_SchoolIds.add(objAcc.Id);   
        }
        
        for(Account objProgram : [select Id,Name,ParentId from Account where ParentId In : set_SchoolIds])
        {
            set_ProgramIds.add(objProgram.Id);
        }
        
        for(hed__Program_Plan__c objProgBatch :[select Id,Name,hed__Account__c,Active__c from hed__Program_Plan__c where 
                                                Active__c = true and hed__Account__c In : set_ProgramIds])
        {
            objPrgBtch.map_Prgmbtch.put(objProgBatch.Id,objProgBatch.Name); 
        }
        return objPrgBtch;
    }
    
    @AuraEnabled
    public static WrapperSemester getSemesterDetails(string str_selprgId)
    {
        WrapperSemester objSemstr = new WrapperSemester();
        string termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        for(hed__Term__c  objSemester :[select Id,Name,RecordTypeId,Program_Batch__c,Active__c from hed__Term__c where Active__c =: true
                                        and RecordTypeId =: termRecTypeId and Program_Batch__c =: str_selprgId])
        {
            objSemstr.map_Semster.put(objSemester.Id,objSemester.Name);
        }
        return objSemstr;
    }
    
    @AuraEnabled
    public static List<WrapProgEnrollments> getStudentDetails(string str_selSemId,string str_selectedEligbl)
    {
        //system.debug('==== Eligibility Type ======='+str_selectedEligbl);
        List<WrapProgEnrollments> list_WrapProgs = new List<WrapProgEnrollments>();
        set<Id> set_PrgEnrllIds = new set<Id>();
        set<Id> set_ProgramEnrollmentIds = new set<Id>();
        Map<Id,hed__Course_Enrollment__c> map_CourseEnrolls = new Map<Id,hed__Course_Enrollment__c>();
        Map<string,string> map_StudentFees = new Map<string,string>();
        List<hed__Program_Enrollment__c> list_ProgEnrollments = new List<hed__Program_Enrollment__c>();
        Map<Id,string> map_inEligibleCandidates = new Map<Id,String>();
        
        for(hed__Program_Enrollment__c objProgEnrollment :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                           Semester__c =: str_selSemId and Active__c =: true 
                                                           and Issue_Hall_Ticket__c =: false])
        {
            set_PrgEnrllIds.add(objProgEnrollment.Id);
        }
                
        //Open Surveys Start
        if(str_selectedEligbl == 'Open Surveys' && str_selectedEligbl != null)
        {   
            
            set<Id> set_PendingSurveyIds = new set<Id>();
            for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                         Id  In : set_PrgEnrllIds and Pending_Survey__c > 0 ])
            {
                set_PendingSurveyIds.add(objPrgEnrll.Id);
            }
            
            for(hed__Course_Enrollment__c objCourse : [select Id,Name,Total_Classes_Attended__c,Total_Classes_Completed__c,hed__Contact__c,
                                                       hed__Program_Enrollment__c,Classes_Attended__c from hed__Course_Enrollment__c 
                                                       where hed__Program_Enrollment__c In : set_PendingSurveyIds and Classes_Attended__c <: decimal.valueof(Label.ASM_AttendancePercentage)])
            {                 
                map_inEligibleCandidates.put(objCourse.hed__Program_Enrollment__c,objCourse.Name);
            }
            
            for(hed__Course_Enrollment__c objCourse : [select Id,Name,Total_Classes_Attended__c,Total_Classes_Completed__c,hed__Contact__c,
                                                       hed__Program_Enrollment__c,Classes_Attended__c from hed__Course_Enrollment__c 
                                                       where hed__Program_Enrollment__c In : set_PendingSurveyIds and Classes_Attended__c >: decimal.valueof(Label.ASM_AttendancePercentage)])
            {
                // system.debug('===== Enter 2 =======');
                
                if(objCourse.Classes_Attended__c != null)
                {
                    if(!map_inEligibleCandidates.ContainsKey(objCourse.hed__Program_Enrollment__c))
                    {
                        set_ProgramEnrollmentIds.add(objCourse.hed__Program_Enrollment__c);  
                        map_CourseEnrolls.put(objCourse.hed__Program_Enrollment__c,objCourse);   
                    }
                }
            }
            
            set<Id> set_FinalIds = new set<Id>();
            
            List<Student_Fee__c> list_StudentsFee = new List<Student_Fee__c>();
            
            for(Student_Fee__c objStudentsFee : [select Id,Name,Program_Enrollment__c from Student_Fee__c
                                                 where Program_Enrollment__c In : set_ProgramEnrollmentIds])
            {
                list_StudentsFee.add(objStudentsFee);
            }
            //system.debug('===== Students Fee ====='+list_StudentsFee);
            if(list_StudentsFee.size() == 0)
            {
                for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                             Id  In : set_ProgramEnrollmentIds ])
                {       
                    WrapProgEnrollments objWrpProgEnroll = new WrapProgEnrollments();
                    objWrpProgEnroll.str_Eligibility = 'Not Eligible';
                    objWrpProgEnroll.objProgEnrlmnt = objPrgEnrll;
                    list_WrapProgs.add(objWrpProgEnroll);
                }     
            }
            else
            {
                for(Student_Fee__c objStudentFee :  [select Program_Enrollment__c,Amount_Pending__c from Student_Fee__c
                                           where ((Due_Date__c <=: system.today() 
                                                  and Amount_Pending__c > 0)   
                                                  and Program_Enrollment__c In: set_ProgramEnrollmentIds )
                                          ])
                {                
                    map_StudentFees.put(objStudentFee.Program_Enrollment__c,objStudentFee.Program_Enrollment__c);
                }
                
                for(Student_Fee__c objStudentNoFee :  [select Program_Enrollment__c,Amount_Pending__c from Student_Fee__c
                                           where (((Due_Date__c <=: system.today() and (Amount_Pending__c = 0 or Amount_Pending__c = null) ) OR
                                                   (Due_Date__c >=: system.today() and  Amount_Pending__c > 0))
                                                  and Program_Enrollment__c In: set_ProgramEnrollmentIds )
                                          ])
                {             
                    if(!map_StudentFees.ContainsKey(objStudentNoFee.Program_Enrollment__c)) set_FinalIds.add(objStudentNoFee.Program_Enrollment__c);
                    
                }
                
                for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                             Id  In : set_FinalIds ])
                {       
                    WrapProgEnrollments objWrpProgEnroll = new WrapProgEnrollments();
                    objWrpProgEnroll.str_Eligibility = 'Not Eligible';
                    objWrpProgEnroll.objProgEnrlmnt = objPrgEnrll;
                    list_WrapProgs.add(objWrpProgEnroll);
                }     
            } 
        }
        
        //Open Surveys end
        
        // Attendance Shortage Start
        else if(str_selectedEligbl == 'Attendance Shortage' && str_selectedEligbl != null)
        {            
            set<Id> set_PendingSurveyIds = new set<Id>();
            for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                         Id  In : set_PrgEnrllIds and (Pending_Survey__c = 0 or Pending_Survey__c = null)])
            {
                set_PendingSurveyIds.add(objPrgEnrll.Id);
            }
            
            //system.debug('==153===>>>>'+set_PendingSurveyIds);
            for(hed__Course_Enrollment__c objCourse : [select Id,Name,Total_Classes_Attended__c,Total_Classes_Completed__c,hed__Contact__c,
                                                       hed__Program_Enrollment__c,Classes_Attended__c from hed__Course_Enrollment__c 
                                                       where hed__Program_Enrollment__c In : set_PendingSurveyIds and Classes_Attended__c <: decimal.valueof(Label.ASM_AttendancePercentage)])
            {        
                set_ProgramEnrollmentIds.add(objCourse.hed__Program_Enrollment__c); 
                map_inEligibleCandidates.put(objCourse.hed__Program_Enrollment__c,objCourse.Name);
            }
            
            //system.debug('=162===>>>'+set_ProgramEnrollmentIds);
            
            set<Id> set_FinalIds = new set<Id>();
            
            List<Student_Fee__c> list_StudentsFee = new List<Student_Fee__c>();
            
            for(Student_Fee__c objStudentsFee : [select Id,Name,Program_Enrollment__c from Student_Fee__c
                                                 where Program_Enrollment__c In : set_ProgramEnrollmentIds])
            {
                list_StudentsFee.add(objStudentsFee);
            }
            //system.debug('===== Students Fee ====='+list_StudentsFee);
            if(list_StudentsFee.size() == 0)
            {
                for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                             Id  In : set_ProgramEnrollmentIds ])
                {       
                    WrapProgEnrollments objWrpProgEnroll = new WrapProgEnrollments();
                    objWrpProgEnroll.str_Eligibility = 'Not Eligible';
                    objWrpProgEnroll.objProgEnrlmnt = objPrgEnrll;
                    list_WrapProgs.add(objWrpProgEnroll);
                }     
            }
            else
            {
                for(Student_Fee__c objStudentFee :  [select Program_Enrollment__c,Amount_Pending__c from Student_Fee__c
                                           where ((Due_Date__c <=: system.today() and Amount_Pending__c > 0)
                                                  and Program_Enrollment__c In: set_ProgramEnrollmentIds )
                                          ])
                {                
                    map_StudentFees.put(objStudentFee.Program_Enrollment__c,objStudentFee.Program_Enrollment__c);
                }
                
                for(Student_Fee__c objStudentNoFee :  [select Program_Enrollment__c,Amount_Pending__c from Student_Fee__c
                                           where (((Due_Date__c <=: system.today() and (Amount_Pending__c = 0 or Amount_Pending__c = null))
                                                  OR (Due_Date__c >=: system.today() and Amount_Pending__c > 0))
                                                  and Program_Enrollment__c In: set_ProgramEnrollmentIds )
                                          ])
                {             
                    if(!map_StudentFees.ContainsKey(objStudentNoFee.Program_Enrollment__c)) set_FinalIds.add(objStudentNoFee.Program_Enrollment__c);
                    
                }
                
                for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                             Id  In : set_FinalIds ])
                {       
                    WrapProgEnrollments objWrpProgEnroll = new WrapProgEnrollments();
                    objWrpProgEnroll.str_Eligibility = 'Not Eligible';
                    objWrpProgEnroll.objProgEnrlmnt = objPrgEnrll;
                    list_WrapProgs.add(objWrpProgEnroll);
                }     
            }             
        }
        
        //Pending Fees Start
        else if(str_selectedEligbl == 'Pending Fees' && str_selSemId != null)
        {
            set<Id> set_PendingSurveyIds = new set<Id>();
            for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                         Id  In : set_PrgEnrllIds and (Pending_Survey__c = 0 or Pending_Survey__c = null)])
            {
                set_PendingSurveyIds.add(objPrgEnrll.Id);
            }
            
            //system.debug('==212===>>>>'+set_PendingSurveyIds);
            for(hed__Course_Enrollment__c objCourse : [select Id,Name,Total_Classes_Attended__c,Total_Classes_Completed__c,hed__Contact__c,
                                                       hed__Program_Enrollment__c,Classes_Attended__c from hed__Course_Enrollment__c 
                                                       where hed__Program_Enrollment__c In : set_PendingSurveyIds and Classes_Attended__c <: decimal.valueof(Label.ASM_AttendancePercentage)])
            {                 
                map_inEligibleCandidates.put(objCourse.hed__Program_Enrollment__c,objCourse.Name);
            }
            
            for(hed__Course_Enrollment__c objCourse : [select Id,Name,Total_Classes_Attended__c,Total_Classes_Completed__c,hed__Contact__c,
                                                       hed__Program_Enrollment__c,Classes_Attended__c from hed__Course_Enrollment__c 
                                                       where hed__Program_Enrollment__c In : set_PendingSurveyIds and Classes_Attended__c >: decimal.valueof(Label.ASM_AttendancePercentage)])
            {                
                if(objCourse.Classes_Attended__c != null)
                {
                    if(!map_inEligibleCandidates.ContainsKey(objCourse.hed__Program_Enrollment__c))
                    {
                        set_ProgramEnrollmentIds.add(objCourse.hed__Program_Enrollment__c);  
                        map_CourseEnrolls.put(objCourse.hed__Program_Enrollment__c,objCourse);   
                    }
                }
            }
            
            //system.debug('=236===>>>'+set_ProgramEnrollmentIds);
            set<Id> set_FinalIds = new set<Id>();
            for(Student_Fee__c objStudentFee :  [select Program_Enrollment__c,Amount_Pending__c from Student_Fee__c
                                       where ((Due_Date__c <=: system.today() and Amount_Pending__c > 0)
                                              and Program_Enrollment__c In: set_ProgramEnrollmentIds )
                                      ])
            {                
                set_FinalIds.add(objStudentFee.Program_Enrollment__c);
            }
            
            for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                         Id  In : set_FinalIds ])
            {      
                WrapProgEnrollments objWrpProgEnroll = new WrapProgEnrollments();
                objWrpProgEnroll.str_Eligibility = 'Not Eligible';
                objWrpProgEnroll.objProgEnrlmnt = objPrgEnrll;
                list_WrapProgs.add(objWrpProgEnroll);
                
            }           
            
        }
        
        //Pending Fees end
        
        //Open Surveys & Attendance Shortage Start
        else if(str_selectedEligbl == 'Open Surveys & Attendance Shortage' && str_selectedEligbl != null)
        {
            
            set<Id> set_PendingSurveyIds = new set<Id>();
            for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                         Id  In : set_PrgEnrllIds and Pending_Survey__c > 0])
            {
                set_PendingSurveyIds.add(objPrgEnrll.Id);
            }
            
            for(hed__Course_Enrollment__c objCourse : [select Id,Name,Total_Classes_Attended__c,Total_Classes_Completed__c,hed__Contact__c,
                                                       hed__Program_Enrollment__c,Classes_Attended__c from hed__Course_Enrollment__c 
                                                       where hed__Program_Enrollment__c In : set_PendingSurveyIds and Classes_Attended__c <: decimal.valueof(Label.ASM_AttendancePercentage)])
            {                 
                set_ProgramEnrollmentIds.add(objCourse.hed__Program_Enrollment__c); 
                map_inEligibleCandidates.put(objCourse.hed__Program_Enrollment__c,objCourse.Name);
            }
            
           set<Id> set_FinalIds = new set<Id>();
            
            List<Student_Fee__c> list_StudentsFee = new List<Student_Fee__c>();
            
            for(Student_Fee__c objStudentsFee : [select Id,Name,Program_Enrollment__c from Student_Fee__c
                                                 where Program_Enrollment__c In : set_ProgramEnrollmentIds])
            {
                list_StudentsFee.add(objStudentsFee);
            }
            //system.debug('===== Students Fee ====='+list_StudentsFee);
            if(list_StudentsFee.size() == 0)
            {
                for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                             Id  In : set_ProgramEnrollmentIds ])
                {       
                    WrapProgEnrollments objWrpProgEnroll = new WrapProgEnrollments();
                    objWrpProgEnroll.str_Eligibility = 'Not Eligible';
                    objWrpProgEnroll.objProgEnrlmnt = objPrgEnrll;
                    list_WrapProgs.add(objWrpProgEnroll);
                }     
            }
            else
            {
                for(Student_Fee__c objStudentFee :  [select Program_Enrollment__c,Amount_Pending__c from Student_Fee__c
                                           where ((Due_Date__c <=: system.today() 
                                                  and Amount_Pending__c > 0)
                                                  and Program_Enrollment__c In: set_ProgramEnrollmentIds )
                                          ])
                {                
                    map_StudentFees.put(objStudentFee.Program_Enrollment__c,objStudentFee.Program_Enrollment__c);
                }
                
                for(Student_Fee__c objStudentNoFee :  [select Program_Enrollment__c,Amount_Pending__c from Student_Fee__c
                                           where (((Due_Date__c <=: system.today() and (Amount_Pending__c = 0 or Amount_Pending__c = null))
                                                  OR (Due_Date__c >=: system.today() and Amount_Pending__c > 0))
                                                  and Program_Enrollment__c In: set_ProgramEnrollmentIds )
                                          ])
                {             
                    if(!map_StudentFees.ContainsKey(objStudentNoFee.Program_Enrollment__c)) set_FinalIds.add(objStudentNoFee.Program_Enrollment__c);
                    
                }
                
                for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                             Id  In : set_FinalIds ])
                {       
                    WrapProgEnrollments objWrpProgEnroll = new WrapProgEnrollments();
                    objWrpProgEnroll.str_Eligibility = 'Not Eligible';
                    objWrpProgEnroll.objProgEnrlmnt = objPrgEnrll;
                    list_WrapProgs.add(objWrpProgEnroll);
                }     
            }             
        }
        else if(str_selectedEligbl == 'Open Surveys & Pending Fees' && str_selectedEligbl != null )
        {
            
            set<Id> set_PendingSurveyIds = new set<Id>();
            for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                         Id  In : set_PrgEnrllIds and Pending_Survey__c > 0])
            {
                set_PendingSurveyIds.add(objPrgEnrll.Id);
            }
            
            //system.debug('==327===>>>>'+set_PendingSurveyIds);
            for(hed__Course_Enrollment__c objCourse : [select Id,Name,Total_Classes_Attended__c,Total_Classes_Completed__c,hed__Contact__c,
                                                       hed__Program_Enrollment__c,Classes_Attended__c from hed__Course_Enrollment__c 
                                                       where hed__Program_Enrollment__c In : set_PendingSurveyIds and Classes_Attended__c <: decimal.valueof(Label.ASM_AttendancePercentage)])
            {                 
                map_inEligibleCandidates.put(objCourse.hed__Program_Enrollment__c,objCourse.Name);
            }
            
            for(hed__Course_Enrollment__c objCourse : [select Id,Name,Total_Classes_Attended__c,Total_Classes_Completed__c,hed__Contact__c,
                                                       hed__Program_Enrollment__c,Classes_Attended__c from hed__Course_Enrollment__c 
                                                       where hed__Program_Enrollment__c In : set_PendingSurveyIds and Classes_Attended__c >: decimal.valueof(Label.ASM_AttendancePercentage)])
            {                
                if(objCourse.Classes_Attended__c != null)
                {
                    if(!map_inEligibleCandidates.ContainsKey(objCourse.hed__Program_Enrollment__c))
                    {
                        set_ProgramEnrollmentIds.add(objCourse.hed__Program_Enrollment__c);  
                        map_CourseEnrolls.put(objCourse.hed__Program_Enrollment__c,objCourse);   
                    }
                }
            }
            
            //system.debug('=351===>>>'+set_ProgramEnrollmentIds);
            set<Id> set_FinalIds = new set<Id>();
            for(Student_Fee__c objStudentFee :  [select Program_Enrollment__c,Amount_Pending__c from Student_Fee__c
                                       where ((Due_Date__c <=: system.today() 
                                              and Amount_Pending__c > 0) 
                                              and Program_Enrollment__c In: set_ProgramEnrollmentIds )
                                      ])
            {                
                set_FinalIds.add(objStudentFee.Program_Enrollment__c);
                map_StudentFees.put(objStudentFee.Program_Enrollment__c,objStudentFee.Program_Enrollment__c);
            }
            
            for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                         Id  In : set_FinalIds ])
            {      
                WrapProgEnrollments objWrpProgEnroll = new WrapProgEnrollments();
                objWrpProgEnroll.str_Eligibility = 'Not Eligible';
                objWrpProgEnroll.objProgEnrlmnt = objPrgEnrll;
                list_WrapProgs.add(objWrpProgEnroll);
                
            }  
        }
        else if(str_selectedEligbl == 'Attendance Shortage & Pending Fees' && str_selectedEligbl != null)
        {
            set<Id> set_PendingSurveyIds = new set<Id>();
            for(hed__Program_Enrollment__c objPrgEnrll :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                         Id  In : set_PrgEnrllIds and (Pending_Survey__c = 0 or Pending_Survey__c = null)])
            {
                set_PendingSurveyIds.add(objPrgEnrll.Id);
            }
            
            for(hed__Course_Enrollment__c objCourse : [select Id,Name,Total_Classes_Attended__c,Total_Classes_Completed__c,hed__Contact__c,
                                                       hed__Program_Enrollment__c,Classes_Attended__c from hed__Course_Enrollment__c 
                                                       where hed__Program_Enrollment__c In : set_PendingSurveyIds and Classes_Attended__c <: decimal.valueof(Label.ASM_AttendancePercentage)])
            {                 
                set_ProgramEnrollmentIds.add(objCourse.hed__Program_Enrollment__c); 
                map_inEligibleCandidates.put(objCourse.hed__Program_Enrollment__c,objCourse.Name);
            }
            
            
            set<Id> set_FinalIds = new set<Id>();
            
            for(Student_Fee__c objStudentFee :  [select Program_Enrollment__c,Amount_Pending__c from Student_Fee__c
                                       where ((Due_Date__c <=: system.today() 
                                              and Amount_Pending__c > 0)
                                              and Program_Enrollment__c In: set_ProgramEnrollmentIds)
                                      ])
            {                
                set_FinalIds.add(objStudentFee.Program_Enrollment__c);
            }
            
            for(hed__Program_Enrollment__c objSurvyEnrollmts :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                               Id  In : set_FinalIds])
            {
                WrapProgEnrollments objWrpProgEnroll = new WrapProgEnrollments();
                objWrpProgEnroll.str_Eligibility = 'Not Eligible';
                objWrpProgEnroll.objProgEnrlmnt = objSurvyEnrollmts;
                list_WrapProgs.add(objWrpProgEnroll);
            }
            
            //system.debug('=====>>'+set_FinalIds);
        }
        else if(str_selectedEligbl == 'Open Surveys & Attendance Shortage & Pending Fees' && str_selectedEligbl != null)
        {
            
            for(hed__Program_Enrollment__c objSurvyEnrollmts :[select Id,Name,Semester__c,hed__Contact__c,hed__Contact__r.Student_Full_Name__c,Active__c,hed__Contact__r.SRN_Number__c,Pending_Survey__c,Issue_Hall_Ticket__c from hed__Program_Enrollment__c where 
                                                               Id  In : set_PrgEnrllIds and Pending_Survey__c > 0])
            {
                set_ProgramEnrollmentIds.add(objSurvyEnrollmts.Id);
            }
            
            set<Id> set_CourseEnrollments = new set<Id>();
            
            for(hed__Course_Enrollment__c objCourse : [select Id,Name,Total_Classes_Attended__c,Total_Classes_Completed__c,hed__Contact__c,
                                                       hed__Program_Enrollment__c,Classes_Attended__c from hed__Course_Enrollment__c 
                                                       where hed__Program_Enrollment__c In : set_ProgramEnrollmentIds and Classes_Attended__c <: decimal.valueof(Label.ASM_AttendancePercentage)])
            {
                if(objCourse.Classes_Attended__c != null)
                {
                    set_CourseEnrollments.add(objCourse.hed__Program_Enrollment__c);
                }
            }
            
            set<Id> set_FinalIds = new set<Id>();
            for(Student_Fee__c objStudentFee :  [select Program_Enrollment__c,Amount_Pending__c from Student_Fee__c
                                       where ((Due_Date__c <=: system.today() 
                                              and Amount_Pending__c > 0)
                                              and Program_Enrollment__c In: set_CourseEnrollments )
                                      ])
            {                
                set_FinalIds.add(objStudentFee.Program_Enrollment__c);
            } 
            //system.debug('=====>>'+set_ProgramEnrollmentIds);
            for(hed__Program_Enrollment__c objPrgEnrll : [select Id,Name,Issue_Hall_Ticket__c,hed__Contact__r.Student_Full_Name__c,hed__Contact__r.SRN_Number__c
                                                          from hed__Program_Enrollment__c where Id In: set_FinalIds])
            {
                WrapProgEnrollments objWrpProgEnroll = new WrapProgEnrollments();
                objWrpProgEnroll.str_Eligibility = 'Not Eligible';
                objWrpProgEnroll.objProgEnrlmnt = objPrgEnrll;
                list_WrapProgs.add(objWrpProgEnroll);
            }   
        }
        
        /*system.debug('====== ProgEnrollments ===='+list_WrapProgs);
        system.debug('====== ProgEnrollments size===='+list_WrapProgs.size());*/
        return list_WrapProgs;
    }
    
    @AuraEnabled
    public static WrapSaveStudents saveStudentsDetails(List<hed__Program_Enrollment__c> list_WrapProgs)
    {
        WrapSaveStudents objSaveWrp = new WrapSaveStudents();
        set<Id> set_ProgId = new set<Id>();
        List<hed__Program_Enrollment__c> list_Enroll = new List<hed__Program_Enrollment__c>();
        try
        { 
            for(hed__Program_Enrollment__c objEnroll : list_WrapProgs)
            {
                
                objEnroll.Issue_Hall_Ticket__c = true;
                list_Enroll.add(objEnroll);
            }
            
            if(!list_Enroll.IsEmpty())
            {
                update list_Enroll;
            }
            objSaveWrp.strMessage = 'Success';
            return objSaveWrp;
        }
        
        catch(Exception ex)
        {
            objSaveWrp.strMessage = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objSaveWrp;
        }    
    }
    
    public class WrapperProgrmBtch
    {
        @AuraEnabled 
        Public Map<Id,string> map_Prgmbtch{get;set;}
        
        public WrapperProgrmBtch()
        {
            map_Prgmbtch = new Map<Id,string>(); 
        }
    }
    
    public class WrapperSemester
    {
        @AuraEnabled 
        public Map<Id,string> map_Semster{get;set;}
        
        public WrapperSemester()
        {
            map_Semster = new Map<Id,string>();
        }
    }
    
    public class WrapProgEnrollments
    {
        @AuraEnabled public hed__Program_Enrollment__c objProgEnrlmnt{get;set;}
        @AuraEnabled public string str_Eligibility {get;set;}
    }
    
    public class WrapSaveStudents
    {
        @AuraEnabled public string strMessage {get;set;}
    }
}