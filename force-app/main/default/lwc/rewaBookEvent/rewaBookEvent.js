import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAppointmentCaseEvent from '@salesforce/apex/rewaCaseController.createAppointmentCaseEvent';

export default class rewaBookEvent extends LightningElement {
    @track severity;
    @track modeOfCounselling;
    @track preferredLanguage;
    description = '';
    @track howAmIFeeling;
    @track presentingProblem;
    @track angry;
    @track stressed;
    @track sad;
    @track lonely;
    @track hurt;
    @track confused;
    @track frightened;
    @track anxious;
    
    @track SelectedEventId;
    @track eventDetails;

    @track eventDetailsFormatted = {
        StartDateTimeFormatted: '',
        EndDateTimeFormatted: ''
    };
    @api selectDate='';
    @api selectTimeSlot='';
    @api selectYear;
    @api selectMonth;
    @api selectDay;
    @api selectStarthours;
    @api selectStartminutes;
    @api selectEndhours;
    @api selectEndminutes;
    @track isSubmitting = false;
    //checking for professor referral   
    @api selectContact;
    @api selectedAppointmentType;
    showOtherPresentingProblem;
    otherPresentingProblemValue = '';




    //checking for professor referral 
    // URL for the PDF
    pdfUrl = 'https://reva-university--codev1.sandbox.my.salesforce.com/sfc/p/1e0000000p6O/a/1e0000000l12/GDpdN1YvRzhTt8t9yc0Xgigt8xgAJakHKXj87vk4uHw';
    isChecked = false;

    formattedLabelText = 'I have reviewed this <a href=' + this.pdfUrl + ' target="_blank">Professional Counselling Informed Consent Agreement</a>. I accept this agreement and consent to counselling.';

    severityOptions = [
        { label: 'Critical', value: 'Critical' },
        { label: 'Urgent', value: 'Urgent' },
        { label: 'As Soon As Possible', value: 'As Soon As Possible' }
    ];

    modeOptions = [
        { label: 'Online', value: 'Online' },
        { label: 'Phone Call', value: 'Phone Call' },
        { label: 'Face to Face', value: 'Face to Face' }
    ];

    languageOptions = [
        { label: 'Hindi', value: 'Hindi' },
        { label: 'English', value: 'English' },
        { label: 'Tamil', value: 'Tamil' },
        { label: 'Telugu', value: 'Telugu' },
        { label: 'Kannada', value: 'Kannada' }
    ];
    //checking for professor referral
    // In the professor component
    // handleStudentSelection(event) {
    //     const selectedContactId = event.detail.contactId; // Assuming you have a way to get the selected contact ID
    //     this.template.querySelector('c-rewa-book-event').selectedContactId = selectedContactId;
    // }

    handleSeverity(event){
        this.severity = event.target.value;
        console.log('severity-->> '+this.severity);
        console.log('Retrieved Date:', this.selectDate);
        console.log('Retrieved timeslot:', this.selectTimeSlot);
        console.log('selectContact test'+this.selectContact);
        console.log('selectedAppointmentType'+this.selectedAppointmentType);
    }

    handlemode(event){
        this.modeOfCounselling = event.target.value;
        console.log('modeOfCounselling--'+this.modeOfCounselling);
    }

    handlefeeling(event){
        this.howAmIFeeling = event.target.value;
        console.log('howAmIFeeling--'+this.howAmIFeeling);
    }

    handleProblem(event){
        this.presentingProblem = event.target.value;
        this.showOtherPresentingProblem = this.presentingProblem === 'Others';
    }
    handleOtherPresentingProblemChange(event) {
        
        const input = this.refs.otherPresentingProblem;
        this.otherPresentingProblemValue = input.value;
        
       
    }
    handleLanguage(event){
        this.preferredLanguage = event.target.value;
    }

    handleKeyUp(event){
        this.description = event.target.value;
        console.log('desc-->'+this.description);
    }

