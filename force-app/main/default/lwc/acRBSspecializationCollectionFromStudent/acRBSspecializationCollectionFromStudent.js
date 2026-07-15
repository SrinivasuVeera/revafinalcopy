import { LightningElement, wire, track, api } from 'lwc';
import getRBSspecializations from '@salesforce/apex/RBSstudentSpclCollectionCtrl.getRBSspecializations';
import getCoursesBySpecializations from '@salesforce/apex/RBSstudentSpclCollectionCtrl.getCoursesBySpecializations';
import saveSpeclOnEnrollment from '@salesforce/apex/RBSstudentSpclCollectionCtrl.saveSpeclOnEnrollment';
import isSpecializationsExist from '@salesforce/apex/RBSstudentSpclCollectionCtrl.isSpecializationsExist';
import getCourseOfferingsBySpcl from '@salesforce/apex/RBSstudentSpclCollectionCtrl.getCourseOfferingsBySpcl';
import getSpclNamesFromEnrollment from '@salesforce/apex/RBSstudentSpclCollectionCtrl.getSpclNamesFromEnrollment';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Course Name', fieldName: 'Course_Name__c' },
    { label: 'Course Type', fieldName: 'Course_Type__c' },
    { label: 'Course Id', fieldName: 'Course_Id__c' },
    { label: 'Credits', fieldName: 'Credits__c' },
    { label: 'Offered by School', fieldName: 'Offered_By_School__c' }
];

export default class AcRBSspecializationCollectionFromStudent extends LightningElement {
    @track specalizations = [];
    @track selectedSpecl = ['', ''];
    @track selectedSpec1 = null;
    @track selectedSpec2 = null;
    @track selectedSpec1Name = '';
    @track selectedSpec2Name = '';
    @track coursesForSpec1 = [];
    @track coursesForSpec2 = [];
    @track isModalOpen = false;
    @track showConfirmation = false;
    @track openSections = ['spec1', 'spec2'];
    @track isSpeclExist = false;
    isSpinner = false;
    hasSpclOfferings = false

    totalCredits;
    courseColumns = COLUMNS;

    connectedCallback() {
        this.getSpecialization(this.isSpinner);
        this.getSpclNamesFromEnrlment();
    }
    getSpecialization(isSpinner) {
        isSpecializationsExist()
            .then(result => {
                if (result === true) {
                    this.isSpeclExist = true;
                } else {
                    this.isSpeclExist = false;
                }

                if (this.isSpeclExist === true) {
                    getCourseOfferingsBySpcl()
                        .then(courseResult => {
                            if (Object.keys(courseResult).length > 0) {
                                let SNO = 1;
                                this.hasSpclOfferings = true;
                                let totalCredits = 0;
                                this.lstSpclOfferings = courseResult.map(courseOffering => {
                                    totalCredits += courseOffering.Credits__c;
                                    return {
                                        ...courseOffering,
                                        SNO: SNO++
                                    };
                                });
                                this.totalCredits = totalCredits;
                                if (isSpinner) {
                                    this.sendCreditToAura(this.totalCredits)
                                }
                            } else {
                                this.hasSpclOfferings = false;
                                ;
                            }
                        })
                        .catch(courseError => {
                            console.error('Error retrieving course offerings:', courseError);
                        });
                    this.isSpinner = false;
                }
            })
            .catch(error => {
                console.error('Error checking if specializations exist:', error);
            });

    }
    getSpclNamesFromEnrlment() {
        getSpclNamesFromEnrollment()
            .then(result => {
                this.selectedSpec1Name = result[0].RBS_Specialization_1__r.Name;
                this.selectedSpec2Name = result[0].RBS_Specialization_2__r.Name;
            })
    }

    sendCreditToAura(totalCredits) {
        this.dispatchEvent(new CustomEvent('spclcredits', {
            detail: { spclcredits: totalCredits }
        }));
    }


    @wire(getRBSspecializations)
    wiredSpecalizations({ error, data }) {
        if (data) {
            this.specalizations = data.map(spcl => ({
                label: spcl.Name,
                value: spcl.Id
            }));
        } else if (error) {
            console.error('Error retrieving specializations:', error);
        }
    }

    get spcl1Name() {
        return `SPECIALIZATION - 1 : ${this.selectedSpec1Name}`;
    }

    get spcl2Name() {
        return `SPECIALIZATION - 2 : ${this.selectedSpec2Name}`;
    }

