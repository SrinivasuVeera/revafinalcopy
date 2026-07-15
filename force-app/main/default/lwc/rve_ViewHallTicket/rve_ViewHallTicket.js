import { LightningElement, wire, track, api} from 'lwc';
import Id from '@salesforce/user/Id';
import { loadScript } from 'lightning/platformResourceLoader';
import downloadjs from '@salesforce/resourceUrl/downloadjs';
import GetStudentDetails from '@salesforce/apex/ASM_HallTicketCtrl.GetStudentDetails';
import downloadExamHallTicketPDF from '@salesforce/apex/ASM_HallTicketCtrl.DowloadHallTicket';
import getExamNotification from '@salesforce/apex/Rve_ViewHallTicketController.getExamNotification';
import downloadIAHallTicketPDF from '@salesforce/apex/Rve_ViewHallTicketController.getPdfFileAsBase64String';
import savePdfAsFile from '@salesforce/apex/Rve_ViewHallTicketController.savePdfAsFile';
import deleteAction from '@salesforce/apex/Rve_ViewHallTicketController.deleteFile';
export default class Rve_ViewHallTicket extends LightningElement {
    boolShowSpinner = true;
    SRNNumber = '';
    PendingServey = '';
    HallTicketEnabled = false;
    IAHallTicketEnabled = false;
    showPendingSurveyTable = false;
    showAttendanceTable = false;
    showStudentFeeTable = false;
    isPrintDisabled = false;
    showErrorMsg = false;
    showSemErrorMsg = false;
    showIaErrorMsg = false;
    @track lst_Attendance = [];
    @track lst_StudentFee = [];
    @track lstSurveyPending = [];
    @api hallType;
    
    connectedCallback(){
        this.isPrintDisabled = true;
        loadScript(this, downloadjs)
        .then(() => {
            this.isPrintDisabled = false;
            this.boolShowSpinner = false;
        })
        .catch();

        getExamNotification({recType: this.hallType})
        .then(response => {
            if(response != null){
                this.hallTicketType = response.RecordType.DeveloperName;
                
                GetStudentDetails()
                .then(result => {
                    this.SRNNumber = result.SRNNumber;
                    this.PendingServey = result.SurveyPending;
                    this.lst_Attendance = result.AttendanceWrapper;
                    this.lst_StudentFee = result.StudentFee;
                    this.IAHallTicketEnabled = this.hallType == 'hed_IA_Notification' ? result.EnableIAHallTicket : false;
                    this.HallTicketEnabled = this.hallType == 'hed_Semester_Notification' ? result.EnableSemHallTicket : false;
                    this.lstSurveyPending = result.lstSurveyPending;
                       
                    this.boolShowSpinner = false;
                    if(this.hallType == 'hed_Semester_Notification' && this.HallTicketEnabled== false)
                    {
                      this.showSemErrorMsg = true;

                    }else{
                        if(this.hallType == 'hed_IA_Notification' && this.IAHallTicketEnabled == false)
                        {
                            this.showIaErrorMsg = true;
                        }
                    }

                })
                .catch(error => {
                    this.boolShowSpinner = false;
                    this.showErrorMsg = true;
                })

            }
            else {
                this.showErrorMsg = true;
            }
        })
        .catch(error => {
            this.showErrorMsg = true;
        })

    }

    downloadHallTicket(event){
        this.boolShowSpinner = true;

         if(this.hallType == 'hed_IA_Notification'){
            savePdfAsFile({ StudentSRN: this.SRNNumber })
                .then(response => {
                   let vfPageUrl = '/StudentPortal/sfc/servlet.shepherd/version/download/' + response.Id;
                   window.open(vfPageUrl, '_blank');
                   deleteAction({ "contentDocumentId": response.Id });
                    this.boolShowSpinner = false;
                })
                .catch(error => {
                    console.error('Error downloading IA hall ticket:', error);
                    this.IAHallTicketEnabled = false;
                    this.showErrorMsg = true;
                    this.boolShowSpinner = false;
                    
                });
         }
         else {
             downloadExamHallTicketPDF({StudentSRN : this.SRNNumber}).then(response => {
                this.boolShowSpinner = false;
                window.open(response.url, "_self");
            }).catch(error => {

                 console.error('error=> ',error);
                 this.HallTicketEnabled = false;
                 this.boolShowSpinner = false;
             });
         }
    }
}