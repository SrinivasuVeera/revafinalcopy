public class PublisherLeadValidationTriggerHandler {

    
    // =========================================
    // Main Method Called From Trigger
    // =========================================
    public static void validatePublisherLeads(
        List<Lead> leadList
    ){

        List<Lead> publisherLeads = getPublisherLeads(
            leadList
        );

        if(!publisherLeads.isEmpty()){

            validateSchoolAndProgram(
                publisherLeads
            );
        }
    }


    // =========================================
    // Filter Publisher Leads
    // =========================================
 /*   private static List<Lead> getPublisherLeads(
        List<Lead> leadList
    ){

        List<Lead> publisherLeads =
            new List<Lead>();

        Set<Id> ownerIds = new Set<Id>();


        // Collect Owner Ids
        for(Lead ld : leadList){

            if(ld.OwnerId != null){

                ownerIds.add(ld.OwnerId);
            }
        }


        // Query Users
        Map<Id, User> ownerMap =
            new Map<Id, User>(

            [
                SELECT Id,
                       Profile.Name
                FROM User
                WHERE Id IN :ownerIds
            ]
        );


        // Filter Publisher Leads
        for(Lead ld : leadList){

            User ownerUser =
                ownerMap.get(ld.OwnerId);

            if(
                ownerUser != null &&
                ownerUser.Profile.Name ==
                'Reva Publisher'
            ){

                publisherLeads.add(ld);
            }
        }

        return publisherLeads;
    }*/

private static List<Lead> getPublisherLeads(
    List<Lead> leadList
){

    List<Lead> publisherLeads =
        new List<Lead>();

    Set<Id> ownerIds = new Set<Id>();


    // Collect Owner Ids
    for(Lead ld : leadList){

        if(ld.OwnerId != null){

            ownerIds.add(ld.OwnerId);
        }
    }


    // Query Users
    Map<Id, User> ownerMap =
        new Map<Id, User>(

        [
            SELECT Id,
                   Profile_Name__c
            FROM User
            WHERE Id IN :ownerIds
        ]
    );


    // Filter Publisher Leads
    for(Lead ld : leadList){

        User ownerUser =
            ownerMap.get(ld.OwnerId);
        system.debug('ownerUser:'+ownerUser);
        system.debug('ownerUser.Profile_Name__c:'+ownerUser.Profile_Name__c);
        if(
            ownerUser != null &&
            ownerUser.Profile_Name__c ==
            'Reva Publisher'
        ){

            publisherLeads.add(ld);
        }
    }

    return publisherLeads;
}



    // =========================================
    // Validate School & Program
    // =========================================
    Public static void validateSchoolAndProgram(
        List<Lead> leadList
    ){

        Set<String> schoolSet =
            new Set<String>();

        Set<String> programSet =
            new Set<String>();


        // Collect values
        for(Lead ld : leadList){

            if(String.isNotBlank(ld.School__c)){

                schoolSet.add(
                    ld.School__c
                    .trim()
                    .toLowerCase()
                );
            }

            if(String.isNotBlank(
                ld.Program_Name_Display__c
            )){

                programSet.add(
                    ld.Program_Name_Display__c
                    .trim()
                    .toLowerCase()
                );
            }
        }


        // Query Fee Masters
        List<Fee_Master__c> feeMasterList = [

            SELECT Id,
                   School_Name__c,
                   Program_Name_Display__c
            FROM Fee_Master__c
            WHERE IsActive__c = true
            AND Program_Name_Display__c
                IN :programSet
            AND Fee_Type__c =
                'Application Fee'
        ];


        // Create Valid Map
        Map<String, Fee_Master__c> feeMap =
            new Map<String, Fee_Master__c>();


        for(Fee_Master__c fm :
            feeMasterList){

            if(String.isBlank(fm.School_Name__c) || String.isBlank( fm.Program_Name_Display__c) ){
                continue;
            }


            for(String schoolName :schoolSet){

                if(fm.School_Name__c.toLowerCase().contains(schoolName)){
                    String key =schoolName +'###' +fm.Program_Name_Display__c.trim().toLowerCase();
                    feeMap.put(key, fm);
                }
            }
        }


        // Validate Leads
        for(Lead ld : leadList){

            if( String.isBlank(ld.School__c) || String.isBlank(ld.Program_Name_Display__c)){
                continue;
            }

            String key = ld.School__c.trim().toLowerCase()+'###' +ld.Program_Name_Display__c.trim().toLowerCase();

            if(!feeMap.containsKey(key)){
                ld.addError(
                    'Invalid School and Program combination.'
                );
            }
        }
    }
}