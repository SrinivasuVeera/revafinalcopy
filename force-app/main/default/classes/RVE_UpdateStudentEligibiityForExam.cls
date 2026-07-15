//Test class for this class is rveupdateChekingEligibilecontactTest
public class RVE_UpdateStudentEligibiityForExam implements Database.Batchable<sObject>{
    public date examdate = system.today().adddays(3);
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([Select Id,Rve_Semester__c,rve_Exam_Start_Date__c,Rve_End_Date__c,Rve_Publish__c,rve_Active__c from Rve_Exam_Notification__c where Rve_Publish__c =true and rve_Active__c =true AND rve_Exam_Start_Date__c <=:examdate and Rve_End_Date__c>=TODAY]);
    }
    public void execute(Database.BatchableContext BC, List<Rve_Exam_Notification__c> notification){
        Map<Id,Contact> IneligibleStudents = new Map<Id, Contact>();
        Map<Id,Contact> EligibleStudents = new Map<Id,Contact>();
        Set<Id> conId = new set<Id>();
        set<Id> inEligibleStudentsSet = new set<Id>();
        List<Contact> updateStudents = new List<Contact>();
        List<Contact> students = [Select Id,Name,Total_average_current_sem_attendance__c,Exam_Approval__c from Contact where Active_Semester__c = :notification[0].Rve_Semester__c AND Active__c = TRUE AND Student_Status__c ='Pursuing' AND Exam_Approval__c = FALSE];
        If(students!=NULL){
                For(Contact student :students){
                conId.add(student.Id);
                If(student.Total_average_current_sem_attendance__c<75){
                    IneligibleStudents.put(student.Id,student);
                    inEligibleStudentsSet.add(student.Id);
                }
            }
            for(Student_Fee__c fee : [select Id,Amount_Pending__c,Contact__c from Student_Fee__c where Contact__c  In :conId AND Amount_Pending__c>0 AND Due_Date__c<=TODAY]){
                If(!inEligibleStudentsSet.contains(fee.Contact__c)){
                    inEligibleStudentsSet.add(fee.Contact__c);
                }
            }
            For(Contact con : students){
                contact student = new Contact();
                If(inEligibleStudentsSet.contains(con.Id)){
                    student.Id = con.Id;
                    student.Checking_Eligibility_for_Exam__c = 'InEligible';
                    updateStudents.add(student);
                }else{
                    student.Id = con.Id;
                    student.Checking_Eligibility_for_Exam__c = 'Eligible';
                    updateStudents.add(student);
                }
            }
            If(updateStudents!=NULL){
                Database.Update(updateStudents,false);
            }
        }
        
    }
    public void finish(Database.BatchableContext BC) {
    }
}