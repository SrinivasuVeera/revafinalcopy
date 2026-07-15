global class RemoveOmniStudioLicenseScheduler implements Schedulable {
   //Remove the Omniscript Licence Based on the Login Time 
    global void execute(SchedulableContext sc) {

        Datetime limitTime = System.now().addMinutes(-30);

        List<User> inactiveUsers = [
            SELECT Id
            FROM User
            WHERE LastActivityTime__c < :limitTime
        ];

        if(inactiveUsers.isEmpty()){
            return;
        }

        Set<Id> userIds = new Set<Id>();

        for(User u : inactiveUsers){
            userIds.add(u.Id);
        }

        List<PermissionSetAssignment> psaList = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId IN :userIds
            AND PermissionSet.Name = 'Omnistudio_Experience_Users'
        ];

        if(!psaList.isEmpty()){
            delete psaList;
        }

    }
}