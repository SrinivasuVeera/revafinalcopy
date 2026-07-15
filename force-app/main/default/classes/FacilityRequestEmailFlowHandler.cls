public class FacilityRequestEmailFlowHandler {
    

    @InvocableMethod(label='Send Facility Request Emails to Facility Contacts'
                     description='Sends email notifications to Facility Contacts for approved Facility Requests.')
    public static void sendEmails(List<IdWrapper> requestIds) {
        if (requestIds == null || requestIds.isEmpty()) return;

        List<Id> facilityRequestIds = new List<Id>();
        for (IdWrapper wrapper : requestIds) {
            if (wrapper.requestId != null) {
                facilityRequestIds.add(wrapper.requestId);
            }
        }

        // Avoid callouts during test execution
        if (!Test.isRunningTest()) {
            FacilityRequestEmailHandler.sendEmails(facilityRequestIds);
        }
        else {
            // Optionally, you can add debug or alternative logic for tests
            System.debug('Test context detected, skipping callouts.');
        }
    }

    public class IdWrapper {
        @InvocableVariable(label='Facility Request Id')
        public Id requestId;
    }
}