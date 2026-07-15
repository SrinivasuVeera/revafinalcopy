import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendEmailOtp from '@salesforce/apex/NewLeadCreation.sendEmailOtp';
import verifyEmailOtp from '@salesforce/apex/StudentAdmissionSinglePageController.verifyEmailOtp';
import sendOtp from '@salesforce/apex/StudentAdmissionSinglePageController.sendOtp';
import verifyOtp from '@salesforce/apex/StudentAdmissionSinglePageController.verifyOtp';
import resendOtp from '@salesforce/apex/StudentAdmissionSinglePageController.resendOtp';
import getStatePicklist from '@salesforce/apex/StudentAdmissionSinglePageController.getStatePicklist';
import getCountryPicklist from '@salesforce/apex/StudentAdmissionSinglePageController.getCountryPicklist';
import getSourcePicklist from '@salesforce/apex/StudentAdmissionSinglePageController.getSourcePicklist';
import getCountryCodePicklist from '@salesforce/apex/StudentAdmissionSinglePageController.getCountryCodePicklist';
import getSchoolPrograms from '@salesforce/apex/RegistrationFormUtility.getSchoolPrograms';
import getSchoolProgramCategoryData from '@salesforce/apex/StudentAdmissionSinglePageController.getSchoolProgramCategoryData';
import updateAndSendMobileOtp from '@salesforce/apex/NewLeadCreation.updateAndSendMobileOtp';
import updateLeadBeforeOTP from '@salesforce/apex/NewLeadCreation.updateLeadBeforeOTP';
import submitApplication from '@salesforce/apex/NewLeadCreation.submitApplication';
import validateLead from '@salesforce/apex/NewLeadCreation.validateLead';
import redirectToPaymentPage from '@salesforce/apex/StudentAdmissionSinglePageController.redirectToPaymentPage';
import getProgramsBySchool from '@salesforce/apex/RegistrationFormUtility.getProgramsBySchool';
import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Lead.Id';
import ASSIGNED_FIELD from '@salesforce/schema/Lead.Assigned__c';
import { RefreshEvent } from 'lightning/refresh';

export default class NewleadCreation extends LightningElement {
    @track firstName = ''; @track lastName = ''; @track email = '';
    @track phoneCode = ''; @track mobileNumber = ''; @track emailOtp = ''; @track otp = '';
    @track category = ''; @track selectedSchool = ''; @track selectedProgram = '';
    @track source = 'Walk-In';

    @track isEmailVerified = false; @track showEmailOTP = false; @track emailExists = false;
    @track isVerified = false; @track showMobileOtp = false; @track isEmailSending = false;
    @track declarationChecked = false; @track isSubmitting = false;

    @track phoneCodeOptions = []; @track categoryOptions = [];
    @track schools = []; @track programs = []; @track sourceOptions = []; 
    @track disableState = false;
    @track disableCountry = false;
    @track stateOptions = [];
    @track countryOptions = [];
    @track state = '';
    @track country = '';
    @track leadHasMobile = false;

    saarcCountryOptions = [
    { label: 'Afghanistan', value: 'Afghanistan' },
    { label: 'Bangladesh', value: 'Bangladesh' },
    { label: 'Bhutan', value: 'Bhutan' },
    { label: 'India', value: 'India' },
    { label: 'Maldives', value: 'Maldives' },
    { label: 'Nepal', value: 'Nepal' },
    { label: 'Pakistan', value: 'Pakistan' },
    { label: 'Sri Lanka', value: 'Sri Lanka' }
];

    schoolProgramsMap = new Map();
    leadId;

    connectedCallback() {
        getCountryCodePicklist().then(data => {
            this.phoneCodeOptions = data.map(item => ({ label: item.label, value: item.value }));
        });
        getSourcePicklist().then(data => {
            const allowedSources = ['Walk-In', 'Telephony'];

            this.sourceOptions = data
                .filter(item => allowedSources.includes(item.value))
                .map(item => ({
                    label: item.label,
                    value: item.value
                }));
        });
        getSchoolProgramCategoryData().then(data => {
            this.categoryOptions = data.categories || [];
        });
    }