    get hasCoursesForSpec1() {
        return this.coursesForSpec1 && this.coursesForSpec1.length > 0;
    }

    get hasCoursesForSpec2() {
        return this.coursesForSpec2 && this.coursesForSpec2.length > 0;
    }

    get isModelnextDis() {
        return !(this.hasCoursesForSpec1 && this.hasCoursesForSpec2);
    }

    get isSpeclnextDis() {
        return this.isModelnextDis;
    }

    handleSpecialization(event) {
        const selectedValue = event.detail.value;
        const fieldId = event.target.dataset.id;
        const index = fieldId === 'spec1' ? 0 : 1;
        const otherIndex = index === 0 ? 1 : 0;

        if (this.selectedSpecl[otherIndex] === selectedValue) {
            this.showMessageToast("Error", "Specialization-1 & Specialization-2 must be different .", "error");
            this.resetSpecialization(index);
            return;
        }

        this.selectedSpecl[index] = selectedValue;

        if (index === 0) {
            this.selectedSpec1 = selectedValue;
            this.selectedSpec1Name = this.getLabelByValue(selectedValue);
        } else {
            this.selectedSpec2 = selectedValue;
            this.selectedSpec2Name = this.getLabelByValue(selectedValue);
        }
    }

    resetSpecialization(index) {
        this.selectedSpecl[index] = '';
        if (index === 0) {
            this.selectedSpec1 = null;
            this.selectedSpec1Name = '';
        } else {
            this.selectedSpec2 = null;
            this.selectedSpec2Name = '';
        }
        const input = this.template.querySelector(`[data-id="spec${index + 1}"]`);
        if (input) input.value = null;
    }

    getLabelByValue(value) {
        const found = this.specalizations.find(opt => opt.value === value);
        return found ? found.label : '';
    }

    async openModal() {
        if (!this.selectedSpec1) {
            this.showMessageToast("Error", "Please select Specialization - 1 .", "error");

            return;
        }
        if (!this.selectedSpec2) {
            this.showMessageToast("Error", "Please select Specialization - 2 .", "error");
            return;
        }

        this.isModalOpen = true;

        try {
            const ids = [this.selectedSpec1, this.selectedSpec2];

            const result = await getCoursesBySpecializations({ specializationIds: ids });

            // Example: map the response to flat data for datatable
            this.coursesForSpec1 = (result[this.selectedSpec1] || []).map(c => ({
                Course_Name__c: c.hed__Course__r?.Name,
                Credits__c: c.Credits__c,
                Course_Type__c: c.hed__Course__r?.HardCore_Sub_Type__c,
                Offered_By_School__c: c.hed__Course__r?.Offered_By_School__r?.Name,
                Course_Id__c: c.hed__Course__r?.hed__Course_ID__c,
            }));

            this.coursesForSpec2 = (result[this.selectedSpec2] || []).map(c => ({
                Course_Name__c: c.hed__Course__r?.Name,
                Credits__c: c.Credits__c,
                Course_Type__c: c.hed__Course__r?.HardCore_Sub_Type__c,
                Offered_By_School__c: c.hed__Course__r?.Offered_By_School__r?.Name,
                Course_Id__c: c.hed__Course__r?.hed__Course_ID__c,
            }));

        } catch (error) {
            console.error('Error loading courses:', error);
        }
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleSaveClick() {
        this.showConfirmation = true;
        this.isModalOpen = false;
    }

    cancelConfirmation() {
        this.showConfirmation = false;
    }

    confirmSpecializations() {
        this.isSpinner = true;
        saveSpeclOnEnrollment({ spec1: this.selectedSpec1, spec2: this.selectedSpec2 })
            .then(response => {
                if (response === 'Success') {
                    this.showMessageToast("Success", "Specializations saved successfully", "success");
                    setTimeout(() => {
                        this.getSpecialization(this.isSpinner);
                    }, 3000);
                } else {
                    this.showMessageToast("Error", "Failed to save specializations. Please try again.", "error");
                }
            })
            .catch(error => {
                console.error('Error saving specializations:', error);
                this.showMessageToast("Error", "An error occurred while saving specializations.", "error");
            })
            .finally(() => {
                // this.isSpinner = false;
                this.showConfirmation = false;
                this.isModalOpen = false;
            });

    }

    showMessageToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }

}