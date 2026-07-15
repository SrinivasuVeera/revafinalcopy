public class ActivityTracker {
    public static void updateActivity(Id userId) {
        User u = [SELECT Id FROM User WHERE Id = :userId];
        u.LastActivityTime__c = System.now();
        update u;
    }
}