  @wire(getSchoolPrograms, { selectionMode: 'ApplicationFee' })
        wiredPrograms({ data, error }) {
        if (data) {

            this.schoolProgramsMap = new Map();
            const CSE_BASE = 'School of Computer Science and Engineering';

            data.forEach(item => {
                let schoolName = item.School_Name__c;
                let programName = item.Program_Name_Display__c;

                if (!schoolName || !programName) return;

                if (schoolName.startsWith(CSE_BASE)) {
                    schoolName = CSE_BASE;
                }

                if (!this.schoolProgramsMap.has(schoolName)) {
                    this.schoolProgramsMap.set(schoolName, new Set());
                }

                this.schoolProgramsMap.get(schoolName).add(programName);
            });

            this.schools = Array.from(this.schoolProgramsMap.keys())
                .map(s => ({ label: s, value: s }));
        }

        if (error) {
            console.error('School program load error', error);
        }
    }
    handleStateChange(event) {
        this.state = event.detail.value;
    }
    handleCountryChange(event) {
        this.country = event.detail.value;
    }
      get showStatePicklist() {
        return this.category === 'Non-Karnataka';
    }
    get showCountryPicklist() {
        return this.category === 'Indian (SAARC)' || this.category === 'Non-Resident Indian(NRI)' || this.category === 'Foreign Nationals';
    }
    // Handlers
    handleFirstNameChange(e) { this.firstName = e.target.value; }
    handleLastNameChange(e) { this.lastName = e.target.value; }
    handleEmailChange(e) { this.email = e.target.value; }
    handleMobileChange(e) { this.mobileNumber = e.target.value; }
    handleEmailOtpChange(e) { this.emailOtp = e.target.value; }
    handleOtpChange(e) { this.otp = e.target.value; }
    handleCategoryChange(e) { 
        this.category = e.detail.value;

    if (this.category === 'Non-Karnataka') {

        getStatePicklist().then(data => {
            this.stateOptions = data;
        });
        console.log()
        if (!this.disableCountry) this.country = 'India';

    } else if (this.category === 'Karnataka') {
        this.stateOptions = [];
        if (!this.disableState) this.state = 'Karnataka';
        if (!this.disableCountry) this.country = 'India';

    } else if (
        this.category === 'SAARC' ||
        this.category === 'Indian (SAARC)'
    ) {
        // ✅ ONLY SAARC COUNTRIES
        this.countryOptions = this.saarcCountryOptions;
        if (!this.disableState) this.state = '';

    } else if (
        this.category === 'Non-Resident Indian(NRI)' ||
        this.category === 'Foreign Nationals'
    ) {
        // ✅ ALL COUNTRIES
        getCountryPicklist().then(data => {
            this.countryOptions = data;
        });
        if (!this.disableState) this.state = '';

    } 
     }
    handleDeclarationChange(e) { this.declarationChecked = e.target.checked; }
    handlePhoneCodeChange(e) { this.phoneCode = e.detail.value; }
    handleSourceChange(e) { this.source = e.detail.value; }

   onSchoolChange(e) {
    this.selectedSchool = e.target.value;
    const pSet = this.schoolProgramsMap.get(this.selectedSchool);

    if (pSet) {
        this.programs = Array.from(pSet).map(p => ({
            label: p,
            value: p
        }));
    } else {
        this.programs = [];
    }
}
onProgramChange(e) { this.selectedProgram = e.target.value; }

    // Logic for Verification
    sendEmailOtp = async () => {
        if (!this.leadId) {
            this.showToast('Error', 'Please click Submit to create the lead first', 'error');
            return;
        }

        try {
            // Passing leadId ensures we update the EXISTING record
            await sendEmailOtp({
                email: this.email,
                firstName: this.firstName,
                lastName: this.lastName,
                leadId: this.leadId 
            });

            this.showEmailOTP = true; // Shows the OTP input field
            this.showToast('Success', 'OTP sent to ' + this.email, 'success');

        } catch (e) {
            this.showToast('Error', e.body?.message, 'error');
        }
    }
    handleEditEmail() {
    this.isEmailVerified = false;
    this.showEmailOTP = false;
    this.emailOtp = '';
}

    verifyEmailOtp = async () => {
        try {
            const res = await verifyEmailOtp({ leadId: this.leadId, otp: this.emailOtp });
            if (res.isVerified) {
                this.isEmailVerified = true;
                this.showEmailOTP = false; // Hide OTP input after success
                this.showToast('Success', 'Email verified successfully!', 'success');
            } else {
                this.showToast('Error', 'Invalid OTP.', 'error');
            }
        } catch (e) {
            this.showToast('Error', 'Verification error.', 'error');
        }
    }

    handleResendEmailOtp = async () => {
        try {
            await resendOtp({ leadId: this.leadId });
            this.showToast('Success', 'A new OTP has been sent to your email.', 'success');
        } catch (e) { this.showToast('Error', 'Failed to resend OTP.', 'error'); }
    }

