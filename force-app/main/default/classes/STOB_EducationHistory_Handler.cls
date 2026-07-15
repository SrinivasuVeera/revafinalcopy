public class STOB_EducationHistory_Handler
{
    //updates the status of program Enrollment(Eligible to enroll) to Confirmed if all the Educ history Mandatory one's are Approved. 
    public static void updatePrgmEnrlmtStatus(list<hed__Education_History__c> lst_EduHst,map<id,hed__Education_History__c> oldmap)
    {  
        set<id> set_conId=new Set<id>();
        list<hed__Program_Enrollment__c> lst_PrgmEnrlmt=new list<hed__Program_Enrollment__c>();
        map<id,set<string>> map_Status=new map<id,set<string>>();
        
        for(hed__Education_History__c objEduHst: lst_EduHst)
        {
            if(oldmap!= null && objEduHst.hed__Contact__c!=null && objEduHst.Mandatory_for_SRN_Generation__c ==true 
               && objEduHst.hed__Verification_Status__c=='Approved'
               && objEduHst.hed__Verification_Status__c!=oldmap.get(objEduHst.id).hed__Verification_Status__c)
            {
                set_conId.add(objEduHst.hed__Contact__c);
            }
        }  
        if(set_conId.size()>0)
        {
            for(hed__Education_History__c objEduHst:[Select id,hed__Verification_Status__c,hed__Contact__c from hed__Education_History__c
                                                     where hed__Contact__c IN :set_conId and Mandatory_for_SRN_Generation__c = true ])
            {
                if(map_Status.get(objEduHst.hed__Contact__c) == Null)
                {
                    map_Status.put(objEduHst.hed__Contact__c, new Set<String>());
                }
                map_Status.get(objEduHst.hed__Contact__c).add(objEduHst.hed__Verification_Status__c);
            }
            for(hed__Program_Enrollment__c objPrgmEnrlmt:[Select id,Program_Enrollment_Status__c,Active__c,hed__Eligible_to_Enroll__c,hed__Contact__c from hed__Program_Enrollment__c
                                                          where hed__Contact__c IN :set_conId and Active__c=true])
            {
                if(!map_Status.get(objPrgmEnrlmt.hed__Contact__c).contains('Rejected') && !map_Status.get(objPrgmEnrlmt.hed__Contact__c).contains('Pending')
                   && objPrgmEnrlmt.Program_Enrollment_Status__c!='Confirmed')
                {
                    objPrgmEnrlmt.hed__Eligible_to_Enroll__c = true;
                    objPrgmEnrlmt.hed__Admission_Date__c = System.today();
                    objPrgmEnrlmt.Program_Enrollment_Status__c='Confirmed';
                    lst_PrgmEnrlmt.add(objPrgmEnrlmt);
                }                
            }
        }
        if(lst_PrgmEnrlmt.size()>0)
        {
            system.debug('Before update'+lst_PrgmEnrlmt);
            update lst_PrgmEnrlmt;
            system.debug('after update'+lst_PrgmEnrlmt);
        }
    }
}