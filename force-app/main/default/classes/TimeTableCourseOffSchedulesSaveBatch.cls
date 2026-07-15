/**
* @description This batch class is responsible for processing and saving course offering schedules
* based on the provided timetable data and day-to-dates mapping.
* and maintains state across batch transactions.
*
* @author        Devender Jadala
* @team          Cloud Odyssey
* @createdDate   18/11/2025
* @lastModified
*/
public class TimeTableCourseOffSchedulesSaveBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    public String timetableDataJson;
    public Id recordId;
    public Map<String, List<Date>> dayToDatesMap;
    
    public Integer totalRecords = 0;
    public Integer parentInserted = 0;
    public Integer actuaInserted = 0;
    public Integer failedRecords = 0;
    
    /**
* @description Constructor to initialize the batch class with required parameters.
* @param recordId The Id of the term record being processed.
* @param timetableDataJson The JSON string containing timetable data.
* @param dayToDatesMap A map of weekdays to their corresponding dates.
*/
    public TimeTableCourseOffSchedulesSaveBatch(Id recordId, String timetableDataJson, Map<String, List<Date>> dayToDatesMap) {
        this.recordId = recordId;
        this.timetableDataJson = timetableDataJson;
        this.dayToDatesMap = dayToDatesMap != null ? dayToDatesMap : new Map<String, List<Date>>();
    }
    
    /**
* @description Start method for the batch process. Queries the term record for context.
* @param batchContext The batch context provided by the system.
* @return A QueryLocator for the term record.
*/
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        // Query the term so we have context
        return Database.getQueryLocator([SELECT Id, Schedule_not_Created__c, Allow_time_table_replication__c,hed__Account__r.Parent.School_Head__c FROM hed__Term__c WHERE Id = :recordId LIMIT 1]);
    }
    
    // Execute method
    /**
* @description Executes the batch process for the given list of term records.
* @param batchContext The batch context provided by the system.
* @param termList The list of term records to process.
*/
    public void execute(Database.BatchableContext batchContext, List<hed__Term__c> termList) {
        if (String.isBlank(timetableDataJson)) {
            throw new AuraHandledException('No timetable data received.');
        }
        Map<String, Object> timetableMap = (Map<String, Object>) JSON.deserializeUntyped(timetableDataJson);
        Map<String, Object> sectionWiseSchedulesRaw = (Map<String, Object>) timetableMap.get('sectionWiseSchedules');
        
        if (sectionWiseSchedulesRaw == null || sectionWiseSchedulesRaw.isEmpty()) {
            return;
        }
        
        // STEP 2: Prepare records for insertion
        Map<String, hed__Course_Offering_Schedule__c> parentOffSchMap = new Map<String, hed__Course_Offering_Schedule__c>();
        List<hed__Course_Offering_Schedule__c> dummyToInsert = new List<hed__Course_Offering_Schedule__c>();
        List<hed__Course_Offering_Schedule__c> actualToInsert = new List<hed__Course_Offering_Schedule__c>();
        
        // Build contact -> email map for professors (existing logic)
        Map<Id, String> contactIdToEmail = new Map<Id, String>();
        for (Contact c : [SELECT Id, Email FROM Contact WHERE Email != null AND recordType.Name = 'Professor']) {
            contactIdToEmail.put(c.Id, c.Email);
        }
        
        Map<String, Id> emailToUserId = new Map<String, Id>();
        if (!contactIdToEmail.isEmpty()) {
            for (User u : [SELECT Id, Email FROM User WHERE Email IN :contactIdToEmail.values()]) {
                emailToUserId.put(u.Email, u.Id);
            }
        }
        
        // Time block map
        Map<Id, hed__Time_Block__c> blockMap = new Map<Id, hed__Time_Block__c>([
            SELECT Id, Name, hed__End_Time__c, hed__Start_Time__c, Break__c, Friday__c, Monday__c, Saturday__c, Sunday__c, Thursday__c, Tuesday__c, Wednesday__c, Slot__c
            FROM hed__Time_Block__c
            WHERE Active__c = TRUE
            ORDER BY Slot__c
        ]);
        
        // Iterate sections from JSON payload
        for (String sectionKey : sectionWiseSchedulesRaw.keySet()) {
            List<Object> scheds = (List<Object>) sectionWiseSchedulesRaw.get(sectionKey);
            if (scheds == null) {
                continue;
            }
            Integer total = 0;
            
            for (Object o : scheds) {
                Map<String, Object> m = (Map<String, Object>) o;
                if (m == null) {
                    continue;
                }
                
                // Read basic values (safe casts)
                Id sectionId = (m.get('Section__c') != null) ? (Id) m.get('Section__c') : null;
                Id batchGroupId = (m.get('Batch_Group__c') != null) ? (Id) m.get('Batch_Group__c') : null;
                Id blockId = (m.get('hed__Time_Block__c') != null) ? (Id) m.get('hed__Time_Block__c') : null;
                
                if (blockId == null || !blockMap.containsKey(blockId)) {
                    continue;
                }
                
                hed__Time_Block__c block = blockMap.get(blockId);
                
                String courseOfferingVal = (m.get('hed__Course_Offering__c') != null) ? String.valueOf(m.get('hed__Course_Offering__c')) : null;
                
                String weekdayKey = '';
                for (String d : new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'}) {
                    Object val = m.get(d + '__c');
                    if (val != null && Boolean.valueOf(val) == true) {
                        weekdayKey = d;
                        break;
                    }
                }
                if (String.isBlank(weekdayKey)) {
                    continue;
                }
                
                Id profId = null;
                if(courseOfferingVal == 'Break' || courseOfferingVal == 'Free_Slot'){
                    profId = null;
                }
                else {
                    if (m.get('Professor__c') == null) {
                        continue;
                    }
                    try {
                        profId = (Id) m.get('Professor__c');
                        if (profId != null && contactIdToEmail.containsKey(profId)) {
                            String email = contactIdToEmail.get(profId);
                            if (emailToUserId.containsKey(email)) {
                                profId = emailToUserId.get(email);
                            }
                        }
                    } catch (Exception ex) {
                        continue;
                    }
                }
                
                
                
                String key = sectionId + '-' + batchGroupId + '-' + blockId + '-' + courseOfferingVal + '-' + weekdayKey + '-' + String.valueOf(block.hed__Start_Time__c) + '-' + String.valueOf(block.hed__End_Time__c )+ '-' +  profId ;
                System.debug('key0------'+key);
                // Break Records Process
                if (courseOfferingVal != null && courseOfferingVal == 'Break') {
                    total++;
                    
                    // Ensure parent dummy exists (one per key)
                    if (!parentOffSchMap.containsKey(key)) {
                        hed__Course_Offering_Schedule__c parent = new hed__Course_Offering_Schedule__c(
                            Section__c = sectionId,
                            Batch_Group__c = batchGroupId,
                            hed__Time_Block__c = blockId,
                            Status__c = 'Scheduled',
                            Break__c = true,
                            hed__Start_Time__c = block.hed__Start_Time__c,
                            hed__End_Time__c = block.hed__End_Time__c,
                            hed__Monday__c = (weekdayKey == 'Monday'),
                            hed__Tuesday__c = (weekdayKey == 'Tuesday'),
                            hed__Wednesday__c = (weekdayKey == 'Wednesday'),
                            hed__Thursday__c = (weekdayKey == 'Thursday'),
                            hed__Friday__c = (weekdayKey == 'Friday'),
                            hed__Saturday__c = (weekdayKey == 'Saturday'),
                            hed__Sunday__c = (weekdayKey == 'Sunday'),
                            Professor__c = null
                        );
                        dummyToInsert.add(parent);
                        parentOffSchMap.put(key, parent);
                    }
                    
                    // Create child break records for each date in dayToDatesMap[weekdayKey]
                    if (this.dayToDatesMap != null && this.dayToDatesMap.containsKey(weekdayKey) && termList[0].Allow_time_table_replication__c) {
                        List<Date> datesForDay = this.dayToDatesMap.get(weekdayKey);
                        for (Date dt : datesForDay) {
                            if (dt == null) {
                                continue;
                            }
                            
                            hed__Course_Offering_Schedule__c breakRec = new hed__Course_Offering_Schedule__c(
                                Section__c = sectionId,
                                Batch_Group__c = batchGroupId,
                                hed__Time_Block__c = blockId,
                                Status__c = 'Scheduled',
                                Break__c = true,
                                hed__Start_Time__c = block.hed__Start_Time__c,
                                hed__End_Time__c = block.hed__End_Time__c,
                                School_Head__c = termList[0].hed__Account__r.Parent.School_Head__c,
                                Date__c = dt,
                                hed__Monday__c = (weekdayKey == 'Monday'),
                                hed__Tuesday__c = (weekdayKey == 'Tuesday'),
                                hed__Wednesday__c = (weekdayKey == 'Wednesday'),
                                hed__Thursday__c = (weekdayKey == 'Thursday'),
                                hed__Friday__c = (weekdayKey == 'Friday'),
                                hed__Saturday__c = (weekdayKey == 'Saturday'),
                                hed__Sunday__c = (weekdayKey == 'Sunday'),
                                Professor__c = null
                            );
                            actualToInsert.add(breakRec);
                        }
                    }
                }
                
                if (courseOfferingVal != null && courseOfferingVal == 'Free_Slot') {
                    total++;
                    
                    // Ensure parent dummy exists (one per key)
                    if (!parentOffSchMap.containsKey(key)) {
                        hed__Course_Offering_Schedule__c parent = new hed__Course_Offering_Schedule__c(
                            Section__c = sectionId,
                            // Batch_Group__c = batchGroupId,
                            hed__Time_Block__c = blockId,
                            Status__c = 'Scheduled',
                            Free_Slot__c  = true,
                            hed__Start_Time__c = block.hed__Start_Time__c,
                            hed__End_Time__c = block.hed__End_Time__c,
                            hed__Monday__c = (weekdayKey == 'Monday'),
                            hed__Tuesday__c = (weekdayKey == 'Tuesday'),
                            hed__Wednesday__c = (weekdayKey == 'Wednesday'),
                            hed__Thursday__c = (weekdayKey == 'Thursday'),
                            hed__Friday__c = (weekdayKey == 'Friday'),
                            hed__Saturday__c = (weekdayKey == 'Saturday'),
                            hed__Sunday__c = (weekdayKey == 'Sunday'),
                            Professor__c = null
                        );
                        dummyToInsert.add(parent);
                        parentOffSchMap.put(key, parent);
                    }
                    
                    // Create child break records for each date in dayToDatesMap[weekdayKey]
                    if (this.dayToDatesMap != null && this.dayToDatesMap.containsKey(weekdayKey) && termList[0].Allow_time_table_replication__c) {
                        List<Date> datesForDay = this.dayToDatesMap.get(weekdayKey);
                        for (Date dt : datesForDay) {
                            if (dt == null) {
                                continue;
                            }
                            
                            hed__Course_Offering_Schedule__c breakRec = new hed__Course_Offering_Schedule__c(
                                Section__c = sectionId,
                                // Batch_Group__c = batchGroupId,
                                hed__Time_Block__c = blockId,
                                Status__c = 'Scheduled',
                                Free_Slot__c  = true,
                                hed__Start_Time__c = block.hed__Start_Time__c,
                                hed__End_Time__c = block.hed__End_Time__c,
                                School_Head__c = termList[0].hed__Account__r.Parent.School_Head__c,
                                Date__c = dt,
                                hed__Monday__c = (weekdayKey == 'Monday'),
                                hed__Tuesday__c = (weekdayKey == 'Tuesday'),
                                hed__Wednesday__c = (weekdayKey == 'Wednesday'),
                                hed__Thursday__c = (weekdayKey == 'Thursday'),
                                hed__Friday__c = (weekdayKey == 'Friday'),
                                hed__Saturday__c = (weekdayKey == 'Saturday'),
                                hed__Sunday__c = (weekdayKey == 'Sunday'),
                                Professor__c = null
                            );
                            actualToInsert.add(breakRec);
                        }
                    }
                }
                
                Id offeringId = null;
                if (m.get('hed__Course_Offering__c') != null) {
                    try {
                        offeringId = (Id) m.get('hed__Course_Offering__c');
                    } catch (Exception ex) {
                        continue;
                    }
                }
                if (offeringId == null) {
                    continue;
                }
                
                
                // Normal Records
                if (!parentOffSchMap.containsKey(key)) {
                    hed__Course_Offering_Schedule__c dummyRec = new hed__Course_Offering_Schedule__c(
                        Section__c = sectionId,
                        Batch_Group__c = batchGroupId,
                        hed__Course_Offering__c = offeringId,
                        hed__Time_Block__c = blockId,
                        Status__c = 'Scheduled',
                        hed__Start_Time__c = block.hed__Start_Time__c,
                        hed__End_Time__c = block.hed__End_Time__c,
                        hed__Facility__c = (m.get('hed__Facility__c') != null) ? (Id) m.get('hed__Facility__c') : null,
                        hed__Monday__c = (weekdayKey == 'Monday'),
                        hed__Tuesday__c = (weekdayKey == 'Tuesday'),
                        hed__Wednesday__c = (weekdayKey == 'Wednesday'),
                        hed__Thursday__c = (weekdayKey == 'Thursday'),
                        hed__Friday__c = (weekdayKey == 'Friday'),
                        hed__Saturday__c = (weekdayKey == 'Saturday'),
                        hed__Sunday__c = (weekdayKey == 'Sunday'),
                        Professor__c = profId
                    );
                    
                    dummyToInsert.add(dummyRec);
                    parentOffSchMap.put(key, dummyRec);
                }
                
                // Create actual schedule child records for each date in dayToDatesMap[weekdayKey]
                if (this.dayToDatesMap != null && this.dayToDatesMap.containsKey(weekdayKey) && termList[0].Allow_time_table_replication__c) {
                    List<Date> datesForDay = this.dayToDatesMap.get(weekdayKey);
                    for (Date dt : datesForDay) {
                        if (dt == null) {
                            continue;
                        }
                        hed__Course_Offering_Schedule__c rec = new hed__Course_Offering_Schedule__c(
                            Section__c = sectionId,
                            Batch_Group__c = batchGroupId,
                            hed__Course_Offering__c = offeringId,
                            School_Head__c = termList[0].hed__Account__r.Parent.School_Head__c,
                            hed__Time_Block__c = blockId,
                            Status__c = 'Locked',
                            Date__c = dt,
                            hed__Start_Time__c = block.hed__Start_Time__c,
                            hed__End_Time__c = block.hed__End_Time__c,
                            Faculty_Course_Connection__c = (m.get('Faculty_Course_Connection__c') != null) ? (Id) m.get('Faculty_Course_Connection__c') : null,
                            hed__Facility__c = (m.get('hed__Facility__c') != null) ? (Id) m.get('hed__Facility__c') : null,
                            hed__Monday__c = (weekdayKey == 'Monday'),
                            hed__Tuesday__c = (weekdayKey == 'Tuesday'),
                            hed__Wednesday__c = (weekdayKey == 'Wednesday'),
                            hed__Thursday__c = (weekdayKey == 'Thursday'),
                            hed__Friday__c = (weekdayKey == 'Friday'),
                            hed__Saturday__c = (weekdayKey == 'Saturday'),
                            hed__Sunday__c = (weekdayKey == 'Sunday'),
                            Professor__c = profId
                        );
                        actualToInsert.add(rec);
                        
                    }
                }
            }
            
        }
        
        if (!dummyToInsert.isEmpty()) {
            Database.SaveResult[] dummyResults = Database.insert(dummyToInsert, false);
            for (Database.SaveResult sr : dummyResults) {
                totalRecords++;
                if (sr.isSuccess()) {
                    parentInserted++;
                } else {
                    failedRecords++;
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Error inserting dummy record: ' + err.getMessage());
                    }
                }
            }
        }
        
        // STEP 4: Attach parent dummy IDs to actual schedules (if parent inserted)
        for (hed__Course_Offering_Schedule__c rec : actualToInsert) {
            String weekdayKey = '';
            Date d = rec.Date__c;
            String offeringValue = rec.Break__c == true ? 'Break' : rec.Free_Slot__c == true ? 'Free_Slot' : (rec.hed__Course_Offering__c != null ? String.valueOf(rec.hed__Course_Offering__c) : null);
                if (d != null) {
                    weekdayKey = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0)).format('EEEE');
                }
            if (String.isNotBlank(weekdayKey)) {
                
                String parentKey = rec.Section__c + '-' + rec.Batch_Group__c + '-' + rec.hed__Time_Block__c + '-' + offeringValue + '-' + weekdayKey + '-' + String.valueOf(rec.hed__Start_Time__c) + '-' + String.valueOf(rec.hed__End_Time__c) + '-'+ rec.Professor__c ;
                System.debug('parentKey----'+parentKey);
                if (parentOffSchMap.containsKey(parentKey) && parentOffSchMap.get(parentKey).Id != null) {
                    rec.CO_Schedule_Parent__c = parentOffSchMap.get(parentKey).Id;
                }
            }
        }
        
        if (!actualToInsert.isEmpty()) {
            Database.SaveResult[] actualResults = Database.insert(actualToInsert, false);
            for (Database.SaveResult res : actualResults) {
                totalRecords++;
                if (res.isSuccess()) {
                    actuaInserted++;
                } else {
                    failedRecords++;
                    for (Database.Error err : res.getErrors()) {
                        System.debug('Error inserting actual schedule record: ' + err.getMessage());
                    }
                }
            }
        }
        
        if (!termList.isEmpty()) {
            termList[0].Schedule_not_Created__c = false;
            update termList;
        }
    }
    
    /**
* @description Finish method for the batch process. Publishes a platform event with the batch summary.
* @param batchContext The batch context provided by the system.
*/
    public void finish(Database.BatchableContext batchContext) {
        String message;
        try {
            message = 'Batch Completed Successfully! Total=' + totalRecords +
                ', Total Parent Inserted=' + parentInserted +
                ', Total child Records Inserted=' + actuaInserted +
                ', Failed=' + failedRecords;
        } catch (Exception e) {
            message = 'Batch Failed: ' + e.getMessage() +
                ', Total processed=' + totalRecords +
                ', Successful=' + (parentInserted + actuaInserted) +
                ', Failed=' + failedRecords;
        }
        
        try {
            Time_table_scheduled_Creation__e event = new Time_table_scheduled_Creation__e(
                Batch_Message__c = message,
                Record_Id__c = recordId
            );
            EventBus.publish(event);
        } catch (Exception e) {
            System.debug('⚠️ Failed to publish Platform Event: ' + e.getMessage());
        }
    }
    
}