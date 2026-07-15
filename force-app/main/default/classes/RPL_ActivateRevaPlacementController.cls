/**
* @description       : This component is used for activating the reva placement
* @author            : Kiruba Sankar M
* @group             :
* @last modified on  : 09-13-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class RPL_ActivateRevaPlacementController implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    private String body;
    private String registrationEndDate;
    private String accademicPrograms;
    private Map<String, String> smsMap = new Map<String, String>();
    private Map<String, String> smsMapToParent = new Map<String, String>();
    
    public RPL_ActivateRevaPlacementController(
        String body,
        String accademicPrograms,
        String registrationEndDate
    ) {
        this.body = body;
        this.accademicPrograms = accademicPrograms;
        this.registrationEndDate = registrationEndDate;
    }
    
    @InvocableMethod(label='Activate Reva Placement To All Pre Or Final Year')
    public static void activateRevaPlacement(List<List<String>> input) {
        Database.executeBatch(
            new RPL_ActivateRevaPlacementController(
                input[0][0],
                input[0][1],
                input[0][2]
            ),
            30
        );
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id FROM Contact WHERE Id = NULL';
        List<RecordType> studentRecordType = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Contact' AND DeveloperName = 'Student'
            LIMIT 1
        ];
        
        if (!studentRecordType.isEmpty()) {
            String recordTypeId = studentRecordType[0].Id;
            String accademicProgramNames = accademicPrograms;
            List<String> elements = accademicProgramNames.split(',');
            
            for (Integer i = 0; i < elements.size(); i++) {
                elements[i] = '\'' + elements[i].trim() + '\'';
            }
            String resultString = '(' + String.join(elements, ',') + ')';
            
            query =
                'SELECT Id, Rpl_Is_Placement_Created__c,Personal_Email__c, Student_Full_Name__c, Year_Of_Graduation__c, MobilePhone, Mother__r.Email,  Mother__r.Name, Mother__r.MobilePhone, Father__r.Email, Father__r.Name, Father__r.MobilePhone FROM Contact WHERE RecordTypeId = :recordTypeId AND Rpl_Is_Pre_Final_Year__c = TRUE AND Student_Status__c = \'Pursuing\' AND Primary_Academic_Program__r.Program_Alias__c IN ' +
                resultString;
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Contact> scope) {
        if (scope.size() > 0) {
            List<Contact> conListToUpdate = new List<Contact>();
            Date currentDate = Date.today();
            Integer currentYear = currentDate.year();
            String currentYearString = String.valueOf(currentYear);
            
            List<String> toAddresses = new List<String>();
            
            Map<String, Map<string, string>> toAddressToValues = new Map<String, Map<string, string>>();
            
            for (Contact eachContact : scope) {
                if (eachContact.MobilePhone != null) {
                    Map<String, Map<string, string>> phoneNumberToValues = new Map<String, Map<string, string>>();
                    //Making data to send whatsapp notification
                    Map<String, String> whatsAppvalues = new Map<String, String>();
                    String studentName = eachContact.Student_Full_Name__c != null
                        ? eachContact.Student_Full_Name__c
                        : 'Student';
                    String regEndDate = registrationEndDate != null
                        ? registrationEndDate
                        : '____';
                    
                    whatsAppvalues.put('studentname', studentName);
                    whatsAppvalues.put('date', regEndDate);
                    phoneNumberToValues.put(eachContact.MobilePhone, whatsAppvalues);
                    
                    try {
                        Rpl_UtilityClass.sendWhatsAppNotification(
                            'placement_registration',
                            phoneNumberToValues
                        );
                    } catch (Exception e) {
                        ErrorLogUtility.logError(e);
                    }
                    
                    String smsMessage =
                        'Dear ' +
                        studentName +
                        ', Please register yourself for Placements@REVA in your Student Portal for getting nottified about the upcoming recruitment drives. The last date to register is ' +
                        registrationEndDate +
                        '. REVA UNIVERSITY';
                    smsMap.put(eachContact.MobilePhone, smsMessage);
                }
                if (eachContact.Mother__r.MobilePhone != null) {
                    Map<String, Map<string, string>> notificationToMother = new Map<String, Map<string, string>>();
                    Map<String, String> whatsAppvalues = new Map<String, String>();
                    String parentName = eachContact.Mother__r.Name != null
                        ? eachContact.Mother__r.Name
                        : 'Parent';
                    String regEndDate = registrationEndDate != null
                        ? registrationEndDate
                        : '____';
                    
                    whatsAppvalues.put('parentname', parentName);
                    whatsAppvalues.put('date', regEndDate);
                    notificationToMother.put(
                        eachContact.Mother__r.MobilePhone,
                        whatsAppvalues
                    );
                    try {
                        Rpl_UtilityClass.sendWhatsAppNotification(
                            'placement_registration1',
                            notificationToMother
                        );
                    } catch (Exception e) {
                        ErrorLogUtility.logError(e);
                    }
                    String smsMessage =
                        'Dear ' +
                        parentName +
                        ' Please inform your ward to register for Placements@REVA in thier Student Portal for getting notified about the upcoming recruitment drives. The last date to register is ' +
                        regEndDate +
                        '. REVA University';
                    smsMapToParent.put(eachContact.Mother__r.MobilePhone, smsMessage);
                }
                if (eachContact.Father__r.MobilePhone != null) {
                    Map<String, Map<string, string>> notificationToFather = new Map<String, Map<string, string>>();
                    Map<String, String> whatsAppvalues = new Map<String, String>();
                    String parentName = eachContact.Father__r.Name != null
                        ? eachContact.Father__r.Name
                        : 'Parent';
                    String regEndDate = registrationEndDate != null
                        ? registrationEndDate
                        : '____';
                    
                    whatsAppvalues.put('parentname', parentName);
                    whatsAppvalues.put('date', regEndDate);
                    notificationToFather.put(
                        eachContact.Father__r.MobilePhone,
                        whatsAppvalues
                    );
                    try {
                        Rpl_UtilityClass.sendWhatsAppNotification(
                            'placement_registration1',
                            notificationToFather
                        );
                    } catch (Exception e) {
                        ErrorLogUtility.logError(e);
                    }
                    String smsMessage =
                        'Dear ' +
                        parentName +
                        ' Please inform your ward to register for Placements@REVA in thier Student Portal for getting notified about the upcoming recruitment drives. The last date to register is ' +
                        regEndDate +
                        '. REVA University';
                    smsMapToParent.put(eachContact.Father__r.MobilePhone, smsMessage);
                }
                if (!String.isEmpty(eachContact.Personal_Email__c)) {
                    //Making data to send Email Notification
                    
                    String regEndDate = registrationEndDate != null
                        ? registrationEndDate
                        : '____';
                    Map<String, String> emailValues = new Map<String, String>();
                    String subject =
                        'Placement : Registration open for Academic Year ' +
                        currentYearString;
                    String body =
                        'Dear ' +
                        eachContact.Student_Full_Name__c +
                        ',\n\n' +
                        'Greetings from Team CDC!\n\n' +
                        'Pleased to inform you that the Placements registration for ' +
                        eachContact.Year_Of_Graduation__c +
                        ' graduating batch is open.\n' +
                        'Kindly register yourself with the correct information and documents from your Student Portal before the last date: ' +
                        regEndDate +
                        '.\n\n' +
                        'Student Portal Link: https://reva-university.my.site.com/StudentPortal/s/login/\n\n' +
                        'Only after the successful registration, you shall be notified about the upcoming recruitment drives at REVA University.\n\n' +
                        'Warm Regards,\nCareer Development Centre\nREVA University';
                    
                    emailValues.put('subject', subject);
                    emailValues.put('body', body);
                    toAddressToValues.put(eachContact.Personal_Email__c, emailValues);
                }
                if (!String.isEmpty(eachContact.Mother__r.Email)) {
                    String regEndDate = registrationEndDate != null
                        ? registrationEndDate
                        : '____';
                    Map<String, String> emailValues = new Map<String, String>();
                    String subject =
                        'Placement : Registration open for Academic Year ' +
                        currentYearString;
                    String body =
                        'Dear Mrs.' +
                        eachContact.Mother__r.Name +
                        ',\n\n' +
                        'Greetings from REVA University!\n\n' +
                        'Pleased to inform you that the Placements registration for ' +
                        eachContact.Year_Of_Graduation__c +
                        ' graduating batch is open.\n' +
                        'Kindly inform your ward to register himself/ herself with the correct information and documents from his/ her Student Portal before the last date: ' +
                        regEndDate +
                        '.\n\n' +
                        'Student Portal Link: https://reva-university.my.site.com/StudentPortal/s/login/\n\n' +
                        'Only after the successful registration, you shall be notified about the upcoming recruitment drives at REVA University.\n\n' +
                        'Warm Regards,\nCareer Development Centre\nREVA University';
                    
                    emailValues.put('subject', subject);
                    emailValues.put('body', body);
                    toAddressToValues.put(eachContact.Mother__r.Email, emailValues);
                }
                if (!String.isEmpty(eachContact.Father__r.Email)) {
                    String regEndDate = registrationEndDate != null
                        ? registrationEndDate
                        : '____';
                    Map<String, String> emailValues = new Map<String, String>();
                    String subject =
                        'Placement : Registration open for Academic Year ' +
                        currentYearString;
                    String body =
                        'Dear Mr.' +
                        eachContact.Father__r.Name +
                        ',\n\n' +
                        'Greetings from REVA University!\n\n' +
                        'Pleased to inform you that the Placements registration for ' +
                        eachContact.Year_Of_Graduation__c +
                        ' graduating batch is open.\n' +
                        'Kindly inform your ward to register himself/ herself with the correct information and documents from his/ her Student Portal before the last date: ' +
                        regEndDate +
                        '.\n' +
                        'Student Portal Link: https://reva-university.my.site.com/StudentPortal/s/login/\n\n' +
                        'Only after the successful registration, you shall be notified about the upcoming recruitment drives at REVA University.\n\n' +
                        'Warm Regards,\nCareer Development Centre\nREVA University';
                    
                    emailValues.put('subject', subject);
                    emailValues.put('body', body);
                    toAddressToValues.put(eachContact.Father__r.Email, emailValues);
                }
                if(!eachContact.Rpl_Is_Placement_Created__c){
                    eachContact.Rpl_Is_Placement_Created__c = true;
                    conListToUpdate.add(eachContact);
                }
            }
            
            if (!toAddressToValues.isEmpty()) {
                try {
                    Rpl_UtilityClass.sendEmailWithPlainTextBody(toAddressToValues);
                } catch (Exception e) {
                    ErrorLogUtility.logError(e);
                }
            }
            
            try {
                update conListToUpdate;
            } catch (Exception e) {
                ErrorLogUtility.logError(e);
            }
        }
    }
    
    public void finish(Database.BatchableContext context) {
        if (!smsMap.isEmpty()) {
            try {
                Rpl_UtilityClass.sendSMS('Placement registration', smsMap);
            } catch (Exception e) {
                ErrorLogUtility.logError(e);
            }
        }
        if (!smsMapToParent.isEmpty()) {
            try {
                Rpl_UtilityClass.sendSMS(
                    'Placement registration to parent',
                    smsMapToParent
                );
            } catch (Exception e) {
                ErrorLogUtility.logError(e);
            }
        }
    }
}