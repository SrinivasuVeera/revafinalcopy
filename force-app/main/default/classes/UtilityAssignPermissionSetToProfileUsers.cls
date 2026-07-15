public class UtilityAssignPermissionSetToProfileUsers {
    /**
     * Assigns a permission set to all users of a given profile.
     * 
     * @param profileName The name of the profile whose users will be updated.
     * @param permissionSetName The API name of the permission set to assign.
     */
    public static void assignPermissionSet(String profileName, String permissionSetName) {
        try {
            // Get the Profile ID based on the profile name
            Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
            
            if (profile == null) {
                System.debug('Profile not found: ' + profileName);
                return;
            }

            // Get all active users with the specified profile
            List<User> users = [SELECT Id FROM User WHERE ProfileId = :profile.Id AND IsActive = true];
            if (users.isEmpty()) {
                System.debug('No active users found for the profile: ' + profileName);
                return;
            }

            // Fetch the Permission Set
            PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
            if (permissionSet == null) {
                System.debug('Permission Set not found: ' + permissionSetName);
                return;
            }

            // Create PermissionSetAssignment records
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (User user : users) {
                psaList.add(new PermissionSetAssignment(
                    AssigneeId = user.Id,
                    PermissionSetId = permissionSet.Id
                ));
            }

            // Insert the PermissionSetAssignment records
            if (!psaList.isEmpty()) {
                Database.SaveResult[] results = Database.insert(psaList, false);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        System.debug('Failed to assign Permission Set to user: ' + result.getErrors()[0].getMessage());
                    }
                }
                System.debug('Permission Set successfully assigned to users.');
            }
        } catch (Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
        }
    }
}