import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getRecentCases from '@salesforce/apex/BrandingCaseListView.getRecentCases';
import getFacultyRecordTypeId from '@salesforce/apex/BrandingCaseListView.getFacultyRecordTypeId';
import { refreshApex } from '@salesforce/apex';

export default class CaseListViewDuplicate extends NavigationMixin(LightningElement) {
    @track cases = [];
    @track error;
    @track openModalForCreateCase = false;
    @track showServiceFields = false;
    @track showOldCaseNumber = false;
    @track showGoodiesFields = false;
    @track showStudioFields = false;
    @track showRoutineFields = false;
    @track facultyRecordTypeId;
    @track isSpinner = false;
    wiredCase;

    @wire(getFacultyRecordTypeId)
    wiredRecordTypeId({ error, data }) {
        if (data) {
            this.facultyRecordTypeId = data;
        } else if (error) {
            this.showToast('Error', 'Failed to fetch Department Branding Request record type: ' + (error.body ? error.body.message : error.message), 'error');
            this.facultyRecordTypeId = null;
        }
    }

    @wire(getRecentCases)
    wiredCases(result) {
        this.wiredCase = result;
        if (result.data) {
            this.cases = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.showToast('Error', 'Failed to load cases: ' + JSON.stringify(result.error), 'error');
            this.cases = [];
        }
    }

    createCase() {
        if (!this.facultyRecordTypeId) {
            this.showToast('Error', 'Department Branding Request record type not configured for your profile', 'error');
            return;
        }
        this.isSpinner = true;
        setTimeout(() => {
            this.openModalForCreateCase = true;
            this.isSpinner = false;
        }, 500);
    }

    handleModalClose() {
        this.openModalForCreateCase = false;
        this.showServiceFields = false;
        this.showOldCaseNumber = false;
        this.showGoodiesFields = false;
        this.showStudioFields = false;
        this.showRoutineFields = false;
    }

    handleCategoryChange(event) {
        if (!event || !event.target) return;
        const category = event.target.value;
        this.showGoodiesFields = category === 'Goodies Request';
        this.showStudioFields = category === 'Studio Services';
        this.showRoutineFields = false;
    }

    handleSubCategoryChange(event) {
        if (!event || !event.target) return;
        const subCategory = event.target.value;
        this.showRoutineFields = subCategory === 'Routine Services';
        this.showServiceFields = subCategory === 'Routine Services';
    }

    handleSubjectChange(event) {
        if (!event || !event.target) return;
        const subject = event.target.value;
        this.showOldCaseNumber = subject.includes('Old');
    }

