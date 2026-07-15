import { LightningElement, track, api, wire } from 'lwc';
import fetchStudentRegDetailsfrom from '@salesforce/apex/RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails'
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from "lightning/uiRecordApi"
import getPlacementDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.getPlacementDetails';
import Fill_Basic_Detail_Right_Column_Text from '@salesforce/label/c.RPL_Fill_Basic_Detail_Right_Column_Text_For_Student_Portal';
import Placement_Registration_Text from '@salesforce/label/c.RPL_Placement_Registration_Text_For_Student_Portal';
import RPL_Placement_Portal_Header_Paragraph from '@salesforce/label/c.RPL_Placement_Portal_Header_Paragraph';
import isAlreadyRegistered from '@salesforce/apex/RPL_StudentRegistrationDetails.isAlreadyRegistered';

// this gets you the logged in user
import USER_ID from "@salesforce/user/Id";
import Static_Resources from '@salesforce/resourceUrl/RPL_Static_Resources';
const imageSources = {
    BW: {
        1: Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/1.png',
        2: Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/2.png',
        3: Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/3.png',
        4: Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/4.png',
       // 5: Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/5.png',
    },
    Orange: {
        1: Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/1.png',
        2: Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/2.png',
        3: Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/3.png',
        4: Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/4.png',
        // 5: Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/5.png',
    }
};
export default class Rpl_RevaPlacement extends LightningElement {
    @track currentStep = 1;
    @track stepNumber = 1;
    isSpinner;
    isStudentBasicDetailsSaveBtnDisabled = false;
    registerYourselfLogoBW = Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/1.png';
    verifyEmailOrSmsLogoBW = Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/2.png'
    fillBasicDetailsLogoBW = Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/3.png'
    educationDetailsLogoBW = Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/4.png'
    //approvalStatusLogoBW = Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/5.png'
    registerYourselfLogoOrange = Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/1.png';
    verifyEmailOrSmsLogoOrange = Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/2.png';
    fillBasicDetailsLogoOrange = Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/3.png';
    educationDetailsLogoOrange = Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/4.png';
    //approvalStatusLogoOrange = Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/5.png';
    svgImage = Static_Resources + '/Reva_Placement_Static_Resources/Icons/svgImage.png';
    @api studentregrecordid;
    wiredData;
    contactId;
    isApprovalSuccess;
    isFirstStep;
    isThirdStep;
    isSecondStep;
    isFourthStep;
   // isFifthStep;
    isRecordUnderApprovalProcess;
    isThirdStepEventTriggered;
    isOtpVerified;
    wiredContact;
    keyForWire=1;
    isPlacementRegistrationStarted = false;
    alreayChecked = false;
    placementRegistrationText = Placement_Registration_Text;
    fillBasicDetailsRightColText  = Fill_Basic_Detail_Right_Column_Text;
    headerText = RPL_Placement_Portal_Header_Paragraph;
    @track isAlreadyRegistered = false;
    @track studentRegDetails = {}
    @track isFillBasicDetails = false;
@track isDocumentUpload = false;
@track isBasicDetailsCompleted = false;
studentRegistrationId;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_ID]
    })
    async userec(result) {

        this.wiredContact = result;
        if (result.error) {
            this.error =result.error;
            console.error('Error', result.error);
             this.isSpinner = false;
        } else if (result.data) {
            this.contactId = result.data.fields[CONTACT_ID.fieldApiName].value;
            try {
            const registered = await isAlreadyRegistered({ contactId: this.contactId });
            this.isAlreadyRegistered = registered;


        } catch (error) {
            console.error('Registration check failed:', error);
            this.showStepOne();
        }

        }
    }
