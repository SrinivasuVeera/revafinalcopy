import { LightningElement, track, wire, api } from 'lwc';
import saveGuestHouseRequest from '@salesforce/apex/RevaGuestHouseController.saveGuestHouseRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getGuestCoordinator  from '@salesforce/apex/RevaGuestHouseController.getGuestCoordinator';
import attachFileToGuestHouseRequest from '@salesforce/apex/RevaGuestHouseController.attachFileToGuestHouseRequest';
import { NavigationMixin } from 'lightning/navigation';
import getLoggedInUserProfile from '@salesforce/apex/RevaGuestHouseController.getLoggedInUserProfile';
import roomAvailability  from '@salesforce/apex/RevaGuestHouseController.RoomAvailibility';
import getUsersBasedOnProfile  from '@salesforce/apex/RevaGuestHouseController.getUsersBasedOnProfile';
import getCitizenshipPicklistValues from '@salesforce/apex/RevaGuestHouseController.getCitizenshipPicklistValues';
import getRoomTypePicklistValues from '@salesforce/apex/RevaGuestHouseController.getRoomTypePicklistValues';
import getSharingTypePicklistValues from '@salesforce/apex/RevaGuestHouseController.getSharingTypePicklistValues';
import getGuestTypePicklistValues from '@salesforce/apex/RevaGuestHouseController.getGuestTypePicklistValues';
import searchContacts from '@salesforce/apex/RevaGuestHouseController.searchContacts';
import getRoomPicklistValues from '@salesforce/apex/RevaGuestHouseController.getRoomPicklistValues';
import getDistinctSchoolNames from '@salesforce/apex/RevaGuestHouseController.getDistinctSchoolNames';
let guestIdCounter = 0;

export default class guestHouseBookingByGuestHouseManager extends  NavigationMixin(LightningElement)  {
    @track roomType;
    @track guestType;
    @track guestDescription;
    @track purposeOfVisit;
    @track age;
    @track gender;
    @track guestCoordinator;
    @track showDescription = false;
    @track Description;
    @track BookingName;
    @track searchKey = '';
    @track searchcon ='';
    @track showSearchResults = false;
    @track professors = [];
    @track filteredProfessors = [];
    @track selectedProfessorName = '';
    @track select;
    @track fileName;
    @track fileUploaded = false;
    @track saving = false; 
    file;
    @track bookingId;
    @track sharingType;
    @track startDate;
    @track endDate;
    @track showRoomType;
    @track showSharingType;
    @track guestType;
    @track checkIn = false;
    showNewRequestForm = false;
    @track isGuestHouseManager = false;
    @track isStuAndGuestManager = false;
    @track purposeOfVisit = ''; 
    @track selectedPurposeTypes = []; 
    @track GuestName;
    @track noOfGuests;
    @track noOfDays;
    @track coOrdinatorMobile;
    @track coOrdinatorEmail;
    @track visaDate;
    @track PrivateVisit;
    @track PersonalVisit;
    @track visaNumber;
    @track coOrdinatorName;
    @track deptName;
    @track passportNumber;
    @track roomsNumber;
    @track phoneNumber;
    @track email;
    @track address;
    @track citizenshipName;
    @track nonIndian = false;
    @track userName;
    @track guestUserName;
    @track profileName;
    @track citizenshipOptions = [];
    @track roomOptions = [];
    @track shareTypeOptions = [];
    @track GuestTypeOptions = [];
    @track roomsTypeOptions = [];
    @track showDeptSchoolField = false;
    @track showStudentStaffField = false;
    @track isCitizen = false;
    @track selectedContactId = '';
    @track selectedCoOrdinatorId = '';
    @track GuestDescription;
    schoolOptions = [];
    @api programType;
    @api currentProgramName;
    @track showManualEntry =false;
    @track guests = 1;
    @track disableSaveButton = false;
    @track guestList = [
         { id: guestIdCounter++, guestname: '', age: '', gender: '' }
      
    ];
    @track emailError = '';
    @track isCoOrdinator = true;
    @track isCoOrdinatorDisabled = false;
    
