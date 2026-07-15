/* navigationBar.js */
import { LightningElement, track } from 'lwc';

export default class SdreNavigationBar extends LightningElement {
    @track isMobileMenuOpen = false;

    get navLinksClass() {
        return this.isMobileMenuOpen ? 'nav-links active' : 'nav-links';
    }

    get menuIconClass() {
        return this.isMobileMenuOpen ? 'menu-icon active' : 'menu-icon';
    }

    toggleMobileMenu() {
        this.isMobileMenuOpen = !this.isMobileMenuOpen;
    }

    handleLogoClick(event) {
        event.preventDefault();
        // Navigate to home or handle logo click
        this.navigateToPage('home');
        this.closeMobileMenu();
    }

    handleNavClick(event) {
        event.preventDefault();
        const page = event.target.dataset.page;
        this.navigateToPage(page);
        this.closeMobileMenu();
    }

    handleLoginClick() {
        // Handle login button click
        this.navigateToPage('login');
        this.closeMobileMenu();
    }

    navigateToPage(page) {
        // For Experience sites, you can use NavigationMixin
        // or dispatch custom events to parent components
        const navEvent = new CustomEvent('navigate', {
            detail: { page: page }
        });
        this.dispatchEvent(navEvent);
    }

    closeMobileMenu() {
        this.isMobileMenuOpen = false;
    }

    // Close mobile menu when clicking outside
    renderedCallback() {
        if (this.isMobileMenuOpen) {
            document.addEventListener('click', this.handleDocumentClick.bind(this));
        }
    }

    handleDocumentClick(event) {
        const navbar = this.template.querySelector('.navbar');
        if (navbar && !navbar.contains(event.target)) {
            this.closeMobileMenu();
            document.removeEventListener('click', this.handleDocumentClick.bind(this));
        }
    }
}