/**
 * @description       : 
 * @author            : owais.ahanger@cloudodyssey.co
 * @group             : 
 * @last modified on  : 06-04-2024
 * @last modified by  : owais.ahanger@cloudodyssey.co
**/
import { LightningElement } from 'lwc';
import basePath from '@salesforce/community/basePath';
import STUDENTPORTALICONS from '@salesforce/resourceUrl/SR_STUDENTPORTALASSETS';

const baseImageUrl = `${STUDENTPORTALICONS}/StudentPortalAssests/Icons/Header-Icons/`;

export default class RevStdHomeStudentLogOut extends LightningElement {
    logOutImageUrl = `${baseImageUrl}logout.png`;
    get logOutPageUrl() {

        const sitePrefix = basePath.replace(/\/s$/i, "");
        const studentPortalLoginPageUrl = `${basePath}/login`;
        return `${sitePrefix}/secur/logout.jsp?retUrl=${encodeURIComponent(studentPortalLoginPageUrl)}`;
    }
}