/**
 * @description: Single-page LWC for student admission registration. Integrates all steps: email, details, OTP, program selection, declaration, and submission.
 * @author: GitHub Copilot
 * @group: Admissions
 * @version: 1.0
 * @Last Modified on: 2025-10-10
 * @Last Modified by: GitHub Copilot
 */
import { LightningElement, track, api, wire } from 'lwc';
import checkExistingEmail from '@salesforce/apex/StudentAdmissionSinglePageController.checkExistingEmail';
import sendOtp from '@salesforce/apex/StudentAdmissionSinglePageController.sendOtp';
import sendEmailOtp from '@salesforce/apex/StudentAdmissionSinglePageController.sendEmailOtp';
import verifyOtp from '@salesforce/apex/StudentAdmissionSinglePageController.verifyOtp';
import verifyEmailOtp from '@salesforce/apex/StudentAdmissionSinglePageController.verifyEmailOtp';
import getSchoolProgramCategoryData from '@salesforce/apex/StudentAdmissionSinglePageController.getSchoolProgramCategoryData';
import submitApplication from '@salesforce/apex/StudentAdmissionSinglePageController.submitApplication';
import redirectToPaymentPage from '@salesforce/apex/StudentAdmissionSinglePageController.redirectToPaymentPage';
import redirectToPaymentPageNew from '@salesforce/apex/StudentAdmissionSinglePageController.redirectToPaymentPageNew';
import getCountryCodePicklist from '@salesforce/apex/StudentAdmissionSinglePageController.getCountryCodePicklist';
import resendOtp from '@salesforce/apex/StudentAdmissionSinglePageController.resendOtp';
import getStatePicklist from '@salesforce/apex/StudentAdmissionSinglePageController.getStatePicklist';
import getCountryPicklist from '@salesforce/apex/StudentAdmissionSinglePageController.getCountryPicklist';
import getContactInfo from '@salesforce/apex/StudentAdmissionSinglePageController.getContactInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ADMISSIONPORTALASSETS from '@salesforce/resourceUrl/SR_ADMISSIONPORTALASSESTS';
//import Admission_BackgroundLogo from '@salesforce/resourceUrl/Admission_Background_Logo';
import getNameByEmail from '@salesforce/apex/StudentAdmissionSinglePageController.getNameByEmail';
import getSchoolPrograms from '@salesforce/apex/RegistrationFormUtility.getSchoolPrograms';
import redirectToApplicantPortal from '@salesforce/apex/StudentAdmissionSinglePageController.redirectToApplicantPortal';
import getProgramsBySchool from '@salesforce/apex/RegistrationFormUtility.getProgramsBySchool';
import banner from '@salesforce/resourceUrl/application_mob_bg';

const baseImageUrl = `${ADMISSIONPORTALASSETS}/AdmissionPortalAssets/Icons`;

export default class StudentAdmissionSinglePageNew extends LightningElement {
    registrationProcessImageUrl = `${baseImageUrl}/registration-process.png`;
    mobBackgroundStyle = `background-image: url(${banner});`;
    //BannerImage=Admission_BackgroundLogo;
    @api propYear = '2026';
    @track state = '';
    @track country = '';
    @track stateOptions = [];
    @track countryOptions = [];
    // UI state
    @track isVerified = false; // set true after successful OTP verification
    @track isEmailVerified = false;
    @track isSubmitting = false; // to prevent multiple submits
    @track submitErrorMessage = '';
    resendOtpMessage = '';
    resendEmailOtpMessage = '';
    @track email = '';
    @track firstName = '';
    @track lastName = '';
    @track phoneCode = '';
    @track mobileNumber = '';
    @track otp = '';
    @track emailoOtp = '';
    @track expectedOtp = '';
    @track leadId = '';
    @track contactId = '';
    @track school = '';
    @track program = '';
    @track category = '';
    @track declarationChecked = false;
    @track emailExists = false;
    @track emailInvalid = false;
    @track otpError = false;
    @track emailOtpError = false;
    @track phoneCodeOptions = [];
    @track schoolOptions = [];
    @track programOptions = [];
    @track categoryOptions = [];
    @track mobileErrorMessage = '';
    @track disableEmail = false;
    @track disable = true;
    @track disablePhoneOtp = true;
    @track disableSendOtp = true;
    @track disableOtp = true;
    @track disableCat = true;
    @track disableSchool = true;
    @track disableProgram = true;
    @track disableDeclaration = true;
    @track verifyEmail = false;
    @track verifyPhone = true;
    @track mobileOtp = true;
    @track otherCountry = false;
    @track showEmailOTP = false;
    @track emailOtp = '';
    @track showcountryCode = false;
    @track showMobileOtp = false;
    @track showCategory = false;
    @track hideSendOtp = false;
    // Paid admission view
    @track showPaidView = false; // when true, show the "already registered/paid" page
    @track IsshowPaidView = false;
    @track paidName = '';
    @track paidSchool = '';
    @track paidProgram = '';
    @track paidApplicationNumber = '';
    @track paidMessage = '';
    @track addedMessage = '';
    @track isPUCView = false;
    @track showSubmitMessage = false;
    // Read-only contact fields to display near the title
    @track programBatchName = '';
    @track schoolName = '';
    @track applicationNumber = '';
    @track mobileError = '';
    @track emaildisable = false;
    @track oneClick = false;
    @track isSignInMode = false;
    @track isPaymentClicked = false;
    @track showSpinner = false;
    @track utmSource = '';
    @track utmMedium = '';
    @track utmCampaign = '';
    // @track utmTerm = '';
    // @track utmContent = '';
    @track disableState = false;
    @track disableCountry = false;
    @track disableRegisterPageLink = false;
    @api selectionMode = 'ApplicationFee';
    @api selectedSchool = '';
    @api selectedProgram = '';
    schools = [];
    programs = [];
    schoolPrograms = new Map(); //Key = School Name, Value = Set() of Program Name (Display)s
    programPB = new Map();

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

