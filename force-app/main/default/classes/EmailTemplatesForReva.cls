public class EmailTemplatesForReva {

public static String sendIAMarksEntryEmailtoFaculty2(hed__Course_Offering__c courseDetails,string examname,string formattedDate) {
        String body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Marks Entry Reminder</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear ' + courseDetails.hed__Faculty__r.Name + ',</p>' +
                      '<p>Greetings of the day!</p>' +
                      '<p>This is to inform you to update the ' + examname + ' marks for the below mentioned Course details before ' + formattedDate + '.</p>' +
                      '<p>Program Batch- ' + courseDetails.hed__Term__r.Program_Batch__r.Name + '<br>' +
                      'Semester- ' + courseDetails.hed__Term__r.Name + '<br>' +
                      'Section- ' + courseDetails.Section_Name__c + '<br>' +
                      'Course ID- ' + courseDetails.hed__Course__r.hed__Course_ID__c+ '</p>' +
                      '<p>Please find the attachment of the manual for entering the marks.</p>' +
                      '<p>Thank You &amp; Warm regards,</p>' +
                      '<p>REVA University</p>' +
                      '</body>' +
                      '</html>';       
        return body;
    }
    
    
  public static String sendPushCourseOffering3(hed__Course_Offering__c courseDetails,string formattedDate1) {
    String body = '<!DOCTYPE html>' +
                  '<html>' +
                  '<head>' +
                  '<meta charset="utf-8">' +
                  '<title>Course Offering Reminder</title>' +
                  '</head>' +
                  '<body>' +
                  '<p>Dear ' + courseDetails.Offered_By_School__r.Vertical_Head__r.name + ',</p>' +
                  '<p>Greetings of the day!</p>' +
                  '<p>This is a gentle reminder to push the approved course offerings for the Semester- ' + courseDetails.hed__Term__r.name + ' to Logisys before ' + formattedDate1 + '.</p>' +
                  '<p><b><u>Note: Please check the details of all the courses before pushing it to Logisys. Once the course master is pushed to Logisys, there will be no option to edit the course details.</u></b></p>' +
                  '<p>Thank You &amp; Warm regards,</p>' +
                  '<p>REVA University</p>' +
                  '</body>' +
                  '</html>';       
    return body;
}

    

 public static String sendIATimeTableCreationEmail4(String verticalHead, String examName, String semesterName, String tenDaysBeforeExamDate) {
        String subject = 'Reminder: Create ' + examName + ' timetable for ' + semesterName;
     system.debug('inside email body');
        String body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Timetable Creation Reminder</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear ' + verticalHead + ',</p>' +
                      '<p>Greetings of the day!</p>' +
                      '<p>This is a gentle reminder to create and publish the ' + examName + ' Timetable for the Theory and Practical courses for the semester: ' + semesterName + ' before ' + tenDaysBeforeExamDate + '.</p>' +
                      '<p>Please find the attachment of the manual for creating a ' + examName + ' Timetable.</p>' +
                      '<p>Thank You &amp; Warm regards,</p>' +
                      '<p>REVA University</p>' +
                      '</body>' +
                      '</html>';   
     system.debug('return body');
        return body;
 }

public static String sendHallTicketEmailtoEligibleStudent7(String studentName, String examName, String studentPortalLink) {
        String subject = 'Download your Hall ticket for ' + examName;
        String body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Hall Ticket Download Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear ' + studentName + ',</p>' +
                      '<p>Greetings of the day!</p>' +
                      '<p>The Hall Ticket for ' + examName + ' has been published in your Student Portal.</p>' +
                      '<p>Please login to your Student Portal using the below URL and download the Hall ticket.</p>' +
                       '<p><a href="https://reva-university--codev1.sandbox.my.site.com/StudentPortal">' + studentPortalLink + '</a></p>'  +
                      '<p>Thank You &amp; Warm regards,</p>' +
                      '<p>REVA University</p>' +
                      '</body>' +
                      '</html>';      
        return body;
    }

 public static String sendHallTicketPublishEmailtoParent8(String parentName, String semesterName, String examName) {
        String subject = 'Hall ticket Published for ' + examName;
        String body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Hall Ticket Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear Mr./Ms. ' + parentName + ',</p>' +
                      '<p>Hope this message finds you well. This is to inform you that the Hall Ticket for your ward has been published for ' + semesterName + ' ' + examName + '.</p>' +
                      '<p>Thank You &amp; Warm regards,</p>' +
                      '<p>REVA University</p>' +
                      '</body>' +
                      '</html>';       
        return body;
    }


public static String sendInEligibleHallTicketEmailtoStudent9(String studentName, String examName) {
        String subject = 'Ineligible to download the Hall ticket for ' + examName;
        String body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Ineligibility Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear ' + studentName + ',</p>' +
                      '<p>This is to inform you that due to ineligibility you are restricted from downloading your Hall Ticket for ' + examName + '.</p>' +
                      '<p>Please contact your School Director.</p>' +
                      '<p>Thank You &amp; Warm regards,</p>' +
                      '<p>REVA University</p>' +
                      '</body>' +
                      '</html>';       
        return body;
    }

public static String sendInEligibleHallTicketEmailtoParent10(String parentName, String studentName, String examName) {
        String subject = 'Ineligible to download the Hall ticket for ' + examName;
        String body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Ineligibility Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear Mr./Ms. ' + parentName + ',</p>' +
                      '<p>Hope this email finds you well. We regret to inform you that due to ineligibility your ward ' + studentName + ' is restricted from downloading the Hall Ticket for ' + examName + '.</p>' +
                      '<p>To address this situation please contact your ward\'s mentor.</p>' +
                      '<p>Thank You &amp; Warm regards,</p>' +
                      '<p>REVA University</p>' +
                      '</body>' +
                      '</html>';       
        return body;
    }


    public static String sendAbsentEmailforStudent15(String studentName, String courseName, String examName, String date1, String startTime, String endTime) {
        String subject = 'Marked absent for ' + courseName + '-' + examName + ' scheduled on ' + date1 + ', ' + startTime + ' - ' + endTime + '.';
        String body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Absence Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear ' + studentName + ',</p>' +
                      '<p>Hope this message finds you well. You have been marked absent for the ' + courseName + ' - ' + examName + ' scheduled on ' + date1 + ' at ' + startTime + ' - ' + endTime + '.</p>' +
                      '<p>Thank You &amp; Warm regards,</p>' +
                      '<p>REVA University</p>' +
                      '</body>' +
                      '</html>';       
        return body;
    }

    public static String sendAbsentEmailforParent16(String parentName, String studentName, String courseName, String examName, String date1, String startTime, String endTime) {
        String subject = 'Your ward is marked absent for ' + courseName + ' ' + examName + ' scheduled on ' + date1 + ', ' + startTime + ' - ' + endTime + '.';
        String body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Absence Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear Mr./Ms. ' + parentName + ',</p>' +
                      '<p>Hope this email finds you well. This is to inform you that your ward ' + studentName + ' has been marked absent for the ' + courseName + ' ' + examName + ' scheduled on ' + date1 + ' from ' + startTime + ' to ' + endTime + '. We wanted to bring this to your attention promptly.</p>' +
                      '<p>Thank You &amp; Warm regards,</p>' +
                      '<p>REVA University</p>' +
                      '</body>' +
                      '</html>';       
        return body;
    }
public static String sendAbsentEmailtoMentor18(String mentorName, String menteeName, String srn, String examName, String courseName, String date1, String startTime, String endTime) {
        String subject = 'Absent for the ' + examName;
        String body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Absence Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear ' + mentorName + ',</p>' +
                      '<p>Greetings of the day!</p>' +
                      '<p>This is to inform you that your mentee ' + menteeName + ', ' + srn + ' was marked absent for ' + examName + ' for the course ' + courseName + ' conducted on ' + date1 + ' from ' + startTime + ' to ' + endTime + '.' +
                      '<p>Kindly interact with your mentee and inform them to attend the exam without fail.</p>' +
                      '<p>Thank You &amp; Warm regards,</p>' +
                      '<p>REVA University</p>' +
                      '</body>' +
                      '</html>';       
        return body;
    }

    public static String sendMallPraticeEmailtoMentor19(String mentorName, String menteeName, String srn, String examName, String courseName, String date1, String startTime, String endTime) {
        String subject = 'Notification on malpractice incident';
        String body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Malpractice Incident Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear ' + mentorName + ',</p>' +
                      '<p>Greetings of the day!</p>' +
                      '<p>This is to inform you that your mentee ' + menteeName + ', ' + srn + ' was disbarred from the ' + examName + ' exam for the course ' + courseName + ' conducted on ' + date1 + ' from ' + startTime + ' to ' + endTime + '.' +
                      '<p>The student was caught engaging in malpractice during the exam.</p>' +
                      '<p>Thank You &amp; Warm regards,</p>' +
                      '<p>REVA University</p>' +
                      '</body>' +
                      '</html>';       
        return body;
    }
 public static String sendMallPraticeEmailtoParent20(String parentName, String studentName, String exam, String courseName, String date1, String startTime, String endTime) {
        String subject = 'Notification on malpractice Incident';
        String body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Malpractice Incident Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear Mr./Ms. ' + parentName + ',</p>' +
                      '<p>Greetings of the day!</p>' +
                      '<p>Hope this email finds you well. We regret to inform you that your ward ' + studentName + ' was disbarred from the ' + exam + ' for the course ' + courseName + ' conducted on ' + date1 + ' from ' + startTime + ' to ' + endTime + '.' +
                      '<p>The student was caught engaging in malpractice during the exam.</p>' +
                      '<p>Thank You &amp; Warm regards,</p>' +
                      '<p>REVA University</p>' +
                      '</body>' +
                      '</html>';       
        return body;
    }
    public static string IASEEAbsentAttendanceNotificationForParents(string parentname, string studentname, string coursename, string examname, string examdate, string starttime, string endtime){
        String subject = 'Your ward is marked absent for {{coursename}} {{examname}} scheduled on {{date}}, {{starttime}} - {{endtime}}.';
        string body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Malpractice Incident Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear Mr./Ms. '+parentname+',</p>'+
                      '<p>Hope this email finds you well. This is to inform you that your ward '+studentname+' has been marked absent for the '+coursename+' ' +examname+' scheduled on '+examdate+' from '+starttime+' to '+endtime+'. We wanted to bring this to your attention promptly.'+
                      '<p>Thank You &amp; Warm regards,</p>'+
                      '<p>REVA University</p>'+
                      '</body>' +
                      '</html>';   
        return body;
    }
    Public static string AbsentAttendnaceToMentor(string mentorname, string menteename,string SRN,string examname, string coursename, string examdate, string starttime, string endtime){
        String Subject ='Absent for the {{examname}}';
        string body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Malpractice Incident Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear '+mentorname+',</p>'+
                      '<p>Greetings of the day!</p>'+
                      '<p>This is to inform you that your mentee '+menteename+', '+SRN+' was marked absent for '+examname+' for the course '+coursename+' conducted on '+examdate+' from '+starttime+' to '+endtime+'.</p>'+
                      '<p>Kindly interact with your mentee and inform them to attend the exam without fail.</p>'+
                      '<p>Thank You & Warm regards,</p>'+
                      '<p>REVA University</p>';

        return body;
    }
    Public static string IASEEAbsentAttendanceNotificationForStudents(string studentname, string examname,string coursename,  string examdate, string starttime, string endtime){
        String subject = 'Marked absent for {{coursename}}-{{examname}} scheduled on {{Examdate}}, {{starttime}} - {{Endtime}}.';
        string body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Malpractice Incident Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear '+studentname+',</p>'+
                      '<p>Hope this email finds you well. You have been marked absent for the '+coursename+'- ' +examname+' scheduled on '+examdate+' from '+starttime+' to '+endtime+'.'+
                      '<p>Thank You &amp; Warm regards,</p>'+
                      '<p>REVA University</p>'+
                      '</body>' +
                      '</html>';   
        return body;
    }
    Public static string ExamApplicationFormEmailNotificationToStudnets(string studentname, string semestername, string ThirtydaysbrforetheExamstartdate){
        string siteURL;
        If(!Test.isRunningTest()){
            Network myNetwork = [SELECT Id FROM Network WHERE Name ='StudentPortal' ];
           ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
            siteURL =myCommunity.siteUrl;
        }else{
            siteURL='URL not found';
        }
        
        System.debug('MyDebug : ' +siteURL );
        String subject = 'Semester End Exam Application Form is LIVE for the {{semestername}}';
        string body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Semester Examination	 Notification</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear '+studentname+',</p>'+
                      '<p>Greetings of the day!</p>'+
                      '<p>The Semester End Exam Application form is LIVE for '+semestername+'. ' +
                      '<p>Kindly login to your student portal to fill the form and pay the examination fee before the last date '+ThirtydaysbrforetheExamstartdate+
                      '<p>Student Portal Link: <a href=siteURL>' + siteURL + '</a></p>' +
                      '<p>Thank You &amp; Warm regards,</p>'+
                      '<p>REVA University</p>'+
                      '</body>' +
                      '</html>'; 
        system.debug('emailbody>>' + body);
        return body;
    }
    
     Public static string results21(string studentname, string semestername){
        string siteURL;
        If(!Test.isRunningTest()){
            Network myNetwork = [SELECT Id FROM Network WHERE Name ='StudentPortal' ];
           ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
            siteURL =myCommunity.siteUrl;
        }else{
            siteURL='URL not found';
        }
        
        System.debug('MyDebug : ' +siteURL );
        String subject = 'Semester End Exam Application Form is LIVE for the {{semestername}}';
        string body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Results</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear '+studentname+',</p>'+
                      '<p>Greetings of the day!</p>'+
                      '<p>Please be informed that the results of '+semestername+' has been published. ' +
                      '<p>Kindly login to your Student Portal for more details.'+
                      '<p>Student Portal Link: <a href=siteURL>' + siteURL + '</a></p>' +
                      '<p>Thank You &amp; Warm regards,</p>'+
                      '<p>REVA University</p>'+
                      '</body>' +
                      '</html>';   
        return body;
    }
    
    
    Public static string results22(string studentname, string semestername, string parentname){

        string body = '<!DOCTYPE html>' +
                      '<html>' +
                      '<head>' +
                      '<meta charset="utf-8">' +
                      '<title>Results</title>' +
                      '</head>' +
                      '<body>' +
                      '<p>Dear Mr./Ms. '+parentname+',</p>'+
                      '<p>Greetings of the day!</p>'+
                      '<p>Hope this message finds you well. Please be informed that the results of '+semestername+ ' for your ward '+studentname+'has been published. We encourage to take some time and review the results.' +
                      '<p>Thank You &amp; Warm regards,</p>'+
                      '<p>REVA University</p>'+
                      '</body>' +
                      '</html>';   
        return body;
    }
}