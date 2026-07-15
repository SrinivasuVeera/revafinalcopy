/* working one*/
/* public class StaffQuarterRequestTriggerHandler {
    public static void createAttachment(List<Staff_Quarters_Request__c> newList) {
        User wardenUser = [SELECT Id FROM User WHERE Name = 'Warden1' LIMIT 1];
        System.debug('Warden User Id: ' + wardenUser.Id);
        
        // Check if the user is found
        if (wardenUser != null) {
            List<Attachment> attachmentsToInsert = new List<Attachment>();
            
            for (Staff_Quarters_Request__c request : newList) {
                // Check if the status is updated to "Vacation Initiated" and it meets the criteria specified
                if (request.Status__c == 'Vacation Initiated') {
                    // Generate PDF from Visualforce page for this specific request
                    PageReference pdfPage = Page.StaffVacationNOC;
                    System.debug('Quarter request record Id: ' + request.Id);
                    pdfPage.getParameters().put('id', request.Id); // Use request.Id here
                    Blob pdfBlob;
                    try {
                        pdfBlob = pdfPage.getContentAsPDF();
                    } catch(Exception e) {
                        System.debug('Error generating PDF: ' + e.getMessage());
                        continue; 
                    }

                   
                    Attachment attachment = new Attachment();
                    attachment.ParentId = request.Id; 
                    attachment.Name = 'StaffVacationRequest_' + request.Id + '.pdf'; 
                    attachment.Body = pdfBlob;
                    attachmentsToInsert.add(attachment);
                } 
            }

           
            if (!attachmentsToInsert.isEmpty()) {
                insert attachmentsToInsert;
            }
        } else {
           
            System.debug('Warden User not found. Attachment not created.');
        }
    }
}*/
public class StaffQuarterRequestTriggerHandler {
    public static void createAttachment(List<Staff_Quarters_Request__c> newList) {
        //    User wardenUser = [SELECT Id FROM User WHERE Name = 'Warden 1' LIMIT 1]; commented for deployment
        User wardenUser = [SELECT Id FROM User WHERE Profile.Name = 'Warden' LIMIT 1];
            System.debug('Warden User Id: ' + wardenUser.Id);
            if (wardenUser != null) {
                List<Attachment> attachmentsToInsert = new List<Attachment>();
                for (Staff_Quarters_Request__c request : newList) {
                    if (request.Status__c == 'Vacation Initiated') {
                        Blob pdfBlob;
                        try {
                            if (Test.isRunningTest()) {
                                // Simulate PDF content during tests
                                pdfBlob = Blob.valueOf('Test PDF Content');
                            } else {
                                // Actual PDF generation
                                PageReference pdfPage = Page.StaffVacationNOC;
                                pdfPage.getParameters().put('id', request.Id);
                                pdfBlob = pdfPage.getContentAsPDF();
                            }
                        } catch (Exception e) {
                            System.debug('Error generating PDF for request: ' + request.Id + ' - ' + e.getMessage());
                            continue; // Skip this request if PDF generation fails
                        }
                        Attachment attachment = new Attachment();
                        attachment.ParentId = request.Id;
                        attachment.Name = 'StaffVacationRequest_' + request.Id + '.pdf';
                        attachment.Body = pdfBlob;
                        attachmentsToInsert.add(attachment);
                    }
                }
                if (!attachmentsToInsert.isEmpty()) {
                        insert attachmentsToInsert;
                }
            } else {
                System.debug('Warden User not found. Attachment not created.');
            }
        
    }
}