import { LightningElement, wire } from 'lwc';
import basePath from '@salesforce/community/basePath';
import STUDENTPORTALICONS from '@salesforce/resourceUrl/SR_STUDENTPORTALASSETS';
import isGuest from '@salesforce/user/isGuest';

const baseImageUrl = `${STUDENTPORTALICONS}/StudentPortalAssests/Icons/Header-Icons/`;
export default class RevAdmNavigation extends LightningElement {
    loginUrl = `${basePath}/login`;
    logOutImageUrl = `${baseImageUrl}logout.png`;
    notificationImageUrl = `${baseImageUrl}notification.png`;
    showNotifications = false;


    get guestUser() {
        return isGuest;
    }
    get logOutPageUrl() {
        const sitePrefix = basePath.replace(/\/s$/i, "");
        const admissionPortalLoginPageUrl = `${basePath}/login`;
        return `${sitePrefix}/secur/logout.jsp?retUrl=${encodeURIComponent(admissionPortalLoginPageUrl)}`;
    }
    toggleNotificationHandler(event) {
        this.showNotifications = !this.showNotifications;
        if (this.showNotifications) {
            this.adjustCaretPosition(event.currentTarget);
        }
        this.manageListeners(event);
    }
    adjustCaretPosition(triggerElement) {
        window.requestAnimationFrame(() => {
            const menu = this.template.querySelector('.menu');
            const triggerRect = triggerElement.getBoundingClientRect();
            const menuRect = menu.getBoundingClientRect();
            const triggerCenter = triggerRect.left + triggerRect.width / 2;
            const menuLeft = menuRect.left;
            const caretLeft = (triggerCenter - menuLeft) - 7;
            menu.style.setProperty('--caret-left', `${caretLeft}px`)
        });
    }
    manageListeners(event) {
        if (this.showNotifications) {
            // Add an event listener to the document when any menu is open
            window.addEventListener('click', this.handleOutsideClick);
        } else {
            // Remove the event listener from the document when all menus are closed
            window.removeEventListener('click', this.handleOutsideClick);
        }
        // Stop the click from propagating to the document, which would immediately close the menu
        event.stopPropagation();
    }
    handleOutsideClick = (event) => {
        if (!this.template.contains(event.target)) {
            this.showNotifications = false;
            window.removeEventListener('click', this.handleOutsideClick);
        }
    }
    disconnectedCallback() {
        window.removeEventListener('click', this.handleOutsideClick);
    }
}