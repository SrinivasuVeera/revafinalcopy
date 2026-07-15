public class QueueableBulkWhatsappNotification  implements System.Queueable , Database.AllowsCallouts {
    Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> localPhoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

    public QueueableBulkWhatsappNotification (Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications){
        localPhoneNumbersToNotifications = phoneNumbersToNotifications;
    } 
    
    public void execute(QueueableContext context){
        System.debug('inside QueueableBulkWhatsappNotification'+localPhoneNumbersToNotifications);
        Yellow_AI_Utility.sendWhatsAppNotifications(localPhoneNumbersToNotifications);
    }
}