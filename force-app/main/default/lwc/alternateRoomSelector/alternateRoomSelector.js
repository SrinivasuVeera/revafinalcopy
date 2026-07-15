import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import getAlternateFacilitiesSameSchool from '@salesforce/apex/RoomBookingController.getAlternateFacilitiesSameSchool';
import getOtherSchools from '@salesforce/apex/RoomBookingController.getOtherSchools';
import getAlternateFacilitiesOtherSchool from '@salesforce/apex/RoomBookingController.getAlternateFacilitiesOtherSchool';
import confirmAlternateBooking from '@salesforce/apex/RoomBookingController.confirmAlternateBooking';
import getScheduleDetails from '@salesforce/apex/RoomBookingController.getScheduleDetails';
import getPendingRequests from '@salesforce/apex/RoomBookingController.getPendingRoomChangeRequests';
import getCompletedRequests from '@salesforce/apex/RoomBookingController.getCompletedRoomChangeRequests';

export default class AlternateRoomSelector extends LightningElement {
  // booking info
  @track bookingDate;
  @track slot;
  @track school;
  @track conflictId; 
  @track courseOfferingName;
  @track sectionName;
  @track roomChangeStatus;

  // pending/completed data
  @track pendingRequests = [];
  @track completedRequests = [];
  @track isPendingView = true;
  @track isCompletedView = false;

  // facility select
  @track facilities = [];
  @track selectedFacility;
  @track schoolOptions = [];
  @track selectedOtherSchool;

  // ui state
  @track showFacilityOptions = false;
  @track showSchoolSelector = false;
  @track showAlternateSelector = false;   // 🔹 for showing booking UI after click
  @track isLoading = false;
  @track message;

  // button variants
  get pendingButtonVariant() {
    return this.isPendingView ? 'brand' : 'neutral';
  }
  get completedButtonVariant() {
    return this.isCompletedView ? 'brand' : 'neutral';
  }

