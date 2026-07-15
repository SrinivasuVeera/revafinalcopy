import { LightningElement, track, wire } from 'lwc';
import getBankNames from '@salesforce/apex/BulkOfflineCheckPayment.getBankNames';
import updateBulkOfflinePayments from '@salesforce/apex/AdmissionsProcessUtility.updateBulkOfflinePayments'
import getStudentFeePaymentRelatedRecords from '@salesforce/apex/BulkOfflineCheckPayment.getStudentFeePaymentRelatedRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const COLUMNS = [
    { label: 'Bank Name', fieldName: 'ChequeBankName' },
    { label: 'Cheque Number', fieldName: 'ChequeDDNumber' },
    { label: 'Amount', fieldName: 'StudentPaymentAmount', type: 'currency', cellAttributes: { alignment: "left" } },
    { label: 'Cheque Date', fieldName: 'ChequeDDDate', type: 'date' },
    { label: 'Contact', fieldName: 'ContactName' },
    { label: 'Application Number', fieldName: 'ApplicationNumber' }

];

export default class BulkOfflineCheckPayment extends LightningElement {

    successPaymentStatus = 'Success';
    failedPaymentStatus = 'Failed';
    chequeRealizationDate;
    studentPaymentIds;
    paymentStatus;
    recordIds;

    @track contactName;
    @track selectedRowChequeDDNumber = [];
    @track picklistValues;

    bankName = '';
    searchChequeNumber;
    chequeDDRealisationDate;
    bankNameOptions = [];
    columns = COLUMNS;
    records = [];
    disableAccept = true;
    disableReject = true;
    selectedRows = [];
    showModal = false;
    displayDataTable = true;
    //displayDataTable = false;
    recordfound = false;
    status;
    offlinePaymentDetails;

    @wire(getBankNames)
    wiredBankNamePicklistValues({ data, error }) {
        if (data) {
            this.picklistValues = data;
            console.log('this.picklistValues', this.picklistValues);
            this.handlePickListValues();
        } else if (error) {
            console.error(error);
        }
    }

    handlePickListValues() {
        this.bankNameOptions = this.picklistValues.map(bankName => ({
            label: bankName,
            value: bankName
        }));
        this.bankNameOptions.unshift({
            label: 'All Bank',
            value: 'All Bank'
            
        });
    }

    handleBankNameChange(event) {
        this.bankName = event.detail.value;
        console.log('this.bankName', this.bankName);
        this.records = [];
        
        if (this.bankName === null || this.bankName ==='') {
            
            this.displayDataTable = false;
        } else if(this.bankName === 'All Bank') {
            this.displayDataTable = true;
            this.records = this.offlinePaymentDetails ;
        }
        else{
            this.displayDataTable = true;
        }
        this.queryRecord();
       
    }

    chequeNumberEntered(event) {
        this.searchChequeNumber = event.detail.value;
        console.log('this.searchChequeNumber', this.searchChequeNumber);
        this.records = [];
        if (this.searchChequeNumber !== null) {
            this.displayDataTable = true;
        } else {
            this.displayDataTable = false;
        }
        this.queryRecord();
    }

    @wire(getStudentFeePaymentRelatedRecords)
    getStudentFeePaymentRelatedRecords({ data, error }) {
        console.log('inside wire method');
        if (data) {
            this.offlinePaymentDetails = data;
            this.records=data;
            console.log('this.offlinePaymentDetails', this.offlinePaymentDetails);
            this.queryRecord();
        } else if (error) {
            console.error(error);
        }
    }

    queryRecord() {
        
        this.offlinePaymentDetails.forEach(item => {
           
            if (item.ChequeBankName === this.bankName || (item.ChequeDDNumber.includes(this.searchChequeNumber) && this.searchChequeNumber.length>0)) {
                this.records.push(item);
                
            }
        
        });
        if(this.records.length===0){
           
            this.recordfound=false;
        }else{
            
            this.recordfound=true;
        }
    }

    handleDateChange(event) {
        this.chequeDDRealisationDate = event.target.value;
        console.log('this.chequeDDRealisationDate', this.chequeDDRealisationDate);
        if ((!this.chequeDDRealisationDate || this.chequeDDRealisationDate) && this.selectedRows.length===0) {
            this.disableAccept = true;
            this.disableReject = true;
        }
        else if (!this.chequeDDRealisationDate && this.selectedRows!==0) {
            this.disableAccept = true;
            this.disableReject = false;
        }
        else {
            this.disableAccept = false;
            this.disableReject = true;
        }
    }

    handleRowSelection = event => {
        this.selectedRows = event.detail.selectedRows;
        console.log('this.selectedRows', this.selectedRows);
        this.selectedRowChequeDDNumber = this.selectedRows.map(row => row.ChequeDDNumber);
        console.log('this.selectedRowChequeDDNumber', this.selectedRowChequeDDNumber);
        if ((!this.chequeDDRealisationDate || this.chequeDDRealisationDate) && this.selectedRows.length===0) {
            this.disableAccept = true;
            this.disableReject = true;
        }
        else if (!this.chequeDDRealisationDate && this.selectedRows!==0) {
            this.disableAccept = true;
            this.disableReject = false;
        }
        else {
            this.disableAccept = false;
            this.disableReject = true;
        }
    }

    handleClickAccept() {
        this.status = this.successPaymentStatus;
        this.showModal = true;
    }

    handleClickReject() {
        this.status = this.failedPaymentStatus;
        console.log('On Reject status is : ' + this.status);
        this.showModal = true;
    }

    handleClickConfirm() {
        this.showModal = false;
        console.log('on Confirm this.status', this.status);

        updateBulkOfflinePayments({ recordIds: this.selectedRows.map(row => row.StudentpaymentIds), paymentStatus: this.status, chequeRealizationDate: this.chequeDDRealisationDate })
            .then(result => {
                // this.error = undefined;
                console.log('recordIds', result);
                console.log('paymentStatus', this.paymentStatus);
                console.log('chequeRealizationDate', this.chequeRealizationDate);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
            this.handleReload();
    }

    handleClickCancel() {
        this.showModal = false;
    }

    
    handleReload() {
        //window.location.reload();
        setTimeout(function(){
            window.location.reload();
        }, 2000); 
       }
}