public class RPL_EligibilityHandlerClass {
    public static String getPlacementDriveId(
        List<Rpl_Eligibility__c> eligibilityList,
        Boolean isUpdate
    ) {
        string dynamicQuery = '';
        try {
 
            System.debug('Rpl_Recursive_Controller.isAlreadyExecuted ' +Rpl_Recursive_Controller.isAlreadyExecuted);
            
            System.debug('Inside Method');
            Map<Id, Rpl_Eligibility__c> placeDriveIdMap = new Map<Id, Rpl_Eligibility__c>();
            CriteriaWrapperClass crtWrap = new CriteriaWrapperClass();
            //Rpl_Eligibility__c eligibility = eligibilityList[0];
            
            
            for (Rpl_Eligibility__c eElg : eligibilityList) {
                if (!String.isEmpty(eElg.Rpl_Placement_Drive__c)) {
                    System.debug(eElg);
                    placeDriveIdMap.put(eElg.Rpl_Placement_Drive__c, eElg);
                    // Populate criteria wrapper class
                    crtWrap.tenthPercentage = eElg.Rpl_Tenth_Percentage__c;
                    crtWrap.studentVerificationStatus = eElg.Rpl_Verification_Status_Of_Student__c;
                    crtWrap.paymentStatus = eElg.Rpl_Fee_Payment_Status__c;
                    crtWrap.twelvePercentage = eElg.Rpl_Twelveth_Percentage__c;
                    crtWrap.UGPercentage = eElg.Rpl_UG_Percentage1__c;
                    crtWrap.PGPercentage = eElg.Rpl_PG_Percentage1__c;
                    crtWrap.currentBackLog = eElg.Rpl_Current_Backlogs__c;
                    crtWrap.specializationType = eElg.Rpl_Specialization__c;
                    crtWrap.rbsSpecializationType = eElg.RBS_Specialization_Picklist__c; //Added by  srija
                    crtWrap.totalBacklogs = eElg.Rpl_Total_Backlogs__c;
                    crtWrap.gender = eElg.Gender__c;
                    crtWrap.OfferCount = eElg.Offer_Count__c;
                    crtWrap.placementDriveId = eElg.Rpl_Placement_Drive__c;
                    crtWrap.gapYear = eElg.Rpl_Gap_Years__c;
                    crtWrap.placementInterest = eElg.Rpl_Placement_Interest__c;
                    crtWrap.attendance = eElg.Rpl_Attendance_Percentage__c;
                    crtWrap.includeCompanies = !String.isEmpty(eElg.Rpl_Include_Students_With_Offer_In__c)
                        ? String.escapeSingleQuotes(eElg.Rpl_Include_Students_With_Offer_In__c)
                        : '';
                    crtWrap.excludeCompanies = !String.isEmpty(eElg.Rpl_Exclude_Students_With_Offer_In__c)
                        ? String.escapeSingleQuotes(eElg.Rpl_Exclude_Students_With_Offer_In__c)
                        : ''; 
                    crtWrap.tenthCgpaOperator = eElg.Rpl_Tenth_CGPA_Operator__c;
                    crtWrap.twelfthCgpaOperator = eElg.Rpl_12th_CGPA_Operator__c;
                    crtWrap.tenthPercentageOperator = eElg.Rpl_Tenth_Percentage_Operator__c;
                    crtWrap.twelfthPercentageOperator = eElg.Rpl_12th_Percentage_Operator__c;
                    crtWrap.diplomaAggregateOperator = eElg.Rpl_Diploma_Aggregate_Operator__c;
                    crtWrap.attendanceOperator = eElg.Rpl_Attendance_Operator__c;
                    crtWrap.currentBacklogOperator = eElg.Rpl_Current_Backlogs_Operator__c;
                    crtWrap.totalBacklogOperator = eElg.Rpl_Total_Backlogs_Operator__c;
                    crtWrap.gapYearsOperator = eElg.Rpl_Gap_Years_Operator__c;
                    crtWrap.UGCgpaOperator = eElg.Rpl_UG_CGPA_Operator__c;
                    crtWrap.PGCgpaOperator = eElg.Rpl_PG_CGPA_Operator__c;
                    crtWrap.UgPercentageOperator = eElg.Rpl_UG_Percentage_Operator__c;
                    crtWrap.PgPercentageOperator = eElg.Rpl_PG_Percentage_Operator__c;
                    crtWrap.offerCountOperator = eElg.Rpl_Offer_Count_Operator__c;
                    crtWrap.tenthCGPA = eElg.Rpl_Tenth_CGPA__c;
                    crtWrap.twelveCGPA = eElg.Rpl_Twelveth_CGPA__c;
                    crtWrap.UgCGPA = eElg.Rpl_UG_CGPA__c;
                    crtWrap.PgCGPA = eElg.Rpl_PG_CGPA__c;
                    crtWrap.diplomaAggregate = eElg.Rpl_Diploma_Aggregate__c;
                    crtWrap.isPlacementInterest = eElg.Rpl_Placement_Interest__c;
                }
            }
            if (!string.isEmpty(crtWrap.specializationType)) {
                crtWrap.specialization = crtWrap.specializationType.split(',');
            } else {
                crtWrap.specialization = new List<String>();
            }
            
            if (!String.isEmpty(crtWrap.rbsSpecializationType)) {
                crtWrap.rbsSpecializationList = crtWrap.rbsSpecializationType.split(';');
            } else {
                crtWrap.rbsSpecializationList = new List<String>();
               }
            
            if (!placeDriveIdMap.isEmpty()) {
                // Checking if the event is an update
                if (isUpdate == true) {
                    List<Rpl_Student_Registration_Drive__c> stdRegDrve = [
                        SELECT Rpl_Student_Registration__c, Rpl_Placement_Drive__c
                        FROM Rpl_Student_Registration_Drive__c
                        WHERE Rpl_Placement_Drive__c IN :placeDriveIdMap.keySet()
                    ];
                    if (stdRegDrve.size() > 0) {
                        delete stdRegDrve;
                    }
                }
                system.debug('In line 79');
                Set<Id> revaPlacementDriveIdSet = new Set<Id>();
                for (Rpl_Placement_Drive__c ePlceDrve : [
                    SELECT
                    ID,
                    Reva_Placement__r.Id
					
                    FROM Rpl_Placement_Drive__c
                    WHERE ID IN :placeDriveIdMap.keySet()
                ]) {
                    if (!String.isEmpty(ePlceDrve.Reva_Placement__r.Id)) {
                        revaPlacementDriveIdSet.add(ePlceDrve.Reva_Placement__r.Id);
                    }
                }
                
                if (!revaPlacementDriveIdSet.isEmpty()) {
                    String userOrGroupsIdString = String.join(revaPlacementDriveIdSet, '\',\'');
                    String query = 'SELECT ID, Contact__c FROM Rpl_Student_Registration__c';
                    
                    query += ' WHERE (( Reva_Placement__c IN (\'' + userOrGroupsIdString + '\') ';
                    if (crtWrap.studentVerificationStatus == 'Include Verified Students Only') {
                        query += ' AND Rpl_Status__c = \'Registration Successfully\' ';
                    }
                    if (!String.isEmpty(crtWrap.gender)) {
                        if (crtWrap.gender == 'Male') {
                            query += ' AND Rpl_Gender__c = \'Male\' ';
                        } else if (crtWrap.gender == 'Female') {
                            query += ' AND Rpl_Gender__c = \'Female\' ';
                        }
                    }
                    if (!crtWrap.specialization.isEmpty()) {
                        String specialization = String.join(crtWrap.specialization, '\',\'');
                        query += ' AND Rpl_Branch_Name__c IN (\'' + specialization + '\') ';
                    }
                    
                    if (!crtWrap.rbsSpecializationList.isEmpty()) {
                        String rbsSpecStr = String.join(crtWrap.rbsSpecializationList, '\',\'');
                        query += ' AND (RBS_Specialization_1__r.Display_Name_Program__c IN (\'' + rbsSpecStr + '\')' +
                            ' OR RBS_Specialization_2__r.Display_Name_Program__c IN (\'' + rbsSpecStr + '\')'+
                            ' OR RBS_Specialization_1__r.Name IN (\'' + rbsSpecStr + '\')'+
                            ' OR RBS_Specialization_2__r.Name IN (\'' + rbsSpecStr + '\'))';
                    }

                    if (crtWrap.isPlacementInterest) {
                        query += ' AND Rpl_Interested_in_placement__c = \'Yes\' ';
                    }
                    System.debug('Query ' + query);
                    List<String> conditions = new List<String>();
                    conditions.add(
                        '( Rpl_10th_Percentage__c' +
                        getGreaterThanQueryString(crtWrap.tenthPercentageOperator, crtWrap.tenthPercentage) +
                        ' OR Rpl_Tenth_CGPA__c' +
                        getGreaterThanQueryString(crtWrap.tenthCgpaOperator, crtWrap.tenthCGPA) +
                        ' )'
                    );
                    conditions.add(
                        '( Rpl_12th_Percentage__c' +
                        getGreaterThanQueryString(
                            crtWrap.twelfthPercentageOperator,
                            crtWrap.twelvePercentage
                        ) +
                        ' OR Rpl_Twelfth_CGPA__c' +
                        getGreaterThanQueryString(crtWrap.twelfthCgpaOperator, crtWrap.twelveCGPA) +
                        ' OR Rpl_Diploma_Percentage__c' +
                        getGreaterThanQueryString(
                            crtWrap.diplomaAggregateOperator,
                            crtWrap.diplomaAggregate
                        ) +
                        ' )'
                    );
                    conditions.add(
                        '( Rpl_UG_Overall_Percentage__c' +
                        getGreaterThanQueryString(crtWrap.UgPercentageOperator, crtWrap.UGPercentage) +
                        ' OR Rpl_UG_Overall_CGPA__c' +
                        getGreaterThanQueryString(crtWrap.UGCgpaOperator, crtWrap.UgCGPA) +
                        ' )'
                    );
                    conditions.add(
                        '( Rpl_PG_Overall_Percentage__c' +
                        getGreaterThanQueryString(crtWrap.PgPercentageOperator, crtWrap.PGPercentage) +
                        ' OR Rpl_PG_OVerall_CGPA__c' +
                        getGreaterThanQueryString(crtWrap.PGCgpaOperator, crtWrap.PgCGPA) +
                        ' )'
                    );
                    //conditions.add(' Rpl_Diploma_Percentage__c' + getGreaterThanQueryString(crtWrap.diplomaAggregateOperator, crtWrap.diplomaAggregate));
                    conditions.add(
                        ' Rpl_Current_Backlogs__c' +
                        getLesserThanQueryString(crtWrap.currentBacklogOperator, crtWrap.currentBackLog)
                    );
                    conditions.add(
                        ' Rpl_Total_Backlogs__c' +
                        getLesserThanQueryString(crtWrap.totalBacklogOperator, crtWrap.totalBacklogs)
                    );
                    conditions.add(
                        ' Rpl_Education_Gap__c' +
                        getLesserThanQueryString(crtWrap.gapYearsOperator, crtWrap.gapYear)
                    );
                    /*conditions.add(
' Contact__r.Rpl_Overall_Attendance_Percentage__c' +
getGreaterThanQueryString(crtWrap.attendanceOperator, crtWrap.attendance)
);*/
                    
                    //conditions.add((!String.isEmpty(crtWrap.tenthPercentage) && crtWrap.tenthPercentage != 'No Criteria') ? 'Rpl_10th_Percentage__c ' + crtWrap.tenthPercentage : null);
                    
                    for (String eStr : conditions) {
                        if (!String.isEmpty(eStr)) {
                            System.debug('Query ' + query);
                            
                            query += ' AND ' + eStr;
                        }
                    }
                    
                    if (
                        !String.isEmpty(crtWrap.excludeCompanies) && !String.isEmpty(crtWrap.includeCompanies)
                    ) {
                        query += ') OR (';
                        query +=
                            ' Rpl_Companies_Got_Placed_In__c INCLUDES (\' ' +
                            crtWrap.includeCompanies +
                            '\'))) AND (NOT Rpl_Companies_Got_Placed_In__c INCLUDES (\'' +
                            crtWrap.excludeCompanies +
                            '\')) ';
                    } else if (
                        String.isEmpty(crtWrap.excludeCompanies) && !String.isEmpty(crtWrap.includeCompanies)
                    ) {
                        query += ') OR (';
                        query +=
                            ' Rpl_Companies_Got_Placed_In__c INCLUDES (\' ' +
                            crtWrap.includeCompanies +
                            '\') ))';
                    } else if (
                        !String.isEmpty(crtWrap.excludeCompanies) && String.isEmpty(crtWrap.includeCompanies)
                    ) {
                        query += ') AND (';
                        query +=
                            ' NOT Rpl_Companies_Got_Placed_In__c INCLUDES (\'' +
                            crtWrap.excludeCompanies +
                            '\')))';
                    } else {
                        query += '))';
                    }
                    dynamicQuery = query;
                    
                    
                    
                    System.debug('Query '     + query) ;
                    if (Database.query(query).isEmpty()) {
                        Rpl_Eligibility__c eligibility = new Rpl_Eligibility__c(Id = eligibilityList[0].ID);
                        eligibility.Rpl_Dynamic_Query__c = dynamicQuery;
                        update eligibility;
                        return null;
                    }
                    System.debug('Query '     + query) ;
                    Set<Id> studentRegIds = new Set<Id>();
                    Set<Id> contactIds = new Set<Id>();
                    
                    
                    for (Rpl_Student_Registration__c eStd : Database.query(query)) {
                        studentRegIds.add(eStd.Id);
                        contactIds.add(eStd.Contact__c);
                    }
                    Set<Id> studentWithNoFeePending = new Set<Id>();
                    if (crtWrap.paymentStatus == 'Exclude Students With Payment Pending') {
                        studentRegIds.clear();
                        List<Contact> contactList = [
                            SELECT
                            Id,
                            (SELECT Id FROM Student_Registrations__r),
                            (SELECT Id FROM Student_Fees__r WHERE Amount_Pending__c > 0)
                            FROM Contact
                            WHERE Id IN :contactIds
                        ];
                        if (!contactList.isEmpty()) {
                            for (Contact eachContact : contactList) {
                                if (eachContact.Student_Fees__r.size() == 0) {
                                    studentRegIds.add(eachContact.Student_Registrations__r[0].Id);
                                }
                            }
                        }
                    }
                    if (studentRegIds.isEmpty()) {
                        return null;
                    }
                    List<Rpl_Student_Registration_Drive__c> stdRegDriveList = new List<Rpl_Student_Registration_Drive__c>();
                    for (Id eStdId : studentRegIds) {
                        Rpl_Student_Registration_Drive__c stdReg = new Rpl_Student_Registration_Drive__c();
                        stdReg.Rpl_Student_Registration__c = eStdId;
                        stdReg.Rpl_Placement_Drive__c = crtWrap.placementDriveId;
                        stdRegDriveList.add(stdReg);
                    }
                    if (!stdRegDriveList.isEmpty()) {
                        insert stdRegDriveList;
                    }
                    
                    
                }
                
            }
            Rpl_Eligibility__c eligibility = new Rpl_Eligibility__c(Id = eligibilityList[0].ID);
            eligibility.Rpl_Dynamic_Query__c = dynamicQuery;
            update eligibility;
           
            
            
        } catch (Exception e) {
            System.debug('Exception ' +e.getMessage() + ' Line ' + e.getLineNumber());
            ErrorLogUtility.logError(e);
        }
        return null;
    }
    
