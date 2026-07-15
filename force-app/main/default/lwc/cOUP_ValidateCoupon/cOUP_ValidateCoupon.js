import { LightningElement, wire ,api} from 'lwc';
import validateCoupon from '@salesforce/apex/COUP_CouponCodeUtility.validateCoupon';
import applyDiscount from '@salesforce/apex/COUP_CouponCodeUtility.applyDiscount';

export default class COUP_ValidateCoupon extends LightningElement {

    enteredCouponCode;
    validationMessage;
    applyMessage;
    disableApply = true;
    disableValidate = true;
    
    @api discountPercent;
    @api contactId;
    @api programId;

    handleCouponCodeChange(event){
        this.enteredCouponCode = event.target.value;
        if(this.enteredCouponCode.length === 0){
            this.disableValidate = true;

        }else if(this.enteredCouponCode.length > 20){
            this.validationMessage = 'Invalid Coupon Code';
            this.disableValidate = true;

        }else{
            this.disableValidate = false;
            this.validationMessage = '';
        }
        this.applyMessage = '';
        this.disableApply = true;
    }

    validateCoupon(){
        if(this.enteredCouponCode !== undefined){
            validateCoupon( { enteredCouponCode : this.enteredCouponCode , contactId : this.contactId , programId : this.programId})
            .then(result => {
                console.log(result);
                this.validationMessage = result;
                
                console.log(this.validationMessage);
                this.error = undefined
                if(this.validationMessage === 'Valid. Click on Apply'){
                    this.disableApply = false;  
                    this.disableValidate = true;
                }
            })
            .catch(error => {
                this.error = error;
            });
        } else {
            this.validationMessage = 'Enter a value';
        }
    }

    applyCoupon(){
        applyDiscount( { enteredCouponCode : this.enteredCouponCode , contactId : this.contactId})
            .then(result =>{
                this.applyMessage = result[0];
                this.discountPercent=result[1];
                this.error = undefined;
                this.disableApply = true;
                this.disableValidate = true;
            })
            .catch(error => {
                this.error = error;
            });
    }
}