/**********************working one********************************************* */
   async getPlacementDetails(){
        getPlacementDetails({contactId: this.contactId})
            .then(res => {

                this.isPlacementRegistrationStarted = res && res.isPreOrFinalYear ? res.isPreOrFinalYear  : this.studentregrecordid;

                if (this.isPlacementRegistrationStarted && !this.alreayChecked) {

                this.keyForWire ++;
            }
            this.alreayChecked =true;
        })
        .catch(error => {
            this.isSpinner = false;
            const event = new ShowToastEvent({
                title : 'Error when processing ',
                message : error.body.message
            })
            this.dispatchEvent(event);
            return false;
        })
    }
   connectedCallback() {
    this.showStepOne(); // Keep this if you want default fallback
}
    updateStyles() {
        let iconStep = 1;
        let textStep = 2;
        let progressStep = 3;

        for (let i = 1; i <= 3; i++) {  // 5
            const icon = this.template.querySelector(`.div${iconStep}  img`);
            const text = this.template.querySelector(`.div${textStep} `);
            const progress = this.template.querySelector(`.div${progressStep}`);

            if (i < this.currentStep) {
                // Step completed
                icon.src = imageSources.BW[i];
                text.style.color = 'black';
                progress.style.backgroundColor = '#19a734';
            } else if (i === this.currentStep) {
                // Current step
                icon.src = imageSources.Orange[i];
                text.style.color = '#f57f26';
                progress.style.backgroundColor = '#f57f26';
            } else {
                // Upcoming steps
                icon.src = imageSources.BW[i];
                text.style.color = 'black';
                progress.style.backgroundColor = '#6F6F6F';
            }
            iconStep += 3;
            textStep += 3;
            progressStep += 3;
        }
    }

    handleOtpVerified() {
        this.isOtpVerified = true;
        this.showStepThree();
        this.keyForWire++;

    }
    @wire(fetchStudentRegDetailsfrom, {recordId: '$contactId', key:'$keyForWire'})
    async wiredStudentRecord(result){

        if(this.contactId){
            const isPlacementCreated = await this.getPlacementDetails();
        }
        this.isSpinner = true;
        if (!this.isPlacementRegistrationStarted) {
            this.isSpinner = false;
        }
        this.wiredData = result;
        if (result.data) {

            if (result.data.length > 0) {

                    this.isOtpVerified = true;
                    //Program_Name__c
                    this.studentregrecordid = result.data[0].Id;
                if (this.isThirdStepEventTriggered) {

                        this.isThirdStepEventTriggered = false;
                        this.showStepFour();
                        this.isSpinner = false;
                        return;
                    }
                    this.isStudentBasicDetailsSaveBtnDisabled = result.data[0].Rpl_Is_Student_Details_Verified__c;
                    this.isRecordUnderApprovalProcess = result.data[0].Rpl_Is_Under_Approval_Process__c;
                    this.isApprovalSuccess = result.data[0].Rpl_Status__c === 'Registration Successfully' ? true : false;
                if (this.isApprovalSuccess) {
                    this.isPlacementRegistrationStarted = false;

                        this.isSpinner = false;
                        return;
                }


                    if (!this.isRecordUnderApprovalProcess) {

                        if (this.isThirdStepEventTriggered) {
                            return; // ✅ prevent override
                        }

                        if (!this.isOtpVerified) {
                            this.showStepTwo();
                        } else if (!this.isBasicDetailsCompleted) {
                            this.showStepThree();
                        } else {
                            this.showStepFour(); // ✅ move forward properly
                        }
                    }else {
                       this.showStepOne();
                    }
                }else{
                    this.showStepOne();
                }
        }else if(result.error){
        }
        this.isSpinner = false;
    }



    handleBasicDetailsCompleted(event) {
    this.isThirdStepEventTriggered = true;
    this.keyForWire++;

    this.showStepFour();

    // Optional: store data from the child event
    this.studentregrecordid = event.detail.recordId;
    this.isBasicDetailsCompleted = event.detail.isBasicDetailsCompleted;
}




    handleDocumentUploadCompleted() {
        this.showStepFour();
    }