    // @track guestList = [
    //     { age: '', gender: '' }
    // ];
    
    addGuest() {
        this.guestList.push({id: guestIdCounter++, guestname: '',age: '', gender: '' });
        this.guests = this.guests + 1;
    }

    removeGuest(event) {
       const id = event.target.dataset.id;
    const index = this.guestList.findIndex(guest => guest.id == id);
    if (index !== -1 && this.guestList.length > 1) {
        this.guestList.splice(index, 1);
        this.guests = this.guests - 1;
    }
     
    }

    @wire(getCitizenshipPicklistValues)
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.citizenshipOptions = data.map(value => {
                return { label: value, value: value };
            });
        } else if (error) {
            // Handle error
            console.error(error);
        }
    }

    
    @wire(getRoomTypePicklistValues)
    wiredRoomTypeValues({ error, data }) {
        if (data) {
            this.roomOptions = data.map(value => {
                return { label: value, value: value };
            });
        } else if (error) {
            // Handle error
            console.error(error);
        }
    }

    
    @wire(getSharingTypePicklistValues)
    wiredSharingTypeValues({ error, data }) {
        if (data) {
            this.shareTypeOptions = data.map(value => {
                return { label: value, value: value };
            });
        } else if (error) {
            // Handle error
            console.error(error);
        }
    }

   
   /* @wire(getGuestTypePicklistValues)
    wiredGuestTypeValues({ error, data }) {
        if (data) {
            this.GuestTypeOptions = data.map(value => {
                return { label: value, value: value };
            });
        } else if (error) {
            // Handle error
            console.error(error);
        }
    } */
    @wire(getRoomPicklistValues)
    wiredRoomsValues({ error, data }) {
        if (data) {
            this.roomsTypeOptions = data.map(value => {
                return { label: value, value: value };
            });
        } else if (error) {
            // Handle error
            console.error(error);
        }
    }

    genderOptions = [
        { label: 'Male', value: 'Male' },
        { label: 'Female', value: 'Female' },
        { label: 'Others', value: 'Others' }
    ];

    @wire(getDistinctSchoolNames)
    wiredSchoolNames({ error, data }) {
        if (data) {
            this.schoolOptions = data.map(schoolName => {
                return { label: schoolName, value: schoolName };
            });
        } else if (error) {
            // Handle error
            console.error('Error retrieving school names:', error);
        }
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value;
        if (this.searchKey.length >= 2) {
            searchContacts({ searchKey: this.searchKey })
                .then(result => {
                    this.contacts = result;
                   console.log("this.contacts", this.contacts);
                })
                .catch(error => {
                    this.contacts = [];
                    console.error('Error occurred while fetching contacts:', error);
                });
        } else {
            this.contacts = [];
        }
    }
    
    handleSearchcontact(event) {
        this.searchcon = event.target.value;
        console.log('Hello:'+this.searchcon);
        if (this.searchcon.length >= 2) {
            getGuestCoordinator({ searchcon: this.searchcon })
                .then(result => {
                    this.contacts = result;
                   console.log("this.contacts", this.contacts);
                })
                .catch(error => {
                    this.contacts = [];
                    console.error('Error occurred while fetching contacts:', error);
                });
        } else {
            this.contacts = [];
        }
    }
    
    handleContactSelect(event) {
        this.selectedContactId = event.target.dataset.id;
        this.selectedContactName = event.target.dataset.name;
        this.searchKey = this.selectedContactName;
        this.contacts = []; // Clear search results

       
    }
    handlecoordinatorSelect(event) {
        this.selectedCoOrdinatorId = event.target.dataset.id;
        this.selectedCoordinatorName = event.target.dataset.name;
        console.log(" this.selectedCoordinatorName", this.selectedCoordinatorName);
        this.searchcon = this.selectedCoordinatorName;
        this.contacts = []; 
        console.log('Selected Coordinator ID:', this.selectedCoOrdinatorId);
        console.log('KKKK:'+ this.selectedCoOrdinatorId);
       // alert('ID'+ this.selectedCoordinatorId);
      }

      

    handleCitizenshipChange(event) {
        this.citizenshipName = event.target.value; 
        console.log("Selected Citizenship:", this.citizenshipName);
        if(this.citizenshipName != 'India'){
            this.nonIndian = true;
         }
         else{
            this.nonIndian = false;
         }
    }


    handleGuestNameChange(event) {
        const index = event.target.dataset.id;
        this.guestList[index].guestname = event.target.value;
    }

    handleGuestAgeChange(event) {
        const index = event.target.dataset.id;
       // this.guestList[index].age = event.target.value;

         let age = parseInt(event.target.value, 10);

    // Validation: Age should be between 1 and 100
    if (age < 1 || age > 100 || isNaN(age)) {
        // Handle invalid age input (show error message, reset value, etc.)
        this.showToast('Error', 'Please enter valid age ', 'error');
        this.guestList[index].age = '';
    } else {
        this.guestList[index].age = age;
    }
    }

    handleGuestGenderChange(event) {
        const index = event.target.dataset.id;
        this.guestList[index].gender = event.target.value;
    }


    
    handleGuestTypeChange(event) {
        this.guestType = event.target.value;
        this.roomType = null;
        this.sharingType = null;
        this.isCitizen = true;
        if (event.target.value === 'Others') {
            this.guestType = event.target.value;
            this.showDescription = true;
            this.showRoomType = true;
            this.showSharingType = true;
            this.roomOptions=[
                { label: 'None', value: 'None' },
                { label: 'A/C', value: 'A/C' },
               // { label: 'Non A/C', value: 'Non A/C' }
            ];
            this.shareTypeOptions = [
                { label: 'None', value: 'None' },
                { label: 'Two Sharing', value: 'Two Sharing' },
                { label: 'Three Sharing', value: 'Three Sharing' },
               // { label: 'Four Sharing', value: 'Four Sharing' }
            ];
             this.roomType='None';
             this.sharingType = 'None'; 
            console.log('Guest Type:', this.guestType);
            this.showDeptSchoolField = false;
            this.showStudentStaffField = true;
        } 
       else if (event.target.value === 'University Guest') {
            this.showRoomType = true;
            this.showDescription = false;
            this.showSharingType = true;
            this.roomOptions = [
                { label: 'None', value: 'None' },
                { label: 'A/C', value: 'A/C' }
            ];
          //  this.roomType = 'A/C';
            this.shareTypeOptions = [
                { label: 'None', value: 'None' },
                { label: 'King Bed', value: 'King Bed' },
                { label: 'Queen Bed', value: 'Queen Bed' },
                { label: 'Two Sharing', value: 'Two Sharing' },
                { label: 'Three Sharing', value: 'Three Sharing' }
            ];
            this.roomType = 'None';
            this.sharingType = 'None';
            this.showDeptSchoolField = true;
            this.showStudentStaffField = false;
        } else if(event.target.value === 'Department Guest'){
            this.guestType = event.target.value;
            this.showDescription = false;
            this.showRoomType = true;
            this.showSharingType = true;
            this.roomOptions = [
                { label: 'None', value: 'None' },
                { label: 'A/C', value: 'A/C' },
                { label: 'Non A/C', value: 'Non A/C' }
            ];
            this.shareTypeOptions = [
                { label: 'None', value: 'None' },
                { label: 'Two Sharing', value: 'Two Sharing' },
                { label: 'Three Sharing', value: 'Three Sharing' },
                { label: 'Four Sharing', value: 'Four Sharing' }
            ];
            this.roomType = 'None';
            this.sharingType = 'None';
            this.showDeptSchoolField = true;
            this.showStudentStaffField = false;
        } 
        else {
            this.guestType = event.target.value;
            this.showDescription = false;
            this.showRoomType = true;
            this.showSharingType = true;
            this.roomOptions = [
                { label: 'None', value: 'None' },
                { label: 'A/C', value: 'A/C' },
                //{ label: 'Non A/C', value: 'Non A/C' }
            ];
            this.shareTypeOptions = [
                { label: 'None', value: 'None' },
                { label: 'Two Sharing', value: 'Two Sharing' },
                { label: 'Three Sharing', value: 'Three Sharing' },
                { label: 'Four Sharing', value: 'Four Sharing' }
            ];
            this.roomType = 'None';
            this.sharingType = 'None';
            this.showDeptSchoolField = false;
            this.showStudentStaffField = true;
        }
        
    }


    handleFileChange(event) {
        if (event.target.files.length > 0) {
            this.file = event.target.files[0];
        this.fileUploaded = true;
    console.log('File Uploaded:', this.fileUploaded);
        }
        this.fileName = this.file.name;
        console.log("this", this.file);
    }

    handleGuestDescription(event){
        this.GuestDescription = event.target.value;
        console.log(" this.GuestDescription", this.GuestDescription);
    }

    handleCancel() {
        this.fileUploaded = false;
        console.log('File Uploaded:', this.fileUploaded);
        this.file = null;
        this.fileName = null;
        
    }

    @wire(getUsersBasedOnProfile)
    wiredgetUsersBasedOnProfile({ error, data }) {
        if (data) {
            this.userName = data;
           console.log('Hello:'+  this.userName);
            
        } else if (error) {
            this.error = error;
            this.guestHouseRequest = undefined;
        }
    }


