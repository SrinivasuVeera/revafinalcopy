public without sharing class PicklistValuesController {
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            picklistValues.add(f.getLabel());
        }
        return picklistValues;
    }
     @AuraEnabled
    public static void insertMenuRecords(String jsonString) {
        try{
            System.debug('Menu Records ' + jsonString);
            MenuRecord obj =  new MenuRecord();
            List<MenuRecord> menuRecords = obj.parse(jsonString);
        List<Reva_Mess_Menu__c> recordsToInsert = new List<Reva_Mess_Menu__c>();
        for (MenuRecord record : menuRecords) {
            System.debug('Each Record ' + record);
            Reva_Mess_Menu__c menuRecord = new Reva_Mess_Menu__c();
            menuRecord.Type__c = record.type;
            menuRecord.Mess_Items__c = String.join(record.menuItems, ';');
            menuRecord.Start_Time__c = convertStringToTime(record.startTime);
            menuRecord.End_Time__c = convertStringToTime(record.endTime);
            menuRecord.Date__c = record.mealDate;
            
            recordsToInsert.add(menuRecord);
            System.debug('recordsToInsert' +recordsToInsert);

        }
        System.debug('recordsToInsert' +recordsToInsert);
        insert recordsToInsert;
    }catch(Exception e){
       
        system.debug('Exception  ' + e.getMessage() + ' Line Number ' + e.getLineNumber());
         throw new AuraHandledException(e.getMessage());
    }
    }
    public static Time convertStringToTime(String timeString) {
       
        List<String> timeParts = timeString.split('[:.]');
        
        
        Integer hours = Integer.valueOf(timeParts[0]);
        Integer minutes = Integer.valueOf(timeParts[1]);
        Integer seconds = Integer.valueOf(timeParts[2]);
        Integer milliseconds = Integer.valueOf(timeParts[3]);

        return Time.newInstance(hours, minutes, seconds, milliseconds);
    }

    public class MenuRecord {
        @AuraEnabled public String type;
        @AuraEnabled public List<String> menuItems;
        @AuraEnabled public Date mealDate;
        @AuraEnabled public String startTime;
        @AuraEnabled public String endTime;


	public List<MenuRecord> parse(String json) {
		return (List<MenuRecord>) System.JSON.deserialize(json, List<MenuRecord>.class);
	}
    }
       @AuraEnabled(cacheable = true)
public static Map<String, Meal_Timings__c> getMealTimings() {
    Map<String, Meal_Timings__c> mealTimingsMap = new Map<String, Meal_Timings__c>();
    List<Meal_Timings__c> mealTimings = [SELECT Name, Start_Time__c, End_Time__c FROM Meal_Timings__c];
    for (Meal_Timings__c timing : mealTimings) {
        mealTimingsMap.put(timing.Name, timing);
    }
    return mealTimingsMap;
}
}