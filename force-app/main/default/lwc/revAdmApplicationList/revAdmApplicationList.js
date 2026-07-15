import { LightningElement, wire, track } from 'lwc';
import getAdmissionApplications from '@salesforce/apex/ApplicationListController.getAdmissionApplications';
import basePath from '@salesforce/community/basePath';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RevAdmApplicationList extends LightningElement {

    @track applicationsResult;
    applicationListId;
    applicationName;
    applicationFilterId;
    @wire(getAdmissionApplications)
    wiredData({ error, data }) {
        if (data) {
            this.applicationsResult = data;
            this.applicationListId = this.applicationsResult.applicationList[0].Id || "N/A";
            this.applicationName = this.applicationsResult.applicationList[0].Name || "N/A";
            this.applicationFilterId = this.applicationsResult.myApplicationsFilterId || "N/A";


        } else if (error) {
            this.showErrorToast(error.body.message);
        }
    }


    get applicationNumber() {
        return this.applicationsResult.applicationList[0].Application_Number__c || "N/A";

    }
    get applicationStatus() {
        return this.applicationsResult.applicationList[0].hed__Application_Status__c || "N/A";

    }
    get applicationReviewStatus() {
        return this.applicationsResult.applicationList[0].randa__Application_Review_Status__c || "N/A";

    }

    get applicationUrl() {
        return `${basePath}/application/${this.applicationListId}/${this.applicationName}`;

    }
    get viewAllApplicationUrl() {
        return `${basePath}/application/hed__Application__c/${this.applicationFilterId}`;

    }
    //Error Notification
    showErrorToast(errorMessage) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: errorMessage,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }


}