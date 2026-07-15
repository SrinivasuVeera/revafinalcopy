import { LightningElement, track, wire, api } from 'lwc';
import getAppointments from "@salesforce/apex/revaSWAppointmentController.getAppointments";
import cancelAppointment from '@salesforce/apex/revaSWAppointmentController.cancelAppointment';
import upcomingSessions from '@salesforce/apex/revaSWAppointmentController.upcomingSessions';
import getContactsForStudentPortal from '@salesforce/apex/revaSWAppointmentController.getContactsForStudentPortal';
import fetchCustomMetadataMap from '@salesforce/apex/rewaTimeSlot.fetchCustomMetadataMap';
import { NavigationMixin } from 'lightning/navigation';
import getCustomMetadataValue from '@salesforce/apex/revaSWCustomMetadataController.getAllCustomMetadata';
import getUserProfile from '@salesforce/apex/revaSWAppointmentController.getUserProfile';
import getExistingAppointments from '@salesforce/apex/revaSWAppointmentController.getExistingAppointments'; 
import checkNoManodaraAppointments from '@salesforce/apex/revaSWAppointmentController.checkManodaraAppointments';
import CreateNewRescheduleAppointment from '@salesforce/apex/revaSWAppointmentController.CreateNewAppointment';
import RescheduleAppointment from '@salesforce/apex/rewaCaseController.RescheduleAppointment';
import fetchEventDetails from '@salesforce/apex/rewaCaseController.fetchEventDetails';
import createAppointmentCaseEvent from '@salesforce/apex/rewaCaseController.createAppointmentCaseEvent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



const DELAY = 300;

export default class RevaSWcaseDetails extends  NavigationMixin(LightningElement) {
    @track showAppointmentDetails = false;
    @track showBookAppointmentButton = false; 
    @track hideSlot=false;
    @track showCheckboxConfirmation = false;
    @track showcustomcalendar=false;
    @track showParentCommponent= true;
    @track selectedContact = null;
    @track showSearchResults = true;
    @track isContactSelected = false;
    @track isSubmitButtonDisabled = true;
    @track isRescheduleButtonDisabled = true;
    @track professorProfile = false;
    filteredContactslabel=false;
    @track timeSlots = [];
    stringtimeSlot = [];
    rescheduleAppointment;
    selectContact;
    selectedAppointmentType;
    //selectedAppointmentTypeSelf = null;
    selectEndhours;
    selectEndminutes;
    selectStarthours;
    selectStartminutes;
    selectDay;
    selectMonth;
    selectYear;
    selectDate;
    @track showDatePickerModal = false;
    @track selectedAppointmentId;
    @track selectedDate = '';
    @track selectedTimeSlot;
    @track isTimeSlotComponentVisible = false;
    
   // @track tempShowSearchResults = true;
    monadharaAppDescription;
    @track radioOptions = [
        { label: 'Yes', value: 'yes' },
        { label: 'No', value: 'no' }
    ];
    @track appointments = [];
    appointmentToCancel;
    selectedRadioValue = 'no'; // Default value
    customMetadataValue;

    @track selectedAppointmentType;
   // @track selectedAppointmentTypeSelf;
    @track appointmentTypeOptions = [];

   

    @track isReferral = false;
    @track selectedContactId = '';
    @track contactOptions = [];
    @track searchTerm = '';
    @track filteredContacts = [];
    @track showAppointmentType = false;
    @track newSelectedContactEmail;
    @api selectedAppointment ;
    eligibleProfiles = ['Student Portal Profile','Student Profile'];

    
    updateSubmitButtonState() {
        const today = new Date().toISOString().split('T')[0];
        this.isSubmitButtonDisabled = this.selectedDate < today;
       // this.isSubmitButtonDisabled = true;
    }

