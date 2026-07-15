import { LightningElement, track } from 'lwc';
import banner from '@salesforce/resourceUrl/applicant_portal_banner';
import handleForgotPassword from '@salesforce/apex/ForgotPasswordController.handleForgotPassword';

export default class ForgotPasswordConfirmMessage extends LightningElement {

    // Full page background — identical to login page
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

    // ── Card shell — identical dimensions and shadow as login card ──
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

    // Inner padding — same as login card
    cardPaddingStyle = `
        padding: 38px 36px 32px 36px;
    `;

    // ── Title row — centered, uppercase bold ──
    titleRowStyle = `
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 10px;
    `;

    titleTextStyle = `
        font-size: clamp(18px, 1.8vw, 24px); 
        font-weight: 700;
        color: #000;        
        text-align: center;        
    `;

    // ── Red underline — same as login card ──
    dividerStyle = `
        width: 56px;
        height: 3.5px;
        background: #c0392b;
        border-radius: 2px;
        margin: 0 auto 24px auto;
    `;

    // ── Info paragraph 1 — centered ──
    infoPara1Style = `
        font-size: 0.88rem;
        color: #444444;
        text-align: center;
        line-height: 1.65;
        margin: 0 0 16px 0;
        font-family: 'Segoe UI', Arial, sans-serif;
    `;

    // ── Info paragraph 2 — centered, slightly lighter ──
    infoPara2Style = `
        font-size: 0.88rem;
        color: #444444;
        text-align: center;
        line-height: 1.65;
        margin: 0 0 22px 0;
        font-family: 'Segoe UI', Arial, sans-serif;
    `;

    // ── Thin grey separator — same as login card ──
    lineDividerStyle = `
        width: 100%;
        height: 1px;
        background: #e4e9ee;
        margin-bottom: 22px;
    `;

    // ── Field wrapper ──
    fieldWrapperStyle = `
        display: flex;
        flex-direction: column;
        gap: 6px;
        margin-bottom: 20px;
    `;

    // Label — same style as login card
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

    // ── Input field — same style as login card ──
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

    // Hint text — same italic grey as login card
    hintTextStyle = `
        font-size: 0.78rem;
        color: #999999;
        font-style: italic;
        font-family: 'Segoe UI', Arial, sans-serif;
        padding-left: 2px;
        margin-top: 1px;
    `;

    // Button row
    btnRowStyle = `
        margin-top: 6px;
        margin-bottom: 20px;
    `;

    // ── Full-width blue Reset Password button ──
    resetBtnStyle = `
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
    `;

    // ── Cancel link row — centered at bottom ──
    cancelRowStyle = `
        display: flex;
        justify-content: center;
        padding-top: 2px;
    `;

    // Cancel hyperlink — blue, centered
    cancelLinkStyle = `
        font-size: 0.88rem;
        color: #1a6fc4;
        font-weight: 500;
        text-decoration: none;
        font-family: 'Segoe UI', Arial, sans-serif;
        cursor: pointer;
    `;
     
}