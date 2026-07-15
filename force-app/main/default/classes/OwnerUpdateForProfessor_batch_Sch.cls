global class OwnerUpdateForProfessor_batch_Sch implements Schedulable {

    global void execute (SchedulableContext sc)
    {
         OwnerUpdateForProfessor_batch sch = New OwnerUpdateForProfessor_batch();
         Database.executeBatch(sch,1);
    }
}