import { LightningElement, track } from 'lwc';
import sendOTP from '@salesforce/apex/OTPLoginController.sendOTP';
import verifyOTP from '@salesforce/apex/OTPLoginController.verifyOTP';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import banner from '@salesforce/resourceUrl/applicant_portal_banner';

export default class StudentAdmissionOTPLogin extends LightningElement {

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

    // Card shell - identical dimensions and shadow as CustomForgotPasswordNew
    cardStyle = `
        background: #ffffff;
        border-radius: 20px;
        width: 440px;
        max-width: 92vw;
        box-shadow: 0 20px 60px rgba(0,0,0,0.40), 0 4px 16px rgba(0,0,0,0.20);
        overflow: hidden;
        position: relative;
        z-index: 10000;
        font-family: 'Segoe UI', Arial, sans-serif;
    `;

    // Inner padding - same as CustomForgotPasswordNew
    cardPaddingStyle = `
        padding: 20px 36px 32px 36px;
    `;

    // Title row
    titleRowStyle = `
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        margin-bottom: 10px;
    `;

    titleTextStyle = `
        font-size: 1.3rem;
        font-weight: 700;
        color: #2c2c2c;
        text-align: center;
        font-family: 'Segoe UI', Arial, sans-serif;
    `;
    
    // Red underline divider - same as CustomForgotPasswordNew
    dividerStyle = `
        width: 56px;
        height: 3.5px;
        background: #c0392b;
        border-radius: 2px;
        margin: 0 auto 24px auto;
    `;

    // Thin grey separator
    lineDividerStyle = `
        width: 100%;
        height: 1px;
        background: #e4e9ee;
        margin: 4px 0 20px 0;
    `;

    // Field wrapper
    fieldWrapperStyle = `
        display: flex;
        flex-direction: column;
        gap: 6px;
        margin-bottom: 12px;
    `;

    // Label - same style as CustomForgotPasswordNew
    labelStyle = `
        font-size: 0.9rem;
        font-weight: 700;
        color: #2c2c2c;
        font-family: 'Segoe UI', Arial, sans-serif;
        margin-bottom: 2px;
    `;

    // Red asterisk
    reqStyle = `
        color: #c0392b;
        font-weight: 700;
    `;

    

    // Input field - same style as CustomForgotPasswordNew
    inputStyle = `
        width: 100%;
        padding: 14px 16px;
        border: 1.5px solid #c8d8ea;
        border-radius: 10px;
        font-size: 0.95rem;
        color: #1a1a1a;
        outline: none;
        background: #ffffff;
        box-sizing: border-box;
        font-family: 'Segoe UI', Arial, sans-serif;
    `;

    // Hint text
    hintTextStyle = `
        font-size: 0.78rem;
        color: #999999;
        font-style: italic;
        font-family: 'Segoe UI', Arial, sans-serif;
        padding-left: 2px;
        margin-top: 1px;
    `;

    // Error message
    errorStyle = `
        font-size: 0.84rem;
        color: #c0392b;
        font-weight: 600;
        background: #fff5f5;
        border-left: 3px solid #c0392b;
        border-radius: 6px;
        padding: 8px 12px;
        margin-bottom: 14px;
        font-family: 'Segoe UI', Arial, sans-serif;
        box-sizing: border-box;
    `;

    // Button row
    btnRowStyle = `
        margin-top: 6px;
        margin-bottom: 20px;
    `;

    // Full-width Login button - matches CustomForgotPasswordNew reset button
    loginBtnStyle = `
        background: #c0392b;
        color: #ffffff;
        border: none;
        border-radius: 10px;
        padding: 15px 0;
        width: 100%;
        font-size: 1.1rem;
        font-weight: 700;
        cursor: pointer;
        letter-spacing: 0.5px;
        box-sizing: border-box;
        text-align: center;
        font-family: 'Segoe UI', Arial, sans-serif;
    `;

    // Helper links row (Forgot / Resend)
    helperLinksRowStyle = `
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        margin-bottom: 12px;
        flex-wrap: wrap;
    `;

    helperLinkStyle = `
        font-size: 0.875rem;
        font-weight: 600;
        color: #c0392b;
        text-decoration: none;
        font-family: 'Segoe UI', Arial, sans-serif;
        white-space: nowrap;
    `;

    pipeSeparatorStyle = `
        color: #cccccc;
        font-size: 0.875rem;
        user-select: none;
    `;

    // Not a Member row
    alreadyRegisteredStyle = `
        font-size: 0.875rem;
        text-align: center;
        color: #444;
        font-family: 'Segoe UI', Arial, sans-serif;
    `;

    registerLinkStyle = `
        margin-left: 4px;
        font-weight: 600;
        color: #c0392b;
        text-decoration: none;
        font-size: 0.875rem;
        font-family: 'Segoe UI', Arial, sans-serif;
    `;

    // Spinner backdrop
    spinnerBackdropStyle = `
        position: absolute;
        inset: 0;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        background: rgba(255,255,255,0.88);
        border-radius: 20px;
        z-index: 100;
    `;

    spinnerTextStyle = `
        margin-top: 12px;
        font-size: 0.85rem;
        color: #555;
        font-family: 'Segoe UI', Arial, sans-serif;
    `;

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
    this.identifier = this.identifier.trim();
    // Email validation
    const emailRegex =
        /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (
        !this.identifier ||
        !emailRegex.test(this.identifier)
    ) {

        this.showToast(
            'Error',
            'Please enter a valid email address.',
            'error'
        );

        return;
    }

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