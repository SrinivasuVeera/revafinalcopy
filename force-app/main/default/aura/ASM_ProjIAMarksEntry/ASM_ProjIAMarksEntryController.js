({
	doInit : function(component, event, helper) {
        helper.doInitHpr(component, event, helper);
    },
    calcTotal : function(component, event, helper) {
        helper.calcTotalHpr(component, event, helper);
    },
    saveIaMarks : function(component, event, helper) {
        helper.saveIaMarksHpr(component, event, helper);
    },
    backToList : function(component, event, helper) {
        helper.fireRefEvent(component, event, helper);
    },
    downloadAsPDF: function(component, event, helper) {
        try {
            var prfConId = component.get("v.profCrsConId");
            var iaType = component.get("v.iaType");
            if (!prfConId || !iaType) {
                throw new Error('Required parameters are missing.');
            }

            // Construct the URL for the Visualforce page
            var vfPageUrl = '/apex/IAMarksEntryPDF?prfConId=' + encodeURIComponent(prfConId) + '&iaType=' + encodeURIComponent(iaType);
            
            // Open the URL in a new window/tab to trigger the PDF download
            window.open(vfPageUrl, '_blank');

            helper.showToast(component, 'dismissible', 'Success', 'PDF download initiated.', 'success');
        } catch (error) {
            console.error('Error initiating PDF download:', error);
            helper.showToast(component, 'dismissible', 'Error', 'Failed to initiate PDF download: ' + error.message, 'error');
        }
    }
})