import { LightningElement, api, wire } from 'lwc';
import getApplicationId from '@salesforce/apex/AdmissionsProcessUtility.getApplicationId';
import { NavigationMixin } from 'lightning/navigation';
import getSiteUrl from '@salesforce/apex/RegistrationFormUtility.getSiteURL';
import getApplicationDeclaration from '@salesforce/apex/AdmissionsProcessUtility.getApplicationDeclaration';
import getFeeStructureDefined from '@salesforce/apex/AdmissionsProcessUtility.getFeeStructureDefined';
import getApplicationStatusInterested from '@salesforce/apex/AdmissionsProcessUtility.getApplicationStatusInterested';
import getPOFullySigned from '@salesforce/apex/AdmissionsProcessUtility.getPOFullySigned';
import getRelatedFilesByRecordId from '@salesforce/apex/AdmissionsProcessUtility.getRelatedFilesByRecordId';

const VF_PAGE_Fee_Structure = '/apex/ProgramFeeStructure?Id=';
const VF_PAGE_PO_LETTER = '/apex/POLetter?Id=';

export default class AdmissionRelatedDocuments extends NavigationMixin(LightningElement) {
    appId;
    appDeclaration;
    applicationInteresteRecord;
    appPOFullySigned;
    appFeeStructureDefined;
    poViewStatus;
    interestApplication;


    @wire(getApplicationId)
    getApplicationId({ data, error }) {
        if (data) {
            this.appId = data;
            console.log('userId', this.appId);
        }
    }

    @wire(getApplicationDeclaration, { appId: '$appId' })
    getApplicationDeclaration({ data, error }) {
        if (data) {
            this.appDeclaration = data;
            console.log('appDeclaration', this.appDeclaration);
        }
    }

    @wire(getFeeStructureDefined, { appId: '$appId' })
    getFeeStructureDefined({ data, error }) {
        if (data) {
            this.appFeeStructureDefined = data;
            console.log('appDeclaration', this.appFeeStructureDefined);
        }
    }

    @wire(getApplicationStatusInterested, { appId: '$appId' })
    getApplicationStatusInterested({ data, error }) {
        if (data) {
            this.applicationInteresteRecord = data;
            console.log('App',this.applicationInteresteRecord);
            this.poViewStatus = this.applicationInteresteRecord.Provisional_Admission_Fee_Paid__c === true ? true : false
            this.interestApplication=this.applicationInteresteRecord.hed__Application_Status__c==='Interested'?true:false;
        }
    }

    @wire(getPOFullySigned, { appId: '$appId' })
    getPOFullySigned({ data, error }) {
        if (data) {
            this.appPOFullySigned = data;
            console.log('appPOFullySigned', this.appPOFullySigned);
        }
    }

    @wire(getSiteUrl)
    wired_getSiteUrl({ data, error }) {
        if (data) {
            this.siteUrl = data;
            this.error = undefined;
        } else if (error) {
            this.siteUrl = undefined;
            this.error = error;
        }
    };

    filesList = []
    @wire(getRelatedFilesByRecordId, { appId: '$appId' })
    getRelatedFilesByRecordId({ data, error }) {
        if (data) {
            //console.log('working');
            console.log(data)
            this.filesList = Object.keys(data).map(item => ({
                "label": data[item],
                "value": item,
                "url": `/sfc/servlet.shepherd/document/download/${item}`
            }))
            console.log('working', this.filesList)
        }
        if (error) {
            console.log(error)
        }
    }

    handleClick() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                //url: this.siteUrl+ VF_PAGE_Fee_Structure + this.appId
                url: VF_PAGE_Fee_Structure + this.appId
            }
        }).then(url => {
            window.open(url);
            console.log('url', url);
        });
    }

    onhandleClick() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                //url: this.siteUrl+ VF_PAGE_Fee_Structure + this.appId
                url: VF_PAGE_PO_LETTER + this.appId
            }
        }).then(url => {
            window.open(url);
            console.log('url', url);
        });
    }
}