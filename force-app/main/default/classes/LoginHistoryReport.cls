public class LoginHistoryReport {
    @AuraEnabled(cacheable=true)
    public static List<String> getProfileNames() {
        // Query to get all profiles with the Salesforce user license
        List<Profile> profiles = [
            SELECT Name 
            FROM Profile 
            //WHERE UserLicense.Name = 'Salesforce' 
            WHERE UserLicense.Name IN ('Salesforce', 'Customer Community Plus', 'Customer Community Plus Login')
            ORDER BY Name ASC
        ];
        
        // List to hold profile names
        List<String> profileNames = new List<String>();
        
        // Adding the profile names to the list
        for (Profile profile : profiles) {
            profileNames.add(profile.Name);
        }
        return profileNames;
    }
        
   @AuraEnabled(cacheable=true)
public static List<UserLoginData> generateLoginReport(List<String> selectedProfileNames, Date startDate, Date endDate) {
    // Validate input parameters
    if (selectedProfileNames == null || selectedProfileNames.isEmpty()) {
        throw new AuraHandledException('No profile selected.');
    }
    if (startDate == null || endDate == null) {
        throw new AuraHandledException('Start date or end date cannot be null.');
    }
    if (startDate > endDate) {
        throw new AuraHandledException('Start date cannot be after end date.');
    }

     try {
        // Step 1: Fetch all active users who belong to the selected profiles
        Map<Id, User> userMap = new Map<Id, User>([
            SELECT Id, Username, Profile.Name, Department
            FROM User
            WHERE Profile.Name IN :selectedProfileNames
            AND IsActive = true
        ]);

        System.debug('Total active users retrieved: ' + userMap.size());

        // Step 2: Fetch login history counts for the selected users
        List<AggregateResult> loginCounts = [
            SELECT UserId, COUNT(Id) LoginCount
            FROM LoginHistory
            WHERE LoginTime >= :startDate AND LoginTime <= :endDate
            AND UserId IN :userMap.keySet()
            GROUP BY UserId
        ];

        System.debug('Login counts retrieved: ' + loginCounts.size());

        // Step 3: Store login counts in a map (UserId -> LoginCount)
        Map<Id, Long> loginCountMap = new Map<Id, Long>();
        for (AggregateResult ar : loginCounts) {
            loginCountMap.put((Id) ar.get('UserId'), (Long) ar.get('LoginCount'));
        }

        // Step 4: Compile the final report, ensuring all users are included
        List<UserLoginData> reportData = new List<UserLoginData>();
        for (User user : userMap.values()) {
            Long loginCount = loginCountMap.containsKey(user.Id) ? loginCountMap.get(user.Id) : 0;
            
            reportData.add(new UserLoginData(
                user.Username,
                user.Profile.Name,
                loginCount,
                user.Department
            ));
        }
          // Step 5: Sort the report data in descending order of loginCount
        reportData.sort(new LoginCountComparator());

        System.debug('Report data size: ' + reportData.size());
        return reportData;

    } catch (Exception ex) {
        System.debug('Error in generateLoginReport: ' + ex.getMessage());
        throw new AuraHandledException('An error occurred while generating the report: ' + ex.getMessage());
    }
}
    // Custom Comparator to sort by loginCount in descending order

public class LoginCountComparator implements Comparator<UserLoginData> {

    public Integer compare(UserLoginData a, UserLoginData b) {

          return (b.loginCount < a.loginCount) ? 1 : (b.loginCount > a.loginCount) ? -1 : 0;

    }

}
    public class UserLoginData {
        @AuraEnabled public String username { get; set; }
        @AuraEnabled public String profileName { get; set; }
        @AuraEnabled public Long loginCount { get; set; }
        @AuraEnabled public String department { get; set; }

        public UserLoginData(String username, String profileName, Long loginCount, String department) {
            this.username = username;
            this.profileName = profileName;
            this.loginCount = loginCount;
            this.department = department;
        }    
 }
}