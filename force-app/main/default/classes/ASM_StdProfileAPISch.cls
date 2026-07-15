global class ASM_StdProfileAPISch  implements Schedulable{
    global void execute(SchedulableContext sc){
        Integer days = Integer.valueOf(Label.StudentMasterScheduleTime);
        Database.executeBatch(new ASM_StdProfileAPIBatch(System.today().addDays(days)),100);
        /*************Added By Veera 05052025******************/
        RveResetStudentExamFieldsBatch batch = new RveResetStudentExamFieldsBatch();
        Database.executeBatch(batch,10); // 200 is the batch size
        
        Database.executeBatch(new RVE_UpdateStudentEligibiityForExam(),1);
         
    }
}