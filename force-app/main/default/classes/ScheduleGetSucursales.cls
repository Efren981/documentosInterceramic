public class ScheduleGetSucursales implements System.Schedulable {

    public void execute(SchedulableContext ctx){
        System.enqueueJob(New QueueableGetSucursales());
    }

}