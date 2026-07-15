public class InvalidStatusUpdater implements Queueable {
    private Id recordId;
    private String status;
    public InvalidStatusUpdater(Id recordId, String status) {
        this.recordId = recordId;
        this.status = status;
    }
    public void execute(QueueableContext ctx) {
        Reva_Meal_Booking__c record = [
            SELECT Id, Error_Msg_Check__c
            FROM Reva_Meal_Booking__c
            WHERE Id = :recordId
            LIMIT 1 FOR UPDATE
        ];
        if(status == 'Invalid'){
            record.Error_Msg_Check__c = true;
        } else if(status == 'Success'){
            record.Error_Msg_Check__c = false;
        }
        update record;
    }
}