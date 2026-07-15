import { LightningElement, track,wire } from 'lwc';
import getStudentBySRN from '@salesforce/apex/RevahostelFelxibleRequestController.getStudentBySRN';
import revaHostelRoomAllotment from '@salesforce/apex/RevahostelFelxibleRequestController.RevaHostelRoomAllotment';
import createStudentFeeRecord from '@salesforce/apex/RevahostelFelxibleRequestController.createStudentFeeRecord';
import calculateHostelFee from '@salesforce/apex/RevahostelFelxibleRequestController.calculateHostelFee'; 
import getAllRoomPrices from '@salesforce/apex/RevahostelFelxibleRequestController.getAllRoomPrices';
import getAcademicYears from '@salesforce/apex/RevahostelFelxibleRequestController.getAcademicYears';
import RevaHostelCautionFeeAmount from '@salesforce/label/c.Reva_Hostel_Caution_Fee_Amount';
import RevaHostelPremiumCautionFeeAmount from '@salesforce/label/c.Reva_Hostel_Premium_Caution_Fee_Amount';
import BOOKING_AMOUNT_PREMIUM from '@salesforce/label/c.WithPremium';
import BOOKING_AMOUNT_NON_PREMIUM from '@salesforce/label/c.WithoutPremium';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSharingOptions from '@salesforce/apex/RevahostelFelxibleRequestController.getSharingOptions';
export default class FlexibleHostelRegistrationForm extends LightningElement {

    // SRN
    @track srnInput = '';
    @track showForm = false;
    @track hostelRequestId;
    // Student Data
    @track currentUserContact = {};
    @track studentName = '';
    @track customSettingsData = [];
    @track programBatch = '';
     @track gender = '';
    // Form fields
    @track sharingType = '';
    @track planType = '';
    @track startDate;
    @track endDate;
    @track isFetchDisabled = false;
    @track totalAmount = 0;
    @track isPremium = false;
    @track totalHostelFee ;
    @track selectPaymentType;
    @track totalHostelFeeRaw = 0;
    @track manualAmount = 0;
    @track perDayAmount = 0;
    @track concession = 0;
    @track academicYear = '';
    @track academicYearOptions = [];
    @track showBookingAmount=false;
    @track cautionFee ;
    @track bookingAmount;
    @track isSubmitting = false;
    @track comments;
    @wire(getAcademicYears)
    wiredYears({ data, error }) {
    if (data) {
        this.academicYearOptions = data.map(item => {
            return { label: item, value: item };
        });
    } else if (error) {
        console.error(error);
    }
    }

  /*  get sharingOptions() {
        let options = [
            { label: '4 Sharing Extra Space', value: '4ExtraSpace' }, 
            { label: '4 Sharing', value: '4' }, 
            { label: '3 Sharing', value: '3' },
            { label: '2 Sharing AC', value: '2' },
            { label: '2 Sharing AC Premium', value: '2AC' },
            { label: 'Single Occupant', value: '1' }

        ];

        if (!this.isPremium) {
                    // Remove premium room options for non-premium users
            options = options.filter(
                option => option.value !== '2' && option.value !== '2AC'
            );
        }
         if (this.isPremium ) {
            // Only include option 2 when premium
            options = options.filter(
                    option => option.value === '2' || option.value === '2AC'
                );            
        }

          return options;
    }*/

@track metadataOptions = []; 

@wire(getSharingOptions)
wiredSharingOptions({ data, error }) {
    if (data) {
        this.metadataOptions = data;
        console.log('Metadata Options', JSON.stringify(data));
    } else if (error) {
        console.error(error);
    }
}

get sharingOptions() {

    let options = [];

    // Flexible / Flexible Manual
    if (this.planType === 'Flexible Manual' || this.planType === 'Flexible') {

        options = [
            { label: '4 Sharing Extra Space', value: '4ExtraSpace' },
            { label: '4 Sharing', value: '4' },
            { label: '3 Sharing', value: '3' },
            { label: '2 Sharing AC', value: '2' },
            { label: '2 Sharing AC Premium', value: '2AC' },
            { label: 'Single Occupant', value: '1' }
        ];

    } else if (this.planType === 'One Semester') {
       
       console.log('optionss:'+this.metadataOptions);
       console.log('optionss:'+ [...this.metadataOptions]);
        // Metadata options
        options = [...this.metadataOptions];
    }

    // Premium filtering
    if (!this.isPremium) {
        options = options.filter(
            option => option.value !== '2' && option.value !== '2AC'
        );
    } else {
        options = options.filter(
            option => option.value === '2' || option.value === '2AC'
        );
    }

    return options;
}
       get paymentTypeOptions(){
        let options = [
            
            { label: 'Full Payment', value: 'Full Payment' },
            { label: 'Booking Amount', value: 'Partial Payment' }
        ];
        return options;
    }
    

    planOptions = [
        { label: 'One Semester', value: 'One Semester' },
        // { label: 'Flexible', value: 'Flexible' },
        { label: 'Flexible Manual', value: 'Flexible Manual' }

    ];

