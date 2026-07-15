@RestResource(urlMapping='/GrayQuestWebhook/*')
global without sharing class FEE_GrayQuestWebhookHandler {

    @HttpPost
    global static Map<String, String> handleNotification() {
        RestRequest req = RestContext.request;
        String jsonBody = (req != null && req.requestBody != null) ? req.requestBody.toString() : '';

        try {
            if(String.isNotBlank(jsonBody)) {
                Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);                
                
                GrayQuest_Webhook_Event__e evt = new GrayQuest_Webhook_Event__e();
                evt.Reference_Id__c = String.valueOf(root.get('reference_id'));
                evt.Event_Name__c = String.valueOf(root.get('event'));

                if(root.containsKey('application_details')) {
                    Map<String, Object> app = (Map<String, Object>)root.get('application_details');
                    evt.Transaction_Id__c = String.valueOf(app.get('code'));
                    evt.Payment_Method__c = 'EMI';
                    evt.GQ_ID__c = String.valueOf(app.get('ID'));
                } else if(root.containsKey('payment_details')) {
                    Map<String, Object> pay = (Map<String, Object>)root.get('payment_details');
                    evt.Transaction_Id__c = String.valueOf(pay.get('code'));
                    evt.Payment_Method__c = String.valueOf(pay.get('method'));
                    evt.GQ_ID__c = String.valueOf(pay.get('ID'));
                }

                EventBus.publish(evt);
            }
        } catch (Exception e) {
            System.debug('GQ Webhook Error: ' + e.getMessage());
        }

        Debug_Log__c dblog = new Debug_Log__c(
            Class_Name__c = 'FEE_GrayQuestWebhookHandler',
            Processing_API_Name__c = 'GrayQuest',
            Data_Received__c = jsonBody,
            Status__c = 'Success'
        );
        Database.insert(dblog, false); 

        return new Map<String, String>{'status' => 'success'};
    }
}