import { LightningElement, api } from 'lwc';

export default class BannerMessages extends LightningElement {
    @api error;
    @api success;
    @api warning;
}