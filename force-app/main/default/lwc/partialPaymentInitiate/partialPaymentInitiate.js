import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPaymentRecord from '@salesforce/apex/RevaHostelRequestAndAllotment.createPaymentRecord';
import getStudentFee from '@salesforce/apex/RevaHostelRequestAndAllotment.getStudentFee';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

export default class PartialPaymentInitiate extends NavigationMixin(LightningElement) {
    @track paymentAmount = 0;
    @track studentFee;
    @track wiredStudentFeeResult;
    @track totalAmount=0;
    @track paidAmount=0;
    @track pendingAmount=0;  
    @track isPaymentValid = true;
    @track errorMessage = '';
    
    @wire(getStudentFee)
    wiredStudentFee(result) {
        if (result.data) {
            console.log('Full Student Fee Data:', result.data);
            this.totalAmount = result.data.Amount__c;
            this.paidAmount = result.data.Amount_Paid__c;
            this.pendingAmount = result.data.Amount_Pending__c;
            this.studentFee = result.data;
            console.log('Student Fee details:', this.studentFee);
        } else if (result.error) {
            console.error('Error loading student fee', result.error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading student fee',
                    message: result.error.body.message,
                    variant: 'error'
                })
            );
        }
    }


    handleInputChange(event) {
        const field = event.target.dataset.id;
        if (field === 'amount') {
            this.paymentAmount = event.target.value;
            if (this.paymentAmount >= (this.pendingAmount / 2) && this.paymentAmount <= this.pendingAmount) {
                this.isPaymentValid = false;
                this.errorMessage = '';
            } 
            else {
                this.isPaymentValid = true;
                if (this.paymentAmount <= (this.totalAmount / 2)) {
                this.errorMessage = `Please Enter Amount more than 50% of Pending Amount`;
                }else if (this.paymentAmount > this.pendingAmount) {
                    this.errorMessage = `Payment Amount must not exceed the Pending Amount.`;
                }
                this.showToastMessage('Error', this.errorMessage, 'error');            }
        }
    }
    
    showToastMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    createPayment() {
        createPaymentRecord({ amount: this.paymentAmount, pendingAmount: this.pendingAmount })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Payment record created successfully',
                        variant: 'success'
                    })
                );
                this.paymentAmount = 0;
                this.isPaymentValid = false;
                refreshApex(this.wiredStudentFeeResult);
                this.closeModal();
                // Navigate to the new URL
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/Admissions/s/?tabset-906eb=2'
                    }
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    closeModal() {
        const closeModalEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeModalEvent);
    }

}