 planOptions = [
        { label: 'One Semester', value: 'One Semester' },
        // { label: 'Flexible', value: 'Flexible' },
        { label: 'Flexible Manual', value: 'Flexible Manual' }

    ];

    // 🔹 Handle SRN input
    handleSRNChange(event) {
        this.srnInput = event.target.value;
        console.log('this.srnInput:'+this.srnInput);
        }

    handlePremiumCheckboxChange(event) {
            this.isPremium = event.target.checked;
            this.fetchHostelFee();
             if (this.isPremium) {this.cautionFee = RevaHostelPremiumCautionFeeAmount 
            ? parseFloat(RevaHostelPremiumCautionFeeAmount) 
            : 0;
            } else {this.cautionFee = RevaHostelCautionFeeAmount 
            ? parseFloat(RevaHostelCautionFeeAmount) 
            : 0;
            }
    }
     handlePaymentTypeChange(event) {
    this.selectPaymentType = event.detail.value;

    if (this.selectPaymentType === 'Partial Payment') {
        this.showBookingAmount = true;

        // ✅ Set booking amount only for partial payment
        if (this.isPremium) {
            this.bookingAmount = BOOKING_AMOUNT_PREMIUM;
        } else {
            this.bookingAmount = BOOKING_AMOUNT_NON_PREMIUM;
        }

    } else {
        // ✅ Full Payment
        this.showBookingAmount = false;
        this.bookingAmount = 0; // reset
    }
}
    handleChangeAcademicYear(event) {
        this.academicYear = event.detail.value;
           this.fetchHostelFee();
    }

    handleConcessionAmount(event) {
    this.concession = parseFloat(event.target.value) || 0;
     if (this.planType === 'Flexible') {
        this.calculateFlexibleAmount();
    } else if (this.planType === 'Flexible Manual') {
        this.calculateFlexibleManual();
    }
}
    

    handleFetchStudent(){

    if (!this.srnInput) {
        alert('Enter Application Number');
        return;
    }

    getStudentBySRN({ srn: this.srnInput })
        .then(result => {
            this.currentUserContact = result.Id;
            this.studentName = result.Name;
            this.programBatch = result.ProgramBatch;
            this.gender = result.Gender;

            this.showForm = true;

            // ✅ Disable button after fetch
            this.isFetchDisabled = true;
        })
        .catch(error => {
            console.error(error);
            alert('Student not found');
            this.showForm = false;
            this.isFetchDisabled = false;
        });
    }

     handleChangeShareType(event) {
        this.sharingType = event.target.value;
        this.isSubmitting = false;
        this.fetchHostelFee();

        if (this.isPremium) {this.cautionFee = RevaHostelPremiumCautionFeeAmount 
                ? parseFloat(RevaHostelPremiumCautionFeeAmount) 
                : 0;
        } else {this.cautionFee = RevaHostelCautionFeeAmount 
                ? parseFloat(RevaHostelCautionFeeAmount) 
                : 0;
        }
    }

        // handleChangePlanType(event) {
        //     this.planType = event.target.value;
        //       this.fetchHostelFee();
        // }

        handleChangePlanType(event) {
            this.planType = event.target.value;
 
            this.sharingType = '';
            if (this.planType === 'One Semester') {
                this.fetchHostelFee(); // system amount
            } else {
                // Flexible → reset
                this.totalHostelFee = 0;
                this.totalHostelFeeRaw = 0;
                this.selectPaymentType = 'Full Payment';
            }
        }

        handleManualAmountChange(event) {

            this.perDayAmount = parseFloat(event.target.value) || 0;
            if(this.planType === 'Flexible'){
                console.log('entered into Flexible');
            this.calculateFlexibleAmount();
            }else if(this.planType === 'Flexible Manual'){
                console.log('entered into Flexible Manual');
                this.calculateFlexibleManual();
            }
        }
        calculateFlexibleManual(){
            let totalManual = this.perDayAmount - this.concession;

            this.totalHostelFeeRaw = totalManual;  // backend
            this.totalHostelFee = totalManual; 
        }

        calculateFlexibleAmount() {
            if(this.planType === 'Flexible Manual'){
                return;
            }
            if (!this.startDate || !this.endDate || !this.perDayAmount ) {
                this.totalHostelFee = 0;
                this.totalHostelFeeRaw = 0;
                return;
            }

            let start = new Date(this.startDate);
            let end = new Date(this.endDate);

            let timeDiff = end - start;
            let days = Math.ceil(timeDiff / (1000 * 60 * 60 * 24))+1;

            if (days <= 0) {
                this.totalHostelFee = 0;
                this.totalHostelFeeRaw = 0;
                return;
            }

            let total = days * this.perDayAmount - this.concession;

            this.totalHostelFeeRaw = total;  // backend
            this.totalHostelFee = total;     // UI

            console.log('Days:', days);
            console.log('Per Day:', this.perDayAmount);
            console.log('Total:', total);
        }

