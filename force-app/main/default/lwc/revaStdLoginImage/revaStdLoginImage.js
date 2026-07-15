import { LightningElement, track } from 'lwc';
import STUDENTPORTALICONS from '@salesforce/resourceUrl/SR_STUDENTPORTALASSETS';

const baseImageUrl = `${STUDENTPORTALICONS}/StudentPortalAssests/Logos/`;

export default class RevaStdLoginImage extends LightningElement {

    revaStdLoginImage = `${baseImageUrl}login-logo.png`;
    revaUniversityLogoUrl = `${baseImageUrl}reva-university.png`;

}