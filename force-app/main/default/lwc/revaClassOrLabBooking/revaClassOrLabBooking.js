import { LightningElement, wire, track, api } from 'lwc';
import getFacilitesAndSemesters from '@salesforce/apex/revaClassAndLabBookingController.getFacilitesAndSemesters';
//import getFacilitesAndSemestersDifferentDept from '@salesforce/apex/revaClassAndLabBookingController.getFacilitesAndSemestersDifferentDept';
import createFacilityRequest from '@salesforce/apex/revaClassAndLabBookingController.createFacilityRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import hasBypassClassBookingValidation from '@salesforce/customPermission/REVA_Infra_Room_Booking';
//import getSchools from '@salesforce/apex/revaClassAndLabBookingController.getSchools';
import { CloseActionScreenEvent } from "lightning/actions";
import { loadStyle } from "lightning/platformResourceLoader";
import modal from "@salesforce/resourceUrl/custommodalcss";
import getUserDepartment from '@salesforce/apex/revaClassAndLabBookingController.getUserDepartment';
import getCourseOfferingRecord from '@salesforce/apex/revaClassAndLabBookingController.getCourseOfferingRecord';
//import COURSE_OFFERING_ID from '@salesforce/schema/hed__Course_Offering_Schedule__c.hed__Course_Offering__c'


export default class RevaClassOrLabBooking extends LightningElement {
    //For UAT Test recordId = '0015j00000etbTeAAI';
    @api recordId ;
    @track departmentName;
    @track rows = [{
        id: 1,
        selectedSemesters: [],
        selectedFacilities: [],
        filteredSemesters: [],
        filteredFacilities: [],
        facilityHelpText: '',
    }];
    @track schoolOptions = [];
    isSpinner;
    @track semMapAlreadyBookedFacilities = {};
    @track selectedSemesters = [];
    @track facilities = [];
    @track filteredFacilities = [];
    @track semesters = [];
    @track selectedSchoolId;
    @track filteredSchoolOptions = [];
    @track isBookCrossDept=false;
    wiredResult;
    courseOfferingData ;



      @wire(getFacilitesAndSemesters, { accountId: '$recordId', schoolName: '$departmentName', isCrossDept: '$isBookCrossDept' })
    wiredData(result) {
        this.wiredResult = result;
        if (result.data) {
            console.log('Data:', JSON.stringify(result.data , null, 2));

            // Extract data from the wire response
            const { semesters, facilities, alreadyBookedFacilities } = result.data;
            this.semesters = semesters.map(semester => ({
                label: semester.Semester_Name_With_Date__c,
                value: semester.Id
            }));
            this.facilities = facilities;
            this.filteredFacilities = facilities;

            // Process already booked facilities into a map
            if (alreadyBookedFacilities) {
                const result = new Map(); // Map<SemesterId, Set<FacilityId>>

                for (const eachFacilityRequest of alreadyBookedFacilities) {
                    const { Semester__c, Facility__c } = eachFacilityRequest;

                    if (!result.has(Semester__c)) {
                        result.set(Semester__c, new Set([Facility__c]));
                    } else {
                        result.get(Semester__c).add(Facility__c);
                    }
                }

                // Convert map to a plain object for reactive tracking
                const readableResult = {};
                for (const [semesterId, facilityIds] of result.entries()) {
                    readableResult[semesterId] = Array.from(facilityIds);
                }

                this.semMapAlreadyBookedFacilities = readableResult;
                console.log('Resulting Map:', JSON.stringify(this.semMapAlreadyBookedFacilities, null, 2));
            }
        } else if (result.error) {
            this.showToastMessage('Error when fetching classroom and semesters', result.error.body.message, 'error');
            console.error('Error when fetching classroom and semesters', result.error.body.message);
        }
    }


    getCourseOfferingStatus(){
        getCourseOfferingRecord({recordId: this.recordId}).then((res)=>{
            console.log('object --->', JSON.stringify(res,null,2))
        }).catch((err)=>{
            console.log('err --->', JSON.stringify(err))
        })

    }
    connectedCallback() {
        loadStyle(this, modal);
        this.getCourseOfferingStatus();
        //this.fetchSchools();
    }

    /*fetchSchools() {
        getSchools()
            .then(result => {
                this.schoolOptions = result.map(school => {
                    return { label: school.Name, value: school.Id };
                });
            })
            .catch(error => {
                console.error('Error fetching schools:', error);
            });
    }*/

    

    handleBookCrossDept(){
        this.isBookCrossDept = true;
        refreshApex(this.wiredResult)
        .then(() => {
            // Once data is refreshed, clear the selected facilities
            this.rows = this.rows.map(row => ({
                ...row,
                selectedFacilities: [] // Clear selected facilities
            }));
        })
        .catch(error => {
            // Handle errors if refresh fails
            console.error('Error refreshing data:', error);
        });
    }

