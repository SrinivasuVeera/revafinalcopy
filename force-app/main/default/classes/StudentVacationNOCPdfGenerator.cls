public class StudentVacationNOCPdfGenerator implements Queueable, Database.AllowsCallouts {
    private Id requestId;

    public StudentVacationNOCPdfGenerator(Id requestId) {
        this.requestId = requestId;
    }

    public void execute(QueueableContext context) {
        PageReference pdfPage = Page.StudentVactionNOC;
        pdfPage.getParameters().put('requestId', requestId);
        System.debug('Page Reference: ' + pdfPage);

        Blob pdfBlob;
        try {
            pdfBlob = pdfPage.getContentAsPDF();
            System.debug('PDF Blob size: ' + pdfBlob.size());
        } catch (Exception e) {
            pdfBlob = Blob.valueOf('Error generating PDF');
            System.debug('Error generating PDF: ' + e.getMessage());
        }

        Attachment attachment = new Attachment();
        attachment.ParentId = requestId;
        attachment.Body = pdfBlob;
        attachment.Name = 'HostelVacationNOC.pdf';
        attachment.ContentType = 'application/pdf';
        insert attachment;

        User recipient = [SELECT Id, Email FROM User WHERE Profile.Name = 'Warden' LIMIT 1];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{recipient.Email});
        email.setSubject('Student Hostel Vacation NOC');
        email.setPlainTextBody('Please find attached No Objection Certificate');
        Messaging.EmailFileAttachment attachmentToEmail = new Messaging.EmailFileAttachment();
        attachmentToEmail.setFileName('HostelVacationNOC.pdf');
        attachmentToEmail.setBody(pdfBlob);
        email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachmentToEmail});
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }
}