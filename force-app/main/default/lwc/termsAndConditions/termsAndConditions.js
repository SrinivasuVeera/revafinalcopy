import { LightningElement } from 'lwc';

export default class TermsAndConditions extends LightningElement {
    renderedCallback(){
        location.reload();
    }
}