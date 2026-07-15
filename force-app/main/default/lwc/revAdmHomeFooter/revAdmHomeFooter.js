import { LightningElement, track } from 'lwc';

export default class RevAdmHomeFooter extends LightningElement {

    @track currentYear = new Date().getFullYear();
}