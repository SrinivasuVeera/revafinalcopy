public class smt_Create_Summit_Trackers {
    public static string summitTrackerName;
    public static string replacementForYYYY;
    public static date semOneTimeline;
    public static date semTwoTimeline;
    
    @InvocableMethod(Description = 'Create Summit Trackers')
    public static void setInputValues(List<List<String>> inputValues){
        List<String> input = inputValues[0];
        summitTrackerName = input[0];
        semOneTimeline = Date.valueOf(input[1]);
        semTwoTimeline = Date.valueOf(input[2]);
        replacementForYYYY = input[3];
        createSummitTrackers();
    }
    
    public static void createSummitTrackers(){
        System.debug(summitTrackerName + ' ' + replacementForYYYY + ' ' + semOneTimeline + ' ' + semTwoTimeLine);
        List<RecordType> recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'University_Department' LIMIT 1];
        if(!recordType.isEmpty()){
            List<smt_Summit_Tracker__c> summitTrackers = new List<smt_Summit_Tracker__c>();
            for(Account eachSchool: [SELECT Id,Name FROM Account WHERE RecordTypeId =: recordType[0].Id AND Name Like 'School%']){
                smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c();
                summitTracker.Name = summitTrackerName;
                summitTracker.smt_School__c = eachSchool.Id;
                summitTracker.smt_Year__c = Decimal.valueOf(replacementForYYYY);
                summitTracker.smt_Is_Active__c = TRUE;
                summitTrackers.add(summitTracker);
            }
            if(!summitTrackers.isEmpty()){
                insert summitTrackers;
                createSummitSections(summitTrackers);
            }  
        }
    }
    
    public static void createSummitSections(List<smt_Summit_Tracker__c> summitTrackers){
        List<Summit_Section_Metadata__mdt> summitSectionMetadatas = [SELECT MasterLabel , smt_Weightage__c FROM Summit_Section_Metadata__mdt];
        List<smt_Summit_Section__c> summitSections = new List<smt_Summit_Section__c>();   
        
        for(smt_Summit_Tracker__c summitTracker : summitTrackers){
            for(Summit_Section_Metadata__mdt summitSectionMetadata : summitSectionMetadatas){
                smt_Summit_Section__c summitSection = new smt_Summit_Section__c();
                summitSection.Name = summitSectionMetadata.MasterLabel;
                summitSection.smt_Weightage__c = summitSectionMetadata.smt_Weightage__c;
                summitSection.smt_Summit_Tracker__c = summitTracker.Id;
                summitSections.add(summitSection);
            }
        }
        if(!summitSections.isEmpty()){
            insert summitSections;
            createSummitParticulars(summitSections);
        }
    }
    
    public static void createSummitParticulars(List<smt_Summit_Section__c> summitSections){
        Map<String, List<Summit_Particular__mdt>> summitSectionNameMapsSummitParticular = new Map<String, List<Summit_Particular__mdt>>();
        
        for(Summit_Section_Metadata__mdt summitSectionMetadata : [SELECT MasterLabel, (SELECT MasterLabel From Summit_Particulars__r) FROM Summit_Section_Metadata__mdt]) {
            summitSectionNameMapsSummitParticular.put(summitSectionMetadata.MasterLabel, summitSectionMetadata.Summit_Particulars__r);
        }
        if(!summitSectionNameMapsSummitParticular.isEmpty()){
            List<smt_Summit_Particular__c> summitParticulars = new List<smt_Summit_Particular__c>();
            for(smt_Summit_Section__c summitSection :summitSections){
                for(Summit_Particular__mdt summitParticularMetadata : summitSectionNameMapsSummitParticular.get(summitSection.Name)){
                    String summitParticularName =  summitParticularMetadata.MasterLabel;
                    smt_Summit_Particular__c summitParticular = new smt_Summit_Particular__c();
                    summitParticular.Name = summitParticularName.replace('YYYY', replacementForYYYY);
                    summitParticular.smt_Summit_Section__c = summitSection.Id;
                    summitParticular.smt_Timeline__c =(summitParticularName.endsWith('Odd') || summitParticularName.endsWith('OS') || summitParticularName.endsWith('Odd Sem'))  ? semTwoTimeline :semOneTimeline;
                    summitParticulars.add(summitParticular);                    
                }                 
            }
            System.debug(summitParticulars);
            if(!summitParticulars.isEmpty()){
                insert summitParticulars; 
            }
        }      
        
    }
    
    
}