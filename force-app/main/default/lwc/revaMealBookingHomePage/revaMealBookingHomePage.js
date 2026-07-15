import { LightningElement, api, wire, track } from "lwc";
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';


export default class RevaMealBookingHomePage extends LightningElement {
    showAvailedPage = false;
    showBookedPage = false;
    showBookingPage = true;
    @api isValied = false;

    @api recordId;
    renderedCallback() {
        if (this.showBookingPage == true) {
            console.log('inside de');
            const tab = this.template.querySelector(".tab[data-step='1']");
            if (tab) {
                tab.style.color = "white";
                tab.style.backgroundColor = "#F07F07";
            }
        }
        // Log or process the leaveRequestId
        console.log('Leave Request ID:', this.recordId);
    }
    handleBackClick() {
        //this.dispatchEvent(new CustomEvent('clickback'));
        if (window.location.origin.includes('site.com')) {
            if (this.profileName === 'Student Portal Profile' || this.profileName === 'Student Profile') {
                window.location.href = '/StudentPortal/s/';
            } else {
                window.location.href = '/NonTeachingStaff/s/quartersfornonteachingstaff';
            }
        }
        else {
            location.reload();
        }

    }
    updateStyles(stepNumber) {
        const tabs = this.template.querySelectorAll(".tab");
        tabs.forEach((tab) => {
            const tabStepNumber = tab.dataset.step;
            if (tabStepNumber != stepNumber) {
                tab.style.backgroundColor = "#FEF3EA";
                tab.style.color = "black";
            } else {
                tab.style.color = "white";
                tab.style.backgroundColor = "#F07F07";
            }
        });
    }

    handleStepClick(event) {
        const stepNumber = event.target.dataset.step;
        if (stepNumber == 1) {
            this.showAvailedPage = false;
            this.showBookedPage = false;
            this.showBookingPage = true;
            this.updateStyles(stepNumber);
        } else if (stepNumber == 2) {
            this.showAvailedPage = false;
            this.showBookedPage = true;
            this.showBookingPage = false;
            this.updateStyles(stepNumber);
        } else if (stepNumber == 3) {
            this.isValied = true;
            this.showAvailedPage = true;
            this.showBookedPage = false;
            this.showBookingPage = false;
            this.updateStyles(stepNumber);
        }
    }

    handleClickBack() { }
    //---------------------------------------------------------------------------
    profileName
    showBackButton = true;
    userId = Id;
    @wire(getRecord, { recordId: '$userId', fields: [PROFILE_NAME_FIELD] })
    userHandler({ error, data }) {
        if (data) {
            // If data is received, store the profile name
            this.profileName = data.fields.Profile.displayValue || data.fields.Profile.value;
            if (this.profileName === 'Student Profile' || this.profileName === 'Student Portal Profile') {
                this.showBackButton = false;
            }
        } else if (error) {
            // Handle any error that occurs while fetching the user profile
            console.error('Error fetching user profile:', error);
        }
    }
}