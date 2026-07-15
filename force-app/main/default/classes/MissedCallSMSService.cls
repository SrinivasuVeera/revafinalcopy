public class MissedCallSMSService {

    public static final String MISSED_CALL_TEMPLATE =
        'Hi Applicant, Thanks for your interest in REVA University. Our Admission counselor will contact you soon. Connect with us on WhatsApp: https://wa.me/919021190211 -REVA University';

    @InvocableMethod(label='Send SMS for Missed Call')
    public static void sendSMS(List<String> phoneNumbers) {

        if(phoneNumbers != null && !phoneNumbers.isEmpty()){
            sendSMSFuture(phoneNumbers);
        }
    }

    @future(callout=true)
    public static void sendSMSFuture(List<String> phoneNumbers) {

        List<SMS_API_Utility.shortMessageWrp> lstShortMsg =
            new List<SMS_API_Utility.shortMessageWrp>();

        for(String phone : phoneNumbers){

            if(String.isNotBlank(phone)){

                phone = phone.replaceAll('[^0-9]', '');
                while(phone.startsWith('91') && phone.length() > 10){
                    phone = phone.substring(2);
                }

                if(phone.length() > 10){
                    phone = phone.right(10);
                }

                if(phone.length() != 10){
                    System.debug('Invalid mobile number skipped: ' + phone);
                    continue;
                }

                SMS_API_Utility.shortMessageWrp msg =
                    new SMS_API_Utility.shortMessageWrp();

                msg.recipient = '+91' + phone;

                msg.message = MISSED_CALL_TEMPLATE;

                System.debug('Final Recipient: ' + msg.recipient);

                lstShortMsg.add(msg);
            }
        }

        if(!lstShortMsg.isEmpty()){

            System.debug('Sending SMS count: ' + lstShortMsg.size());

            SMS_API_Utility.SendSMSOneToMany(
                'Missed Call Alert',
                lstShortMsg
            );
        }
    }
}