    handleButtonClick(event) {
        this.hideSlot=true;
         fetchCustomMetadataMap()
        .then(result => {
            console.log("Succesfuly retrieved slots");
            // Process the result here
            const hourToCMDTMap = result;
            this.timeSlots = [];
            for (const [hourKey, cmdtRecords] of Object.entries(hourToCMDTMap)) {
                this.timeSlots.push({ hourKey, cmdtRecords });
            }
            if(this.selectedDate != null){
                this.timeSlots.forEach(slot => {
                    const stringtimeSlot5 =this.stringtimeSlot.join(',');
                    var bookedslots = stringtimeSlot5.split(',');
                   // slot.disabled = this.stringtimeSlot.includes(slot.hourKey);
                    slot.disabled = false;
                    console.log('slot.disabled initial'+slot.disabled);

                     //console.log('bookedslots is empty');
    
                    if (JSON.stringify(bookedslots) == '[""]') {
    // Handle case where bookedslots is an empty array
    console.log('bookedslots is empty');
    slot.disabled = (this.doTimeSlotsOverlap1(slot.hourKey, this.selectedDate) || slot.disabled);
    console.log('slot.disabled' + slot.disabled);
} else {
                    bookedslots.forEach(bookedSlot => {
                    slot.disabled = ((this.doTimeSlotsOverlap(bookedSlot, slot.hourKey, this.selectedDate))||slot.disabled);
                    console.log('slot.disabled'+slot.disabled);
                });
}
                });
            }
            console.log(JSON.stringify(this.timeSlots));
        })
        .catch(error => {
            // Handle any errors here
            console.error('Error fetching time slots:', error);
        });
    }

     // Function to check if two time slots overlap
     doTimeSlotsOverlap(slot1, slot2, selectedDate) {
        const [start1, end1] = slot1.split(' - ');
        const [start2, end2] = slot2.split(' - ');
        
        const convertToDateTime= (timeString) => {
            const [time, period] = timeString.split(' ');
        
            const [hours, minutes] = time.split(':').map(Number);
        
            let hours24 = hours;
            if (period.toLowerCase() === 'pm' && hours24 < 12) {
                hours24 += 12;
            } else if (period.toLowerCase() === 'am' && hours24 === 12) {
                hours24 = 0;
            }
        
            const date = new Date();
            date.setHours(hours24, minutes, 0, 0);
        
            return date;
        }
        const today = new Date();

const year = today.getFullYear();
const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are zero-based
const day = String(today.getDate()).padStart(2, '0');

const formattedDate = `${year}-${month}-${day}`;


    const currentDateTime = new Date();
    console.log("currentDateTime --->"+currentDateTime);
    
        const startDateTime1 = convertToDateTime(start1);
        const endDateTime1 = convertToDateTime(end1);
        const startDateTime2 = convertToDateTime(start2);
        const endDateTime2 = convertToDateTime(end2);
       
    
        if(formattedDate == selectedDate){
        return ((startDateTime1 < endDateTime2 && startDateTime1 >= startDateTime2)||(endDateTime1 <= endDateTime2 && endDateTime1 > startDateTime2)||(startDateTime1 <= startDateTime2 && endDateTime1 >= endDateTime2)||(startDateTime2 <= currentDateTime));
        }
    
        else {
            return ((startDateTime1 < endDateTime2 && startDateTime1 >= startDateTime2)||(endDateTime1 <= endDateTime2 && endDateTime1 > startDateTime2)||(startDateTime1 <= startDateTime2 && endDateTime1 >= endDateTime2));
            }
        
    }

     doTimeSlotsOverlap1( slot2, selectedDate) {
    //const [start1, end1] = slot1.split(' - ');
    const [start2, end2] = slot2.split(' - ');

    const convertToDateTime= (timeString) => {
        const [time, period] = timeString.split(' ');
    
        const [hours, minutes] = time.split(':').map(Number);
    
        let hours24 = hours;
        if (period.toLowerCase() === 'pm' && hours24 < 12) {
            hours24 += 12;
        } else if (period.toLowerCase() === 'am' && hours24 === 12) {
            hours24 = 0;
        }
    
        const date = new Date();
        date.setHours(hours24, minutes, 0, 0);
    
        return date;
    }

    const today = new Date();

const year = today.getFullYear();
const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are zero-based
const day = String(today.getDate()).padStart(2, '0');

const formattedDate = `${year}-${month}-${day}`;

console.log("today new---"+formattedDate);
//console.log("4 --->"+(formattedDate == currentDateTime));

    const currentDateTime = new Date();
    const startDateTime2 = convertToDateTime(start2);
    const endDateTime2 = convertToDateTime(end2);
 

    if(formattedDate == selectedDate){
    return ((startDateTime2 <= currentDateTime));
    }

    
}

