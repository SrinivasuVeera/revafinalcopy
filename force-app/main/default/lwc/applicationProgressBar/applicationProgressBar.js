import { LightningElement, api, wire, track } from 'lwc';
import getLoggedInProfile from '@salesforce/apex/ProgressBarController.getLoggedInProfile';
import getApplicationStatus from '@salesforce/apex/ProgressBarController.getApplicationStatus';
import updateApplicationStatus from '@salesforce/apex/ProgressBarController.updateApplicationStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

export default class ApplicationProgressBar extends LightningElement {
    @api recordId;
    @track currentStatus; 
    @track selectedStatus; 
    @track userProfile;
    _wiredStatusResult;

    steps = [
        { label: 'Started', value: 'Started' },
        { label: 'Incomplete', value: 'Incomplete' },
        { label: 'Submitted', value: 'Submitted' },
        { label: 'In Review', value: 'In Review' },
        { label: 'Awaiting Docs', value: 'Awaiting Documents' },
        { label: 'Interested', value: 'Interested' },
        { label: 'Provisionally Offered', value: 'Provisionally Offered' },
        { label: 'Partial Paid', value: 'Partial Paid' },
        { label: 'PAF Full Paid', value: 'PAF Full Paid' },
        { label: 'Annual Fee Paid', value: 'Annual Fee Paid' },
        //{ label: 'Admit', value: 'Admit' },
        { label: 'Application Lost', value: 'Application Lost' }
    ];

    @wire(getLoggedInProfile)
    wiredProfile({ error, data }) {
        if (data) this.userProfile = data;
        console.log('Profile Name: ' + this.userProfile);
    }

    @wire(getApplicationStatus, { recordId: '$recordId' })
    wiredStatus(result) {
        this._wiredStatusResult = result;
        if (result.data) {
            this.currentStatus = result.data;            
            if(!this.selectedStatus || this.selectedStatus === this.currentStatus) {
                this.selectedStatus = result.data;
            }
        }
    }
    get displaySteps() {
        const allowedProfiles = [
            'System Administrator',
            'Admissions Profile','Additional Registrar'

        ];

        if (allowedProfiles.includes(this.userProfile)) {
            return this.steps;
        }

        return this.steps.filter(
            step => step.value !== 'Application Lost'
        );
    }

    get isButtonDisabled() {
        const restrictedProfiles = ['Counselor', 'Admission Team Lead', 'Reception Admissions'];
        
        const currentIndex = this.steps.findIndex(s => s.value === this.currentStatus);
        const selectedIndex = this.steps.findIndex(s => s.value === this.selectedStatus);

        if (restrictedProfiles.includes(this.userProfile)) {
            
            if (selectedIndex <= currentIndex) {
                return true;
            }
            const isValidFrom = (this.currentStatus === 'In Review' || this.currentStatus === 'Awaiting Documents');
            const isValidTo = (this.selectedStatus === 'Awaiting Documents' || this.selectedStatus === 'Interested');

            if (isValidFrom && isValidTo) {
                return false; 
            }

            return true; 
        }
        return this.selectedStatus === this.currentStatus;
    }

    handleStepClick(event) {
        this.selectedStatus = event.target.value;
    }

    async handleUpdateStatus() {
        try {
            await updateApplicationStatus({ 
                applicationId: this.recordId, 
                status: this.selectedStatus 
            });
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Application Status Updated to ' + this.selectedStatus,
                variant: 'success'
            }));

            await notifyRecordUpdateAvailable([{recordId: this.recordId}]);
            return refreshApex(this._wiredStatusResult);

        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body ? error.body.message : 'An error occurred',
                variant: 'error'
            }));
        }
    }
}