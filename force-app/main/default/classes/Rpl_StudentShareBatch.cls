public class Rpl_StudentShareBatch implements Database.Batchable<SObject> {
    // Class variable to store the user ID
    private Id vhUserId;
    private Set<Id> sharedParentIds;

    // Constructor to initialize the user ID based on profile name
    public Rpl_StudentShareBatch() {
        // Query for the user ID based on the profile name
        Profile vhProfile = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];
        User vhUser = [SELECT Id FROM User WHERE ProfileId = :vhProfile.Id And isActive=true LIMIT 1];
        if(vhUser != null){
            this.vhUserId = vhUser.Id;
        }
        // Initialize the sharedParentIds set
        sharedParentIds = new Set<Id>();

        // Debug statement
        System.debug('Constructor: Initialized vhUserId = ' + this.vhUserId);
    }

    // Define the query in the start method
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Fetch all ParentId values from Rpl_Student_Registration__Share
        List<Rpl_Student_Registration__Share> shareRecords = [SELECT ParentId,UserOrGroup.Profile.Name FROM Rpl_Student_Registration__Share where UserOrGroup.Profile.Name  ='Vertical Head'];
        System.debug('Start: Retrieved ' + shareRecords.size() + ' share records.');

        for (Rpl_Student_Registration__Share share : shareRecords) {
            sharedParentIds.add(share.ParentId);
        }

        // Debug statement to check sharedParentIds
        System.debug('Start: Shared Parent IDs = ' + sharedParentIds);

        // Construct the main query to find all student registrations without share records
        String query = 'SELECT Id FROM Rpl_Student_Registration__c WHERE Id NOT IN :sharedParentIds';
        System.debug('Start: Constructed query = ' + query);

        // Check if query is correctly constructed
        if (sharedParentIds.isEmpty()) {
            System.debug('Start: No existing share records found. Query might return all records.');
        }
System.debug('query:'+ query);
        return Database.getQueryLocator(query);
        
    }

    // Execute method to process the batch and create share records
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Rpl_Student_Registration__Share> sharesToCreate = new List<Rpl_Student_Registration__Share>();

        // Debug statement
        System.debug('Execute: Processing batch with ' + scope.size() + ' records.');
        if(this.vhUserId != NULL){
        // Iterate over the scope and cast to Rpl_Student_Registration__c
        for (SObject sObj : scope) {
            Rpl_Student_Registration__c student = (Rpl_Student_Registration__c) sObj;
            if (!sharedParentIds.contains(student.Id)) {
                Rpl_Student_Registration__Share shareRecord = new Rpl_Student_Registration__Share();
                shareRecord.ParentId = student.Id;
                shareRecord.UserOrGroupId = this.vhUserId; // Assign to the retrieved user ID
                shareRecord.AccessLevel = 'Read'; // Adjust access level as needed
                sharesToCreate.add(shareRecord);
                System.debug('Execute: Adding share record for student with Id = ' + student.Id);
            } else {
                System.debug('Execute: Skipping student with Id = ' + student.Id + ' as it already has a share record.');
            }
        }
    }

        // Insert share records
        if (!sharesToCreate.isEmpty()) {
            System.debug('Execute: Inserting ' + sharesToCreate.size() + ' share records.');
            try {
                insert sharesToCreate;
            } catch (DmlException e) {
                System.debug('Execute: DML exception occurred - ' + e.getMessage());
            }
        } else {
            System.debug('Execute: No new share records to insert.');
        }
    }

    // Finish method for post-processing
    public void finish(Database.BatchableContext BC) {
        // Debug statement
        System.debug('Finish: Batch job finished.');
    }
}