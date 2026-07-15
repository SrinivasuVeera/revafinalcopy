import { LightningElement, track } from 'lwc';
import sendOTP from '@salesforce/apex/OTPLoginController.sendOTP';
import verifyOTP from '@salesforce/apex/OTPLoginController.verifyOTP';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import banner from '@salesforce/resourceUrl/applicant_portal_banner';

export default class StudentAdmissionOTPEmailConfirmation extends LightningElement {

    get backgroundStyle() {
        return `
            background-image: url(${banner});
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            z-index: 9999;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            padding-right: 4%;
            box-sizing: border-box;
            font-family: 'Segoe UI', Arial, sans-serif;
        `;
    }

  /*  @track identifier = '';
    @track otp = '';
    @track otpSent = false;

    loginIdentifier;

    handleIdentifierChange(event) {

        this.identifier = event.target.value;
    }

    handleOTPChange(event) {

        this.otp = event.target.value;
    }

    async sendOTP() {

        try {

            const response = await sendOTP({
                identifier: this.identifier
            });

            this.loginIdentifier =
                response.loginIdentifier;

            this.otpSent = true;

            this.showToast(
                'Success',
                response.message,
                'success'
            );

        } catch(error) {

            this.handleError(error);
        }
    }

    async verifyOTP() {

        try {

            const redirectUrl = await verifyOTP({

                identifier: this.identifier,
                otp: this.otp,
                loginIdentifier: this.loginIdentifier,
                startUrl: '/s/'
            });

            if(redirectUrl) {

                window.location.assign(
                    redirectUrl
                );

            } else {

                this.showToast(
                    'Error',
                    'Login failed',
                    'error'
                );
            }

        } catch(error) {

            this.handleError(error);
        }
    }

    handleError(error) {

        let message = 'Unknown error';

        if(error?.body?.message) {

            message = error.body.message;

        } else if(error?.message) {

            message = error.message;
        }

        this.showToast(
            'Error',
            message,
            'error'
        );
    }

    showToast(title, message, variant) {

        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    } */

 /*   import { LightningElement, track } from 'lwc';

import sendOTP from '@salesforce/apex/OTPLoginController.sendOTP';
import verifyOTP from '@salesforce/apex/OTPLoginController.verifyOTP';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OtpLogin extends LightningElement { */

    @track identifier = '';
    @track otp = '';
    @track otpSent = false;

    @track isLoading = false;

    @track disableResend = false;
    @track resendLabel = 'Resend OTP';

    loginIdentifier;
    resendTimer;

    /*
     * HANDLE IDENTIFIER CHANGE
     */
    handleIdentifierChange(event) {

        this.identifier = event.target.value;
    }

    /*
     * HANDLE OTP CHANGE
     */
    handleOTPChange(event) {

        this.otp = event.target.value;
    }

    /*
     * SEND OTP
     */
    async sendOTP() {

        this.isLoading = true;

        try {

            const response = await sendOTP({
                identifier: this.identifier
            });

            this.loginIdentifier =
                response.loginIdentifier;

            this.otpSent = true;

            this.startResendCooldown();

            this.showToast(
                'Success',
                response.message,
                'success'
            );

        } catch(error) {

            this.handleError(error);

        } finally {

            this.isLoading = false;
        }
    }

    /*
     * RESEND OTP
     */
    async resendOTP() {

        await this.sendOTP();
    }

    /*
     * VERIFY OTP
     */
    async verifyOTP() {

        this.isLoading = true;

        try {

            const redirectUrl = await verifyOTP({

                identifier: this.identifier,
                otp: this.otp,
                loginIdentifier: this.loginIdentifier,
                startUrl: '/s/'
            });

            if(redirectUrl) {

                window.location.assign(
                    redirectUrl
                );

            } else {

                this.showToast(
                    'Error',
                    'Login failed.',
                    'error'
                );
            }

        } catch(error) {

            this.handleError(error);

        } finally {

            this.isLoading = false;
        }
    }

    /*
     * RESEND COOLDOWN TIMER
     */
    startResendCooldown() {

        this.disableResend = true;

        let remainingSeconds = 30;

        this.resendLabel =
            `Resend OTP (${remainingSeconds}s)`;

        clearInterval(this.resendTimer);

        this.resendTimer = setInterval(() => {

            remainingSeconds--;

            this.resendLabel =
                `Resend OTP (${remainingSeconds}s)`;

            if(remainingSeconds <= 0) {

                clearInterval(this.resendTimer);

                this.disableResend = false;

                this.resendLabel = 'Resend OTP';
            }

        }, 1000);
    }

    /*
     * HANDLE ERRORS
     */
    handleError(error) {

        let message = 'Unknown error';

        if(error?.body?.message) {

            message = error.body.message;

        } else if(error?.message) {

            message = error.message;
        }

        this.showToast(
            'Error',
            message,
            'error'
        );
    }

    /*
     * SHOW TOAST
     */
    showToast(title, message, variant) {

        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    /*
     * CLEANUP
     */
    disconnectedCallback() {

        clearInterval(this.resendTimer);
    }
}