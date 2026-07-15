import { LightningElement, api, track, wire } from 'lwc';
import searchRoute from '@salesforce/apex/routeMasterController.searchRoute';
import transportRegistration from '@salesforce/apex/routeMasterController.transportRegistration'
import getPickUpPoints from '@salesforce/apex/RTR_routePickupPointController.getPickUpPoints';
import getAccessToken from '@salesforce/apex/HCMIntegartionController.getAccessToken'
import getSalaryRange from '@salesforce/apex/HCMIntegartionController.getSalaryRange'
import searchRevaRequest from '@salesforce/apex/routeMasterController.searchRevaRequest';
import searchRecordType from '@salesforce/apex/routeMasterController.searchRecordType';
import updatePayableAmount from '@salesforce/apex/routeMasterController.updatePayableAmount';
import getFacultyDetails from '@salesforce/apex/routeMasterController.getFacultyDetails';
import RTR_IMAGE_1 from '@salesforce/resourceUrl/RTR_Image_1'
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';

//import { CurrentPageReference } from 'lightning/navigation'
const DELAY = 100;

export default class StudentTransportForm extends NavigationMixin(LightningElement) {

  @track recordsList;
  @track searchKey = "";
  @api selectedValue;
  @api selectedRecordId;
  @api revaTransportId;
  @api revaTransportName;
  @track selectedAmount = '';
  @track facultyAmount = '';
  @track showStartDateError = false;
  studentCapacity = ''
  concessionAmount;
  selectedpickupAmount;
  requestStatus;
  employeeNumber = '';
  @track requestPickupPoint;
  recordTypeName;
  montlyDeduction;
  shortDistanceAmt;
  selectedDate;
  registrationId;
  AmountDeduction
  studentAllocated = '';
  facultyAllocated = '';
  facultyCapacity;
  RoutePath;
  isSubmitButtonDisable = false;
  @track loginDetails = [];
  showCourseData = false;

  @track longDistDeduction;
  @track pickupPointName;
  @track selectedPickupPoint;

  //   @api objectApiName;  
  //@api iconName;  
  // @api lookupLabel;  
  @track message;
  @track routeMessage;
  @track showMessageComponent = false;
  @track pickupPointOptions = [];
  @track value;
  @track studentCapacityFull = false;
  @track showConcessionAmount = false;
  @track isProfessor = false;
  @track showMonthlyDeduction = false;
  @track initialSelection = false;
  @track showFacultyDetails = false;
  @track pastDate = false;
  @track showConfirmationModal = false;

  IMAGES = {
    rtrImage1: RTR_IMAGE_1

  }


