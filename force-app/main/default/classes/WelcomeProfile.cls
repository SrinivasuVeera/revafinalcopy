public with sharing class WelcomeProfile {
    @AuraEnabled
    public  static map<string,object> getHierarchy(string userid) { 
        if(userid == null || userid == '')
            userid = UserInfo.getUserId();
          User currentUser=getProfileUser(userid);
        
        map<string,object> JSONHierarchy = new map<string,object>();
        JSONHierarchy.put('selectedUser', currentUser);
        //get welcomeprofilebackground static resource time stamp to construct the path of the static resource
        String resourceName ='welcomeprofilebackground';
        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp 
                                            FROM StaticResource 
                         WHERE Name = :resourceName
                      ];
        JSONHierarchy.put('staticResourceDateTimeStamp', resourceList);
        return JSONHierarchy;
    } 
    

    public static User getProfileUser(id userid) {
        User u = [SELECT Id, Name, FirstName, LastName, physicalDeliveryOfficeName__c, FullPhotoUrl FROM User where Id =: userid];
        return u;
    }
}