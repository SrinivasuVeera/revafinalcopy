import { LightningElement, track, wire } from 'lwc';
import searchAttendanceRecords from '@salesforce/apex/StudAttendanceUpdate.searchAttendanceRecords';
import updateAttendanceRecords from '@salesforce/apex/StudAttendanceUpdate.updateAttendanceRecords'; 
import updateAttendanceWithNotify from '@salesforce/apex/StudAttendanceUpdate.updateAttendanceWithNotify'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getHedReasonPicklistValues from '@salesforce/apex/StudAttendanceUpdate.getHedReasonPicklistValues';
import getSchoolProgram from '@salesforce/apex/StudAttendanceUpdate.getSchoolProgramData';
import getSchoolAttendanceData from '@salesforce/apex/StudAttendanceUpdate.getSchoolAttendanceData';
import getLoggedInUserProfile from '@salesforce/apex/StudAttendanceUpdate.getLoggedInUserProfile';


export default class StudAttendanceUpdate extends LightningElement {    
    enable = false;
    @track srnInput = '';
    @track searchFromDate = '';
    @track searchToDate = '';
    @track minDate;
    // Store current date
    currentDatePick = new Date().toISOString().split('T')[0];
    // @track selectedDate;
    @track records = [];
    @track approvalPendingRecords = [];
    @track selectedRows = new Set();  // Store selected row IDs
    isLoading = false;
    isPendingApprLoading = true;
    attendanceRecords = [];
    schoolDirectorVisible = false;
    verticleHeadVisible = false;
    SCHOOL_DIRECTOR_PROFILE = 'School Director';
    VERTICLE_HEAD_PROFILE = 'Vertical Head';
    SYSTEM_ADMINISTRATOR = 'System Administrator';
    @track reasonOptions = [];
    @track selectedReason = 'Select Reason'; // Default value
    @track otherReason = ''; // To store custom input
    @track isLoading1 = true;
    updateRecords = false;
    isModalOpen = false;    
    searchTypeVal = 'Select option here';
    isSRNnumber;

    @track selected_reason = ''; // Default value for the spinner
    options = [
        { label: 'Sports', value: 'Sports' },
        { label: 'NCC/NSS', value: 'NCC/NSS' },
        { label: 'Club Activities', value: 'Club Activities' },
        { label: 'Placement', value: 'Placement' },
        { label: 'Extra Curricular Activity', value: 'Extra Curricular Activity' },
        { label: 'Others', value: 'Others' }
    ];
    searchOptions = [{ label: 'Search by SRN number', value: 'SRN' },
                     { label: 'Search by Application number', value: 'Application' }];

    //********************************CheckBox Logic*************
    @track selectedSlots = [];
    @track firstHalfSelected = false;
    @track secondHalfSelected = false;
    @track fullDaySelected = false;

    slotOptions = [
        { label: 'Slot 1', value: '1' },
        { label: 'Slot 2', value: '2' },
        { label: 'Slot 3', value: '3' },
        { label: 'Slot 4', value: '4' },
        { label: 'Slot 5', value: '5' },
        { label: 'Slot 6', value: '6' },
        { label: 'Slot 7', value: '7' },
        { label: 'Slot 8', value: '8' },
        { label: 'Slot 9', value: '9' },
    ];

    //*********************************************
  
    @track
    validSrns = [];
    @track
    invalidSrns = [];

    @track loginUserProgramCodes = [];
    @track errorPrograms;    

