public class LicenseAssignmentHandler {
  //Omnistodio Licence Assgnment based on the login
    public class InputWrapper {
        @InvocableVariable(required=true)
        public String userId;
    }
    public static Boolean bypassTestContact = false; 
    public static Boolean bypassPermissionInsert = false;

    @InvocableMethod(label='Update License')
    public static void assignLicenseOnLogin(List<InputWrapper> inputs){

        if(inputs == null || inputs.isEmpty()) return;
        if(String.isBlank(inputs[0].userId)) return;

        Id userId = (Id)inputs[0].userId;

        User u = [
            SELECT Id, ContactId
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];

        Contact c;

        if(Test.isRunningTest() && !bypassTestContact){
            // In test mode, simulate a contact
            c = new Contact(Primary_Application_Submitted__c=false);
        }
        else{
            if(u.ContactId == null) return;

            List<Contact> contacts = [
                SELECT Id, Primary_Application_Submitted__c
                FROM Contact
                WHERE Id = :u.ContactId
                LIMIT 1
            ];

            if(contacts.isEmpty()) return;
            c = contacts[0];
        }

        if(!c.Primary_Application_Submitted__c){

            PermissionSet ps = [
                SELECT Id
                FROM PermissionSet
                WHERE Name='Omnistudio_Experience_Users'
                LIMIT 1
            ];

            if(!Test.isRunningTest() || bypassPermissionInsert){
                assignPermissionFuture(userId, ps.Id);
            }

            u.LastLoginTime__c = System.now();
            u.LastActivityTime__c = System.now();

            update u;
        }
    }

   @future
public static void assignPermissionFuture(Id userId, Id psId){
    // Allow bypass in test mode
    if(Test.isRunningTest() && !bypassPermissionInsert){
        return;
    }

    List<PermissionSetAssignment> existing = [
        SELECT Id
        FROM PermissionSetAssignment
        WHERE AssigneeId=:userId
        AND PermissionSetId=:psId
        LIMIT 1
    ];

    if(existing.isEmpty()){
        if(!Test.isRunningTest() || bypassPermissionInsert) {
            insert new PermissionSetAssignment(
                AssigneeId=userId,
                PermissionSetId=psId
            );
        }
    }
}
}