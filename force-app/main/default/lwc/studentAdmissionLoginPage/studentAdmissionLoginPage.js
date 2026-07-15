import { LightningElement, track , api} from 'lwc';
import login from '@salesforce/apex/ExperienceLoginController.login';
import banner from '@salesforce/resourceUrl/applicant_portal_banner';
import mob from '@salesforce/resourceUrl/application_mob_bg';

export default class StudentAdmissionLoginPage extends LightningElement {
    @track username = '';
    @track password = '';
    @track error;
    @track showSpinner = false;
    isLoading = false;

     _privateTitle;

        @api
        get title() {
            return this._privateTitle;
        }

        set title(value) {
            this._privateTitle = value;
            this.setAttribute("title", this._privateTitle);
        }

        connectedCallback() {
            this.title = "REVA University - Applicant Portal";
            document.title = "REVA University - Applicant Portal";
        }

    // Full page background
    // Mobile / tablet (<= 1024px) uses application_mob_bg
    // Desktop (> 1024px) uses applicant_portal_banner
    get backgroundStyle() {
        const isMobileOrTablet = window.matchMedia('(max-width: 1024px)').matches;
        const bgImage = isMobileOrTablet ? mob : banner;

        return `
            background-image: url(${bgImage});
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

    // ─────────────────────────────────────────
    //  All functionality unchanged
    // ─────────────────────────────────────────

    handleUsername(event) {
        this.username = event.target.value;
    }

    handlePassword(event) {
        this.password = event.target.value;
    }

    async handleLogin() {
        this.error = null;

        if (!this.username || !this.password) {
            this.error = 'Please enter username and password.';
            return;
        }

        this.isLoading = true;
        this.showSpinner = true;

        try {
            const redirectUrl = await login({
                username: this.username,
                password: this.password
            });

            window.location.assign(redirectUrl);

        } catch (error) {
            console.log('Error:: ' + JSON.stringify(error));
            this.error = 'Login failed. Please check your credentials and try again.';
        } finally {
            this.isLoading = false;
            this.showSpinner = false;
        }
    }
}