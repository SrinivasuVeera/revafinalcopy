public with sharing class CaseTeamController {
    
    // Wrapper class without teamRoleName
    public class TeamMemberWrapper {
        @AuraEnabled public Id memberId { get; set; }
        @AuraEnabled public String memberName { get; set; }
        @AuraEnabled public String studentStatus { get; set; }
        @AuraEnabled public String srnNumber { get; set; }
        @AuraEnabled public Decimal Attendance { get; set; }
        @AuraEnabled public Id userId { get; set;}
        @AuraEnabled public String loginUrl { get; set; }
    } 
    
    
    @AuraEnabled(cacheable=true)
    public static List<TeamMemberWrapper> getCaseTeamMembers(String caseId) {
        // Fetch CaseTeamMember records without TeamRole
        List<CaseTeamMember> teamMembers = [SELECT Id, MemberId 
                                            FROM CaseTeamMember 
                                            WHERE ParentId = :caseId];
        System.debug('Team Members: ' + teamMembers);

        // Collect MemberIds (Contact IDs)
        Set<Id> contactIds = new Set<Id>();
        for (CaseTeamMember member : teamMembers) {
            if (member.MemberId != null) {
                contactIds.add(member.MemberId);
            }
        }
        System.debug('Contact IDs: ' + contactIds);

        // Fetch Contact details
        Map<Id, Contact> contactMap = new Map<Id, Contact>(
            [SELECT Id, Name, Student_Status__c, SRN_Number__c,Total_average_current_sem_attendance__c 
             FROM Contact 
             WHERE Id IN :contactIds]
        );
        System.debug('Contact Map: ' + contactMap);
        
       
        // Fetch Users related to those Contacts (include UserType)
    Map<Id, User> userMapByContact = new Map<Id, User>();
    for (User u : [
        SELECT Id, ContactId, UserType 
        FROM User 
        WHERE ContactId IN :contactIds
    ]) {
        userMapByContact.put(u.ContactId, u);
    }
     
         // 🔹 Fetch Org and Network info dynamically
    String baseUrl = System.URL.getOrgDomainUrl().toExternalForm();
    String orgId = UserInfo.getOrganizationId();

    //Find NetworkId dynamically (your site’s network)
   
        List<Network> siteNetworkList = [SELECT Id, Name,UrlPathPrefix, Status FROM Network 
                 WHERE (Name = 'Student Portal'OR UrlPathPrefix = 'StudentPortal') AND Status = 'Live' LIMIT 1];
        String networkId = (siteNetworkList.isEmpty()) ? null : siteNetworkList[0].Id;
 
        if (networkId == null) {
         System.debug('⚠️ No active Student Portal network found. Login URL will not be generated.');
         }
        
        // Build the wrapper list
        List<TeamMemberWrapper> wrappers = new List<TeamMemberWrapper>();
        for (CaseTeamMember member : teamMembers) {
            Contact relatedContact = contactMap.get(member.MemberId);
           // User relatedUser = userMap.get(member.MemberId);
            User relatedUser =userMapByContact.get(member.MemberId);
            System.debug('contact name==='+relatedContact);
            TeamMemberWrapper wrapper = new TeamMemberWrapper();
            wrapper.memberId = member.Id;
            wrapper.memberName = (relatedContact != null && relatedContact.Name != null) ? relatedContact.Name : 'Unknown Member';
            wrapper.studentStatus = (relatedContact != null && relatedContact.Student_Status__c != null) ? relatedContact.Student_Status__c : 'N/A';
            wrapper.srnNumber = (relatedContact != null && relatedContact.SRN_Number__c != null) ? relatedContact.SRN_Number__c : '';
            wrapper.Attendance = (relatedContact != null && relatedContact.Total_average_current_sem_attendance__c != null) ? relatedContact.Total_average_current_sem_attendance__c.setScale(2) : 0 ;
           // wrapper.userId = (relatedUser != null) ? relatedUser.Id : null;
            //  Only assign userId if this is an Experience user
        if (relatedUser != null && (
            relatedUser.UserType == 'CustomerPortal' ||
            relatedUser.UserType == 'PowerCustomerSuccess' ||
            relatedUser.UserType == 'CSPLitePortal'
        )) {
            wrapper.userId = relatedUser.Id;
            wrapper.loginUrl = baseUrl + '/servlet/servlet.su?oid=' + orgId +
                               '&sunetworkid=' + networkId +
                               '&sunetworkuserid=' + relatedUser.Id;
        } else {
            wrapper.userId = null; // hide login button for internal users
            wrapper.loginUrl = null;
        }

        wrappers.add(wrapper);
            System.debug('Wrappers: ' + wrappers);
    }
            
            return wrappers;
        
        }
      
    @AuraEnabled
    public static void deleteCaseTeamMembers(List<Id> memberIds) {
        try {
            List<CaseTeamMember> membersToDelete = [SELECT Id FROM CaseTeamMember WHERE Id IN :memberIds];
            if (!membersToDelete.isEmpty()) {
                delete membersToDelete;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting case team members: ' + e.getMessage());
        }
    }
}