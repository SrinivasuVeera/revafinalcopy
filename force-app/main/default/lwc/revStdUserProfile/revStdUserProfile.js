import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CONTACT_ID_FIELD from '@salesforce/schema/User.ContactId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const SEMESTER_FIELDS = ['hed__Term__c.Name'];
const CONTACT_FIELDS =
    ['Contact.Name', 'Contact.Student_Status__c', 'Contact.School_Name__c',
        'Contact.Academic_Program__c', 'Contact.Program_Batch_Name__c', 'Contact.Active_Section__c',
        'Contact.Personal_Email__c', 'Contact.hed__Gender__c', 'Contact.Blood_Group__c', 'Contact.Mother_Tongue__c', 'Contact.Marital_Status__c',
        'Contact.Aadhar_Card_Number__c', 'Contact.PAN_Number__c', 'Contact.Nationality__c', 'Contact.hed__Religion__c', 'Contact.Caste_Category__c', 'Contact.Date_of_Admission_in_Institute__c', 'Contact.Quota__c', 'Contact.Admission_Mode__c', 'Contact.Enrollment_Type__c', 'Contact.Select_Category__c',
        'Contact.Father_Name__c', 'Contact.Father_Email_ID__c', 'Contact.Father_Mobile_Number__c',
        'Contact.Mother_Name1__c', 'Contact.Mother_Email_ID__c', 'Contact.Mother_Mobile_Number__c',
        'Contact.Bank_Beneficiary_Name__c', 'Contact.Bank_Name__c', 'Contact.Bank_Account_Number__c', 'Contact.Bank_Branch_Name__c', 'Contact.IFSC_Code__c', 'Contact.UPI_Number__c'];
export default class RevStdUserProfile extends LightningElement {

    userContactId;
    @track contactRecord;
    activeSemesterId;
    activeSemesterRecord;


    @wire(getRecord, { recordId: USER_ID, fields: CONTACT_ID_FIELD })
    wiredUser({ error, data }) {
        if (data) {
            this.userContactId = getFieldValue(data, CONTACT_ID_FIELD); //Accepts String ,i.e, Field Api Name 

        } else if (error) {
            this.showErrorToast(error.body.message);
        }
    }


    // Retrieve the Contact record based on the ContactId retrieved from the User record
    @wire(getRecord, { recordId: '$userContactId', fields: CONTACT_FIELDS })
    wiredContactRecord({ error, data }) {
        if (data) {
            this.contactRecord = data;
            this.activeSemesterId = getFieldValue(this.contactRecord, 'Contact.Active_Section__c') || 'N/A';

        } else if (error) {
            this.showErrorToast(error.body.message);

        }
    }




    @wire(getRecord, { recordId: "$activeSemesterId", fields: SEMESTER_FIELDS })
    wiredActiveSection({ error, data }) {
        if (error) {
            this.showErrorToast(error.body.message);
        } else if (data) {
            this.activeSemesterRecord = data;

        }
    }




    get contactName() {
        return this.capitalizeFirstLetterOfEachWord(getFieldValue(this.contactRecord, 'Contact.Name'));
    }
    get status() {
        return getFieldValue(this.contactRecord, 'Contact.Student_Status__c') || 'N/A';
    }
    get schoolName() {
        return getFieldValue(this.contactRecord, 'Contact.School_Name__c') || 'N/A';
    }

    get academicProgram() {
        return getFieldValue(this.contactRecord, 'Contact.Academic_Program__c') || 'N/A';
    }
    get programBatchName() {
        return getFieldValue(this.contactRecord, 'Contact.Program_Batch_Name__c') || 'N/A';
    }

    get semester() {
        return getFieldValue(this.activeSemesterRecord, 'hed__Term__c.Name') || 'N/A';
    }
    get email() {
        return getFieldValue(this.contactRecord, 'Contact.Personal_Email__c') || 'N/A';
    }
    get gender() {
        return getFieldValue(this.contactRecord, 'Contact.hed__Gender__c') || 'N/A';
    }
    get bloodGroup() {
        return getFieldValue(this.contactRecord, 'Contact.Blood_Group__c') || 'N/A';
    }

