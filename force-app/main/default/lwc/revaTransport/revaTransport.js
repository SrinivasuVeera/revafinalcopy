import { LightningElement, wire, track,api } from 'lwc';
import revaTransportRegPage from '@salesforce/apex/RevaTransportHandler.revaTransportRegPage'
import revaTransportPortal from '@salesforce/apex/RevaTransportHandler.revaTransportPortal';
import ContactDetails from '@salesforce/apex/RevaTransportHandler.ContactDetails';
import revaTransportCancel from '@salesforce/apex/RevaTransportHandler.revaCancel';
import createCancellationRecord from '@salesforce/apex/TransportCancellationController.createCancellationRecord';
import createTransportRequest from '@salesforce/apex/TransportCancellationController.createTransportRequest';
import getTransportPolicy from '@salesforce/apex/TransportCancellationController.getTransportPolicy';
import searchRoute from '@salesforce/apex/routeMasterController.searchRoute';
import getPickUpPoints from '@salesforce/apex/RTR_routePickupPointController.getPickUpPoints';
import getTrasnportCancel from '@salesforce/apex/TransportCancellationController.getTransportcancelmdt';
import getUserProfileName from '@salesforce/apex/TransportCancellationController.getUserProfileName';
import RTR_IMAGE_1 from '@salesforce/resourceUrl/RTR_Image_1';
import RTR_IMAGE_4 from '@salesforce/resourceUrl/RTR_Image_4';

