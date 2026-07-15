/**
 * @description: Single-page LWC for student admission registration. Integrates all steps: email, details, OTP, program selection, declaration, and submission.
 * @author: GitHub Copilot
 * @group: Admissions
 * @version: 1.0
 * @Last Modified on: 2025-10-10
 * @Last Modified by: GitHub Copilot
 */
import { LightningElement, track,api,wire } from 'lwc';
import checkExistingEmail from '@salesforce/apex/StudentAdmissionSinglePageController.checkExistingEmail';
import sendOtp from '@salesforce/apex/StudentAdmissionSinglePageController.sendOtp';
import sendEmailOtp from '@salesforce/apex/StudentAdmissionSinglePageController.sendEmailOtp';
import verifyOtp from '@salesforce/apex/StudentAdmissionSinglePageController.verifyOtp';
import verifyEmailOtp from '@salesforce/apex/StudentAdmissionSinglePageController.verifyEmailOtp';
import getSchoolProgramCategoryData from '@salesforce/apex/StudentAdmissionSinglePageController.getSchoolProgramCategoryData';
import submitApplication from '@salesforce/apex/StudentAdmissionSinglePageController.submitApplication';
import redirectToPaymentPage from '@salesforce/apex/StudentAdmissionSinglePageController.redirectToPaymentPage';
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

const baseImageUrl = `${ADMISSIONPORTALASSETS}/AdmissionPortalAssets/Icons`;

export default class StudentAdmissionSinglePage extends LightningElement {
    registrationProcessImageUrl = `${baseImageUrl}/registration-process.png`;
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
    // Paid admission view
    @track showPaidView = false; // when true, show the "already registered/paid" page
    @track IsshowPaidView = false;
    @track paidName = '';
    @track paidSchool = '';
    @track paidProgram = '';
    @track paidApplicationNumber = '';
    @track paidMessage = '';
    @track addedMessage= '';
    @track isPUCView = false;

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

  @api selectionMode = 'ApplicationFee'
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


    @wire(getSchoolPrograms, {selectionMode: '$selectionMode'}) 
    wiredSchoolPrograms({data, error}) {
      if (data) {
        //console.log(data);
        data.forEach(item => {
          if (!this.schoolPrograms.has(item.School_Name__c)) {
            this.schoolPrograms.set(item.School_Name__c, new Set());
          }
          this.schoolPrograms.get(item.School_Name__c).add(item.Program_Name_Display__c);
          this.programPB.set(item.Program_Name_Display__c, item.Program_Batch__c);
        });
        this.setSchoolOptions();
      }
      if (error) {
        console.log(error);
      }
    }