    @wire(getLoggedInUserProfile)
    wiredLoggedInUserProfile({ data, error }){
        if(data){
         //   console.log('wiredLoggedInUserProfile Result ::: '+data);
            if(data === this.SCHOOL_DIRECTOR_PROFILE){
                this.schoolDirectorVisible = true;
                this.verticleHeadVisible = false;
            }
            if(data === this.VERTICLE_HEAD_PROFILE || data === this.SYSTEM_ADMINISTRATOR){
                this.schoolDirectorVisible = false;
                this.verticleHeadVisible = true;
            }         
            
        } else if(error){           
            this.errorMessage = 'An error occurred: ' + error.body.message;
            console.log('wiredLoggedInUserProfile Error ::: '+this.errorMessage);
        }
    }
    // Retrieve school program data
    @wire(getSchoolProgram)
    wiredPrograms({ data, error }) {
        if (data) {
            if (data.length > 0 && !data[0].error) {
                this.loginUserProgramCodes = data; // Data retrieved successfully
                this.errorMessage = ''; // Clear any previous error message
                console.log('Result ::: '+this.loginUserProgramCodes);
            } else {
                this.loginUserProgramCodes = [];
                this.errorMessage = data.length > 0 ? data[0].error : 'No data found.';
                console.log(this.errorMessage);
            }
        } else if (error) {
            this.loginUserProgramCodes = [];
         //   this.errorMessage = 'An error occurred while fetching data.';
            console.log('Gotch error while fetching School Program :'+error);
        }
    }

    // Retrieves records of Pending For Approval
    @wire(getSchoolAttendanceData)
    wiredApprovalPending({ data, error }) {
        if (data) {
            // Successfully received data
            console.log('getSchoolAttendanceData Length :'+data.length);
            
                this.isPendingApprLoading = false;                   

                if (data.length === 0) {
                    this.showToast('Info', 'Pending For Approval Records Not Available', 'info');
                } else {
                //    console.log('Record Length : '+data.length);
                    //this.approvalPendingRecords = data; 
                    this.approvalPendingRecords = data.map(record => {
                        return {
                            ...record,
                            displaySRNOrApplication: record.SRN__c ? record.SRN__c : record.Application_Number__c
                        };
                    });
                    // this.approvalPendingRecords = data; 
                }        
            this.errorMessage = '';  // Clear any previous error
        } else if (error) {
            // Handle error
            this.isPendingApprLoading = false;   
            this.approvalPendingRecords = [];
            this.errorMessage = 'An error occurred: ' + error.body.message;
        }
    }

    // **********************************************************************************
    connectedCallback() {
        this.fetchPicklistValues();
    }

    async fetchPicklistValues() {
        try {
            const picklistValues = await getHedReasonPicklistValues();
            // Add the default option to the options array
            this.reasonOptions = [
                { label: 'Select Reason', value: 'Select Reason' },
                ...picklistValues.map(value => ({ label: value, value }))
            ];
        } catch (error) {
            console.error('Error fetching picklist values:', error);
        } finally {
            this.isLoading1 = false;
        }
    }

    handleReasonChange(event) {
        this.selectedReason = event.detail.value;            
        console.log('Selected Reason --: '+this.selectedReason);
    }

    get isOtherSelected() {
        return this.selectedReason === 'Other'; // Check if 'Other' is selected
    }

    handleOtherReasonChange(event) {
        this.otherReason = event.detail.value; // Capture custom input
        // console.log('Selected Other Reason :',this.otherReason);
    }   