import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class RevaTransport extends LightningElement {
    /* Display Registration information */

    @track isStudent = false;
    @track recordsList;
      @track searchKey = "";
      @api selectedValue;
     @api selectedRecordId;
     @track routePay;
     @track routeRefund;
     @track value; // pickup point
     @track reason;
     @track startDate;
     @track processingFee;
     @track within90days;
     @track within60days;
     @track within30days;
     @track pickupPointOptions = [];
     policyText;
    programBatch = [];
    ProgramBatchName;
    cancellationDate;
    formattedDate;
    //programBatchName;
    //@track RevaCancel;
    RejectedStatus;
    CancelStatus;
    transportCancelleation;

    @track revaRegistrationPage;
    @track createdDate ='';
    @track createdDates;
    @track isSubmitting = false;
    @track isRouteChangeModalOpen = false;
    @track isRouteChangePolicy = false;
    diffDays;
    contactId;
    srnNumber;
    finalFee;
    isModalOpens;
    @track revaTransport;
    @track pickupPoint;
    @track amountPaid;
    @track transportCancel;
    @track transcancel;
    @track revaReg = [];
    reasonRejection;
    @track revaTransportRecordId;// capturing record Id of revaTransport record
    @track revaTransportRecordName = '';
    @track showStudentTransportForm = false;
    @track showParentComponent = true;
    loginDetails;
    pendingFee;
    uniFeePending;
    transFeePending;
    loginUserName;
    errorMessage;
    ReadytobeTransitioned;
    cancellationsDate;
    showCourseData = false;
    @track showData = false;
    @track isMobile = false;
    @track isDesktop = false;
    
    IMAGES;
    IMAGESTR;
    
    connectedCallback() {
         const width = window.innerWidth;
         console.log('width=> ',width);
        if (width > 768) { // You can adjust this width based on your needs
            this.isDesktop = true;
            this.isMobile = false;
            this.IMAGES=RTR_IMAGE_1;
        } else {
            this.isDesktop = false;
            this.isMobile = true;
             this.IMAGESTR= RTR_IMAGE_4;
            }
        }

    ///////////new Changes
    @track isPolicyOpen = false;
     @track isModalOpen = false;
    @track cancellationDate = '';
    @track cancellationReason = '';

    // Open the modal when the cancel button is clicked
    handleCancelClick() {
        this.isPolicyOpen = true;
    }
    handleAgreePolicy() {
        this.isPolicyOpen = false;
        this.isModalOpen = true;
    }
    handleClosePolicy() {
        this.isPolicyOpen = false;
        this.isRouteChangePolicy = false;
    }
    // Close the modal
    handleCloseModal() {
        this.isModalOpen = false;
        this.cancellationDate = '';
        this.cancellationReason = '';
    }
    get isCancelHidden() {
       // return this.revaRegistrationPage?.Registration_Status__c === 'Request made';
       const status = this.revaRegistrationPage?.Registration_Status__c;
       return !(status === 'Transport Admin Rejected' || status === 'Active' || status === 'Finance Team Rejected' || status === 'Route change Transport admin Rejected' );
    }

    
    @wire(getTransportPolicy)
    wiredPolicy({ error, data }) {
        if (data) {
            this.policyText = data;
            console.log('Policy Text>> ',this.policyText);
        } else if (error) {
            console.error('Error fetching transport policy:', error);
        }
    }

     @wire(getUserProfileName)
    wiredProfile({ error, data }) {
        if (data) {
            console.log('Profile Name:', data);
            this.isStudent = data === 'Student Profile';
            console.log('profileName>>> ',this.isStudent); 
        } else if (error) {
            console.error('Error fetching profile name:', error);
        }
    }
    // new changes for route change request 

    onLeave(event) {
        setTimeout(() => {
          this.searchKey = "";
          this.recordsList = null;
        }, 300);
      }

    handleKeyChange(event) {
        const searchKey = event.target.value;
        console.log('searchkey', searchKey);
        this.searchKey = searchKey;
        this.getLookupResult();
      }
    getLookupResult() {
        searchRoute({ searchKey: this.searchKey })
          .then((result) => {
            if (result.length === 0) {
              this.recordsList = [];
              this.message = "No Records Found";
            } else {
              this.recordsList = result;
              console.log('searchKey-->> ', this.searchKey);
              console.log('recordsList-->> ', this.recordsList)
              this.message = "";
            }
            this.error = undefined;
          })
          .catch((error) => {
            this.error = error;
            this.recordsList = undefined;
          });
      }

      removeRecordOnLookup(event) {
        this.searchKey = "";
        this.selectedValue = null;
        this.selectedRecordId = null;
        this.recordsList = null;
        this.selectedAmount = " ";
        this.showMessageComponent = false;
        this.studentCapacityFull = false;
        this.showConcessionAmount = false;
        this.showMonthlyDeduction = false;
        this.value = null;
        this.isProfessor = true;
        console.log('professor in lookup>>', this.isProfessor);
        this.onSeletedRecordUpdate();
      }

      onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.searchKey = "";
        this.onSeletedRecordUpdate();
        console.log(`selectedRecordId ${this.selectedRecordId}`);
        console.log(`selectedValue ${this.selectedValue}`);
        console.log('Retrieved revaTransportId---->>> ' + this.revaTransportId);
        console.log('Retrieved revaTransportName---->>> ' + this.revaTransportName);
      }

      @wire(getPickUpPoints, { selectedValue: '$selectedRecordId' })
  wiredContacts({ data, error }) {
    if (data) {
      console.log('pick-up points--->>> ', data) // fetch pickup point's all fields
      this.pickupPointOptions = data.map(RTR_Route_Pick_Up_Point__c => ({

        label: RTR_Route_Pick_Up_Point__c.Name,

        value: RTR_Route_Pick_Up_Point__c.Id,

        amount: RTR_Route_Pick_Up_Point__c.RTR_Payment_Amount__c,// fetch pick-up point amount

        facultyAmount: RTR_Route_Pick_Up_Point__c.RTR_Faculty_Fee__c,

        ifShortDistance: RTR_Route_Pick_Up_Point__c.rtr_If_Short_Distance__c,

        shortDistanceAmt: RTR_Route_Pick_Up_Point__c.Amount__c

      }));

      console.log('this is pickupPointOptions----------', this.pickupPointOptions);

    } else if (error) {

      // Handle error

    }

  }
  handleChange(event) {
    this.value = event.target.value;
    console.log('Selected Pickup-point---->>> ' + this.value)

    this.selectedPickupPoint = this.pickupPointOptions.find(options => options.value === this.value);

  }
    // new changes for route change request

    // Handle input changes
   handleDateChange(event) {
    this.cancellationDate = event.target.value;
console.log('Cancellation Date:', this.cancellationDate);
console.log('Cancellation Date (Type):', typeof this.cancellationDate);
this.cancellationsDate = new Date(this.cancellationDate);
console.log('Cancellation Date (After Parsing):', this.cancellationsDate);

const year = this.cancellationsDate.getFullYear();
const month = String(this.cancellationsDate.getMonth() + 1).padStart(2, '0');
const day = String(this.cancellationsDate.getDate()).padStart(2, '0');

this.formattedDate = `${year}-${month}-${day}`;
console.log('Formatted Date (YYYY-MM-DD):', this.formattedDate);

// Parse and normalize cancellation date
const cancellationDate = new Date(this.cancellationDate);
console.log('Cancellation Date:', cancellationDate);
console.log('Cancellation Date (Type):', typeof cancellationDate);
const cancellationDateString = cancellationDate.toISOString().split('T')[0];
const normalizedCancellationDate = new Date(cancellationDateString);

// Parse and normalize created date
const createdDate = new Date(this.createdDate);
console.log('Created Date:', createdDate);
const createdDateString = createdDate.toISOString().split('T')[0];
const normalizedCreatedDate = new Date(createdDateString);
const inputElement = event.target;
// Compare the normalized dates
/*
if (normalizedCancellationDate > normalizedCreatedDate) {
    console.log('Cancellation date is after created date.');
} else if (normalizedCancellationDate < normalizedCreatedDate) {
    console.log('Cancellation date is before created date.');
} else {
    console.log('Both dates are the same.');
}*/

    
    const endOfYear = new Date(new Date().getFullYear(), 11, 31); // Dec 31 of current year
    console.log('endOfYear--->> ',endOfYear);

     // Validation: cancellationDate should not be before createdDate
     
    if (normalizedCancellationDate < normalizedCreatedDate) {
        console.log('Cancellation date is before created date.');
        inputElement.setCustomValidity('Cancellation date cannot be before the created date.');
      // this.finalFee = null;
      // return;
    }else {
        inputElement.setCustomValidity('');
    }
    inputElement.reportValidity();

    // Validation: cancellationDate should not be after Dec 31 of current year
   /* if (cancellationDate > endOfYear) {
        this.errorMessage = 'Cancellation date cannot be later than December 31 of this year.';
        this.finalFee = null;
        return;
    }*/

    // Clear previous error if validations pass
    this.errorMessage = '';
     // Check if cancellation date is the same as created date
     if (
        cancellationDate.getFullYear() === createdDate.getFullYear() &&
        cancellationDate.getMonth() === createdDate.getMonth() &&
        cancellationDate.getDate() === createdDate.getDate()
    ) {
        this.finalFee = this.amountPaid - this.processingFee;
        console.log('Same day cancellation. ₹2000 deducted. Final Fee:', this.finalFee);
        this.errorMessage = '';
        return;
    }

    // Calculate the difference in days
    const diffTime = cancellationDate - createdDate;
    console.log('diffTime',diffTime);
    this.diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    console.log('Days of Service:', this.diffDays);

    let fee = this.amountPaid;
    console.log('Fee1',fee);
    let discount = 0;
    this.errorMessage = ''; // Clear previous error message

    // Convert array values to numbers and sort them in ascending order
const sortedTranscancel = this.transcancel.map(Number).sort((a, b) => a - b);

if (this.diffDays < sortedTranscancel[0]) {
    discount = this.within30days * fee;
    console.log('discount>>',discount);
    console.log('within30days>>>inside ',this.within30days);
} else if (this.diffDays >= sortedTranscancel[0] && this.diffDays < sortedTranscancel[1]) {
    discount = this.within60days * fee;
} else if (this.diffDays >= sortedTranscancel[1] && this.diffDays < sortedTranscancel[2]) {
    discount = this.within90days * fee;
} else {
    this.errorMessage = 'No refund is applicable as the usage exceeds ' + sortedTranscancel[2] + ' days.';
    console.error(this.errorMessage);

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Refund Not Applicable',
            message: this.errorMessage,
            variant: 'error',
            mode: 'dismissable' 
        })
    );

    return;
}


    const finalFee = fee - discount;
    console.log(`Final Fee after deduction: ${finalFee}`);
    this.finalFee = finalFee;
}