        handleChangeStartDate(event) {
            this.startDate = event.target.value;
               if (this.planType === 'Flexible') {
                    this.calculateFlexibleAmount();
                }

        }

        handleChangeEndDate(event) {
            this.endDate = event.target.value;
          if (this.planType === 'Flexible') {
                this.calculateFlexibleAmount();
            }
        }
handleComments(event){
     this.comments = event.target.value;

}
        get isOneSemester() {
            return this.planType === 'One Semester';
        }
        get isFlexible() {
            return this.planType === 'Flexible';
        }
        get isFlexibleManual(){
            return this.planType === 'Flexible Manual';
        }

    // 🔹 Submit
    handleSubmitEvent() {

            this.isSubmitting = true;
            
        if (!this.sharingType || !this.planType || !this.comments ) {
            alert('Fill all required fields');
             this.isSubmitting = false;
            return;
        }

        console.log('this.currentUserContact.Id:'+this.currentUserContact);
        console.log('this. this.sharingType.Id:'+ this.sharingType);
       
        let finalAmount = 0;

        // if (this.planType === 'Flexible') {
        //     if (!this.manualAmount || this.manualAmount <= 0) {
        //         alert('Please enter valid amount');
        //         return;
        //     }
        //     finalAmount = this.manualAmount;
        // } else {
        //     finalAmount = this.totalHostelFeeRaw;
        // }
        
        if (this.planType === 'Flexible') {
                if (!this.totalHostelFeeRaw || this.totalHostelFeeRaw <= 0) {
                    alert('Please enter valid dates and per day amount');
                     this.isSubmitting = false;
                    return;
                }

                finalAmount = this.totalHostelFeeRaw; // ✅ CORRECT TOTAL
            } else {
                finalAmount = this.totalHostelFeeRaw;
             }

        // let occupancy = this.sharingType;

        // console.log('Original Occupancy:', occupancy);

        // // Convert 2AC -> 2
        // if (occupancy === '2AC') {
        //     occupancy = '2';
        // }

        //  console.log('Occupancy:',occupancy);
        revaHostelRoomAllotment({
            requestForId: this.currentUserContact,
            occupancy: this.sharingType,
            isPremium: this.isPremium,
            joiningDate: this.startDate,
            planType: this.planType,
            finalAmount: finalAmount,
            concession : this.concession,
            comments : this.comments
        })
        .then(result => {
            if (result.Status === 'Request Created!') {
               this.showToast('Success', 'Hostel request created successfully', 'success');
                 this.hostelRequestId = result.Id;
                 // this.fetchHostelFee();
                  this.createStudentFeeRecordImperative(finalAmount);
                    setTimeout(() => {
                        window.location.reload();
                    }, 1000);

            } else {
                alert(result.Status);
            }
        })
        .catch(error => {
            console.error(error);
            alert('Error');
        });
    }
handleClearEvent(){
    window.location.reload();
}
    fetchHostelFee() {

        if (!this.sharingType || !this.currentUserContact) {
            return;
        }

        calculateHostelFee({
            roomType: this.sharingType,
            isPremium: this.isPremium,
            isFinalYear: this.isFinalYear,
            gender: this.gender,
            planType : this.planType,
            academicYear : this.academicYear
        })
        .then(data => {

            // const formatNumberWithCommas = (number) => {
            //     return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            // };

            // // ✅ IMPORTANT
            // this.totalHostelFeeRaw = data?.hostelFee || 0;

            // // Only for UI
            // this.totalHostelFee = formatNumberWithCommas(this.totalHostelFeeRaw);

             this.totalHostelFeeRaw = data?.hostelFee || 0;
             this.totalHostelFee = this.totalHostelFeeRaw;

            console.log('RAW:', this.totalHostelFeeRaw);
            console.log('DISPLAY:', this.totalHostelFee);

        })
        .catch(error => {
            console.error('Error fetching hostel fee', error);
        });
    }

    @wire(getAllRoomPrices) 
    wiredCustomSettingsData({ error, data }) {
        if (data) {
            this.customSettingsData = data;
        } else if (error) {
            console.error('Error fetching custom settings data', error);
        }
    }
        
    createStudentFeeRecordImperative(amount) {
        console.log('Current User:', this.currentUserContact);
        console.log('Hostel Request ID:', this.hostelRequestId);
        console.log('Payment Type:', this.selectPaymentType);
         console.log('totalHostelFee:', amount);
      
        createStudentFeeRecord({ contactId: this.currentUserContact, paymentType: this.selectPaymentType, 
                                 totalFee: amount,isPremium: this.isPremium,
                                 hostelRequestId: this.hostelRequestId,planType: this.planType,
                                 concession: this.concession})
            .then((result) => {
                // Handle success if needed
                this.result = result;
                console.log('Student Fee Record Created Successfully:', result);
            })
            .catch((error) => {
                // Handle error if needed
                console.error('Error creating student fee record', error);
            });
    }
    showToast(title, message, variant) {
    this.dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: variant // success | error | warning | info
        })
    );
}
}