validateForm() {
    // Validate main form fields
    if (!this.guestType || !this.noOfGuests || !this.roomType || !this.startDate || !this.phoneNumber || !this.purposeOfVisit || !this.roomsNumber || !this.sharingType || !this.endDate) {
        this.dispatchEvent(
            new ShowToastEvent({
                message: 'Please fill in all required fields.',
                variant: 'error',
            })
        );
        this.disableSaveButton = true;
        return false; // Stop execution if validation fails
    }
    if ((this.showManualEntry == true && !this.coOrdinatorName ) ||( this.showManualEntry == false &&  !this.searchcon && (this.guestType == 'University Guest' ||  this.guestType == 'Department Guest'))) {
        this.dispatchEvent(
            new ShowToastEvent({
                message: 'Please fill Co-Ordinator detailes.',
                variant: 'error',
            })
        );
        this.disableSaveButton = true;
        return false; // Stop execution if validation fails
    }

    // Validate guest fields
    for (let i = 0; i < this.guestList.length; i++) {
        let guest = this.guestList[i];
       console.log('guest==> ',guest);
        if (!guest.guestname || !guest.age || !guest.gender) {
            console.log('guestdetails==> ', guest);
            this.dispatchEvent(
                new ShowToastEvent({
                    message: `Please fill in all required guest details for Guest .`,
                    variant: 'error',
                })
            );
            return false; // Stop execution if validation fails
        }
        this.disableSaveButton = true;
    }

    return true; // Proceed if all validations pass
}



    handleSave() {
        this.disableSaveButton = true;
        console.log('this.guests:'+this.guests);
   if(this.guests !==  Number(this.noOfGuests)){
      
        this.showToast('Error', 'Please Enter ' +this.noOfGuests+ ' Guests Details', 'error');
        this.disableSaveButton = false;
        return;
        }
    if (!this.file) {
        this.showToast('Error', 'Please select a file.', 'error');
        this.disableSaveButton = false;
        return;
    }
    if (this.emailError) {
        this.showToast('Error', 'Please enter a valid email address.', 'error');
        this.disableSaveButton = false;
        return;
    }

    let isValid = true;
   /* this.guestList.forEach(guest => {
        if (!/^\d+$/.test(guest.age) || guest.age.length > 3) {
            isValid = false;
            this.ageError = `Guest ${guest.guestname}'s age must be a valid number `;
        }
    });*/

    if (!isValid) {
        this.showToast('Error', this.ageError, 'error');
        this.disableSaveButton = false;
        return;
    }

    if (this.validateForm()) {
        this.saving = true;

        roomAvailability({
            occupancy: this.sharingType,
            roomType: this.roomType,
            startDate: this.startDate,
            endDate: this.endDate,
            roomsNumber: this.roomsNumber
        })
        .then(isAvailable => {
            if (isAvailable) {
                console.log("isAvailable", isAvailable);
                this.saveGuestHouseRequest();
            } else {
                this.showToast('Error', 'Room is not available for the selected time range.', 'error');
                this.disableSaveButton = false;
                this.saving = false;
            }
        })
        .catch(error => {
            this.showToast('Error', 'An error occurred while checking room availability.', 'error');
            console.error('Error occurred while checking room availability:', error);
            this.saving = false;
            this.disableSaveButton = false;
        });
    }
    else {
        this.disableSaveButton = false;
    }
}


    saveGuestHouseRequest() {
        const fileReader = new FileReader();
        fileReader.onloadend = () => {
            const base64Data = fileReader.result.split(',')[1];
            const fileName = this.file.name; 
            console.log('selectedcorodinator432'+this.selectedCoOrdinatorId);
    saveGuestHouseRequest({
        guestType: this.guestType,
        guestUserName:this.guestUserName,
        selectedContactId: this.selectedContactId || null,
        selectedCoordinatorId: this.selectedCoOrdinatorId || null,
        deptName: this.deptName,      
        noOfGuests: this.noOfGuests,
        citizenshipName: this.citizenshipName,
        guestDescription: this.GuestDescription,
        passportNumber: this.passportNumber,
        address: this.address,
        email: this.email,
        phoneNumber: this.phoneNumber,
        roomsNumber : this.roomsNumber,
        roomType: this.roomType,
        sharingType: this.sharingType,
        startDate: this.startDate,
        endDate: this.endDate,
        PrivateVisit:this.PrivateVisit || false,
        PersonalVisit: this.PersonalVisit || false,
        purposeOfVisit: this.purposeOfVisit,
        coOrdinatorName: this.coOrdinatorName,
        coOrdinatorMobile: this.coOrdinatorMobile,
        coOrdinatorEmail: this.coOrdinatorEmail,
        visaNumber: this.visaNumber,
        visaDate:this.visaDate || null,
        guestList: this.guestList
      //  remarks: this.Remarks
    }) 
    .then(result => {
        this.bookingId = result.Id;
        console.log("result.Id",result.Id)
        this.autoNumber = result.AutoNumber;
        console.log("this.autoNumber", this.autoNumber);
        attachFileToGuestHouseRequest({
            guestHouseRequestId: result.Id,
            fileName: fileName,
            base64Data: base64Data
        })  
        .then(() => {
            this.showToast('Success', 'Guest house request saved successfully.', 'success');
             return getLoggedInUserProfile();
           
             //   this.navigateToRecordPage(result.Id);  
        })
        .then((userProfile) => {
            console.log('User Profile:', userProfile);
            console.log("this.guest", this.guestType);
            if (userProfile === 'Student Profile' || userProfile === 'Student Portal Profile') {
                this.redirectToStudentFeePaymentComponent();
            }else if (userProfile  === 'Non Teaching Profile' && this.guestType === 'Parents') {
                console.log(userProfile);
                console.log(this.guestType);
                location.reload()
              //  this.redirectToNonTeachingFeePaymentComponent();
            }  else if (userProfile  === 'Non Teaching Profile' && this.guestType !== 'Parents') {
               // redirectToBookingComponent();
               location.reload()
            }
            else {
                this.navigateToRecordPage(result.Id); 
             //   console.error('Unknown user profile:', userProfile);
            }   this.showNewRequestForm = false;
        })
        .catch(error => {
            this.showToast('An error occurred while attaching the file.', 'error');
            console.error('Error occurred while attaching file:', error);
        })
        .finally(() => {
            this.saving = false; // Finish saving operation
            // location.reload();
        });
    })
  
};



fileReader.readAsDataURL(this.file);
}

    redirectToStudentFeePaymentComponent() {
        window.location.href = '/StudentPortal/s/student-fee';
    }

    redirectToBookingComponent() {
        window.location.href = '/NonTeachingStaff/s/guest-house-booking';
    }

    redirectToNonTeachingFeePaymentComponent(){
        console.log("wwwwwwwwwww");
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/NonTeachingStaff/s/non-teaching-staff-fee'
            }
        });
    }

    navigateToRecordPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Reva_Guest_House_Booking__c', 
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    handleAddress(event){
        this.address = event.target.value;
        console.log(" this.address", this.address);
    }
    handleEmail(event){
        this.email = event.target.value;
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(this.email)) {
            this.emailError = 'Invalid email format';
        } else {
            this.emailError = '';
        }
    }
    handlePhoneNumber(event){
        this.phoneNumber = event.target.value;
    }
    
    handleUsername(event){
        this.guestUserName = event.target.value;
    }
    
    handledeptName(event){
        this.deptName = event.target.value;
    }

    handlenoOfGuests(event){
        this.noOfGuests = event.target.value;
        console.log('this.noOfGuests'+this.noOfGuests);
    }

    handlepassportNumber(event){
        this.passportNumber = event.target.value;
    }
    handleRoomsChange(event){
        this.roomsNumber = event.target.value;
    }
    handleRoomTypeChange(event){
        this.roomType = event.target.value;
        if(this.roomType  === 'A/C' && this.guestType !== 'University Guest' ){
            this.shareTypeOptions = [
                { label: 'None', value: 'None' },
                { label: 'Two Sharing', value: 'Two Sharing' },
                { label: 'Three Sharing', value: 'Three Sharing' }
            ];
        } if(this.roomType  === 'Non A/C'){
            this.shareTypeOptions = [
                { label: 'None', value: 'None' },
                { label: 'Two Sharing', value: 'Two Sharing' },
                { label: 'Three Sharing', value: 'Three Sharing' },
                { label: 'Four Sharing', value: 'Four Sharing' }
            ];
        }
    }

    handleSharingTypeChange(event){
        this.sharingType = event.target.value;
    }
    // handleStartDateChange(event){
    //     this.startDate = event.target.value;
    // }
   
    // handleEndDateChange(event){
    //     this.endDate = event.target.value;
    // }
 
    handlePurposeOfVisitChange(event){
        this.purposeOfVisit = event.target.value;
    }
    handlecoOrdinatorNameChange(event){
        this.coOrdinatorName = event.target.value;
    }

    handleCoOrdinatorMobile(event){
        this.coOrdinatorMobile = event.target.value;
    }
    handlecoOrdinatorEmail(event){
        this.coOrdinatorEmail = event.target.value;
    }
    handleCheckboxChange(event) {
        this.showManualEntry = event.target.checked;
        if (this.showManualEntry == true ){
           this.isCoOrdinatorDisabled = true;
        }
        else {
            this.isCoOrdinatorDisabled = false; 
        }
        
        
    }
    handlepvisaNumber(event){
     this.visaNumber=event.target.value;
    }
    handleVisaDateChange(event){
    this.visaDate =event.target.value;
    }
    handlePrivateChange(event){
    this.PrivateVisit =event.target.checked;
    }
    handlePersonalChange(event){
    this.PersonalVisit =event.target.checked;
    }

     get isPrivateDisabled() {
        return this.PersonalVisit; // Disable Private checkbox if PersonalVisit is true
    }

    get isPersonalDisabled() {
        return this.PrivateVisit; // Disable Personal checkbox if PrivateVisit is true
    }