handleReasonChanges(event) {
        this.cancellationReason = event.target.value;
        console.log('cancellationReason',this.cancellationReason);
        
    }

     // Submit cancellation
    handleSubmit() {
        this.isSubmitting = true;
      console.log('Submitting cancellation request...');

        if (!this.formattedDate || !this.cancellationReason) {

            this.isSubmitting = false;

            const dateInput = this.template.querySelector('lightning-input');
            const reasonInput = this.template.querySelector('lightning-textarea');
        
            // Show native field-level validation
            this.formattedDate = dateInput.reportValidity();
            this.cancellationReason = reasonInput.reportValidity();
        }

        createCancellationRecord({ 
            cancellationDate: this.formattedDate, 
            cancellationReason: this.cancellationReason,
            contactId : this.contactId,
            srnNumber : this.srnNumber,
            revaTransport : this.revaTransport,
            pickupPoint : this.pickupPoint,
            finalFee : this.finalFee,
            uniFeePending  : this.uniFeePending,
            transFeePending : this.transFeePending
        })
        .then(() => {
            this.showToast('Success', 'Your Request For Transport Cancellation Is Submitted Successfully.', 'success');
            //this.contactId = '';
            this.isModalOpen = false;

            setTimeout(() => {
                window.location.reload();
            }, 1500);
        })
        .catch(error => {
            console.error('Error:', error);
            this.showToast('Error', 'An error occurred while submitting your request.', 'error');
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

     @wire(revaTransportCancel)
    getRevatransportCancel({data,error}){
  if(data){
    this.transportCancel = data;
    console.log('dataCancel',this.transportCancel);
    this.transcancel = this.transportCancel.map(item => item.MasterLabel);
   
    //this.transcancel = this.transportCancel[0].MasterLabel;
    console.log('transportCancel',this.transcancel);
  }
  if(error){
    console.log('error');
  }
    }

    handleReasonChange(event) {
        this.reason = event.target.value;
        console.log('Reason for Route Change>>>',this.reason);
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
        console.log('StartDate for Route Change>>>',this.startDate);

    }

     handleRouteChangeSubmit() {
     createTransportRequest({
                routePath: this.selectedRecordId,
                pickupPoint: this.value,
                reason: this.reason,
                startDate: this.startDate,
                contactId : this.contactId
            })
            .then(() => {
                this.showToast('Success', 'Your Request For Route Change Request Is Submitted Successfully.', 'success');
                //this.contactId = '';
                this.isModalOpen = false;
    
                setTimeout(() => {
                    window.location.reload();
                }, 1500);
            })
            .catch(error => {
                console.error('Error:', error);
                this.showToast('Error', 'An error occurred while submitting your request.', 'error');
            });
            this.closeRouteChangeModal();
        }
 
    //new changes for route change request


   openRouteChangeModal() {
        this.isRouteChangePolicy = true;
    }

    closeRouteChangeModal() {
        this.isRouteChangeModalOpen = false;
    }
agreeToPolicy() {
        this.isRouteChangePolicy = false;
        console.log('User agreed to policy.');
        this.isRouteChangeModalOpen = true;
    }
    closeModal() {
        this.isRouteChangePolicy = false;
    }
    //new changes for route change request 
/////////New Changes
    //For Contact Details
    @wire(ContactDetails)
    getContactDetails({ data, error }) {
        if (data) {
            // alert(JSON.stringify(data));
            this.loginDetails = data;
            console.log('loginDetails-->> ', data);
           
            if (data.Name != null) {
                this.loginUserName = data.Name;
                this.ReadytobeTransitioned = data.Ready_to_be_Transitioned__c;
                console.log('ReadytobeTransitioned-->> ' + this.ReadytobeTransitioned);
                console.log('Name-->> ' + this.loginUserName);
                this.pendingFee = data.Pending_Fees__c;
                console.log('Pending_Fees__c-->> ' + this.pendingFee);
            }

            console.log('this.loginDetails.Record_Type_Name__c-->> ', this.loginDetails.Record_Type_Name__c)

            if (this.loginDetails.Record_Type_Name__c === 'Student') {
                this.showCourseData = true;
            }
            else {
                this.showCourseData = false;
            }

               //iterate over studentfees to fetch amount pending
               this.loginDetails.Student_Fees__r.forEach(item => {
                if(item.Fee_Type__c=='University Fee' && item.Amount_Pending__c>0){
                  this.uniFeePending = item.Amount_Pending__c;
                  console.log('uniFeePending-->> ',this.uniFeePending);
                }
                if(item.Fee_Type__c=='Transportation Fee' && item.Amount_Pending__c >0){
                    this.transFeePending = item.Amount_Pending__c;
                    console.log('transFeePending-->> ',this.transFeePending);
                }
        })



        }
        if (error) {
            console.log(error);
        }
    }

    @wire(getTrasnportCancel)
     getTrasnportCancelrecords({ data, error }){
        if(data){
            this.transportCancelleation = data;
            console.log('transportCancelleation',this.transportCancelleation);
            this.within30days = data.Within_30_days__c/100;
            console.log('this.within30days-->> ',this.within30days);
            this.within30daysDec = this.within30days/100;
            console.log('this.within30daysDec-->> ',this.within30daysDec);
            this.within60days = data.Within_60_days__c/100;
            console.log('this.within60days-->> ',this.within60days);
            this.within90days = data.Within_90_days__c/100;
            console.log('this.within90days->>',typeof(this.within90days));
            this.processingFee = data.Processing_Fee__c;
            console.log('this.processingFee-->> ',this.processingFee);


        }
    
    
     if (error) {
         console.log(error);
     }
}

get showMainRefund() {
        const main = this.revaRegistrationPage?.Amount_to_be_Refunded__c;
        const route1 = this.revaRegistrationPage?.Route_Change_Refund__c;
        const route2 = this.revaRegistrationPage?.RouteChangeAmountToPay__c;
        return main && (!route1 && !route2);
    }

    get showRouteRefunds() {
        const main = this.revaRegistrationPage?.Amount_to_be_Refunded__c;
        const route1 = this.revaRegistrationPage?.Route_Change_Refund__c;
        const route2 = this.revaRegistrationPage?.RouteChangeAmountToPay__c;
        return (route1 || route2) && !main;
    }
     get showPayButton() {
        return this.revaRegistrationPage?.RouteChangeAmountToPay__c ;
    }
    

    handlePayRouteChange() {
        
        console.log('Pay Route Change Fee clicked');
        window.location.href = '/StudentPortal/s/student-fee';
    
    }
    //For Registration Details
    @wire(revaTransportRegPage)
    registrationRecords({ data, error }) {
        if (data) {
           console.log('Registration Details-->> ', data)
            
            if (data.Id) {
                this.revaRegistrationPage = data;
                 if(this.revaRegistrationPage.Registration_Status__c=='Transport Admin Rejected' || this.revaRegistrationPage.Registration_Status__c=='Route change Transport admin Rejected'){
                    this.RejectedStatus = this.revaRegistrationPage.Registration_Status__c;
                }
                if(this.revaRegistrationPage.Registration_Status__c=='Cancellation Approved' || this.revaRegistrationPage.Registration_Status__c=='Route change Transport admin Approved' || this.revaRegistrationPage.Registration_Status__c=='Route change Finance team approved' || this.revaRegistrationPage.Registration_Status__c=='Route change Finance team rejected'){
                    this.CancelStatus = this.revaRegistrationPage.Registration_Status__c;
                }
                //this.showData = true;
                console.log('Data', this.revaRegistrationPage);
                console.log('createdDate',this.createdDate);
               const semesterNumber = data.Contact__r.Active_Semester__r.Semester_Number_c__c;

                

            if (semesterNumber % 2 === 1) {
   
            this.createdDates = data.Contact__r.Active_Semester__r.hed__Start_Date__c;
            console.log('oddsemDate>> ',this.createdDates);
                } 
                else {

            this.createdDates = data.Contact__r.Active_Semester__r.Odd_Semester_Start_Date_c__c;
            console.log('evensemDate>> ',this.createdDates);
            }
             
            this.contactId = data.Contact__c;
            console.log('contactId>>',this.contactId)
            this.revaRegistrationPage = data;
            console.log('revaRegistrationPage >>>>>',JSON.stringify(this.revaRegistrationPage));
            
                this.pickupPoint = data.Route_Pick_Up_Point__c;
                console.log('Pickuppoint>>',this.pickupPoint);
                console.log('typeofPickuppoint>>',typeof(this.pickupPoint));
                
                this.srnNumber = data.Contact__r.SRN_Number__c;
                console.log('srnNumber>>',this.srnNumber);
                this.revaTransport = data.Reva_Transport__c;
                console.log('revaTransport>>',this.revaTransport);
                this.createdDate = this.createdDates.split('T')[0];
                console.log('createdDate1',this.createdDate);
                this.amountPaid = data.Amount_Paid__c;
                console.log('AmountPaid>>>',this.amountPaid);
                this.reasonRejection = data.Reason_For_Rejection__c;
                
                this.routeRefund = data.Route_Change_Refund__c;
                console.log('routeRefund',this.routeRefund);
                this.routePay = data.RouteChangeAmountToPay__c;
                console.log('routePay',this.routePay);
               
            }
            else {
                //this.showData = false;
            }
        }
        else if (error) {
            console.error('Student has not registered for transport ' + error)
        }
    }

    get regStatus() {
        return `${this.revaRegistrationPage.Registration_Status__c === 'Cancelled' ? 'slds-text-color_error' : 'slds-text-color_success'}`
    }
    get regStat() {
        return `${this.revaRegistrationPage.Registration_Status__c === 'Transport Admin Rejected' ? 'slds-text-color_error':''}`
    }
        

    //For Registration Button
    @wire(revaTransportPortal)
    revaRegistrationRecord({ data, error }) {
        if (data) {
            //this.programType = data[0].Program_Types__r;
            //console.log('programType-->> ', this.programType);
            //if (Array.isArray(this.programType)) {
              //  this.programType.forEach(item => {
            this.programBatch = data[0].Program_Batches__r;
            console.log('programBatch-->> ', this.programBatch);
            if (Array.isArray(this.programBatch)) {
                this.programBatch.forEach(item => {
                    if (item) {
                        if (item.Name) {
                            this.ProgramBatchName = item.Name;
                            console.log('ProgramBatchName-->> ', this.ProgramBatchName);

                            if ((this.loginDetails.Record_Type_Name__c === 'Student')) {
                                if (this.ProgramBatchName === this.loginDetails.Program_Batch__r.Name) {
                                    console.log('inside if block', this.ProgramBatchName)
                                    console.log('REGISTER Button-->> ', data);
                                    this.revaReg = data;
                                    console.log('Registration Records---->>> ' + JSON.stringify(this.revaReg));
                                }
                                else {
                                    console.log('Program Batch Name and Program Type is not Matching');
                                }
                            }
                            else if (this.loginDetails.Record_Type_Name__c === 'Applicant' && this.ReadytobeTransitioned === true) {
                                console.log('REGISTER Button-->> ', data);
                                this.revaReg = data;
                                console.log('Registration Records---->>> ' + JSON.stringify(this.revaReg));
                            }
                            else if (this.loginDetails.Record_Type_Name__c === 'Professor' || this.loginDetails.Record_Type_Name__c === 'Non Teaching') {
                                console.log('else block entered of non-student i.e professor and non-teaching')
                                console.log('REGISTER Button-->> ', data);
                                this.revaReg = data;
                                console.log('Registration Records---->>> ' + JSON.stringify(this.revaReg));
                            }

                        }
                    }
                })
            }


            

        }
        else if (error) {
            console.error(error);
        }
    }

    handleNavigation(event) {
        this.revaTransportRecordId = event.target.dataset.key;
        this.revaTransportRecordName = event.target.dataset.name;
        console.log(`Target revaTransport Record Id---->>> ${this.revaTransportRecordId}`)
        console.log(`Target revaTransport RecordName---->>> ${this.revaTransportRecordName}`)
        this.showStudentTransportForm = true
        this.showParentComponent = false;

        // Navigate to revaTransport Registration Page
        //window.location.href = `/StudentPortal/s/transport-registration-page?recordId=${this.revaTransportRecordId}`;
    }
    handlecancel(event){

    }
}