    handleBookSameDept(){
        this.isBookCrossDept = false;
        refreshApex(this.wiredResult)
        .then(() => {
            // Once data is refreshed, clear the selected facilities
            this.rows = this.rows.map(row => ({
                ...row,
                selectedFacilities: [] // Clear selected facilities
            }));
        })
        .catch(error => {
            // Handle errors if refresh fails
            console.error('Error refreshing data:', error);
        });
    }

    @wire(getUserDepartment)
    wiredDepartment({ error, data }) {
        if (data) {
            this.departmentName = data;
            console.log('this.departmentName', this.departmentName);
            console.log('data', data);
        } else if (error) {
            this.showToastMessage('Error fetching department', error.body.message, 'error');
        }
    }

    handleSchoolChange(event) {
        const index = event.target.dataset.index;
        const selectedSchoolId = event.detail.value;
        this.rows[index].selectedSchool = selectedSchoolId;
        const selectedSchool = this.schoolOptions.find(school => school.value === selectedSchoolId);
    if (selectedSchool) {
        this.departmentName = selectedSchool.label;
    }
    }

    /* handleSchoolSearch(event) {
        const searchValue = event.target.value.toLowerCase();
        this.filteredSchoolOptions = this.schoolOptions.filter(option =>
            option.label.toLowerCase().includes(searchValue)
        );
    }*/

     closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    addRow() {
        this.rows = [...this.rows, {
            id: this.rows.length + 1,
            selectedSemesters: [],
            selectedFacilities: [],
            filteredSemesters: [],
            filteredFacilities: [],
             facilityHelpText: '',
        }];
    }

    deleteRow(event) {
        const index = event.target.dataset.index;
        const removedRow = this.rows[index];
        const removedSemestersIds = removedRow.selectedSemesters.map(sem => sem.Id);
        this.selectedSemesters = this.selectedSemesters.filter(sem => !removedSemestersIds.includes(sem.Id));
        this.rows = this.rows.filter((row, rowIndex) => rowIndex != index);
    }

    

    handleSemesterSearch(event) {
        const index = event.target.dataset.index;
        const searchValue = event.target.value.toLowerCase();
        if (searchValue === '') {
            this.rows[index].filteredSemesters = [];
            return;
        }
        const filteredSemesters = this.semesters.filter(semester => semester.Name.toLowerCase().includes(searchValue));
        const alreadySelectedSemIds = this.selectedSemesters.map(sem => sem.Id);
        this.rows[index].filteredSemesters = filteredSemesters.filter(sem => !alreadySelectedSemIds.includes(sem.Id));
    }

    handleFacilitySearch(event) {
        const index = event.target.dataset.index;
        if (this.rows[index].selectedSemesters.length == 0) {
            this.showToastMessage('Select semester before searching facility', '', 'info');
            return;
        } 
        const searchValue = event.target.value.toLowerCase();
        
        if (searchValue === '') {
            this.rows[index].filteredFacilities = [];
            return;
        }
        console.log('hasBypassClassBookingValidation ' + hasBypassClassBookingValidation);
        if (!hasBypassClassBookingValidation) {
            const selectedSemester = this.rows[index].selectedSemesters[0];
          //  this.filterFacilityBasedOnSemesterStartDate(selectedSemester, index);
        }
        const semesterId = this.rows[index].selectedSemesters[0].Id;
        const bookedFacilitiesForSemester = this.semMapAlreadyBookedFacilities[semesterId] || [];
        const filteredFacilities = this.facilities.filter(facility => {
            return !bookedFacilitiesForSemester.includes(facility.Id) &&
               facility.Display_Name__c.toLowerCase().includes(searchValue);
        });
        this.rows[index].filteredFacilities = [...filteredFacilities];
    }
    
    

    handleSemesterSelection(event) {
        const index = event.target.dataset.index;
    const selectedSemesterId = event.detail.value;
    
    // Find the selected semester from the semesters list
    const selectedSemester = this.semesters.find(semester => semester.value === selectedSemesterId);

    // If the semester is found, update the corresponding row
    if (selectedSemester) {
        this.rows[index].selectedSemesters.push({
            Id: selectedSemester.value,
            Semester_Name_With_Date__c: selectedSemester.label
        });

        // Optionally, you can remove the selected semester from filteredSemesters to prevent re-selection
        this.rows[index].filteredSemesters = this.rows[index].filteredSemesters.filter(
            semester => semester.value !== selectedSemesterId
        );
    }
    }

    handleFacilitySelection(event) {
        const index = event.target.dataset.index;
        const facilityId = event.target.dataset.id;
        const selectedFacility = this.facilities.find(fac => fac.Id === facilityId);
        const isAlreadySelected = this.rows[index].selectedFacilities.some(fac => fac.Id === facilityId);
        if (!isAlreadySelected) {
            this.rows[index].selectedFacilities = [...this.rows[index].selectedFacilities, selectedFacility];
        }
        
    }

