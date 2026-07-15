/**
 * @description Controller class for managing student allocation in RBS.
 * This class contains methods to handle course offerings, student data, and course connections.
 */
public with sharing class RBS_StudentAllocationController {
    /**
    *@description Wrapper class to store course offering data along with prgram and term.
    */
    public class CourseOfferingWrapper {
        @AuraEnabled public String programPlanName;
        @AuraEnabled public String termName;
        @AuraEnabled public Map<String, List<CourseOfferingdata>> mapCourseOfferingdata = new Map<String, List<CourseOfferingdata>>();
        /**
        *@description Wrapper class to store course offering data .
        */
        @AuraEnabled public List<CourseOfferingdata> lstCourseOffrData{get;set;}
    }

   /**
    *@description Wrapper class to store course offering data .
    */
    public class CourseOfferingdata {
        @AuraEnabled public String courseOfferingId;
        @AuraEnabled public String name;
        @AuraEnabled public String parentCourseOfferingName;
        @AuraEnabled public String courseName;
        @AuraEnabled public Boolean active;
        @AuraEnabled public Decimal assigned;
        @AuraEnabled public String specializationId;
    }

    /**
    *@description Wrapper class to student detailes .
    */
    public class RBSStudentWrapper {
        @AuraEnabled public String contactName;
        @AuraEnabled public String contactId;
        @AuraEnabled public String section;
        @AuraEnabled public String srnNumber;
        @AuraEnabled public String spclId;
        @AuraEnabled public String programEnrId;
    }
    /**
     * @description Returns Course Offering data grouped by specialization for the given Term Id.
     *
     * @param termId  Id of the hed__Term__c record to retrieve Course Offerings for.
     * @return        CourseOfferingWrapper containing program/term info, grouped map, and flat list.
     */
    @AuraEnabled
    public static CourseOfferingWrapper displayCourseOfferingRecords(String termId) {
        CourseOfferingWrapper wrap = new CourseOfferingWrapper();
        Set<String> categorySet = new Set<String>{'RBS Specialization'};
        List<CourseOfferingdata> lstCourseOfferingdata2 = new List<CourseOfferingdata>();
        List<CourseOfferingdata> lstCourseOfferingdata = new List<CourseOfferingdata>();
        for (hed__Term__c term : [
            SELECT Id, Name, Program_Batch__r.Name
            FROM hed__Term__c
            WHERE Id = :termId WITH USER_MODE
        ]) {
            wrap.programPlanName = term.Program_Batch__r.Name;
            wrap.termName = term.Name;
        }

        for (hed__Course_Offering__c course : [
            SELECT Id, Name, Specialization__r.Name, Assigned__c, Active__c, Sequence__c,Parent_Course_Offering__r.Name,Parent_Course_Offering__c
            FROM hed__Course_Offering__c
            WHERE hed__Term__c = :termId AND Category__c IN :categorySet WITH USER_MODE
            ORDER BY Sequence__c
        ]) {
            CourseOfferingdata data = new CourseOfferingdata();
            data.courseOfferingId = course.Id;
            data.name = course.Name;
            data.courseName = course.Name;
            data.parentCourseOfferingName = course.Specialization__r != null ? course.Specialization__r.Name : 'Uncategorized';
            data.active = course.Active__c;
            data.assigned = course.Assigned__c;
            data.specializationId = course.Specialization__c;

            if (!wrap.mapCourseOfferingdata.containsKey(data.parentCourseOfferingName)) {
                wrap.mapCourseOfferingdata.put(data.parentCourseOfferingName, new List<CourseOfferingdata>());
            }
            wrap.mapCourseOfferingdata.get(data.parentCourseOfferingName).add(data);
            lstCourseOfferingdata2.add(data);
        }
            for(CourseOfferingdata objCourse : lstCourseOfferingdata2)
        {
            //lstCourseOfferingdata.add(objCourse);
            if(wrap.mapCourseOfferingdata.get(objCourse.parentCourseOfferingName) != Null)
            {
                for(CourseOfferingdata objChildCourse : wrap.mapCourseOfferingdata.get(objCourse.parentCourseOfferingName))
                {
                    lstCourseOfferingdata.add(objChildCourse);
                }
            }
        }

        wrap.lstCourseOffrData = lstCourseOfferingdata;
        return wrap;
    }


   /**
     * @description Retrieves students enrolled in the specified specialization for a given term.
     *
     * @param spclId  Id of the specialization to filter students by.
     * @param termId  Id of the hed__Term__c (semester) to filter enrollments.
     * @return        List<RBSStudentWrapper> containing matching student details.
    */
    @AuraEnabled
    public static List<RBSStudentWrapper> getRBSstudentsbySpcl(String spclId, String termId) {
        List<RBSStudentWrapper> results = new List<RBSStudentWrapper>();
        if (String.isBlank(spclId) || String.isBlank(termId)) {
            return results;
        }

        try {
            List<hed__Program_Enrollment__c> enrollments = [
                SELECT Id,
                       hed__Contact__r.Name,
                       hed__Contact__c,
                       SRN_Number__c,
                       Application_Number__c,
                       Section__c
                FROM hed__Program_Enrollment__c
                WHERE Semester__c = :termId
                AND (RBS_Specialization_1__c = :spclId OR RBS_Specialization_2__c = :spclId) WITH USER_MODE
            ];


            for (hed__Program_Enrollment__c pe : enrollments) {
                if (pe.hed__Contact__c == null || pe.hed__Contact__r == null) {
                    continue;
                }
                RBSStudentWrapper wrapper = new RBSStudentWrapper();
                wrapper.contactId = pe.hed__Contact__c;
                wrapper.contactName = pe.hed__Contact__r.Name;
                wrapper.section = pe.Section__c;
                wrapper.srnNumber = String.isBlank(pe.SRN_Number__c) ? pe.Application_Number__c : pe.SRN_Number__c;
                wrapper.spclId = spclId;
                wrapper.programEnrId = pe.Id;

                results.add(wrapper);
            }


        } catch (Exception ex) {
            return results;
        }

        return results;
    }

    /**
     * @description Creates or updates Course Enrollment records for given students and semester.
     *
     * @param studentJson  JSON string of RBSStudentWrapper records to process.
     * @param semId        Id of the hed__Term__c (semester) in which to create enrollments.
     * @return             String indicating result status: 'Success', 'Partial', or 'Failed'.
    */
    @AuraEnabled
    public static String createCourseConnections(String studentJson , Id semId) {
        String status = 'Failed';

        try {
            List<RBSStudentWrapper> students = (List<RBSStudentWrapper>) JSON.deserialize(studentJson, List<RBSStudentWrapper>.class);
            if (students.isEmpty()) {
            return status;
            }
                Id ccStudRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();

            Set<Id> spclIds = new Set<Id>();
            for (RBSStudentWrapper sw : students) {
                if (!String.isBlank(sw.spclId)) {
                    spclIds.add(sw.spclId);
                }
            }

            Map<Id, List<hed__Course_Offering__c>> spclToOfferingsMap = new Map<Id, List<hed__Course_Offering__c>>();
            for (hed__Course_Offering__c offering : [
                SELECT Id, Specialization__c, hed__Term__c,
                       hed__Course__r.Course_External_ID__c
                FROM hed__Course_Offering__c
                WHERE Specialization__c IN :spclIds AND hed__Term__c = :semId WITH USER_MODE]) {

                if (!spclToOfferingsMap.containsKey(offering.Specialization__c)) {
                    spclToOfferingsMap.put(offering.Specialization__c, new List<hed__Course_Offering__c>());
                }
                spclToOfferingsMap.get(offering.Specialization__c).add(offering);

            }
            List<hed__Course_Enrollment__c> enrollmentsToUpsert = new List<hed__Course_Enrollment__c>();
            Set<String> externalIdSet = new Set<String>();

            for (RBSStudentWrapper sw : students) {
                if (String.isBlank(sw.contactId) || String.isBlank(sw.spclId)) {
                    continue;
                }

                List<hed__Course_Offering__c> offerings = spclToOfferingsMap.get(sw.spclId);
                if (offerings == null || offerings.isEmpty()) {
                    continue;
                }

                for (hed__Course_Offering__c offering : offerings) {
                    String extId = sw.srnNumber + '_' + offering.Id;
                    externalIdSet.add(extId);

                    enrollmentsToUpsert.add(new hed__Course_Enrollment__c(
                        External_Id__c = extId,
                        hed__Course_Offering__c = offering.Id,
                        hed__Program_Enrollment__c = sw.programEnrId,
                        Section__c = offering.hed__Term__c,
                        Logisys_External_Id__c = sw.srnNumber +''+ offering.hed__Course__r.Course_External_ID__c,
                        Semester_ID__c = offering.hed__Term__c,
                        RecordTypeId = ccStudRecTypeId,
                        hed__Contact__c = sw.contactId
                    ));
                }
            }


            if (!enrollmentsToUpsert.isEmpty()) {
                Database.UpsertResult[] results = Database.upsert(enrollmentsToUpsert, hed__Course_Enrollment__c.External_Id__c, false);
                Integer successCount = 0;
                Integer failureCount = 0;
                for (Database.UpsertResult res : results) {
                    if (res.isSuccess()) {
                        successCount++;
                    }
                    else {
                        failureCount++;
                    }
                }
                if (successCount > 0 && failureCount == 0) {
                    status = 'Success';
                } else if (successCount > 0 && failureCount > 0) {
                    status = 'Partial';
                } else {
                    status = 'Failed';
                }
            }

        } catch (Exception ex) {
            status = 'Failed';
        }

        return status;
    }

    /**
     * @description Activates or deactivates a Course Offering based on the provided JSON data.
     *
     * @param strCourOffer  JSON string of CourseOfferingdata containing the courseOfferingId and active flag.
     * @return              WrapperClass with a status message such as 'Success' or an error description.
     */
    @AuraEnabled
    public static WrapperClass activateCourseOffering(String strCourOffer) {
        WrapperClass objWrapperClass = new WrapperClass();
        try {
            CourseOfferingdata objCourseOfferWrp = (CourseOfferingdata)JSON.deserialize(strCourOffer, CourseOfferingdata.class);
            if (objCourseOfferWrp != null && String.isNotBlank(objCourseOfferWrp.courseOfferingId)) {
                hed__Course_Offering__c objCourseOff = new hed__Course_Offering__c(
                    Id = objCourseOfferWrp.courseOfferingId,
                    Active__c = objCourseOfferWrp.active
                );
                if (Schema.sObjectType.hed__Course_Offering__c.isUpdateable() && Schema.sObjectType.hed__Course_Offering__c.fields.Active__c.isUpdateable()) {
                    update objCourseOff;
                    objWrapperClass.strMessage = 'Success';
                } else {
                    objWrapperClass.strMessage = 'Error: insufficient access to update Course Offering.';
            }

            } else {
                objWrapperClass.strMessage = 'Error: Missing courseOfferingId';
            }
        } catch (Exception ex) {
            objWrapperClass.strMessage = 'Error: ' + ex.getMessage();
        }
        return objWrapperClass;
    }

  /*  public class ElectiveSubjects {
        @AuraEnabled public String subjectsNo;
        @AuraEnabled public String subjectsName;
        @AuraEnabled public String subjectsId;
        @AuraEnabled public String newSubjectId;
        @AuraEnabled public Integer totalRecords;
        @AuraEnabled public List<StudentPreferenceElectivs> lstStudPrefElect;

        public ElectiveSubjects() {
            lstStudPrefElect = new List<StudentPreferenceElectivs>();
            totalRecords = 0;
        }
    }

    public class StudentPreferenceElectivs {
        @AuraEnabled public String StudentPreferenceId;
        @AuraEnabled public String courseOfferingId;
        @AuraEnabled public String CourseOfferingCode;
        @AuraEnabled public String CourseName;
        @AuraEnabled public String Contact_Id;
        @AuraEnabled public String Contact_Name;
        @AuraEnabled public String Section_Name;
        @AuraEnabled public String SectionId;
        @AuraEnabled public String SRN_No;
        @AuraEnabled public String termId;
        @AuraEnabled public String termName;
        @AuraEnabled public String Preference1;
        @AuraEnabled public String Preference1_Id;
        @AuraEnabled public String Preference2;
        @AuraEnabled public String Preference2_Id;
        @AuraEnabled public String Preference3;
        @AuraEnabled public String Preference3_Id;
        @AuraEnabled public String newSubject_Id;
        @AuraEnabled public String newCourseOfferCode;
        @AuraEnabled public String ProgramEnrollId;
        @AuraEnabled public String SemesterId;
        @AuraEnabled public Boolean isChecked;

        public StudentPreferenceElectivs() {
            isChecked = false;
        }
    } */


    /**
     * @description WrapperClass for error message or success message
     */
    public class WrapperClass {
        @AuraEnabled public String strMessage;
    }
}