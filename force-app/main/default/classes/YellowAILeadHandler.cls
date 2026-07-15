public class YellowAILeadHandler {

 /*   public static void processLeadConversion(List<Id> leadIds){

        List<Lead> leads = [
            SELECT Id, School__c, Program_Name_Display__c, Category__c
            FROM Lead
            WHERE Id IN :leadIds
        ];

        // Collect values for bulk queries
        Set<String> programNames = new Set<String>();
        Set<String> schoolNames = new Set<String>();
        Set<String> categories = new Set<String>();

        for(Lead ld : leads){
            if(ld.Program_Name_Display__c != null)
                programNames.add(ld.Program_Name_Display__c);

            if(ld.School__c != null)
                schoolNames.add(ld.School__c);

            if(ld.Category__c == 'Karnataka' || ld.Category__c == 'Non-Karnataka')
                categories.add('Indian (SAARC)');
            else
                categories.add(ld.Category__c);
        }

        // Query Fee Masters once
        List<Fee_Master__c> feeMasters = [
            SELECT Id, Program_Name_Display__c, School_Name__c, Applicant_Category__c
            FROM Fee_Master__c
            WHERE Program_Name_Display__c IN :programNames
            AND School_Name__c IN :schoolNames
            AND Applicant_Category__c IN :categories
            AND IsActive__c = true
            AND Fee_Type__c = 'Application Fee'
        ];

        // Create map for quick lookup
        Map<String, Fee_Master__c> feeMasterMap = new Map<String, Fee_Master__c>();

        for(Fee_Master__c fm : feeMasters){
            String key = fm.Program_Name_Display__c + '-' + fm.School_Name__c + '-' + fm.Applicant_Category__c;
            feeMasterMap.put(key, fm);
        }

        // Query Custom Metadata once
        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        // Store contact ids returned from conversion
        Set<Id> contactIds = new Set<Id>();

        for(Lead leadToUpdate : leads){

            RegistrationFormUtility.updateLeadPriorConversion(leadToUpdate.Id);

            String feeMasterCategory;

            if (leadToUpdate.Category__c == 'Karnataka' || leadToUpdate.Category__c == 'Non-Karnataka')
                feeMasterCategory = 'Indian (SAARC)';
            else
                feeMasterCategory = leadToUpdate.Category__c;

            String key = leadToUpdate.Program_Name_Display__c + '-' +
                         leadToUpdate.School__c + '-' +
                         feeMasterCategory;

            if(!feeMasterMap.containsKey(key)){
                continue;
            }

            String fmID = feeMasterMap.get(key).Id;

            List<RegistrationFormUtility.UtilityResponse> resp =
                RegistrationFormUtility.convertLead(leadToUpdate.Id, fmID);

            if (resp != null && resp.size() > 0 && resp[0].applicantContactId != null) {

                contactIds.add(resp[0].applicantContactId);
            }
        }

        if(contactIds.isEmpty() || pucSetting.Boolean_Value__c == false){
            return;
        }

        // Query Contacts once
        Map<Id, Contact> contactMap = new Map<Id, Contact>([  SELECT Id, MobilePhone  FROM Contact  WHERE Id IN :contactIds ]);

        Set<String> mobiles = new Set<String>();

        for(Contact c : contactMap.values()){
            if(c.MobilePhone != null)
                mobiles.add(c.MobilePhone);
        }

        // Query PUC data once
        List<PUC_Drive_Data__c> pucDataList = [ SELECT Id, Mobile_Number__c  FROM PUC_Drive_Data__c WHERE Mobile_Number__c IN :mobiles];

        Set<String> pucMobiles = new Set<String>();

        for(PUC_Drive_Data__c p : pucDataList){
            pucMobiles.add(p.Mobile_Number__c);
        }

        // Final processing
        for(Contact con : contactMap.values()){

            if(pucMobiles.contains(con.MobilePhone)){

                RegistrationFormUtility.PUCUpdateRecord(con.Id);

            }
        }
    }*/
     public static void processLeadConversion(List<Id> leadIds){

        List<Lead> leads = [
            SELECT Id, School__c, Program_Name_Display__c, Category__c
            FROM Lead
            WHERE Id IN :leadIds
        ];

        // Collect values for bulk queries
        Set<String> programNames = new Set<String>();
        Set<String> schoolNames = new Set<String>();
        Set<String> categories = new Set<String>();

        for(Lead ld : leads){
            if(ld.Program_Name_Display__c != null)
                programNames.add(ld.Program_Name_Display__c);

            if(ld.School__c != null)
                schoolNames.add(ld.School__c);

            if(ld.Category__c == 'Karnataka' || ld.Category__c == 'Non-Karnataka')
                categories.add('Indian (SAARC)');
            else if(ld.Category__c != null)
                categories.add(ld.Category__c);
        }

        // ✅ Query Fee Masters WITHOUT school filter
        List<Fee_Master__c> feeMasters = [
            SELECT Id, Program_Name_Display__c, School_Name__c, Applicant_Category__c
            FROM Fee_Master__c
            WHERE Program_Name_Display__c IN :programNames
            AND Applicant_Category__c IN :categories
            AND IsActive__c = true
            AND Fee_Type__c = 'Application Fee'
        ];

        // ✅ Map using CONTAINS logic
        Map<String, Fee_Master__c> feeMasterMap = new Map<String, Fee_Master__c>();

        for(Fee_Master__c fm : feeMasters){

            for(String school : schoolNames){

                if(fm.School_Name__c != null && school != null &&
                   fm.School_Name__c.toLowerCase().contains(school.toLowerCase())){

                    String key = fm.Program_Name_Display__c + '-' + school + '-' + fm.Applicant_Category__c;

                    // Avoid overwrite if already exists
                    if(!feeMasterMap.containsKey(key)){
                        feeMasterMap.put(key, fm);
                    }
                }
            }
        }

        // Query Custom Metadata once
        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        // Store contact ids returned from conversion
        Set<Id> contactIds = new Set<Id>();

        for(Lead leadToUpdate : leads){

            RegistrationFormUtility.updateLeadPriorConversion(leadToUpdate.Id);

            String feeMasterCategory;

            if (leadToUpdate.Category__c == 'Karnataka' || leadToUpdate.Category__c == 'Non-Karnataka')
                feeMasterCategory = 'Indian (SAARC)';
            else
                feeMasterCategory = leadToUpdate.Category__c;

            String key = leadToUpdate.Program_Name_Display__c + '-' +
                         leadToUpdate.School__c + '-' +
                         feeMasterCategory;

            if(!feeMasterMap.containsKey(key)){
                continue;
            }

            String fmID = feeMasterMap.get(key).Id;

            List<RegistrationFormUtility.UtilityResponse> resp =
                RegistrationFormUtility.convertLead(leadToUpdate.Id, fmID);

            if (resp != null && resp.size() > 0 && resp[0].applicantContactId != null) {
                contactIds.add(resp[0].applicantContactId);
            }
        }

        if(contactIds.isEmpty() || pucSetting.Boolean_Value__c == false){
            return;
        }

        // Query Contacts once
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, MobilePhone
            FROM Contact
            WHERE Id IN :contactIds
        ]);

        Set<String> mobiles = new Set<String>();

        for(Contact c : contactMap.values()){
            if(c.MobilePhone != null)
                mobiles.add(c.MobilePhone);
        }

        // Query PUC data once
        List<PUC_Drive_Data__c> pucDataList = [
            SELECT Id, Mobile_Number__c
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c IN :mobiles
        ];

        Set<String> pucMobiles = new Set<String>();

        for(PUC_Drive_Data__c p : pucDataList){
            pucMobiles.add(p.Mobile_Number__c);
        }

        // Final processing
        for(Contact con : contactMap.values()){
            if(pucMobiles.contains(con.MobilePhone)){
                RegistrationFormUtility.PUCUpdateRecord(con.Id);
            }
        }
    }

 
    public static Boolean isPUCStudenttest(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }


    public static Boolean isPUCStudenttesting(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }


    public static Boolean isPUCStudentte(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }


    public static Boolean testisPUCStudenttesting(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }

    public static Boolean testingisPUCStudent(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }
    
       public static Boolean isPUCtestStudent(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }
       public static Boolean isPUCtestingStudent(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }
       public static Boolean isPUCtestingdStudent(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }
    
        public static Boolean isPUCteesingdStudent(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }
        public static Boolean isPUCtestigdStudent(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }
        public static Boolean isPUCtestidStudent(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }
}