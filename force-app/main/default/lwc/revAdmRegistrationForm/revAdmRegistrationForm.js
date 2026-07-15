import { LightningElement, track, api } from 'lwc';
import ADMISSIONPORTALASSETS from '@salesforce/resourceUrl/SR_ADMISSIONPORTALASSESTS';

const baseImageUrl = `${ADMISSIONPORTALASSETS}/AdmissionPortalAssets/Icons`;
export default class RevAdmRegistrationForm extends LightningElement {

    registrationProcessImageUrl = `${baseImageUrl}/registration-process.png`;
    registerYourSelfIconUrl = `${baseImageUrl}/register-yourself.png`;
    verifyEmailOrSmsIconUrl = `${baseImageUrl}/otp-verification.png`;
    payApplicationFeeIconUrl = `${baseImageUrl}/pay-application-fee.png`;
    resetPasswordIconUrl = `${baseImageUrl}/reset-password.png`;
    fillApplicationFormIconUrl = `${baseImageUrl}/fill-application-form.png`;
    awaitCallIconUrl = `${baseImageUrl}/await-for-call.png`;

    @api admissionYear;
    @track currentStatus = 1;

    handleCallCount(event) {
        const receivedCount = event.detail.count;  // Do something with the received count value
        this.currentStatus = receivedCount;
    }



    updateStatus(selectedNumber) {
        this.currentStatus = selectedNumber;
    }

    get statusItems() {
        return [1, 2, 3, 4, 5, 6].map(number => ({
            number: number,
            class: `status-circle ${this.currentStatus >= number ? 'active' : 'inactive'}`,
            showLine: number < 6
        }));
    }



}