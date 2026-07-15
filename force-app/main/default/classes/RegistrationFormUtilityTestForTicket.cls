public with sharing class RegistrationFormUtilityTestForTicket {
    public static final String REVA_UNIVERSITY = 'REVA University';
    private static final String FEE_TYPE_APPLICATION = 'Application Fee';
    private static final String ENROLMENT_YEAR_CMDT_NAME = 'Enrolment_Year';
    private static final String APPLICATION_PORTAL_NAME = 'Application_Portal_Name';

    @AuraEnabled(cacheable=true)
    public static List<Fee_Master__c> getChangeSchoolPrograms(String programType, String currentProgramName) {
        String enrolmentYear = getCurrentEnrolmentYear();
        system.debug(enrolmentYear);
        
        return [select School_Name__c, Program_Name_Display__c, Program_Type__c, Program_Name__c 
                from Fee_Master__c
                where Fee_Type__c = :FEE_TYPE_APPLICATION
                and Enrolment_Year__c = :enrolmentYear
                and Program_Type__c = :programType
                and ((Program_Batch__r.name like '%2022%' or Application_Number_Prefix__c like '24%') or (Program_Batch__r.name like '%2023%' or Application_Number_Prefix__c like '24%') or (Program_Batch__r.name like '%2024%' or Application_Number_Prefix__c like '24%') OR Program_Batch__r.Name != null
                  OR Application_Number_Prefix__c != null)
                order by School_Name__c, Program_Name_Display__c, Application_Number_Prefix__c desc];
    }
 public static String getCurrentEnrolmentYear() {
        return [select Text_Value__c from General_Setting__mdt where DeveloperName = :ENROLMENT_YEAR_CMDT_NAME limit 1].Text_Value__c;
    }
  
    }