    handleCheckboxChange(event) {
        this.isChecked = event.target.checked;
    }

    @track Angry = 0;
    handleSliderChangeForAngry(event) {
        this.Angry = event.target.value;
        console.log('this.Angry--'+this.Angry);
    }
    
    @track Stressed = 0;
    handleSliderChangeStressed(event) {
        this.Stressed = event.target.value;
    }

    @track Sad = 0;
    handleSliderChangeSad(event) {
        this.Sad = event.target.value;
    }

    @track Lonely = 0;
    handleSliderChangeLonely(event) {
        this.Lonely = event.target.value;
    }

    @track Hurt = 0;
    handleSliderChangeHurt(event) {
        this.Hurt = event.target.value;
    }

    @track Confused = 0;
    handleSliderChangeConfused(event) {
        this.Confused = event.target.value;
    }

    @track Frightened = 0;
    handleSliderChangeFrightened(event) {
        this.Frightened = event.target.value;
    }

    @track Anxious = 0;
    handleSliderChangeAnxious(event) {
        this.Anxious = event.target.value;
    }

    handleSubmit(event) {
        event.preventDefault();
        
       
        const input = this.refs.otherPresentingProblem;
        console.log('this.showOtherPresentingProblem', this.showOtherPresentingProblem);
        console.log('this.presentingProblem', this.presentingProblem);
        console.log('input', input);
        console.log(this.showOtherPresentingProblem && !input.value && this.presentingProblem === 'Others' );
        if (this.showOtherPresentingProblem && !input.value && this.presentingProblem === 'Others' ) {
            input.setCustomValidity('Please provide your other presenting problem');
            input.reportValidity();
            console.log('Inside if');
            return;
        } else if(this.showOtherPresentingProblem && input.value && this.presentingProblem === 'Others') {
            console.log('Inside else');
            input.setCustomValidity('');
            input.reportValidity();
        }       

        console.log('Outside.....');
        this.isSubmitting = true; // Show loading spinner

        createAppointmentCaseEvent({
            severity: this.severity,
            modeOfCounselling: this.modeOfCounselling,
            preferredLanguage: this.preferredLanguage,
            howAmIFeeling: this.howAmIFeeling,
            presentingProblem: this.presentingProblem,
            description: this.description,
            selectedDate: this.selectDate,
            selectYear: this.selectYear,
            selectMonth: this.selectMonth,
            selectDay: this.selectDay,
            selectStarthours: this.selectStarthours,
            selectStartminutes: this.selectStartminutes,
            selectEndhours: this.selectEndhours,
            selectEndminutes: this.selectEndminutes,
            selectContact: this.selectContact,
            selectedAppointmentType: this.selectedAppointmentType,
            angry: this.Angry,
            stressed: this.Stressed,
            sad: this.Sad,
            lonely: this.Lonely,
            hurt: this.Hurt,
            confused: this.Confused,
            frightened: this.Frightened,
            anxious: this.Anxious,
            OtherPresentingProblem : this.otherPresentingProblemValue,
            //checking for professor referral
           // selectedContactId: this.selectedContactId 
        })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Your appointment is submitted.',
                    variant: 'success'
                })
            );
            location.reload();
        })
        .catch(error => {
            console.error(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An error occurred while submitting the appointment.',
                    variant: 'error' 
                })
            );
            //location.reload();
        })
        .finally(() => {
            this.isSubmitting = false; // Hide loading spinner
        });
        
    }

    get showReferralDiv() {
        return this.selectedAppointmentType != 'Referral';
    }

    get isButtonDisabled() {
        if (this.selectedAppointmentType === 'Referral') {
            return this.areAllFieldsFilled || this.isSubmitting;
        } else {
            return this.areAllFieldsFilled ||!this.isChecked || this.isSubmitting;
        }
    }

    get areAllFieldsFilled() {
        return !(this.severity && this.modeOfCounselling);
    }
}