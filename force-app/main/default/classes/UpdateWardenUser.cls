public class UpdateWardenUser {
public static void GetCustomWardenUser(List<Reva_Hostel_Request__c> recordList) {
     System.debug('Classs');
        
    // Ensure the input list is not empty
    if (recordList == null || recordList.isEmpty()) {
        return;
    }

    Set<Id> recordIds = new Set<Id>();
    for (Reva_Hostel_Request__c rec : recordList) {
        recordIds.add(rec.Id);
    }

    // Query all relevant Reva_Hostel_Request__c records
    List<Reva_Hostel_Request__c> revaReq = [
        SELECT Id, Name, Reva_Hostel_Room__c, Reva_Hostel_Room__r.Block__c, 
               Hostel_Room_Request_For__c, Hostel_Room_Request_For__r.hed__Gender__c 
        FROM Reva_Hostel_Request__c 
        WHERE Id IN :recordIds and Warden__c = null
    ];
   System.debug('revaReq:'+revaReq);
    Map<Id, Reva_Hostel_Request__c> requestMap = new Map<Id, Reva_Hostel_Request__c>();
    String block = null;
    String gender = null;
    Id recId = null;
     Map<String, String> genderMap = new Map<String, String>{
        'male' => 'Boys',
        'female' => 'Girls'
    };

    for (Reva_Hostel_Request__c rhr : revaReq) {
        if (rhr.Reva_Hostel_Room__c != null) {
            block = rhr.Reva_Hostel_Room__r.Block__c;
            recId = rhr.Id;
            gender = genderMap.get(rhr.Hostel_Room_Request_For__r.hed__Gender__c.toLowerCase());
            requestMap.put(recId, rhr);
            break; // Process one matching record
        }
    }

    if (block == null) {
        return;
    }

    // custom settings Query Warden Users
    List<Warden_Users__c> wardenUsers = [
        SELECT Id, Name, Block__c, Gender__C 
        FROM Warden_Users__c 
        WHERE (Block__c = :block OR Block__c = NULL) AND Gender__C = :gender
    ];
  System.debug('wardenUsers:'+wardenUsers);
    Warden_Users__c blockWarden = null;
    Warden_Users__c chiefWarden = null;

    for (Warden_Users__c wu : wardenUsers) {
        if (wu.Block__c == block) {
            blockWarden = wu;
        } else if (wu.Block__c == null) {
            chiefWarden = wu;
        }
    }

    if (blockWarden == null || chiefWarden == null) {
        return;
    }

    // Query Users
    Map<String, User> userMap = new Map<String, User>();
    List<User> users = [
        SELECT Id, Name, Profile.Name 
        FROM User 
        WHERE (Profile.Name = 'Warden' or Profile.Name = 'Chief Warden')
        AND Name IN :new Set<String>{blockWarden.Name, chiefWarden.Name}
    ];

    for (User usr : users) {
        userMap.put(usr.Name, usr);
    }
            System.debug('getUser:'+userMap.get(blockWarden.Name));
           System.debug('getUser2:'+userMap.get(chiefWarden.Name));
   if (userMap.containsKey(blockWarden.Name) && userMap.containsKey(chiefWarden.Name)) {
        User getUser = userMap.get(blockWarden.Name);
        User getUser2 = userMap.get(chiefWarden.Name);
        System.debug('getUser:'+getUser);
           System.debug('getUser2:'+getUser2);
        if (getUser != null && getUser2 != null) {
            Reva_Hostel_Request__c requestUpdate = new Reva_Hostel_Request__c();
            requestUpdate.Id = recId;
            requestUpdate.Warden__c = getUser.Id; 
            requestUpdate.ChiefWarden__c = getUser2.Id;

            try {
                update requestUpdate;
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
        }
    }
}

}