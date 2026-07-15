global class ASM_StdSubjectAPISch  implements Schedulable{
    global void execute(SchedulableContext sc){
        Integer days = Integer.valueOf(Label.ASM_StdSubAPIDay);
        Database.executeBatch(new ASM_StdSubjectAPIBatch(System.today().addDays(days)), 1);
    }
}