    get motherTongue() {
        return getFieldValue(this.contactRecord, 'Contact.Mother_Tongue__c') || 'N/A';
    }
    get martialStatus() {
        return getFieldValue(this.contactRecord, 'Contact.Marital_Status__c') || 'N/A';
    }

    get adhaarNumber() {
        return getFieldValue(this.contactRecord, 'Contact.Aadhar_Card_Number__c') || 'N/A';
    }
    get panNumber() {
        return getFieldValue(this.contactRecord, 'Contact.PAN_Number__c') || 'N/A';
    }
    get nationality() {
        return getFieldValue(this.contactRecord, 'Contact.Nationality__c') || 'N/A';
    }

    get religion() {
        return getFieldValue(this.contactRecord, 'Contact.hed__Religion__c') || 'N/A';
    }
    get casteCategory() {
        return getFieldValue(this.contactRecord, 'Contact.Caste_Category__c') || 'N/A';
    }

    get admissionDate() {
        return getFieldValue(this.contactRecord, 'Contact.Date_of_Admission_in_Institute__c') || 'N/A';
    }
    get quota() {
        return getFieldValue(this.contactRecord, 'Contact.Quota__c') || 'N/A';
    }

    get admissionMode() {
        return getFieldValue(this.contactRecord, 'Contact.Admission_Mode__c') || 'N/A';
    }
    get enrollmentType() {
        return getFieldValue(this.contactRecord, 'Contact.Enrollment_Type__c') || 'N/A';
    }
    get selectCategory() {
        return getFieldValue(this.contactRecord, 'Contact.Select_Category__c') || 'N/A';
    }
    get fatherName() {
        return getFieldValue(this.contactRecord, 'Contact.Father_Name__c') || 'N/A';
    }
    get fatherEmailId() {
        return getFieldValue(this.contactRecord, 'Contact.Father_Email_ID__c') || 'N/A';
    }
    get fatherMobileNumber() {
        return getFieldValue(this.contactRecord, 'Contact.Father_Mobile_Number__c') || 'N/A';
    }

    get motherName() {
        return getFieldValue(this.contactRecord, 'Contact.Mother_Name1__c') || 'N/A';
    }
    get motherEmailId() {
        return getFieldValue(this.contactRecord, 'Contact.Mother_Email_ID__c') || 'N/A';
    }
    get motherMobileNumber() {
        return getFieldValue(this.contactRecord, 'Contact.Mother_Mobile_Number__c') || 'N/A';
    }

    get bankBeneficiaryName() {
        return getFieldValue(this.contactRecord, 'Contact.Bank_Beneficiary_Name__c') || 'N/A';
    }
    get bankName() {
        return getFieldValue(this.contactRecord, 'Contact.Bank_Name__c') || 'N/A';
    }
    get bankAccountNumber() {
        return getFieldValue(this.contactRecord, 'Contact.Bank_Account_Number__c') || 'N/A';
    }
    get bankBranchName() {
        return getFieldValue(this.contactRecord, 'Contact.Bank_Branch_Name__c') || 'N/A';
    }
    get bankIfscCode() {
        return getFieldValue(this.contactRecord, 'Contact.IFSC_Code__c') || 'N/A';
    }
    get bankUpiNumber() {
        return getFieldValue(this.contactRecord, 'Contact.UPI_Number__c') || 'N/A';
    }







    // Helper method to capitalize the first letter of each word in a string
    capitalizeFirstLetterOfEachWord(value) {
        // Check if the value is null or undefined, return 'N/A'
        if (value === null || value === undefined) {
            return 'N/A';
        }

        const stringValue = typeof value === 'string' ? value : String(value);
        return stringValue
            .split(' ')
            .map(word => word ? word.charAt(0).toUpperCase() + word.slice(1).toLowerCase() : '')
            .join(' ');
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