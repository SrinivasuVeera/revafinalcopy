import { LightningElement, track } from 'lwc';



export default class RevStdHomeFooter extends LightningElement {

    @track currentYear = new Date().getFullYear();
}