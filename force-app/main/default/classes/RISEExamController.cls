/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : RISEExamController
 * Author          : Santoshkumar
 * Created Date    : Jun 11, 2026
 * Description     : This class controlls the RISE related requests
 *   
 */

public with sharing class RISEExamController {

    @AuraEnabled(cacheable=false)
    public static List<Contact> getApplicants(String searchKey, String selectedDepartmentKey, String selectedAcademicProgramKey) {
        System.debug('Input Params : ' + 'searchKey : ' + searchKey + ' selectedDepartmentKey : ' + selectedDepartmentKey + ' selectedAcademicProgramKey : ' + selectedAcademicProgramKey);
        String query = 'SELECT Id, Name, Application_Number__c, Email, MobilePhone, ' +
                       'Primary_Academic_Program__c, Exam_Date1__c, RISE_Exam_Score__c, ' +
                       'RISE_Violation_Score__c, RISE_Pushed_Date__c, RISE_Actual_Score__c, ' +
                       'RISE_Result__c ' +
                       'FROM Contact ' +
                       'WHERE Record_Type_Name__c = \'Applicant\' ' +
                       'AND Application_Fee_Paid__c = true ' +
                       'AND Applying_For_REVA_CET__c = \'Yes\' ' +
                       'AND Program_Batch_Name__c LIKE \'%2026-%\'';

        if (String.isNotBlank(searchKey)) {
            String likeKey = '%' + String.escapeSingleQuotes(searchKey) + '%';
            query += ' AND (Application_Number__c LIKE :likeKey ' +
                     'OR Email LIKE :likeKey ' +
                     'OR MobilePhone LIKE :likeKey ' +
                     'OR Name LIKE :likeKey)';
        }

        if (String.isNotBlank(selectedDepartmentKey)) {
            query += ' AND School__c = \'' + String.escapeSingleQuotes(selectedDepartmentKey) + '\'';
        }

        if (String.isNotBlank(selectedAcademicProgramKey)) {
            query += ' AND Primary_Academic_Program__c = \'' +
                    String.escapeSingleQuotes(selectedAcademicProgramKey) + '\'';
        }

        query += ' ORDER BY Application_Number__c ASC NULLS LAST';

        System.debug('Final Query: ' + query);

        return Database.query(query);
    }

    // @AuraEnabled
    // public static List<Contact> getApplicantsByExamDate(Date examDate) {
    //     return [
    //         SELECT Id, Name, Application_Number__c, Email, MobilePhone,
    //                Primary_Academic_Program__c, Exam_Date1__c, RISE_Exam_Score__c,
    //                RISE_Violation_Score__c, RISE_Pushed_Date__c, RISE_Actual_Score__c,
    //                RISE_Result__c
    //         FROM Contact
    //         WHERE Record_Type_Name__c = 'Applicant'
    //         AND Application_Fee_Paid__c = true
    //         AND Applying_For_REVA_CET__c = 'Yes'
    //         AND Program_Batch_Name__c LIKE '%2026-%'
    //         AND Exam_Date1__c = :examDate
    //         ORDER BY Application_Number__c ASC NULLS LAST
    //         LIMIT 200
    //     ];
    // }

    @AuraEnabled
    public static String saveApplicants(List<Contact> contacts) {
        try {
            if (contacts == null || contacts.isEmpty()) {
                return 'No records to save.';
            }

            List<Contact> toUpdate = new List<Contact>();
            for (Contact c : contacts) {
                toUpdate.add(new Contact(
                    Id = c.Id,
                    RISE_Actual_Score__c = c.RISE_Actual_Score__c,
                    RISE_Result__c = c.RISE_Result__c
                ));
            }

            update toUpdate;
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException('Error saving records: ' + e.getMessage());
        }
    }    

    @AuraEnabled(cacheable=true)
    public static List<DepartmentOption> getDepartments() {

        Set<String> departmentNames = new Set<String>();

        for (AggregateResult ar : [
            SELECT Department
            FROM User
            WHERE Department != null
            AND Department LIKE '%School%'
            GROUP BY Department
        ]) {
            departmentNames.add((String)ar.get('Department'));
        }

        List<DepartmentOption> options = new List<DepartmentOption>();

        if (!departmentNames.isEmpty()) {
            for (Account acc : [
                SELECT Id, Name
                FROM Account
                WHERE Name IN :departmentNames
                ORDER BY Name
            ]) {
                options.add(
                    new DepartmentOption(
                        acc.Name,      // label shown in combobox
                        acc.Id         // value returned on selection
                    )
                );
            }
        }

        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<ComboOption> getAcademicPrograms(String departmentId) {

        List<ComboOption> options = new List<ComboOption>();

        for (Account acc : [
            SELECT Id, Name
            FROM Account
            WHERE ParentId = :departmentId
            AND RecordType.Name = 'Academic Program'
            ORDER BY Name
        ]) {
            options.add(new ComboOption(acc.Name, acc.Id));
        }

        return options;
    }

    public class DepartmentOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public DepartmentOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

     public class ComboOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public ComboOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}