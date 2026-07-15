import { LightningElement , track, wire, api} from 'lwc';
import getApprovalStatus from '@salesforce/apex/Rpl_DocumentUploadClass.getApprovalStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchStudentRegDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails';
import getDocumentStatus from '@salesforce/apex/Rpl_DocumentUploadClass.getDocumentStatus';
import updateIsUnderApprovalProcess from '@salesforce/apex/Rpl_DocumentUploadClass.updateIsUnderApprovalProcess';
import Static_Resources from '@salesforce/resourceUrl/RPL_Static_Resources';
import {refreshApex} from '@salesforce/apex';


export default class Rpl_RevaStudentRegistrationStatus extends LightningElement {
    @api recordId;
    @api placementRegistrationText;
    @track registrationData;
    @api isUnderApproval = false;
    isApprovalStatus = false;
    isDocumentStatus = false;

    isApproved = false;
    isSpinner = false;
    successIcon = Static_Resources + '/Reva_Placement_Static_Resources/Icons/success.png';
    clearIcon =  Static_Resources + '/Reva_Placement_Static_Resources/Icons/clear.png';
    @wire(getApprovalStatus, {recordId : '$recordId'})
    wiredApprovalStatus({data, error}){
       /*  this.isSpinner = true; */
        if(data){
            this.registrationData = data.map(record => {
                let approvalStatus = '';
                if(!record.Rpl_Is_Record_Shared__c){
                    approvalStatus = 'Not Submitted';
                }else{
                    approvalStatus = record.Rpl_Status__c;
                }
                return {
                    ...record,
                    variant: this.getStatusVariant(record.Rpl_Status__c),
                    approvalStatus,
                    reasonForRejection : record.Rpl_Reason_for_Documentation_Fail__c != undefined ? record.Rpl_Reason_for_Documentation_Fail__c : '--',
                }
            })

            this.registrationData = this.registrationData[0];

        }else if(error){
            this.isSpinner = false; 
        }
    }

    getStatusVariant(status) {
        switch (status) {
            case 'Document Validation Failed':
                return 'destructive';
            case 'Document Validation Pending':
                return 'neutral';
            case 'Registration Successful':
                return 'success';
            default:
                return 'neutral';
        }
    }


     handleStepClick(event){
        const stepNumber = event.target.dataset.step;
    
        this.updateStyles(stepNumber);
        if(stepNumber == 1){
            this.isDocumentStatus = true;
            this.isApprovalStatus = false
        }else if(stepNumber == 2){
            this.isDocumentStatus = false;
            this.isApprovalStatus = true;
        }
    }

    updateStyles(stepNumber){
        const tabs = this.template.querySelectorAll('.tab');
        tabs.forEach(tab => {
            const tabStepNumber = tab.dataset.step;
            if(tabStepNumber!=stepNumber){
                tab.style.backgroundColor = '#FEF3EA';
                tab.style.color = 'black';
            }else{
                tab.style.backgroundColor = '#F07F07';
                tab.style.color = 'white';
            }
        })
    }
//////////////////////////////////////////////////////////////////////////
    isSubmitDisabled = true;
    isCheckboxDisabled = false;
    acknowledgmentChecked = false;
    documentNameMapsApi = {};
    programType;
    wiredStudentData;
    keyForWire = 1;
    //secondKey = 1;

     connectedCallback() {
        this.isSpinner = true;
        //this.keyForWire++;        
    }

    @wire(fetchStudentRegDetails, {recordId : '$recordId', key:'$keyForWire'})
    wiredMethod(result){
        if(result.data){
            this.studentRegistration = result.data[0];
            this.programType = this.studentRegistration.Rpl_Program_Type__c;       
            this.modifyData();
            this.isDocumentStatus = true;   
        }else if(result.error){
            const toastEvent = new ShowToastEvent({
                title : 'Error When Fetching Status',
                message : result.error.body.message,
            })
            this.isSpinner = false;
        }
        
    }


