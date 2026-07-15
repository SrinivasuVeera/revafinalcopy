import { LightningElement, api, wire, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getApplicationRelatedRecords from '@salesforce/apex/AdmissionsProcessUtility.getApplicationRelatedRecords';
import UnlockApplicationRecord from '@salesforce/apex/AdmissionsProcessUtility.UnlockApplicationRecord';
import getContactOwnerInfo from '@salesforce/apex/AdmissionsProcessUtility.getContactOwnerInfo';
import submitConcessionForApproval from '@salesforce/apex/AdmissionsProcessUtility.submitConcessionForApproval';
import updateFeeStructureAndContact from '@salesforce/apex/AdmissionsProcessUtility.updateFeeStructureAndContact';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';

import Student_FEE__OBJECT from '@salesforce/schema/Student_Fee__c';
import CONTACT__FIELD from '@salesforce/schema/Student_Fee__c.Contact__c';
import NAME__FIELD from '@salesforce/schema/Student_Fee__c.Name';
import FEE_MASTER__FIELD from '@salesforce/schema/Student_Fee__c.Fee_Master__c';
import FEE_PAYMENT_CRITERIA__FIELD from '@salesforce/schema/Student_Fee__c.Fee_Payment_Criteria__c';
import AMOUNT_PENDING__FIELD from '@salesforce/schema/Student_Fee__c.Amount_Pending__c';
import AMOUNT_PAID__FIELD from '@salesforce/schema/Student_Fee__c.Amount_Paid__c';
import AMOUNT_TOTAL__FIELD from '@salesforce/schema/Student_Fee__c.Amount__c';
import FEE_TYPE__FIELD from '@salesforce/schema/Student_Fee__c.Fee_Type__c';
import ID__FIELD from '@salesforce/schema/Student_Fee__c.Id';
import SEAT_BLOCKING_PAYMENT_OPTION__FIELD from '@salesforce/schema/Student_Fee__c.Seat_Blocking_Payment_Option__c';
import PROVISIONAL_ADMISSION_FEE__FIELD from '@salesforce/schema/Student_Fee__c.Provisional_Admission_Fee__c';
import CONCESSION_FIELD from '@salesforce/schema/Student_Fee__c.Concession__c';
import PREMIUM_FIELD from '@salesforce/schema/Student_Fee__c.Premium__c';
import SCHOLARSHIP_FIELD from '@salesforce/schema/Student_Fee__c.Scholarship__c';
import ACTUAL_PROGRAM_FEE__FIELD from '@salesforce/schema/Student_Fee__c.Actual_Program_Fee__c';
import FEE_YEAR__FIELD from '@salesforce/schema/Student_Fee__c.Fee_Year__c';
import DISPLAY_NUMBER__FIELD from '@salesforce/schema/Student_Fee__c.Display_No__c';
import DUE_DATE__FIELD from '@salesforce/schema/Student_Fee__c.Due_Date__c';
import STUDENT_PERSONAL_MAIL__FIELD from '@salesforce/schema/Student_Fee__c.Student_Personal_Email__c';
import STUDENT_MOBILE_NUMBER__FIELD from '@salesforce/schema/Student_Fee__c.Student_Mobile_Number__c';
import FATHER_MOBILE_NUMBER__FIELD from '@salesforce/schema/Student_Fee__c.Father_Mobile_Number__c';
import FATHER_EMAIL_ID__FIELD from '@salesforce/schema/Student_Fee__c.Father_Email_ID__c';
import MOTHER_EMAIL_ID__FIELD from '@salesforce/schema/Student_Fee__c.Mother_Email_ID__c';
import MOTHER_MOBILE_NUMBER__FIELD from '@salesforce/schema/Student_Fee__c.Mother_Mobile_Number__c';
import SCHOLARSHIP_CATEGORY_FIELD from '@salesforce/schema/Student_Fee__c.Scholarship_Categories__c';
import SCHOLARSHIP_SUB_CATEGORY_FIELD from '@salesforce/schema/Student_Fee__c.Scholarship_Sub_Category__c';
import SCHOLARSHIP_DATE_FIELD from '@salesforce/schema/Student_Fee__c.Scholarship_Date__c';
import COINSELOR_NAME_FIELD from '@salesforce/schema/Student_Fee__c.Counselor_Name__c';
import SCHOLARSHIP_CREATED_BY_FIELD from '@salesforce/schema/Student_Fee__c.Scholarship_Created_by__c';
import SCHOLARSHIP_PERCENTAGE from '@salesforce/schema/Student_Fee__c.Scholarship_Percentage__c';
import APPLICATION_RECORD_ID__FIELD from '@salesforce/schema/hed__Application__c.Id';
import FIRST_YEAR_CONCESSION__FIELD from '@salesforce/schema/hed__Application__c.Concession_1st_Year__c';
import SECOND_YEAR_CONCESSION__FIELD from '@salesforce/schema/hed__Application__c.Concession_2nd_Year__c';
import THIRD_YEAR_CONCESSION__FIELD from '@salesforce/schema/hed__Application__c.Concession_3rd_Year__c';
import FOURTH_YEAR_CONCESSION__FIELD from '@salesforce/schema/hed__Application__c.Concession_4th_Year__c';
import FIFTH_YEAR_CONCESSION__FIELD from '@salesforce/schema/hed__Application__c.Concession_5th_Year__c';
import SCHOLARSHIP_LOOKUP_FIELD from '@salesforce/schema/hed__Application__c.hed_Scholarship__c';
import ADDITIONAL_DOCUMENTS_REQUIRED__FIELD from '@salesforce/schema/hed__Application__c.Additional_Documents_Required__c';
import ADDITIONAL_DOCUMENTS_FIELD from '@salesforce/schema/hed__Application__c.Additional_Documents__c';
import CONCESSION_REMARKS__FIELD from '@salesforce/schema/hed__Application__c.Concession_Remarks__c';
import FEE_STRUCTURE_DEFINED__FIELD from '@salesforce/schema/hed__Application__c.Fee_Structure_Defined__c';
import hasLowPAFPermission from '@salesforce/customPermission/Allow_PAF_Less_Than_50';


export default class FeeDetailsComponent extends LightningElement {
    @api recordId;
    @api applicableForAllYears = false;
    @api discountedPercentage = 0;
    @api scholarDisAmount = 0;
    @api scholarDisAmount2ndYear = 0;
    @api scholarDisAmount3rdYear = 0;
    @api scholarDisAmount4thYear = 0;
    @api scholarDisAmount5thYear = 0;
    @api scholarshipId;
    @api selectedScholarCategory;
    @api selectedScholarSubCategory;
    @api OtherSelectedCategory;
    @api OtherSelectedSubCategory;
    @api scholarshipRequiredDocs;

    @track scholarshipDetails = false;
    @track showChildCom = false;
    @track contactDetails;
    @track contactName;
    @track title;
    @track message;
    @track variant;
    @track type;
    @track programType;
    @track isDocumentsRequired = true;
    @track admissionMode;
    @track enrolmentype;
    @track quota;
    @track PAFStatus;
    @track Category;
    @track selectedSchool;
    @track selectedProgram;
    @track tenthMarks;
    @track twelfthMarks;
    @track ugMarks;
    @track pgMarks;
    @track ugEducationHistory;
    @track pgEducationHistory;
    @track tenthEducationHistory;
    @track ApplicationId;
    @track twelfthEducationHistory;
    @track wiredValues;
    @track feeMasters;
    @track feePaymentCriterias;
    @track error;
    @track data;
    @track completeData;
    @track tuitionFees;
    @track universityFees
    @track tuitionFeeAmount;
           finalYearTuitionFeeAmount;
    @track paymentStatus;
    @track totalTuitionFees;
    @track totalUniversityFees = 0;
    @track totalConcession = 0;
    @track totalScholarship = 0;
    @track totalSeatBlockingAmount = 0;
    @track balanceAmountToBePaid = 0
    @track universityFeeAmount;
    @track numberOfYears;
    @track numberOfYearsArray = [];
    @track feeArray = [];
    @track years = ["1st Year", "2nd Year", "3rd Year", "4th Year", "5th Year"];
    @track inputConcessionValues = [];
    @track inputPremiumValues = [];
    @track inputSeatBlockingAmount = [];
    @track inputSchloarshipAmounts = [];
    @track updatedScholarshipAmounts = [];
    @track varUpdatedFeeMaster = [];
    @track tutionFeesArray = [];
    @track updateBalanceFees;
    @track finalIndex;
    @track studentTuitionFeeAmounts = [];
    @track studentUniversityFeeAmounts = [];
    @track existingStudentFeerecords = [];
    @track tuitionFeeRecordIds = {};
    @track universityFeeRecordIds = {};
    @track seatBlockingFeeRecordId = [];
    @track updatedInputConsessionValues = [];
    @track updatedInputSeatBlockValues = [];
    @track updatedInputPremiumValues = [];
    @track updatedBalanceFeeInputValues = [];
    @track existingFeeRecordsBalanceFees = [];
    @track existingPremiumRecords = [];
    @track totalBalanceFee;
    @track totalPremium = 0;
    @track BalanceFee = [];
    @track scholarShipAmounts = [];
    @track scholarshipDifferenceAmount;
    @track scholarshipDifference = []
    @track existingConcessionRecords = [];
    @track existingScholarshipRecords = [];
    @track ApplicationConcessionStatus;
    @track programFeeAmount;
           finalYearProgramFeeAmount;
    @track programFees;
    @track tutionFeeRecords = {};
    @track seatBlockingRecords = {};
    @track universityFeeRecords = {};
    @track tutionFeeRecordAmounts = [];
    @track seatBlockingRecordAmounts = [];
    @track universityFeeRecordAmounts = [];
    @track tuitionFeeValues = [];
    @track BalanceFeesInputValues = [];
    @track applicationDetails;
    @track universityTotalCalculatedAmount = [];
    @track tuitionTotalCalculatedAmount = [];
    @track discountedAmount = 0;
    @track showInfo = false;
    @track amountPendingDifference;
    @track showError = false;
    @track showError2 = false;
    @track errorText;
    @track errorText2;
    @track mainRemarks;
    @track remarksInput;
    @track existingConcessionRemarks = [];
    @track title;
    @track message;
    @track variant;
    @track dueDate=[];
    @track seatBlockingAmountDueDateString;
    @track ApplicantMobileNumber;
    @track ApplicantEmailId;
    @track FatherMobileNumber;
    @track FatherEmailId;
    @track MotherEmailId;
    @track MotherMobileNumber;
    @track SBA;
    @track PaidTuitionFees=[];
    @track PaidUniversityFees=[];
    @track showConfirmationModal=false;
    @track existingAdditionalDocuments;
    @track existingScholarshipDocuments;
    @track additionalDocuments
    @track showLoadingModal = false;
    @track applicationScholarshipRecordId;
    @track applicationRecordReload=false;
    @track TuitionFeeRecordsReload=false;
    @track UniversityFeeRecordsReload=false;
    @track feeStructureDefined = false;
    //showRequestConcessionButton = false;
     SBAI;
    recordOwnerUsername;
    currentUserUsername;
    currentUserUserProfileName;
    paymentAmount;
    localTotalUniversityFee = 0;
    @track scholarshipDate;
    @track lateralenrtryFinalYear = {};
    @track  finalYearpaf= [];
    @track premiumAmount;
    connectedCallback() {
      this.scholarshipDate = new Date().toISOString().split('T')[0];

    }
   
    //RENDERING
    renderedCallback() {  
        const seatBlockingInputs = this.template.querySelectorAll('.SeatBlockingAmount');
        const premiumInputs = this.template.querySelectorAll('.Premium');
        const concessionInputs = this.template.querySelectorAll('.Concession');
        const tuitionInputs =this.template.querySelectorAll('.TuitionFees');
        const universityInputs = this.template.querySelectorAll('.UniversityFees');
        const scholarshipInputs = this.template.querySelectorAll('.Scholarship');
      
        universityInputs.forEach((input,index)=>{
            if (index >=1) {
                // console.log('INPUT',input)
                input.type = "number"
                input.formatter="currency"
                input.step="1"
            }
        })
        tuitionInputs.forEach((input, index)=>{
            if (index >=1) {
                // console.log('INPUT',input.type)
                input.type = "number"
                input.formatter="currency"
                input.step="1"
            }
        })
        scholarshipInputs.forEach((input, index)=>{
            if (index >=1) {
                // console.log('INPUT',input.type)
                input.type = "number"
                input.formatter="currency"
                input.step="1"
            }
        })

        seatBlockingInputs.forEach((input, index) => {
         
            if (index === 0) {
                input.readOnly = true;
            }
            else  {
                input.type = "number";
                input.formatter="currency"
                input.step="1"
            }
            
        });

        concessionInputs.forEach((input, index) => {
            if (index === 0) {
                input.readOnly = true;
            }
            else {
                input.type ="number"
                input.formatter="currency"
                input.step="1"
            }
        })

        premiumInputs.forEach((input, index) => {
            if (index === 0) {
                input.readOnly = true;
            } else {
                input.type ="number"
                input.formatter="currency"
                input.step="1"
            }
        })


        if (["Under Approval", "Initiated"].includes(this.ApplicationConcessionStatus)) {
            const inputs = this.template.querySelectorAll(".Concession");
            const remarksInputs = this.template.querySelectorAll('.Remarks');
            inputs.forEach((input, index) => {
                if (index >= 1) {
                    input.disabled = true;
                }
            });
            remarksInputs[0].disabled = true;
            // console.log("REMARKS", this.existingConcessionRemarks[0])
            remarksInputs[0].value = this.existingConcessionRemarks[0];
        }
        else if (this.ApplicationConcessionStatus === 'Approved') {
            const remarksInputs1 = this.template.querySelectorAll('.Remarks');
            remarksInputs1[0].value = this.existingConcessionRemarks[0];
        }

       /* if (this.PAFStatus) {
            const SBAI = this.template.querySelectorAll(".SeatBlockingAmount");
            SBAI[1].disabled = true;
        }*/

             else if (this.ApplicationConcessionStatus === 'Approved') {
            const remarksInputs1 = this.template.querySelectorAll('.Remarks');
            remarksInputs1[0].value = this.existingConcessionRemarks[0];
        }

        /*if (this.PAFStatus) {
            const SBAI = this.template.querySelectorAll(".SeatBlockingAmount");
            SBAI[1].disabled = true;
        }*/
       const SBAI = this.template.querySelectorAll(".SeatBlockingAmount");

if (this.feeStructureDefined) {
    SBAI.forEach(input => {
        input.disabled = true;
        input.readOnly = true;
    });
}
else if (this.PAFStatus) {
    SBAI[1].disabled = true;
}

        const submitButton = this.template.querySelectorAll('lightning-button.Submit');
        //const SBAI = this.template.querySelectorAll(".SeatBlockingAmount");
       /* if (SBAI.length > 0) {
                 this.SBAI = SBAI;
        for(let i=2;i<this.feeArray.length-1;i++){
            if(this.feeArray[i].SeatBlockingAmount ===0 || this.feeArray[i].SeatBlockingAmount ==='0' || this.feeArray[i].SeatBlockingAmount ===''){
                
            this.SBAI[i].disabled = true;
            } 
            if(this.inputSeatBlockingAmount[i-1]>0 && this.inputSeatBlockingAmount[i-1]== this.feeArray[i-1].BalanceFee){
                this.SBAI[i].disabled = false;
            }
            for(let i=2;i<this.feeArray.length;i++){
           
                if( ( this.inputSeatBlockingAmount[i-1] > 0 && this.inputSeatBlockingAmount[i-1] > this.feeArray[i-1].BalanceFee) ||  this.inputSeatBlockingAmount[i-1]===''){ 
                submitButton[0].disabled = true;
              this.showError = true;
              this.errorText = "Please enter a valid amount and deductions cannot be greater than Program Fee. Thank you!";
            }
        }
         }
        
    }*/
   if (SBAI.length > 0) {
    this.SBAI = SBAI;

    for(let i=2;i<this.feeArray.length-1;i++){

        if(this.feeArray[i].SeatBlockingAmount ===0 ||
           this.feeArray[i].SeatBlockingAmount ==='0' ||
           this.feeArray[i].SeatBlockingAmount ===''){

            this.SBAI[i].disabled = true;
        }

        if(this.inputSeatBlockingAmount[i-1] > 0 &&
           this.inputSeatBlockingAmount[i-1] == this.feeArray[i-1].BalanceFee){
            this.SBAI[i].disabled = false;
        }

        // Skip PAF validation once Fee Structure is defined
        if (!this.feeStructureDefined) {

            for(let j=2; j<this.feeArray.length; j++){

                if(
                    (this.inputSeatBlockingAmount[j-1] > 0 &&
                     this.inputSeatBlockingAmount[j-1] > this.feeArray[j-1].BalanceFee)
                     ||
                     this.inputSeatBlockingAmount[j-1] === ''
                ){
                    submitButton[0].disabled = true;
                    this.showError = true;
                    this.errorText =
                        "Please enter a valid amount and deductions cannot be greater than Program Fee. Thank you!";
                }
            }

        } else {
            // Fee Structure already defined
            // Allow Apply Scholarship + Update Fee Structure
            submitButton[0].disabled = false;
            this.showError = false;
        }
    }
}
    
   
        const BalancefeetoBePaid = this.template.querySelectorAll('.Balancetobepaid');
        BalancefeetoBePaid.forEach((input, index)=>{
            if (index >=1) {
                // console.log('INPUT',input.type)
                input.type = "number"
                input.formatter="currency"
                input.step="1"
            }
        })

       

        this.BalanceFeesInputValues = Array.from(BalancefeetoBePaid).map(BTP => BTP.value);
        const updatedBalanceFeeInputValues = this.BalanceFeesInputValues.slice(1, -1);
        if (updatedBalanceFeeInputValues.length > 0) {
            this.totalBalanceFee = updatedBalanceFeeInputValues.reduce((accumulator, currentValue) => Number(accumulator) + Number(currentValue));
        }
    }

    @wire(getContactOwnerInfo, { ApplicationRecordId: '$recordId' })
    wiredRecord({ error, data }) {
        if (data) {
            this.recordOwnerUsername = data.contactOwnerName;
        } else if (error) {
            console.error('Error fetching contact owner username: ', error);
        }
    }

    
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [Name, ProfileName]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            //this.ownerUsername = getFieldValue(data, OWNER_USERNAME_FIELD);
            this.currentUserUsername = data.fields.Name.value;
            this.currentUserUserProfileName = data.fields.Profile.value.fields.Name.value;
        }
    }
    

    //WIRED RECORDS
    @wire(getApplicationRelatedRecords, { ApplicationRecordId: '$recordId' })
    wiredApplicationDetails(value) {
        this.wiredValues = value;

        const { data, error } = value;
        if (data) {
            console.log("!!!!368",data);
            this.completeData = data;
             console.log("COMPLETE DATA", this.completeData);
            this.applicationDetails = data.ApplicationRecord;
            console.log('ApplicationDetails',this.applicationDetails);
            this.ApplicationId = data.ApplicationRecord.Id;
            this.feeStructureDefined = data.ApplicationRecord.Fee_Structure_Defined__c;
            this.applicationScholarshipRecordId = (data.ApplicationRecord.hed_Scholarship__c) ? data.ApplicationRecord.hed_Scholarship__c : '';
            if (data.AppliedScholarship) {
            this.existingScholarshipDocuments = (data.AppliedScholarship)? (data.AppliedScholarship.Documents_Required__c) : null;
            }
            else {
                this.existingScholarshipDocuments = '';
            }
            // console.log('exScholarshipDocuments', this.existingScholarshipDocuments);
            this.existingAdditionalDocuments = (this.applicationDetails.Additional_Documents__c)? (this.applicationDetails.Additional_Documents__c) : null;
            this.PAFStatus = data.ApplicationRecord.Provisional_Admission_Fee_Paid__c;
            this.ApplicationConcessionStatus = data.ApplicationRecord.Concession_Status__c;

            this.contactDetails = data.ApplicationContact;
            // console.log("COMPLETE DATA", this.contactDetails);
            this.type = data.ApplicationContact.Type__c;
            this.programType = data.ApplicationContact.Program_Type__c;
            this.Category = this.contactDetails.Select_Category__c;
            this.admissionMode = data.ApplicationContact.Admission_Mode__c;
            this.enrolmentype = data.ApplicationContact.Enrollment_Type__c;
            this.quota = data.ApplicationContact.Quota__c;
            this.contactName = this.contactDetails.Name;
            this.selectedSchool = this.contactDetails.School_Name__c
            this.selectedProgram = this.contactDetails.Academic_Program__c;
            this.ApplicantEmailId = this.contactDetails.Email ? this.contactDetails.Email : null;
            this.ApplicantMobileNumber = this.contactDetails.MobilePhone ? this.contactDetails.MobilePhone : null;
            this.FatherEmailId = this.contactDetails.Father_Email_ID__c ? this.contactDetails.Father_Email_ID__c : null;
            this.FatherMobileNumber = this.contactDetails.Father_Mobile_Number__c ? this.contactDetails.Father_Mobile_Number__c : null;
            this.MotherEmailId = this.contactDetails.Mother_Email_ID__c ? this.contactDetails.Mother_Email_ID__c : null;
            this.MotherMobileNumber = this.contactDetails.Mother_Mobile_Number__c ? this.contactDetails.Mother_Mobile_Number__c : null;
         
            //Concession Remarks Manipulation
            this.existingConcessionRemarks = [this.applicationDetails.Concession_Remarks__c];
            if (this.programType === 'UG') {
                if(this.contactDetails.hed__Education_History__r !== undefined){
                    this.tenthEducationHistory = this.contactDetails.hed__Education_History__r.find((educationHistory) => {
                        return (educationHistory.Type_of_Course__c === '10th');
                    })
                }
                if (this.tenthEducationHistory) {
                    this.tenthMarks = this.tenthEducationHistory.Percentage__c;
                }
                else if (error) {
                    try {
                        throw new Error(error.body.message);
                    } catch (e) {
                        this.error = e.message;
                    }
                }
                if(this.contactDetails.hed__Education_History__r !== undefined){
                    this.twelfthEducationHistory = this.contactDetails.hed__Education_History__r.find((educationHistory) => {
                        return (educationHistory.Type_of_Course__c === '12th');
                    })
                }
                if (this.twelfthEducationHistory) {
                    this.twelfthMarks = this.twelfthEducationHistory.Percentage__c;
                }
                else if (error) {
                    try {
                        throw new Error(error.body.message);
                    } catch (e) {
                        this.error = e.message;
                    }
                }
            }
            else if (this.programType === 'PG') {
                if(this.contactDetails.hed__Education_History__r !== undefined){
                    this.ugEducationHistory = this.contactDetails.hed__Education_History__r.find((educationHistory) => {
                        return (educationHistory.Type_of_Course__c === 'UG')
                    });
                }
                if (this.ugEducationHistory) {
                    this.ugMarks = this.ugEducationHistory.Percentage__c;
                }
                else if (error) {
                    try {
                        throw new Error(error.body.message);
                    } catch (e) {
                        this.error = e.message;
                    }
                }
            }
            this.feePaymentCriterias = data.FeePaymentCriterias;
            this.feeMasters = data.ApplicationFeeMasterRecords;
            console.log('456'+ this.feeMasters);
            this.existingStudentFeerecords = data.ApplicationStudentFeeRecords;

            this.FeeMasters();

        } else if (error) {
            console.log(error);
        }
    }
    //Unlock the Application Record
    unlockApplicationRecordId() {
        UnlockApplicationRecord({Id: '$recordId'})
    }

    get applyScholarshipDisabled() {

        if (this.feeArray.length > 1) {
            return (this.feeArray[this.feeArray.length - 1]).Scholarship > 0
          } else {
            return false;
          }
    }

    get removeScholarshipDisabled() {
    if (this.feeArray.length > 1) {
        return (this.feeArray[this.feeArray.length - 1]).Scholarship === 0;
      } else {
        return false;
      }
    }

    //FEEJSON MANIPULATION
    FeeMasters() {
        console.log('calling apex class1');
      
        this.getInputValues();
        this.feeArray = [];
        console.log('calling apex class2');
        console.log('calling apex class3'+JSON.stringify(this.feeMasters[0]));
         if (this.enrolmentype === 'Lateral Entry' && this.admissionMode === 'UQ') {
              this.numberOfYears  = 3;
         }
         else{
        this.numberOfYears =  this.feeMasters[0].Program_Batch__r.hed__Account__r.Program_Type__c === "Ph.D" ? 1 : this.feeMasters[0].Program_Batch__r.Number_of_Years__c;
       }
        console.log('numberOfYears1'+this.numberOfYears);
        if(this.feeMasters !== undefined){
            this.programFees = this.feeMasters.find((feeMaster) => {
                return (feeMaster.Fee_Type__c == 'Program Fee');
            })
        }

        console.log('numberOfYears11'+this.feeMasters[0].Program_Batch__c);
        console.log('numberOfYears11'+this.feeMasters[0].Program_Batch__r.Number_of_Years__c);
        console.log('numberOfYears11'+this.numberOfYears);
        if (this.programFees !== undefined) {
            this.programFeeAmount = this.programFees.Fee_Amount__c;
            this.premiumAmount = this.programFees.Premium_Amount__c;
        } else if (error) {
            console.log('Error in 518 line');
            try {
                console.log('error1>>'+error);
                throw new Error(error.body.message);
            } catch (e) {
                console.log('error2>>'+e);
                this.error = e.message;
            }
        }
        if(this.feeMasters !== undefined){
            this.universityFees = this.feeMasters.find((feeMaster) => {
                return (feeMaster.Fee_Type__c == 'University Fee');
            })
        }
        if (this.universityFees !== undefined) {
            this.universityFeeAmount = this.universityFees.Fee_Amount__c;
        } else if (error) {
            try {
                throw new Error(error.body.message);
            } catch (e) {
                this.error = e.message;
            }
        }

        this.tuitionFeeAmount = Number(this.programFeeAmount) - Number(this.universityFeeAmount);
        // this.totalUniversityFees = this.numberOfYears * this.universityFeeAmount;
        
        // for (let i = 1; i <= this.universityFees.length; i++) {
        //     this.localTotalUniversityFee += this.universityFees[i].Fee_Amount__c;
        // }
        // this.totalUniversityFees = this.universityFees.find((universityFee) => {
        //     return (universityFee.Fee_Amount__c += universityFee.Fee_Amount__c);
        //   });
        // console.log('line number 520 totalUniversityFees -->'+this.localTotalUniversityFee);
        let specialFeeRec;
        if(this.feeMasters !== undefined){
            specialFeeRec = this.feeMasters.find((feeMaster) => {
            return (feeMaster.Fee_Type__c == 'Final Year Special Fee');
            });
        }
        if (specialFeeRec !== undefined) {
          this.finalYearProgramFeeAmount = specialFeeRec.Fee_Amount__c;
          this.finalYearTuitionFeeAmount = specialFeeRec.Fee_Amount__c - this.universityFeeAmount;
        } else {
          this.finalYearProgramFeeAmount = this.programFeeAmount;
          this.finalYearTuitionFeeAmount = this.tuitionFeeAmount;
        }

        let feeNames = {
            "id": 0,
            "Name": "Fee Types",
            "TuitionFees": "Tuition Fee",
            "UniversityFees": "University Fee",
            "Scholarship": "Scholarship Amount",
            "Concession": "Concession Amount",
            "Premium": "Premium Amount",
            "SeatBlockingAmount": "Provisional Admission Fee",
            "BalanceFee": "Balance Fees"
        }
        this.feeArray.push(feeNames);
        
        const submitButton = this.template.querySelectorAll('lightning-button.Submit');
        submitButton[0].disabled = false;
        this.showError= false;

        this.totalUniversityFees = this.numberOfYears * this.universityFeeAmount;  
        this.totalTuitionFees = (this.numberOfYears - 1) * this.tuitionFeeAmount + this.finalYearTuitionFeeAmount;

        let totalFeeJson;

        if (this.enrolmentype === 'Lateral Entry' && this.admissionMode === 'UQ') {
         
            for (let i = 1; i <= 3; i++) {
                let feeJson;
                this.finalIndex = this.numberOfYears + 1;
                var feeScholarship = 0;
                var existingScholarship;
                var balanceExistingFees;
                var balanceJson = 0;
        
                if (this.existingStudentFeerecords.length === 0) {
                    if (this.scholarShipAmounts.length === 0) {
                        balanceJson = i === this.numberOfYears ? this.finalYearProgramFeeAmount : this.programFeeAmount;
                    } else {
                        feeScholarship = this.scholarShipAmounts[i - 1];
                       // balanceJson = Number(i === this.numberOfYears ? this.finalYearProgramFeeAmount : this.programFeeAmount) - Number(this.scholarShipAmounts[i - 1]);
                       balanceJson =
                                    (
                                        Number(i === this.numberOfYears
                                            ? this.finalYearProgramFeeAmount
                                            : this.programFeeAmount)
                                        + Number(this.premiumAmount || 0)
                                    )
                                    - Number(this.scholarShipAmounts[i - 1]);
                    }
        console.log('balanceJson::'+balanceJson);
                    feeJson = {
                        "id": i,
                        "Name": this.years[i],
                        "TuitionFees": i === this.numberOfYears ? this.finalYearTuitionFeeAmount : this.tuitionFeeAmount,
                        "UniversityFees": this.universityFeeAmount,
                        "Scholarship": feeScholarship,
                        "Concession": 0,
                       // "Premium": 0,
                        "Premium": this.premiumAmount || 0,
                        "SeatBlockingAmount": this.seatBlockingRecordAmounts[i - 1] || 0, // Use 0 if undefined
                        "BalanceFee": balanceJson
                    };
                    if (Number(balanceJson) < 0) {
                        submitButton[0].disabled = true;
                        this.showError = true;
                        this.errorText = "Scholarship shouldn't be greater than balance fees, Thank you!";
                    }
        
                } else {
                    this.StudentFeeRecords();
                    if (this.scholarShipAmounts.length === 0) {
                        existingScholarship = Number(this.existingScholarshipRecords[i - 1]);
                        balanceExistingFees = this.existingFeeRecordsBalanceFees[i - 1];
                    } else {
                        existingScholarship = this.scholarShipAmounts[i - 1];
                        if (this.PAFStatus === true) {
                            balanceExistingFees = this.programFeeAmount - 
                                Number(this.updatedInputConsessionValues[i - 1]) -
                                Number(existingScholarship) -
                                Number(this.seatBlockingRecordAmounts[i - 1] || 0) + 
                                Number(this.updatedInputPremiumValues[i - 1]);
                        } else {
                            balanceExistingFees = this.programFeeAmount - 
                                Number(this.updatedInputConsessionValues[i - 1]) -
                                Number(existingScholarship) +
                                Number(this.updatedInputPremiumValues[i - 1]);
                        }
                        if (Number(balanceExistingFees) < 0) {
                            submitButton[0].disabled = true;
                            this.showError = true;
                            this.errorText = "Scholarship shouldn't be greater than balance fees, Thank you!";
                        }
                    }
        
                    // Debugging logs
                    console.log('SeatBlockingAmount for year ' + i + ': ' + this.seatBlockingRecordAmounts[i - 1]);
        
                    feeJson = {
                        "id": i,
                        "Name": this.years[i],
                        "TuitionFees": i === this.numberOfYears ? this.finalYearTuitionFeeAmount : this.tuitionFeeAmount,
                        "UniversityFees": this.universityFeeAmount,
                        "SeatBlockingAmount": this.seatBlockingRecordAmounts[i] || 0, // Use 0 if undefined
                        "Concession": this.existingConcessionRecords[i - 1],
                        "Scholarship": existingScholarship,
                        "Premium": this.existingPremiumRecords[i - 1] || 0,
                        //"Premium": this.premiumAmount || 0,
                        "BalanceFee": balanceExistingFees
                    };
                }
                this.feeArray.push(feeJson);
            }
        
            console.log('HHH::' + this.finalYearpaf);
        }
        
        else{
        for (let i = 1; i <= this.numberOfYears; i++) {
            let feeJson;
            this.finalIndex = this.numberOfYears + 1;
            var feeScholarship = 0;
            var existingScholarship;
            var balanceExistingFees;
            var balanceJson = 0;
          
            if (this.existingStudentFeerecords.length === 0) {
                if (this.scholarShipAmounts.length === 0) {
                    balanceJson = (i === this.numberOfYears ? this.finalYearProgramFeeAmount : this.programFeeAmount)+this.premiumAmount;
                }
                else {
                    feeScholarship = this.scholarShipAmounts[i - 1]
                    //Shashi: Final year total fee calculation is wrong - issue maybe here
                   // balanceJson = Number(i === this.numberOfYears ? this.finalYearProgramFeeAmount : this.programFeeAmount) - Number(this.scholarShipAmounts[i - 1]);
                   balanceJson =(Number(i === this.numberOfYears ? this.finalYearProgramFeeAmount : this.programFeeAmount)+ Number(this.premiumAmount || 0))- Number(this.scholarShipAmounts[i - 1]);
                }
                let seatBlockingDefault = 0;

                if (i === 1) {
                    let totalFee = this.tuitionFeeAmount + this.universityFeeAmount + this.premiumAmount;
                    seatBlockingDefault = Math.round(totalFee * 0.5);
                } else {
                    seatBlockingDefault = 0;
                }

                feeJson = {
                    "id": i,
                    "Name":  this.years[i - 1],
                    "TuitionFees": i === this.numberOfYears ? this.finalYearTuitionFeeAmount : this.tuitionFeeAmount,
                    "UniversityFees": this.universityFeeAmount,
                    "Scholarship": feeScholarship,
                    "Concession": 0,
                    //"Premium": 0,
                    "Premium": this.premiumAmount || 0,
                    "SeatBlockingAmount": seatBlockingDefault,
                    "BalanceFee": balanceJson
                }
                if (Number(balanceJson) < 0) {
                    submitButton[0].disabled = true;
                    this.showError = true;
                    this.errorText = "Scholarship shouldn't be greater than balance fees, Thank you!";
                }

            } else {
                this.StudentFeeRecords();
                if (this.scholarShipAmounts.length === 0) {
                    existingScholarship = Number(this.existingScholarshipRecords[i - 1]);
                    balanceExistingFees = this.existingFeeRecordsBalanceFees[i - 1]
                }
                else {
                    existingScholarship = this.scholarShipAmounts[i - 1];
                    if (this.PAFStatus === true) {
                    balanceExistingFees = this.programFeeAmount - //i === this.numberOfYears ? this.finalYearProgramFeeAmount : 
                                            Number(this.updatedInputConsessionValues[i - 1]) -
                                            Number(existingScholarship) -
                                            Number(this.inputSeatBlockingAmount[i]) +
                                            Number(this.updatedInputPremiumValues[i - 1]);         
                    }       
                    else {
                        balanceExistingFees = this.programFeeAmount  //i === this.numberOfYears ? this.finalYearProgramFeeAmount : 
                                                - Number(this.updatedInputConsessionValues[i - 1]) 
                                                - Number(existingScholarship) 
                                                + Number(this.updatedInputPremiumValues[i - 1])
                    }
                   if (Number(balanceExistingFees) < 0) {
                        // console.log('GOINGINNN');
                        submitButton[0].disabled = true;
                        this.showError = true;
                        this.errorText = "Scholarship shouldn't be greater than balance fees, Thank you!";
                    }
                    
                }          
                   
                    feeJson = {
                        "id": i,
                        "Name": this.years[i - 1],
                        "TuitionFees": i === this.numberOfYears ? this.finalYearTuitionFeeAmount : this.tuitionFeeAmount,
                        "UniversityFees": this.universityFeeAmount,
                        "SeatBlockingAmount": i === 1 ? this.seatBlockingRecordAmounts[0] : 0,
                        "Concession": this.existingConcessionRecords[i - 1],
                        "Scholarship": existingScholarship,
                        "Premium": this.existingPremiumRecords[i - 1] || 0,
                        //"Premium": this.premiumAmount || 0,
                        "BalanceFee": balanceExistingFees
                    }
                
              

            }
            this.feeArray.push(feeJson);
           
        }
       }

        if (this.scholarShipAmounts.length === 0 && this.existingScholarshipRecords.length === 0) {
            this.totalScholarship = 0;
        } else if (this.scholarShipAmounts.length === 0) {
            this.totalScholarship = this.existingScholarshipRecords.reduce((acc, cur) => Number(acc) + Number(cur), 0);
        } else {
            this.totalScholarship = this.scholarShipAmounts.reduce((acc, cur) => Number(acc) + Number(cur), 0);
        }

        let totalCon = isNaN(this.totalConcession) ? 0 : this.totalConcession;
        let totalPremium = isNaN(this.totalPremium) ? 0 : this.totalPremium;
        let totalScholarship = isNaN(this.totalScholarship) ? 0 : this.totalScholarship;
        let totalSeatBlockingAmount = isNaN(this.totalSeatBlockingAmount) ? 0 : this.totalSeatBlockingAmount;
        if (this.PAFStatus === true) {
            this.totalBalanceFee = Number(this.totalTuitionFees) + Number(this.totalUniversityFees)
                                - Number(totalCon)
                                - Number(totalScholarship)
                                + Number(totalPremium)
                                - Number(totalSeatBlockingAmount);
        }
        else {
            this.totalBalanceFee = Number(this.totalTuitionFees) + Number(this.totalUniversityFees)
                                    - Number(totalCon)
                                    - Number(totalScholarship)
                                    + Number(totalPremium)

        }
    totalFeeJson = {
            "id": this.finalIndex,
            "Name": "Total Fees",
            "FeeName": "Total Fee Name",
            "TuitionFees": this.totalTuitionFees,
            "UniversityFees": this.totalUniversityFees,
            "Concession": this.totalConcession,
            "Scholarship": this.totalScholarship,
            "SeatBlockingAmount": this.feeArray[1] ? Number(this.feeArray[1].SeatBlockingAmount) : 0,
            "Premium": this.totalPremium,
            "BalanceFee": this.totalBalanceFee
        }
        this.feeArray.push(totalFeeJson);

        }

    //SCHOLARSHIP RECORDS MANIPULATION
