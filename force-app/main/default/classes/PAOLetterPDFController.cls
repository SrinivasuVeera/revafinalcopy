public with sharing class PAOLetterPDFController {
    
    public Contact con {get;set;}
    
    public List<String> yearList {get;set;}
    
    public Map<String,Decimal> annualFeeMap {get;set;}
    public Map<String,Decimal> scholarshipMap {get;set;}
    public Map<String,Decimal> netFeeMap {get;set;}
    
    public Decimal totalAnnual {get;set;}
    public Decimal totalScholarship {get;set;}
    public Decimal totalNet {get;set;}
    public Datetime transactionDateTime { get; set; }
    public String istFormatted { get; set; }
    public String paymentUrl {get;set;}
    
    public PAOLetterPDFController(){
        totalAnnual = 0;
    totalScholarship = 0;
    totalNet = 0;

    Datetime istTime = System.now();
    istFormatted = istTime.format('dd-MM-yyyy','Asia/Kolkata');

    Id contactId;

    if(Test.isRunningTest()){
        contactId = ApexPages.currentPage().getParameters().get('id');
    } else {
        contactId = ApexPages.currentPage().getParameters().get('id');
    }

    paymentUrl = ApexPages.currentPage().getParameters().get('payUrl');

    if(contactId == null){
        return;
    }
        
        if(contactId != null){
            con = [
                SELECT Id, Name, Email, Application_Number__c,
                Primary_Academic_Program_Name__c,
                Primary_Academic_Program__r.No_of_Years__c,
                Owner.Name,
                Owner.Email,
                Owner.Phone
                FROM Contact
                WHERE Id = :contactId
                LIMIT 1
            ];
        }
        
        List<Student_Fee__c> feeList = [
            SELECT Fee_Year__c,
            Fee_Type__c,
            Actual_Program_Fee__c,
            Premium__c,
            Scholarship__c
            FROM Student_Fee__c
            WHERE Contact__c = :contactId AND Fee_Type__c IN ('Tuition Fee','University Fee')
        ];
        
        List<Student_Payment__c> studentPymtList = [SELECT Id, Name, Amount__c, Fee_Type__c, Payment_Date_Time__c, Payment_Status__c, Transaction_Date_Time__c, Transaction_Status__c, Contact__c
        FROM Student_Payment__c WHERE Contact__c = :contactId AND (Fee_Type__c LIKE '%Tuition Fee%' OR Fee_Type__c like '%University Fee%') AND Payment_Status__c = 'Pending'];
       
        if (!studentPymtList.isEmpty()) {            
            transactionDateTime = studentPymtList[0].Payment_Date_Time__c;
            system.debug('DATE TIME==='+transactionDateTime);
        } else {            
            transactionDateTime = null; 
        }
        
        Set<String> yearSet = new Set<String>();
        yearList = new List<String>();
        annualFeeMap = new Map<String,Decimal>();
        scholarshipMap = new Map<String,Decimal>();
        netFeeMap = new Map<String,Decimal>();
        
        Map<String,Decimal> tuitionMap = new Map<String,Decimal>();
        Map<String,Decimal> universityMap = new Map<String,Decimal>();
        
        for(Student_Fee__c fee : feeList){
            
            yearSet.add(fee.Fee_Year__c);
            
            if(fee.Fee_Type__c == 'Tuition Fee'){
                Decimal tuitionAmount = (fee.Actual_Program_Fee__c != null ? fee.Actual_Program_Fee__c : 0) + (fee.Premium__c != null ? fee.Premium__c : 0);
        		tuitionMap.put(fee.Fee_Year__c, tuitionAmount);
            }
            
            if(fee.Fee_Type__c == 'University Fee'){
                 Decimal universityAmount = (fee.Actual_Program_Fee__c != null ? fee.Actual_Program_Fee__c : 0) + (fee.Premium__c != null ? fee.Premium__c : 0);
        		universityMap.put(fee.Fee_Year__c, universityAmount);
            }
            
            if(!scholarshipMap.containsKey(fee.Fee_Year__c))
                scholarshipMap.put(fee.Fee_Year__c,0);
            
            scholarshipMap.put(
                fee.Fee_Year__c,
                scholarshipMap.get(fee.Fee_Year__c) + fee.Scholarship__c
            );
        }
        yearList.addAll(yearSet);
        
        yearList.sort(); 
        
        Decimal commonScholarship = 0;

         // Get scholarship from first year
          if(scholarshipMap.containsKey('1st Year')){
           commonScholarship = scholarshipMap.get('1st Year');
          }

         // Apply same scholarship to all years
           for(String year : yearList){
           scholarshipMap.put(year, commonScholarship);
             }
        
        
        for(String year : yearList){
            
            Decimal annual = (tuitionMap.get(year) != null ? tuitionMap.get(year) : 0)
                + (universityMap.get(year) != null ? universityMap.get(year) : 0);
            
            annualFeeMap.put(year, annual);
            
            Decimal scholarship = scholarshipMap.containsKey(year) ? scholarshipMap.get(year) : 0;
            
            Decimal net = annual - scholarship;
            
            netFeeMap.put(year, net);
            
            totalAnnual += annual;
            totalScholarship += scholarship;
            totalNet += net;
        }
    }
}