    @track data = [
    //{ id: '1', documentName: 'Student General Information', statusLabel: null, apiName:'Rpl_isStudentDetailsComplete__c', variant:'brand' },
    //{ id: '2', documentName: 'School Education Details', statusLabel: null, apiName: 'Rpl_isStudentDetailsComplete__c', variant:'brand' },
    //{ id: '1', documentName: 'College Education Details', statusLabel: null, apiName: 'RPL_IsGraduationComplete__c', variant:'brand' },
    { id: '1', documentName: 'Fill Basic Details', statusLabel: null, apiName: 'RPL_IsGraduationComplete__c', variant:'brand' },
    { id: '2', documentName: 'Tenth Marksheet', statusLabel: null, apiName : 'Rpl_Is_Tenth_Marksheet_Uploaded__c', variant:'brand'},
    { id: '3', documentName: 'Twelveth / Diploma Marksheet', statusLabel: null , apiName : 'Rpl_Is_Twelveth_Marksheet_Uploaded__c', variant:'brand'},
    { id: '4', documentName: 'Resume Upload', statusLabel: null ,apiName: 'Rpl_Is_Resume_Uploaded__c',variant:'brand' },
];

modifyData(){
     if(this.programType == 'UG'){    
        this.data.push({ id: '5', documentName: 'UG Marksheet Upload', statusLabel: null ,apiName: 'Rpl_Is_UG_Marksheet_Uploaded__c',variant:'brand' });
    }else if(this.programType == 'PG'){
        this.data.push({ id: '5', documentName: 'UG Marksheet Upload', statusLabel: null ,apiName: 'Rpl_Is_UG_Marksheet_Uploaded__c',variant:'brand' });
        this.data.push({ id: '6', documentName: 'PG Marksheet Upload', statusLabel: null ,apiName: 'Rpl_Is_PG_Marksheet_Uploaded__c',variant:'brand' });
    } 
    //this.secondKey ++ ;
    //this.fetchDocumentStatus(); 
    return refreshApex(this.wiredStudentData);
}

@track modifiedData = [];


    @wire(getDocumentStatus, { recordId: '$recordId'})
    wiredGetDocumentStatus(result) {
        this.wiredStudentData = result;
        this.modifiedData = [];
        if (result.data) {
            this.isCheckboxDisabled = this.isUnderApproval;            
            this.modifiedData = this.data.map(row => {
                const apiName = row.apiName;
                const matchingStatus = result.data[apiName];
                
                if (!matchingStatus) {
                    this.isCheckboxDisabled = true;
                }
                
                return {
                    id: row.id,
                    documentName: row.documentName,
                    statusLabel: matchingStatus ? 'action:approval' : 'utility:spinner',
                    iconSize: matchingStatus ? 'small' : 'large',
                    variant: matchingStatus ? 'brand' : 'warning',
                    iconClass: matchingStatus ? 'slds-m-horizontal_auto slds-m-left_small' : 'slds-m-horizontal_auto slds-m-left_x-small',
                    imgSrc : matchingStatus ? this.successIcon : this.clearIcon,
                };
            });

            this.isSpinner = false;
        } else if (result.error) {
            console.error('Error fetching document status:', result.error);
            this.isSpinner = false;
        }
    }
handleAcknowledgmentChange(event){
    this.acknowledgmentChecked = event.target.checked;
    this.isSubmitDisabled = !this.acknowledgmentChecked;
}
handleSubmit(event){
    this.isSpinner = true;
    updateIsUnderApprovalProcess({recordId : this.recordId})
    .then(result => {
        const event = new CustomEvent('sendapproval', {
            bubbles: true, // Allow the event to bubble up the DOM hierarchy
        });
        this.dispatchEvent(event);
        this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Documents Sent For Verification Successfully!',
                    variant: 'success'
                })
            );
        this.isSpinner = false;
        location.reload();

    }).catch(error=>{
        this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'destructive'
                })
            );
        this.isSpinner = false;
    })
}
}