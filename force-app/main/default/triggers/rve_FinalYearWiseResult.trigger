trigger rve_FinalYearWiseResult on hed__Term_Grade__c (after update , after insert) {
    
/* Map<Id, Decimal> contactCreditsMap = new Map<Id, Decimal>();
Set<Id> detainedContacts = new Set<Id>();
Set<Id> passedContacts = new Set<Id>();
Decimal totalCredits;
decimal totalCourses;
    for (hed__Term_Grade__c grade : Trigger.new) {
        
        String currentSem = grade.hed__Term__r.Name;
        system.debug(currentSem);
            
            if (grade.hed__Result__c == 'fail') {
       
                // Add the contact ID and No_of_Credits__c to the map
                if (contactCreditsMap.containsKey(grade.hed__Contact__c))
                {
                    contactCreditsMap.put(grade.hed__Contact__c, 0);
                   
                }
                else{
                    contactCreditsMap.put(grade.hed__Contact__c, 0);
                }
                
            }
            System.debug('Contact ID to Failed Credits Map: ' + contactCreditsMap);

   // System.debug('Contact ID to Failed Credits Map: ' + contactCreditsMap);
       /* else{
            
         Integer updatedSem = Integer.valueOf(lastCharacter)+1;
           system.debug(grade.hed__Contact__r.Active_Semester__r.Name.substring(0, grade.hed__Contact__r.Active_Semester__r.Name.length() - 1) +String.valueOf(updatedSem));
       grade.hed__Contact__r.Active_Semester__r.Name = grade.hed__Contact__r.Active_Semester__r.Name.substring(0, grade.hed__Contact__r.Active_Semester__r.Name.length() - 1) +String.valueOf(updatedSem);
    
}*/
                                                                                                                                         
   
   /* }
    List<Contact> listOfContacts =  [SELECT Id , Name, Active_Semester__c, Active_Semester__r.Name FROM Contact WHERE Id In :contactCreditsMap.keySet()]; 
    Map<Id, String> contactLastSemMap = new Map<Id, String>();
    Map<Id, String> contactThisSemMap = new Map<Id, String>();
    
    for(Contact con : listOfContacts){
String currentSem = con.Active_Semester__r.Name;
        system.debug(currentSem);
        String thisSemNumber = currentSem.substring(currentSem.length() - 1);
system.debug(thisSemNumber);
           Integer lastSemNumber = Integer.valueOf(thisSemNumber)-1;
            String lastSem = currentSem.substring(0, currentSem.length() - 1)+String.valueOf(lastSemNumber);
system.debug(lastSem);

if (integer.valueOf(thisSemNumber)==2 || integer.valueOf(thisSemNumber)==4 || integer.valueOf(thisSemNumber)==6 || integer.valueOf(thisSemNumber)==8 || integer.valueOf(thisSemNumber)==10){
contactThisSemMap.put(con.Id , currentSem);
contactLastSemMap.put(con.Id, lastSem);
}
}
System.debug('Contact ID to last Sem Map: ' + contactLastSemMap);
System.debug('Contact ID to last Sem Map: ' + contactThisSemMap);

List <hed__Term_Grade__c> thisYearRecords = [SELECT Id ,hed__Contact__c,No_of_Credits__c,hed__Result__c, hed__Contact__r.Program_Batch__r.Name , Name , hed__Term__r.Name From hed__Term_Grade__c WHERE (hed__Contact__c In :contactLastSemMap.keySet() AND hed__Result__c = 'Fail')];


System.debug('last Sem List: ' + thisYearRecords );

for (hed__Term_Grade__c lastSemRecord : thisYearRecords ) {
        system.debug(lastSemRecord.hed__Contact__r.Program_Batch__r.Name.startsWith('B. Tech') && (lastSemRecord.hed__Term__r.Name == contactLastSemMap.get(lastSemRecord.hed__Contact__c)||lastSemRecord.hed__Term__r.Name == contactThisSemMap.get(lastSemRecord.hed__Contact__c)) );
        // Check if the contact's program batch starts with 'B. Tech' and if the term matches the last semester
        if (lastSemRecord.hed__Contact__r.Program_Batch__r.Name.startsWith('B. Tech') 
            && (lastSemRecord.hed__Term__r.Name == contactLastSemMap.get(lastSemRecord.hed__Contact__c)||lastSemRecord.hed__Term__r.Name == contactThisSemMap.get(lastSemRecord.hed__Contact__c))) {
            
            string batch = lastSemRecord.hed__Contact__r.Program_Batch__r.Name.substring(lastSemRecord.hed__Contact__r.Program_Batch__r.Name.lastIndexOf('-') + 1 , lastSemRecord.hed__Contact__r.Program_Batch__r.Name.lastIndexOf(')'));
system.debug(batch);
            
     if (Integer.valueOf(batch) >= 2023){
if (contactCreditsMap.containsKey(lastSemRecord.hed__Contact__c))
                {
                    contactCreditsMap.put(lastSemRecord.hed__Contact__c, 
                                     contactCreditsMap.get(lastSemRecord.hed__Contact__c) + lastSemRecord.No_of_Credits__c);
                   
                }
                else{
                    contactCreditsMap.put(lastSemRecord.hed__Contact__c, lastSemRecord.No_of_Credits__c);
                }
                
              totalCredits = contactCreditsMap.get(lastSemRecord.hed__Contact__c);
              
              if(totalCredits > 12){
 detainedContacts.add(lastSemRecord.hed__Contact__c);
}
else {
        passedContacts.add(lastSemRecord.hed__Contact__c);
        }
}



else if (Integer.valueOf(batch) < 2023){
if (contactCreditsMap.containsKey(lastSemRecord.hed__Contact__c))
                {
                    contactCreditsMap.put(lastSemRecord.hed__Contact__c, 
                                     contactCreditsMap.get(lastSemRecord.hed__Contact__c) + 1);
                   
                }
                else{
                    contactCreditsMap.put(lastSemRecord.hed__Contact__c, 1);
                }

totalCourses = contactCreditsMap.get(lastSemRecord.hed__Contact__c);

if(totalCourses > 4)
{
 detainedContacts.add(lastSemRecord.hed__Contact__c);
}
else {
        passedContacts.add(lastSemRecord.hed__Contact__c);
        }
}


        }
        
        else {
        passedContacts.add(lastSemRecord.hed__Contact__c);
        }
    }
    System.debug('detainedContacts: ' + detainedContacts);
    List<Contact> detainedContactsToUpdate = [SELECT Id , Student_Status__c FROM Contact WHERE Id In : detainedContacts];
    List<Contact> passedContactsToUpdate = [SELECT Id , Student_Status__c, Active_Semester__c FROM Contact WHERE Id In : passedContacts];
    
    for (Contact con : detainedContactsToUpdate )
    {
    con.Student_Status__c = 'Detained';
    }
    
    if (!detainedContactsToUpdate.isEmpty()) {
    update detainedContactsToUpdate;
}

/*for (Contact con : passedContactsToUpdate )
    {
    con.Student_Status__c = 'Detained';
    }
    
    if (!detainedContactsToUpdate.isEmpty()) {
    update detainedContactsToUpdate;
}*/
    
/* System.debug('Contact ID to Failed Credits Map: ' + contactCreditsMap); */

}