    handleTileClick(event) {
        this.selectedTimeSlot = event.currentTarget.dataset.timeslot;
        this.showRewaBookEvent = true;
        this.showParentComponent = false;
        const selectedDate = this.selectedDate;
        const timeSlot = this.selectedTimeSlot; // Replace with your selected time slot
        const [startTime, endTime] = timeSlot.split(' - ');
        console.log('startTime--->'+startTime);
        var dateParts = selectedDate.split("-");
         this.selectYear = dateParts[0];
         this.selectMonth = dateParts[1];
         this.selectDay = dateParts[2];
        var starttimeParts = startTime.split(":");
         this.selectStarthours = parseInt(starttimeParts[0]);
         this.selectStartminutes = parseInt(starttimeParts[1]);
        if (startTime.includes("PM") && this.selectStarthours < 12) {
            this.selectStarthours += 12;
        }
        var endtimeParts = endTime.split(":");
         this.selectEndhours = parseInt(endtimeParts[0]);
         this.selectEndminutes = parseInt(endtimeParts[1]);
        if (endTime.includes("PM") && this.selectEndhours < 12) {
            this.selectEndhours += 12;
        }
        this.updateRescheduleButtonState();
    }
    createRescheduleAppointment(newApp){
     createAppointmentCaseEvent({
            severity: (newApp.severity) ? newApp.severity : null,
            
            modeOfCounselling: (newApp.modeOfCounselling) ? newApp.modeOfCounselling : null,
            preferredLanguage: (newApp.preferredLanguage) ? newApp.preferredLanguage : null,
            description: (newApp.description) ? newApp.description:null,
            selectedDate: this.selectedDate,
            selectYear: this.selectYear,
            selectMonth: this.selectMonth,
            selectDay: this.selectDay,
            selectStarthours: this.selectStarthours,
            selectStartminutes: this.selectStartminutes,
            selectEndhours: this.selectEndhours,
            selectEndminutes: this.selectEndminutes,
            selectContact: (newApp.contactId) ? newApp.contactId : null,
            selectedAppointmentType: (newApp.appointmentType) ? newApp.appointmentType : null,

            howAmIFeeling: (newApp.howAmIFeeling) ? newApp.howAmIFeeling : null,
            presentingProblem: (newApp.presentingProblem) ? newApp.presentingProblem : null,
            angry: (newApp.angry) ? newApp.angry : null,
            stressed: (newApp.stressed) ? newApp.stressed : null,
            sad: (newApp.sad) ? newApp.sad : null,
            lonely: (newApp.lonely) ? newApp.lonely : null,
            hurt: (newApp.hurt) ? newApp.hurt : null,
            confused: (newApp.confused) ? newApp.confused : null,
            frightened: (newApp.frightened) ? newApp.frightened : null,
            anxious: (newApp.anxious) ? newApp.anxious : null
            //checking for professor referral
           // selectedContactId: this.selectedContactId 
        })
        
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Rescheduled Successfully',
                    message: 'Your appointment was rescheduled successfully.',
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
                    message: 'An error occurred while rescheduling the appointment.',
                    variant: 'error'
                })
            );
        })
    }


    filteredAppointments = [];

    @wire(upcomingSessions)
    wiredUpcomingSessions({ error, data }) {
        if (data) {
            console.log('upcomingSessions>>>>>>',data);
            // Handle the returned data
            this.filteredAppointments = data;
        } else if (error) {
            // Handle the error
            console.error('Error fetching appointments:', error);
        }
    }


        @wire (fetchEventDetails,{ selectedDate: '$selectedDate' })
    
    fetchEventDetails({data,error}){
        if(data){
            console.log('>>>>>>',data);
            const stringtimeSlots = []; // Initialize as an empty array

            data.forEach(event => {
                const startDateTime = event.StartDateTime;
                const endDateTime = event.EndDateTime;

                const formatTime = (dateTime) => {
                    const options = { hour: 'numeric',minute: 'numeric', hour12: true };
                    return new Intl.DateTimeFormat('en-US', options).format(new Date(dateTime));
                };
                
                // Create time slot strings
                const startTimeSlot = formatTime(startDateTime);
                const endTimeSlot = formatTime(endDateTime);
                
                // Split the time into hours and AM/PM
                const startTimeParts = startTimeSlot.split(' ');
                const endTimeParts = endTimeSlot.split(' ');
                
                // Remove the minutes from the hours
                const formattedStartTime = startTimeParts[0] + ' ' + startTimeParts[1];
                const formattedEndTime = endTimeParts[0] + ' ' + endTimeParts[1];
                
                // Create a string for the time slot
                stringtimeSlots.push(`${formattedStartTime} - ${formattedEndTime}`); // Push into the array    
                this.stringtimeSlot = stringtimeSlots;
                console.log('stringtimeslot', this.stringtimeSlot);            
        });
    }
        else if(error){
            console.log(error);
        }
    }

    handleChildEvent(event) {
    this.messageReceived = event.detail;
  }


  handlegrandChildEvent(event) {
    this.messageReceived = event.detail;
  }


    @wire(getCustomMetadataValue)
    wiredCustomMetadataValue({ error, data }) {
        if (data) {
            this.customMetadataValue = data;
            this.monadharaAppDescription=data[0].RSW_Manodhaara_App_Info__c;
            console.log('Custom Metadata Data:', data);
        } else if (error) {
            console.error('Error fetching custom metadata value', error);
        }
    }
    
    
    loadContacts() {
        getContactsForStudentPortal({ searchString: this.searchTerm })
            .then(result => {
                console.log(JSON.stringify(result));
                this.filteredContacts = result.map(contact => ({ label: contact.Name, value: contact.Id, email: contact.Email, SRN: contact.SRN_Number__c, ApplicationNumber: contact.Application_Number__c}));
                console.log('this.filteredContacts ' + JSON.stringify(this.filteredContacts));
                this.filteredContactslabel = true;
            })
            .catch(error => {
                console.error('Error fetching contacts:', error);
            });
    }
    


    connectedCallback() {
        this.loadAppointments();
        //profile restriction
        getUserProfile()
            .then(result => {
                console.error('result---:', result);
                 // Determine the user's profile
            if ((result == 'System Administrator')||(result == 'Manodhaara Counselor')) {
                this.showAppointmentType = true;
                this.appointmentTypeOptions = [
                    { label: 'Self', value: 'Self' },
                    { label: 'Referral', value: 'Referral' }
                ];
            } else if (!this.eligibleProfiles.includes(result)) {
                this.professorProfile = true;
                console.log('professorProfile',this.professorProfile);
                this.showAppointmentType = true;
                this.appointmentTypeOptions = [
                    { label: 'Self', value: 'Self' },
                    { label: 'Referral', value: 'Referral' }
                ];
            }else if ((result == 'Student Portal Profile')||(result == 'Student Profile')) {
                this.showAppointmentType = false;
                this.selectedAppointmentType = 'Self';
               // this.selectedAppointmentTypeSelf = true;
                this.appointmentTypeOptions = [
                    { label: 'Self', value: 'Self' }
                ];
                console.log(this.selectedAppointmentType); // Move the log inside the 'Student Portal Profile' block

                checkNoManodaraAppointments()
                .then(result => {
                    if (result) {
                        console.log('inside loop 1');
                        this.showBookAppointmentButton = false; // hide book appointment button for "Self"
                    } else {
                        console.log('inside loop 2');
                        this.showBookAppointmentButton = true; // show book appointment button for "Self"
                    }
                })
                .catch(error => {
                    console.error('Error checking for Manodara appointments:', error);
                });
                
            }
                // Set showAppointmentType based on the result
               // this.showAppointmentType = result;
            })
            .catch(error => {
                console.error('Error fetching user profile:', error);
            });

    }
    

    loadAppointments() {
        let anyScheduled = false; // Flag to track if any appointment is scheduled
        getAppointments()
            .then(result => {
                this.appointments = result.map(appointment => {
                    if ((appointment.appointmentStatus === 'Scheduled')) {
                        anyScheduled = true; // Mark the flag if any appointment is scheduled
                    }
                    return {
                        ...appointment,
                        showCancelButton: this.shouldShowCancelButton(appointment.appointmentStatus,   
                                                                      appointment.appointmentDate,   appointment.timeSlot),
                        showViewButton: this.shouldShowViewButton(appointment.appointmentStatus, 
                                                                  appointment.appointmentDate, appointment.timeSlot),
                        showRescheduleButton: this.shouldShowRescheduleButton(appointment.appointmentStatus, 
                                                                    appointment.appointmentDate, appointment.timeSlot)
                    };
                });
    
    
                // If user is a professor, show book appointment button if appointment type is referral
                if (this.showAppointmentType && this.selectedAppointmentType === 'Referral' && this.selectedContact !== null) {
                    this.showBookAppointmentButton = true;
                    console.log('changed');
                }

            })
            .catch(error => {
                console.error('Appointment fetch error:', error);
            });
    }
    
    
    
    

    shouldShowCancelButton(appointmentStatus, appointmentDate, timeSlot) {
        const currentTime = new Date();
        const appointmentDateTime = new Date(appointmentDate + ' ' + timeSlot.split('-')[0]); 
        return appointmentStatus === 'Scheduled' && currentTime < appointmentDateTime;
       // return appointmentStatus !== 'Cancelled' && appointmentStatus !== 'Completed' && currentTime < appointmentDateTime;
    }
    
    shouldShowViewButton(appointmentStatus, appointmentDate, timeSlot) {
        const currentTime = new Date();
        const appointmentDateTime = new Date(appointmentDate + ' ' + timeSlot.split('-')[0]);
        return (appointmentStatus === 'Initiated' || appointmentStatus === 'Completed' || appointmentStatus === 'Cancelled' || appointmentStatus === 'Scheduled')     
                                                    ||      currentTime >= appointmentDateTime;
       
    }

    shouldShowRescheduleButton(appointmentStatus, appointmentDate, timeSlot) {
        const currentTime = new Date();
        const appointmentDateTime = new Date(appointmentDate + ' ' + timeSlot.split('-')[0]); 
        return appointmentStatus === 'Scheduled' && currentTime < appointmentDateTime;
       // return appointmentStatus !== 'Cancelled' && appointmentStatus !== 'Completed' && currentTime < appointmentDateTime;
    }

    handleCancelAppointment(event) {
        const appointmentId = event.target.dataset.id;
        this.appointmentToCancel = this.appointments.find(appointment => appointment.appointmentId === appointmentId);
        this.showCheckboxConfirmation = true;
    }


    handleRescheduleAppointment(event) {
                //this.appointmentToCancel = this.appointments.find(appointment => appointment.appointmentId === appointmentId);

        this.selectedAppointmentId = event.target.dataset.id;
        this.minDate = new Date().toISOString().split('T')[0];
        this.showDatePickerModal = true;
        this.showParentCommponent = false;
    }

    handleDateChange(event) {
        const selectedDate = event.target.value;
        this.stringtimeSlot = [];
        this.hideSlot=false;
        // Validate that the selected date is after today
      //  const currentDate = new Date().toISOString().split('T')[0];
        this.selectedDate = selectedDate;
        console.log(this.selectedDate);
        this.updateSubmitButtonState();
       // this.showTimeSlotComponent();
    }
    updateRescheduleButtonState() {
        this.isRescheduleButtonDisabled = false;
    }
    async handleRescheduleConfirm() {
        console.log('Confirm Reschedule');
        await this.cancelAppointment(this.selectedAppointmentId, 'Rescheduled');
            // Remove the cancelled appointment from the list
           await CreateNewRescheduleAppointment({appointmentId: this.selectedAppointmentId})
        .then(result => {
            console.log('RESULT    '+JSON.stringify(result));
            this.createRescheduleAppointment(result);
            })
        .catch(error => JSON.stringify(error))
            const updatedAppointments = this.appointments.filter(appointment => appointment.appointmentId !== 
                 this.appointmentToCancel.appointmentId);
            this.appointments = [...updatedAppointments];
           
        
      
    }    

    bookNewAppointment(params) {
        // Call the Apex method to create a new appointment record
        // Example: replace 'yourApexMethod' with your actual Apex method name
        return RescheduleEvent(params)
            .then(result => {
                // Handle the result as needed
                console.log('New appointment booked successfully:', result);
            })
            .catch(error => {
                // Handle the error
                console.error('Error booking new appointment:', error);
                throw error; // Propagate the error to the next catch block
            });
    }

    handleRescheduleCancel() {
        location.reload();
        this.showParentCommponent = true;
        // Close the modal without taking any action
        this.showDatePickerModal = false;
        this.isTimeSlotComponentVisible = false;
        
    }

    handleRadioChange(event) {
        this.selectedRadioValue = event.detail.value;
    }

    handleCancelClick() {
        this.showCheckboxConfirmation = false;

        // Enable the radio options
        this.radioOptions = this.radioOptions.map(option => ({
            ...option,
            disabled: false
        }));
        location.reload();
    }

    @track reason = '';

    handleReasonChange(event) {
        this.reason = event.target.value;
    }

    handleConfirmClick() {
        if (this.selectedRadioValue === 'yes') {
           // this.updateCancellationReason(this.appointmentToCancel.appointmentId, this.reason);
    
             // Perform the cancel operation
            this.cancelAppointment(this.appointmentToCancel.appointmentId ,this.reason);

            // Remove the cancelled appointment from the list
            const updatedAppointments = this.appointments.filter(appointment => appointment.appointmentId !== 
                 this.appointmentToCancel.appointmentId);
            this.appointments = [...updatedAppointments];
     }

        this.appointmentToCancel = null;
        this.selectedRadioValue = 'no';
        this.showCheckboxConfirmation = false;

        // Enable the radio options
        this.radioOptions = this.radioOptions.map(option => ({
            ...option,
            disabled: false
        }));
    }

    get isSelectedRadioYes() {
        return this.selectedRadioValue === 'yes';
    }
    
    get isConfirmButtonDisabled() {
        // Disable the Confirm button if selectedRadioValue is not 'Yes'
        return !this.isSelectedRadioYes;
    }
  
    async cancelAppointment(appointmentId , cancellationReason) {
        this.showParentCommponent = true;
        this.showDatePickerModal = false;
    
        await cancelAppointment({ appointmentId: appointmentId, cancellationReason: cancellationReason })
            .then(result => {
                // Handle success or refresh the data
                console.log('Cancellation result:',JSON.stringify(result));
            })
            .catch(error => {
                // Handle error
                console.error('Cancellation error:', error);
            });
    }
    
    handleViewAppointment(event) {
        const appointmentId = event.target.dataset.id;
        this.selectedAppointment = this.appointments.find(appointment => appointment.appointmentId === appointmentId);
        this.showAppointmentDetails = true;
        console.log('selectedAppointment',selectedAppointment);
    }
    
    handleCloseAppointmentDetails(event) {
        this.showAppointmentDetails = false;
    }

    
    handleAppointmentTypeChange(event) {
        this.selectedAppointmentType = event.detail.value;
        this.searchTerm = '';
        
        if (this.selectedAppointmentType === 'Referral') {
            this.loadContactsForStudentPortal();
            this.isReferral = true; // Show the search box for Referral
            console.log('this.selectedContactId --loop1 --'+ this.selectedContactId);
           // this.showBookAppointmentButton = true; // Show book appointment button for professor
        } else if (this.selectedAppointmentType === 'Self'){
            checkNoManodaraAppointments()
                .then(result => {
                    if (result) {
                        console.log('inside loop 1');
                        this.showBookAppointmentButton = false; // hide book appointment button for "Self"
                    } else {
                        console.log('inside loop 2');
                        this.showBookAppointmentButton = true; // show book appointment button for "Self"
                    }
                })
                .catch(error => {
                    console.error('Error checking for Manodara appointments:', error);
                });
    
            this.isReferral = false; // Hide the search box for Self
        }else{
            this.showBookAppointmentButton = false;
        }
    }
    

    
    handleSearch(event) {
        
        const searchString = event.target.value;
       // this.searchTerm = searchString;
    
        // Only perform the search if appointment type is referral
        if (this.selectedAppointmentType === 'Referral') {
            window.clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(() => {
            //this.searchContactsByName(searchString);
            this.searchTerm = searchString;
            this.loadContacts();
            }, DELAY);
        }
    }
   

     //**added for showing message for professor if alreaady exsting appointment is there13102023**/
    checkForExistingAppointments(contactEmail) {
        getExistingAppointments({ contactEmail })
            .then(result => {
                
                if (result && result.length > 0) {
                    const existingAppointmentsMessage = 'This student already has existing appointments with "Initiated" or "Scheduled" status. Please create a new appointment when the current appointments are completed.';
                    alert(existingAppointmentsMessage);
                    this.showBookAppointmentButton = false;
                } else {
                    this.createNewAppointment(contactEmail);
                }
            })
            .catch(error => {
                console.error('Error checking for existing appointments:', error);
            });
    }

   
    @track selectedContactDetails = false;

    handleContactSelect(event) {
        this.selectedContactId = event.currentTarget.dataset.id;
        const selectedContact = this.filteredContacts.find(contact => contact.value === this.selectedContactId);
        if (selectedContact) {
            this.searchTerm = selectedContact.label;
            const selectedContactEmail = selectedContact.email;
            this.checkForExistingAppointments(selectedContactEmail);
            this.filteredContacts = [];
            this.filteredContactslabel = false;

            this.selectedContactDetails = {
                label: selectedContact.label,
                email: selectedContact.email,
                SRN: selectedContact.SRN,
                ApplicationNumber: selectedContact.ApplicationNumber
                // Add other properties as needed
            };
            console.log('this.selectedContactDetails====>: ' + JSON.stringify(this.selectedContactDetails));
        }
                                if (this.showAppointmentType && this.selectedAppointmentType === 'Referral' && this.selectedContactId !== null) {
                                    this.showBookAppointmentButton = true;
                                    console.log('changed');
                                }
                               
    }
    
   
    
    loadContactsForStudentPortal() {
        getContactsForStudentPortal()
            .then(result => {
                this.contactOptions = result.map(contact => ({ label: contact.Name, value: contact.Id, SRN: SRN_Number__c }));
                this.filteredContacts = [...this.contactOptions]; // Initialize filtered contacts with all contacts
                this.isReferral = true;
            })
            .catch(error => {
                console.error('Error fetching contacts:', error);
            });
    }

    handleAppointmentTypeSelection(event) {
        this.selectedType = event.detail.value;
    }


   get selectedAppointmentTypeSelf() {
    return this.selectedAppointment && this.selectedAppointment.appointmentType == 'Self';
}
    
    get isAppointmentCompleted() {
        return this.selectedAppointment && this.selectedAppointment.appointmentStatus === 'Completed';
    }

    get isAppointmentInitiated() {
        return this.selectedAppointment && this.selectedAppointment.appointmentStatus === 'Initiated';
    }

    //15/02
    navigateToCommunityPage() {
       // this.showCalendarEvent = false;
     this.showcustomcalendar=true;
     this.showParentCommponent=false;

    }

}