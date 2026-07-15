import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StudentDetailsManager extends LightningElement {
    @api recordId;
    @track isEditMode = false;
    @track statusValue = '';
    @track readmissionValue = false;
    @track promotionValue = false;
    isInitialLoad = true;
    @track isSaving = false;

    handleEdit() {
        this.isEditMode = true;
        this.isInitialLoad = true;
        this.isSaving = false; // Reset guard when entering edit mode
    }

    handleCancel() {
        this.isEditMode = false;
        this.isSaving = false;
    }

    handleLoad(event) {
        // ONLY set values from the database if this is the FIRST time the form is loading
        if (this.isInitialLoad) {
            const fields = event.detail.records[this.recordId].fields;
            
            const dbStatus = fields.Student_Status__c?.value || '';
            this.statusValue = dbStatus;
            this.initialStatus = dbStatus;
            this.readmissionValue = fields.Readmission__c?.value || false;
            this.promotionValue = fields.Promotional_Eligibility__c?.value || false;
            
            console.log('--- Initial Data Loaded ---');
            console.log('Database Status:', this.statusValue);
            
            this.isInitialLoad = false; // Close the guard
        } else {
            console.log('--- Form Refreshed (Blocked Overwrite) ---');
        }
    }

    handleStatusChange(event) {
        // Update our local variable immediately
        this.statusValue = event.detail.value;
        console.log('Manual Change to:', this.statusValue);
    }

    handleReadmissionChange(event) {
        this.readmissionValue = event.detail.value;
        if (this.readmissionValue) {
            this.promotionValue = false;
        }
    }

    handlePromotionChange(event) {
        this.promotionValue = event.detail.value;
         if (this.promotionValue) {
            this.readmissionValue = false;
        }
    }    

     handleSubmit(event) {
        this.isSaving = true;
        event.preventDefault(); // Stop the default save
        const fields = event.detail.fields;

        // Set the fields based on our local tracked variables
        fields.Readmission__c = this.readmissionValue;
        fields.Promotional_Eligibility__c = this.promotionValue;

        // If neither is checked, clear Semester/Year as well
        if (!this.readmissionValue && !this.promotionValue) {
            fields.Readmission_Semester__c = null;
            fields.Readmission_Year__c = null;
        }

        // Submit the cleaned data to Salesforce
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleError(event) {
        // Re-enable button if Salesforce returns an error (e.g. Validation Rule)
        this.isSaving = false; 
        console.log('Error received. Button re-enabled.');
    }

    // GETTERS remain the same - they are reactive!
     get isPursuing() { 
        // Safety: trim() handles potential whitespace in the picklist value
        return this.statusValue?.trim() === 'Pursuing'; 
    }
    
    get isActionRequired() {
        const wasInitiallyPursuing = this.initialStatus?.trim() === 'Pursuing';
        const requiredState = this.isPursuing && !wasInitiallyPursuing;
        console.log('Current Status:', this.statusValue, '| Is Action Required:', requiredState);
        return requiredState;
    }

    get showReadmissionField() {
        return this.isPursuing && !this.promotionValue;
    }

    get showPromotionField() {
        return this.isPursuing && !this.readmissionValue;
    }

    get showSemesterFields() {
        return this.readmissionValue || this.promotionValue;
    }

    handleSuccess() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Record updated successfully',
            variant: 'success'
        }));
        this.isSaving = false;
        this.isEditMode = false;
    }
}