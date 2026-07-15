public class SAPAPIQueueableHandler {
    public class FacultyMasterCreationQueueable implements Queueable,Database.AllowsCallouts {
        private List<Id> facultyIds;
        
        public FacultyMasterCreationQueueable(List<Id> facultyIds) {
            this.facultyIds = facultyIds;
        }
        
        public void execute(QueueableContext context) {
            SAP_FacultyMasterCreationAPI.FacultyMasterCreationMethod(facultyIds);
        }
    }
    
    public class SchoolMasterCreationQueueable implements Queueable,Database.AllowsCallouts  {
        private List<Id> schoolIds;
        
        public SchoolMasterCreationQueueable(List<Id> schoolIds) {
            this.schoolIds = schoolIds;
        }
        
        public void execute(QueueableContext context) {
            SAP_SchoolMasterCreationAPI.SchoolMasterCreationMethod(schoolIds);
        }
    }
    
    public class ProgramMasterCreationQueueable implements Queueable,Database.AllowsCallouts {
        private List<Id> programIds;
        
        public ProgramMasterCreationQueueable(List<Id> programIds) {
            this.programIds = programIds;
        }
        
        public void execute(QueueableContext context) {
            SAP_ProgramMasterCreationAPI.ProgramMasterCreationMethod(programIds);
        }
    }
    
}