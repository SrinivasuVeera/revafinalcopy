public class rve_ConvocationQR_PDFController {
  @InvocableMethod(label='Call batch apex to Send Convocation Email Notification' description='Calls batch apex to send convocation email notifications to the specified contacts')
    public static void sendEmailNotification(List<List<Contact>> contactIds) {
        // Instantiate the batch class with contactIds parameter
        rve_ConvocationEmailNotification batchJob = new rve_ConvocationEmailNotification(contactIds);
        
        // Execute the batch job
        Database.executeBatch(batchJob,20);
    }

  @AuraEnabled
public static String updateIsPresent(String SRN_Number) {
  try {
    if (String.isNotBlank(SRN_Number)) {
      List<Contact> studentConvocationAttendance = [
        SELECT Id, rve_Present_for_Convocation__c , SRN_Number__c
        FROM Contact
        WHERE
          Contact.SRN_Number__c = :SRN_Number
        LIMIT 1
      ];

      if (!studentConvocationAttendance.isEmpty() ) {
        if(studentConvocationAttendance[0].rve_Present_for_Convocation__c == FALSE){
          studentConvocationAttendance[0].rve_Present_for_Convocation__c = true;
          update studentConvocationAttendance;
          return 'true';
        
      } else if (studentConvocationAttendance[0].rve_Present_for_Convocation__c == true) {
        return 'neutral';
      }
    }

      else {
      return 'false';
    }

    // Add a default return statement outside the if conditions
    return 'false';
  }

  else {
                return 'false'; // Return 'false' if SRN_Number is blank
            }

  } catch (Exception e) {
    
    // Return an error message
    return e.getMessage();
  }
}
}