    sendOtp = async () => {
    try {
        const extractedCode = this.phoneCode.match(/\(\+\d+\)/)?.[0].replace(/[()]/g, '');
        const combinedNumber = `${extractedCode}-${this.mobileNumber}`;
        
        // 2. STEP A: Update the Lead record first
        // This ensures the DB matches the UI so the backend check passes
        await updateLeadBeforeOTP({
            leadId: this.leadId,
            phoneCode: this.phoneCode,
            mobileNumber: this.mobileNumber
        });

        console.log('STEP 2: Sending OTP...');

        // 3. STEP B: Call the original OTP service
        // Since the Lead is already updated, this will not throw WRONG_MOBILE
        await sendOtp({
            leadId: this.leadId,
            phoneCode: this.phoneCode,
            mobileNumber: combinedNumber,
            email: this.email
        });

        this.showMobileOtp = true;
        this.showToast('Success', 'OTP sent to mobile.', 'success');

    } catch (error) {
        console.error('ERROR DETAIL => ', error);
        
        let message = 'Something went wrong';
        if (error.body && error.body.message) {
            message = error.body.message;
        }

        // Specific handling for known error codes
        if (message === 'WRONG_MOBILE') {
            this.showToast('Error', 'Mobile number does not match. Please try clicking Submit again.', 'error');
        } else if (message === 'DUPLICATE_MOBILE') {
            this.showToast('Error', 'This mobile number is already registered.', 'error');
        } else {
            this.showToast('Error', message, 'error');
        }
    }
};
    verifyOtp = async () => {
        try {
            const valid = await verifyOtp({ leadId: this.leadId, otp: this.otp });
            if (valid) {
                this.isVerified = true;
                this.showToast('Success', 'Mobile number verified successfully!', 'success');
            } else {
                this.showToast('Error', 'Invalid Mobile OTP. Please try again.', 'error');
            }
        } catch (e) { this.showToast('Error', 'Verification failed.', 'error'); }
    }

    handleResendOtp = async () => {
        try {
            await resendOtp({ leadId: this.leadId, phoneCode: this.phoneCode });
            this.showToast('Success', 'A new OTP has been sent to your mobile.', 'success');
        } catch (e) { this.showToast('Error', 'Failed to resend OTP.', 'error'); }
    }
    validateForm() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (!allValid) {
            this.showToast('Error', 'Please fill in all required fields before proceeding.', 'error');
        }
        return allValid;
    }

    submitApplication = async () => {

    if (!this.validateForm()) return;

    if (this.isSubmitting) return;
    this.isSubmitting = true;

    try {

       // ✅ ONLY validate on first submit
if (!this.leadId) {

    const validationResult = await validateLead({
        email: this.email,
        mobileNumber: this.mobileNumber,
        phoneCode: this.phoneCode
    });

    if (validationResult === 'EMAIL_EXISTS') {
    this.showToast('Error', 'Email is already registered. Kindly go to the website and complete the registration.', 'error');
    this.isSubmitting = false;
    return;
}

if (validationResult === 'MOBILE_EXISTS') {
    this.showToast('Error', 'Mobile is already registered. Kindly go to the website and complete the registration.', 'error');
    this.isSubmitting = false;
    return;
}

if (validationResult === 'EMAIL_MOBILE_EXISTS') {
    this.showToast('Error', 'Both email and mobile number are already registered. Kindly go to the website and complete the registration.', 'error');
    this.isSubmitting = false;
    return;
}
}

        // ✅ STEP 4: Proceed only if OK
        const studentData = {
            leadId: this.leadId,
            email: this.email,
            firstName: this.firstName,
            lastName: this.lastName,
            phoneCode: this.phoneCode,
            mobileNumber: this.mobileNumber,
            category: this.category,
            state: this.state,
            country: this.country,
            school: this.selectedSchool,
            program: this.selectedProgram,
            source: this.source
        };

        const result = await submitApplication({ studentData });

        if (!this.leadId) {
            this.leadId = result;
            this.showToast('Success', 'Lead created successfully. Please verify Email and Mobile.', 'success');
        } else {
            this.showToast('Success', 'Application submitted successfully!', 'success');
            setTimeout(() => {
        this.PaymentPage();
    }, 1500);
        }

    } catch (error) {
        console.error(error);
        let message = error?.body?.message;

    if (message === 'EMAIL_EXISTS') {
        this.showToast('Error', 'This email is already registered.', 'error');
    } 
    else if (message === 'MOBILE_EXISTS') {
        this.showToast('Error', 'This mobile number is already registered.', 'error');
    } 
    else if (message === 'EMAIL_MOBILE_EXISTS') {
        this.showToast('Error', 'Both email and mobile are already registered.', 'error');
    } 
    else {
        this.showToast('Error', 'Submission failed.', 'error');
    }
    } finally {
        this.isSubmitting = false;
    }
};

    PaymentPage() {
      //  redirectToPaymentPage({ applicationId: this.leadId }).then(url => {
       //     window.location.href = url;
      //  });
      this.dispatchEvent(new CustomEvent('close'));
      window.location.reload();
    }
    get isLeadCreated() {
        return !!this.leadId;
    }

    // Getters
    get isVerifyEmailDisabled() {
    return !this.isLeadCreated || this.isEmailVerified;
}
    get isSendOtpDisabled() {
    return !this.isLeadCreated || !this.isEmailVerified || this.isVerified || !this.phoneCode || !this.phoneCode.includes('+91');
}
    get isSubmitDisabled() {
           if (this.isSubmitting) return true;
        if (!this.isLeadCreated) return false; 
        const isIndia = this.phoneCode && this.phoneCode.includes('+91');
        return !this.declarationChecked || (isIndia && !this.isVerified) || !this.isEmailVerified;
    }
    get disableCat() { return !this.isVerified; }
    get submitLabel() { return this.isSubmitting ? 'Saving...' : 'Submit'; }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}