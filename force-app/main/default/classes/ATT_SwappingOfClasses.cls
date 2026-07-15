public without sharing class ATT_SwappingOfClasses 
{
    @AuraEnabled
    public static Map<id,string> DisplaySemesterRecords()
    {
        id usrid = userinfo.getuserid();
        date dt =system.today();
        map<id,hed__Course_Offering_Schedule__c> map_sch = new map<id,hed__Course_Offering_Schedule__c>();
        map<id,string> map_Semester = new map<id,string>();
        for(hed__Course_Offering_Schedule__c objsch : [select Id,Name,hed__Course_Offering__c,Section__c,Section__r.Name,Date__c from 
                                                       hed__Course_Offering_Schedule__c where Date__c =: dt])
        {
            map_sch.put(objsch.hed__Course_Offering__c,objsch);
        }
        if(map_sch.size()>0)
        {
            for(hed__Course_Enrollment__c objenroll : [select Id,Name,hed__Contact__c,hed__Course_Offering__c,Section__c,Section__r.Name,Owner_ID__c from
                                                       hed__Course_Enrollment__c where Owner_ID__c =: String.valueOf(usrid).substring(0, 15)
                                                       and hed__Course_Offering__c in: map_sch.keyset()])
            {
                if(map_sch.get(objenroll.hed__Course_Offering__c).Section__c != null)
                    map_Semester.put(map_sch.get(objenroll.hed__Course_Offering__c).Section__c,map_sch.get(objenroll.hed__Course_Offering__c).Section__r.Name);
            }
        }
        return map_Semester;
    }    
    @AuraEnabled
    public static Map<id,string> DisplayCourseOffering(Id SemesterId)
    {
        id usrid = userinfo.getuserid(); 
        date dt =system.today();
        map<id,hed__Course_Offering_Schedule__c> map_sch = new map<id,hed__Course_Offering_Schedule__c>();
        map<id,string> map_sec = new map<id,string>();
        if(SemesterId != null)
        {
            for(hed__Course_Offering_Schedule__c objsch : [select Id,Name,hed__Course_Offering__c,Section__c,Date__c,hed__Course_Offering__r.Name,hed__Start_Time__c,hed__End_Time__c from 
                                                           hed__Course_Offering_Schedule__c where Date__c =: dt and Section__c =:SemesterId])
            {
                map_sch.put(objsch.hed__Course_Offering__c ,objsch);
            }
        }
        if(map_sch.size()>0)
        {
            for(hed__Course_Enrollment__c objenroll : [select Id,Name,hed__Contact__c,hed__Contact__r.Name,hed__Course_Offering__c,Section__c,Owner_ID__c from
                                                       hed__Course_Enrollment__c where Owner_ID__c =: String.valueOf(usrid).substring(0, 15) and 
                                                       hed__Course_Offering__c in: map_sch.keyset()])
            {
                if(map_sch.get(objenroll.hed__Course_Offering__c).hed__Course_Offering__c != null)
                {
                    date stdate = map_sch.get(objenroll.hed__Course_Offering__c).Date__c;
                    string sdate = stdate.format();
                    string sttime = map_sch.get(objenroll.hed__Course_Offering__c).hed__Start_Time__c.hour() +':'+
                        map_sch.get(objenroll.hed__Course_Offering__c).hed__Start_Time__c.minute()+':'+
                        map_sch.get(objenroll.hed__Course_Offering__c).hed__Start_Time__c.second();
                    string endtime = map_sch.get(objenroll.hed__Course_Offering__c).hed__End_Time__c.hour() +':'+
                        map_sch.get(objenroll.hed__Course_Offering__c).hed__End_Time__c.minute()+':'+
                        map_sch.get(objenroll.hed__Course_Offering__c).hed__End_Time__c.second();
                    map_sec.put(map_sch.get(objenroll.hed__Course_Offering__c).Id,(map_sch.get(objenroll.hed__Course_Offering__c).hed__Course_Offering__r.Name+'-'+sdate+'-'+
                                                                                   sttime+'-'+endtime+'-'+objenroll.hed__Contact__r.Name));
                }
            }
        }
        return map_sec;
    }
    @AuraEnabled
    public static Map<id,string> DisplaySwappingRecords(Id SemesterId,Id CourseSchid)
    {
        id usrid = userinfo.getuserid();        
        date dt =system.today();
        time set_time;
        map<id,hed__Course_Offering_Schedule__c> map_sch = new map<id,hed__Course_Offering_Schedule__c>();
        map<id,string> map_sec = new map<id,string>();
        if(CourseSchid != null)
        {
            for(hed__Course_Offering_Schedule__c objsch : [select Id,Name,hed__Course_Offering__c,Section__c,Date__c,hed__Course_Offering__r.Name,hed__Start_Time__c,hed__End_Time__c from 
                                                           hed__Course_Offering_Schedule__c where id =:CourseSchid])
            {
                set_time = objsch.hed__Start_Time__c;
            }
        }
        if(SemesterId != null)
        {
            for(hed__Course_Offering_Schedule__c objsch : [select Id,Name,hed__Course_Offering__c,Section__c,Date__c,hed__Course_Offering__r.Name,hed__Start_Time__c,hed__End_Time__c from 
                                                           hed__Course_Offering_Schedule__c where Date__c =: dt and Section__c =:SemesterId])
            {
                map_sch.put(objsch.hed__Course_Offering__c ,objsch);
            }
        }
        if(map_sch.size()>0)
        {
            for(hed__Course_Enrollment__c objenroll : [select Id,Name,hed__Contact__c,hed__Contact__r.Name,hed__Course_Offering__c,Section__c,Owner_ID__c,Recordtype.Name from
                                                       hed__Course_Enrollment__c where Owner_ID__c !=: String.valueOf(usrid).substring(0, 15) and 
                                                       hed__Course_Offering__c in: map_sch.keyset() and Recordtype.Name =: Utility.CC_Faculty_RecType])
            {
                if(map_sch.get(objenroll.hed__Course_Offering__c).hed__Course_Offering__c != null)
                {
                    if(map_sch.get(objenroll.hed__Course_Offering__c).hed__Start_Time__c > set_time)
                    {
                        date stdate = map_sch.get(objenroll.hed__Course_Offering__c).Date__c;
                        string sdate = stdate.format();
                        string sttime = map_sch.get(objenroll.hed__Course_Offering__c).hed__Start_Time__c.hour() +':'+
                            map_sch.get(objenroll.hed__Course_Offering__c).hed__Start_Time__c.minute()+':'+
                            map_sch.get(objenroll.hed__Course_Offering__c).hed__Start_Time__c.second();
                        string endtime = map_sch.get(objenroll.hed__Course_Offering__c).hed__End_Time__c.hour() +':'+
                            map_sch.get(objenroll.hed__Course_Offering__c).hed__End_Time__c.minute()+':'+
                            map_sch.get(objenroll.hed__Course_Offering__c).hed__End_Time__c.second();
                        map_sec.put(map_sch.get(objenroll.hed__Course_Offering__c).Id,(map_sch.get(objenroll.hed__Course_Offering__c).hed__Course_Offering__r.Name+'-'+sdate+'-'+
                                                                                       sttime+'-'+endtime+'-'+objenroll.hed__Contact__r.Name));               
                    }
                }
            }
        }
        return map_sec;
    }
    
    @AuraEnabled
    public static string SavingSwappingRecords(string FromId,string ToId)
    {
        string message;
        String ContactId;
        String ToCourseid;
        String FromCourseid;
        set<id> set_CourseId = new set<id>();
        list<Swapping_Classes__c> lst_Swap = new list<Swapping_Classes__c>();
        if(FromId != null && ToId != null)
        {
            try
            {
                for(hed__Course_Offering_Schedule__c objsch : [select Id,Name,hed__Course_Offering__c,Section__c,Date__c,hed__Course_Offering__r.Name,hed__Start_Time__c,hed__End_Time__c from 
                                                               hed__Course_Offering_Schedule__c where  id =: FromId])
                {
                    FromCourseid = objsch.hed__Course_Offering__c;
                }   
                for(hed__Course_Offering_Schedule__c objsch : [select Id,Name,hed__Course_Offering__c,Section__c,Date__c,hed__Course_Offering__r.Name,hed__Start_Time__c,hed__End_Time__c from 
                                                               hed__Course_Offering_Schedule__c where  id =: ToId])
                {
                    set_CourseId.add(objsch.hed__Course_Offering__c);
                    ToCourseid = objsch.hed__Course_Offering__c;
                }
                if(set_CourseId.size  ()>0)
                {
                    for(hed__Course_Enrollment__c objenroll : [select Id,Name,Ownerid,hed__Contact__c,hed__Contact__r.Ownerid,hed__Course_Offering__c,Section__c,Owner_ID__c,Recordtype.Name from
                                                               hed__Course_Enrollment__c where hed__Course_Offering__c in: set_CourseId])
                    {
                        ContactId = objenroll.hed__Contact__r.Ownerid;
                    }
                }
                Swapping_Classes__c objSwap = new Swapping_Classes__c();
                if(FromId != null)
                    objSwap.From_Class__c = FromId;
                if(ToId != null)
                    objSwap.To_Class__c = ToId;
                objSwap.Requested_Date__c = system.today();
                if(ContactId != null)
                    objSwap.Approver__c = ContactId;
                objSwap.Approval_Status__c ='Submitted';
                if(FromCourseid !=null)
                    objSwap.From_class_ID__c = FromCourseid;
                if(ToCourseid != null)
                    objSwap.To_Class_ID__c = ToCourseid;
                objSwap.From_COS_ID__c = FromId;
                objSwap.To_COS_ID__c = ToId;
                lst_Swap.add(objSwap);
                if(lst_Swap.size()>0)
                {
                    insert lst_Swap;
                    message = 'Swapping Classes Records are Created Successfully';
                }
            }
            catch(exception e)
            {
                message = e.getMessage();
            }
        }
        return message;
    }
}