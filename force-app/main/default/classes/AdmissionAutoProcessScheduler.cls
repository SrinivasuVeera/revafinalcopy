global class AdmissionAutoProcessScheduler implements Schedulable {
    
   // String cron = '0 0 1 * * ?';

//System.schedule('Admission Auto Process', cron,new AdmissionAutoProcessScheduler());

    global void execute(SchedulableContext sc) {

        Database.executeBatch(
            new AdmissionAutoProcessBatch(),
            200
        );

    }

}