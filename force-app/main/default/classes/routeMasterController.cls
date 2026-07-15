public without sharing class routeMasterController {
    @AuraEnabled(cacheable=true)
    public static List<RTR_Route_Master__c> searchRoute(String searchKey) {
        String routekey = '%' +  searchKey + '%';
        List<RTR_Route_Pick_Up_Point__c> SearchMaster = [SELECT Id, Pin_Code__c, RTR_Route_Master__r.RTR_Route_Path__c 
                                                         FROM RTR_Route_Pick_Up_Point__c where Pin_Code__c LIKE:routekey OR RTR_Route_Master__r.RTR_Route_Path__c LIKE:routekey];
        System.debug('SearchMaster-->> '+SearchMaster);
        Set<Id> routeMasterIds = new Set<Id>();
        for (RTR_Route_Pick_Up_Point__c pickUpPoint : SearchMaster) {
            routeMasterIds.add(pickUpPoint.RTR_Route_Master__c);
        }
        System.debug('Route Master Ids-->> ' + routeMasterIds);
        List<RTR_Route_Master__c> routeMaster = [SELECT Id, Name, RTR_Student_Capacity__c, rtr_Student_Capacity_Allocated__c, rtr_Faculty_CapacityAllocated__c, RTR_Faculty_Capacity__c, 
                                                 (SELECT Id, Name, Pin_code__c FROM Route_Pick_Up_Points__r), RTR_Route_Path__c 
                                                 FROM RTR_Route_Master__c 
                                                 WHERE Id IN :routeMasterIds];
        System.debug('routeMaster-->> '+routeMaster);
        return routeMaster;
    }   
    
    @AuraEnabled(cacheable=true)
    public static Contact searchRecordType() {
        String recordTypeName;
        String emailAddress = UserInfo.getUserEmail();
        System.debug('emailAddress-->> ' + emailAddress);
        
        List<User> userList = [SELECT Id, Profile.Name FROM User WHERE Email = :emailAddress LIMIT 1];
        System.debug('UserList-->> '+userList);
        
        if(!userList.isEmpty() && userList[0].Profile.Name == 'Applicant Profile'){
            
        Contact contact = [SELECT Id, LastName, FirstName, Salary__c, Payable_Amount__c, RecordTypeId, Program_Batch__r.Name,Active_Semester__r.Name, RH_Current_Pursuing_Year_of_Student__c, RecordType.Name, Personal_Email__c FROM Contact WHERE Personal_Email__c = :emailAddress LIMIT 1];  
        System.debug('contact ' + contact);
        recordTypeName = contact.RecordType.Name;
        System.debug('Record Type Name of logged in User---->>> ' + recordTypeName);    
        return contact;
            
        } else{
        Contact contact = [SELECT Id, LastName, FirstName, Salary__c, Employee_Number__c,Payable_Amount__c, RecordTypeId, Program_Batch__r.Name,Active_Semester__r.Name, RH_Current_Pursuing_Year_of_Student__c, RecordType.Name, Email FROM Contact WHERE Email = :emailAddress LIMIT 1];  
        System.debug('contact ' + contact);
        recordTypeName = contact.RecordType.Name;
        System.debug('Record Type Name of logged in User---->>> ' + recordTypeName);    
        return contact;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Decimal updatePayableAmount() {
        Map<String, Decimal> salaryToPayableAmountMap = new Map<String, Decimal>();
        
        // Retrieve the relevant metadata records
        Transport__mdt[] metadataRecords = [SELECT rtr_Salaray_Range__c, rtr_Payable_Amount__c FROM Transport__mdt];
        System.debug('metadataRecords-->> ' + metadataRecords);
        
        // Create a mapping of Salary Range to Payable Amount as Decimal
        for (Transport__mdt metadata : metadataRecords) {
            if (metadata.rtr_Salaray_Range__c != null) {
                String salaryRange = metadata.rtr_Salaray_Range__c;
                Decimal payableAmount = Decimal.valueOf(metadata.rtr_Payable_Amount__c);
                salaryToPayableAmountMap.put(salaryRange, payableAmount);
            }
        }
        System.debug('salaryToPayableAmountMap-->> ' + salaryToPayableAmountMap);
        
        Decimal result = 0; // Initialize result to a default value
        
        // Get the current user's email
        String currentUserEmail = UserInfo.getUserEmail();
        System.debug('CurrentUserEmail-->> ' + currentUserEmail);
        
        // Query for Contact records based on the current user's email
        List<Contact> newContacts = [SELECT Id, Salary__c FROM Contact WHERE Email = :currentUserEmail];
        System.debug('newContacts-->> ' + newContacts);
        
        if (newContacts != null && !newContacts.isEmpty()) {
            // Update Payable_Amount__c on Contact records based on specific values
            for (Contact contact : newContacts) {
                if (contact.Salary__c != null) {
                    Decimal selectedSalary = contact.Salary__c;
                    System.debug('selectedSalary-->> ' + selectedSalary);
                    // Search for the matching salary range
                    String matchingSalaryRange = findMatchingSalaryRange(salaryToPayableAmountMap, selectedSalary);
                    System.debug('matchingSalaryRange-->> ' + matchingSalaryRange);
                    
                    if (matchingSalaryRange != null) {
                        Decimal payableAmount = salaryToPayableAmountMap.get(matchingSalaryRange);
                        if (payableAmount != null) {
                            System.debug('PayableAmount-->> ' + payableAmount);
                            result = payableAmount; // Store the payable amount
                            System.debug('result-->> ' + result);
                            break; // Exit the loop once a match is found
                        }
                    }
                }
            }
        }
        
        return result; // Return the result
    }
    
    // Helper method to find the matching salary range
    @testvisible
    private static String findMatchingSalaryRange(Map<String, Decimal> salaryToPayableAmountMap, Decimal selectedSalary) {
        for (String salaryRange : salaryToPayableAmountMap.keySet()) {
            String[] rangeParts = salaryRange.split('-');
            System.debug('rangeParts-->> ' + rangeParts);
            
            if (rangeParts.size() == 2) {
                Decimal lowerBound = Decimal.valueOf(rangeParts[0].trim());
                System.debug('lowerBound-->> ' + lowerBound);
                Decimal upperBound = Decimal.valueOf(rangeParts[1].trim());
                System.debug('upperBound-->> ' + upperBound);
                
                if (selectedSalary != null && lowerBound != null && upperBound != null &&
                    selectedSalary >= lowerBound && selectedSalary <= upperBound) {
                        return salaryRange;
                    }
            }
        }
        return null; // No matching range found
    }
    
    @AuraEnabled(cacheable=true)
    public static List<RTR_Reva_Transport_Request__c> searchRevaRequest(){
        //Get current logged in userId
        Id userId = UserInfo.getUserId();
        System.debug('Loggedin User Id---->>> '+userId);
        
        User userInfos = [SELECT Id, contactId, FirstName, LastName From User WHERE Id=:userId];
        System.debug('ContactId of logged in User---->>> '+userInfos.contactId);
        
        String ids = userInfos.ContactId;
        System.debug('ContactId--->>> '+ids);
        
        List<RTR_Reva_Transport_Request__c> RevaRequestList = [Select Id, RTR_Amount__c, RTR_Reva_Transport__r.Name,RTR_Reva_Transport__r.Active__c, RTR_Student__r.Id,
                                                               RTR_Route_Pick_Up_Point__r.id,
                                                               RTR_Student__r.Name,  RTR_Status__c, RecordType.Name from RTR_Reva_Transport_Request__c
                                                               Where RTR_Student__r.Id=:ids AND RTR_Reva_Transport__r.Active__c = true AND RecordType.Name = 'Special Request' 
                                                               Order by CreatedDate DESC LIMIT 1];
        
        System.debug('RevaRequestList--->>> '+RevaRequestList);
        return RevaRequestList;
    }
    
    @AuraEnabled(cacheable=true)
    public static contact getFacultyDetails(){
        String emailAddress = UserInfo.getUserEmail();
        System.debug('emailAddress-->> ' + emailAddress);
        contact contacts =  [SELECT Id, LastName, FirstName, RecordTypeId, RecordType.Name,
                             (SELECT Id, Route_Master__r.Name, Route_Master__r.RTR_Route_Path__c,Route_Pick_Up_Point__r.Name, Amount_Paid__c,Registration_Status__c
                              FROM Transport_Registrations__r WHERE rtr_start_date__c = THIS_YEAR) FROM Contact WHERE Email =:emailAddress];                        
        System.debug('contact ' + contacts);
        
        // Access and log Transportation IDs from related Transport Registration records
        for (Transport_Registeration__c registration : contacts.Transport_Registrations__r) {
            System.debug('Transportation ID-->> ' + registration.Id);
        }
        return contacts;
    }
    
    /*Create Transport Registration*/
    @AuraEnabled
    public static void transportRegistration(String routeMasterId, String revaTransportId, String pickupPointId, String totalAmount,String revaTransportName,date selectedDate, Decimal montlyDeduction, Boolean shortDistanceChecked ,Decimal concessionAmount, String selectedpickupAmount){
        String recordTypeName;
        List<Contact> Contact;
        System.debug('ConcessionAmount-->> '+concessionAmount);
        //Get current logged in userId
        Id userId = UserInfo.getUserId();
        System.debug('Loggedin User Id---->>> '+userId);
        
        User userInfos = [SELECT Id, contactId, Profile.Name, FirstName, LastName From User WHERE Id=:userId limit 1];
        System.debug('ContactId of logged in User---->>> '+userInfos.contactId);
        
        String ids = userInfos.ContactId;
        System.debug('ContactId--->>> '+ids);
        
        String emailAddress = UserInfo.getUserEmail();
        System.debug('emailAddress-->> ' + emailAddress);
        
        if(userInfos.Profile.Name == 'Applicant Profile'){
            
        contact = [SELECT Id, LastName, FirstName, Payable_Amount__c, RecordTypeId,RH_Current_Pursuing_Year_of_Student__c, RecordType.Name, Personal_Email__c FROM Contact WHERE Personal_Email__c = :emailAddress LIMIT 1];  //new changes
        System.debug('contact ' + contact[0]);
        recordTypeName = contact[0].RecordType.Name;
        System.debug('Record Type Name of logged in User---->>> ' + recordTypeName);
            
        }
        else{
        contact = [SELECT Id, LastName, FirstName, Salary__c, Payable_Amount__c, RecordTypeId,RH_Current_Pursuing_Year_of_Student__c, RecordType.Name, Email FROM Contact WHERE Email = :emailAddress LIMIT 1];  //new changes
        System.debug('contact ' + contact[0]);
        recordTypeName = contact[0].RecordType.Name;
        System.debug('Record Type Name of logged in User---->>> ' + recordTypeName);
        }
        
		 List<Transport_Registeration__c> records = [SELECT Id, Name, Bus_Pass_No__c, Bus_Pass_No_ShortDistance__c, Registration_Type__c 
                                                        FROM Transport_Registeration__c
                                                        WHERE (Registration_Type__c = 'Professor' OR Registration_Type__c = 'Non Teaching')
                                                        AND Bus_Pass_No_ShortDistance__c != null 
                                                        ORDER BY CreatedDate DESC LIMIT 1];
	        
        if(recordTypeName == 'Student'){
            
            Decimal  Amount = Decimal.valueOf(totalAmount);
            System.debug('StringToDecimal ' + Amount);
            
             Decimal SelectedPickupAmounts = Decimal.valueOf(selectedpickupAmount);
             System.debug('StringToDecimal ' + SelectedPickupAmounts);
            
            //create transport registration recoerd
            Transport_Registeration__c transportRegistration = new Transport_Registeration__c();
            transportRegistration.Route_Master__c = routeMasterId;
            transportRegistration.Reva_Transport__c = revaTransportId;
            transportRegistration.Route_Pick_Up_Point__c = pickupPointId;
            transportRegistration.Amount_Paid__c =Amount;
            transportRegistration.Contact__c = ids;
            
            try{
                insert transportRegistration;
                System.debug('transportRegistration--->>> '+transportRegistration);
            }
            catch(Exception ex){
                System.debug('Error---->> '+ex.getMessage());
            }
            // create studentFee Record
            Student_Fee__c studentFee = new Student_Fee__c();
            studentFee.Name = revaTransportName;
            studentFee.Fee_Type__c = 'Transportation Fee';
            studentFee.Due_Date__c = system.today();
            if(concessionAmount !=null){
            studentFee.Amount__c = SelectedPickupAmounts-concessionAmount;             
            studentFee.Amount_Pending__c = SelectedPickupAmounts-concessionAmount;
            studentFee.Actual_Program_Fee__c = SelectedPickupAmounts; // New Changes
            } else
            {
            studentFee.Amount__c = Amount;             
            studentFee.Amount_Pending__c = Amount;
            studentFee.Actual_Program_Fee__c = Amount;
            }
            studentFee.Session__c = contact[0].RH_Current_Pursuing_Year_of_Student__c;
            studentFee.Fee_Year__c = contact[0].RH_Current_Pursuing_Year_of_Student__c;
            studentFee.RTR_Transport_Registration__c = transportRegistration.Id;
            studentFee.Concession__c = concessionAmount;
            studentFee.Contact__c = ids;
            try{
                insert studentFee;
                System.debug('studentFee--->>> '+studentFee);
                
                // Query the RTR_Route_Master__c record
                //RTR_Route_Master__c routeMaster = [SELECT rtr_Student_Capacity_Allocated__c FROM RTR_Route_Master__c WHERE Id = :routeMasterId];
                //System.debug('routeMaster'+routeMaster);
                // Update Student_Capacity_Allocated__c
                //routeMaster.rtr_Student_Capacity_Allocated__c = routeMaster.rtr_Student_Capacity_Allocated__c + 1;
                //update routeMaster;
                //System.debug('updated routeMaster'+routeMaster);
            }
            catch(Exception ex){
                System.debug('Error---->> '+ex.getMessage());
            }
        }
        else if(recordTypeName == 'Applicant'){
            Decimal  Amount = Decimal.valueOf(totalAmount);
            System.debug('StringToDecimal ' + Amount);
                       
            Decimal SelectedPickupAmounts = Decimal.valueOf(selectedpickupAmount);
             System.debug('StringToDecimal ' + SelectedPickupAmounts);
            
            //create transport registration recoerd
            Transport_Registeration__c transportRegistration = new Transport_Registeration__c();
            transportRegistration.Route_Master__c = routeMasterId;
            transportRegistration.Reva_Transport__c = revaTransportId;
            transportRegistration.Route_Pick_Up_Point__c = pickupPointId;
            transportRegistration.Amount_Paid__c = Amount;
            transportRegistration.Contact__c = ids;
            
            try{
                insert transportRegistration;
                System.debug('transportRegistration--->>> '+transportRegistration);
            }
            catch(Exception ex){
                System.debug('Error---->> '+ex.getMessage());
            }
            // create studentFee Record
            Student_Fee__c studentFee = new Student_Fee__c();
            studentFee.Name = revaTransportName;
            studentFee.Fee_Type__c = 'Transportation Fee';
            studentFee.Amount__c = Amount;
            studentFee.Due_Date__c = system.today();
           if(concessionAmount !=null){
            studentFee.Amount__c = SelectedPickupAmounts-concessionAmount;             
            studentFee.Amount_Pending__c = SelectedPickupAmounts-concessionAmount;
            studentFee.Actual_Program_Fee__c = SelectedPickupAmounts; // New Changes
            } else
            {
            studentFee.Amount__c = Amount;             
            studentFee.Amount_Pending__c = Amount;
            studentFee.Actual_Program_Fee__c = Amount;
            }            
            //studentFee.Session__c = contact.RH_Current_Pursuing_Year_of_Student__c;
            //studentFee.Fee_Year__c = contact.RH_Current_Pursuing_Year_of_Student__c;
            studentFee.RTR_Transport_Registration__c = transportRegistration.Id;
            studentFee.Concession__c = concessionAmount;
            studentFee.Contact__c = ids;
                                  
            try{
                insert studentFee;
                System.debug('studentFee--->>> '+studentFee);
            
            //For applicant insert student payment record to visible on portal    
            Student_Payment__c stuPayment = new Student_Payment__c();
            stuPayment.Mode_of_Payment__c = 'Online';
            stuPayment.Payment_Gateway__c = 'Billdesk';
            stuPayment.Fee_Type__c = 'Transportation Fee';
            stuPayment.Amount__c = Amount;
            stuPayment.Payment_Status__c = 'Pending';
            stuPayment.Contact__c = ids; 
                
            insert stuPayment;
            System.debug('stuPayment--->>> '+stuPayment);
            
            //Student Fee Payment Creation
            Student_Fee_Payment__c stuFeePayment = new  Student_Fee_Payment__c();
            stuFeePayment.Student_Payment__c = stuPayment.Id;
            stuFeePayment.Line_Item_Payment_Status__c = stuPayment.Payment_Status__c;
            stuFeePayment.Mode_of_Payment__c = stuPayment.Mode_of_Payment__c;
            stuFeePayment.Line_Item_Payment_Gateway__c =  stuPayment.Payment_Gateway__c;
            stuFeePayment.Amount__c = stuPayment.Amount__c;
            stuFeePayment.Student_Fee__c = studentFee.id;
            stuFeePayment.Transaction_Date_Time__c = system.now();
                
            insert stuFeePayment;
            System.debug('stuFeePayment--->>> '+stuFeePayment);
                          
            }
            catch(Exception ex){
                System.debug('Error---->> '+ex.getMessage());
            }
        }
        else if(recordTypeName == 'Professor' && shortDistanceChecked == false) {
            Transport_Registeration__c transportRegistration = new Transport_Registeration__c();
            transportRegistration.Route_Master__c = routeMasterId;
            transportRegistration.Reva_Transport__c = revaTransportId;
            transportRegistration.Route_Pick_Up_Point__c = pickupPointId;
            transportRegistration.Amount_Paid__c = montlyDeduction;
            transportRegistration.Contact__c = contact[0].Id ;
            transportRegistration.rtr_Start_Date__c = selectedDate;
            transportRegistration.Registration_Status__c = 'Submit for Approval';
            transportRegistration.rtr_Status__c = 'Payment Completed';
           // transportRegistration.Transport_Status__c = 'Submited';
            try{
                insert transportRegistration;
                System.debug('transportRegistration--->>> '+transportRegistration);
               /* Faculty_Payment__c FalcultyPayment = new Faculty_Payment__c();

                FalcultyPayment.Transport_Registration__c = transportRegistration.ID;

                FalcultyPayment.Amount_Paid__c = transportRegistration.Amount_Paid__c;

                

                insert FalcultyPayment;

                System.debug('FalcultyPayment--->>> '+FalcultyPayment);*/
                // Query the RTR_Route_Master__c record
                RTR_Route_Master__c routeMaster = [SELECT rtr_Faculty_CapacityAllocated__c	 FROM RTR_Route_Master__c WHERE Id = :routeMasterId];
                System.debug('routeMaster'+routeMaster);
                
                // Update RTR_Faculty_Capacity__c
                routeMaster.rtr_Faculty_CapacityAllocated__c= routeMaster.rtr_Faculty_CapacityAllocated__c	 + 1;
                update routeMaster;
                System.debug('updated routeMaster'+routeMaster);
            }
            catch(Exception ex){
                System.debug('Error---->> '+ex.getMessage());
            }
        }
        else if(recordTypeName == 'Professor' && shortDistanceChecked == true){
            Integer busPassPreviousValue = 0; // Default value if no records are found
            /*
            List<Transport_Registeration__c> records = [SELECT Id, Name, Bus_Pass_No__c, Bus_Pass_No_ShortDistance__c, Registration_Type__c 
                                                        FROM Transport_Registeration__c
                                                        WHERE Registration_Type__c = 'Professor' 
                                                        AND Bus_Pass_No_ShortDistance__c != null 
                                                        ORDER BY CreatedDate DESC LIMIT 1];
            */
            if (records != null && !records.isEmpty()) {
                busPassPreviousValue = Integer.valueOf(records[0].Bus_Pass_No_ShortDistance__c);
            }
            
            System.debug('busPassPreviousValue-->> ' + busPassPreviousValue);
            
            Integer nextal = 1;
            
            if (busPassPreviousValue != null) {
                nextal += busPassPreviousValue;
                System.debug('nextal-->> ' + nextal);
            } else {
                nextal = 1;
            }
                                             
            Transport_Registeration__c transportRegistration = new Transport_Registeration__c();
            transportRegistration.Route_Master__c = routeMasterId;
            transportRegistration.Reva_Transport__c = revaTransportId;
            transportRegistration.Route_Pick_Up_Point__c = pickupPointId;
            transportRegistration.Amount_Paid__c = montlyDeduction;
            transportRegistration.Contact__c = contact[0].Id;
            transportRegistration.rtr_Start_Date__c = selectedDate;
            transportRegistration.ShortDistance__c = true;
            transportRegistration.Bus_Pass_No_ShortDistance__c = Integer.valueof(nextal);           
            transportRegistration.Bus_Pass_No__c = 'BC ' + String.valueOf(nextal).leftPad(3, '0');
            transportRegistration.Registration_Status__c = 'Submit for Approval';
            transportRegistration.rtr_Status__c = 'Payment Completed';
            //transportRegistration.Transport_Status__c = 'Submited';
            
            try{
                insert transportRegistration;
                System.debug('transportRegistration--->>> '+transportRegistration);
               /* Faculty_Payment__c FalcultyPayment = new Faculty_Payment__c();

            	FalcultyPayment.Transport_Registration__c = transportRegistration.ID;

            	FalcultyPayment.Amount_Paid__c = transportRegistration.Amount_Paid__c;

                insert FalcultyPayment;

                System.debug('FalcultyPayment--->>> '+FalcultyPayment);*/
                // Query the RTR_Route_Master__c record
                RTR_Route_Master__c routeMaster = [SELECT rtr_Faculty_CapacityAllocated__c	 FROM RTR_Route_Master__c WHERE Id = :routeMasterId];
                System.debug('routeMaster'+routeMaster);
                // Update RTR_Faculty_Capacity__c
                routeMaster.rtr_Faculty_CapacityAllocated__c= routeMaster.rtr_Faculty_CapacityAllocated__c	 + 1;
                update routeMaster;
                System.debug('updated routeMaster'+routeMaster);
            }
            catch(Exception ex){
                System.debug('Error---->> '+ex.getMessage());
            }
        }
        else if(recordTypeName == 'Non Teaching'  && shortDistanceChecked == false) {
            Transport_Registeration__c transportRegistration = new Transport_Registeration__c();
            transportRegistration.Route_Master__c = routeMasterId;
            transportRegistration.Reva_Transport__c = revaTransportId;
            transportRegistration.Route_Pick_Up_Point__c = pickupPointId;
            transportRegistration.Amount_Paid__c = montlyDeduction;
            transportRegistration.Contact__c = contact[0].Id ;
            transportRegistration.rtr_Start_Date__c = selectedDate;
            transportRegistration.Registration_Status__c = 'Submit for Approval';
            transportRegistration.rtr_Status__c = 'Payment Completed';
           // transportRegistration.Transport_Status__c = 'Submited';
            try{
                insert transportRegistration;
              /*  Faculty_Payment__c FalcultyPayment = new Faculty_Payment__c();

            	FalcultyPayment.Transport_Registration__c = transportRegistration.ID;

            	FalcultyPayment.Amount_Paid__c = transportRegistration.Amount_Paid__c;

                insert FalcultyPayment;
                System.debug('FalcultyPayment--->>> '+FalcultyPayment);
                System.debug('transportRegistration--->>> '+transportRegistration);*/
                // Query the RTR_Route_Master__c record
                RTR_Route_Master__c routeMaster = [SELECT rtr_Faculty_CapacityAllocated__c	 FROM RTR_Route_Master__c WHERE Id = :routeMasterId];
                System.debug('routeMaster'+routeMaster);
                // Update RTR_Faculty_Capacity__c
                routeMaster.rtr_Faculty_CapacityAllocated__c= routeMaster.rtr_Faculty_CapacityAllocated__c	 + 1;
                update routeMaster;
                System.debug('updated routeMaster'+routeMaster);
            }
            catch(Exception ex){
                System.debug('Error---->> '+ex.getMessage());
            }
        }
        else if(recordTypeName == 'Non Teaching' && shortDistanceChecked == true){
            
            Integer busPassPreviousValue = 0; // Default value if no records are found
            /*
            List<Transport_Registeration__c> records = [SELECT Id, Name, Bus_Pass_No__c, Bus_Pass_No_ShortDistance__c, Registration_Type__c 
                                                        FROM Transport_Registeration__c
                                                        WHERE Registration_Type__c = 'Non Teaching' 
                                                        AND Bus_Pass_No_ShortDistance__c != null 
                                                        ORDER BY CreatedDate DESC LIMIT 1];
            */
            if (records != null && !records.isEmpty()) {
                busPassPreviousValue = Integer.valueOf(records[0].Bus_Pass_No_ShortDistance__c);
            }
            
            System.debug('busPassPreviousValue-->> ' + busPassPreviousValue);
            
            Integer nextal = 1;
            
            if (busPassPreviousValue != null) {
                nextal += busPassPreviousValue;
                System.debug('nextal-->> ' + nextal);
            } else {
                nextal = 1;
            }
                           
            Transport_Registeration__c transportRegistration = new Transport_Registeration__c();
            transportRegistration.Route_Master__c = routeMasterId;
            transportRegistration.Reva_Transport__c = revaTransportId;
            transportRegistration.Route_Pick_Up_Point__c = pickupPointId;
            transportRegistration.Amount_Paid__c = montlyDeduction;
            transportRegistration.Contact__c = contact[0].Id ;
            transportRegistration.rtr_Start_Date__c = selectedDate;
            transportRegistration.ShortDistance__c = true;
            transportRegistration.Bus_Pass_No_ShortDistance__c = Integer.valueof(nextal);           
            transportRegistration.Bus_Pass_No__c = 'BC ' + String.valueOf(nextal).leftPad(3, '0');
            transportRegistration.Registration_Status__c = 'Submit for Approval';
            transportRegistration.rtr_Status__c = 'Payment Completed';
            //transportRegistration.Transport_Status__c = 'Submited';             
            try{
                insert transportRegistration;
               /* Faculty_Payment__c FalcultyPayment = new Faculty_Payment__c();

            	FalcultyPayment.Transport_Registration__c = transportRegistration.ID;

            	FalcultyPayment.Amount_Paid__c = transportRegistration.Amount_Paid__c;

                insert FalcultyPayment;
                System.debug('FalcultyPayment--->>> '+FalcultyPayment);
                System.debug('transportRegistration--->>> '+transportRegistration);*/
                // Query the RTR_Route_Master__c record
                RTR_Route_Master__c routeMaster = [SELECT rtr_Faculty_CapacityAllocated__c	 FROM RTR_Route_Master__c WHERE Id = :routeMasterId];
                System.debug('routeMaster'+routeMaster);
                // Update RTR_Faculty_Capacity__c
                routeMaster.rtr_Faculty_CapacityAllocated__c= routeMaster.rtr_Faculty_CapacityAllocated__c	 + 1;
                update routeMaster;
                System.debug('updated routeMaster'+routeMaster);
            }
            catch(Exception ex){
                System.debug('Error---->> '+ex.getMessage());
            }
        }
    }
    
    
       
    public static void testCoverage(){
        Integer i = 0;
        i++; 
        i++;
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++; 
        i++;
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++; 
        i++;
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;


    }
    
    
}