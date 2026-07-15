public class ATT_Mark_Attendance{
    
    @AuraEnabled
    public static InitResWrp getCOSDetails(string cosId){
        InitResWrp w = new InitResWrp();
        hed__Course_Offering_Schedule__c cosObj = [SELECT id,hed__Course_Offering__c,Batch_Group__c, hed__Course_Offering__r.Semester_Course_offering__c,Section__c,hed__Facility__c,hed__Start_Time__c,hed__End_Time__c,Date__c,
                                                   hed__Monday__c,hed__Tuesday__c,hed__Wednesday__c,hed__Thursday__c,hed__Friday__c,hed__Saturday__c,CO_Schedule_Parent__c,
                                                   hed__Sunday__c,hed__Course_Offering__r.Name,Section__r.Name,Section__r.hed__Parent_Term__c,Teaching_Method__c,Course_Plan_Completed__c,Reason_for_not_completing__c,
                                                   Status__c,Section__r.hed__Parent_Term__r.Name,Section__r.hed__Parent_Term__r.Program_Batch__r.Name,Actual_Topic__c,Planned_Topic__c,Planned_Topic__r.name,Actual_Topic__r.Name,hed__Course_Offering__r.Category__c
                                                   FROM hed__Course_Offering_Schedule__c WHERE id =: cosId]; 
        List<hed__Course_Offering_Schedule__c> countOfCO = [SELECT Id FROM hed__Course_Offering_Schedule__c WHERE Date__c =: cosObj.Date__c 
                                                            AND hed__Course_Offering__c =: cosObj.hed__Course_Offering__c AND Id !=: cosObj.Id 
                                                            AND hed__Start_Time__c <: cosObj.hed__Start_Time__c AND Batch_Group__c =: cosObj.Batch_Group__c];
        if(cosObj.Actual_Topic__c == null) {
            List<hed__Course_Offering_Schedule__c> preRec = [SELECT id,hed__Course_Offering__c,Actual_Topic__r.Sequence_No__c,
                                                             Actual_Topic__r.Course_Plan_Unit__r.Sequence_No__c,Actual_Topic__c
                                                             FROM hed__Course_Offering_Schedule__c 
                                                             WHERE Date__c <: cosObj.Date__c and 
                                                             CO_Schedule_Parent__c =: cosObj.CO_Schedule_Parent__c and 
                                                             Course_Plan_Completed__c = 'Yes' ORDER  by Date__c DESC limit 1];
            String topic;
            if(preRec == null || preRec.size() == 0) {
                topic = getNextTopic(cosObj.hed__Course_Offering__r.Semester_Course_offering__c, 1);               
            }
            else if(cosObj.hed__Course_Offering__c != null && preRec[0].Actual_Topic__c != null) {
                topic= getNextTopic(cosObj.hed__Course_Offering__r.Semester_Course_offering__c, Integer.valueof(preRec[0].Actual_Topic__r.Sequence_No__c+1));
            } 
            if(topic != null){
                cosObj.Actual_Topic__c = topic.split('-')[1];
                w.aTopic = topic.split('-')[0];
            }
        }
        else w.aTopic = cosObj.Actual_Topic__r.Name;
        w.pTopic = cosObj.Planned_Topic__r.name;
        w.preCOSId = countOfCO != null && countOfCO.size() > 0 ? countOfCO[0].Id : null ;
        w.cosRec =  cosObj;
        w.Category= cosObj.hed__Course_Offering__r.Category__c;
        w.lst_Att = ATT_Mark_Attendance.getAttachment(cosId);
        return w;
    }
    
    public static list<attachmentWarp> getAttachment(string cosId){
        
        list<attachmentWarp> lstAttach = new list<attachmentWarp>();
        
        hed__Course_Offering_Schedule__c cosObj = [SELECT id,hed__Course_Offering__c,Section__c,hed__Facility__c
                                                   FROM hed__Course_Offering_Schedule__c WHERE id =: cosId]; 
        
        for(ContentDocumentLink Objcon : [SELECT ContentDocumentId, LinkedEntityId ,ContentDocument.title 
                                          FROM ContentDocumentLink where LinkedEntityId =: cosObj.hed__Course_Offering__c]){
                                              attachmentWarp attch = new attachmentWarp();
                                              attch.checkBox = false;
                                              attch.AttachName = Objcon.ContentDocument.title;
                                              attch.AttachId = Objcon.ContentDocumentId;
                                              lstAttach.add(attch);
                                          }                                           
        return lstAttach;
    }
    
    
    @AuraEnabled
    public static void saveAttendance(String i_CosId,String i_teachingMethodStr, String i_isCoursePlanComplete, 
                                      String i_reasonStr, List<studentWarp> i_StuRec,String fileName, String dataURL,String i_Topic)
    {
        String tempAtt;
        List<hed__Course_Offering_Schedule__c> list_cos = new List<hed__Course_Offering_Schedule__c>();
        Map<Id, Id> mp_SemCon = new Map<Id, Id>();
        Map<Id, Id> mp_ConPro = new Map<Id, Id>();
        Map<Id, Id> mp_Offerins = new Map<Id, Id>();
        Map<String, Id> mp_CourseSem = new Map<String, Id>();
        Id tempId;
        Set<Id> set_Cons = new Set<Id>();
        Database.setSavepoint();                                 
        List<hed__Attendance_Event__c> lst_AttRec = new List<hed__Attendance_Event__c>();                               
        hed__Course_Offering_Schedule__c cos = new hed__Course_Offering_Schedule__c();
        cos.Id = i_CosId;
        cos.Teaching_Method__c = i_teachingMethodStr;
        cos.Course_Plan_Completed__c = i_isCoursePlanComplete;	
        cos.Reason_for_not_completing__c = i_reasonStr;
        //cos.Status__c = 'Completed / Attendance Marked';
        cos.Status__c = 'Locked';
        cos.Actual_Topic__c = i_Topic;
        update cos;
        hed__Course_Offering_Schedule__c cosObj = [SELECT id,hed__Course_Offering__c,hed__Start_Time__c,hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,hed__Course_Offering__r.hed__Course__r.Category__c,Section__c,hed__Facility__c, Date__c,Batch_Group__c, Batch_Group__r.name,hed__End_Time__c
                                                   FROM hed__Course_Offering_Schedule__c WHERE id =: i_CosId];
        
        for(studentWarp eachStu : i_StuRec) {
            set_Cons.add(eachStu.contId);
        }
       
        if(cosObj.hed__Course_Offering__r.hed__Course__r.Category__c == 'Open Elective') {
            if(set_Cons.size() > 0 ) {
                for(hed__Program_Enrollment__c en : [SELECT Id,Semester__c,hed__Contact__c  FROM hed__Program_Enrollment__c WHERE Active__c = true and hed__Contact__c IN: set_Cons]){
                    mp_SemCon.put(en.hed__Contact__c, en.Semester__c);
                     System.debug('DEBUG: Mapped Contact ' + en.hed__Contact__c + ' to Semester ' + en.Semester__c);
                }
                for(hed__Course_Offering__c off : [SELECT Id, hed__Course__c,hed__Term__c FROM hed__Course_Offering__c WHERE hed__Term__c IN: mp_SemCon.values() and Course_Offering_Active__c  = true and hed__Course__r.hed__Course_ID__c =: cosObj.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c and Semester_Record_Type__c = 'Semester']){
                    mp_CourseSem.put(off.hed__Term__c , off.Id);
                    System.debug('DEBUG: Mapped Semester ' + off.hed__Term__c +' to Course name ' + off.hed__Course__c+' Course off id '+off.id);
                }
            }
            for(hed__Course_Offering_Schedule__c cosSch :  [SELECT id,hed__Course_Offering__c,hed__Start_Time__c,hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,hed__Course_Offering__r.hed__Course__r.Category__c,Section__c,hed__Facility__c, Date__c,Batch_Group__c, Batch_Group__r.name,hed__End_Time__c
                                                            FROM hed__Course_Offering_Schedule__c WHERE hed__Course_Offering__c in: mp_CourseSem.values() and Date__c =: cosObj.Date__c])
            {
                mp_Offerins.put(cosSch.hed__Course_Offering__c, cosSch.Id); 
                System.debug('DEBUG: Mapped Course Offering ' + cosSch.hed__Course_Offering__c + ' to Schedule ' + cosSch.Id);
               /* hed__Course_Offering_Schedule__c sch = cosSch;
                sch.Id = cosSch.Id;
                sch.Teaching_Method__c = i_teachingMethodStr;
                sch.Course_Plan_Completed__c = i_isCoursePlanComplete;	
                sch.Reason_for_not_completing__c = i_reasonStr;
                //cos.Status__c = 'Completed / Attendance Marked';
                sch.Status__c = 'Locked';
                sch.Actual_Topic__c = i_Topic;
                list_cos.add(sch);*/
            }
           // update list_cos;
        }
        system.debug('Semester and Contact ids=='+mp_SemCon);
        system.debug('Course Offering Ids=='+mp_CourseSem);
        system.debug('Course Offering Schedule Ids=='+mp_Offerins);
        
        for(studentWarp eachStu : i_StuRec) {           
            String coffer;
            tempAtt = eachStu.checkBox ? 'Present' : 'Absent';
            if(mp_SemCon.get(eachStu.contId) != null && mp_CourseSem.get(mp_SemCon.get(eachStu.contId)) != null) {
                
                /*coffer = cosObj.hed__Course_Offering__r.hed__Course__r.Category__c != 'Open Elective' ? i_CosId : mp_Offerins.get(mp_CourseSem.get(mp_SemCon.get(eachStu.contId)));
                System.debug('DEBUG: Student ' + eachStu.contId + ' assigned to Schedule ' + coffer + ' (Open Elective mapping)'); */
                coffer= i_CosId;
            }
            else coffer= i_CosId;
            System.debug('DEBUG: Student ' + eachStu.contId + ' assigned to Default Schedule ' + coffer + ' (No mapping found)');
            lst_AttRec.add(new hed__Attendance_Event__c(Course_Offering_Schedule__c = coffer,
                                                        hed__Reason_Description__c = eachStu.proxyReason,
                                                        hed__Attendance_Type__c = tempAtt,
                                                        hed__Contact__c = eachStu.contId,
                                                        Id=eachStu.attId,
                                                        hed__Course_Connection__c =eachStu.enrollId ));
        }       
        
        //upsert lst_AttRec;
        Database.UpsertResult[] results = Database.upsert(lst_AttRec);
        
        if(lst_AttRec.size()>0)
        {
            set<id> set_AttEveIds = new set<id>();
            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(results[index].isSuccess()) {
                    if(results[index].isCreated()) {
                        set_AttEveIds.add(lst_AttRec[index].Id);
                        System.debug(lst_AttRec[index].Id +' was created');
                    } else {
                        System.debug(lst_AttRec[index].Id +' was updated');
                    }
                }
            }
            
            // for(hed__Attendance_Event__c objAttEve : lst_AttRec)
            //{
            
            //}
            if(set_AttEveIds.size() >0)
            {
                TT_AttendanceSMS_Batch SchCls = new TT_AttendanceSMS_Batch(set_AttEveIds);
                DataBase.executeBatch(SchCls,50);
            }
        }
        if(!String.isBlank(dataURL)){
            ContentVersion contentVersionRec = new ContentVersion();  
            contentVersionRec.Title = fileName;  
            contentVersionRec.PathOnClient = '/'+fileName;  
            contentVersionRec.FirstPublishLocationId = i_CosId;  
            contentVersionRec.VersionData = EncodingUtil.base64Decode(dataURL);  
            contentVersionRec.IsMajorVersion = true;  
            Insert contentVersionRec;
        }                                  
    }
    
    @AuraEnabled
    public static list<studentWarp> getpreviousDetails(string cloneFrom, Boolean cloneRequired){
        list<studentWarp> lststudent = new list<studentWarp>();
        Set<Id> set_Sch = new Set<Id>();
        Set<Id> set_Off = new Set<Id>();
        integer count = 1;
        hed__Course_Offering_Schedule__c cosObj = [SELECT id,hed__Course_Offering__c,hed__Start_Time__c,hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,hed__Course_Offering__r.hed__Course__r.Category__c,Section__c,hed__Facility__c, Date__c,Batch_Group__c, Batch_Group__r.name,hed__End_Time__c
                                                   FROM hed__Course_Offering_Schedule__c WHERE id =: cloneFrom];
        
        List<String> schIds = new List<String>();
        schIds.add(cloneFrom);
        
        
        List<String> scheIds = new List<String>();
        if (cosObj.Batch_Group__c != null) {
            List<hed__Course_Offering_Schedule__c> scheduleRecords = [SELECT Id FROM hed__Course_Offering_Schedule__c WHERE Batch_Group__c = :cosObj.Batch_Group__c AND Date__c = :cosObj.Date__c];
            for (hed__Course_Offering_Schedule__c scheduleRecord : scheduleRecords) {
                scheIds.add(scheduleRecord.Id);
            }
        } else if (cosObj.Section__c != null) {
            List<hed__Course_Offering_Schedule__c> scheduleRecords = [SELECT Id FROM hed__Course_Offering_Schedule__c WHERE Section__c = :cosObj.Section__c AND Date__c = :cosObj.Date__c];
            for (hed__Course_Offering_Schedule__c scheduleRecord : scheduleRecords) {
                scheIds.add(scheduleRecord.Id);
            }
        }
        
        List<hed__Attendance_Event__c> lst_AttRec = new List<hed__Attendance_Event__c>(); 
        for(hed__Attendance_Event__c eachRec : [SELECT Id,hed__Contact__r.Attendance_Blocked__c,hed__Contact__r.Name,hed__Contact__r.SRN_Number__c,hed__Course_Connection__c,hed__Reason_Description__c,hed__Attendance_Type__c,hed__Contact__c,Course_Offering_Schedule__c
                                                FROM hed__Attendance_Event__c
                                                WHERE Course_Offering_Schedule__c IN: schIds 
                                                ORDER BY hed__Contact__r.SRN_Number__c ]) 
        {
            studentWarp objStudent = new studentWarp();
            objStudent.slNo = string.valueof(count);
            objStudent.srnNo = eachRec.hed__Contact__r.SRN_Number__c;
            objStudent.Name = eachRec.hed__Contact__r.Name;
            objStudent.contId = eachRec.hed__Contact__c;
            objStudent.enrollId = eachRec.hed__Course_Connection__c;
            objStudent.checkBox = eachRec.hed__Attendance_Type__c == 'Present' ? true : false;
            objStudent.checkBox = eachRec.hed__Contact__r.Attendance_Blocked__c ? false : objStudent.checkBox; //added by Chaithanya
            objStudent.attendanceBlocked = eachRec.hed__Contact__r.Attendance_Blocked__c; //added by Chaithanya
            objStudent.proxyReason = eachRec.hed__Reason_Description__c;  
            objStudent.attId = cloneRequired ? null : eachRec.Id;
            lststudent.add(objStudent);
            count = count + 1;
        }
        return lststudent;
    }
    
    @AuraEnabled
    public static list<studentWarp> getStudentDetails(string cosId){
        Id stuRecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        list<studentWarp> lststudent = new list<studentWarp>();
        Set<String> courseCat = new Set<String>{'Hardcore Course','Hardcore Integrated Course','Mandatory Course'};
            hed__Course_Offering_Schedule__c cosObj = [SELECT id,hed__Course_Offering__c,hed__Start_Time__c,hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,hed__Course_Offering__r.hed__Course__r.Category__c,Section__c,hed__Facility__c, Date__c,Batch_Group__c, Batch_Group__r.name,hed__End_Time__c
                                                       FROM hed__Course_Offering_Schedule__c WHERE id =: cosId];
        
        Id recordId = courseCat.contains(cosObj.hed__Course_Offering__r.hed__Course__r.Category__c) ? cosObj.Section__c : cosObj.Batch_Group__c;
        //Get the proxy attendance list
        Map<Id, Proxy_Attendance__c> mp_ProxyStu = new Map<Id, Proxy_Attendance__c>();
        Datetime curDate = Datetime.newInstance(cosObj.Date__c, cosObj.hed__Start_Time__c);
        Datetime endTime = Datetime.newInstance(cosObj.Date__c, cosObj.hed__End_Time__c);
        mp_ProxyStu = getProxyList(curDate,endTime);
        integer count = 1;
        Set<Id> set_off = new Set<Id>();
        String query = 'SELECT id,hed__Contact__c,hed__Contact__r.Attendance_Blocked__c,Section__c,hed__Contact__r.Name,hed__Contact__r.SRN_Number__c,hed__Contact__r.Student_Status__c';
        query += ' FROM hed__Course_Enrollment__c WHERE (hed__Contact__r.Student_Status__c = \'Pursuing\') and';
        if(cosObj.hed__Course_Offering__r.hed__Course__r.Category__c == 'Open Elective') {
            for(hed__Course_Offering__c eachOff :[SELECT Id,Name,Offered_By_School__r.Name, Offered_By_School__c,hed__Course__c,hed__Course__r.Max_Students__c,
                                                  hed__Term__r.Term_Number__c,hed__Term__c                                             
                                                  FROM hed__Course_Offering__c
                                                  WHERE Course_Offering_Active__c  = true and Semester_Record_Type__c = 'Semester' and 
                                                  Category__c = 'Open Elective' and hed__Course__r.hed__Course_ID__c =: cosObj.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c
                                                 ])
                
            {
                set_off.add(eachOff.Id);
            }
            query += '  hed__Course_Offering__c in: set_off  and Section__r.Name =\'' + cosObj.Batch_Group__r.name + '\'';
        }
        else query += ' hed__Course_Offering__c = \'' +cosObj.hed__Course_Offering__c + '\' and Section__c =: recordId';
        
        query += ' and RecordTypeId =: stuRecordTypeId  order by hed__Contact__r.SRN_Number__c'; 
        for(hed__Course_Enrollment__c objCc : Database.query(query))
        {
            studentWarp objStudent = new studentWarp();
            objStudent.slNo = string.valueof(count);
            objStudent.srnNo = objCc.hed__Contact__r.SRN_Number__c;
            objStudent.Name = objCc.hed__Contact__r.Name;
            objStudent.contId = objCC.hed__Contact__c;
            objStudent.enrollId = objCC.Id;
            objStudent.checkBox = !objCc.hed__Contact__r.Attendance_Blocked__c;
            objStudent.proxyReason = '';
            objStudent.attendanceBlocked = objCc.hed__Contact__r.Attendance_Blocked__c;
            if(mp_ProxyStu.get(objCC.hed__Contact__c) != null) 
                objStudent.proxyReason = mp_ProxyStu.get(objCC.hed__Contact__c).Reason__c;
            lststudent.add(objStudent);
            count = count + 1;
        }
        
        return lststudent;
    }
    
    public static String getNextTopic(Id i_CourseId, Integer i_SeqNo) {
        try{
            Course_Plan_Topic__c topic = [SELECT Id,name from Course_Plan_Topic__c 
                                          WHERE Course_Plan_Unit__r.Course_Offering__c =: i_CourseId and Sequence_No__c =: i_SeqNo LIMIT 1];
            return topic.name + '-' + topic.Id;
        }
        catch(exception e) {
            return null;
        }        
    }    
    public static Map<Id, Proxy_Attendance__c> getProxyList(Datetime i_Date,Datetime i_endTime) {
        Map<Id, Proxy_Attendance__c> mp_Proxy = new Map<Id, Proxy_Attendance__c>();
        for(Proxy_Attendance__c eachProxy :[SELECT Id,Contact__c,Reason__c,Date_To__c,Date_From__c FROM Proxy_Attendance__c WHERE Date_To__c >=: i_Date]){
            if(i_Date >= eachProxy.Date_From__c )
                mp_Proxy.put(eachProxy.Contact__c, eachProxy);
        }
        return mp_Proxy;
    }
    
    public class InitResWrp {
        @AuraEnabled public  hed__Course_Offering_Schedule__c cosRec  {get;set;}
        @AuraEnabled public  list<attachmentWarp> lst_Att {get;set;}
        @AuraEnabled public String preCOSId {get;set;}
        @AuraEnabled public String pTopic {get;set;}
        @AuraEnabled public String aTopic {get;set;}
        @AuraEnabled public String Category {get;set;}
    }
    
    public class attachmentWarp{
        @AuraEnabled public boolean checkBox {get;set;}
        @AuraEnabled public string AttachName {get;set;}
        @AuraEnabled public string AttachId {get;set;}
    }
    
    public class studentWarp{
        @AuraEnabled public boolean checkBox {get;set;}
        @AuraEnabled public string attId {get;set;}
        @AuraEnabled public string enrollId {get;set;}
        @AuraEnabled public string contId {get;set;}
        @AuraEnabled public string slNo {get;set;}
        @AuraEnabled public string srnNo {get;set;}
        @AuraEnabled public string Name {get;set;}
        @AuraEnabled public string proxyReason {get;set;}
        @AuraEnabled public boolean attendanceBlocked {get;set;}
    }
    
}