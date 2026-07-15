public class ChangeQuotaSchoolsList { 
    private static final String FEE_TYPE_APPLICATION = 'Program Fee';
    private static final String ENROLMENT_YEAR_CMDT_NAME = 'Enrolment_Year';
   /* Public Static String AdmissionMode;
    public class inputParameters{
        @InvocableVariable(required=true)
        public String AdmissionMode;
    }
     
    @InvocableMethod(label='Admission Mode')
    public static void AdmissionMode(List<inputParameters> input){
     
        if(input != null){
            AdmissionMode = input[0].AdmissionMode;
        }
        system.debug('AdmissionMode'+input[0].AdmissionMode);
         system.debug('AdmissionMode2'+AdmissionMode);
    }*/
    
    @AuraEnabled(cacheable=true)
    public static List<Fee_Master__c> getChangeSchoolPrograms(String programType, String currentProgramName, string selectedMode) {
        String enrolmentYear = getCurrentEnrolmentYear();
        system.debug(enrolmentYear);
          system.debug(programType);
          system.debug(currentProgramName);
        system.debug('AdmissionMode'+selectedMode);
        return [select School_Name__c, Program_Name_Display__c, Program_Type__c, Program_Name__c,Quota__c
                from Fee_Master__c
                where Fee_Type__c = :FEE_TYPE_APPLICATION
                and Enrolment_Year__c = :enrolmentYear
                and Program_Type__c = :programType
                and Quota__c =:selectedMode
                and Program_Name__c != :currentProgramName and IsActive__c = true 
                and ((Program_Batch__r.name like '%2022%' or Application_Number_Prefix__c like '24%') or (Program_Batch__r.name like '%2023%' or Application_Number_Prefix__c like '24%')
                     OR Program_Batch__r.Name != null OR Application_Number_Prefix__c != null)
                order by School_Name__c, Program_Name_Display__c, Application_Number_Prefix__c desc];
    }
    
    public static String getCurrentEnrolmentYear() {
        return [select Text_Value__c from General_Setting__mdt where DeveloperName = :ENROLMENT_YEAR_CMDT_NAME limit 1].Text_Value__c;
    }
    
}