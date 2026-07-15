/**
 * @description       : 
 * @author            : owais.ahanger@cloudodyssey.co
 * @group             : 
 * @last modified on  : 05-31-2024
 * @last modified by  : owais.ahanger@cloudodyssey.co
**/
public class SP_FetchStudentDetailsController {
    @AuraEnabled
    public static Case getMenteeLatestCase() {
        
        try{
			RecordType rt = [SELECT Id FROM RecordType 
                             WHERE SobjectType = 'Case' 
                             AND DeveloperName = 'Mentee' 
                             LIMIT 1];
            
            string contactId=[SELECT ContactId FROM User WHERE Id=:userInfo.getUserId() Limit 1].ContactId;
            
            List<Case> cases = [
                SELECT Id, Subject,Mentor_Name__c,Mentor_Mobile__c
                FROM Case 
                WHERE ContactId = :contactId AND RecordTypeId=:rt.Id ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            
            if (cases.isEmpty()) {
                return null;
            }
            return cases[0];
        }catch(Exception e){ throw new Reva_CustomException('An Errror Occured'+e.getMessage());}
        
    }
    
    
    @AuraEnabled
    public static Case getSupportRequestLatestCase() {
        try{
            RecordType rt = [SELECT Id FROM RecordType 
                             WHERE SobjectType = 'Case' 
                             AND DeveloperName = 'Support_Request' 
                             LIMIT 1];
            string contactId=[SELECT ContactId FROM User WHERE Id=:userInfo.getUserId() Limit 1].ContactId;
            
            List<Case> cases = [
                SELECT Id, CaseNumber, Category__c, Case_Status__c
                FROM Case 
                WHERE ContactId = :contactId
                AND RecordTypeId = :rt.Id
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            
            if (cases.isEmpty()) {
                return null;
            }
            return cases[0];
        }
        catch(exception e){ throw new Reva_CustomException('An Errror Occured'+e.getMessage()); }
        
    }
    
    
    @AuraEnabled
    public static hed__Term__c getNextExamDates() {
        try{
            string contactId=[SELECT ContactId FROM User WHERE Id=:userInfo.getUserId() Limit 1].ContactId;
            String semesterId=[SELECT Active_Semester__c FROM Contact WHERE Id=:contactId Limit 1].Active_Semester__c;
            
            List<hed__Term__c> terms = [
                SELECT IA_1_Start_date__c, IA_2_Start_date__c, Exam_Start_Date__c 
                FROM hed__Term__c 
                WHERE Id = :semesterId
                LIMIT 1
            ];
            if (terms.size()<=0) {
                return null; 
            }
            return terms[0];
        } catch(Exception e){  throw new Reva_CustomException('An Errror Occured '+e.getMessage()); }
        
    }
    
    
    @AuraEnabled (cacheable=true)
    public static Map<String, Boolean> getStudentPortalTileMenuVisibility(){
        try{
            
         List<Student_Portal_Tile_Menu_Visibility_Rule__mdt> metadataRecords = [SELECT Assessment__c, Examination__c, FeesAndPayments__c,MentorOrMentee__c,Placement__c,SupportRequest__c,TimeTable__c FROM Student_Portal_Tile_Menu_Visibility_Rule__mdt LIMIT 1];
         if (metadataRecords.isEmpty()) {
                throw new Reva_CustomException('Custom Metadata-Student Portal Tile Menu Visibility Rule ! Visibility Details Record does not exist');
            }
        Map<String, Boolean> visibilityValues = new Map<String, Boolean>();    
        Student_Portal_Tile_Menu_Visibility_Rule__mdt record = metadataRecords[0];
        
            visibilityValues.put('Assessment', record.Assessment__c);
            visibilityValues.put('Examination', record.Examination__c);
            visibilityValues.put('FeesAndPayments', record.FeesAndPayments__c);
            visibilityValues.put('MentorOrMentee', record.MentorOrMentee__c);
            visibilityValues.put('Placement', record.Placement__c);
            visibilityValues.put('SupportRequest', record.SupportRequest__c);
            visibilityValues.put('TimeTable', record.TimeTable__c);
         return visibilityValues;
        }catch(Exception e){throw new Reva_CustomException('An error occured'+e.getMessage());
        }
       
    }
    
 
    @AuraEnabled(cacheable=true)
    public static Boolean isGuestUser() {
        try{
            return Auth.CommunitiesUtil.isGuestUser();
        }
        catch(Exception e){ throw new Reva_CustomException('An Errror Occured '+e.getMessage()); }
        
    }
}