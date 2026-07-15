import { LightningElement, wire,track, api } from 'lwc';
import getAvailableFacilities from '@salesforce/apex/revaClassAndLabBookingController.getAvailableFacilities';
import createFacilityRequestAllocation from '@salesforce/apex/revaClassAndLabBookingController.createFacilityRequestAllocation';
import deleteFacilityRequestAllocation from '@salesforce/apex/revaClassAndLabBookingController.deleteFacilityRequestAllocation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue,updateRecord } from 'lightning/uiRecordApi';
import COURSE_OFFERING_ID from '@salesforce/schema/hed__Course_Offering_Schedule__c.hed__Course_Offering__c';
import COURSE_OFFERING_Elective from '@salesforce/schema/hed__Course_Offering_Schedule__c.hed__Course_Offering__r.Active_Elective_Course__c';


import { CloseActionScreenEvent } from "lightning/actions";
import { loadStyle } from "lightning/platformResourceLoader";
import modal from "@salesforce/resourceUrl/custommodalcss";
import { refreshApex } from '@salesforce/apex';


export default class RevaAllocateClassOrLab extends LightningElement {
    @track facilities = [];
    @track alreadyBookedFacility = [];
    @track filteredFacilities = [];
    @track selectedRows = [];
    @api recordId;
    searchValue = '';
    isAlreadyBooked;
    isElectiveCourse;
    wiredFacilitiesResult;
    columnsToAllocate = [
        { label: 'Id', fieldName: 'Name', initialWidth: 190, },
        { label: 'Facility Name', fieldName: 'facilityName' },
       
    ];

     columnsToDeAllocate = [
       // { label: 'Id', fieldName: 'Name', initialWidth: 150, },
        { label: 'Facility Name', fieldName: 'facilityName' },
       
    ];
    
    @wire(getRecord, { recordId: '$recordId', fields: [COURSE_OFFERING_Elective] })
    wiredDataOfCourseElective(result) {
        this.wiredResult = result;
        if (result.data) {
            console.log('result of course offering id elective----->', JSON.stringify(result.data, null, 2));
            this.isElectiveCourse = result?.data?.fields?.hed__Course_Offering__r?.value?.fields?.Active_Elective_Course__c?.value;
            console.log(this.isElectiveCourse);
            
        } else if (result.error) {
            console.error('Error fetching course offering id', result.error);
            // Handle the error
        }
    }

    connectedCallback() {
        loadStyle(this, modal);
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    @wire(getAvailableFacilities, { courseOfferingScheduleId: '$recordId' })
    wiredFacilities(result) {
        this.wiredFacilitiesResult = result;
        if (result.data) {
            const data = result.data;
            this.isAlreadyBooked = data.isAlreadyBooked;
            if (data.isAlreadyBooked === true) {
                this.alreadyBookedFacility = data.alreadyBookedFacility.map(item => ({
                    ...item,
                    facilityName: item?.Facility_Request__r?.Facility__r?.Display_Name__c
                }));
                this.facilities = data.facilityRequests
                    .filter(item => item.isBooked) // Assuming `isBooked` is a property that indicates if the facility is booked
                    .map(item => ({
                        ...item,
                        facilityName: item.Facility__r?.Display_Name__c,
                    }));
                this.filteredFacilities = this.facilities;
                return;
            } else if (data.isAlreadyBooked === true && this.isElectiveCourse === true) {
                console.log('recordid ' + this.recordId);
                console.log('Data ' + JSON.stringify(data));
                this.facilities = data.facilityRequests
                    .filter(item => item.isBooked) // Assuming `isBooked` is a property that indicates if the facility is booked
                    .map(item => ({
                        ...item,
                        facilityName: item.Facility__r?.Display_Name__c,
                    }));
                this.filteredFacilities = this.facilities;
            }
            
            console.log('recordid ' + this.recordId);
            console.log('Data ' + JSON.stringify(data));
            this.facilities = data.facilityRequests.map(item => ({
                ...item,
                facilityName: item.Facility__r?.Display_Name__c,
            }));
            this.filteredFacilities = this.facilities;
            
        } else if (result.error) {
            this.showToastMessage('Error when fetching available facilities', result.error.body.message, 'error');
            console.error('Error when fetching available facilities ' + result.error.body.message);
        }
    }

    handleSearch(event) {
        this.searchValue = event.target.value.toLowerCase();
        if (this.searchValue === '') {
            this.filteredFacilities = this.facilities;
        } else {
            this.filteredFacilities = this.facilities.filter(facility =>
                facility.facilityName.toLowerCase().includes(this.searchValue)
            );
        }
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        console.log('Selected Row ' + JSON.stringify(this.selectedRows));
    }

    handleAllocate() {
        if (this.selectedRows.length > 0) {
            const facilityRequestId = this.selectedRows[0].Id;
            this.createFacilityRequestAllocation(facilityRequestId);
            console.log('Selected Facility ID:', facilityRequestId);
        } else {
            this.showToastMessage('Select Facility To Allocate', '', 'info');
            
        }
    }
    deAllocateFacility() {
        const facilityRequestAllocationId = this.alreadyBookedFacility[0].Id;
        const facilityName = this.alreadyBookedFacility[0].facilityName;
        deleteFacilityRequestAllocation({ facilityRequestAllocationId: facilityRequestAllocationId })
            .then(resullt => {
                this.showToastMessage(`Facility Deallocated Successfully`, '', 'success');
                return refreshApex(this.wiredFacilitiesResult);
            }).catch(error => {
                console.error('Error when deallocation ' + error);
                this.showToastMessage('Error when deallocation ', error.body.message, 'error');
        })
        console.log('facilityRequestAllocationId ' + facilityRequestAllocationId);
    }

    createFacilityRequestAllocation(facilityRequestId) {
        createFacilityRequestAllocation({ facilityRequestId: facilityRequestId, courseOfferingScheduleId: this.recordId })
            .then(result => {
                this.showToastMessage('Facility allocated successfully', '', 'success')
                return refreshApex(this.wiredFacilitiesResult);
            }).catch(error => {
            
        })
    }
      showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }


}