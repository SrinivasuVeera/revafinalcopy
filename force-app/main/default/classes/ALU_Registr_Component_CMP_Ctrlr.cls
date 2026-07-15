public without sharing class ALU_Registr_Component_CMP_Ctrlr {
    
    
    public static List<String> getPicklistValues(String objectName, String fieldName, String label) {
        List<String> options = new List<String>();
        try {
            Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
            if (fieldResult.getType() == Schema.DisplayType.PICKLIST) {
                List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
                
                for (Schema.PicklistEntry p: pList) {
                    options.add(p.getLabel());
                }
                
                
            }
        }
        catch (Exception e) {
            // Handle the exception here
        }
        return options;
    }
    
    @AuraEnabled
    public static AlumniRegistrationWrapper createAlumniRegistration(String Name, String Email, String Mobile, Date DOB, String MaritalStatus, 
                                                                     String Bg, String Gender, String YearOfGrad, String SRNno, String program,string countryCode) 
    {
        AlumniRegistrationWrapper result = new AlumniRegistrationWrapper();
         system.debug('Name '+SRNno);
        system.debug('Email '+Email);
        // Check if a record with the same email already exists
        List<Alumni_Registration__c> existingRecords = [SELECT Id,Name,Email__c FROM Alumni_Registration__c WHERE  (Name =:SRNno) OR (Email__c=:Email)];
        system.debug('existingRecords '+existingRecords.size());
        if (existingRecords.size() > 0) {
            result.message = 'Already Registered with same Email or SRN Number';
            result.isSuccess = false;
            return result;
        }
        
        
        
        
        try {
            Alumni_Registration__c objAlReg = new Alumni_Registration__c();
            objAlReg.Name__c = Name;
            objAlReg.Email__c = Email;
            objAlReg.Mobile__c = Mobile;
            objAlReg.DOB__c = DOB;
            objAlReg.Marital_Status__c = MaritalStatus;
            objAlReg.Blood_Group__c = Bg;
            objAlReg.Gender__c = Gender;
            objAlReg.Program__c = Program;
            objAlReg.Year_of_Graduation__c = YearOfGrad;
            objAlReg.Name = SRNno;
            objAlReg.Country_Code__c = countryCode;
            insert objAlReg;
            result.message = 'Thank you for Registering, the confirmation will be sent to you shortly.';
            result.isSuccess = true;
        } catch (Exception e) {
            result.message = e.getMessage();
            result.isSuccess = false;
        }
        
        return result;
    }
    
    @AuraEnabled
    public static AlumniRegistrationWrapper getPicklistOptions(){
        AlumniRegistrationWrapper wrapper = new AlumniRegistrationWrapper();
        wrapper.bloodGroupOptions = getPicklistValues('Alumni_Registration__c','Blood_Group__c', 'Blood Group');
        wrapper.genderOptions = getPicklistValues('Alumni_Registration__c','Gender__c', 'Gender');
        wrapper.maritalStatusOptions = getPicklistValues('Alumni_Registration__c','Marital_Status__c', 'Marital Status');
        wrapper.countryCodesOptions = getPicklistValues('Alumni_Registration__c','Country_Code__c', 'Country Code');
        wrapper.programOptions = getPicklistValues('Alumni_Registration__c','Program__c', 'Program');
        wrapper.yogOptions = getPicklistValues('Alumni_Registration__c','Year_of_Graduation__c', 'Year of Graduation');
        return wrapper;
    }
    
    public class AlumniRegistrationWrapper {
        @AuraEnabled
        public  List<String> bloodGroupOptions;
        @AuraEnabled
        public  List<String> genderOptions;
        @AuraEnabled
        public  List<String> maritalStatusOptions;
        @AuraEnabled
        public  List<String> countryCodesOptions;
        @AuraEnabled
        public  List<String> programOptions;
        @AuraEnabled
        public  List<String> yogOptions;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean isSuccess;
    }     
    
    
}