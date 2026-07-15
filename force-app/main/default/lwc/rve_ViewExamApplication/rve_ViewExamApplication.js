/**
 * @description       : 
 * @author            : owais.ahanger@cloudodyssey.co
 * @group             : 
 * @last modified on  : 06-05-2024
 * @last modified by  : owais.ahanger@cloudodyssey.co
**/
import { LightningElement, wire, track, api } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import REVA_LOGO_IMAGE from "@salesforce/resourceUrl/REVA_LOGO";
import ApplicationPortalBannerMobile_LOGO from "@salesforce/resourceUrl/ApplicationPortalBannerMobile";
import { loadScript } from 'lightning/platformResourceLoader';
import downloadjs from '@salesforce/resourceUrl/downloadjs';
import getContactDetails from '@salesforce/apex/Rve_ViewExamApplicationController.getContactDetails';
import downloadPDF from '@salesforce/apex/Rve_ViewExamApplicationController.getPdfFileAsBase64String';

import STUDENTPORTALICONS from '@salesforce/resourceUrl/SR_STUDENTPORTALASSETS';
const baseImageUrl = `${STUDENTPORTALICONS}/StudentPortalAssests/Logos/`;

export default class Rve_ViewExamApplication extends LightningElement {
    @api applicationId;
    recordId = Id; //user ID
    REVA_LOGO = `${baseImageUrl}reva-university.png`; //    revaUniversityLogoUrl = `${baseImageUrl}reva-university.png`; //REVA_LOGO_IMAGE
    ProfilePic = ApplicationPortalBannerMobile_LOGO;
    @track studentData = {};
    @track examApplication = {};
    @track examApplicationLineItems = [];
    @track examApplicationNotification = [];
    @track StudentFeePayment = {};
    boolShowSpinner = true;
    isPrintDisabled = true;
    examApplicationHeader = '';

    connectedCallback() {
        let userId = this.recordId;

        getContactDetails({ applicationId: this.applicationId })
            .then(result => {
                this.studentData = result != null && result?.student;
                this.examApplication = result != null && result?.selectedEA;
                this.examApplicationNotification = result != null && result?.selectedEN;
                let count = 1;
                this.examApplicationLineItems = this.examApplication.Rve_Exam_Application_Line_Items__r != null ? this.examApplication.Rve_Exam_Application_Line_Items__r : [];
                this.examApplicationLineItems = this.examApplicationLineItems.map(item => {
                    return { ...item, SN: count++ }
                })
                this.StudentFeePayment = result != null && result?.StudentFeePayment;

                const date = new Date(this.examApplication.Rve_Exam_Notification__r.Rve_Start_Date__c);  // 2023-11-10
                const endDate = new Date(this.examApplication.Rve_Exam_Notification__r.Rve_End_Date__c);
                this.examApplicationHeader = (date.toLocaleString('default', { month: 'long' })).toUpperCase() + (date.getMonth() != endDate.getMonth() ? '/' + (endDate.toLocaleString('default', { month: 'long' })).toUpperCase() : '') + ' ' + (parseFloat(date.getYear()) + 1900) + ' EXAMINATION'.toUpperCase();

                // Load DownloadJS Library
                this.isPrintDisabled = true;
                loadScript(this, downloadjs)
                    .then(() => {
                        this.isPrintDisabled = false;
                        this.boolShowSpinner = false;
                    })
                    .catch();
            })
            .catch(error => {
                this.boolShowSpinner = false;
            })
    }

    back() {
        this.dispatchEvent(new CustomEvent('back'));
    }

    printForm() {
        this.boolShowSpinner = true;
        const fileName = 'Exam Application ' + this.examApplication.Rve_Registration_Number__c;
        downloadPDF({ studentId: this.studentData.Id, applicationId: this.applicationId }).then(response => {
            this.boolShowSpinner = false;
            var strFile = "data:application/pdf;base64," + response;
            window.download(strFile, fileName + ".pdf", "application/pdf");

        }).catch(error => {
            this.boolShowSpinner = false;
        });
    }
}