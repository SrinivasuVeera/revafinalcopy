public class ResetPasswordSendEmail {

    @InvocableMethod
    public static List<String> sendEmail(List<EmailTemplateInput> emailInputs) {
        List<String> returnList = new List<String>();
        for (EmailTemplateInput emailInput : emailInputs) {
            List<Contact> conList = [Select id, name, email From Contact where id =: emailInput.contactId];
            if(conList.size() > 0){
                List<User> applicantList = [Select id, username, email FROM User WHERE email =: conList[0].email];
                if(applicantList.size() > 0){
                    System.resetpassword(applicantList[0].id,true);
                } else {
                    returnList.add('User is not available');
                    return returnList;
                }
            } else {
                returnList.add('Contact is not available');
                return returnList;
            }
        }
        return returnList;
    }

    public class EmailTemplateInput {
        @InvocableVariable(label='Contact ID' required=true)
        public Id contactId;
    }

}