@wire(getLoggedInUserProfile)
wiredgetLoggedInUserProfile({ error, data }) {
    if (data) {
        this.profileName = data
        console.log('Hello:'+ this.profileName );
        if (this.profileName === 'Student Profile' || this.profileName === 'Student Portal Profile') {
            this.GuestTypeOptions = [
                { label: 'Parents', value: 'Parents' },
                { label: 'Others', value: 'Others' }
            ];
            console.log('Hello:'+ this.profileName );
            
        } else if (this.profileName === 'Professor' || this.profileName === 'Non Teaching Profile' 
                   || this.profileName === 'Hostel Profile' || this.profileName === 'System Administrator'
                   || this.profileName === 'Placement Admin' || this.profileName === 'Placement Vertical Head'
                   || this.profileName === 'Examination Vertical Head' || this.profileName === 'Vertical Head'
                   || this.profileName === 'Admissions Profile' || this.profileName === 'Finance Manager'
                   || this.profileName === 'School Director' || this.profileName === 'Transport Admin'
                   || this.profileName === 'Alumni Team' || this.profileName === 'TChancellery Profile'
                   || this.profileName === 'Chief Warden' || this.profileName === 'VC Office') {
            this.GuestTypeOptions = [
                { label: 'University Guest', value: 'University Guest' },
                { label: 'Department Guest', value: 'Department Guest' }
            ];
            console.log('Hello:'+ this.profileName );
        } else if (this.profileName === 'Guest House Manager') {
            this.GuestTypeOptions = [
                // { label: 'University Guest', value: 'University Guest' },
                // { label: 'Department Guest', value: 'Department Guest' },
                { label: 'Parents', value: 'Parents' },
                { label: 'Others', value: 'Others' },
                { label: 'Alumni', value: 'Alumni' }
            ];
            this.isGuestHouseManager = true;
            console.log('Hello:'+ this.profileName );
            console.log('Hello:'+  this.isGuestHouseManager );
        }
    }
    else if (error) {
        this.error = error;
        this.guestHouseRequest = undefined;
    }

}
handleClose() {
    location.reload();
}
handleEndDateChange(event){
    // this.endDate = event.target.value;
      const endDate = new Date(event.target.value);
     const startDate = new Date(this.startDate);
     console.log("startDate", startDate);

     if (endDate <= startDate) {
         this.dispatchEvent(
             new ShowToastEvent({
                 title: 'Error',
                 message: 'End date cannot be before start date.',
                 variant: 'error',
             })
         );
         this.template.querySelector('lightning-input[data-id="DeptDate"]').value ='';
         this.endDate = ''; // Clear the invalid date
     } else {
         this.endDate = event.target.value;
         console.log("this.endDate", this.endDate);
         this.error = '';
     }
 }
handleStartDateChange(event){
    //  this.startDate = event.target.value;
        const selectedDate = new Date(event.target.value);
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate()); // Get tomorrow's date
      tomorrow.setHours(0, 0, 0, 0); // Set to start of tomorrow
     // selectedDate.setHours(0, 0, 0, 0);

      if (selectedDate < tomorrow) {
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Start date must be from future onwards.',
                  variant: 'error',
              })
          );
          this.template.querySelector('lightning-input[data-id="arrivalDate"]').value ='';
          this.startDate = ''; // Clear the invalid date
      } 
             
      else if(selectedDate > new Date(this.endDate)){
        console.log('enddate less than');
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Start date must be less than the end date.',
                variant: 'error',
            })
        );
        this.template.querySelector('lightning-input[data-id="arrivalDate"]').value ='';
        this.startDate = ''; // Clear the invalid date
      }
      else {
          this.startDate = event.target.value;
          console.log("this.startDate",this.startDate);
         this.error = '';
      }
  }

  }