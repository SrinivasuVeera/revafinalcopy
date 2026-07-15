/**
 * @description       : 
 * @author            : owais.ahanger@cloudodyssey.co
 * @group             : 
 * @last modified on  : 06-04-2024
 * @last modified by  : owais.ahanger@cloudodyssey.co
**/
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';

export default class RevStdHomeStudentSearch extends NavigationMixin(LightningElement) {
    showSearch = false;
    inputValue = '';

    searchDataHandler(event) {
        this.inputValue = event.target.value;

        if (this.inputValue.length >= 3) {
            this.showSearch = true;
        } else {
            this.showSearch = false;
        }
    }

    searchFocusHandler() {
        if (this.inputValue.length >= 3) {
            this.showSearch = true;
        }
    }
    searchBlurHandler() {

        setTimeout(() => {

            this.showSearch = false; // Hide the flyout
        }, 400);
    }
    handleSearchKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            this.navigateToSearchPage();

        }
    }

    navigateToSearchPage() {
        this.searchBlurHandler();
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: `${basePath}/global-search/${this.inputValue}`
            }
        });

    }
}