  // read params from URL & fetch schedule info
  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    if (currentPageReference) {
      this.conflictId = currentPageReference.state.c__scheduleId;
      if (this.conflictId) {
        this.fetchScheduleDetails(this.conflictId);
      }
    }
  }

  fetchScheduleDetails(scheduleId) {
    this.isLoading = true;
    getScheduleDetails({ scheduleId })
      .then(data => {
        this.conflictId = scheduleId;
        this.courseOfferingName = data.courseOfferingName;
        this.sectionName = data.sectionName;
        this.bookingDate = data.date;
        this.slot = data.slot;
        this.school = data.school;
        this.roomChangeStatus = data.roomChangeStatus;
        this.showAlternateSelector = true;   // 🔹 show selection UI
      })
      .catch(err => {
        console.error('❌ getScheduleDetails error', err);
        this.message = err?.body?.message || 'Error fetching schedule details.';
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  // -------- view toggle --------
  handleViewChange(e) {
    const view = e.target.dataset.view;
    if (view === 'pending') {
      this.isPendingView = true;
      this.isCompletedView = false;
      this.showAlternateSelector = false;
      this.loadPendingRequests();
    } else {
      this.isPendingView = false;
      this.isCompletedView = true;
      this.showAlternateSelector = false;
      this.loadCompletedRequests();
    }
  }
  loadPendingRequests() {
  this.isLoading = true;
  getPendingRequests()
    .then(data => {
      // Map data to safely handle missing relationships
      this.pendingRequests = (data || []).map(req => ({
        ...req,
        courseOfferingName: req.hed__Course_Offering__r?.Name || '',
        sectionName: req.Section__r?.Name || '',
        batchName: req.Batch_Group__r?.Name || ''
      }));
      console.log('✅ Pending Requests:', JSON.stringify(this.pendingRequests));
    })
    .catch(err => {
      console.error('❌ getPendingRequests error', err);
      this.message = err?.body?.message || 'Error fetching pending requests.';
    })
    .finally(() => { this.isLoading = false; });
}


 /* loadPendingRequests() {
    this.isLoading = true;
    getPendingRequests()
      .then(data => { this.pendingRequests = data; })
      .catch(err => {
        console.error('❌ getPendingRequests error', err);
        this.message = err?.body?.message || 'Error fetching pending requests.';
      })
      .finally(() => { this.isLoading = false; });
  }*/

  loadCompletedRequests() {
    /*this.isLoading = true;
    getCompletedRequests()
      .then(data => { this.completedRequests = data; })
      .catch(err => {
        console.error('❌ getCompletedRequests error', err);
        this.message = err?.body?.message || 'Error fetching completed requests.';
      })
      .finally(() => { this.isLoading = false; });*/
      getCompletedRequests()
  .then(data => {
    this.completedRequests = data.map(req => ({
      ...req,
      CourseName: req.hed__Course_Offering__r ? req.hed__Course_Offering__r.Name : '',
      SectionName: req.Section__r ? req.Section__r.Name : '',
      BatchName: req.Batch_Group__r ? req.Batch_Group__r.Name : ''
    }));
  })
  .catch(err => {
    console.error('❌ getCompletedRequests error', err);
  })
  .finally(() => { this.isLoading = false; });
  }

  // -------- when clicking course in pending list --------
  handleCourseClick(e) {
    const scheduleId = e.target.dataset.id;
    if (scheduleId) {
      this.fetchScheduleDetails(scheduleId);
    }
  }

  // -------- same/other school selection --------
  handleSameSchool() {
    this.resetView();
    this.isLoading = true;
    getAlternateFacilitiesSameSchool({
      bookingDate: this.bookingDate,
      slot: Number(this.slot),
      schoolName: this.school
    })
      .then(data => {
        this.facilities = (data || []).map(f => ({
          label: `${f.facilityName} (${f.roomNumber}) - ${f.block}`,
          value: f.facilityId
        }));
        this.showFacilityOptions = true;
        if (!this.facilities.length) {
          this.message = '⚠️ No alternate facilities available in this school.';
        }
      })
      .catch(err => {
        console.error('❌ getAlternateFacilitiesSameSchool error', err);
        this.message = err?.body?.message || 'Error fetching facilities.';
      })
      .finally(() => { this.isLoading = false; });
  }

  handleOtherSchool() {
    this.resetView();
    this.isLoading = true;
    getOtherSchools({ excludeSchool: this.school })
      .then(data => {
        this.schoolOptions = (data || []).map(s => ({ label: s, value: s }));
        this.showSchoolSelector = true;
      })
      .catch(err => {
        console.error('❌ getOtherSchools error', err);
        this.message = err?.body?.message || 'Error fetching schools.';
      })
      .finally(() => { this.isLoading = false; });
  }

  handleSchoolChange(e) {
    this.selectedOtherSchool = e.detail.value;
    if (!this.selectedOtherSchool) return;

    this.isLoading = true;
    getAlternateFacilitiesOtherSchool({
      bookingDate: this.bookingDate,
      slot: Number(this.slot),
      schoolName: this.selectedOtherSchool
    })
      .then(data => {
        this.facilities = (data || []).map(f => ({
          label: `${f.facilityName} (${f.roomNumber}) - ${f.block}`,
          value: f.facilityId
        }));
        this.showFacilityOptions = true;
        if (!this.facilities.length) {
          this.message = '⚠️ No alternate facilities available.';
        }
      })
      .catch(err => {
        console.error('❌ getAlternateFacilitiesOtherSchool error', err);
        this.message = err?.body?.message || 'Error fetching facilities.';
      })
      .finally(() => { this.isLoading = false; });
  }

  handleFacilityChange(e) {
    this.selectedFacility = e.detail.value;
  }

  confirmAlternate() {
    if (!this.selectedFacility) {
      this.message = '⚠️ Please select a facility first.';
      return;
    }
    if (!this.conflictId) {
      this.message = '❌ Missing schedule reference.';
      return;
    }
    this.isLoading = true;
    confirmAlternateBooking({
      scheduleId: this.conflictId,
      newFacilityId: this.selectedFacility
    })
      .then(res => { this.message = res; })
      .catch(err => {
        console.error('❌ confirmAlternateBooking error', err);
        this.message = err?.body?.message || 'Error updating facility.';
      })
      .finally(() => { this.isLoading = false; });
  }

  get disableConfirm() {
    return !this.selectedFacility;
  }

  resetView() {
    this.facilities = [];
    this.selectedFacility = null;
    this.showFacilityOptions = false;
    this.showSchoolSelector = false;
    this.message = null;
  }
}