    showToastMessage(selectedValue) {
        const evt = new ShowToastEvent({
            title: 'Selected+Reason',
            message: `You selected: ${selectedValue}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    handleSrnChange(event) {
        this.srnInput = event.target.value;       
        // console.log('SRN :'+this.srnInput);
    }

    handleVisible(event) {
        const val  = event.target.value;       
        console.log('Visible :' +val);
        if(val === 'santosh007'){
            this.enable = true;
        }
        
    } 

    handleReset(event){
        window.location.reload();
        // this.processSrns();        
    }

    // Calendar picker 
    handleFromDateChange(event) {
         this.searchFromDate = event.target.value;        
        //  console.log('Search Date :'+this.searchFromDate);
        //  console.log('currentDatePick :'+this.currentDatePick);
    }

    handleToDateChange(event){
        this.searchToDate = event.target.value;        
        console.log('Search To Date :'+this.searchToDate);
    }
    //***********************CheckBox Logic ************************
    handleSlotChange(event) {
        this.selectedSlots = event.detail.value;
        this.updateCheckboxes();
    }

    handleFirstHalfChange(event) {
        this.firstHalfSelected = event.target.checked;
        if (this.firstHalfSelected) {
            this.selectedSlots = [...new Set([...this.selectedSlots, '1', '2', '3', '4', '5'])];
        } else {
            this.selectedSlots = this.selectedSlots.filter(slot => !['1', '2', '3', '4', '5'].includes(slot));
        }
        this.updateCheckboxes();
    }

    handleSecondHalfChange(event) {
        this.secondHalfSelected = event.target.checked;
        if (this.secondHalfSelected) {
            this.selectedSlots = [...new Set([...this.selectedSlots, '6', '7', '8', '9'])];
        } else {
            this.selectedSlots = this.selectedSlots.filter(slot => !['6', '7', '8', '9'].includes(slot));
        }
        this.updateCheckboxes();
    }

    handleFullDayChange(event) {
        this.fullDaySelected = event.target.checked;
        if (this.fullDaySelected) {
            this.selectedSlots = [...new Set(['1', '2', '3', '4', '5', '6', '7', '8', '9'])];
            this.firstHalfSelected = false;   // Deselect first half if selected
            this.secondHalfSelected = false;   // Deselect second half if selected
        } else {
            this.selectedSlots = this.selectedSlots.filter(slot => !['1', '2', '3', '4', '5', '6', '7', '8', '9'].includes(slot));
        }
        this.updateCheckboxes();
    }

    updateCheckboxes() {
        const checkboxes = this.template.querySelectorAll('lightning-checkbox-group');
        checkboxes.forEach(checkbox => {
            checkbox.value = this.selectedSlots;
        });        
    }
    //***************************************************************

    handleSearch() {     
        // Check if both From and To dates are selected
        if (!this.searchFromDate || !this.searchToDate) {            
            this.showToast('Error', 'Both From and To dates must be selected.', 'error');
            return;
        }

        if(this.searchFromDate > this.currentDatePick){
            this.showToast('Error', 'From Date cannot be later than Today\'s Date.', 'error');
            return;
        }
        
        if(this.searchToDate > this.currentDatePick){
            this.showToast('Error', 'To Date cannot be later than Today\'s Date.', 'error');
            return;
        }

        if(this.searchFromDate > this.searchToDate){
            this.showToast('Error', 'From Date cannot be later than To Date.', 'error');
            return;
        }

        if(this.searchTypeVal === 'Select option here'){
            this.showToast('Error', 'Select search by', 'error');
            return;
        }

        if (this.srnInput && this.searchFromDate && this.searchToDate && this.selectedSlots.length > 0) {      
            this.isLoading = true;      
             // Split the input by commas and trim whitespace
            const srnsVal = this.srnInput.split(',').map(srn => srn.trim()).filter(srn => srn !== '');
            console.log('Entered SRN1 :'+srnsVal+" Date: "+this.searchFromDate);
            if (srnsVal.length === 0) {
                this.showToast('Error', 'Please enter valid SRNs', 'error');
                this.isLoading = false;
                return;
            }
            // School level SRN validation
             this.processSrns(srnsVal);
          //  console.log('Entered SRN2 :'+srnsVal+" Date: "+this.searchFromDate);
          //  console.log('loginUserProgramCodes : '+this.loginUserProgramCodes);
            console.log('Valid SRN : '+this.validSrns);
            console.log('Slots : '+this.selectedSlots);
            console.log('Search Type : '+this.searchTypeVal);
            console.log('Search From Date : '+this.searchFromDate);
            console.log('Search To Date : '+this.searchToDate);
            this.attendanceRecords = [];
         //   this.dispatchEvent(new RefreshEvent());
                if(this.validSrns.length > 0) {
                    searchAttendanceRecords({ srns: this.validSrns, searchType: this.searchTypeVal, searchDate: this.searchFromDate, toDate: this.searchToDate, slots: Array.from(this.selectedSlots)})  
                        .then(result => {
                            console.log('searchAttendanceRecords Length :'+result.length);
                        //  this.records = result;
                            this.isLoading = false;                   

                            if (result.length === 0) {
                                this.showToast('Info', 'Records are not available for the provided input', 'info');
                            } else {
                                console.log('Record Length : '+this.records.length);
                                this.records = result;  
                                console.log('Record Length : '+this.records.length);                      
                                this.updateTime();                        
                                if(this.selectedRows){
                                console.log('Selected Rows Selected');
                                this.selectedRows.clear(); // Clear selection after update 
                                }
                            } 
                        })
                        .catch(error => {
                        //   this.showToast('Error', error.body.message, 'error');
                        // Check if error body is defined before accessing message
                            const message = error.body ? error.body.message : 'An unknown error occurred';
                            this.showToast('Error', message, 'error');
                            this.isLoading = false; // Ensure loading is stopped in case of error
                        });
                } 
                if(this.invalidSrns.length > 0){                  
                    this.openDialog();
                    this.isLoading = false;
                }
            }else {
                this.showToast('Error', 'SRN,Date and Slots are required', 'error');
            }           
    }

    // Method to open the modal
    openDialog() {
        this.isModalOpen = true;
    }

    // Method to close the modal
    closeModal() {
        this.isModalOpen = false;
    }

    updateTime(){        
        if (this.records) {
            this.attendanceRecords = this.records.map(record => {
                return {
                    ...record,
                    startTime: this.convertUtcToIst(record.Course_Offering_Schedule__r.hed__Start_Time__c),
                    endTime: this.convertUtcToIst(record.Course_Offering_Schedule__r.hed__End_Time__c)
                };
            });
        }
        console.log('Formatted  :'+this.attendanceRecords[0].startTime +" : "+this.attendanceRecords[0].endTime+" && "+this.attendanceRecords[0].Slot__c+" : "+this.attendanceRecords[0].SRN__c); 
    }

    //*************************** Handle checkbox selection START ******* */ 

    handleRowSelection(event) {
        const recordId = event.target.dataset.id;
        if (event.target.checked) {
            this.selectedRows.add(recordId);
        } else {
            this.selectedRows.delete(recordId);
        }
    }

    handleSelectAll(event) {
        const checkboxes = this.template.querySelectorAll('tbody input[type="checkbox"]');
        if (event.target.checked) {
            checkboxes.forEach(checkbox => {
                checkbox.checked = true;
                this.selectedRows.add(checkbox.dataset.id);
            });
        } else {
            checkboxes.forEach(checkbox => {
                checkbox.checked = false;
                this.selectedRows.delete(checkbox.dataset.id);
            });
        }
    }
    /*********************** Handle checkbox selection END *********************************************/

    get isUpdateButtonVisible(){
        if(this.attendanceRecords.length > 0){
            return true;
        } 
       return false;
    }

    handleUpdateSelected() {        
      //  console.log('Selected handleUpdateSelected ');
        const selectedRecords = this.records.filter(record => this.selectedRows.has(record.Id));
      //  console.log('Selected records : '+selectedRecords);
     //   console.log('Selected attendence : '+selectedRecords[0].hed__Attendance_Type__c +"  "+selectedRecords[0].hed__Contact__r.Name);
        console.log('Pre +');
        // selectedRecords.forEach(record => {
        //     record.hed__Attendance_Type__c = 'Present'; // Set Attendance Type to 'Present'
        // });
        console.log('Length :'+this.selectedRows.size);
        console.log('selected_reason save button :'+this.selectedReason);        
        let recordsToUpdate;
        if(this.selectedRows.size > 0){
                // Get the current date 
                const currentDate = new Date();
                const formattedCurrentDate = currentDate.toISOString().split('T')[0];
                console.log('Current Date :'+formattedCurrentDate);

                if (this.selectedReason !== 'Select Reason') {
                    if (this.selectedReason === 'Other') {
                    //  this.otherReason = '';
                        console.log('Selected Reason>>: 1', this.selectedReason);
                        // this.showToastMessage(this.selectedReason);
                        if(this.otherReason === '' || this.otherReason == null){
                            this.showToast('Error', 'Enter other reason', 'error');
                            console.log('Selected Reason>>: 2', this.otherReason);
                        }else{                    
                            this.selectedReason = 'Other - '+ this.otherReason;
                            console.log('Selected Reason>>: 3', this.selectedReason);
                            this.updateRecords = true;
                            console.log('Selected Reason>>: create OBJ first', this.selectedReason);
                         
                            recordsToUpdate = selectedRecords.map(record => {
                                return {
                                    Id: record.Id,
                                //    hed__Attendance_Type__c: 'Present',  // Update Attendance Type to 'Present' 
                                    activity_based_att_req_dt__c : formattedCurrentDate,                   
                                    hed__Reason__c : this.selectedReason
                                };         
                            }); 
                        } 
                    } else{
                        this.updateRecords = true;
                        console.log('Selected Reason>>: create OBJ last', this.selectedReason);
                      
                        recordsToUpdate = selectedRecords.map(record => {
                            return {
                                Id: record.Id,
                            //    hed__Attendance_Type__c: 'Present',  // Update Attendance Type to 'Present'   
                                activity_based_att_req_dt__c : this.getCurrentDate(),                  
                                hed__Reason__c : this.selectedReason
                            };         
                        }); 
                    }        
                }else{
                    this.showToast('Error', 'Select Reason To Update', 'error');
                }     
                
                
                console.log('Post ');
                console.log('recordsToUpdate :'+recordsToUpdate[0].Id);
                for(let i = 0 ; i < recordsToUpdate.length ; i++){
                    // console.log('Selected name : '+selectedRecords[i].SRN__c);
                //  selectedRecords[i].hed__Attendance_Type__c = 'Present';
                    console.log('Selected attendence : '+recordsToUpdate[i].hed__Attendance_Type__c +"  "+recordsToUpdate[i].Id+" "+recordsToUpdate[i].hed__Reason__c);
                } 
                
                if(this.updateRecords){
                    this.isLoading = true;
                    updateAttendanceWithNotify({ recordsToUpdate })
                        .then(() => {
                            this.isLoading = false;
                            this.showToast('Success', 'Selected records updated to Present', 'success');
                        //    this.selectedRows.clear(); // Clear selection after update
                            console.log('Result : Success');
                            // Refresh the records on the page to reflect changes
                        //    this.handleSearch(); // Optionally refresh search results after update
                            //  this.reset();
                            //  this.dispatchEvent(new RefreshEvent());
                         //    this.handleSearch();
                         //   return refreshApex(this.records);
                           window.location.reload();
                        })
                        .catch(error => {
                            this.isLoading = false;
                            console.log('Result : Failure');
                            this.showToast('Error', error.body.message, 'error');
                        });      
                } 
            
        }else{            
            this.showToast('Error', 'Select Student Records to Update', 'error');
        }      
    }

    reset(){
        console.log('RESET ()');
        this.otherReason = '';
        this.selectedReason = 'Select Reason';
        this.selectedRows.clear();
        this.records = [];
        this.attendanceRecords = [];
        this.handleSearch();
    }

    handleApproveSubmitted(){
        if(this.selectedRows.size > 0){
            const selectedRecords = this.approvalPendingRecords.filter(record => this.selectedRows.has(record.Id)); 
            console.log('selectedRecords :'+selectedRecords.size);
            console.log('selectedRows :'+this.selectedRows.size);
            this.isLoading = true;

            if(selectedRecords.length > 0) {
                let recordsToUpdate = selectedRecords.map(record => {
                    return {
                        Id: record.Id,
                        hed__Attendance_Type__c: 'Present',  // Update Attendance Type to 'Present' 
                        activity_based_att_app_dt__c : this.getCurrentDate()                   
                    //    hed__Reason__c : this.selectedReason
                    };         
                }); 

                // for(let i = 0 ; i < recordsToUpdate.length ; i++){
                //     // console.log('Selected name : '+selectedRecords[i].SRN__c);
                // //  selectedRecords[i].hed__Attendance_Type__c = 'Present';
                //     console.log('Selected attendence : '+recordsToUpdate[i].hed__Attendance_Type__c +"  "+recordsToUpdate[i].Id+" "+recordsToUpdate[i].activity_based_att_app_dt__c);
                // }
            
                updateAttendanceRecords({ recordsToUpdate })
                            .then(() => {
                                this.isLoading = false;
                                this.showToast('Success', 'Selected records updated to Present', 'success');
                            //    this.selectedRows.clear(); // Clear selection after update
                                console.log('Result : Success');
                                // Refresh the records on the page to reflect changes
                            //    this.handleSearch(); // Optionally refresh search results after update
                                //  this.reset();
                                //  this.dispatchEvent(new RefreshEvent());
                            //    this.handleSearch();
                            //   return refreshApex(this.records);
                                window.location.reload();
                            })
                            .catch(error => {
                                this.isLoading = false;
                                console.log('Result : Failure');
                                this.showToast('Error', error.body.message, 'error');
                            });
            }
        }else{
            this.showToast('Error', 'Select Records To Approve', 'error');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    formatTime(timestamp) {
        if (timestamp) {
            console.log('timeStamp before convertUtcToIst : '+timestamp);
            this.convertUtcToIst(timestamp);
            // Convert milliseconds to a Date object
            const date = new Date(timestamp);
           return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true });
        }
        return '';
    }

    convertUtcToIst(utcDateString) {

        if (!utcDateString) {
            return '';
        }
    
        // Create a Date object from the UTC string
        const utcDate = new Date(utcDateString);
    
        // Convert to IST by adding 5 hours and 30 minutes
        const istOffset = - (5 * 60 + 30); // in minutes
        const istDate = new Date(utcDate.getTime() + istOffset * 60 * 1000);

    //    console.log('Date :::'+istDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true }));
    
        // Format the IST date as desired (e.g., HH:MM AM/PM)
        return istDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true });
    }

    getCurrentDate(){
        // Get the current date 
        const currentDate = new Date();
        const formattedCurrentDate = currentDate.toISOString().split('T')[0];
        console.log('Current Date :'+formattedCurrentDate);
        return formattedCurrentDate;
    }
// *******************************************************        

    // Method to check,the entered SRNs are belongs to login user School
    processSrns(srns) {
        this.validSrns = [];
        this.invalidSrns = []; 
        let val1 = 1;
        let val2 = 100;       
        // Loop through each SRN in the srns array
        srns.forEach(srn => {
            // Ex: Get 'CS' progCode from SRN : R19CS438
            let progCode = srn.substring(3, 6);
            progCode = progCode.replace(/[^A-Za-z]/g, '');
        //    console.log('progCode :'+progCode);
            // if (this.loginUserProgramCodes.includes(progCode)) {   // Revisit this part this is temp fix.
            if(val2 > val1) {
                // this.validSrns.push(srn);
                this.validSrns = [ ...this.validSrns, srn ];
        //        console.log('valid SRN :'+this.validSrns);
            } else {
               // this.invalidSrns.push(srn);
               this.invalidSrns = [ ...this.invalidSrns, srn ];
        //        console.log('Invalid SRN :'+this.invalidSrns);
            }
        });
    }

    handleSearchTypeChange(event){
        this.searchTypeVal = event.detail.value;
        this.isSRNnumber =  (this.searchTypeVal === 'SRN') ? true : false;
    }
}