    @track validationErrors = {};

    @wire(getSchoolPrograms, {selectionMode: '$selectionMode'})
    wiredSchoolPrograms({data, error}) {
 
    if (data) {
 
        const BASE_SCHOOLS = [
        'School of Computer Science and Engineering'
        ];
 
        data.forEach(item => {
 
        let schoolName = item.School_Name__c;
        let programName = item.Program_Name_Display__c;
 
        if (!schoolName || !programName) return;
       
        BASE_SCHOOLS.forEach(base => {
            if (schoolName.startsWith(base)) {
            schoolName = base;
            }
        });
 
        if (!this.schoolPrograms.has(schoolName)) {
            this.schoolPrograms.set(schoolName, new Set());
        }
 
        this.schoolPrograms.get(schoolName).add(programName);
 
        this.programPB.set(programName, item.Program_Batch__c);
 
        });
 
        this.setSchoolOptions();
    }
 
    if (error) {
        console.log(error);
    }
    }

    async setSchoolOptions() {
        this.schools = [];
        this.schools.push({
            value: '',
            label: 'Select a School'
        });
        console.log(this.schoolPrograms.size);
        for (const [school, programs] of this.schoolPrograms) {
            this.schools.push({
                value: school,
                label: school
            });
        };
        const data = await getSchoolProgramCategoryData();
        console.log('Category Data :'+data.categories);
        this.categoryOptions = data.categories || [];
    }

    setProgramOptions() {
        this.programs = [];
        this.programs.push({
            value: '',
            label: 'Select a Program'
        });
        // this.schoolPrograms.get(this.selectedSchool).forEach(program => {
        if (this.school !== '') {
            for (const program of this.schoolPrograms.get(this.school)) {
                this.programs.push({
                    value: program,
                    label: program
                });
            };
        }
        //console.log(this.programs);   
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

    // Whether we have any contact info to show at the top
    get hasContactInfo() {
        return !!(this.programBatchName || this.schoolName || this.applicationNumber);
    }
    get isSendOtpDisabled() {
        console.log('leadId : '+!this.leadId +': Email Verified : '+!this.isEmailVerified+' : Mobile number :'+!this.mobileNumber+' isVerified : '+this.isVerified);
        return !this.leadId || !this.isEmailVerified || !this.mobileNumber || this.isVerified;
    }

    // Handler for resend button (calls Apex resendOtp)
    handleResendOtp = async () => {
        if (!this.leadId) return;
        const newOtp = await resendOtp({ leadId: this.leadId, phoneCode: this.phoneCode });
        this.expectedOtp = newOtp;
        this.resendOtpMessage = 'A new OTP has been sent.';
        this.otpError = false;
        this.otp = '';
    }
    handleResendEmailOtp = async () => {
        if (!this.leadId) return;
        const newOtp = await resendOtp({ leadId: this.leadId, email: this.email });
        this.expectedOtp = newOtp;
        this.resendEmailOtpMessage = 'A new OTP has been sent.';
        this.emailOtpError = false;
        this.emailOtp = '';
    }

    connectedCallback() {
        getCountryCodePicklist().then(data => {
            this.phoneCodeOptions = data.map(item => {
                // Extracts "+91" from "India (+91)"
                const codeMatch = item.label.match(/\(([^)]+)\)/);
                const code = codeMatch ? `(${codeMatch[1]})` : '';
                const countryName = item.label.split('(')[0].trim();

                return {
                    // Label becomes "(+91) | India"
                    label: `${code} | ${countryName}`,
                    value: item.value
                };
            });
        });

        const urlParams = new URLSearchParams(window.location.search);
        const emailParam = urlParams.get('c__email');
        console.log('urlParams' + urlParams);
        if (emailParam) {
            this.email = decodeURIComponent(emailParam);
            // Validate and set email state
            this.emailInvalid = !this.validateEmail(this.email);
            this.emaildisable = true;

            // ✅ AUTO-POPULATE FIRST & LAST NAME
            getNameByEmail({ email: this.email })
                .then(data => {
                    if (data) {
                        this.firstName = data.firstName || '';
                        this.lastName = data.lastName || '';
                    }
                })
                .catch(error => {
                    console.error('Error fetching name:', error);
                });
        }

        // ✅ UTM parameters
        this.utmSource = urlParams.get('utm_source') || 'direct';
        this.utmMedium = urlParams.get('utm_medium') || 'direct';
        this.utmCampaign = urlParams.get('utm_campaign') || 'direct';
        // this.utmTerm     = urlParams.get('utm_term')     || '';
        // this.utmContent  = urlParams.get('utm_content')  || '';

    }

