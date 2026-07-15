import { LightningElement , track } from 'lwc';
import getLoginReport from '@salesforce/apex/LoginHistoryReport.generateLoginReport';
import getProfileNames from '@salesforce/apex/LoginHistoryReport.getProfileNames';

export default class LoginHistoryDisplay extends LightningElement {
    @track loginData = [];
    @track profileOptions = [];
    @track selectedProfile = '';
    @track startDate = '';
    @track endDate = '';
    @track error;

    connectedCallback() {   
        this.fetchProfiles();
    }

   fetchProfiles() {
        // Using @wire is one way to fetch profiles, but you can also use imperative Apex calls if needed.
        getProfileNames()
            .then((data) => {
                this.profileOptions = data.map(profile => ({
                    label: profile,
                    value: profile,
                }));
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error.body ? error.body.message : 'Error fetching profiles';
            });
    }

    handleProfileChange(event) {
        this.selectedProfile = event.detail.value; // Capture the selected profile value
        this.error = undefined; // Reset any previous errors
      
    }
    handleStartDateChange(event) {
        this.startDate = event.target.value; // Capture the selected start date
        if (this.endDate && new Date(this.startDate) > new Date(this.endDate)) {
            this.error = 'Start Date cannot be after End Date.';
        } else {
            this.error = undefined;
        }
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value; // Capture the selected end date
        if (this.startDate && new Date(this.startDate) > new Date(this.endDate)) {
            this.error = 'End Date cannot be before Start Date.';
        } else {
            this.error = undefined;
        }
    }

    fetchLoginData() {
        if (!this.selectedProfile) {
            this.error = 'Please select a profile to fetch data.';
            return;
        }

        if (!this.startDate || !this.endDate) {
            this.error = 'Please select both a start date and an end date.';
            return;
        }

        if (new Date(this.startDate) > new Date(this.endDate)) {
            this.error = 'Start date cannot be after the end date.';
            return;
        }

        getLoginReport({ selectedProfileNames: [this.selectedProfile], 
            startDate: this.startDate,
            endDate: this.endDate
        })
            .then((result) => {
                if (result?.length > 0) {
                    this.loginData = result;
                    this.error = undefined;
                } else {
                    this.error =`In ${this.selectedProfile}, no data available.`;
                    this.loginData = [];
                }
            })
            .catch((error) => {
                console.error('Error fetching login data:', error);
                this.error = error?.body?.message || 'An unexpected error occurred while fetching login data.';
                this.loginData = [];
            });
    }
    generateReport() {
        this.fetchLoginData();
    }
    
}