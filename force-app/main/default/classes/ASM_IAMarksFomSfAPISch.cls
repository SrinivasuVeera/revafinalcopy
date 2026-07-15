global class ASM_IAMarksFomSfAPISch  implements Schedulable{
    global void execute(SchedulableContext sc){
        Integer days = Integer.valueOf(Label.ASM_IAMarksAPIDays);
        Database.executeBatch(new ASM_IAMarksFomSfAPIBatch(System.today().addDays(days)), 1);
    }
}