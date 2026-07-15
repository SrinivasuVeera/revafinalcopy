public class CP_CoursePlanUnitSequenceHandler 
{
    public static void generatecourseplanunitsequence(List<Course_Plan_Unit__c> lst_courseplanunits)
    {
        set<Id> set_courseOffIds = new set<Id>();
        set<Id> set_UnitIds = new set<Id>();
        List<Course_Plan_Unit__c> lst_updateunits = new List<Course_Plan_Unit__c>();
        
        for(Course_Plan_Unit__c objCoursePlanUnits : lst_courseplanunits)
        {
            set_courseOffIds.add(objCoursePlanUnits.Course_Offering__c);  
            set_UnitIds.add(objCoursePlanUnits.Id);
        }
        if(!set_courseOffIds.IsEmpty() && !set_UnitIds.IsEmpty())
        {
            Integer Intseqno = 0;
            for(Course_Plan_Unit__c objCourseUnit :[select Id,Name,Sequence_No__c,Course_Offering__c from Course_Plan_Unit__c 
                                                    where (Course_Offering__c In: set_courseOffIds and Id Not In: set_UnitIds)order by Sequence_No__c])
            {
                Intseqno = Intseqno+1;
                objCourseUnit.Sequence_No__c = Intseqno;
                lst_updateunits.add(objCourseUnit);
            }
        }
        if(!lst_updateunits.IsEmpty())
        {
            update lst_updateunits;
        }
    }
}