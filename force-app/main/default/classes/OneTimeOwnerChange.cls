Global class OneTimeOwnerChange implements Database.Batchable<sObject> {
   /*
OneTimeOwnerChange batch = new OneTimeOwnerChange();
Database.executeBatch(batch,200);

*/
  string OldUserAman= 'Aman V C';
  string NewUserAman= 'New Aman V C';
  string OldUserFariha = 'Fariha F';
  string NewUserFariha= 'New Fariha F';    
  Id NewUserId;

 global Database.QueryLocator start(Database.BatchableContext BC) { 
      System.debug('Inside Start'+[SELECT Id,OwnerId FROM Contact WHERE Owner.Name = : OldUserAman limit 1]);
        return Database.getQueryLocator([SELECT Id,OwnerId FROM Contact WHERE Owner.Name = : OldUserAman limit 1500]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        System.debug('Inside Execute');
        
        NewUserId = [SELECT Id FROM User WHERE Name = :NewUserAman limit 1].Id;        
         System.debug('New User ID Aman: ' + NewUserId);
        
          List<Lead> LeadsToUpdate = new List<Lead>();    
         List<Contact> contactsToUpdate = new List<Contact>();
         List<Account> accountsToUpdate = new List<Account>();
         List<randa__Application_Review__c> applicationReviewsToUpdate = new List<randa__Application_Review__c>();
         List<hed__Application__c> appSet = new List<hed__Application__c>();
         List<Student_fee__c> StuFeeToUpdate = new List<Student_fee__c>();
         List<Student_payment__c> StuPayToUpdate = new List<Student_payment__c>();
         List<student_Fee_payment__c> StuFeePayToUpdate = new List<student_Fee_payment__c>();
        for(Contact con : scope) {
            con.OwnerId =NewUserId;
            contactsToUpdate.add(con);
        }
       
     if(!contactsToUpdate.Isempty()){
        update contactsToUpdate;         
            
        }
        
        
       for(Account acc: [SELECT Id, Name, OwnerId FROM Account WHERE Owner.Name = : OldUserAman ]){
            acc.OwnerId=NewUserId;
             accountsToUpdate.add(acc);
             system.debug('accountsToUpdate::'+accountsToUpdate);
        }
        for(Lead Led: [SELECT Id, Name, OwnerId FROM Lead WHERE Owner.Name = : OldUserAman Limit 5000 ]){
            Led.OwnerId=NewUserId;
             LeadsToUpdate.add(Led);
             system.debug('LeadsToUpdate::'+LeadsToUpdate);
        }
         for(hed__Application__c app: [SELECT Id, Name, OwnerId FROM hed__Application__c WHERE Owner.Name = : OldUserAman]){
            app.OwnerId=NewUserId;
             appSet.add(app);
             system.debug('appSet::'+appSet);
        }
        for(randa__Application_Review__c ar: [SELECT Id, Name, OwnerId FROM randa__Application_Review__c WHERE Owner.Name = : OldUserAman]){
            ar.ownerId = NewUserId;
            applicationReviewsToUpdate.add(ar);
            system.debug('applicationReviewsToUpdate::'+applicationReviewsToUpdate);
        }
         for(Student_fee__c ar: [SELECT Id, Name, OwnerId FROM Student_fee__c WHERE Owner.Name = : OldUserAman limit 1500]){
            ar.ownerId = NewUserId;
            StuFeeToUpdate.add(ar);
            system.debug('StuFeeToUpdate::'+StuFeeToUpdate);
        }
        for(Student_payment__c ar: [SELECT Id, Name, OwnerId FROM Student_payment__c WHERE Owner.Name = : OldUserAman]){
            ar.ownerId = NewUserId;
            StuPayToUpdate.add(ar);
            system.debug('StuPayToUpdate::'+StuPayToUpdate);
        }
         for(student_Fee_payment__c ar: [SELECT Id, Name, OwnerId FROM student_Fee_payment__c WHERE Owner.Name = : OldUserAman ]){
            ar.ownerId = NewUserId;
            StuFeePayToUpdate.add(ar);
            system.debug('StuFeePayToUpdate::'+StuFeePayToUpdate);
        }
        if(StuFeePayToUpdate.size() > 0){
            update StuFeePayToUpdate;
        }
         if(StuFeeToUpdate.size() > 0){
            update StuFeeToUpdate;
        }
        /* if(StuPayToUpdate.size() > 0){
            update StuPayToUpdate;
        }*/
        if(LeadsToUpdate.size() > 0){
            update LeadsToUpdate;
        }
     if(accountsToUpdate.size() > 0){
            update accountsToUpdate;
        }
       
       if(appSet.size() > 0){
            update appSet;
        }
        
        if(applicationReviewsToUpdate.size() > 0){
            update applicationReviewsToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Inside Finish');
    }
}