    handleSave() {
    this.isSpinner = true;
    const form = this.template.querySelector('lightning-record-edit-form');
    if (!form) {
        this.showToast('Error', 'Form not found - please refresh the page', 'error');
        this.isSpinner = false;
        return;
    }

    if (!this.facultyRecordTypeId) {
        this.showToast('Error', 'Invalid record type ID - please contact your administrator', 'error');
        this.isSpinner = false;
        return;
    }

    setTimeout(() => {
        const inputFields = this.template.querySelectorAll('lightning-input-field.create-input');
        if (!inputFields || inputFields.length === 0) {
            this.showToast('Error', 'No input fields found - please check the form', 'error');
            this.isSpinner = false;
            return;
        }

        inputFields.forEach(field => {
            const fieldName = field.fieldName;
            if (fieldName === 'Goodies_Count__c' && !this.showGoodiesFields) {
                field.required = false;
            } else if (['Service_Type__c', 'Venue__c'].includes(fieldName) && !this.showStudioFields) {
                field.required = false;
            } else if (['Service_Time__c', 'From_Time__c', 'To_Time__c'].includes(fieldName) && !this.showRoutineFields) {
                field.required = false;
            } else if (fieldName === 'Old_Case_Number__c' && !this.showOldCaseNumber) {
                field.required = false;
            }
        });

        const fieldValues = Array.from(inputFields).map(field => ({
            name: field.fieldName,
            value: field.value,
            required: field.required || false,
            readonly: field.readonly || false
        }));

        console.log('Field Values: ', fieldValues);

        const requiredFields = fieldValues.filter(field => 
            field.required || 
            (this.showGoodiesFields && field.name === 'Goodies_Count__c') ||
            (this.showStudioFields && ['Service_Type__c', 'Venue__c'].includes(field.name)) ||
            (this.showRoutineFields && ['Service_Time__c', 'From_Time__c', 'To_Time__c'].includes(field.name)) ||
            (this.showOldCaseNumber && field.name === 'Old_Case_Number__c')
        );
        const isAllRequiredFilled = requiredFields.every(field => field.value || field.readonly);
        if (!isAllRequiredFilled) {
            const missingFields = requiredFields
                .filter(field => !field.value && !field.readonly)
                .map(field => field.name);
            this.showToast('Error', `Please fill all required fields: ${missingFields.join(', ')}`, 'error');
            this.isSpinner = false;
            return;
        }

        const alwaysRequired = ['Category__c', 'Sub_Category__c', 'Subject__c'].filter(fieldName => 
            !fieldValues.find(f => f.name === fieldName && f.value)
        );
        if (alwaysRequired.length > 0) {
            this.showToast('Error', `Please fill required fields: ${alwaysRequired.join(', ')}`, 'error');
            this.isSpinner = false;
            return;
        }

        // Optional client-side hint for time validation
        const fromTimeField = fieldValues.find(f => f.name === 'From_Time__c');
        const toTimeField = fieldValues.find(f => f.name === 'To_Time__c');
        const serviceTimeField = fieldValues.find(f => f.name === 'Service_Time__c');
        if (fromTimeField && toTimeField && serviceTimeField && fromTimeField.value && toTimeField.value && serviceTimeField.value) {
            const fromTime = new Date(`1970-01-01T${fromTimeField.value}Z`).getTime();
            const toTime = new Date(`1970-01-01T${toTimeField.value}Z`).getTime();
            const timeDiff = toTime - fromTime;
            const expectedDiff = {
                '15 Mins': 15 * 60 * 1000, // 900,000 ms
                '4 Hours': 4 * 60 * 60 * 1000, // 14,400,000 ms
                '8 Hours': 8 * 60 * 60 * 1000 // 28,800,000 ms
            }[serviceTimeField.value];
            if (toTime <= fromTime || (expectedDiff && Math.abs(timeDiff) !== expectedDiff)) {
                this.showToast('Warning', 'Time difference should match the selected Service Type (15 Mins, 4 Hours, or 8 Hours).', 'warning');
                this.isSpinner = false;
                return;
            }
        }

        try {
            form.submit();
        } catch (submitError) {
            this.showToast('Error', 'Failed to submit form: ' + JSON.stringify(submitError), 'error');
            console.error('Submit Error: ', submitError);
            this.isSpinner = false;
        }
    }, 0);
}

    handleCreateSuccess(event) {
        this.isSpinner = false;
        if (this.wiredCase) {
            refreshApex(this.wiredCase);
        }
        this.openModalForCreateCase = false;
        this.showToast('Branding Case Created Successfully', '', 'success');
    }

    handleCreateError(event) {
        this.isSpinner = false;
        let errorMessage = 'Unknown error';
        if (event.detail && event.detail.detail) {
            // Check for validation rule error involving From_Time__c, To_Time__c, and Service_Time__c
            if (event.detail.detail.some(detail => 
                detail.message && 
                (detail.message.includes('From_Time__c') || 
                 detail.message.includes('To_Time__c') || 
                 detail.message.includes('Service_Time__c')))) {
                errorMessage = 'Time difference must match selected Service Type.';
            } else if (event.detail.detail[0] && event.detail.detail[0].message) {
                errorMessage = event.detail.detail[0].message;
            } else if (event.detail.message) {
                errorMessage = event.detail.message;
            }
        } else if (event.body && event.body.message) {
            errorMessage = event.body.message;
        } else if (event.message) {
            errorMessage = event.message;
        }
        this.showToast('Error', errorMessage, 'error');
        console.error('Create Error: ', event);
    }

    handleRecordClick(event) {
        const caseId = event.currentTarget ? event.currentTarget.dataset.id : null;
        if (caseId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: caseId,
                    objectApiName: 'Branding_Case__c',
                    actionName: 'view'
                }
            });
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}