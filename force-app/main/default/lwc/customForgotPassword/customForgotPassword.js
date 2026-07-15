import { LightningElement, track } from 'lwc';
import handleForgotPassword from '@salesforce/apex/ForgotPasswordController.handleForgotPassword';

export default class CustomForgotPassword extends LightningElement {
    @track username = '';
    @track errorMessage = '';

    handleUsernameChange(event) {
        this.username = event.target.value;
        this.errorMessage = ''; 
    }

    handleReset() {        
        if (!this.username) {
            this.errorMessage = 'Please enter your username.';
            return;
        }

      handleForgotPassword({ username: this.username })
    .then(result => {

        if (result === 'Success') {
            window.location.assign('./CheckPasswordResetEmail');
        }

        else if (result.startsWith('SUGGEST:')) {

            const username = result.replace('SUGGEST:', '');

            this.errorMessage =
                'This is your username: ' + username +
                '. Please use this to reset your password.';
        }

        else if (result.startsWith('ERROR:')) {

            this.errorMessage =
                result.replace('ERROR:', '');
        }

    })
    .catch(() => {
        this.errorMessage = 'Unexpected error occurred.';
    });
    }
}