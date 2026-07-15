import { LightningElement } from 'lwc';
import banner from '@salesforce/resourceUrl/applicant_portal_banner';
import mob    from '@salesforce/resourceUrl/application_mob_bg';

export default class StudentAdmissionParent extends LightningElement {

    /*  Background image switches by viewport width —
        same pattern as StudentAdmissionLoginPage.
        ≤ 767px  → application_mob_bg
        > 767px  → applicant_portal_banner              */
    get wrapperStyle() {
        const isMobile = window.matchMedia('(max-width: 767px)').matches;
        return `background-image: url(${isMobile ? mob : banner});`;
    }
}