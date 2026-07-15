Global class AutoApproveClassAdjustmentschedule  implements Schedulable
{
    Global void execute(SchedulableContext sc) 
    {
        //  Instantiate batch class 
        AutoApproveClassAdjustmentBatch autoUpdate = new AutoApproveClassAdjustmentBatch();
        Database.Executebatch(autoUpdate,200);
    }
}