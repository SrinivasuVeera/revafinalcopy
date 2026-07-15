public class SFMC_Lead_Email_Queueable implements Queueable, Database.AllowsCallouts {

    List<Id> leadIds;

    public SFMC_Lead_Email_Queueable(List<Id> leadIds){
        this.leadIds = leadIds;
    }

    public void execute(QueueableContext qc){

        List<Lead> leads = [
            SELECT Id, Name, Email, MobilePhone, Program_Name_Display__c
            FROM Lead
            WHERE Id IN :leadIds
        ];

        Map<String, SFMC_Email_Config__c> configMap = new Map<String, SFMC_Email_Config__c>();

        // Load configs
        for(SFMC_Email_Config__c cfg : [
            SELECT Id, Account__r.Name, Customer_Key__c, Definition_Key__c, Active__c
            FROM SFMC_Email_Config__c
            WHERE Active__c = true
        ]){
            configMap.put(cfg.Account__r.Name, cfg);
        }

        List<SFMC_Email_Config__c> updateList = new List<SFMC_Email_Config__c>();

        for(Lead l : leads){

            if(String.isBlank(l.Program_Name_Display__c)) continue;
            if(!configMap.containsKey(l.Program_Name_Display__c)) continue;

            SFMC_Email_Config__c cfg = configMap.get(l.Program_Name_Display__c);

            String defKey = cfg.Definition_Key__c;

            // CREATE DEFINITION
            if(String.isBlank(defKey)){

                defKey = 'auto_' + l.Program_Name_Display__c.replace(' ','_') + '_' + Datetime.now().getTime();

                Boolean created = SFMC_Definition_Service.createDefinition(
                    defKey,
                    cfg.Customer_Key__c
                );

                if(created){
                    cfg.Definition_Key__c = defKey;
                    updateList.add(cfg);

                    // Prevent duplicate creation
                    configMap.put(l.Program_Name_Display__c, cfg);
                } else {
                    continue;
                }
            }

            //SEND EMAIL
            SFMC_Send_Email_Service.sendEmail(
                defKey,
                l.Email,
                l.MobilePhone,
                l.Name
            );
        }

        if(!updateList.isEmpty()){
            update updateList;
        }
    }
}