  onLeave(event) {
    setTimeout(() => {
      this.searchKey = "";
      this.recordsList = null;
    }, 300);
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

  handleKeyChange(event) {
    const searchKey = event.target.value;
    this.searchKey = searchKey;
    this.getLookupResult();
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

  onSeletedRecordUpdate() {
    if (this.selectedRecordId && this.selectedValue) {
      const selectedRoute = this.recordsList.find(route => route.Id === this.selectedRecordId)
      if (selectedRoute) {
        this.studentCapacity = selectedRoute.RTR_Student_Capacity__c
        console.log('Student Capacity--->>> ', this.studentCapacity)

        this.studentAllocated = selectedRoute.rtr_Student_Capacity_Allocated__c
        console.log('StudentAllocated-->> ', this.studentAllocated);

        this.facultyAllocated = selectedRoute.rtr_Faculty_CapacityAllocated__c;
        console.log('FacultyAllocated-->> ', this.facultyAllocated);

        this.facultyCapacity = selectedRoute.RTR_Faculty_Capacity__c
        console.log('faculty Capacity--->>> ', this.facultyCapacity)

        if ((this.studentCapacity === this.studentAllocated) && (this.recordTypeName == 'Applicant' || this.recordTypeName === 'Student')) {
          this.routeMessage = 'Student Capacity is full for this Route. Please Contact your Admin ';
          console.log('--->>> ', this.routeMessage);
          this.showMessageComponent = true;
          this.studentCapacityFull = true
        }
        else if ((this.facultyCapacity === this.facultyAllocated) && (this.recordTypeName === 'Professor' || this.recordTypeName === 'Non Teaching')) {
          this.routeMessage = 'Capacity is full for this Route. Please Contact your Admin ';
          console.log('--->>> ', this.routeMessage);
          this.showMessageComponent = true;
          this.studentCapacityFull = true
        }
        else {
          this.routeMessage = '';
          this.showMessageComponent = false;
        }
      }
    }

    const passEventr = new CustomEvent('recordselection', {
      detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }
    });
    this.dispatchEvent(passEventr);
  }

  @wire(searchRecordType)
  getsearchRecordType({ data, error }) {
    if (data) {
      console.log('data-->> ', data)
      console.log('RecordTypeName-->> ', data.RecordType.Name);
      this.recordTypeName = data.RecordType.Name;
      this.loginDetails = data;
      this.employeeNumber = data.Employee_Number__c;
      console.log('employeeNumber', this.employeeNumber);
      console.log('loginDetails-->> ', this.loginDetails);
      if (this.recordTypeName === 'Student') {
        this.showCourseData = true;
        this.isstudent = false;
        console.log('Student Variabel 1>>', this.recordTypeName);
      }else if (this.recordTypeName === 'Applicant') {
        this.showCourseData = true;
      }
      else {
        this.showCourseData = false;
        console.log('Student Variabel 2>>', this.recordTypeName);
        this.isProfessor = true;
        this.isstudent = true;
        console.log('professor Variabel 2>>', this.isProfessor);
      }
    }
    if (error) {
      console.log('error-->> ', error);
    }
  }


  @wire(updatePayableAmount)
  getupdatePayableAmount({ data, error }) {
    if (data) {
      console.log('data Payable-->> ', data)
      this.longDistDeduction = data;
    }
    if (error) {
      console.log('error-->> ', error)
    }
  }


  // //consent form checkedbox
  pdfUrl = 'https://reva-university--codev1.sandbox.my.salesforce.com/sfc/p/1e0000000p6O/a/1e0000000mZg/IglSQ49KnttWJyKW1VlnlCH9S4FQyNrdcwlLfFF5UPs';
  isChecked = false;

  formattedLabelText = 'I have reviewed this <a href=' + this.pdfUrl + ' target="_blank" style="color:orange;">Transport Consent Form</a>. I accept this agreement for Transportation.';


  handleCheckboxChange(event) {
    this.isChecked = event.target.checked;
  }
  get isSubmitButtonDisabled() {
    return this.studentCapacityFull || !this.isChecked || this.pastDate || this.isSubmitButtonDisable;
  }

  handleDateChange(event) {

    this.selectedDate = event.target.value;
    console.log(this.selectedDate);
    const currentDate = new Date().toISOString().split('T')[0];
    console.log('currentDate', currentDate);

    //  const selDate = new Date(this.selectedDate)
    //  console.log('selDate',selDate);
    // Compare the selected date with the current date

    // if (this.selectedDate < currentDate) {
    //   // Prevent the user from selecting a previous date
    //   event.target.setCustomValidity("Please select a future date.");
    //   this.pastDate = true;
    //   this.showStartDateError = false;
    //   console.log('pastdate', this.pastDate);
    // } else {
    //   // Clear any previous validation message
    //   event.target.setCustomValidity("");
    //   this.pastDate = false;
    //   this.showStartDateError = false;
    //   this.isSubmitButtonDisable = false;

    // }
    //Report the validation result
    //event.target.reportValidity();

    // if (event.target.checkValidity()) {
    //   this.isSubmitButtonDisable = false;
    // }

  }


  /* Transport Registration Creation on click of submit button */
  handleSubmit() {
    this.isSubmitButtonDisable = true;
    this.showConfirmationModal = true;
    // if ((this.selectedRecordId || this.revaTransportId) && this.value) {
    //   if (this.recordTypeName === 'Student') {
    //     transportRegistration(
    //       {
    //         routeMasterId: this.selectedRecordId,
    //         revaTransportId: this.revaTransportId,
    //         revaTransportName: this.revaTransportName,
    //         pickupPointId: this.value,
    //         totalAmount: this.selectedAmount,
    //         selectedDate: this.selectedDate,
    //         concessionAmount: this.concessionAmount,
    //         selectedpickupAmount: this.selectedpickupAmount,
    //         montlyDeduction: this.montlyDeduction
    //       }
    //     ).then(result => {
    //       console.log('Transport Registration created successfully--->> ' + result)
    //       this.dispatchEvent(
    //         new ShowToastEvent({
    //           title: 'Success',
    //           message: 'Transport Registration Created Successfully!!',
    //           variant: 'success'

    //         })
    //       );
    //       window.location.href = '/StudentPortal/s/student-fee';
    //     })
    //       .catch(error => {
    //         console.error('Error Occur in transport registration---->>> ' + error)
    //         this.dispatchEvent(
    //           new ShowToastEvent({
    //             title: 'Error',
    //             message: 'Error Occurred While Transport Registration.Please Select Routh Path and Pickup Point',
    //             variant: 'error'
    //           })
    //         );
    //         this.isSubmitButtonDisable = false;
    //       })

    //   }
    //   else if (this.recordTypeName == 'Professor' && this.selectedDate) {
    //     transportRegistration(
    //       {
    //         routeMasterId: this.selectedRecordId,
    //         revaTransportId: this.revaTransportId,
    //         revaTransportName: this.revaTransportName,
    //         pickupPointId: this.value,
    //         totalAmount: this.selectedAmount,
    //         selectedDate: this.selectedDate,
    //         montlyDeduction: this.montlyDeduction,
    //         shortDistanceChecked: this.shortDistanceChecked
    //       }
    //     ).then(result => {
    //       console.log('Transport Registration created successfully--->> ' + result)
    //       this.dispatchEvent(
    //         new ShowToastEvent({
    //           title: 'Success',
    //           message: 'Transport Registration Created Successfully!!',
    //           variant: 'success'

    //         })
    //       );
    //       location.reload();
    //     })
    //       .catch(error => {
    //         console.error('Error Occur in transport registration---->>> ' + error)
    //         this.dispatchEvent(
    //           new ShowToastEvent({
    //             title: 'Error',
    //             message: 'Error Occurred While Transport Registration.Please Select Routh Path and Pickup Point',
    //             variant: 'error'
    //           })
    //         );
    //         this.isSubmitButtonDisable = false;
    //       })

    //   }
    //   else if (this.recordTypeName == 'Non Teaching' && this.selectedDate) {
    //     transportRegistration(
    //       {
    //         routeMasterId: this.selectedRecordId,
    //         revaTransportId: this.revaTransportId,
    //         revaTransportName: this.revaTransportName,
    //         pickupPointId: this.value,
    //         totalAmount: this.selectedAmount,
    //         selectedDate: this.selectedDate,
    //         montlyDeduction: this.montlyDeduction,
    //         shortDistanceChecked: this.shortDistanceChecked
    //       }
    //     ).then(result => {
    //       console.log('Transport Registration created successfully--->> ' + result)
    //       this.dispatchEvent(
    //         new ShowToastEvent({
    //           title: 'Success',
    //           message: 'Transport Registration Created Successfully!!',
    //           variant: 'success'

    //         })
    //       );
    //       location.reload();
    //     })
    //       .catch(error => {
    //         console.error('Error Occur in transport registration---->>> ' + error)
    //         this.dispatchEvent(
    //           new ShowToastEvent({
    //             title: 'Error',
    //             message: 'Error Occurred While Transport Registration.Please Select Routh Path and Pickup Point',
    //             variant: 'error'
    //           })
    //         );
    //         this.isSubmitButtonDisable = false;
    //       })

    //   }
    //   else if (this.recordTypeName == 'Applicant') {
    //     transportRegistration(
    //       {
    //         routeMasterId: this.selectedRecordId,
    //         revaTransportId: this.revaTransportId,
    //         revaTransportName: this.revaTransportName,
    //         pickupPointId: this.value,
    //         totalAmount: this.selectedAmount,
    //         selectedDate: this.selectedDate,
    //         concessionAmount: this.concessionAmount,
    //         selectedpickupAmount: this.selectedpickupAmount,
    //         montlyDeduction: this.montlyDeduction
    //       }
    //     ).then(result => {
    //       console.log('Transport Registration created successfully--->> ' + result)
    //       this.dispatchEvent(
    //         new ShowToastEvent({
    //           title: 'Success',
    //           message: 'Transport Registration Created Successfully!!',
    //           variant: 'success'

    //         })
    //       );
    //       window.location.href = '/Admissions/s/?tabset-906eb=2';
    //       //location.reload();
    //       //this.navigateTab();

    //     })
    //       .catch(error => {
    //         console.error('Error Occur in transport registration---->>> ' + error)
    //         this.dispatchEvent(
    //           new ShowToastEvent({
    //             title: 'Error',
    //             message: 'Error Occurred While Transport Registration.Please Select Routh Path and Pickup Point',
    //             variant: 'error'
    //           })
    //         );
    //         this.isSubmitButtonDisable = false;
    //       })
    //   }

    // } else {
    //   this.dispatchEvent(
    //     new ShowToastEvent({
    //       title: 'Error',
    //       message: 'Error Occurred While Transport Registration',
    //       variant: 'error'
    //     })
    //   );
    //   console.log(`Error Occured both values should be passed`)
    // }
    // if (!this.selectedDate) {
    //   // Start date is not selected, show error message
    //   this.showStartDateError = true;
    //   return;
    // }
    // else {
    //   this.showStartDateError = false;
    // }

  }
  handleCancel() {
    this.showConfirmationModal = false;
  }

// Handles Confirm button in the modal
  handleConfirm() {
      this.showConfirmationModal = false;
     
      if ((this.selectedRecordId || this.revaTransportId) && this.value) {
        if (this.recordTypeName === 'Student') {
          transportRegistration(
            {
              routeMasterId: this.selectedRecordId,
              revaTransportId: this.revaTransportId,
              revaTransportName: this.revaTransportName,
              pickupPointId: this.value,
              totalAmount: this.selectedAmount,
              selectedDate: this.selectedDate,
              concessionAmount: this.concessionAmount,
              selectedpickupAmount: this.selectedpickupAmount,
              montlyDeduction: this.montlyDeduction
            }
          ).then(result => {
            console.log('Transport Registration created successfully--->> ' + result)
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Success',
                message: 'Transport Registration Created Successfully!!',
                variant: 'success'
  
              })
            );
            window.location.href = '/StudentPortal/s/student-fee';
          })
            .catch(error => {
              console.error('Error Occur in transport registration---->>> ' + error)
              this.dispatchEvent(
                new ShowToastEvent({
                  title: 'Error',
                  message: 'Error Occurred While Transport Registration.Please Select Routh Path and Pickup Point',
                  variant: 'error'
                })
              );
              this.isSubmitButtonDisable = false;
            })
              
        }
        else if (this.recordTypeName == 'Professor' && this.selectedDate) {
          transportRegistration(
            {
              routeMasterId: this.selectedRecordId,
              revaTransportId: this.revaTransportId,
              revaTransportName: this.revaTransportName,
              pickupPointId: this.value,
              totalAmount: this.selectedAmount,
              selectedDate: this.selectedDate,
              montlyDeduction: this.montlyDeduction,
              shortDistanceChecked: this.shortDistanceChecked
            }
          ).then(result => {
            console.log('Transport Registration created successfully--->> ' + result)
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Success',
                message: 'Transport Registration Created Successfully!!',
                variant: 'success'
  
              })
            );
            location.reload();
          })
            .catch(error => {
              console.error('Error Occur in transport registration---->>> ' + error)
              this.dispatchEvent(
                new ShowToastEvent({
                  title: 'Error',
                  message: 'Error Occurred While Transport Registration.Please Select Routh Path and Pickup Point',
                  variant: 'error'
                })
              );
              this.isSubmitButtonDisable = false;
            })
  
        }
        else if (this.recordTypeName == 'Non Teaching' && this.selectedDate) {
          transportRegistration(
            {
              routeMasterId: this.selectedRecordId,
              revaTransportId: this.revaTransportId,
              revaTransportName: this.revaTransportName,
              pickupPointId: this.value,
              totalAmount: this.selectedAmount,
              selectedDate: this.selectedDate,
              montlyDeduction: this.montlyDeduction,
              shortDistanceChecked: this.shortDistanceChecked
            }
          ).then(result => {
            console.log('Transport Registration created successfully--->> ' + result)
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Success',
                message: 'Transport Registration Created Successfully!!',
                variant: 'success'
  
              })
            );
            location.reload();
          })
            .catch(error => {
              console.error('Error Occur in transport registration---->>> ' + error)
              this.dispatchEvent(
                new ShowToastEvent({
                  title: 'Error',
                  message: 'Error Occurred While Transport Registration.Please Select Routh Path and Pickup Point',
                  variant: 'error'
                })
              );
              this.isSubmitButtonDisable = false;
            })
  
        }
        else if (this.recordTypeName == 'Applicant') {
          transportRegistration(
            {
              routeMasterId: this.selectedRecordId,
              revaTransportId: this.revaTransportId,
              revaTransportName: this.revaTransportName,
              pickupPointId: this.value,
              totalAmount: this.selectedAmount,
              selectedDate: this.selectedDate,
              concessionAmount: this.concessionAmount,
              selectedpickupAmount: this.selectedpickupAmount,
              montlyDeduction: this.montlyDeduction
            }
          ).then(result => {
            console.log('Transport Registration created successfully--->> ' + result)
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Success',
                message: 'Transport Registration Created Successfully!!',
                variant: 'success'
  
              })
            );
            window.location.href = '/Admissions/s/?tabset-906eb=2';
            //location.reload();
            //this.navigateTab();
  
          })
            .catch(error => {
              console.error('Error Occur in transport registration---->>> ' + error)
              this.dispatchEvent(
                new ShowToastEvent({
                  title: 'Error',
                  message: 'Error Occurred While Transport Registration.Please Select Routh Path and Pickup Point',
                  variant: 'error'
                })
              );
              this.isSubmitButtonDisable = false;
            })
        }
  
      } else {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'Error Occurred While Transport Registration',
            variant: 'error'
          })
        );
        console.log(`Error Occured both values should be passed`)
      }
      if (!this.selectedDate) {
        // Start date is not selected, show error message
        this.showStartDateError = true;
        return;
      }
      else {
        this.showStartDateError = false;
      }
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

  // revaRequest data
  // @wire(searchRevaRequest)
  // revaRequestRecord({ data, error }) {
  //   if (data) {
  //     console.log('RevaRequestList--->>> ', data);
  //     if (Array.isArray(data)) {
  //       data.forEach(item => {
  //         // Check if item is not null or undefined
  //         if (item) {
  //           // Check if the properties exist before accessing them
  //           if (item.RTR_Amount__c) {
  //             this.concessionAmount = item.RTR_Amount__c;
  //             console.log('ConcessionAmount-->> ', this.concessionAmount);
  //           }
  //           if (item.RTR_Status__c) {
  //             this.requestStatus = item.RTR_Status__c;
  //             console.log('Request Status-->> ', this.requestStatus);
  //           }
  //           // Check if the related record exists before accessing its properties
  //           if (item.RTR_Route_Pick_Up_Point__r && item.RTR_Route_Pick_Up_Point__r.Id) {
  //             this.requestPickupPoint = item.RTR_Route_Pick_Up_Point__r.Id;
  //             console.log('RequestPickupPoint--->>> ', this.requestPickupPoint);
  //           }
  //         }
  //       });
  //     }
  //   } else if (error) {
  //     console.error(error);
  //   }
  // }

  handleChange(event) {
    this.value = event.target.value;
    console.log('Selected Pickup-point---->>> ' + this.value)

    this.selectedPickupPoint = this.pickupPointOptions.find(options => options.value === this.value);

    searchRevaRequest()
      .then(result => {
        console.log('RevaRequestList--->>> ', result);
        if (Array.isArray(result)) {
          result.forEach(item => {
            // Check if item is not null or undefined
            if (item) {
              // Check if the properties exist before accessing them
              if (item.RTR_Amount__c) {
                this.concessionAmount = item.RTR_Amount__c;
                console.log('ConcessionAmount-->> ', this.concessionAmount);
              }
              if (item.RTR_Status__c) {
                this.requestStatus = item.RTR_Status__c;
                console.log('Request Status-->> ', this.requestStatus);
              }
              // Check if the related record exists before accessing its properties
              if (item.RTR_Route_Pick_Up_Point__r && item.RTR_Route_Pick_Up_Point__r.Id) {
                this.requestPickupPoint = item.RTR_Route_Pick_Up_Point__r.Id;
                console.log('RequestPickupPoint--->>> ', this.requestPickupPoint);
              }
            }
          });
        }

        if (this.selectedPickupPoint) {
          this.pickupPointName = this.selectedPickupPoint.label;
          console.log('pickupPointName-->> ', this.pickupPointName);

          this.shortDistanceChecked = this.selectedPickupPoint.ifShortDistance;
          console.log('shortDistanceChecked-->> ', this.shortDistanceChecked);

          this.shortDistanceAmt = this.selectedPickupPoint.shortDistanceAmt;
          console.log('shortDistanceAmt-->> ', this.shortDistanceAmt);

          if (this.recordTypeName == 'Applicant' || this.recordTypeName === 'Student') {
            if (this.concessionAmount != null && this.requestStatus === 'Approved' && (this.value === this.requestPickupPoint)) {
              console.log('revaRequestData.RTR_Amount__c ', this.concessionAmount);
              console.log('revaRequestData.RTR_Status__c ', this.requestStatus);
              console.log('Selected Pickpoint Amount Before Concession--->> ' + this.selectedPickupPoint.amount);
              console.log('Datatype of selectedAmount-->> ', typeof (this.selectedAmount));
              this.showConcessionAmount = true;
              this.selectedpickupAmount = this.selectedPickupPoint.amount;
              this.selectedAmount = this.selectedPickupPoint.amount - this.concessionAmount;
              console.log('Pick up point Amount After Concession--->>> ', this.selectedAmount);
            } else {
              this.showConcessionAmount = false;
              this.concessionAmount = 0;
              this.selectedAmount = this.selectedPickupPoint.amount;
              this.selectedpickupAmount = this.selectedPickupPoint.amount;
              console.log('Selected Pickpoint Amount--->> ' + this.selectedAmount);
              this.pickupPointName = this.selectedPickupPoint.label;
              console.log('pickupPointName-->> ', this.pickupPointName);
            }
          }

          if (this.recordTypeName == 'Professor' || this.recordTypeName == 'Non Teaching') {
            this.isProfessor = true;
            console.log('Professor Variabel 4 >>', this.isProfessor);
            getAccessToken({ employeeNumber: this.employeeNumber, Type: "Transportation" }) //24/09/2024 
              .then(accessToken => {
                this.isProfessor = true;
                console.log('Professor Variabel 0 >>', this.isProfessor);
                console.log('Access Token: ' + accessToken);
                console.log('type', this.type);
                return getSalaryRange({ accessToken: accessToken, employeeNumber: this.employeeNumber, Type: "Transportation" }); //24/09/2024
              })
              .then(async salaryRange => {
                console.log('Salary Range: ' + salaryRange);
                this.salaryRange = Number(salaryRange);
                if (this.shortDistanceChecked === true && this.shortDistanceAmt != null) {
                  if (!this.initialSelection) {
                    this.initialSelection = true;
                    console.log('hi');
                    this.montlyDeduction = this.shortDistanceAmt;
                    this.facultyAmount = (this.montlyDeduction) * 12;
                    this.showMonthlyDeduction = true;
                    this.isProfessor = true;
                    console.log('Professor Variabel 1 >>', this.isProfessor);
                  }
                }
                else {
                  console.log('Salary Range123 ' + this.salaryRange);
                  this.initialSelection = false;
                  this.montlyDeduction = this.salaryRange;
                  console.log('montlyDeduction', this.montlyDeduction);
                  this.facultyAmount = (this.montlyDeduction) * 12;
                  console.log('facultyAmount', this.facultyAmount);
                  this.showMonthlyDeduction = true;
                  this.isProfessor = true;
                  console.log('Professor Variabel 2 >>', this.isProfessor);
                  console.log('pickupPointName-->> ', this.pickupPointName);
                  console.log('Data Type pickupPointName-->> ', typeof (this.pickupPointName));
                }


              })


          }
          else {
            this.isProfessor = false;
          }
        } else {
          this.selectedAmount = '';
          this.facultyAmount = '';
          this.initialSelection = false;
        }

      })
      .catch(error => {
        console.error(error);
      });
  }




  @wire(getFacultyDetails)
  getDetails({ data, error }) {
    if (data) {
      console.log('Faculty Details-->>', data);
      // Check if data is defined before accessing its properties
      if (data.Transport_Registrations__r && data.Transport_Registrations__r.length > 0) {
        // Access properties if they are defined
        this.registrationId = data.Transport_Registrations__r[0].Id;
        this.routeMasterNumber = data.Transport_Registrations__r[0].Route_Master__r.Name;
        this.pickupName = data.Transport_Registrations__r[0].Route_Pick_Up_Point__r.Name;
        this.AmountDeduction = data.Transport_Registrations__r[0].Amount_Paid__c;
        this.RoutePath = data.Transport_Registrations__r[0].Route_Master__r.RTR_Route_Path__c;
        this.RegistrationStatus = data.Transport_Registrations__r[0].Registration_Status__c;
        this.showFacultyDetails = true;
      } else {
        // Handle the case when data.Transport_Registrations__r is undefined or empty
        this.showFacultyDetails = false;
      }
    } else if (error) {
      console.log('Data is not present -->> ', error);
      // Handle the error case here
    }
  }
  get regStatus() {
    return `${this.RegistrationStatus === 'Cancelled' ? 'slds-text-color_error' : 'slds-text-color_success'}`
  }

  navigateTab() {
    console.log('calling navigation');
    this[NavigationMixin.Navigate]({
      type: 'standard__component',
      attributes: {
        componentName: '/payment-page'
      }
    });
  }
}