handleStepClick(event) {
        const stepNumber = event.target.dataset.stepNumber;
        this.currentStep = parseInt(stepNumber);        
       
       if (this.isRecordUnderApprovalProcess) {
        this.showErrorToastMessage(
            'Record Under Review',
            'We appreciate your submission. However, your record is currently under review, and editing is temporarily disabled.'
        );
        return;
    }
       
        switch (stepNumber) {
            case '1':
                if(this.isOtpVerified){
                    this.showErrorToastMessage('Already Registered', 'You have already registered for placement');
                    return;
                }                
                this.showStepOne();
                break;
            case '2':
                 if(this.isOtpVerified){
                    this.showErrorToastMessage('Already Verified', 'You have already verified your email and mobile number');
                    return;
                }
                if (!this.studentRegDetails || !this.studentRegDetails.Contact__c) {
                this.showErrorToastMessage(
                    'Registration Required',
                    'Please register before verifying OTP'
                );
                return;
            }
                  this.showStepTwo();
            break;
           case '3':
            if (!this.isOtpVerified) {
                this.showErrorToastMessage(
                    'Verification Required',
                    'Please verify Email/SMS before filling Basic Details'
                );
                return;
            }
            this.showStepThree();
            break;
            case '4':
            if (!this.isOtpVerified) {
                this.showErrorToastMessage(
                    'Verification Required',
                    'Please verify Email/SMS before uploading documents'
                );
                return;
            }
            this.showStepFour();
            break;
            case '5':
            if (!this.isOtpVerified) {
                this.showErrorToastMessage(
                    'Verification Required',
                    'Please complete previous steps before submitting'
                );
                return;
            }
            this.showStepFive();
            break;

        default:
            break;
    }
    }

showStepOne() {

    this.currentStep = 1;
    this.resetSteps();
    this.isFirstStep = true;
}

showStepTwo() {

    this.currentStep = 2;
    this.resetSteps();
    this.isSecondStep = true; // ✅ Will render Fill Basic Details
}

showStepThree() {
    this.currentStep = 3;
    this.resetSteps();
    this.isThirdStep = true;
}

showStepFour() {
    this.currentStep = 4;
    this.resetSteps();
    this.isFourthStep = true;
}

resetSteps() {
    this.isFirstStep = false;
    this.isSecondStep = false;
    this.isThirdStep = false;
    this.isFourthStep = false;
}



    handleApprovalSubmit(event) {
        this.showStepOne();
        location.reload();
    }

    showErrorToastMessage(title, message) {
        const evnt = new ShowToastEvent({
                message,
                variant: 'destructive',
                title,
            }
        )
        this.dispatchEvent(evnt);
    }

    handlestudentselfregister(event) {
        this.isOtpVerified = false;
        this.studentRegDetails = event.detail.message;
        this.isAlreadyRegistered = true; 
      this.showStepTwo();
    }


    handlerevaverifysms(event) {
        //this.showStepThree();

    }

    get stepOneLabel() {
    return this.isAlreadyRegistered ? '✅ Registered' : 'Register Yourself';
}

get stepOneColorStyle() {
    return this.isAlreadyRegistered ? 'color: green; cursor: default;' : 'color: #f57f26;';
}

get stepOneButtonStyle() {
    return this.isAlreadyRegistered ? 'background-color: green; cursor: default;' : 'background-color: #f57f26;';
}

get stepOneButtonLabel() {
    return this.isAlreadyRegistered ? '✔' : '1';
}

get stepTwoLabel() {
    return this.isBasicDetailsCompleted  ? '✅ Basic Details Filled' : 'Fill Basic Details';
}
get stepTwoColorStyle() {
    return this.isBasicDetailsCompleted ? 'color: green; cursor: default;' : 'color: #f57f26;';
}
get stepTwoButtonStyle() {
    return this.isBasicDetailsCompleted ? 'background-color: green; cursor: default;' : 'background-color: #f57f26;';
}
get stepTwoButtonLabel() {
    return this.isBasicDetailsCompleted ? '✔' : '3';
}

// STEP 3
get stepThreeLabel() {
    return this.isDocumentUpload  ? '✅ Documents Uploaded' : 'Document Upload';
}
get stepThreeColorStyle() {
    return this.isDocumentUpload  ? 'color: green; cursor: default;' : 'color: #f57f26;';
}
get stepThreeButtonStyle() {
    return this.isDocumentUpload  ? 'background-color: green; cursor: default;' : 'background-color: #f57f26;';
}
get stepThreeButtonLabel() {
    return this.isDocumentUpload ? '✔' : '4';
}


}