    handleEmailChange(event) {
        this.email = event.target.value;
        this.emailInvalid = !this.validateEmail(this.email);
    }

    validateEmail(email) {
        // Simple email regex
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    }
    handleFirstNameChange(event) {
        this.firstName = event.target.value;
        this.updateSendOtpState();
    }
    handleLastNameChange(event) {
        this.lastName = event.target.value;
        this.updateSendOtpState();
    }
    handlePhoneCodeChange(event) {
        this.phoneCode = event.detail.value;
        // re-validate mobile when country code changes
        this.validateMobileNumber();
        this.updateSendOtpState();
        this.mobileError = '';
        if (this.phoneCode == '+91' || this.phoneCode == 'India (+91)') {
            this.disableCat = true;
        }
    }
    handleMobileChange(event) {
        this.mobileNumber = event.target.value;
        this.validateMobileNumber();
        this.updateSendOtpState();
    }

    async validateMobileNumber() {
        // Clear previous message
        this.mobileErrorMessage = '';
        if (!this.mobileNumber) return true;

        // Remove non-digit characters
        const digits = this.mobileNumber.replace(/[^0-9]/g, '');
        const code = (this.phoneCode || '').toString();

        // Check if country code is India (+91)
        const isIndia = code === '+91' || code.includes('91');

        if (isIndia) {
            this.showCategory = false;
            this.otherCountry = false;
            if (digits.length !== 10) {
                this.mobileErrorMessage = 'Enter Valid Mobile Number';
                this.mobileOtp = true;
                return false;
            } if (digits.length === 10 && this.phoneCode != '') {
                this.mobileOtp = false;
            }
        } else {
            this.otherCountry = true;
            this.disableCat = false;
            this.showCategory = true;
            // Fetch school/program/category data
            // const data = await getSchoolProgramCategoryData();
            // this.categoryOptions = data.categories || [];
            // this.disableDeclaration = false;

            // For other countries, you can allow flexible length (min 6, max 15 as example)
            if (digits.length < 6 || digits.length > 25) {
                this.mobileErrorMessage = 'Mobile number length is invalid for the selected country.';
                this.mobileOtp = true;

                return false;
            }
        }

        return true;
    }
    handleOtpChange(event) {
        this.otp = event.target.value;
    }
    handleEmailOtpChange(event) {
        this.emailOtp = event.target.value;
    }
    // handleSchoolChange(event) {
    //     this.school = event.detail.value;
    // }
    // handleProgramChange(event) {
    //     this.program = event.detail.value;
    // }


    onSchoolChange(event) {
 
        this.selectedProgram = '';
        this.school = event.detail.value;
 
        if (!this.disableSchool) {
            this.selectedProgram = '';
            this.program = '';
        }
 
        this.setProgramOptions();
 
        if (!this.program) {
            this.disableProgram = !this. School;
        }
 
    }

    onProgramChange(event) {
        this.program = event.target.value;

    }

    /*  handleCategoryChange(event) {
          this.category = event.detail.value;
          // Enable school after category is selected
          if (!this.school) {
          this.disableSchool = !this.category; 
      }
          // Show state picklist if Non-Karnataka
          if (this.category === 'Non-Karnataka') {
              getStatePicklist().then(data => {
                  this.stateOptions = data;
              });
               this.country = 'India';
          } else if(this.category === 'Karnataka'){
              this.stateOptions = [];
              this.state = this.category;
              this.country = 'India';
          }else if(this.category === 'SAARC' || this.category === 'Indian (SAARC)' ||this.category === 'Non-Resident Indian(NRI)'||this.category === 'Foreign Nationals' ) {
              getCountryPicklist().then(data => {
                  this.countryOptions = data;
                      this.state = '';
              });
  
          }else{
              this.stateOptions = [];
              this.state = '';
          }
      }*/


