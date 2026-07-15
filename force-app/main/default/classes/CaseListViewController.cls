public class CaseListViewController {
    
    @AuraEnabled(cacheable = true)
    public static List<Case> getCases(String contactId, String recordTypeName, String userId){
        if(recordTypeName == 'Infra Support Request'){
            return [Select Id, CaseNumber, INFRA_Category__c, Status, Priority, Owner.Name, Facility__c,
                    Facility__r.Name, Description, INFRA_Sub_Category__c, CreatedDate,
                    CreatedBy.Name, Facility_Name__c
                    From Case
                    Where (CreatedById =:userId OR OwnerId =: userId)
                    AND RecordType.Name = :recordTypeName
                    Order By CreatedDate DESC];
        } else {
            return new List<Case>();
        }
    }
    @AuraEnabled(cacheable = true)
    public static List<Case> getFacultySupportCases(String contactId, String recordTypeName, String userId){        
        if(recordTypeName == 'Faculty Support Ticket'){
            return [Select Id, CaseNumber, Faculty_Category__c, Status, Priority, Owner.Name,
                    Description, Faculty_Case_Sub_Category__c, CreatedDate,
                    CreatedBy.Name,Faculty_Case_Attachment__c,Case_Status__c,Agent_Remarks__c,Case_Comments__c,Old_Case_Number__c
                    From Case
                    Where (CreatedById =:userId OR OwnerId =: userId)
                    AND RecordType.Name = :recordTypeName
                    Order By CreatedDate DESC];
        } else {
            return new List<Case>();
        }
    }
    @AuraEnabled(cacheable = true)
    public static String getFacultyRecordTypeId(){
        return [SELECT Id,Name from RecordType WHERE SObjectType = 'Case' AND Name = 'Faculty Support Ticket' LIMIT 1]?.Id;
    }
    // for Hostel Support request
    @AuraEnabled(cacheable = true)
    public static List<Case> getHostelCases(String contactId, String recordTypeName, String userId){
        System.debug('record type: '+ recordTypeName);    
        if(recordTypeName == 'REVA Hostel Support Request'){
            return [Select Id, CaseNumber, Hostel_Category__c,Hostel_Sub_Category__c,Hostel_Block__c, Status, Priority, Description                  
                    From Case 
                    Where Record_Type_Name__c =:recordTypeName
                    Order By CreatedDate DESC];
        }else{
            return new List<Case>();
        }
    }
    @AuraEnabled(cacheable = true)
    public static List<Case> getCasesForNonTeaching(String contactId, String recordTypeName, String userId, String createdbyid){
        if(recordTypeName == 'REVA Hostel Support Request'){
            System.debug('createdbyid: '+ createdbyid); 
            List<case> caseList = [Select Id, CaseNumber, Record_Type_Name__c, Hostel_Category__c,Hostel_Sub_Category__c,
                                   Hostel_Block__c, Status, Priority, Owner.Name, CreatedBy.Name, createdDate,
                                   Description
                                   From Case
                                   Where Record_Type_Name__c =:recordTypeName
                                   And (CreatedById =:createdbyid OR OwnerId =: userId)
                                   Order By CreatedDate DESC];
            
            System.debug('list size: '+ caseList.size());
            
            
            return caseList;
            
        }else{
            return new List<Case>();
        }
    }
    @AuraEnabled
    public static String createCase(String caseDescription, String hostelCategory, String hostelSubCategory, String casePriority) {
        // Query for the Record Type Id
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'REVA_Hostel_Support_Request' AND SObjectType = 'Case' LIMIT 1];
        Case newCase = new Case(
            recordTypeId = rt.Id,
            Description = caseDescription,
            Hostel_Category__c = hostelCategory,
            Hostel_Sub_Category__c = hostelSubCategory,
            Priority = casePriority
        );
        
        try {
            insert newCase;
            return 'Case created successfully. Id: ' + newCase.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating case: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getPicklistValues() {
        Map<String, List<String>> picklistValues = new Map<String, List<String>>();
        
        picklistValues.put('Hostel_Category__c', getPicklistValuesForField(Case.Hostel_Category__c));
        picklistValues.put('Hostel_Sub_Category__c', getPicklistValuesForField(Case.Hostel_Sub_Category__c));
        picklistValues.put('Priority', getPicklistValuesForField(Case.Priority));
        
        return picklistValues;
    }
    
    private static List<String> getPicklistValuesForField(Schema.SObjectField field) {
        List<String> values = new List<String>();
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            values.add(entry.getLabel());
        }
        return values;
    }
}