handleClick(event) {
    // 1. Destructure values from event detail
    const { 
        discountAmount, 
        ApplicableFor, 
        scholarshipId, 
        scholarshipReqDocs, 
        discountPercentage,
        discountAmount2ndYear,
        discountAmount3rdYear,
        discountAmount4thYear,
        discountAmount5thYear,
        selectedScholarCategory,
        selectedScholarSubCategory,
        OtherSelectedCategory,
        OtherSelectedSubCategory 
    } = event.detail;
    
    this.scholarshipId = scholarshipId;
    this.applicableForAllYears = ApplicableFor;
    this.discountedPercentage = Number(discountPercentage) || 0;
    this.scholarDisAmount = Number(discountAmount) || 0;
    this.scholarDisAmount2ndYear = Number(discountAmount2ndYear) || 0;
    this.scholarDisAmount3rdYear = Number(discountAmount3rdYear) || 0;
    this.scholarDisAmount4thYear = Number(discountAmount4thYear) || 0;
    this.scholarDisAmount5thYear = Number(discountAmount5thYear) || 0;
    this.selectedScholarCategory = selectedScholarCategory;
    this.selectedScholarSubCategory = selectedScholarSubCategory;
    this.OtherSelectedCategory = OtherSelectedCategory;
    this.OtherSelectedSubCategory = OtherSelectedSubCategory;
    //alert('Scholarship Id : ' + this.scholarshipId);
  console.log('Selected Scholarship Id => ', this.scholarshipId);

    var filteredDocs;
    var existingScholarshipDocs = [];
    var existingDocs = [];
    if (scholarshipReqDocs) this.scholarshipRequiredDocs = scholarshipReqDocs;
    else this.scholarshipRequiredDocs = undefined;

    if (this.existingAdditionalDocuments) existingDocs = this.existingAdditionalDocuments.split(';');
    else existingDocs = null;

    if (this.existingScholarshipDocuments) existingScholarshipDocs = this.existingScholarshipDocuments.split(';');
    else existingScholarshipDocs = undefined;

    if (existingDocs !== null && existingScholarshipDocs !== undefined) {
        filteredDocs = existingDocs.filter((element) => !existingScholarshipDocs.includes(element));
    } else if (existingDocs) {
        filteredDocs = existingDocs;
    } else {
        filteredDocs = '';
    }

    if (this.scholarshipRequiredDocs) {
        this.additionalDocuments = filteredDocs ? filteredDocs.concat(this.scholarshipRequiredDocs).join(';') : this.scholarshipRequiredDocs;
    } else {
        this.additionalDocuments = filteredDocs ? (Array.isArray(filteredDocs) ? filteredDocs.join(';') : filteredDocs) : this.existingAdditionalDocuments;
    }
    this.isDocumentsRequired = true;

    this.scholarShipAmounts = new Array(this.numberOfYears).fill(0);
    const standardTotalFee = Number(this.programFeeAmount || 0) + Number(this.premiumAmount || 0);
    const finalYearTotalFee = Number(this.finalYearProgramFeeAmount || 0) + Number(this.premiumAmount || 0) ;

    // Check if either data is available to proceed with our logic
    if (this.scholarDisAmount > 0 || this.discountedPercentage > 0) {
        
        if (this.applicableForAllYears) {            
            const calculatedPctValue = (this.discountedPercentage / 100) * standardTotalFee;

            if (this.scholarDisAmount > 0 && this.discountedPercentage > 0) {
                if (this.scholarDisAmount >= calculatedPctValue) {
                    // Flat Amount is better
                    this.scholarShipAmounts.fill(this.scholarDisAmount);
                } else {                    
                    const stdVal = (this.discountedPercentage / 100) * standardTotalFee;
                    const finalVal = (this.discountedPercentage / 100) * finalYearTotalFee;
                    this.scholarShipAmounts.fill(stdVal);
                    this.scholarShipAmounts[this.scholarShipAmounts.length - 1] = finalVal;
                }
            }            
            else if (this.scholarDisAmount > 0) {
                this.scholarShipAmounts.fill(this.scholarDisAmount);
            }             
            else if (this.discountedPercentage > 0) {
                const stdVal = (this.discountedPercentage / 100) * standardTotalFee;
                const finalVal = (this.discountedPercentage / 100) * finalYearTotalFee;
                this.scholarShipAmounts.fill(stdVal);
                this.scholarShipAmounts[this.scholarShipAmounts.length - 1] = finalVal;
            }
        } 
        else {
            // Logic for Specific Years (Single year comparison)
            const firstYearPctValue = (this.discountedPercentage / 100) * standardTotalFee;
            
            // Choose the maximum between Amount and Percentage for Year 1
            this.scholarShipAmounts[0] = Math.max(this.scholarDisAmount, firstYearPctValue);
            
            // Following years take specific flat amounts if provided in Master
            if (this.scholarDisAmount2ndYear) this.scholarShipAmounts[1] = this.scholarDisAmount2ndYear;
            if (this.scholarDisAmount3rdYear) this.scholarShipAmounts[2] = this.scholarDisAmount3rdYear;
            if (this.scholarDisAmount4thYear) this.scholarShipAmounts[3] = this.scholarDisAmount4thYear;
            if (this.scholarDisAmount5thYear) this.scholarShipAmounts[4] = this.scholarDisAmount5thYear;
        }
    }

    // 5. Difference logic (Standard maintenance)
    this.scholarshipDifferenceAmount = Number(this.tuitionFeeAmount) - Number(this.scholarShipAmounts[0]);
    if (this.scholarshipDifferenceAmount < 0) {
        this.scholarshipDifference = this.applicableForAllYears 
            ? new Array(this.numberOfYears).fill(this.scholarshipDifferenceAmount) 
            : [this.scholarshipDifferenceAmount, ...new Array(this.numberOfYears - 1).fill(0)];
    } else {
        this.scholarshipDifference = new Array(this.numberOfYears).fill(0);
    }

    // 6. UI Reset & Final Recalculation
    this.showChildCom = false;
    this.scholarshipDetails = false;
    this.FeeMasters();
}


    StudentFeeRecords() {

        //TutionFee Existing Records
        this.tutionFeeRecords = this.existingStudentFeerecords.filter(record => record.Fee_Type__c === 'Tuition Fee');
        this.tuitionFeeRecordIds = this.tutionFeeRecords.map(record => record.Id);
        this.tuitionFeeRecordAmounts = this.tutionFeeRecords.map(record => Number(record.Amount__c));

        //Premium Existing Records
        this.existingPremiumRecords = this.tutionFeeRecords.map(record => Number(record.Premium__c));
        this.totalPremium = this.existingPremiumRecords.reduce((accumulator, currentValue) => accumulator + currentValue);

        //Scholarship Existing Records
        this.existingScholarshipRecords = this.tutionFeeRecords.map(record => Number(record.Scholarship__c));
        this.totalScholarship = this.existingScholarshipRecords.reduce((accumulator, currentValue) => accumulator + currentValue);

        //Paid Existing Records 
        this.PaidTuitionFees = this.tutionFeeRecords.map(record => Number(record.Amount_Paid__c));

        //UniversityFee Existing Records
        this.universityFeeRecords = this.existingStudentFeerecords.filter(record => record.Fee_Type__c === 'University Fee');
        this.universityFeeRecordIds = this.universityFeeRecords.map(record => record.Id);
        this.PaidUniversityFees = this.universityFeeRecords.map(record=>record.Amount_Paid__c);
        this.universityFeeRecordAmounts = this.universityFeeRecords.map(record => Number(record.Amount__c));
        this.universityTotalCalculatedAmount = this.universityFeeRecords.map(record => Number(record.Calculated_Total_Amount__c));
        this.tuitionTotalCalculatedAmount = this.tutionFeeRecords.map(record => Number(record.Calculated_Total_Amount__c));

        //Seatblocking Existing Records
        this.seatBlockingRecords = this.universityFeeRecords.filter(record => record.Fee_Year__c);
        this.seatBlockingRecordAmounts = new Array(this.numberOfYears).fill(0);
        this.seatBlockingRecords.forEach(record => {
            const yearIndex = parseInt(record.Fee_Year__c) - 1; // Adjust the year index
            this.seatBlockingRecordAmounts[yearIndex] += Number(record.Provisional_Admission_Fee__c);
        }); 

        //for latral entry Final Year
        this.lateralenrtryFinalYear = this.universityFeeRecords.filter(record => record.Fee_Year__c === '4th Year');
        this.finalYearpaf = this.lateralenrtryFinalYear.map(record=>record.Provisional_Admission_Fee__c);
      
        //Existing Concessions Manipulation
        this.existingConcessionRecords = [this.applicationDetails.Concession_1st_Year__c, this.applicationDetails.Concession_2nd_Year__c, this.applicationDetails.Concession_3rd_Year__c, this.applicationDetails.Concession_4th_Year__c, this.applicationDetails.Concession_5th_Year__c];
        this.totalConcession = 0;
        this.totalConcession = this.existingConcessionRecords.reduce((accumulator, currentValue) => {
            return isNaN(currentValue) ? accumulator : accumulator + Number(currentValue);
        }, 0);
        this.totalSeatBlockingAmount = 0;
        this.totalSeatBlockingAmount = this.seatBlockingRecordAmounts.reduce((accumulator, currentValue) => {
            return isNaN(currentValue) ? accumulator : accumulator + Number(currentValue);
        }, 0);
        //Concession Remarks Manipulation
        this.existingConcessionRemarks = [this.applicationDetails.Concession_Remarks__c];
        //Existing Fee Balance Maniupuation
          for (let i = 0; i < this.universityFeeRecordAmounts.length; i++) {
            const concession = isNaN(this.existingConcessionRecords[i]) ? 0 : Number(this.existingConcessionRecords[i]);
            const seatBA = isNaN(this.seatBlockingRecordAmounts[i]) ? 0 : Number(this.seatBlockingRecordAmounts[i]);
            if (this.ApplicationConcessionStatus === 'Approved') {
                if (this.PAFStatus === true) {
                this.existingFeeRecordsBalanceFees[i] = this.tuitionTotalCalculatedAmount[i] + this.universityTotalCalculatedAmount[i] - seatBA;
                }
                else {
                    this.existingFeeRecordsBalanceFees[i] = this.tuitionTotalCalculatedAmount[i] + this.universityTotalCalculatedAmount[i];
                }
            }
            else {
                if (this.PAFStatus === true) {
                this.existingFeeRecordsBalanceFees[i] = this.tuitionTotalCalculatedAmount[i] + this.universityTotalCalculatedAmount[i] - concession - seatBA;
                }
                else {
                    this.existingFeeRecordsBalanceFees[i] = this.tuitionTotalCalculatedAmount[i] + this.universityTotalCalculatedAmount[i] - concession;
                }
            }

        }
    }

    //INPUT VALUES MANIPULATION

    getInputValues() {
        console.log('inside getInputValues');
        
        //StudentFee Arrays
        this.studentTuitionFeeAmounts = new Array(this.numberOfYears).fill(this.tuitionFeeAmount);
        this.studentUniversityFeeAmounts = new Array(this.numberOfYears).fill(this.universityFeeAmount);

        //Concession Inputs
        const concessionInputs = this.template.querySelectorAll('.Concession');
        this.inputConcessionValues = [...concessionInputs].map(concessionInput => concessionInput.value);
        this.updatedInputConsessionValues = this.inputConcessionValues.filter((element) => {
            return element;
        });

        this.updatedInputConsessionValues.shift();
        this.updatedInputConsessionValues.pop();
        if (this.updatedInputConsessionValues.length != 0) {
            this.totalConcession = this.updatedInputConsessionValues.reduce((accumulator, currentValue) => Number(accumulator) + Number(currentValue));
        }
        else {
            this.totalConcession = 0;
        }
   
        //Premium Inputs
        const premiumInputs = this.template.querySelectorAll('.Premium');
        this.inputPremiumValues = [...premiumInputs].map(premiumInput => premiumInput.value);
        this.updatedInputPremiumValues = this.inputPremiumValues.filter((element) => {
            return element;
        });
        this.updatedInputPremiumValues.pop();
        this.updatedInputPremiumValues.shift();
        if (this.updatedInputPremiumValues.length != 0) {
            this.totalPremium = this.updatedInputPremiumValues.reduce((accumulator, currentValue) => Number(accumulator) + Number(currentValue));
        }
        //Scholarship Inputs
        const scholarshipInputs = this.template.querySelectorAll('.Scholarship');
        this.inputSchloarshipAmounts = [...scholarshipInputs].map(scholarshipInput => scholarshipInput.value);
        this.updatedScholarshipAmounts = this.inputSchloarshipAmounts.filter((element) => {
            return element;

        });
        this.updatedScholarshipAmounts.pop();
        this.updatedScholarshipAmounts.shift();
        if (this.updatedScholarshipAmounts.length != 0) {
            this.totalScholarship = this.updatedScholarshipAmounts.reduce((accumulator, currentValue) => Number(accumulator) + Number(currentValue));
        }
        //SeatBlocking Inputs
        const seatBlockingAmountInputs = this.template.querySelectorAll('.SeatBlockingAmount');
        // console.log(seatBlockingAmountInputs);
        this.inputSeatBlockingAmount = [...seatBlockingAmountInputs].map(seatBlockingAmountInput => seatBlockingAmountInput.value);

        let tuition = this.studentTuitionFeeAmounts[0];
        let university = this.studentUniversityFeeAmounts[0];

        let minSeatBlocking = (tuition + university) * 0.5;

        // ✅ NEW CONDITION: check if scholarship exists
        let scholarshipAmount  = Number(this.totalScholarship) || 0;

        // Entered event.preventDefault();
        let enteredPAF = Number(this.inputSeatBlockingAmount[1]) || 0;

        // Scholarship + PAF combined
        let totalCoveredAmount = scholarshipAmount + enteredPAF;

      //  if (!hasLowPAFPermission && Number(this.inputSeatBlockingAmount[1]) < minSeatBlocking) {
          if (!hasLowPAFPermission && totalCoveredAmount < minSeatBlocking) {
            const submitButton = this.template.querySelectorAll('lightning-button.Submit');

            submitButton[0].disabled = true;

            this.showError = true;
            this.errorText = `Provisional Admission Fee cannot be less than 50% (${Math.round(minSeatBlocking)})`;

            return;
        } else {
            const submitButton = this.template.querySelectorAll('lightning-button.Submit');

            submitButton[0].disabled = false;

            this.showError = false;
        }

        this.updatedInputSeatBlockValues = this.inputSeatBlockingAmount.filter((element) => {
            return element;
        });
        console.log('PAF'+this.inputSeatBlockingAmount);
        this.updatedInputSeatBlockValues.shift();
        this.updatedInputSeatBlockValues.pop();
        if (this.updatedInputSeatBlockValues.length != 0) {
            this.totalSeatBlockingAmount = this.updatedInputSeatBlockValues.reduce((accumulator, currentValue) => Number(accumulator) + Number(currentValue));
        }
        // else {
        //     this.totalSeatBlockingAmount = 0;
        // }
        this.SBA = this.PAFStatus ? this.inputSeatBlockingAmount[1] : 0
       

        //SeatBlocking FEE Amount Manipulation
        if ((Number(this.studentUniversityFeeAmounts[0] + this.scholarshipDifference[0]) >= 0) && (this.scholarshipDifference[0] !== undefined) && (this.inputSeatBlockingAmount[1] !==0 || (this.inputSeatBlockingAmount[1] !== undefined))) {
            this.amountPendingDifference = this.inputSeatBlockingAmount[1] - (this.studentUniversityFeeAmounts[0] + this.scholarshipDifference[0]);
        }
        else if (this.inputSeatBlockingAmount[1]==0 || !this.inputSeatBlockingAmount[1]) {
            this.amountPendingDifference = 0
        }
        else {
            this.amountPendingDifference = this.inputSeatBlockingAmount[1] - this.studentUniversityFeeAmounts[0];
        }

        //TuitionFee Inputs
        var tutionAmountInputs = this.template.querySelectorAll('.TuitionFees');
        this.tutionAmountInputs = [...tutionAmountInputs].map(tuitionInput => tuitionInput.value);

        //Balance Fee Inputs

        const BalanceInputs = this.template.querySelectorAll('.Balancetobepaid');
        this.BalanceFeesInputValues = [...BalanceInputs].map(BalanceInput => BalanceInput.value);
        const Balance = [...BalanceInputs].map(BalanceInput => BalanceInput.value);
        Balance.pop();
        Balance.shift();
        // this.BalanceFeesInputValues = BalanceInputs.some(BalanceInput=>BalanceInput.value);

        //BALANCE FEE AMOUNT MANIPULATION
        this.feeArray.forEach((fee, index) => {
            if (typeof (fee.TuitionFees) === "number" && typeof (fee.UniversityFees) === "number") {
                if (fee.id != this.finalIndex) {
                    if (this.PAFStatus === true) {
                    const BalanceIndex = fee.TuitionFees + fee.UniversityFees
                                            - Number(this.inputConcessionValues[index])
                                            - Number(this.inputSchloarshipAmounts[index])
                                            - Number(this.inputSeatBlockingAmount[index])
                                            + Number(this.inputPremiumValues[index]);

                    fee.BalanceFee = BalanceIndex;
                    // console.log('123',fee.BalanceFee);
                    fee.SeatBlockingAmount = this.inputSeatBlockingAmount[index];
                }
                else {
                    const BalanceIndex1 = fee.TuitionFees + fee.UniversityFees 
                                            - Number(this.inputConcessionValues[index])
                                            - Number(this.inputSchloarshipAmounts[index])
                                            + Number(this.inputPremiumValues[index]);

                    fee.BalanceFee = BalanceIndex1;
                }
            } else if (fee.id === this.finalIndex) {
              if (this.PAFStatus === true) {
                const Balance = (this.totalTuitionFees + Number(this.totalUniversityFees)
                                - Number(this.totalConcession)
                                - Number(this.totalScholarship)
                                - Number(this.totalSeatBlockingAmount)
                                + Number(this.totalPremium));
                fee.BalanceFee = Balance
              } else {
                const Balance1 = (this.totalTuitionFees + Number(this.totalUniversityFees)
                                - Number(this.totalConcession)
                                - Number(this.totalScholarship)
                                + Number(this.totalPremium));
                fee.BalanceFee = Balance1
              }
              fee.TuitionFees = this.totalTuitionFees;
              fee.UniversityFees = this.totalUniversityFees;
              fee.Concession = this.totalConcession;
              fee.Premium = this.totalPremium;
              fee.Scholarship = this.totalScholarship;
              fee.SeatBlockingAmount = this.totalSeatBlockingAmount;
            }
          }
        });
        const submitButton = this.template.querySelectorAll('lightning-button.Submit');
        const RemarksInput = this.template.querySelectorAll('.Remarks');
        const BalanceIns = [];

        const updatedZeroConcessionValues = this.updatedInputConsessionValues.filter((element) => (Number(element) !== 0))

        if (this.updatedBalanceFeeInputValues.some(value => value !== undefined) || updatedZeroConcessionValues.length > 0) {
            RemarksInput[0].required = true;
            if (!(RemarksInput[0].value) && RemarksInput[0].required === true) {
                this.showError2 = true;
                this.errorText2 = "Please fill the Concession Remarks. Thank you!"
            } else {
                this.showError2 = false;
            }
        } else {
            RemarksInput[0].required = false;
            this.showError2 = false;
        }
        BalanceIns.splice(0, BalanceIns.length);
        for (let i = 0; i < this.numberOfYears; i++) {
          let pgmFee = this.programFeeAmount;
          if (i == (this.numberOfYears - 1)) {
            pgmFee = this.finalYearProgramFeeAmount;
          }
          const BalanceIn = pgmFee - Number(this.updatedInputConsessionValues[i]) - 
                                      Number(this.updatedScholarshipAmounts[i]) - 
                                      Number(this.inputSeatBlockingAmount[i+1]) + 
                                      this.updatedInputPremiumValues[i];
          if (BalanceIn < 0 || isNaN(BalanceIn)) {
              BalanceIns.push(BalanceIn);
          }
        }

         /* for(let i=2;i<this.feeArray.length;i++){
            if(this.inputSeatBlockingAmount[i-1] > 0){
                if(this.inputSeatBlockingAmount[1] < this.feeArray[i-1].UniversityFees){

                    submitButton[0].disabled = true;    
                  this.showError = true;
                  this.errorText = "Please enter Provisional Admission Fee greater than university fee. Thank you!";
    
                }   
           
           else{
            submitButton[0].disabled = false
                this.showError = false;
        }
    } 

    } */  
  }

    getOrdinalSuffix(i) {
        let j = i % 10,
            k = i % 100;
        if (j == 1 && k != 11) {
            return "st";
        }
        if (j == 2 && k != 12) {
            return "nd";
        }
        if (j == 3 && k != 13) {
            return "rd";
        }
        return "th";
    }

    dueDateForStudentFees () {
       
        const SBADuedate = new Date();
        SBADuedate.setDate(SBADuedate.getDate()+20);
        for(let i=0; i<this.numberOfYears; i++) {
        const newdate = new Date();
        newdate.setDate(1);
        newdate.setMonth(6);
        newdate.setFullYear(newdate.getFullYear() + i);
        const dateString =  newdate.toJSON().slice(0, 10);
        this.dueDate.push(dateString);
        }
        
         this.seatBlockingAmountDueDateString = SBADuedate.toJSON().slice(0, 10);
    }

    handleCreateStudentTutionFee() {
        this.getInputValues();
        if (this.dueDate.length < this.numberOfYears) {
            this.dueDateForStudentFees();
        }
        // const seatBlockingAmount = !this.inputSeatBlockingAmount[1] ? 0 : this.inputSeatBlockingAmount[1];
        let tuitionFeePaymentCriteria = this.feePaymentCriterias.find((tuitionFee) => {
            return (tuitionFee.Fee_Type__c == 'Tuition Fee');
        });
        let tuitionFeePaymentCriteriaId = tuitionFeePaymentCriteria.Id;

        let universityFeePaymentCriteria = this.feePaymentCriterias.find((universityFee) => {
            return (universityFee.Fee_Type__c == 'University Fee');
        });
        let universityFeePaymentCriteriaId = universityFeePaymentCriteria.Id;
        for (let i = 0; i < this.numberOfYears; i++) {
            const fields = {};
            fields[AMOUNT_PAID__FIELD.fieldApiName] = 0;
            fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = this.inputSeatBlockingAmount[i+1];
           //  alert('hello'+this.discountedPercentage);
            if(this.selectedScholarCategory !== 'Others') {                  
                fields[SCHOLARSHIP_CATEGORY_FIELD.fieldApiName] = this.selectedScholarCategory;
                fields[SCHOLARSHIP_SUB_CATEGORY_FIELD.fieldApiName] = this.selectedScholarSubCategory;
                 fields[SCHOLARSHIP_DATE_FIELD.fieldApiName] =this.scholarshipDate;
                 fields[COINSELOR_NAME_FIELD.fieldApiName] = this.recordOwnerUsername;
                 fields[SCHOLARSHIP_CREATED_BY_FIELD.fieldApiName] = this.currentUserUsername;
                 fields[SCHOLARSHIP_PERCENTAGE.fieldApiName] = this.discountedPercentage;
                 
            }else{
                fields[SCHOLARSHIP_CATEGORY_FIELD.fieldApiName] = this.OtherSelectedCategory;
                fields[SCHOLARSHIP_SUB_CATEGORY_FIELD.fieldApiName] = this.OtherSelectedSubCategory;
                 fields[SCHOLARSHIP_DATE_FIELD.fieldApiName] =this.scholarshipDate;
                 fields[COINSELOR_NAME_FIELD.fieldApiName] = this.recordOwnerUsername;
                 fields[SCHOLARSHIP_CREATED_BY_FIELD.fieldApiName] = this.currentUserUsername;
                fields[SCHOLARSHIP_PERCENTAGE.fieldApiName] = this.discountedPercentage;
            } 

            if (this.ApplicationConcessionStatus !== 'Approved') {
                if (i == 0) {
                   
                    if (this.amountPendingDifference > 0) {
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - this.universityFeeAmount + Number(this.updatedInputConsessionValues[i]);
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.amountPendingDifference;
                        // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = seatBlockingAmount;
                        fields[DUE_DATE__FIELD.fieldApiName] = this.seatBlockingAmountDueDateString;
                    }
                    else {
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - this.universityFeeAmount  + Number(this.updatedInputConsessionValues[i]);
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - this.universityFeeAmount  + Number(this.updatedInputConsessionValues[i]);
                        // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = 0;
                        fields[DUE_DATE__FIELD.fieldApiName] = this.dueDate[i];
                    }
                }
                else {
                    fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.BalanceFeesInputValues[i + 1] - this.universityFeeAmount + 0 + Number(this.updatedInputConsessionValues[i]);
                    fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.BalanceFeesInputValues[i + 1] - this.universityFeeAmount + 0 + Number(this.updatedInputConsessionValues[i]);
                    fields[DUE_DATE__FIELD.fieldApiName] = this.dueDate[i];
                }
            }
            else {

                if (i == 0) {
                    if (this.amountPendingDifference > 0) {
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - this.universityFeeAmount
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.amountPendingDifference;
                        // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = seatBlockingAmount;
                        fields[DUE_DATE__FIELD.fieldApiName] = this.seatBlockingAmountDueDateString;
                    }
                    else {
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - this.universityFeeAmount
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1])+
                         - this.universityFeeAmount
                        // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = 0;
                        fields[DUE_DATE__FIELD.fieldApiName] = this.dueDate[i];
                    }
                }
                else {
                    fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.BalanceFeesInputValues[i + 1] - this.universityFeeAmount + 0
                    fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.BalanceFeesInputValues[i + 1] - this.universityFeeAmount + 0
                    fields[DUE_DATE__FIELD.fieldApiName] = this.dueDate[i];
                }

            }
            fields[CONTACT__FIELD.fieldApiName] = this.contactDetails.Id;
            fields[ACTUAL_PROGRAM_FEE__FIELD.fieldApiName] = i === (this.numberOfYears - 1) ?
                                                                this.finalYearTuitionFeeAmount : this.tuitionFeeAmount;

            if ((this.existingPremiumRecords[i] == undefined || this.existingPremiumRecords[i] == 0) && this.updatedInputPremiumValues[i] == undefined) {
                fields[PREMIUM_FIELD.fieldApiName] = 0
            }
            else if ((this.existingPremiumRecords[i] == undefined || this.existingPremiumRecords[i] == 0) && this.updatedInputPremiumValues[i] != undefined) {
                fields[PREMIUM_FIELD.fieldApiName] = this.updatedInputPremiumValues[i];
            }
            else if (this.existingPremiumRecords[i] != undefined && this.updatedInputPremiumValues[i] != undefined) {
                fields[PREMIUM_FIELD.fieldApiName] = this.updatedInputPremiumValues[i];
            }
            else {
                fields[PREMIUM_FIELD.fieldApiName] = this.existingPremiumRecords[i];
            }

            if ((this.existingScholarshipRecords[i] == undefined || this.existingScholarshipRecords[i] == 0) && this.scholarShipAmounts[i] == undefined) {
                fields[SCHOLARSHIP_FIELD.fieldApiName] = 0
            }
            else if ((this.existingScholarshipRecords[i] == undefined || this.existingScholarshipRecords[i] == 0) && this.scholarShipAmounts[i] != undefined) {
                fields[SCHOLARSHIP_FIELD.fieldApiName] = this.scholarShipAmounts[i];
            }
            else if (this.existingScholarshipRecords[i] != undefined && this.scholarShipAmounts[i] != undefined) {
                fields[SCHOLARSHIP_FIELD.fieldApiName] = this.scholarShipAmounts[i];
            }
            else {
                fields[SCHOLARSHIP_FIELD.fieldApiName] = this.existingScholarshipRecords[i];
            }
           
          
            if (this.enrolmentype === 'Lateral Entry' && this.admissionMode === 'UQ') {
                fields[NAME__FIELD.fieldApiName] = `Tuition Fee ${i + 2}${this.getOrdinalSuffix(i + 2)} year`,
                fields[FEE_YEAR__FIELD.fieldApiName] = `${i + 2}${this.getOrdinalSuffix(i + 2)} Year`;

            } else {
                fields[NAME__FIELD.fieldApiName] = `Tuition Fee ${i + 1}${this.getOrdinalSuffix(i + 1)} year`,
                fields[FEE_YEAR__FIELD.fieldApiName] = `${i + 1}${this.getOrdinalSuffix(i + 1)} Year`;

            }
            
           // fields[NAME__FIELD.fieldApiName] = `Tuition Fee ${i + 2}${this.getOrdinalSuffix(i + 2)} year`,
                fields[FEE_TYPE__FIELD.fieldApiName] = "Tuition Fee";
          // fields[FEE_YEAR__FIELD.fieldApiName] = `${i + 2}${this.getOrdinalSuffix(i + 2)} Year`;
            if (i == 0) {
                fields[DISPLAY_NUMBER__FIELD.fieldApiName] = i + 1;
            }
            else {
                fields[DISPLAY_NUMBER__FIELD.fieldApiName] = ((2 * i) + 1);
            }
            fields[CONCESSION_FIELD.fieldApiName] = 0;
            fields[FEE_MASTER__FIELD.fieldApiName] = this.programFees.Id;
            fields[FEE_PAYMENT_CRITERIA__FIELD.fieldApiName] = tuitionFeePaymentCriteriaId;
            fields[STUDENT_MOBILE_NUMBER__FIELD.fieldApiName]=this.ApplicantMobileNumber;
            fields[STUDENT_PERSONAL_MAIL__FIELD.fieldApiName]=this.ApplicantEmailId;
            fields[FATHER_EMAIL_ID__FIELD.fieldApiName]=this.FatherEmailId;
            fields[FATHER_MOBILE_NUMBER__FIELD.fieldApiName]=this.FatherMobileNumber;
            fields[MOTHER_EMAIL_ID__FIELD.fieldApiName]=this.MotherEmailId;
            fields[MOTHER_MOBILE_NUMBER__FIELD.fieldApiName]=this.MotherMobileNumber
            const studentTutionFeeRecordCreate = {
                apiName: Student_FEE__OBJECT.objectApiName,
                fields
            };
            createRecord(studentTutionFeeRecordCreate).then(() => {
                // console.log('TUITION FEES CREATED');
               this.TuitionFeeRecordsReload = true;
               if(this.TuitionFeeRecordsReload === true && this.UniversityFeeRecordsReload===true && this.applicationRecordReload === false){                        
                this.handleReload();
            }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
            
        }

        // university fee record creation
        for (let j = 0; j < this.numberOfYears; j++) {
            const fields = {};
            fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = this.inputSeatBlockingAmount[j+1];
            if (Number(this.studentUniversityFeeAmounts[j] + this.scholarshipDifference[j]) >= 0) {
                fields[AMOUNT_PAID__FIELD.fieldApiName] = 0;
                if (j == 0) {
                    if (this.amountPendingDifference > 0) {
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j];
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j];
                        // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = seatBlockingAmount;
                        fields[DUE_DATE__FIELD.fieldApiName] = this.seatBlockingAmountDueDateString;
                    }

                    else {
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j];
                        if (Number(this.studentUniversityFeeAmounts[j]) + Number((this.amountPendingDifference)) === 0) {
                            fields[AMOUNT_PENDING__FIELD.fieldApiName] = Number(this.studentUniversityFeeAmounts[j]);
                            }
                            else {
                                fields[AMOUNT_PENDING__FIELD.fieldApiName] = Number(this.studentUniversityFeeAmounts[j]) + Number((this.amountPendingDifference));
         
                            }
                        // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = seatBlockingAmount;
                        if (this.amountPendingDifference == 0) {
                            fields[DUE_DATE__FIELD.fieldApiName] = this.dueDate[j];
                        }
                        else {
                        fields[DUE_DATE__FIELD.fieldApiName] = this.seatBlockingAmountDueDateString;
                        }
                    }
                } else {
                    fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j] + this.scholarshipDifference[j];
                    fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j] + this.scholarshipDifference[j];
                    fields[DUE_DATE__FIELD.fieldApiName] = this.dueDate[j];

                }
            }
            else {
                if (j === 0) {
                    fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j]
                    fields[AMOUNT_PAID__FIELD.fieldApiName] = 0;
                    fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j]
                    // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = seatBlockingAmount;
                    fields[DUE_DATE__FIELD.fieldApiName] = this.seatBlockingAmountDueDateString;
                }
                else {
                    fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j]
                    fields[AMOUNT_PAID__FIELD.fieldApiName] = 0;
                    fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j]
                    fields[DUE_DATE__FIELD.fieldApiName] = this.dueDate[j];
                }
            }
            if (this.enrolmentype === 'Lateral Entry' && this.admissionMode === 'UQ') {
                fields[NAME__FIELD.fieldApiName] = `University Fee ${j + 2}${this.getOrdinalSuffix(j + 2)} year`
                fields[FEE_YEAR__FIELD.fieldApiName] = `${j + 2}${this.getOrdinalSuffix(j + 2)} Year`;

            }else{
                fields[NAME__FIELD.fieldApiName] = `University Fee ${j + 1}${this.getOrdinalSuffix(j + 1)} year`
                fields[FEE_YEAR__FIELD.fieldApiName] = `${j + 1}${this.getOrdinalSuffix(j + 1)} Year`;

            }

            fields[CONTACT__FIELD.fieldApiName] = this.contactDetails.Id;
            fields[ACTUAL_PROGRAM_FEE__FIELD.fieldApiName] = this.universityFeeAmount;
           // fields[NAME__FIELD.fieldApiName] = `University Fee ${j + 1}${this.getOrdinalSuffix(j + 1)} year`
            fields[FEE_TYPE__FIELD.fieldApiName] = "University Fee";
           // fields[FEE_YEAR__FIELD.fieldApiName] = `${j + 1}${this.getOrdinalSuffix(j + 1)} Year`;
            if (j == 0) {
                fields[DISPLAY_NUMBER__FIELD.fieldApiName] = j + 2
            }
            else {
                fields[DISPLAY_NUMBER__FIELD.fieldApiName] = ((2 * j) + 2);
            }
            fields[CONCESSION_FIELD.fieldApiName] = 0;
            fields[SCHOLARSHIP_FIELD.fieldApiName] = 0;
            fields[PREMIUM_FIELD.fieldApiName] = 0;
            fields[FEE_MASTER__FIELD.fieldApiName] = this.universityFees.Id;
            fields[FEE_PAYMENT_CRITERIA__FIELD.fieldApiName] = universityFeePaymentCriteriaId;
            fields[STUDENT_MOBILE_NUMBER__FIELD.fieldApiName]=this.ApplicantMobileNumber;
            fields[STUDENT_PERSONAL_MAIL__FIELD.fieldApiName]=this.ApplicantEmailId;
            fields[FATHER_EMAIL_ID__FIELD.fieldApiName]=this.FatherEmailId;
            fields[FATHER_MOBILE_NUMBER__FIELD.fieldApiName]=this.FatherMobileNumber;
            fields[MOTHER_EMAIL_ID__FIELD.fieldApiName]=this.MotherEmailId;
            fields[MOTHER_MOBILE_NUMBER__FIELD.fieldApiName]=this.MotherMobileNumber;
            const universityStudentFeeCreate = {
                apiName: Student_FEE__OBJECT.objectApiName,
                fields
            };
            createRecord(universityStudentFeeCreate).then(() => {
                // console.log('UNIVERSITY FEES CREATED');
                this.UniversityFeeRecordsReload = true;
                if(this.TuitionFeeRecordsReload === true && this.UniversityFeeRecordsReload===true && this.applicationRecordReload === false){                        
                    this.handleReload();
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
            
        }
    }

    /*handleUpdateFeeStructreDefined() {
        const fields = {};
        fields[APPLICATION_RECORD_ID__FIELD.fieldApiName] = this.ApplicationId;
        //fields[SCHOLARSHIP_LOOKUP_FIELD.fieldApiName] = this.scholarshipId;
          fields[SCHOLARSHIP_LOOKUP_FIELD.fieldApiName] = this.scholarshipId ?? null;
        fields[FEE_STRUCTURE_DEFINED__FIELD.fieldApiName] = true;
        const updateApplicationRecord = {
            fields
        }
        updateRecord (updateApplicationRecord);
    }*/
  
handleUpdateFeeStructreDefined() {

    updateFeeStructureAndContact({
        applicationId: this.ApplicationId,
        scholarshipId: this.scholarshipId
    })
    .then(() => {
        console.log('Application and Contact updated');
    })
    .catch(error => {
        console.error('Error => ', error);
    });
}


    handleUpdateStudentFeeRecords() {
        this.getInputValues();
        this.StudentFeeRecords();
        // const seatBlockingAmount = !this.inputSeatBlockingAmount[1] ? 0 : this.inputSeatBlockingAmount[1];
        for (let i = 0; i < this.numberOfYears; i++) {
            const fields = {};
            fields[ID__FIELD.fieldApiName] = this.tuitionFeeRecordIds[i];
            fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = this.inputSeatBlockingAmount[i+1];
            fields[ACTUAL_PROGRAM_FEE__FIELD.fieldApiName] = i === (this.numberOfYears - 1) ?
                                                                this.finalYearTuitionFeeAmount : this.tuitionFeeAmount;
         if(this.selectedScholarCategory !== 'Others') {                  
            fields[SCHOLARSHIP_CATEGORY_FIELD.fieldApiName] = this.selectedScholarCategory;
            fields[SCHOLARSHIP_SUB_CATEGORY_FIELD.fieldApiName] = this.selectedScholarSubCategory;
             fields[SCHOLARSHIP_DATE_FIELD.fieldApiName] =this.scholarshipDate;
             fields[COINSELOR_NAME_FIELD.fieldApiName] = this.recordOwnerUsername;            
             fields[SCHOLARSHIP_CREATED_BY_FIELD.fieldApiName] = this.currentUserUsername;
             fields[SCHOLARSHIP_PERCENTAGE.fieldApiName] = this.discountedPercentage;

        }else{
            fields[SCHOLARSHIP_CATEGORY_FIELD.fieldApiName] = this.OtherSelectedCategory;
            fields[SCHOLARSHIP_SUB_CATEGORY_FIELD.fieldApiName] = this.OtherSelectedSubCategory;
             fields[SCHOLARSHIP_DATE_FIELD.fieldApiName] =this.scholarshipDate;
             fields[COINSELOR_NAME_FIELD.fieldApiName] = this.recordOwnerUsername;           
             fields[SCHOLARSHIP_CREATED_BY_FIELD.fieldApiName] = this.currentUserUsername;
             fields[SCHOLARSHIP_PERCENTAGE.fieldApiName] = this.discountedPercentage;
        } 
          // alert(this.selectedScholarCategory);
        
            if (this.ApplicationConcessionStatus !== 'Approved') {
                if (i == 0) {
                    if (this.PAFStatus === true) {
                        // console.log('GOING IN',this.tuitionTotalCalculatedAmount[i])
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.tuitionFeeAmount) + Number(this.updatedInputPremiumValues[i]) - Number(this.updatedScholarshipAmounts[i])
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = Number(this.tuitionFeeAmount) + Number(this.updatedInputPremiumValues[i]) - Number(this.updatedScholarshipAmounts[i]) - Number(this.PaidTuitionFees[i]);
                    }
                   else if (this.amountPendingDifference > 0) {
   
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - Number(this.universityFeeAmount) + Number(this.updatedInputConsessionValues[i]);
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.amountPendingDifference;
                        // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = seatBlockingAmount;
                    }
                    else {

                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - this.universityFeeAmount  + Number(this.updatedInputConsessionValues[i]);
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - this.universityFeeAmount + Number(this.updatedInputConsessionValues[i]);
                        // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = 0;
                    }
                }
                else {                   
                    fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.BalanceFeesInputValues[i + 1] - this.universityFeeAmount + 0 + Number(this.updatedInputConsessionValues[i]);
                    fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.BalanceFeesInputValues[i + 1] - this.universityFeeAmount + 0 + Number(this.updatedInputConsessionValues[i]);
                }
            }
            else if (Number(this.updatedInputConsessionValues[i]) !== Number(this.existingConcessionRecords[i]) || this.ApplicationConcessionStatus === 'Approved') {
                if (i == 0) {
                    if (this.PAFStatus === true) {
                        // console.log('GOING IN',this.tuitionTotalCalculatedAmount[i])
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.tuitionFeeAmount) + Number(this.updatedInputPremiumValues[i]) - Number(this.updatedScholarshipAmounts[i])
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = Number(this.tuitionFeeAmount) + Number(this.updatedInputPremiumValues[i]) - Number(this.updatedScholarshipAmounts[i]) - Number(this.PaidTuitionFees[i]);
                    }
                   else if (this.amountPendingDifference > 0) {
   
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - Number(this.universityFeeAmount) + Number(this.updatedInputConsessionValues[i]);
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.amountPendingDifference;
                        // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = seatBlockingAmount;
                    }
                    else {

                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - this.universityFeeAmount  + Number(this.updatedInputConsessionValues[i]);
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - this.universityFeeAmount + Number(this.updatedInputConsessionValues[i]);
                        // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = 0;
                    }
                }
                else {                   
                    fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.BalanceFeesInputValues[i + 1] - this.universityFeeAmount + 0 + Number(this.updatedInputConsessionValues[i]);
                    fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.BalanceFeesInputValues[i + 1] - this.universityFeeAmount + 0 + Number(this.updatedInputConsessionValues[i]);
                }
            }
            else {

                if (i == 0) {
                  
                    if (this.PAFStatus === true) {
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.tuitionFeeAmount) + Number(this.updatedInputPremiumValues[i]) - Number(this.updatedScholarshipAmounts[i]) - Number(this.updatedInputConsessionValues[i])
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = Number(this.tuitionFeeAmount) + Number(this.updatedInputPremiumValues[i]) - Number(this.updatedScholarshipAmounts[i]) - Number(this.updatedInputConsessionValues[i]) - Number(this.PaidTuitionFees[i]);
                    }
                    else if (this.amountPendingDifference > 0) {
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - this.universityFeeAmount
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.amountPendingDifference;
                        // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = seatBlockingAmount;
                    }
                    else {
                        fields[AMOUNT_TOTAL__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - this.universityFeeAmount 
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = Number(this.BalanceFeesInputValues[i + 1]) - this.universityFeeAmount
                        // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = 0;
                    }
                }
                else {

                    fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.BalanceFeesInputValues[i + 1] - this.universityFeeAmount + 0
                    fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.BalanceFeesInputValues[i + 1] - this.universityFeeAmount + 0
                }

            }

           /* if ((this.existingPremiumRecords[i] == undefined || this.existingPremiumRecords[i] == 0) && this.updatedInputPremiumValues[i] == undefined) {
                fields[PREMIUM_FIELD.fieldApiName] = 0
            }
            else if ((this.existingPremiumRecords[i] == undefined || this.existingPremiumRecords[i] == 0) && this.updatedInputPremiumValues[i] != undefined) {
                fields[PREMIUM_FIELD.fieldApiName] = this.updatedInputPremiumValues[i];
            }
            else if (this.existingPremiumRecords[i] != undefined && this.updatedInputPremiumValues[i] != undefined) {
                fields[PREMIUM_FIELD.fieldApiName] = this.updatedInputPremiumValues[i];
            }
            else {
                fields[PREMIUM_FIELD.fieldApiName] = this.existingPremiumRecords[i];
            }*/
               //Update scholarship time Preserve old Premium values for existing Student Fee records
                if (this.existingPremiumRecords[i] == 0) { fields[PREMIUM_FIELD.fieldApiName] = 0;
                   }
               else if (this.existingPremiumRecords[i] != undefined) {fields[PREMIUM_FIELD.fieldApiName] =
                       this.existingPremiumRecords[i];
               }
               else {
                  fields[PREMIUM_FIELD.fieldApiName] = this.updatedInputPremiumValues[i] || 0;
               }
                    
            if ((this.existingScholarshipRecords[i] == undefined || this.existingScholarshipRecords[i] == 0) && this.scholarShipAmounts[i] == undefined) {
                fields[SCHOLARSHIP_FIELD.fieldApiName] = 0
            }
            else if ((this.existingScholarshipRecords[i] == undefined || this.existingScholarshipRecords[i] == 0) && this.scholarShipAmounts[i] != undefined) {
                fields[SCHOLARSHIP_FIELD.fieldApiName] = this.scholarShipAmounts[i];
            }
            else if (this.existingScholarshipRecords[i] != undefined && this.scholarShipAmounts[i] != undefined) {
                fields[SCHOLARSHIP_FIELD.fieldApiName] = this.scholarShipAmounts[i];
            }
            else {
                fields[SCHOLARSHIP_FIELD.fieldApiName] = this.existingScholarshipRecords[i];
            }
            const tuitionFeeRecordUpdate = { fields };
            updateRecord(tuitionFeeRecordUpdate).then(() => {
                // console.log('TUITION FEES UPDATED');
                this.TuitionFeeRecordsReload = true;
                if(this.TuitionFeeRecordsReload === true && this.UniversityFeeRecordsReload===true && this.applicationRecordReload === false){                        
                    this.handleReload();
                }
                
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });

        }

        // university fee records updation
        for (let j = 0; j < this.numberOfYears; j++) {
            const fields = {};
            fields[ID__FIELD.fieldApiName] = this.universityFeeRecordIds[j];
            fields[ACTUAL_PROGRAM_FEE__FIELD.fieldApiName] = this.universityFeeAmount;
            fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = this.inputSeatBlockingAmount[j+1];

            if (j == 0) {
               
                if (this.PAFStatus === true) {
                    fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.universityTotalCalculatedAmount[j]
                    fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.universityTotalCalculatedAmount[j] - this.PaidUniversityFees[j];
                }
               else if (Number(this.amountPendingDifference) >= 0) {
                    fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j];
                    fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j];
                    // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = seatBlockingAmount
                }
                else {
                    fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j];
                    if (Number(this.studentUniversityFeeAmounts[j]) + Number((this.amountPendingDifference)) === 0) {
                    fields[AMOUNT_PENDING__FIELD.fieldApiName] = Number(this.studentUniversityFeeAmounts[j]);
                    }
                    else {
                        fields[AMOUNT_PENDING__FIELD.fieldApiName] = Number(this.studentUniversityFeeAmounts[j]) + Number((this.amountPendingDifference));
 
                    }
                    // fields[PROVISIONAL_ADMISSION_FEE__FIELD.fieldApiName] = seatBlockingAmount
                }
            }
            else if (Number(this.studentUniversityFeeAmounts[j] + this.scholarshipDifference[j]) > 0 && j != 0) {
                fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j] + this.scholarshipDifference[j];
                fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j] + this.scholarshipDifference[j];


            }
            else {
                fields[AMOUNT_TOTAL__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j]
                fields[AMOUNT_PENDING__FIELD.fieldApiName] = this.studentUniversityFeeAmounts[j]
            }

            const universityStudentFeeUpdate = {
                fields
            };
            updateRecord(universityStudentFeeUpdate).then(() => {
                this.UniversityFeeRecordsReload=true;
                // console.log('UNIVERSITY FEES UPDATED');
                if(this.TuitionFeeRecordsReload === true && this.UniversityFeeRecordsReload===true && this.applicationRecordReload === false){                        
                    this.handleReload();
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }

    }

    handleApplicationConcessionRecordsCreation() {
        //alert('Entered handleApplicationConcessionRecordsCreation');

//alert('Application Id : ' + this.ApplicationId);

//alert('Scholarship Id : ' + this.scholarshipId);

        console.log('ENTERED handleApplicationConcessionRecordsCreation');

    console.log('ApplicationId => ', this.ApplicationId);
    console.log('ScholarshipId => ', this.scholarshipId);
        const fields = {};
        fields[APPLICATION_RECORD_ID__FIELD.fieldApiName] = this.ApplicationId;
       // fields[SCHOLARSHIP_LOOKUP_FIELD.fieldApiName] = this.applicationScholarshipRecordId;
         fields[SCHOLARSHIP_LOOKUP_FIELD.fieldApiName] = this.scholarshipId;
        if (this.additionalDocuments !== undefined) {
            fields[ADDITIONAL_DOCUMENTS_REQUIRED__FIELD.fieldApiName] = this.isDocumentsRequired;
            fields[ADDITIONAL_DOCUMENTS_FIELD.fieldApiName] = this.additionalDocuments;
             console.log('FIELDS => ', JSON.stringify(fields));
        }
        const concessionFields = [FIRST_YEAR_CONCESSION__FIELD.fieldApiName, SECOND_YEAR_CONCESSION__FIELD.fieldApiName,
          THIRD_YEAR_CONCESSION__FIELD.fieldApiName, FOURTH_YEAR_CONCESSION__FIELD.fieldApiName,
          FIFTH_YEAR_CONCESSION__FIELD.fieldApiName];

        for (let k = 0; k < this.numberOfYears; k++) {
            if (!isNaN(this.updatedInputConsessionValues[k]) && this.updatedInputConsessionValues[k] !== 0) {
                fields[concessionFields[k]] = this.updatedInputConsessionValues[k];
            } else if (this.updatedInputConsessionValues[k] === null) {
                fields[concessionFields[k]] = 0;
            }
        }
        const remarks = this.template.querySelectorAll('.Remarks');
        fields[CONCESSION_REMARKS__FIELD.fieldApiName] = remarks[0].value;

        const ApplicationConcessionFields = {
            fields
        };
        /*updateRecord(ApplicationConcessionFields).then(() => {
            if(this.applicationRecordReload===true){
                // console.log('APPLICATION FEES UPDATED');
            this.handleReload();
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }*/
     updateRecord(ApplicationConcessionFields)
   
     .then(() => {
       console.log('submitConcessionForApproval');
     if (
         !this.totalConcession ||
         Number(this.totalConcession) === 0
      ) {
       return;
       }

      if (
            !this.mainRemarks ||
            this.mainRemarks.trim() === ''
         ) {
       this.showToast(
           'Error',
           'Please enter concession remarks',
           'error'
        );
       return;
       }
        return submitConcessionForApproval({
           applicationId: this.ApplicationId
        });
     })
      .then((result) => {

   // console.log('Approval Result => ', result);
    //console.log('FULL ERROR => ', JSON.stringify(error));
    //console.log('ERROR BODY => ', error?.body);
   // console.log('ERROR MESSAGE => ', error?.body?.message|| error.message);
      this.dispatchEvent(
         new ShowToastEvent({
            title: 'Approval Result',
            message: result,
            variant: result && result.startsWith('SUCCESS') ? 'success' : 'error'
         })
     );

    /*if(this.applicationRecordReload === false){
        console.log('APPLICATION FEES UPDATED');
        this.handleReload();
    }*/
       this.handleReload();
      })
        .then(() => {
          this.applicationScholarshipRecordId = this.scholarshipId;
          })
      .catch(error => {

         console.log('FULL ERROR => ', JSON.stringify(error));

         let msg = 'Unknown Error';

        if(error?.body?.message){
          msg = error.body.message;
         } else if(error?.message){
          msg = error.message;
         }

    console.log('ERROR MESSAGE => ', msg);
    console.log('FULL ERROR => ', JSON.stringify(error));
    console.log('ERROR BODY => ', error?.body);
    console.log('ERROR MESSAGE => ', error?.body?.message);

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message: msg,
            variant: 'error'
        })
    );
});
    }
        

    updateData() {
        this.updateMyData()
            .then(() => {
                refreshApex(this.wiredValues)
                    .then(() => {
                        this.dispatchEvent(new CustomEvent('refresh'));
                    });
            });
    }

    updateMyData() {
        return Promise.resolve();
    }
    handleReload() {
     window.location.reload();
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: this.title,
            message: this.message,
            variant: this.variant
        });
        this.dispatchEvent(toastEvent);
    }


    /*handleStudentFeeRecordCreationOrUpdation() {
        if(this.currentUserUserProfileName == 'Counselor' && this.currentUserUsername != this.recordOwnerUsername){
            this.title = 'You are not a assigned Counselor';
            this.message = 'You do not have access to update this record';
            this.variant = 'error';
            this.showToast(this.title, this.message, this.variant);
        } else {
            this.updateData();
          
            if (this.existingStudentFeerecords.length == 0) {
                this.showLoadingModal = true;
                this.handleUpdateFeeStructreDefined();
               
                this.handleCreateStudentTutionFee();
                this.title = 'Fee Structre is Defined';
                this.message = 'Student Fees Created';
                this.variant = 'success';
                for (let i = 0; i < this.numberOfYears; i++) {
                    if ((Number(this.updatedInputConsessionValues[i]) !== 0) || (Number(this.updatedScholarshipAmounts[i]) !== 0)) {
                        this.showLoadingModal = true;
                        this.applicationRecordReload = true;
                        this.handleApplicationConcessionRecordsCreation();
                        this.title = 'Fee Structre is Defined';
                        this.message = 'Student Fees Created and Application Details Updated';
                        this.variant = 'success';
                        this.showToast(this.title, this.message, this.variant);
                        //  this.handleReload(); 
                    }
                    else {
                        this.applicationRecordReload=false;
                        this.showToast(this.title, this.message, this.variant);
                        
                    }
                }
                

            } else {
                this.showLoadingModal = true;
                // console.log("LOADING",this.showLoadingModal);
                this.handleUpdateStudentFeeRecords();
                this.title = 'Success';
                this.message = 'Student Fees Updated';
                this.variant = 'success';
                if (this.updatedInputConsessionValues.length === this.existingConcessionRecords.length || this.updatedScholarshipAmounts.length === this.existingScholarshipRecords.length) {
                    for (let i = 0; i < this.updatedInputConsessionValues.length; i++) {
                        if (Number(this.updatedInputConsessionValues[i]) !== Number(this.existingConcessionRecords[i]) || Number(this.updatedScholarshipAmounts[i]) !== Number(this.existingScholarshipRecords[i])) {
                            this.applicationRecordReload = true;
                            if (this.ApplicationConcessionStatus ==='Initiated' || this.ApplicationConcessionStatus === 'Under Approval') {
                                this.unlockApplicationRecordId();
                            
                            this.handleApplicationConcessionRecordsCreation();
                            }
                            else {
                            this.handleApplicationConcessionRecordsCreation();
                            }
                            
                            this.title = 'Success';
                            this.message = 'Student Fees and Application Details Updated';
                            this.variant = 'success';
                            this.showToast(this.title, this.message, this.variant);
                            // this.handleReload(); 
                        }
                        else {
                            this.applicationRecordReload = false;
                            this.showToast(this.title, this.message, this.variant);
                            
                        }
                    }
                }

                
            }
        }

    }*/
   
        handleStudentFeeRecordCreationOrUpdation() {

    if (
        this.currentUserUserProfileName === 'Counselor' &&
        this.currentUserUsername !== this.recordOwnerUsername
    ) {
        this.title = 'You are not a assigned Counselor';
        this.message = 'You do not have access to update this record';
        this.variant = 'error';
        this.showToast(this.title, this.message, this.variant);
        return;
    }

    this.updateData();

    // CREATE MODE
    if (this.existingStudentFeerecords.length === 0) {

        this.showLoadingModal = false;

        this.handleUpdateFeeStructreDefined();

        console.log(
            'Existing Fee Records => ',
            JSON.stringify(this.existingStudentFeerecords)
        );

        this.handleCreateStudentTutionFee();

        this.title = 'Fee Structure is Defined';
        this.message = 'Student Fees Created';
        this.variant = 'success';

        let hasChanges = false;

        for (let i = 0; i < this.numberOfYears; i++) {

            if (
                Number(this.updatedInputConsessionValues[i]) !== 0 ||
                Number(this.updatedScholarshipAmounts[i]) !== 0
            ) {
                hasChanges = true;
                break;
            }
        }

        if (hasChanges) {

            this.showLoadingModal = False;
            //this.applicationRecordReload = true;

           // this.handleApplicationConcessionRecordsCreation();
  setTimeout(() => {
    this.applicationRecordReload = true;
    this.handleApplicationConcessionRecordsCreation();
}, 3000);
            this.title = 'Fee Structure is Defined';
            this.message =
                'Student Fees Created and Application Details Updated';
            this.variant = 'success';
        } else {
            this.applicationRecordReload = false;
        }

        this.showToast(
            this.title,
            this.message,
            this.variant
        );

    }

    // UPDATE MODE
    else {

        this.showLoadingModal = false;

        console.log(
            'LOADING',
            this.showLoadingModal
        );

        this.handleUpdateStudentFeeRecords();

        let concessionChanged = false;
        let scholarshipChanged = false;

        for (
            let i = 0;
            i < this.updatedInputConsessionValues.length;
            i++
        ) {

            if (
                Number(this.updatedInputConsessionValues[i]) !==
                Number(this.existingConcessionRecords[i])
            ) {
                concessionChanged = true;
            }

            if (
                Number(this.updatedScholarshipAmounts[i]) !==
                Number(this.existingScholarshipRecords[i])
            ) {
                scholarshipChanged = true;
            }
        }

        // Only Concession Changed
        if (concessionChanged) {

            this.applicationRecordReload = true;

            if (
                this.ApplicationConcessionStatus === 'Initiated' ||
                this.ApplicationConcessionStatus === 'Under Approval'
            ) {
                this.unlockApplicationRecordId();
            }

            this.handleApplicationConcessionRecordsCreation();

            this.title = 'Success';
            this.message =
                'Student Fees and Application Details Updated';
            this.variant = 'success';
        }

        // Only Scholarship Changed
        else if (scholarshipChanged) {

            this.applicationRecordReload = false;
              this.handleApplicationConcessionRecordsCreation();
            this.title = 'Success';
            this.message = 'Scholarship Updated Successfully';
            this.variant = 'success';
            console.log('applicationScholarshipRecordId = ', this.applicationScholarshipRecordId);
console.log('selected scholarshipId = ', this.scholarshipId);
console.log('scholarshipChanged = ', scholarshipChanged);
        }

        // No Changes
        else {

            this.applicationRecordReload = false;

            this.title = 'Info';
            this.message = 'No Changes Found';
            this.variant = 'info';
        }

        this.showToast(
            this.title,
            this.message,
            this.variant
        );
    }
}
    updateContact() {
        // Call the Apex method to update the contact record with the selected values
     
    }

    handleClickShow() {
        if(this.currentUserUserProfileName == 'Counselor' && this.currentUserUsername != this.recordOwnerUsername){
            this.title = 'You are not a assigned Counselor';
            this.message = 'You do not have access to update this record';
            this.variant = 'error';
            this.showToast(this.title, this.message, this.variant);
        } else {
            this.scholarshipDetails = false;
            this.showChildCom = true;
        }
    }

    handleConfirmationShowModal() {
        if(this.currentUserUserProfileName == 'Counselor' && this.currentUserUsername != this.recordOwnerUsername){
            this.title = 'You are not a assigned Counselor';
            this.message = 'You do not have access to update this record';
            this.variant = 'error';
            this.showToast(this.title, this.message, this.variant);
        } else {
            this.showConfirmationModal = true;
        }
    }
    handleConfirmationCloseModal() {
        this.showConfirmationModal = false;
    }
    removeScholarship() {
        //alert('Scholarship Id : ' + this.scholarshipId);
        //alert('sch : ' +this.applicationScholarshipRecordId);
        var existingScholarshipDocs=[];
        var existingDocs =[];
        var filteredDocs;
        //fields[SCHOLARSHIP_LOOKUP_FIELD.fieldApiName] = null;
        this.scholarShipAmounts = new Array(this.numberOfYears).fill(0);
        this.scholarshipDifference = new Array(this.numberOfYears).fill(0);
        this.selectedScholarSubCategory='' ;
        this.selectedScholarCategory='';
        this.scholarshipDate = null;
        this.recordOwnerUsername = '';
        this.currentUserUsername='';
        //this.scholarshipId = null;
        this.applicationScholarshipRecordId = null;
        console.log('Scholarship lookup value = ', this.scholarshipId);

        if (this.existingAdditionalDocuments) {
           existingDocs= this.existingAdditionalDocuments.split(';');
        }
        else {
            existingDocs=null
        }
        if (this.existingScholarshipDocuments) {
         existingScholarshipDocs = this.existingScholarshipDocuments.split(';');
        }
        else {
            existingScholarshipDocs=undefined
        }
        if (existingDocs && existingScholarshipDocs) {
            filteredDocs = existingDocs.filter((element)=> !existingScholarshipDocs.includes(element));

          } 
          else if (existingDocs) {
            filteredDocs = existingDocs
          }
          else {

            filteredDocs = '';
          }
          if (filteredDocs !== '') {
        this.additionalDocuments = filteredDocs.join(';');
          } else {
          this.additionalDocuments = filteredDocs;
          }
        this.scholarshipId = null;
        this.FeeMasters();
        this.showConfirmationModal = false;
        setTimeout(() => {
            this.handleStudentFeeRecordCreationOrUpdation();
        }, 2000);
       
    }
}