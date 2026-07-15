global class HallTicketQRDailyScheduler implements Schedulable {

    /**
     * Description  : Scheduler class to run HallTicketQRStudRoomAllotmntBatch
     *                daily at 2:34 AM, passing today's date automatically.
     * 				  which will create a records in HallTicketQR object.
     * 				  Post scanning qr code from hallticket, these records get updated with scanned by,exam date,
     * 				  start time, end time, scanned time
     * Developer    : Santoshkumar Bangarimath
     * 
     */

    global void execute(SchedulableContext sc) {

        Date todayDate = Date.today();

        HallTicketQRStudRoomAllotmntBatch1 batch =
            new HallTicketQRStudRoomAllotmntBatch1(                
                todayDate
            );

        Database.executeBatch(batch, 200);
    }
}