    handleFacilityRemove(event) {
        const index = event.target.dataset.index;
        const facilityId = event.target.dataset.id;
        this.rows[index].selectedFacilities = this.rows[index].selectedFacilities.filter(facility => facility.Id !== facilityId);
    }

    handleSemesterRemove(event) {
        const index = event.target.dataset.index;
        const semesterId = event.target.dataset.id;
        this.rows[index].selectedSemesters = this.rows[index].selectedSemesters.filter(semester => semester.Id !== semesterId);
        this.rows[index].selectedFacilities = [];
        this.rows[index].facilityHelpText = '';
        this.selectedSemesters = this.selectedSemesters.filter(semester => semester.Id !== semesterId);
                this.updateFilteredSemesters(index);

    }

    updateFilteredSemesters(index) {
        const searchInput = this.template.querySelector(`.semester-search-input[data-index="${index}"]`);
        const searchValue = searchInput ? searchInput.value.toLowerCase() : '';
        const filteredSemesters = this.semesters.filter(semester => semester.Name.toLowerCase().includes(searchValue));
        const alreadySelectedSemIds = this.selectedSemesters.map(sem => sem.Id);
        this.rows[index].filteredSemesters = filteredSemesters.filter(sem => !alreadySelectedSemIds.includes(sem.Id));
    }

    handleBookFacilities() {
        this.isSpinner = true;
        let combinations = [];
        let isValid = true;
        this.rows.forEach(row => {
            if (row.selectedFacilities.length == 0 || row.selectedSemesters.length == 0) {
                this.showToastMessage('Each row should contain ateast one semester and facility selected ', '', 'error');
                this.isSpinner = false;
                isValid = false;
                return;
            }
            row.selectedFacilities.forEach(facility => {
                row.selectedSemesters.forEach(semester => {
                    combinations.push({
                        facilityId: facility.Id,
                        semesterId: semester.Id,
                        accountId: this.recordId,
                    });
                });
            });
        });
        if (!isValid) {
            return;
        }
        //this.createFacilityRequest(combinations);
        console.log('Combinations:', JSON.stringify(combinations));

         if (combinations.length === 0) {
        this.showToastMessage('Error', 'There should be atleast one row for booking', 'error');
        this.isSpinner = false;
        return;
    }
    else{
        this.createFacilityRequest(combinations);
    }
        
    }

    createFacilityRequest(combinations) {
        createFacilityRequest({
            jsonString: JSON.stringify(combinations)
        }).then((result) => {
            this.isSpinner = false;
            this.showToastMessage('Success', 'Facility request has been submitted', 'success');
            //Reset the row values.
            this.rows =  [{
                id: 1,
                selectedSemesters: [],
                selectedFacilities: [],
                filteredSemesters: [],
                filteredFacilities: [],
                 facilityHelpText: '',
            }];
            //Reset selected semester values.
            this.selectedSemesters = [];
            return refreshApex(this.wiredResult);
        }).then(() => {
        // Ensure data is refreshed before closing action
        if (this.wiredResult.data) {
            this.closeAction();
        }
    }).catch((error) => {
            this.showToastMessage('Error when creating Facility Request', error.body.message, 'error');
            console.log('error==', error.message);
            this.isSpinner = false;
         })
    }

    /*filterFacilityBasedOnSemesterStartDate(selectedSemester, index) {  
        console.log('Into alteration' + JSON.stringify(selectedSemester));
        
         const remainingDaysToStart = selectedSemester.Days_Remaining_To_Start__c;
        if (remainingDaysToStart <= 0) {
            this.facilities = [];
               // this.rows[index].facilityHelpText = `The selected semester : ${selectedSemester.Name}, was started before ${- (remainingDaysToStart)} days so booking not allowed for this semester.`;
                return;
        } else if (remainingDaysToStart > 7) {
            this.facilities = structuredClone(this.filteredFacilities);
              //  this.rows[index].facilityHelpText = `The selected semester will start in ${remainingDaysToStart} days. Facilities shown will be only from your own department.`;
                this.facilities = this.facilities.filter(facility => {
                    return facility.hed__Account__c == this.recordId || facility.hed__Account__r.ParentId == this.recordId;
                }
                )
        } else {
             this.facilities = structuredClone(this.filteredFacilities);
               // this.rows[index].facilityHelpText = `The selected semester will start in ${remainingDaysToStart} days. Facilities shown will be only from your cross department.`;
                this.facilities = this.facilities.filter(facility => {
                    return facility.hed__Account__c != this.recordId && facility.hed__Account__r.ParentId != this.recordId;
                })
            }
    }*/

    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }

}