    handleCategoryChange(event) {
        this.category = event.detail.value;

        if (!this.school) {
            this.disableSchool = !this.category;
        }

        if (this.category === 'Non-Karnataka') {
            getStatePicklist().then(data => {
                this.stateOptions = data.filter(state => state.value !== 'Karnataka' && state.label !== 'Karnataka');
            });
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

    handleDeclarationChange(event) {
        this.declarationChecked = event.target.checked;
        if (this.declarationChecked == true) {
            this.disableDeclaration = false;
        }
    }

    updateSendOtpState() {
        // Enable Send OTP if firstName, lastName, phone, and country code are filled
        const mobileValid = !this.mobileErrorMessage;
        const emailValid = this.email && !this.emailInvalid;
        this.disableSendOtp = !(emailValid && this.firstName && this.lastName && this.mobileNumber && this.phoneCode && mobileValid);
    }

    // OTP input required flag for template
    get otpRequired() {
        return !this.disableOtp;
    }


    get isCheckEmailButtonDisabled() {
        return !this.email || this.emailInvalid || this.disableEmail;
    }

    // Disable Verify Email button until a valid email is entered or after it has been clicked
    /*get isVerifyEmailDisabled() {
        // return !this.email ||!this.lastName ||!this.firstName || this.emailInvalid || this.verifyEmail;
        return !this.leadId || this.isEmailVerified;
    } */

     get isVerifyEmailDisabled() {
            if (this.isSignInMode) {
                return !this.email || this.emailInvalid;
            }
            return !this.leadId || this.isEmailVerified;
     }   


    sendOtp = async () => {
        this.mobileError = ''; // reset previous error
        const extractedCode = this.phoneCode.match(/\(\+\d+\)/)?.[0].replace(/[()]/g, '');
        const combinedNumber = `${extractedCode}-${this.mobileNumber}`;
        try {
            const result = await sendOtp({
                leadId: this.leadId,
                phoneCode: this.phoneCode,
                mobileNumber: combinedNumber,
                email: this.email
            });
            this.expectedOtp = result.otp;
            this.leadId = result.leadId;
            this.verifyPhone = false;
            this.showMobileOtp = true;
            this.disablePhoneOtp = false;
            this.mobileOtp = true;
            this.disable = true;
            this.disableCat = true;
            // disable Send OTP button
            this.otherCountry = true;
        } catch (error) {
            console.error('OTP Error:', error);
            console.log(' error.body:', error.body);
            console.error('error.body.message:', error.body.message);
            if (error.body && error.body.message === 'DUPLICATE_MOBILE') {
                this.mobileError = 'This mobile number is already registered.';
            } else {
                this.mobileError = 'Wrong mobile Number. Please try again.';
            }
        }
    };


    sendEmailOtp = async () => {

        if ((!this.firstName || !this.lastName || !this.email) && this.isSignInMode == false) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Missing Information',
                    message: 'Please fill in First Name, Last Name, and Email before verifying.',
                    variant: 'error'
                })
            );
            return; // stop execution
        }
        console.log('Sending OTP to:', this.leadId);
        if (this.leadId) {
            this.oneClick = true;
            // Revisit OTP flow
            const newOtp = await resendOtp({ leadId: this.leadId });
            this.expectedOtp = newOtp;
            // Enable OTP field
            this.disableOtp = false;
            this.verifyEmail = true;
            this.showEmailOTP = true;
        } else {
            this.oneClick = true;
            // New lead OTP flow
            const result = await sendEmailOtp({
                email: this.email, firstName: this.firstName, lastName: this.lastName,
                utmSource: this.utmSource,
                utmMedium: this.utmMedium,
                utmCampaign: this.utmCampaign,
                // utmTerm: this.utmTerm,
                // utmContent: this.utmContent
            });
            this.expectedOtp = result.otp;
            this.leadId = result.leadId;
            // Enable OTP field
            this.disableOtp = false;
            this.verifyEmail = true;
            this.showEmailOTP = true;
        }
    }

    verifyOtp = async () => {
        // Call Apex with leadId and otp
        const valid = await verifyOtp({ leadId: this.leadId, otp: this.otp });
        if (valid) {
            this.disable = true;

            this.otpError = false;
            this.disableCat = false;
            this.showCategory = true;
            // Mark as verified and disable further OTP acstions
            this.isVerified = true;
            this.verifyPhone = true;
            this.resendOtpMessage = '';
            this.disableOtp = true;
            this.showSubmitMessage = true;
            // Fetch school/program/category data
            // const data = await getSchoolProgramCategoryData();
            // this.categoryOptions = data.categories || [];
            // this.disableDeclaration = false;
        } else {
            this.otpError = true;
        }
    }

    verifyEmailOtp = async () => {

        try {
            const result = await verifyEmailOtp({ leadId: this.leadId, otp: this.emailOtp });
            console.log('result' + JSON.stringify(result));
            if (result.isVerified) {
                this.isSignInMode = false;
                this.contactId = result.recordId;
                console.log('Verified Record Type:', result.recordType); // 'Lead' or 'Contact'
                this.emailOtpError = false;
                this.isEmailVerified = true;
                this.disableOtp = true;
                this.resendEmailOtpMessage = '';
                this.showcountryCode = true;
                this.firstName = result.firstName;
                this.lastName = result.lastName;
                // this.hideSendOtp = true;
                if (result.recordType === 'Lead') {
                    this.disable = false;
                    this.showPaidView = false;
                    console.log('mobileNumber:' + result.mobileNumber);
                    // const data = await getSchoolProgramCategoryData();
                    // this.categoryOptions = data.categories || [];

                    if (result.mobileNumber && result.phoneCode) {
                     //   this.mobileNumber = result.mobileNumber.replace('+91-','').replace('+91','');
                        this.mobileNumber = result.mobileNumber.replace(/^\+\d+-/, '');
                        this.phoneCode = result.phoneCode;
                        this.disable = true;
                        // ✅ MARK MOBILE AS VERIFIED
                        this.isVerified = false;
                        this.verifyPhone = false;
                        this.showMobileOtp = false;
                        this.otherCountry = false;
                        this.disableOtp = true;
                                                
                        const code = (this.phoneCode || '').toString();
                        // Check if country code is NOT India (+91)
                        const isNotIndia = !(code === '+91' || code.includes('91'));

                        if(result.mobOtpVerified || isNotIndia){
                            this.isVerified = true;
                        }
                        // ✅ ENABLE CATEGORY FLOW DIRECTLY
                        /*  this.disableCat = false;
                         this.showCategory = true;
     
                         // Load category data
                         const data = await getSchoolProgramCategoryData();
                         this.categoryOptions = data.categories || []; */
                    }
                    this.showCategory = true;
                    if (result.category) {
                        this.category = result.category;
                        this.disableCat = true; // Enable category dropdown
                        //this.showCategory = true;
                        // Manually call handleCategoryChange to load state/country options if needed for that category
                        // and enable the school/program picklists.
                        this.handleCategoryChange({ detail: { value: this.category } });

                        if (result.state) {
                            this.state = result.state;
                            this.disableState = true;
                        } else {
                            this.disableState = false;
                        }

                        // Populate and Lock Country
                        if (result.country) {
                            this.country = result.country;
                            this.disableCountry = true;
                        } else {
                            this.disableCountry = false;
                        }
                    } else {
                        this.disableCat = false; // UNLOCK to allow editing
                    }
                    if (result.school) {
                        this.school = result.school;
                        this.selectedSchool = result.school;
                        this.setProgramOptions();
                        this.disableSchool = true; // LOCK because data exists
                    } else {
                        // Only unlock school if category is already selected
                        this.disableSchool = this.category ? false : true;
                    }

                    // 4. Handle Program (Lock if exists, unlock if empty)
                    if (result.program) {
                        this.program = result.program;
                        this.selectedProgram = result.program;
                        this.disableProgram = true; // LOCK because data exists
                    } else {
                        // Only unlock program if school is selected
                        this.disableProgram = this.school ? false : true;
                    }
                } else if (result.recordType === 'Contact') {
                    this.disable = true;
                    this.emailExists = true;
                    this.showPaidView = false;

                } else if (result.recordType === 'Contact_Paid') {
                    // Show the admission/registered page with details (add-on, doesn't change existing flows)
                    this.showPaidView = true;
                    this.IsshowPaidView = true;
                    this.isSignInMode = false;
                    // Fetch contact info and populate the paid view fields
                    try {
                        const infoPaid = await getContactInfo({ contactId: this.contactId });
                        this.paidName = result.recordName || (this.firstName || '') + (this.lastName ? ' ' + this.lastName : '');
                        this.paidSchool = infoPaid.schoolName || result.schoolName || result.School || this.school || '';
                        // Combine program and batch display if available
                        this.paidProgram = infoPaid.programBatchName || result.programName || result.Program || result.program || this.program || '';
                        this.paidApplicationNumber = infoPaid.applicationNumber || result.applicationNumber || result.Application_Number__c || result.appNumber || this.contactId || result.recordId || '';
                        this.paidMessage = result.message || 'We will soon get in touch with you. Please note the above information for further reference.';
                        this.addedMessage = result.message || 'Please check your registered email to reset your password.';
                    } catch (err) {
                        console.error('Error fetching contact info for paid contact:', err);
                    }

                }
            } else {
                this.emailOtpError = true;
            }
        } catch (error) {
            console.error('Error verifying OTP:', error);
        }
    }

    goToDeclaration = () => {
        // Not needed in new UI logic
    }
    PaymentPage() {
        console.log('Redirecting to payment page for applicationId:', this.contactId);
        redirectToPaymentPage({ applicationId: this.contactId }).then(paymentUrl => {
            // window.location.href = paymentUrl;

            window.open(paymentUrl, '_blank');
        });
        this.isPaymentClicked = true;
    }
    PaymentPageNew() {
        console.log('Redirecting to new payment page for applicationId:', this.contactId);
        redirectToPaymentPageNew({ applicationId: this.contactId }).then(paymentUrl => {
            // window.location.href = paymentUrl;

            window.open(paymentUrl, '_blank');
        });
        this.isPaymentClicked = true;
    }

    // Change 06-03-2026
    // submitApplication = async () => {
    //     if (this.isSubmitting) return; // prevent double submit
    //     this.isSubmitting = true;
    //     this.submitErrorMessage = '';

    //      const paymentWindow = window.open('', '_blank');

    // try {

    //     const studentData = {
    //         leadId: this.leadId,
    //         email: this.email,
    //         firstName: this.firstName,
    //         lastName: this.lastName,
    //         phoneCode: this.phoneCode,
    //         mobileNumber: this.mobileNumber,
    //         school: this.school,
    //         program: this.program,
    //         category: this.category,
    //         state: this.state,
    //         country: this.country
    //     };

    //         const appId = await submitApplication({ studentData });
    //         const paymentUrl = await redirectToPaymentPage({ applicationId: appId });
    //         //window.location.href = paymentUrl;
    //         // window.open(paymentUrl, '_blank', 'noopener,noreferrer');
    //         paymentWindow.location.href = paymentUrl;

    //     } catch (err) {
    //         // Re-enable submit on error and show message
    //         this.submitErrorMessage = 'Submission failed. Please try again.';
    //         this.isSubmitting = false;
    //         // Optionally log error
    //         // console.error(err);
    //     }
    // }

    /* 16-03-2025
    submitApplication = async () => {
        // ✅ Validate all fields before proceeding
        if (!this.validateForm()) {
            return; // Stop submission, errors are shown in template
        }

        if (this.isSubmitting) return; // prevent double submit
        this.isSubmitting = true;
        this.submitErrorMessage = '';
        this.showSpinner= true;
        this.disableRegisterPageLink = true;
        // const paymentWindow = window.open('', '_blank');

        try {
            const studentData = {
                leadId: this.leadId,
                email: this.email,
                firstName: this.firstName,
                lastName: this.lastName,
                phoneCode: this.phoneCode,
                mobileNumber: this.mobileNumber,
                school: this.school,
                program: this.program,
                category: this.category,
                state: this.state,
                country: this.country
            };
            this.showSpinner = false;
            const appId = await submitApplication({ studentData }); 
            // const paymentUrl = await redirectToPaymentPage({ applicationId: appId });
            const paymentUrl = await redirectToPaymentPageNew({ applicationId: appId });
            // paymentWindow.location.href = paymentUrl;
             window.location.href = paymentUrl;

        } catch (err) {
            this.showSpinner = false;
            this.submitErrorMessage = 'Submission failed. Please try again.';
            this.isSubmitting = false;
        }
    } */

    /* submitApplication = async () => {
         if (this.isSubmitting) return; // prevent double submit
         this.isSubmitting = true;
         this.submitErrorMessage = '';
         this.showSpinner= true;
         // const paymentWindow = window.open('', '_blank');
 
     // try {
 
         const studentData = {
             leadId: this.leadId,
             email: this.email,
             firstName: this.firstName,
             lastName: this.lastName,
             phoneCode: this.phoneCode,
             mobileNumber: this.mobileNumber,
             school: this.school,
             program: this.program,
             category: this.category,
             state: this.state,
             country: this.country
         };
     
             // const appId = await submitApplication({ studentData });
             // const paymentUrl = await redirectToPaymentPage({ applicationId: appId });
             // //window.location.href = paymentUrl;
             // // window.open(paymentUrl, '_blank', 'noopener,noreferrer');
             // paymentWindow.location.href = paymentUrl;
 
            console.log('studentData:'+JSON.stringify(studentData));
              submitApplication({ studentData })
         .then(appId => {
             // 👉 second async call
             return redirectToPaymentPage({ applicationId: appId });
             
         })
         .then(paymentUrl => {
             const paymentWindow = window.open('', '_blank');
             // ✅ redirect only when URL is ready
             paymentWindow.location.href = paymentUrl;
             this.showSpinner = false;
         })
         .catch(error => {
             this.submitErrorMessage = 'Submission failed. Please try again.';
             this.isSubmitting = false;
             this.showSpinner = false;
             // console.error(error);
         });
 
         
         // } catch (err) {
         //     // Re-enable submit on error and show message
         //     this.submitErrorMessage = 'Submission failed. Please try again.';
         //     this.isSubmitting = false;
         //     // Optionally log error
         //     // console.error(err);
         // }
     }*/

    // Change 06-03-2026
    // get isSubmitDisabled() {
    //     return !this.declarationChecked || this.disableDeclaration || this.isSubmitting;
    // }

    // Change 06-03-2026
    submitApplication = async () => {

    if (!this.validateForm()) {
        return;
    }

    if (this.isSubmitting) return;

    this.isSubmitting = true;

    try {

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
        school: this.school,
        program: this.program,
        utmSource: this.utmSource,
        utmMedium: this.utmMedium,
        utmCampaign: this.utmCampaign
    };

        const result = await submitApplication({ studentData });

        if (!this.leadId) {

            this.leadId = result;

            this.verifyEmail = false;
            this.oneClick = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please verify your Email and Mobile number to proceed',
                    variant: 'warning'
                })
            );

            this.isSubmitting = false;
        }
        else {

            const paymentUrl = await redirectToPaymentPageNew({
                applicationId: result
            });

            window.location.href = paymentUrl;

        }

    } catch (error) {
            console.error(error);

            let message = error?.body?.message;

            if (message === 'EMAIL_EXISTS') {
                this.submitErrorMessage = 'Email is already registered. Click on Incomplete Registration to continue with your existing application.';
            } 
            else if (message === 'MOBILE_EXISTS') {
                this.submitErrorMessage = 'This mobile number already registered, please try with new one.';
            } 
            else if (message === 'EMAIL_MOBILE_EXISTS') {
                this.submitErrorMessage = 'Email and mobile already registered. Click Incomplete Registration to resume or use new details.';
            } 
            else {
                this.submitErrorMessage = 'Submission failed. Please try again.';
            }

            this.isSubmitting = false;
    }
  };
    get isSubmitDisabled() {
        return this.isSubmitting;
    }

    get disableDeclarationCheck() {
        return !this.categoryOptions || !this.program;
    }

    get submitLabel() {
        return this.isSubmitting ? 'Submitting...' : 'Submit';
    }

    get sendOtpDisabled() {
        return this.disableOtp;
    }

    get resendOtpDisabled() {
        return this.disableOtp || this.isVerified;
    }

    get verifyDisabled() {
        return this.disableOtp || this.isVerified;
    }
    get sendEmailOtpDisabled() {
        return this.isEmailVerified || this.disableOtp;
    }


    handleSignIn() {
        this.isSignInMode = true;
        this.showPaidView = true;

        // Reset email verification state for the sign-in flow
        this.verifyEmail = false;
        this.email = '';
        this.isEmailVerified = false;
        this.showEmailOTP = false;
        this.emailOtp = '';
        this.emailOtpError = false;
        this.leadId = '';
    }

    handleApplicantPortal = async () => {
        const paymentUrl = await redirectToApplicantPortal();
        console.log('paymentUrl :' + paymentUrl);
        window.location.href = paymentUrl;
        // window.open(paymentUrl, '_blank');
    }

    validateForm() {
        const errors = {};

        // First Name
        if (!this.firstName || !this.firstName.trim()) {
            errors.firstName = 'First Name is required.';
        }

        // Last Name
        if (!this.lastName || !this.lastName.trim()) {
            errors.lastName = 'Last Name is required.';
        }

        // Email format
        if (!this.email || this.emailInvalid) {
            errors.email = 'Please enter a valid email address.';
        }

        // Email verified
        if (this.leadId && !this.isEmailVerified) {
            errors.emailVerified = 'Email must be verified.';
        }

        // ── FIX 1: Phone code dropdown must be selected ──────────────────
        if (!this.phoneCode) {
            errors.phoneCode = 'Please select a country code.';
        }

        // ── FIX 2: Mobile number must not be empty ───────────────────────
        if (!this.mobileNumber || !this.mobileNumber.trim()) {
            errors.mobileNumber = 'Mobile number is required.';
        } else if (this.mobileErrorMessage) {
            // Propagate any async validation error already set by validateMobileNumber()
            errors.mobileNumber = this.mobileErrorMessage;
        }

        // ── FIX 3: OTP verification — covers both Indian and foreign flows ─
        // For Indian numbers: OTP must be verified.
        // For foreign numbers: phone code must still be selected (checked above).
        // The old guard was `if (this.leadId && !this.otherCountry && !this.isVerified)`
        // which silently passed when mobileNumber was blank (no leadId yet).
        if (this.leadId && !this.otherCountry && !this.isVerified){
            errors.mobileVerified = 'Mobile number must be verified via OTP.';
        }

        // Category
        if (!this.category) {
            errors.category = 'Category is required.';
        }

        // State (only when Non-Karnataka category)
        if (this.showStatePicklist && !this.state) {
            errors.state = 'State is required.';
        }

        // Country (only when applicable category)
        if (this.showCountryPicklist && !this.country) {
            errors.country = 'Country is required.';
        }

        // School
        if (!this.school) {
            errors.school = 'School is required.';
        }

        // Program
        if (!this.program) {
            errors.program = 'Program is required.';
        }

        // Declaration checkbox
        if (!this.declarationChecked) {
            errors.declaration = 'You must authorise REVA to contact you before submitting.';
        }

        this.validationErrors = errors;
        return Object.keys(errors).length === 0;
    }

    /*==============================================
  INLINE DROPUP HANDLERS
  Paste this entire block INSIDE the class body
  of studentAdmissionSinglePageNew.js —
  just before the final closing  }
==============================================*/

    // ── Open/close flags ──────────────────────────────────
    @track phoneCodeOpen = false;
    @track categoryOpen  = false;
    @track stateOpen     = false;
    @track countryOpen   = false;
    @track schoolOpen    = false;
    @track programOpen   = false;

    // ── Floating list position (position:fixed) ───────────
    // @track dropPos = { bottom: 0, left: 0, minWidth: 200, maxWidth: 400 };
    @track dropPos = {};

    // _setDropPos(event) {
    //     const rect     = event.currentTarget.getBoundingClientRect();
    //     const card     = event.currentTarget.closest('.admission-card');
    //     const cardRect = card ? card.getBoundingClientRect() : null;
    //     const left     = rect.left;
    //     const minWidth = rect.width;
    //     const maxWidth = cardRect ? (cardRect.right - left) : minWidth;
    //     this.dropPos = {
    //         bottom   : window.innerHeight - rect.top + 2,
    //         left     : left,
    //         minWidth : minWidth,
    //         maxWidth : maxWidth
    //     };
    // }

    // _setDropPos(event) {
    //     const rect = event.currentTarget.getBoundingClientRect();

    //     // Minimum width for country names
    //     const width = Math.max(rect.width, 280);

    //     let left = rect.left;

    //     // Prevent dropdown from going outside viewport
    //     if (left + width > window.innerWidth - 10) {
    //         left = window.innerWidth - width - 10;
    //     }

    //     this.dropPos = {
    //         bottom: window.innerHeight - rect.top + 2,
    //         left: left,
    //         width: width
    //     };
    // }

    _setDropPos(event) {
        const rect = event.currentTarget.getBoundingClientRect();

        this.dropPos = {
            width: Math.max(rect.width, 280)
        };
    }

    // get dropStyle() {
    //     return `bottom:${this.dropPos.bottom}px;left:${this.dropPos.left}px;width:${this.dropPos.minWidth}px;`;
    // }

    // get dropStyle() {
    //     return `
    //         bottom:${this.dropPos.bottom}px;
    //         left:${this.dropPos.left}px;
    //         width:${this.dropPos.width}px;
    //     `;
    // }

    get dropStyle() {
        return `width:${this.dropPos.width || 280}px;`;
    }

    // ── Close all ─────────────────────────────────────────
    _closeAll() {
        this.phoneCodeOpen = false;
        this.categoryOpen  = false;
        this.stateOpen     = false;
        this.countryOpen   = false;
        this.schoolOpen    = false;
        this.programOpen   = false;
    }

    // ── Label display getters ─────────────────────────────
    get phoneCodeLabelDisplay() {
        const f = (this.phoneCodeOptions||[]).find(o => o.value === this.phoneCode);
        return f ? f.label : 'Select Code';
    }
    get categoryLabelDisplay() {
        const f = (this.categoryOptions||[]).find(o => o.value === this.category);
        return f ? f.label : 'Select Category';
    }
    get stateLabelDisplay() {
        const f = (this.stateOptions||[]).find(o => o.value === this.state);
        return f ? f.label : 'Select State';
    }
    get countryLabelDisplay() {
        const f = (this.countryOptions||[]).find(o => o.value === this.country);
        return f ? f.label : 'Select Country';
    }
    get schoolLabelDisplay() {
        const f = (this.schools||[]).find(o => o.value === this.selectedSchool);
        return f ? f.label : 'Select School';
    }
    get programLabelDisplay() {
        const f = (this.programs||[]).find(o => o.value === this.selectedProgram);
        return f ? f.label : 'Select Program';
    }

    // ── Trigger box CSS (active = blue border) ────────────
    get phoneCodeTriggerClass() { return 'dropup-trigger' + (this.phoneCodeOpen ? ' active' : ''); }
    get categoryTriggerClass()  { return 'dropup-trigger' + (this.categoryOpen  ? ' active' : ''); }
    get stateTriggerClass()     { return 'dropup-trigger' + (this.stateOpen     ? ' active' : ''); }
    get countryTriggerClass()   { return 'dropup-trigger' + (this.countryOpen   ? ' active' : ''); }
    get schoolTriggerClass()    { return 'dropup-trigger' + (this.schoolOpen    ? ' active' : ''); }
    get programTriggerClass()   { return 'dropup-trigger' + (this.programOpen   ? ' active' : ''); }

    // ── Text span CSS (grey placeholder vs dark selected) ─
    get phoneCodeTextClass() { return 'dropup-trigger-text'; } // always dark — default is (+91) India
    get categoryTextClass()  { return 'dropup-trigger-text' + (!this.category       ? ' placeholder' : ''); }
    get stateTextClass()     { return 'dropup-trigger-text' + (!this.state          ? ' placeholder' : ''); }
    get countryTextClass()   { return 'dropup-trigger-text' + (!this.country        ? ' placeholder' : ''); }
    get schoolTextClass()    { return 'dropup-trigger-text' + (!this.selectedSchool ? ' placeholder' : ''); }
    get programTextClass()   { return 'dropup-trigger-text' + (!this.selectedProgram? ' placeholder' : ''); }

    // ── Wrapper CSS class ─────────────────────────────────
    get phoneCodeDropClass() { return 'dropup-wrapper'; }
    get categoryDropClass()  { return 'dropup-wrapper'; }
    get stateDropClass()     { return 'dropup-wrapper'; }
    get countryDropClass()   { return 'dropup-wrapper'; }
    get schoolDropClass()    { return 'dropup-wrapper'; }
    get programDropClass()   { return 'dropup-wrapper'; }

    // ── Toggle handlers ───────────────────────────────────
    togglePhoneCodeDrop(event) {
        const wasOpen = this.phoneCodeOpen; this._closeAll();
        if (!wasOpen) { this._setDropPos(event); this.phoneCodeOpen = true; }
    }
    toggleCategoryDrop(event) {
        const wasOpen = this.categoryOpen; this._closeAll();
        if (!wasOpen) { this._setDropPos(event); this.categoryOpen = true; }
    }
    toggleStateDrop(event) {
        const wasOpen = this.stateOpen; this._closeAll();
        if (!wasOpen) { this._setDropPos(event); this.stateOpen = true; }
    }
    toggleCountryDrop(event) {
        const wasOpen = this.countryOpen; this._closeAll();
        if (!wasOpen) { this._setDropPos(event); this.countryOpen = true; }
    }
    toggleSchoolDrop(event) {
        const wasOpen = this.schoolOpen; this._closeAll();
        if (!wasOpen) { this._setDropPos(event); this.schoolOpen = true; }
    }
    toggleProgramDrop(event) {
        const wasOpen = this.programOpen; this._closeAll();
        if (!wasOpen) { this._setDropPos(event); this.programOpen = true; }
    }

    // ── Select handlers (call existing business logic) ────
    selectPhoneCode(event) {
        event.stopPropagation();
        this.phoneCode = event.currentTarget.dataset.value;
        this.phoneCodeOpen = false;
        this.handlePhoneCodeChange({ detail: { value: this.phoneCode } });
    }
    selectCategory(event) {
        event.stopPropagation();
        this.category = event.currentTarget.dataset.value;
        this.categoryOpen = false;
        this.handleCategoryChange({ detail: { value: this.category } });
    }
    selectState(event) {
        event.stopPropagation();
        this.state = event.currentTarget.dataset.value;
        this.stateOpen = false;
    }
    selectCountry(event) {
        event.stopPropagation();
        this.country = event.currentTarget.dataset.value;
        this.countryOpen = false;
    }
    selectSchool(event) {
        event.stopPropagation();
        this.selectedSchool = event.currentTarget.dataset.value;
        this.schoolOpen = false;
        this.onSchoolChange({ detail: { value: this.selectedSchool } });
    }
    selectProgram(event) {
        event.stopPropagation();
        this.selectedProgram = event.currentTarget.dataset.value;
        this.program = this.selectedProgram;
        this.programOpen = false;
    }

}