    setSchoolOptions() {
        const BASE_CSE = 'School of Computer Science and Engineering';

        this.schools = [
            { value: '', label: 'Select a School' }
        ];

        for (const [school, programs] of this.schoolPrograms) {

            if (
                school.startsWith(BASE_CSE) &&
                school !== BASE_CSE
            ) {
                continue; 
            }

            this.schools.push({
                value: school,
                label: school
            });
        }
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
        const newOtp = await resendOtp({ leadId: this.leadId, email: this.email});
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
        console.log('urlParams'+urlParams);
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
     this.utmSource   = urlParams.get('utm_source')   || 'direct';
     this.utmMedium   = urlParams.get('utm_medium')   || 'direct';
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
         if(this.phoneCode == '+91' || this.phoneCode == 'India (+91)'){
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
    const digits = this.mobileNumber.replace(/\D/g, '');
    const code = (this.phoneCode || '').toString();

    // Check if country code is India (+91)
    const isIndia = code === '+91' || code.includes('91');

    if (isIndia) {
      this.showCategory = false;
      this.otherCountry= false;
        if (digits.length !== 10) {
            this.mobileErrorMessage = 'Enter Valid Mobile Number';
              this.mobileOtp = true; 
            return false;
        }if(digits.length ===10 && this.phoneCode != ''){
            this.mobileOtp = false;
        }
    } else {
        this.otherCountry= true;
         this.disableCat = false;
         this.showCategory = true;
         // Fetch school/program/category data
          const data = await getSchoolProgramCategoryData();
          this.categoryOptions = data.categories || [];
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

    
     async onSchoolChange(event) {

    this.selectedProgram = '';
    this.school = event.target.value;

    console.log('Selected School:', this.school);

    if (!this.disableSchool) {
        this.selectedProgram = '';
        this.program = '';
    }

    const CSE_SCHOOL = 'School of Computer Science and Engineering';

    // ⭐ Check condition
    if (this.school === CSE_SCHOOL) {

    try {

        const data = await getProgramsBySchool({
            schoolName: this.school
        });

        this.programs = [
            { value: '', label: 'Select a Program' }
        ];

        const uniquePrograms = new Set();

        data.forEach(rec => {

            uniquePrograms.add(rec.Program_Name_Display__c);

            this.programPB.set(
                rec.Program_Name_Display__c,
                rec.Program_Batch__c
            );

        });

        uniquePrograms.forEach(program => {
            this.programs.push({
                label: program,
                value: program
            });
        });

        this.disableProgram = false;

    } catch (error) {
        console.error('Error fetching programs:', error);
    }
}

    else {

        console.log('Non-CSE school → Using existing logic');

        this.setProgramOptions();

        if (!this.program) {
            this.disableProgram = !this.school;
        }

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
            this.stateOptions = data;
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
        if(this.declarationChecked == true){
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
        get isVerifyEmailDisabled() {
           // return !this.email ||!this.lastName ||!this.firstName || this.emailInvalid || this.verifyEmail;
           return this.oneClick;
        }


    sendOtp = async () => {
    this.mobileError = ''; // reset previous error
    try {
        const result = await sendOtp({
            leadId: this.leadId,
            phoneCode: this.phoneCode,
            mobileNumber: this.mobileNumber,
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
         
        if ((!this.firstName || !this.lastName || !this.email) && this.isSignInMode == false ) {
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
            const newOtp = await resendOtp({ leadId: this.leadId});
            this.expectedOtp = newOtp;
            // Enable OTP field
            this.disableOtp = false;
            this.verifyEmail = true;
            this.showEmailOTP = true;
        } else {
             this.oneClick = true;
            // New lead OTP flow
            const result = await sendEmailOtp({ email: this.email, firstName: this.firstName, lastName: this.lastName,
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
            // Fetch school/program/category data
            const data = await getSchoolProgramCategoryData();
            this.categoryOptions = data.categories || [];
           // this.disableDeclaration = false;
        } else {
            this.otpError = true;
        }
    }

     verifyEmailOtp = async () => {
      
           try {
        const result = await verifyEmailOtp({ leadId: this.leadId, otp: this.emailOtp });
        console.log('result'+JSON.stringify(result));
        if (result.isVerified) {
            this.isSignInMode = false;
             this.contactId = result.recordId;
            console.log('Verified Record Type:', result.recordType); // 'Lead' or 'Contact'
            this.emailOtpError = false;
            this.isEmailVerified = true;
            this.disableOtp = true;    
            this.resendEmailOtpMessage = '';
            this.showcountryCode = true; 
            this.firstName =result.firstName;          
            this.lastName=result.lastName;

            if(result.recordType === 'Lead') {
                this.disable = false;
                this.showPaidView = false;
                console.log('mobileNumber:'+ result.mobileNumber);
                const data = await getSchoolProgramCategoryData();
                this.categoryOptions = data.categories || [];
               
                 if (result.mobileNumber && result.phoneCode) {
                    this.mobileNumber = result.mobileNumber;
                    this.phoneCode = result.phoneCode;
                    this.disable = true;
                    // ✅ MARK MOBILE AS VERIFIED
                        this.isVerified = true;
                        this.verifyPhone = true;
                        this.showMobileOtp = false;
                        this.otherCountry = true;
                        this.disableOtp = true;
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
            } else if(result.recordType === 'Contact') {
                this.disable = true;
                this.emailExists = true;
                 this.showPaidView = false;
          
            } else if(result.recordType === 'Contact_Paid'){
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

    submitApplication = async () => {
        if (this.isSubmitting) return; // prevent double submit
        this.isSubmitting = true;
        this.submitErrorMessage = '';

         const paymentWindow = window.open('', '_blank');

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
    
            const appId = await submitApplication({ studentData });
            const paymentUrl = await redirectToPaymentPage({ applicationId: appId });
            //window.location.href = paymentUrl;
            // window.open(paymentUrl, '_blank', 'noopener,noreferrer');
            paymentWindow.location.href = paymentUrl;
        
        } catch (err) {
            // Re-enable submit on error and show message
            this.submitErrorMessage = 'Submission failed. Please try again.';
            this.isSubmitting = false;
            // Optionally log error
            // console.error(err);
        }
    }

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
  
    get isSubmitDisabled() {
        return !this.declarationChecked || this.disableDeclaration || this.isSubmitting;
    }

    get disableDeclarationCheck(){
         return  !this.categoryOptions || !this.program;
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
    }

    handleApplicantPortal = async () => {
         const paymentUrl = await redirectToApplicantPortal();
          // window.location.href  = paymentUrl;
           window.open(paymentUrl, '_blank');
    }
}