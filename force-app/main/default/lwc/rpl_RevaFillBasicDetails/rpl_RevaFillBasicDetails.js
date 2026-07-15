import {    LightningElement, track, wire, api} from "lwc";
import {refreshApex} from '@salesforce/apex';
import fetchStudentRegDetailsfrom from '@salesforce/apex/RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails'
import updateDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.updateStudentRegDetails';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import STUDENT_REGISTRATION from '@salesforce/schema/Rpl_Student_Registration__c';
import TENTH_YEAR_OF_PASSING from '@salesforce/schema/Rpl_Student_Registration__c.Rpl_10th_Year_of_passing__c';
import TWELVETH_YEAR_OF_PASSING from '@salesforce/schema/Rpl_Student_Registration__c.Rpl_12th_Year_of_passing__c';
import DIPLOMA_YEAR_OF_PASSING from '@salesforce/schema/Rpl_Student_Registration__c.Rpl_Diploma_Graduation_Year__c';
import UG_GRADGUATION_YEAR from '@salesforce/schema/Rpl_Student_Registration__c.Rpl_UG_Year_of_Graduation__c';
import getEducationDetailsByLevel from '@salesforce/apex/RPL_StudentRegistrationDetails.getEducationDetailsByLevel';
import getStudentCGPAAndEducationDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.getStudentCGPAAndEducationDetails';
import getContactPAN  from '@salesforce/apex/RPL_StudentRegistrationDetails.getContactPAN';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';


import { ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class Rpl_RevaFillBasicDetails extends LightningElement {
    @api studentRegRecordId;
    @track studentRegform = {};
    @api isSaveButtonDisabled;
    isNotEmpty = false;
    previousStep = 1;
    isSaveTrue = true;
    validity = false;
    isSubmitButtonDisabled = false;
    isSpinner = false;
    isFirstPageRendered = false;
    @api contactId;
    @api placementRegistrationText;
    @api fillBasicDetailsRightColText;
    stepNumber = 1;
    wiredResult;
    showEducationGapReason = false;

    isStudentBasicDetails = true;
    isTenthDetails;
    isTwelvethDetails;
    isUgOrPgDetails;
    isUgDetailsOnly;
    isPgDetailsOnly;
    isDiplomaDetailsOnly;
    isTwelvethDetailsOnly;

    ugCheckbox;
    pgCheckbox;
    twelvethCheckbox;
    diplomaCheckbox;
    //maleCheckbox;
    //femaleCheckbox;
    placementInterestCheckbox;
    placementNotInterestCheckbox;

    isUgSem1Required;
    isUgSem2Required;
    isUgSem3Required;
    isUgSem4Required;
    isUgSem5Required;
    isUgSem6Required;
    isUgSem7Required;
    isUgSem8Required;
    isPgSem1Required;
       totalYears;
    isShowUgSem1 = true;
    isShowUgSem2 = true;

    isDiplomaStudent;
    isTwelvethStudent;

    @track tenthPickList = [];
    @track twelvethPickList = [];
    @track diplomaPickList = [];
    @track ugPickList = [];

    // Education history display values
@track tenthBoardName = '';
@track tenthCGPA = '';
@track tenthYearOfPassing = '';

@track isTwelvethStudent = false;
@track isDiplomaStudent = false;

@track hasTwelvethData = false;
@track hasDiplomaData = false;

@track twelvethData = {
    BoardName: '',
    Percentage: '',
    YearOfPassing: ''
};

@track diplomaData = {
    CollegeName: '',
    Percentage: '',
    Branch: '',
    GraduationYear: ''
};

@track isPGStudent = false;
@track isUGStudent = false;

// UG Education Details (only for PG students)
@track ugCollegeName = '';
/*@track ugUniversity = '';
@track ugCGPA = '';*/
@track ugPercentage = '';
@track ugGraduationYear = '';

@track ugCumulativeCgpa = '';
@track ugBranch = '';
@track ugUniversityName = '';


// Semester CGPA (current UG or PG student)
@track semesterCgpaMap = {}; // key = 'Sem 1', value = 8.5 etc.
@track totalBacklogs = 0;
@track totalBacklogs1 = 0;
@track studentRegform = {
    Rpl_Total_Backlogs__c: 0
};
@track panNumber;
@track isBasicDetailsCompleted = false;
// PG Education Details (only for PG students)
    firstStepFields = [ 'Rpl_Pan_Card_No__c', 'Rpl_Current_Backlogs__c', 'Rpl_Cleared_Backlogs__c', 'Rpl_Total_Backlogs__c',  'Rpl_Education_Gap__c',  'Rpl_Student_Image__c'];
    secondStepFields = ['Rpl_10th_Board_Name__c', 'Rpl_10th_Percentage__c', 'Rpl_10th_Year_of_passing__c', 'Rpl_Diploma_University__c', 'Rpl_Diploma_Graduation_Year__c', 'Rpl_Diploma_Percentage__c', 'Rpl_DiplomaName__c'];

    @wire(getObjectInfo, {objectApiName : STUDENT_REGISTRATION})
    studentReg;

    @wire(getPicklistValues, {recordTypeId: '$studentReg.data.defaultRecordTypeId', fieldApiName : TENTH_YEAR_OF_PASSING})
    originField1({data, error}){
        if(data){
            this.tenthPickList = data.values.map(item => ({label : item.label, value:item.value}))

        }else if(error){
            console.error('Error While Fetching Picklist ' + error);
        }
    }
     @wire(getPicklistValues, {recordTypeId: '$studentReg.data.defaultRecordTypeId', fieldApiName : TWELVETH_YEAR_OF_PASSING})
    originField2({data, error}){
        if(data){
            this.twelvethPickList = data.values.map(item => ({label : item.label, value:item.value}))

        }else if(error){
            console.error('Error While Fetching Picklist ' + error);
        }
    }
     @wire(getPicklistValues, {recordTypeId: '$studentReg.data.defaultRecordTypeId', fieldApiName : DIPLOMA_YEAR_OF_PASSING})
    originField3({data, error}){
        if(data){
            this.diplomaPickList = data.values.map(item => ({label : item.label, value:item.value}))

        }else if(error){
            console.error('Error While Fetching Picklist ' + error);
        }
    }
     @wire(getPicklistValues, {recordTypeId: '$studentReg.data.defaultRecordTypeId', fieldApiName : UG_GRADGUATION_YEAR})
    originField4({data, error}){
        if(data){
            this.ugPickList = data.values.map(item => ({label : item.label, value:item.value}))

        }else if(error){
            console.error('Error While Fetching Picklist ' + error);
        }
    }



    /********************Newly added by veera************************* */
    @wire(getContactPAN)
    wiredPan({ error, data }) {
        if (data) {
            this.panNumber = data;
        } else if (error) {
            console.error('Error fetching PAN:', error);
        }
    }

    getSscEducationDetails() {

        getEducationDetailsByLevel()
            .then(result => {


                if (result && result['10th']) {
                    const tenth = result['10th'];


                    this.tenthBoardName = tenth.Board__c || '';
                    this.tenthCGPA = tenth.Percentage__c || '';
                    this.tenthYearOfPassing = tenth.Year_Of_Passings__c || '';
                    this.isTenthDetails = true;
                }
            })
            .catch(error => {
                console.error('Error fetching education details:', error);
            });

}
        //for 12th or diploma
        getTwelvethOrDiplomaDetails() {
    getEducationDetailsByLevel()
        .then(result => {


            if (result['12th']) {
                const twelveth = result['12th'];
                this.twelvethData = {
                    BoardName: twelveth.Board__c || '',
                    Percentage: twelveth.Percentage__c || '',
                    YearOfPassing: twelveth.Year_Of_Passings__c || ''
                };
                this.hasTwelvethData = true;
                this.isTwelvethStudent = true; // Default to 12th if present
                this.isDiplomaStudent = false;
            }

            if (result.Diploma) {
                const diploma = result.Diploma;
                this.diplomaData = {
                    CollegeName: diploma.College_Name__c || '',
                    Percentage: diploma.Percentage__c || '',
                    Branch: diploma.Branch__c || '',
                    GraduationYear: diploma.Year_Of_Passings__c || ''
                };
                this.hasDiplomaData = true;

                // If 12th not found, default to Diploma
                if (!this.hasTwelvethData) {
                    this.isDiplomaStudent = true;
                    this.isTwelvethStudent = false;
                }
            }

            // If both are missing, reset
            if (!this.hasTwelvethData && !this.hasDiplomaData) {
                this.isTwelvethStudent = false;
                this.isDiplomaStudent = false;
            }
        })
        .catch(error => {
            console.error('Error fetching 12th/Diploma details:', error);
        });
}

getStudentCgpaAndEduDetails() {
    getStudentCGPAAndEducationDetails()
        .then(result => {


            const eduMap = result.educationHistory;
            const cgpaMap = result.semesterCGPA;

            if (eduMap && eduMap.UG) {
                const ug = eduMap.UG;
                this.ugCollegeName = ug.hed__Educational_Institution_Name__c || '';
                this.ugUniversityName = ug.University_UG__c || '';
                this.ugCumulativeCgpa = ug.Percentage__c || '';
                this.ugGraduationYear = ug.Year_Of_Passings__c || '';
                this.ugBranch = ug.Program__c || '';
                this.studentRegform.Rpl_UG_CGPA__c = this.ugCumulativeCgpa;
            }

            if (cgpaMap && Object.keys(cgpaMap).length > 0) {
                this.semesterCgpaMap = cgpaMap;

                this.totalBacklogs = result.backlogCount || 0;

            } 
        })
        .catch(error => {
            console.error('Error fetching student CGPA and education details:', error);
        });
}




getSemesterCgpaByNumber(semNum) {
    if (!this.semesterCgpaMap) return '';
    const key = `Sem-${semNum}`;
    return this.semesterCgpaMap[key] || '';
}




// UG Getter
get ugSem1Cgpa() { return this.getSemesterCgpaByNumber(1); }
get ugSem2Cgpa() { return this.getSemesterCgpaByNumber(2); }
get ugSem3Cgpa() { return this.getSemesterCgpaByNumber(3); }
get ugSem4Cgpa() { return this.getSemesterCgpaByNumber(4); }
get ugSem5Cgpa() { return this.getSemesterCgpaByNumber(5); }
get ugSem6Cgpa() { return this.getSemesterCgpaByNumber(6); }
get ugSem7Cgpa() { return this.getSemesterCgpaByNumber(7); }
get ugSem8Cgpa() { return this.getSemesterCgpaByNumber(8); }

// PG Getter (same keys)
get pgSem1Cgpa() { return this.getSemesterCgpaByNumber(1); }
get pgSem2Cgpa() { return this.getSemesterCgpaByNumber(2); }
get pgSem3Cgpa() { return this.getSemesterCgpaByNumber(3); }
get pgSem4Cgpa() { return this.getSemesterCgpaByNumber(4); }



    renderedCallback() {
        this.ugCheckbox = this.template.querySelector('.ug-checkbox');
        this.pgCheckbox = this.template.querySelector('.pg-checkbox');
        this.twelvethCheckbox = this.template.querySelector('.twelveth-checkbox');
        this.diplomaCheckbox = this.template.querySelector('.diploma-checkbox');

       // this.maleCheckbox = this.template.querySelector('.male-checkbox');
       // this.femaleCheckbox = this.template.querySelector('.female-checkbox');
        this.placementInterestCheckbox = this.template.querySelector('.placement-interest');
        this.placementNotInterestCheckbox = this.template.querySelector('.placement-not-interest');
        if (this.isFirstPageRendered) {
            this.updateCheckboxes();
        }
    }

    updateStyles(stepNumber) {
        const tabs = this.template.querySelectorAll('.tab');
        tabs.forEach(tab => {
            const tabStepNumber = tab.dataset.step;
            if (tabStepNumber != stepNumber) {
                tab.style.backgroundColor = '#FEF3EA';
                tab.style.color = 'black';
            } else {
                tab.style.color = 'white';
                tab.style.backgroundColor = '#F07F07';

            }
        })
    }


   handleCheckBoxClick(event) {
    const selected = event.target.dataset.inputCheckbox;

    if (selected === 'twelveth') {
        this.isTwelvethStudent = true;
        this.isDiplomaStudent = false;
    } else if (selected === 'diploma') {
        this.isTwelvethStudent = false;
        this.isDiplomaStudent = true;
    } else if (selected === 'UG') {
        this.isUgDetailsOnly = true;
        this.isPgDetailsOnly = false;

        // Uncheck PG checkbox if ref available
        if (this.pgCheckbox && this.pgCheckbox.checked !== undefined) {
            this.pgCheckbox.checked = false;
        }
    } else if (selected === 'PG') {
        this.isUgDetailsOnly = false;
        this.isPgDetailsOnly = true;

        // Uncheck UG checkbox if ref available
        if (this.ugCheckbox && this.ugCheckbox.checked !== undefined) {
            this.ugCheckbox.checked = false;
        }
    } else if (selected === 'placement-interested') {
        if (this.placementNotInterestCheckbox && this.placementNotInterestCheckbox.checked !== undefined) {
            this.placementNotInterestCheckbox.checked = false;
        }
    } else if (selected === 'placement-not-interested') {
        if (this.placementInterestCheckbox && this.placementInterestCheckbox.checked !== undefined) {
            this.placementInterestCheckbox.checked = false;
        }
    }
}




    handleNextOne(){
        let isValid = true;
            this.isFirstPageRendered = false;

                if (this.placementInterestCheckbox.checked == false && this.placementNotInterestCheckbox.checked == false) {
                    const input = this.template.querySelector(`[data-label="Rpl_Interested_in_placement__c"]`);
                    input.setCustomValidity('Please fill out this field');
                    input.reportValidity();
                    return;
                }
                    const input = this.template.querySelector(`[data-label="Rpl_Interested_in_placement__c"]`);
                    input.setCustomValidity('');
                    input.reportValidity();

                if (!this.validity) {
                    this.showToast('Please upload your passport size image');
                    return;
                }
                this.firstStepFields.forEach(label => {
                    const input = this.template.querySelector(`[data-label="${label}"]`);
                    if (input) {
                        if (!input.reportValidity()) {
                            isValid = false;
                        }
                    }
                });
                if (!isValid) {
                    return;
                }

              this.studentRegform.Rpl_Pan_Card_No__c = this.panNumber;


           //this.showStepTwo();
           updateDetails({ stdRegDetails: this.studentRegform })
           .then(() => refreshApex(this.wiredResult))
        .then(() => {
            this.showStepTwo();
        })
        .catch(error => {
            console.error('Error updating student registration:', error);
            this.showToast('Error saving student details: ' + error.body.message, 'error');
        });
    }


    handleNextTwo() {
    let isValid = true;

    this.secondStepFields.forEach(label => {
        const input = this.template.querySelector(`[data-label="${label}"]`);
        if (input) {
            if (!input.reportValidity()) {
                isValid = false;
            }
        }
    });

    if (!isValid) {
        return;
    }


    this.studentRegform.Rpl_isStudentDetailsComplete__c = true;

    this.studentRegform.Rpl_10th_Board_Name__c = this.tenthBoardName;
    this.studentRegform.Rpl_10th_Percentage__c = this.tenthCGPA;
    this.studentRegform.Rpl_10th_Year_of_passing__c = this.tenthYearOfPassing;

    updateDetails({ stdRegDetails: this.studentRegform })
    .then(() => refreshApex(this.wiredResult))
        .then(() => {
            this.showStepThree();
        })
        .catch(error => {
            console.error('Error updating student registration:', error);
            this.showToast('Error saving student details: ' + error.body.message, 'error');
        });
}


        handleNextThree() {
    let isValid = true;

    // Validate and assign 12th details
    if (this.isTwelvethStudent) {
        const fields = ['12th Board Name', '12th Percentage', '12th Date Of Passing'];
        fields.forEach(label => {
            const input = this.template.querySelector(`[data-label="${label}"]`);
            if (input && !input.reportValidity()) {
                isValid = false;
            }
        });

        if (isValid && this.twelvethData) {
            this.studentRegform.Rpl_12th_Board_Name__c = this.twelvethData.BoardName;
            this.studentRegform.Rpl_12th_Percentage__c = this.twelvethData.Percentage;
            this.studentRegform.Rpl_12th_Year_of_passing__c = this.twelvethData.YearOfPassing;
        }
    }

    // Validate and assign Diploma details
    if (this.isDiplomaStudent) {
        const fields = ['Diploma College Name', 'Diploma Percentage', 'Diploma Branch', 'Diploma Date Of Passing'];
        fields.forEach(label => {
            const input = this.template.querySelector(`[data-label="${label}"]`);
            if (input && !input.reportValidity()) {
                isValid = false;
            }
        });

        if (isValid && this.diplomaData) {
            this.studentRegform.Rpl_Diploma_College_Name__c = this.diplomaData.CollegeName;
            this.studentRegform.Rpl_Diploma_Percentage__c = this.diplomaData.Percentage;
            this.studentRegform.Rpl_Diploma_Branch__c = this.diplomaData.Branch;
            this.studentRegform.Rpl_Diploma_Graduation_Year__c = this.diplomaData.GraduationYear;
        }
    }

    // Stop if validation failed
    if (!isValid) {
        return;
    }

    // Update record and move to next step
    updateDetails({ stdRegDetails: this.studentRegform })
    .then(() => refreshApex(this.wiredResult))
        .then(() => {
            this.showStepFour(); // Show next step
            this.setUgAndPgMarksRequired(
                this.totalYears,
                this.studentRegform.Rpl_Branch_Name__c,
                this.isDiplomaStudent
            );
        })
        .catch(error => {
            console.error('Error updating student registration:', error);
            this.showToast('Error saving 12th/Diploma details: ' + error.body.message, 'error');
        });
}




    handlePreviousTwo(){
        this.showStepOne();
    }
    handlePreviousThree(){
        this.showStepTwo();
    }

    handlePreviousFour(){
        this.showStepThree();
    }
    showStepOne(){
        this.stepNumber = 1;
        this.updateStyles(1);
        this.isStudentBasicDetails = true;
        this.isTenthDetails = false;
        this.isTwelvethDetails = false;
        this.isUgOrPgDetails = false;
        this.isFirstPageRendered = true;
    }
    showStepTwo(){
        this.stepNumber = 2;
            this.getSscEducationDetails();
            this.updateStyles(2);
            this.isStudentBasicDetails = false;
            this.isTenthDetails = true;
            this.isTwelvethDetails = false;
            this.isUgOrPgDetails = false;
            this.isFirstPageRendered = false;
    }
    showStepThree(){
        this.stepNumber = 3;
            this.getTwelvethOrDiplomaDetails();
            this.studentRegform.Rpl_isStudentDetailsComplete__c = true;
            this.isFirstPageRendered = false;
            this.updateStyles(3);
            this.isStudentBasicDetails = false;
            this.isTenthDetails = false;
            this.isUgOrPgDetails = false;
            this.isTwelvethDetails = true;

    }
    showStepFour(){
        this.stepNumber = 4;
       // this.getSscEducationDetails();         // Existing method — fetches SSC
        this.getStudentCgpaAndEduDetails();
        this.updateStyles(4);
        this.isFirstPageRendered = false;
        this.isStudentBasicDetails = false;
        this.isTenthDetails = false;
        this.isTwelvethDetails = false;
        this.isUgOrPgDetails = true;
    }
    handleInput(event) {
        const label = event.target.dataset.label;
        const value = event.target.value;
        this.studentRegform[label] = value;
        if (label === 'Rpl_Total_Backlogs__c') {
        this.totalBacklogs1 = value ? parseInt(value) : 0;
        this.studentRegform.Rpl_Total_Backlogs__c = this.totalBacklogs1;
    }
        if (label == 'Rpl_Cleared_Backlogs__c' || label == 'Rpl_Current_Backlogs__c') {
            const currentBacklog = this.studentRegform.Rpl_Current_Backlogs__c ? parseInt(this.studentRegform.Rpl_Current_Backlogs__c) : 0;
            const clearedBacklog = this.studentRegform.Rpl_Cleared_Backlogs__c ? parseInt(this.studentRegform.Rpl_Cleared_Backlogs__c) : 0;
            this.studentRegform.Rpl_Total_Backlogs__c = currentBacklog + clearedBacklog;
        }
        else if (label == 'Rpl_12th_Percentage__c' || label == 'Rpl_10th_Percentage__c' || label == 'Rpl_Diploma_Percentage__c') {
            this.updateMarks();
        }
        else if(label == 'Rpl_Education_Gap__c' && value > 0){
            this.showEducationGapReason = true;
        }else if(label == 'Rpl_Education_Gap__c' && value == 0){
            this.showEducationGapReason = false;
        }else if(label == 'Rpl_Reason_For_Education_Gap__c'){
             const input = this.template.querySelector(`[data-label="Rpl_Reason_For_Education_Gap__c"]`);
              if(!input.value){
                input.setCustomValidity('Please fill reason for your education gap');
            }else{
                input.setCustomValidity('');
            }
            input.reportValidity();

        }
    }
    blurHandler(event) {
        const label = event.target.dataset.label;
        const value = event.target.value;
        const input = this.template.querySelector(`[data-label="${label}"]`);
        if (label == 'Rpl_Diploma_Graduation_Year__c' || label == 'Rpl_12th_Year_of_passing__c' || label == 'Rpl_10th_Year_of_passing__c') {
            this.validateDate(label, value, input);
        }else if(label == 'Rpl_Education_Gap__c' && value > 0){
            const input = this.template.querySelector(`[data-label="Rpl_Reason_For_Education_Gap__c"]`);
            if(input.value == ''){
                input.setCustomValidity('Please fill reason for your education gap');
            }else{
                input.setCustomValidity('');
            }
            input.reportValidity();
            return;
        }
        input.reportValidity();
    }




async handleStudentImageUpload(event) {
    try {
        if (!event.target.value) {
            return; // nothing to process yet
        }
        this.isSpinner = true;

        const modifiedHtml = await this.modifyHtmlString(event.target.value);

        // Always replace old image with the new one
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = modifiedHtml;

        const imgs = tempDiv.querySelectorAll('img');
        if (imgs.length > 1) {
            // Keep only the last uploaded image
            tempDiv.innerHTML = '';
            tempDiv.appendChild(imgs[imgs.length - 1]);
        }

        this.studentRegform.Rpl_Student_Image__c = tempDiv.innerHTML;
        this.validity = true;
    } catch (error) {
        this.validity = false;
        this.showToast(error.message);
    } finally {
        this.isSpinner = false;
    }
}

    validateDate(label, value, input) {
        const currentDate = new Date().getFullYear();
        const selectedDate = value;
        const tenthYearOfPassing = this.studentRegform.Rpl_10th_Year_of_passing__c ? (this.studentRegform.Rpl_10th_Year_of_passing__c) : undefined;
        if (label == 'Rpl_10th_Year_of_passing__c') {
            if (selectedDate > currentDate) {
                input.setCustomValidity('The date should be in the past');
            } else {
                input.setCustomValidity('');
            }
        } else if (tenthYearOfPassing && (label == 'Rpl_12th_Year_of_passing__c')) {
            const yearDifference = selectedDate - tenthYearOfPassing;
            if (selectedDate > currentDate) {
                input.setCustomValidity('The date should be in the past');
            }
            else if (yearDifference < 2) {
                input.setCustomValidity('There should be a minimum 2-year gap from 10th year of passing');
            } else {
                input.setCustomValidity('');
            }
        } else if (tenthYearOfPassing && (label == 'Rpl_Diploma_Graduation_Year__c')) {
            const yearDifference = selectedDate - tenthYearOfPassing;
            if (selectedDate > currentDate) {
                input.setCustomValidity('The date should be in the past');
            }
            else if (yearDifference < 1) {
                input.setCustomValidity('There should be a minimum 1-year gap from 10th year of passing');
            } else {
                input.setCustomValidity('');
            }
        }
    }

    async handleSave() {
   // alert('inside handle save');
    this.isLoading = true;



    try {
        
        // ✅ UG Student Logic
        if (this.isUGStudent) {

            this.studentRegform.RPL_IsGraduationComplete__c = true;

            this.studentRegform.Rpl_Sem_1_CGPA__c = this.ugSem1Cgpa || null;
            this.studentRegform.Rpl_Sem_2_CGPA__c = this.ugSem2Cgpa || null;
            this.studentRegform.Rpl_Sem_3_CGPA__c = this.ugSem3Cgpa || null;
            this.studentRegform.Rpl_Sem_4_CGPA__c = this.ugSem4Cgpa || null;
            this.studentRegform.Rpl_Sem_5_CGPA__c = this.ugSem5Cgpa || null;
            this.studentRegform.Rpl_Sem_6_CGPA__c = this.ugSem6Cgpa || null;

            if (this.totalYears === 4) {
                this.studentRegform.Rpl_Sem_7_CGPA__c = this.ugSem7Cgpa || null;
                this.studentRegform.Rpl_Sem_8_CGPA__c = this.ugSem8Cgpa || null;
            }
        }
        
        // ✅ PG Student Logic (Include UG details + PG CGPAs)
        if (this.isPGStudent) {           

            this.studentRegform.RPL_IsPostGraduationComplete__c = true;

            // PG semester CGPA
            this.studentRegform.Rpl_PG1_Sem_CGPA__c = this.pgSem1Cgpa || null;
            this.studentRegform.Rpl_PG2_Sem_CGPA__c = this.pgSem2Cgpa || null;
            this.studentRegform.Rpl_PG3_Sem_CGPA__c = this.pgSem3Cgpa || null;
            this.studentRegform.Rpl_PG4_Sem_CGPA__c = this.pgSem4Cgpa || null;

            // UG details for PG student (NO UG semester CGPA)
            this.studentRegform.RPL_IsGraduationComplete__c = true;
            this.studentRegform.Rpl_UG_College_Name__c = this.ugCollegeName || null;
            this.studentRegform.Rpl_UG_Board_Name_University_Name__c = this.ugUniversityName || null;
            this.studentRegform.Rpl_UG_Stream__c = this.ugBranch || null;
            //this.studentRegform.Rpl_UG_Specialization__c = this.ugSpecialization || null;
            this.studentRegform.Rpl_UG_Year_of_Graduation__c = this.ugGraduationYear || null;
            //this.studentRegform.Rpl_UG_CGPA__c = this.ugCumulativeCgpa || null;
        }       

        // ✅ Diploma flag (common for both)
        this.studentRegform.Rpl_Is_Diploma_Student__c = this.isDiplomaStudent;
        this.studentRegform.Rpl_Current_Backlogs__c = this.totalBacklogs || 0;
        this.studentRegform.Rpl_Total_Backlogs__c = this.totalBacklogs1 || 0;
        
       await this.overAllPercentageCalculation();
        // Apex method call
        const result = await updateDetails({ stdRegDetails: this.studentRegform });
        await refreshApex(this.wiredResult);
         this.isBasicDetailsCompleted=true;
        // ✅ Success message
        this.showToastSuccess('UG & PG Details Saved Successfully', 'success');

        // Optional: trigger parent component event if needed
       // this.dispatchEvent(new CustomEvent('fillbasicdetailcompleted'));
       this.dispatchEvent(new CustomEvent('fillbasicdetailcompleted', { // newly added
            detail: { recordId: this.studentRegform.Id, isBasicDetailsCompleted: this.isBasicDetailsCompleted }
        }));

    } catch (error) {
        console.error('Error while saving UG & PG data:', error);
        this.showToast(
            'Error while saving UG & PG data: ' + (error.body?.message || error.message),
            'error'
        );
    } finally {
        this.isLoading = false;
    }
}


    modifyHtmlString(inputHtml) {
        this.isSpinner = true;
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = inputHtml;
        const imgTags = tempDiv.querySelectorAll('img');

        if (imgTags.length > 1) {
            throw new Error('More than one image is not allowed.');
        } else if (imgTags.length == 0) {
            throw new Error('Please upload your passport size image.');
        }

        if (imgTags.length === 1) {
            const imgTag = imgTags[0];
            imgTag.setAttribute('style', 'height: 135px; width: 135px;');
        }
        return tempDiv.innerHTML;
    }
    get twelfthPercentageOrCGPA() {

        return this.studentRegform.Rpl_Twelfth_CGPA__c > this.studentRegform.Rpl_12th_Percentage__c ? this.studentRegform.Rpl_Twelfth_CGPA__c : this.studentRegform.Rpl_12th_Percentage__c;
    }

    get tenthPercentageOrCGPA() {
        return this.studentRegform.Rpl_Tenth_CGPA__c > this.studentRegform.Rpl_10th_Percentage__c ? this.studentRegform.Rpl_Tenth_CGPA__c : this.studentRegform.Rpl_10th_Percentage__c;
    }

    updateStudentRegistration() {
        updateDetails({
                stdRegDetails: this.studentRegform
            })
            .then(result => {
                this.studentRegRecordId = result;
                this.showToastSuccess('Student Details Successfully Updated ');
            })
            .catch(error => {
            });
    }
    connectedCallback(){
        this.isSpinner = true;
    }
    setUgAndPgMarksRequired(numberOfYears, academicProgram, isDiplomaStudent) {

        if (numberOfYears == 2 && (academicProgram == 'CSIT-TEST' || academicProgram == 'MSC-DS')) {
            this.isPgSem1Required = true;
            return;
        }
        let totalSemesters = numberOfYears * 2;
        for (let sem = 1; sem <= totalSemesters - 3; sem++){
            this[`isUgSem${sem}Required`] = true;
        }
        if (isDiplomaStudent) {

            this.isUgSem1Required = false;
            this.isUgSem2Required = false;
            this.isShowUgSem1 = false;
            this.isShowUgSem2 = false;
        }
    }

    @wire(fetchStudentRegDetailsfrom, {recordId: '$contactId'})
    wiredContactFetch(result) {

        this.wiredResult = result;
        if (result.data && result.data.length > 0) {

            result.data.forEach(element => {
            this.totalYears = element.Contact__r.Primary_Academic_Program__r.No_of_Years__c || 2;
            this.studentRegform.Id = element.Id ? element.Id : '';
            this.studentRegform.Rpl_SRN__c = element.Rpl_SRN__c ? element.Rpl_SRN__c : '';
            this.studentRegform.Name = element.Name ? element.Name : '';
            this.studentRegform.Rpl_Gender__c = element.Rpl_Gender__c ? element.Rpl_Gender__c : '';
            this.studentRegform.Rpl_Date_of_Birth__c = element.Rpl_Date_of_Birth__c ? element.Rpl_Date_of_Birth__c : '';
            this.studentRegform.Rpl_Contact_No__c = element.Rpl_Contact_No__c ? element.Rpl_Contact_No__c : '';
            this.studentRegform.Rpl_School__c = element.Rpl_School__c ? element.Rpl_School__c : '';
            this.studentRegform.Rpl_Personal_Mail_ID__c = element.Rpl_Personal_Mail_ID__c ? element.Rpl_Personal_Mail_ID__c : '';
            this.studentRegform.Course_Name__c = element.Course_Name__c ? element.Course_Name__c : '';
            this.studentRegform.Rpl_University_Mail_ID__c = element.Rpl_University_Mail_ID__c ? element.Rpl_University_Mail_ID__c : '';
            this.studentRegform.Rpl_10th_Percentage__c = element.Rpl_10th_Percentage__c ? element.Rpl_10th_Percentage__c : '';
            this.studentRegform.Rpl_10th_Board_Name__c = element.Rpl_10th_Board_Name__c ? element.Rpl_10th_Board_Name__c : '';
            this.studentRegform.Rpl_10th_Year_of_passing__c = element.Rpl_10th_Year_of_passing__c ? element.Rpl_10th_Year_of_passing__c : '';
            this.studentRegform.Rpl_Interested_in_placement__c = element.Rpl_Interested_in_placement__c ? element.Rpl_Interested_in_placement__c : '';
            this.studentRegform.Rpl_Branch__c = element.Rpl_Branch__c ? element.Rpl_Branch__c : '';
            this.studentRegform.Rpl_12th_Percentage__c = element.Rpl_12th_Percentage__c ? element.Rpl_12th_Percentage__c : '';
            this.studentRegform.Rpl_Sem_1_CGPA__c = element.Rpl_Sem_1_CGPA__c ? element.Rpl_Sem_1_CGPA__c : '';
            this.studentRegform.Rpl_Sem_2_CGPA__c = element.Rpl_Sem_2_CGPA__c ? element.Rpl_Sem_2_CGPA__c : '';
            this.studentRegform.Rpl_Sem_3_CGPA__c = element.Rpl_Sem_3_CGPA__c ? element.Rpl_Sem_3_CGPA__c : '';
            this.studentRegform.Rpl_Sem_4_CGPA__c = element.Rpl_Sem_4_CGPA__c ? element.Rpl_Sem_4_CGPA__c : '';
            this.studentRegform.Rpl_Sem_5_CGPA__c = element.Rpl_Sem_5_CGPA__c ? element.Rpl_Sem_5_CGPA__c : '';
            this.studentRegform.Rpl_Sem_6_CGPA__c = element.Rpl_Sem_6_CGPA__c ? element.Rpl_Sem_6_CGPA__c : '';
            this.studentRegform.Rpl_Sem_7_CGPA__c = element.Rpl_Sem_7_CGPA__c ? element.Rpl_Sem_7_CGPA__c : '';
            this.studentRegform.Rpl_Sem_8_CGPA__c = element.Rpl_Sem_8_CGPA__c ? element.Rpl_Sem_8_CGPA__c : '';
            this.studentRegform.Rpl_Pan_Card_No__c = element.Rpl_Pan_Card_No__c ? element.Rpl_Pan_Card_No__c : '';
            this.studentRegform.Rpl_UG_College_Name__c = element.Rpl_UG_College_Name__c ? element.Rpl_UG_College_Name__c : '';
            this.studentRegform.Rpl_UG_Degree__c = element.Rpl_UG_Degree__c ? element.Rpl_UG_Degree__c : '';
            this.studentRegform.Rpl_UG_Year_of_Graduation__c = element.Rpl_UG_Year_of_Graduation__c ? element.Rpl_UG_Year_of_Graduation__c : '';
            this.studentRegform.Rpl_UG_CGPA__c = element.Rpl_UG_CGPA__c ? element.Rpl_UG_CGPA__c : '';
            this.studentRegform.Rpl_Diploma_Graduation_Year__c = element.Rpl_Diploma_Graduation_Year__c ? element.Rpl_Diploma_Graduation_Year__c : '';
            this.studentRegform.Rpl_Diploma_University__c = element.Rpl_Diploma_University__c ? element.Rpl_Diploma_University__c : '';
            this.studentRegform.Rpl_Current_Backlogs__c = element.Rpl_Current_Backlogs__c ? element.Rpl_Current_Backlogs__c : 0;
            this.studentRegform.Rpl_12th_Board_Name__c = element.Rpl_12th_Board_Name__c ? element.Rpl_12th_Board_Name__c : '';
            this.studentRegform.Rpl_12th_Year_of_passing__c = element.Rpl_12th_Year_of_passing__c ? element.Rpl_12th_Year_of_passing__c : '';
            this.studentRegform.Father_Name__c = element.Father_Name__c ? element.Father_Name__c : '';
            this.studentRegform.Mother_Name__c = element.Mother_Name__c ? element.Mother_Name__c : '';
            this.studentRegform.Rpl_Current_Address__c = element.Rpl_Current_Address__c ? element.Rpl_Current_Address__c : '';
            this.studentRegform.RPL_Permanent_Address__c = element.RPL_Permanent_Address__c ? element.RPL_Permanent_Address__c : '';
            this.studentRegform.Rpl_Cleared_Backlogs__c = element.Rpl_Cleared_Backlogs__c ? element.Rpl_Cleared_Backlogs__c : 0;
            this.studentRegform.Rpl_Total_Backlogs__c = element.Rpl_Total_Backlogs__c ? element.Rpl_Total_Backlogs__c : 0;
            this.studentRegform.Rpl_Education_Gap__c = element.Rpl_Education_Gap__c ? element.Rpl_Education_Gap__c : 0;
            this.studentRegform.Rpl_UG_Board_Name_University_Name__c = element.Rpl_UG_Board_Name_University_Name__c ? element.Rpl_UG_Board_Name_University_Name__c : '';
            this.studentRegform.Rpl_UG_Stream__c = element.Rpl_UG_Stream__c ? element.Rpl_UG_Stream__c : '';
            this.studentRegform.Rpl_PG1_Specialization__c = element.Rpl_PG1_Specialization__c ? element.Rpl_PG1_Specialization__c : '';
            this.studentRegform.Rpl_PG2_Specialization__c = element.Rpl_PG2_Specialization__c ? element.Rpl_PG2_Specialization__c : '';
            this.studentRegform.Rpl_PG1_Sem_CGPA__c = element.Rpl_PG1_Sem_CGPA__c ? element.Rpl_PG1_Sem_CGPA__c : '';
            this.studentRegform.Rpl_PG2_Sem_CGPA__c = element.Rpl_PG2_Sem_CGPA__c ? element.Rpl_PG2_Sem_CGPA__c : '';
            this.studentRegform.Rpl_PG3_Sem_CGPA__c = element.Rpl_PG3_Sem_CGPA__c ? element.Rpl_PG3_Sem_CGPA__c : '';
            this.studentRegform.Rpl_PG4_Sem_CGPA__c = element.Rpl_PG4_Sem_CGPA__c ? element.Rpl_PG4_Sem_CGPA__c : '';
            this.studentRegform.Rpl_Parents_Contact_No__c = element.Rpl_Parents_Contact_No__c ? element.Rpl_Parents_Contact_No__c : '';
            this.studentRegform.Rpl_DiplomaName__c = element.Rpl_DiplomaName__c ? element.Rpl_DiplomaName__c : '';
            this.studentRegform.Rpl_Diploma_Percentage__c = element.Rpl_Diploma_Percentage__c ? element.Rpl_Diploma_Percentage__c : '';
            this.studentRegform.Rpl_Student_Image__c = element.Rpl_Student_Image__c ? element.Rpl_Student_Image__c : '';
            this.studentRegform.Rpl_Is_Student_Details_Verified__c = element.Rpl_Is_Student_Details_Verified__c ? element.Rpl_Is_Student_Details_Verified__c : '';
            this.studentRegform.Rpl_Is_Graduation_Details_Verified__c = element.Rpl_Is_Graduation_Details_Verified__c ? element.Rpl_Is_Graduation_Details_Verified__c : '';
            this.studentRegform.Rpl_Tenth_CGPA__c = element.Rpl_Tenth_CGPA__c ? element.Rpl_Tenth_CGPA__c : 0;
            this.studentRegform.Rpl_Twelfth_CGPA__c = element.Rpl_Twelfth_CGPA__c ? element.Rpl_Twelfth_CGPA__c : 0;
            this.studentRegform.Rpl_First_Name__c = element.Rpl_First_Name__c ? element.Rpl_First_Name__c : '';
            this.studentRegform.Rpl_Middle_Name__c = element.Rpl_Middle_Name__c ? element.Rpl_Middle_Name__c : '';
            this.studentRegform.Rpl_Last_Name__c = element.Rpl_Last_Name__c ? element.Rpl_Last_Name__c : '';
            this.studentRegform.Rpl_Pan_Card_No__c = element.Rpl_Pan_Card_No__c ? element.Rpl_Pan_Card_No__c : '';
            this.studentRegform.Rpl_Reason_For_Education_Gap__c = element.Rpl_Reason_For_Education_Gap__c ? element.Rpl_Reason_For_Education_Gap__c : '';
            this.studentRegform.Rpl_Program_Type__c = element.Rpl_Program_Type__c || '';
            const programType = this.studentRegform.Rpl_Program_Type__c;
            this.isPGStudent = programType === 'PG';
            this.isUGStudent = programType === 'UG';            
                this.studentRegform.Rpl_Branch_Name__c = element.Rpl_Branch_Name__c || '';
                this.isDiplomaStudent = element.Rpl_Is_Diploma_Student__c;
                this.isTwelvethStudent = !this.isDiplomaStudent;
                });
        if (this.stepNumber == 1) {
            this.updateCheckboxes();
        }
        if( this.studentRegform.Rpl_Program_Type__c == 'UG'){
            this.isPgDetailsOnly = false;
            this.isUgDetailsOnly = true;

        }else{
            this.isPgDetailsOnly = true;
            this.isUgDetailsOnly = false;
        }

            this.validity = this.studentRegform.Rpl_Student_Image__c ? true : false;
            this.isSubmitButtonDisabled = this.studentRegform.Rpl_Is_Student_Details_Verified__c;
            this.isSpinner = false;
            this.setUgAndPgMarksRequired(this.totalYears, this.studentRegform.Rpl_Branch_Name__c, this.isDiplomaStudent);
        }else if(result.data && result.data.length==0){
            return refreshApex(this.wiredResult);
        }else if(result.error){

              this.isSpinner = false;
        }

    }

    updateCheckboxes() {
     if (this.placementInterestCheckbox) {
        this.placementInterestCheckbox.checked = this.studentRegform.Rpl_Interested_in_placement__c === "Yes";
    }
    if (this.placementNotInterestCheckbox) {
        this.placementNotInterestCheckbox.checked = this.studentRegform.Rpl_Interested_in_placement__c === "No";
    }
    }
    updateMarks() {
        let tenthAggregate = this.studentRegform.Rpl_10th_Percentage__c ? this.studentRegform.Rpl_10th_Percentage__c : this.studentRegform.Rpl_Tenth_CGPA__c  ? this.studentRegform.Rpl_Tenth_CGPA__c  :0;
        let twelfthAggregate = this.studentRegform.Rpl_12th_Percentage__c ? this.studentRegform.Rpl_12th_Percentage__c :  this.studentRegform.Rpl_Twelfth_CGPA__c  ?  this.studentRegform.Rpl_Twelfth_CGPA__c  :0;
        this.studentRegform.Rpl_Tenth_CGPA__c = tenthAggregate <= 10 ? tenthAggregate : 0;
        this.studentRegform.Rpl_10th_Percentage__c = tenthAggregate > 10 ? tenthAggregate : 0;
        this.studentRegform.Rpl_Twelfth_CGPA__c = twelfthAggregate <= 10 ? twelfthAggregate : 0;
        this.studentRegform.Rpl_12th_Percentage__c = twelfthAggregate > 10 ? twelfthAggregate : 0;
        this.studentRegform.Rpl_Diploma_Percentage__c = this.studentRegform.Rpl_Diploma_Percentage__c ? this.studentRegform.Rpl_Diploma_Percentage__c : 0;
        this.isShowUgSem1 = !this.studentRegform.Rpl_Diploma_Percentage__c;
        this.isShowUgSem2 = ! this.studentRegform.Rpl_Diploma_Percentage__c;

    }

    showToast(fieldName = '') {
        const event = new ShowToastEvent({
            title: 'Error',
            message: fieldName,
            variant: 'destructive'
        });
        this.dispatchEvent(event);
    }

    showToastSuccess(fieldName, Title) {
        const event = new ShowToastEvent({
            title: Title,
            message: fieldName,
            variant: 'success'
        });
        this.dispatchEvent(event);
    }

    overAllPercentageCalculation() {
        let numberOfUgSem = 0;
        let ugOverallSum = 0;

        // UG Calculation
        for (let i = 1; i <= 8; i++) {
            let semCGPA = this.studentRegform[`Rpl_Sem_${i}_CGPA__c`];
            if (semCGPA) {
                numberOfUgSem += 1;
                ugOverallSum += parseFloat(semCGPA);
            }

        }
        let UGAggregate = numberOfUgSem == 0 ? 0 : (ugOverallSum / numberOfUgSem).toFixed(1);
        this.studentRegform.Rpl_UG_Overall_Percentage__c = UGAggregate > 10 ? UGAggregate : 0;
        this.studentRegform.Rpl_UG_Overall_CGPA__c = UGAggregate < 10 ? UGAggregate : 0;

    

        // UG Cumulative Mark
        let ugCumulativeMark = this.studentRegform.Rpl_UG_CGPA__c;
        if (ugCumulativeMark && ugCumulativeMark >0) {
            this.studentRegform.Rpl_UG_Overall_Percentage__c = ugCumulativeMark > 10 ? ugCumulativeMark : 0;
            this.studentRegform.Rpl_UG_Overall_CGPA__c = ugCumulativeMark < 10 ? ugCumulativeMark : 0;
        }

        let numberOfPgSem = 0;
        let pgOverallSum = 0;

        // PG Calculation
        for (let i = 1; i <= 4; i++) {
            let semCGPA = this.studentRegform[`Rpl_PG${i}_Sem_CGPA__c`];
            if (semCGPA) {
                numberOfPgSem += 1;
                pgOverallSum += parseFloat(semCGPA);
            }
        }

        let PGAggregate = numberOfPgSem === 0 ? 0 : (pgOverallSum / numberOfPgSem).toFixed(1);
        this.studentRegform.Rpl_PG_Overall_Percentage__c = PGAggregate > 10 ? PGAggregate : 0;
        this.studentRegform.Rpl_PG_OVerall_CGPA__c = PGAggregate < 10 ? PGAggregate : 0;
    }

    validateUgandPgMarks() {
        if (this.isDiplomaStudent && this.studentRegform.Rpl_Program_Type__c == 'UG') {
            for (let i = 3; i <= 8; i++) {
            const input = this.template.querySelector(`[data-label="Rpl_Sem_${i}_CGPA__c"]`);
            if(!input.reportValidity()){
                return false;
            }
        }
        }

        else if(this.studentRegform.Rpl_Program_Type__c == 'UG'){
        for (let i = 1; i <= 8; i++) {
            const input = this.template.querySelector(`[data-label="Rpl_Sem_${i}_CGPA__c"]`);
            if(!input.reportValidity()){
                return false;
            }
        }
        }else if(this.studentRegform.Rpl_Program_Type__c == 'PG'){
            for (let i = 1; i <= 4; i++) {
            const input = this.template.querySelector(`[data-label="Rpl_PG${i}_Sem_CGPA__c"]`);
            if(!input.reportValidity()){
                return false;
            }
            }
            const input = this.template.querySelector(`[data-label="Rpl_UG_CGPA__c"]`);
            if(!input.reportValidity()){
                return false;
            }
        }
        return true;
    }

}