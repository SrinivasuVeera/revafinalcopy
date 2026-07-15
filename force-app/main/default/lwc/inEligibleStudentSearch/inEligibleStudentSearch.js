import { LightningElement,track,wire } from 'lwc';
import searchStudents from '@salesforce/apex/ASM_HallTicketCtrl.searchStudents';
import GetStudentDetails from '@salesforce/apex/ASM_HallTicketCtrl.GetStudentDetails';
import updateContact from '@salesforce/apex/ASM_HallTicketCtrl.updateContact';
export default class InEligibleStudentSearch extends LightningElement {
    searchInput = '';
    students = [];
    filteredStudents = [];
    showDropdown = false;
    boolShowSpinner = true;
    SRNNumber = '';
    PendingServey = '';
    selectedContactId='';
    showPendingSurveyTable = false;
    showAttendanceTable = false;
    showStudentFeeTable = false;
    showErrorMsg = false;
    @track lst_Attendance = [];
    @track lst_StudentFee = [];
    @track lstSurveyPending = [];
    isApproveDisabled = true;
    showPopup = false;
    approvalType='';
    
    get options() {
        return [
            { label: 'IA', value: 'IA' },
            { label: 'Semester', value: 'Semester' },
        ];
    }
    handleSearch(event) {
        this.searchInput = event.target.value;
        if (this.searchInput.length >= 2) {
            this.fetchStudents();
        } else {
            this.filteredStudents = [];
            this.showDropdown = false;
        }
    }
    fetchStudents() {
        searchStudents({ searchTerm: this.searchInput })
            .then(result => {
                this.contacts = result.map(contact => ({
                    label: contact.Name,
                    value: contact.Id
                }));
                this.filteredStudents = this.contacts;
                this.showDropdown = true;
            })
            .catch();
    }
    handleSelection(event) {
        this.showPendingSurveyTable =false;
        this.showAttendanceTable = false;
        this.showStudentFeeTable =false;
        const selectedStudentId = event.detail.value;
        this.selectedContactId = event.detail.value;
        this.isApproveDisabled = !selectedStudentId;
        this.fetchStudentDetails(selectedStudentId);
    }
    fetchStudentDetails(contactId){
       GetStudentDetails({conId:contactId})
        .then(result => {
            this.SRNNumber = result.SRNNumber;
            this.PendingServey = result.SurveyPending;
            this.lst_Attendance = result.AttendanceWrapper;
            this.lst_StudentFee = result.StudentFee;
            this.lstSurveyPending = result.lstSurveyPending;
            this.showPendingSurveyTable = result.lstSurveyPending.length > 0 ? true : false;
            this.showAttendanceTable = result.AttendanceWrapper.length > 0 ? true : false;
            this.showStudentFeeTable = result.StudentFee.length > 0 ? true : false;

            // For IA Hall Ticket We have to skip surveys 
            if (this.hallTicketType == 'hed_IA_Notification') {
                this.HallTicketEnabled = (this.showAttendanceTable || this.showStudentFeeTable) ? false : true;
             
            }
            else {
                this.HallTicketEnabled = (this.showAttendanceTable || this.showStudentFeeTable || this.showPendingSurveyTable) ? false : true;
            }

            this.boolShowSpinner = false;
            this.showErrorMsg = false;
        })
        .catch(error => {
            this.boolShowSpinner = false;
            this.showErrorMsg = true;
        });
    }
    handleApproval(event){
        this.approvalType=event.detail.value;
    }
    handleCommentsChange(event){
        this.comments=event.target.value;
    }
    handleApproveRequest(){
        this.showPopup = true;
    }     
    closePopup() {
        this.showPopup = false;
    }
    handleSuccess() {
        // Handle success after record is saved
        this.showPopup = false;
        updateContact({conId: this.selectedContactId,comments:this.comments,approvalType:this.approvalType})
        .then(result => {
            //this.wiredContact = result;
        })
        .catch(error => {
            this.error = error;
        });
    }  
    
}