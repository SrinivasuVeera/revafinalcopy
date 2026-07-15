public class STOB_ProfessorStudentTriggerHandler
{
    public static void RollupPreference(list<Professor_Student_Course_Preference__c> lst_Preference,
                                        map<id,Professor_Student_Course_Preference__c> olaMap_Preference)
    {
        set<id> set_courseid = new set<id>();
        set<id> set_Termid = new set<id>();
        map<id,hed__Course_Offering__c> map_CourseOff = new map<id,hed__Course_Offering__c>();

        for(Professor_Student_Course_Preference__c objStuPref : lst_Preference)
        {
            if(olaMap_Preference == null && objStuPref.Course_Offering__c  != null && objStuPref.Preference__c != null
               && objStuPref.Contact__c != null && objStuPref.Semester__c !=null)
            {
                set_courseid.add(objStuPref.Course_Offering__c);
                set_Termid.add(objStuPref.Semester__c);
            }
            if(olaMap_Preference !=null && (olaMap_Preference.get(objStuPref.Id).Course_Offering__c != objStuPref.Course_Offering__c ||
                                            olaMap_Preference.get(objStuPref.Id).Preference__c != objStuPref.Preference__c)
                                       && objStuPref.Contact__c != null && objStuPref.Semester__c !=null)
            {
                if(objStuPref.Course_Offering__c  != null)
                    set_courseid.add(objStuPref.Course_Offering__c);
                else if(olaMap_Preference.get(objStuPref.Id).Course_Offering__c != null)
                    set_courseid.add(olaMap_Preference.get(objStuPref.Id).Course_Offering__c);
                set_Termid.add(objStuPref.Semester__c);
            }
        }
        if(set_courseid.size() >0 && set_Termid.size()>0)
        {
            for(Id CourseId : set_courseid)
            {
                map_CourseOff.put(CourseId,new hed__Course_Offering__c(id=CourseId,Student_Preference_1__c=0,Student_Preference_2__c =0,Student_Preference_3__c = 0));
            }
            for(Professor_Student_Course_Preference__c objStuPref : [select id,Name,Course_Offering__c,Preference__c,Contact__c,Semester__c from Professor_Student_Course_Preference__c
                                                                     where Course_Offering__c in: set_courseid and Semester__c in: set_Termid])
            {
                if(map_CourseOff.get(objStuPref.Course_Offering__c) != null)
                {
                    if(objStuPref.Preference__c == '1')  map_CourseOff.get(objStuPref.Course_Offering__c).Student_Preference_1__c += 1;
                    if(objStuPref.Preference__c == '2')  map_CourseOff.get(objStuPref.Course_Offering__c).Student_Preference_2__c += 1;
                    if(objStuPref.Preference__c == '3')  map_CourseOff.get(objStuPref.Course_Offering__c).Student_Preference_3__c += 1;
                }
            }
        }
        if(map_CourseOff.size()>0)
        {
            update map_CourseOff.values();
        }
    }

    /**
     * @description This method rolls up professor preferences for course offerings based on the provided list of preferences.
     *
     * @param lstProPreference List of Professor_Student_Course_Preference__c records to process.
     * @param olaMapProPreference Map of existing Professor_Student_Course_Preference__c records for comparison.
     */
    public static void rollupPreferenceForProfessor(list<Professor_Student_Course_Preference__c> lstProPreference,
                                        map<id,Professor_Student_Course_Preference__c> olaMapProPreference)
    {
        set<id> setCourseIds = new set<id>();
        set<id> setTermid = new set<id>();
        map<id,hed__Course_Offering__c> mapCourseOff = new map<id,hed__Course_Offering__c>();

        for(Professor_Student_Course_Preference__c objStuPref : lstProPreference)
        {
            if(olaMapProPreference == null && objStuPref.Course_Offering__c  != null && objStuPref.Preference__c != null
               && objStuPref.Professor__c != null && objStuPref.Semester__c !=null)
            {
                System.debug('inside ----old null');
                setCourseIds.add(objStuPref.Course_Offering__c);
                setTermid.add(objStuPref.Semester__c);
            }
            else if (olaMapProPreference !=null && (olaMapProPreference.get(objStuPref.Id).Course_Offering__c != objStuPref.Course_Offering__c ||
            olaMapProPreference.get(objStuPref.Id).Preference__c != objStuPref.Preference__c)
                                       && objStuPref.Professor__c != null && objStuPref.Semester__c !=null  && objStuPref.Preference__c != olaMapProPreference.get(objStuPref.Id).Preference__c)
            {
                
                System.debug('inside ----old not null');
                if(objStuPref.Course_Offering__c  != null){
                     System.debug('inside ----old not null off');
                setCourseIds.add(objStuPref.Course_Offering__c);
                }
                else if(olaMapProPreference.get(objStuPref.Id).Course_Offering__c != null)
                {
                setCourseIds.add(olaMapProPreference.get(objStuPref.Id).Course_Offering__c);
                }
                setTermid.add(objStuPref.Semester__c);
            }
        }
         System.debug('setCourseIds ----'+setCourseIds);
         System.debug('setTermid ----'+setTermid);
        if(setCourseIds.size() >0 && setTermid.size()>0)
        {
            for(Id courseId : setCourseIds)
            {
                mapCourseOff.put(courseId, new hed__Course_Offering__c(
                    Id = courseId,
                    Professor_Theory_Preference_1__c = 0,
                    Professor_Theory_Preference_2__c = 0,
                    Professor_Theory_Preference_3__c = 0,
                    Professor_Theory_Preference_4__c = 0,
                    Professor_Theory_Preference_5__c = 0,
                    Professor_Theory_Preference_6__c = 0,
                    Professor_Practical_Preference_1__c = 0,
                    Professor_Practical_Preference_2__c = 0,
                    Professor_Practical_Preference_3__c = 0,
                    Professor_Practical_Preference_4__c = 0
                ));
            }
                for (Professor_Student_Course_Preference__c objStuPref : [SELECT Id, Name, Course_Offering__c, Preference__c, Contact__c, Semester__c,
                                                                                   Course_Offering__r.Category__c
                                                                        FROM Professor_Student_Course_Preference__c
                                                                        WHERE Course_Offering__c IN :setCourseIds AND Semester__c IN :setTermid with USER_MODE
                ]) {
                    if (mapCourseOff.containsKey(objStuPref.Course_Offering__c)) {
                        hed__Course_Offering__c courseOff = mapCourseOff.get(objStuPref.Course_Offering__c);
                        String pref = objStuPref.Preference__c;

                        if (String.valueOf(objStuPref.Course_Offering__r.Category__c) == 'Practical/Term work') {
                            if (pref == '1') {
                                courseOff.Professor_Practical_Preference_1__c += 1;
                            } else if (pref == '2') {
                                courseOff.Professor_Practical_Preference_2__c += 1;
                            } else if (pref == '3') {
                                courseOff.Professor_Practical_Preference_3__c += 1;
                            }
                            else if (pref == '4') {
                                courseOff.Professor_Practical_Preference_4__c += 1;
                            }
                        } else {
                            if (pref == '1') {
                                courseOff.Professor_Theory_Preference_1__c += 1;
                            } else if (pref == '2') {
                                courseOff.Professor_Theory_Preference_2__c += 1;
                            } else if (pref == '3') {
                                courseOff.Professor_Theory_Preference_3__c += 1;
                            } else if (pref == '4') {
                                courseOff.Professor_Theory_Preference_4__c += 1;
                            } else if (pref == '5') {
                                courseOff.Professor_Theory_Preference_5__c += 1;
                            } else if (pref == '6') {
                                courseOff.Professor_Theory_Preference_6__c += 1;
                            }
                        }
                    }
                }
        }
        if(mapCourseOff.size()>0)
        {
            update mapCourseOff.values();
        }
    }
}