    public static string getGreaterThanQueryString(String operator, decimal value) {
        string query = '';
        query += String.isEmpty(operator) ? '>= ' : operator;
        query += value == null ? '0 ' : String.valueOf(value);
        return query;
    }
    public static string getLesserThanQueryString(String operator, decimal value) {
        string query = '';
        query += String.isEmpty(operator) ? '<= ' : operator;
        query += value == null ? '0 ' : String.valueOf(value);
        return query;
    }
    
    /**
* Wrapper class to hold criteria values.
*/
    public class CriteriaWrapperClass {
        public boolean isPlacementInterest;
        public string specializationType; 
        public string rbsSpecializationType;
        public string studentVerificationStatus;
        public string paymentStatus;
        public List<string> specialization;
        public List<string> rbsSpecializationList;
        public Decimal tenthPercentage;
        public Decimal twelvePercentage;
        public decimal tenthCGPA;
        public decimal twelveCGPA;
        public decimal UGPercentage;
        public decimal PGPercentage;
        public decimal UgCGPA;
        public decimal PgCGPA;
        public Decimal currentBackLog;
        public Decimal yearback;
        public Decimal totalBacklogs;
        public String gender;
        public Decimal OfferCount;
        public Id placementDriveId;
        public String includeCompanies;
        public String excludeCompanies;
        public Decimal gapYear;
        public Boolean placementInterest;
        public Decimal attendance;
        public string tenthCgpaOperator;
        public string twelfthCgpaOperator;
        public string tenthPercentageOperator;
        public string twelfthPercentageOperator;
        public string diplomaAggregateOperator;
        public string attendanceOperator;
        public string currentBacklogOperator;
        public string totalBacklogOperator;
        public string gapYearsOperator;
        public string UGCgpaOperator;
        public string PGCgpaOperator;
        public string UgPercentageOperator;
        public string PgPercentageOperator;
        public string offerCountOperator;
        public decimal diplomaAggregate;
    }
}