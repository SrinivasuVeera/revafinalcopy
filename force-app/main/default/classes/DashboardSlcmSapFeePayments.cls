public with sharing class DashboardSlcmSapFeePayments{   
    
        // Get ONLINE Amount Collections    
        @AuraEnabled(cacheable=true)
        public static String getOnlineFeePaymentStats() {
            // Initialize variables to hold the results
            Decimal todayAmount = 0.0; 
            Decimal yesterdayAmount = 0.0;
            Decimal lastWeekAmount = 0.0;
            Decimal currentWeekAmount = 0.0;   
            Decimal lastSevenDaysAmount = 0.0;
            Decimal lastMonthAmount = 0.0;
            Decimal currentMonthAmount = 0.0;
            
            
            // Query to get today's field value
            AggregateResult todayResult = [
                SELECT SUM(Amount__c) totalAmount
                FROM Student_Fee_Payment__c
                WHERE Line_Item_Payment_Status__c = 'Success'
                  AND Student_Payment__r.Mode_of_Payment__c = 'Online'
                  AND Transaction_Date_Time__c = TODAY
                  AND Integrated_with_SAP__c = TRUE
            ];
    
            if (todayResult != null && todayResult.get('totalAmount') != null) {
                todayAmount =  (Decimal)todayResult.get('totalAmount');
            }      
            
             // Query to get yesterday's field value
            AggregateResult yesterdayResult = [
                SELECT SUM(Amount__c) totalAmount
                FROM Student_Fee_Payment__c 
                where Line_Item_Payment_Status__c = 'Success' 
                and Student_Payment__r.Mode_of_Payment__c ='Online' 
                AND Transaction_Date_Time__c = YESTERDAY 
                AND Integrated_with_SAP__c = TRUE
            ];
    
            if (yesterdayResult != null && yesterdayResult.get('totalAmount') != null) {
                yesterdayAmount =  (Decimal)yesterdayResult.get('totalAmount');
            }
            
             // Query to get lastWeek's field value
            AggregateResult lastWeekResult = [
                SELECT SUM(Amount__c) totalAmount
                FROM Student_Fee_Payment__c 
                where Line_Item_Payment_Status__c = 'Success' 
                and Student_Payment__r.Mode_of_Payment__c ='Online' 
                AND Transaction_Date_Time__c = LAST_WEEK  
                AND Integrated_with_SAP__c = TRUE
            ];
    
            if (lastWeekResult != null && lastWeekResult.get('totalAmount') != null) {
                lastWeekAmount =  (Decimal)lastWeekResult.get('totalAmount');
            }
            
             // Query to get currentWeek's field value
            AggregateResult currentWeekResult = [
                SELECT SUM(Amount__c) totalAmount
                FROM Student_Fee_Payment__c 
                where Line_Item_Payment_Status__c = 'Success' 
                and Student_Payment__r.Mode_of_Payment__c ='Online' 
                AND Transaction_Date_Time__c = THIS_WEEK   
                AND Integrated_with_SAP__c = TRUE
            ];
    
            if (currentWeekResult != null && currentWeekResult.get('totalAmount') != null) {
                currentWeekAmount =  (Decimal)currentWeekResult.get('totalAmount');
            }
            
             // Query to get lastMonth's field value
            AggregateResult lastMonthResult = [
                SELECT SUM(Amount__c) totalAmount
                FROM Student_Fee_Payment__c 
                where Line_Item_Payment_Status__c = 'Success' 
                and Student_Payment__r.Mode_of_Payment__c ='Online' 
                AND Transaction_Date_Time__c = LAST_MONTH  
                AND Integrated_with_SAP__c = TRUE
            ];
    
            if (lastMonthResult != null && lastMonthResult.get('totalAmount') != null) {
                lastMonthAmount =  (Decimal)lastMonthResult.get('totalAmount');
            }       
            
            // Query to get last seven days field value
            AggregateResult lastSevenDaysResult = [
                SELECT SUM(Amount__c) totalAmount
                FROM Student_Fee_Payment__c
                WHERE Line_Item_Payment_Status__c = 'Success'
                  AND Student_Payment__r.Mode_of_Payment__c = 'Online'
                  AND Transaction_Date_Time__c = LAST_N_DAYS:7
                  AND Integrated_with_SAP__c = TRUE
            ];
    
            if (lastSevenDaysResult != null && lastSevenDaysResult.get('totalAmount') != null) {
                lastSevenDaysAmount = (Decimal)lastSevenDaysResult.get('totalAmount');
            }
    
            // Query to get current month field value
            AggregateResult currentMonthResult = [
                SELECT SUM(Amount__c) totalAmount
                FROM Student_Fee_Payment__c
                WHERE Line_Item_Payment_Status__c = 'Success'
                  AND Student_Payment__r.Mode_of_Payment__c = 'Online'
                  AND Transaction_Date_Time__c = THIS_MONTH
                  AND Integrated_with_SAP__c = TRUE
            ];
    
            if (currentMonthResult != null && currentMonthResult.get('totalAmount') != null) {
                currentMonthAmount = (Decimal)currentMonthResult.get('totalAmount');
            }
    
            // Construct the response as a JSON string
            Map<String, Decimal> resultMap = new Map<String, Decimal>{
                'today' => todayAmount,
                'yesterday' => yesterdayAmount,
                'lastWeek' => lastWeekAmount,   
                'currentWeek' => currentWeekAmount,                
                'last_seven_days' => lastSevenDaysAmount,
                'current_month' => currentMonthAmount,
                'lastMonth' => lastMonthAmount                
            };
            System.debug('Result :'+resultMap);
            return JSON.serialize(resultMap);
        }
    
        // Get OFFLINE Amount Collections
        @AuraEnabled(cacheable=true)
         public static String getOfflineFeePaymentStats() {
        // Initialize variables to hold the results
        Decimal todayAmount = 0.0; 
        Decimal yesterdayAmount = 0.0;
        Decimal lastWeekAmount = 0.0;
        Decimal currentWeekAmount = 0.0;   
        Decimal lastSevenDaysAmount = 0.0;
        Decimal lastMonthAmount = 0.0;
        Decimal currentMonthAmount = 0.0;
        
        
        // Query to get today's field value
        AggregateResult todayResult = [        
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c 
            WHERE Line_Item_Payment_Status__c = 'Success' 
            AND Student_Payment__r.Mode_of_Payment__c ='Offline' 
            AND Transaction_Date_Time__c = TODAY 
        ];

        if (todayResult != null && todayResult.get('totalAmount') != null) {
            todayAmount =  (Decimal)todayResult.get('totalAmount');
        }      
        
         // Query to get yesterday's field value
        AggregateResult yesterdayResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c 
            WHERE Line_Item_Payment_Status__c = 'Success' 
            AND Student_Payment__r.Mode_of_Payment__c ='Offline' 
            AND Transaction_Date_Time__c = YESTERDAY             
        ];

        if (yesterdayResult != null && yesterdayResult.get('totalAmount') != null) {
            yesterdayAmount =  (Decimal)yesterdayResult.get('totalAmount');
        }
        
         // Query to get lastWeek's field value
        AggregateResult lastWeekResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c 
            WHERE Line_Item_Payment_Status__c = 'Success' 
            AND Student_Payment__r.Mode_of_Payment__c ='Offline' 
            AND Transaction_Date_Time__c = LAST_WEEK          
        ];

        if (lastWeekResult != null && lastWeekResult.get('totalAmount') != null) {
            lastWeekAmount =  (Decimal)lastWeekResult.get('totalAmount');
        }
        
         // Query to get currentWeek's field value
        AggregateResult currentWeekResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c 
            WHERE Line_Item_Payment_Status__c = 'Success' 
            AND Student_Payment__r.Mode_of_Payment__c ='Offline' 
            AND Transaction_Date_Time__c = THIS_WEEK
        ];

        if (currentWeekResult != null && currentWeekResult.get('totalAmount') != null) {
            currentWeekAmount =  (Decimal)currentWeekResult.get('totalAmount');
        }
        
         // Query to get lastMonth's field value
        AggregateResult lastMonthResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c 
            WHERE Line_Item_Payment_Status__c = 'Success' 
            AND Student_Payment__r.Mode_of_Payment__c ='Offline' 
            AND Transaction_Date_Time__c = LAST_MONTH
        ];

        if (lastMonthResult != null && lastMonthResult.get('totalAmount') != null) {
            lastMonthAmount =  (Decimal)lastMonthResult.get('totalAmount');
        }       
        
        // Query to get last seven days field value
        AggregateResult lastSevenDaysResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c 
            WHERE Line_Item_Payment_Status__c = 'Success' 
            AND Student_Payment__r.Mode_of_Payment__c ='Offline' 
            AND Transaction_Date_Time__c = LAST_N_DAYS:7
        ];

        if (lastSevenDaysResult != null && lastSevenDaysResult.get('totalAmount') != null) {
            lastSevenDaysAmount = (Decimal)lastSevenDaysResult.get('totalAmount');
        }

        // Query to get current month field value
        AggregateResult currentMonthResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c 
            WHERE Line_Item_Payment_Status__c = 'Success' 
            AND Student_Payment__r.Mode_of_Payment__c ='Offline' 
            AND Transaction_Date_Time__c = THIS_MONTH
        ];

        if (currentMonthResult != null && currentMonthResult.get('totalAmount') != null) {
            currentMonthAmount = (Decimal)currentMonthResult.get('totalAmount');
        }

        // Construct the response as a JSON string
        Map<String, Decimal> resultMap = new Map<String, Decimal>{
            'today' => todayAmount,
            'yesterday' => yesterdayAmount,
            'lastWeek' => lastWeekAmount,   
            'currentWeek' => currentWeekAmount,                
            'last_seven_days' => lastSevenDaysAmount,
            'current_month' => currentMonthAmount,
            'lastMonth' => lastMonthAmount                
        };
        System.debug('Result :'+resultMap);
        return JSON.serialize(resultMap);
    }    
 
    
        @AuraEnabled(cacheable=true)
        public static String getOnlineFeePaymentsMonthStats() {
            // Initialize a map to hold the results with all months set to 0.0
            Map<String, Decimal> resultMap = new Map<String, Decimal>{
                'Apr' => 0.0,
                'May' => 0.0,
                'Jun' => 0.0,
                'Jul' => 0.0,
                'Aug' => 0.0,
                'Sep' => 0.0,
                'Oct' => 0.0,
                'Nov' => 0.0,
                'Dec' => 0.0,
                'Jan' => 0.0,
                'Feb' => 0.0,
                'Mar' => 0.0
            };
        
            // Calculate the current financial year start and end dates
            Date today = Date.today();
            Integer currentYear = today.year();
            Integer financialYearStartYear = today.month() >= 4 ? currentYear : currentYear - 1;
            Date financialYearStartDate = Date.newInstance(financialYearStartYear, 4, 1); // Start of the financial year (April 1st)
            Date financialYearEndDate = Date.newInstance(financialYearStartYear + 1, 3, 31); // End of the financial year (March 31st)
        
            // Query to get all data for the current financial year
            List<Student_Fee_Payment__c> payments = [
                SELECT Amount__c, Transaction_Date_Time__c
                FROM Student_Fee_Payment__c
                WHERE Line_Item_Payment_Status__c = 'Success'
                  AND Student_Payment__r.Mode_of_Payment__c = 'Online'
                  AND Transaction_Date_Time__c >= :financialYearStartDate
                  AND Transaction_Date_Time__c <= :financialYearEndDate
                  AND Integrated_with_SAP__c = TRUE
            ];
        
            // Process the results to aggregate monthly data
            for (Student_Fee_Payment__c payment : payments) {
                DateTime transactionDateTime = payment.Transaction_Date_Time__c;
                // Convert DateTime to String in 'MMM' format
                String monthKey = transactionDateTime.format('MMM');
                
                // Update the corresponding month's total
                if (resultMap.containsKey(monthKey)) {
                    resultMap.put(monthKey, resultMap.get(monthKey) + payment.Amount__c);
                }
            }
        
            System.debug('Months -> ' + resultMap);
            // Construct the response as a JSON string
            return JSON.serialize(resultMap);       
        }
        
         @AuraEnabled(cacheable=true)
        public static String getOfflineFeePaymentsMonthStats() {
            // Initialize a map to hold the results with all months set to 0.0
            Map<String, Decimal> resultMap = new Map<String, Decimal>{
                'Apr' => 0.0,
                'May' => 0.0,
                'Jun' => 0.0,
                'Jul' => 0.0,
                'Aug' => 0.0,
                'Sep' => 0.0,
                'Oct' => 0.0,
                'Nov' => 0.0,
                'Dec' => 0.0,
                'Jan' => 0.0,
                'Feb' => 0.0,
                'Mar' => 0.0
            };
        
            // Calculate the current financial year start and end dates
            Date today = Date.today();
            Integer currentYear = today.year();
            Integer financialYearStartYear = today.month() >= 4 ? currentYear : currentYear - 1;
            Date financialYearStartDate = Date.newInstance(financialYearStartYear, 4, 1); // Start of the financial year (April 1st)
            Date financialYearEndDate = Date.newInstance(financialYearStartYear + 1, 3, 31); // End of the financial year (March 31st)
        
            // Query to get all data for the current financial year
            List<Student_Fee_Payment__c> payments = [
                SELECT Amount__c, Transaction_Date_Time__c
                FROM Student_Fee_Payment__c
                WHERE Line_Item_Payment_Status__c = 'Success'
                AND Student_Payment__r.Mode_of_Payment__c = 'Offline'
                AND Transaction_Date_Time__c >= :financialYearStartDate
                AND Transaction_Date_Time__c <= :financialYearEndDate
            ];
        
            // Process the results to aggregate monthly data
            for (Student_Fee_Payment__c payment : payments) {
                DateTime transactionDateTime = payment.Transaction_Date_Time__c;
                // Convert DateTime to String in 'MMM' format
                String monthKey = transactionDateTime.format('MMM');
                
                // Update the corresponding month's total
                if (resultMap.containsKey(monthKey)) {
                    resultMap.put(monthKey, resultMap.get(monthKey) + payment.Amount__c);
                }
            }
        
            System.debug('Months -> ' + resultMap);
            // Construct the response as a JSON string
            return JSON.serialize(resultMap);       
        }    
     
}