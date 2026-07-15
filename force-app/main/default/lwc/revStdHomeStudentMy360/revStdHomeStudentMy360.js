/**
 * @description       : 
 * @author            : owais.ahanger@cloudodyssey.co
 * @group             : 
 * @last modified on  : 06-04-2024
 * @last modified by  : owais.ahanger@cloudodyssey.co
**/
import { LightningElement } from 'lwc';
import STUDENTPORTALICONS from '@salesforce/resourceUrl/SR_STUDENTPORTALASSETS';
import basePath from '@salesforce/community/basePath';
const baseImageUrl = `${STUDENTPORTALICONS}/StudentPortalAssests/Icons/Header-Icons/`;

export default class RevStdHomeStudentMy360 extends LightningElement {
    my360ImageUrl = `${baseImageUrl}my-360.png`;
    my360PageUrl = `${basePath}/student360`;
}