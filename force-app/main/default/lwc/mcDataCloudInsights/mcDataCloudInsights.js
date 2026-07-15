import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import query from '@salesforce/apex/MCDataCloudController.query';

const ALL_LABEL = 'All Channels';

const DEFAULT_CHANNELS = [
    {
        label: 'All Channels',
        dloName: 'ALL',
        filterColumn: '',
        identifierType: 'mixed',
        orderByColumn: '',
        icon: 'standard:marketing_actions'
    },
    {
        label: 'Email',
        dloName: 'SFMC_Email_Analytics_DE__dlm',
        filterColumn: 'emailaddress__c',
        identifierType: 'email',
        orderByColumn: 'sentdate__c',
        icon: 'standard:email'
    },
    {
        label: 'SMS',
        dloName: 'SFMC_SMS_Analytics_DE__dlm',
        filterColumn: 'mobile__c',
        identifierType: 'mobile',
        orderByColumn: 'actiondatetime__c',
        icon: 'standard:sms'
    },
    {
        label: 'WhatsApp',
        dloName: 'SFMC_Whatsapp_Analytics_DE__dlm',
        filterColumn: 'mobilenumber__c',
        identifierType: 'mobile',
        orderByColumn: 'lasteventdateutc__c',
        icon: 'standard:messaging_session'
    }
];

const DATE_RANGE_OPTIONS = [
    { label: 'Last 7 days',  value: '7d'  },
    { label: 'Last 30 days', value: '30d' },
    { label: 'Last 90 days', value: '90d' },
    { label: 'All time',     value: 'all' }
];

const ICON_BY_TYPE = {
    Sent: 'standard:email',
    Send: 'standard:email',
    Delivered: 'standard:email_chatter',
    Open: 'standard:email_chatter',
    Opened: 'standard:email_chatter',
    Click: 'standard:event',
    Clicked: 'standard:event',
    Bounce: 'standard:warning',
    Bounced: 'standard:warning',
    SoftBounce: 'standard:warning',
    HardBounce: 'standard:warning',
    Unsubscribe: 'standard:logout',
    Unsubscribed: 'standard:logout',
    SpamComplaint: 'standard:warning',
    Failed: 'standard:warning',
    Pending: 'standard:approval',
    Queued: 'standard:approval',
    Read: 'standard:email_chatter'
};

const BADGE_BY_TYPE = {
    Sent: 'slds-badge slds-theme_default',
    Send: 'slds-badge slds-theme_default',
    Delivered: 'slds-badge slds-theme_success',
    Open: 'slds-badge slds-theme_success',
    Opened: 'slds-badge slds-theme_success',
    Click: 'slds-badge slds-theme_success',
    Clicked: 'slds-badge slds-theme_success',
    Bounce: 'slds-badge slds-theme_error',
    Bounced: 'slds-badge slds-theme_error',
    SoftBounce: 'slds-badge slds-theme_warning',
    HardBounce: 'slds-badge slds-theme_error',
    Unsubscribe: 'slds-badge slds-theme_warning',
    Unsubscribed: 'slds-badge slds-theme_warning',
    SpamComplaint: 'slds-badge slds-theme_error',
    Failed: 'slds-badge slds-theme_error',
    Pending: 'slds-badge slds-theme_default',
    Queued: 'slds-badge slds-theme_default',
    Read: 'slds-badge slds-theme_success'
};

const SENT_TYPES   = new Set(['Sent','Send','Delivered']);
const OPEN_TYPES   = new Set(['Open','Opened','Read']);
const CLICK_TYPES  = new Set(['Click','Clicked']);
const BOUNCE_TYPES = new Set(['Bounce','Bounced','SoftBounce','HardBounce','Failed']);

export default class McDataCloudInsights extends LightningElement {
    @api recordId;

    // Design attributes
    @api defaultChannel = 'Email';
    @api defaultDateRange = '30d';
    @api rowLimit       = 200;
    @api cardTitle      = 'Marketing Cloud Communications';

    @track selectedChannel   = 'Email';
    @track selectedDateRange = '30d';
    @track events = [];
    identifier;
    total = 0;
    error;
    isLoading = false;
    wired;
    lastUpdated;

    connectedCallback() {
        this.selectedChannel   = this.defaultChannel   || 'Email';
        this.selectedDateRange = this.defaultDateRange || '30d';
    }

    /* ------------------------- Channel resolution ------------------------- */

    get channels() {
        return DEFAULT_CHANNELS;
    }

    get channelOptions() {
        return this.channels.map(c => ({ label: c.label, value: c.label }));
    }

    get dateRangeOptions() { return DATE_RANGE_OPTIONS; }

    get currentChannel() {
        return this.channels.find(c => c.label === this.selectedChannel) || this.channels[0];
    }

    get currentDlo()            { return this.currentChannel ? this.currentChannel.dloName        : null; }
    get currentFilterColumn()   { return this.currentChannel ? this.currentChannel.filterColumn   : null; }
    get currentIdentifierType() { return this.currentChannel ? this.currentChannel.identifierType : null; }
    get currentOrderByColumn()  { return this.currentChannel ? this.currentChannel.orderByColumn  : null; }
    get currentCardIcon()       { return this.currentChannel && this.currentChannel.icon          ? this.currentChannel.icon : 'standard:email'; }

    /* ------------------------------- Wire ------------------------------- */

    @wire(query, {
        recordId:       '$recordId',
        dloName:        '$currentDlo',
        filterColumn:   '$currentFilterColumn',
        identifierType: '$currentIdentifierType',
        orderByColumn:  '$currentOrderByColumn',
        rowLimit:       '$rowLimit',
        dateRange:      '$selectedDateRange'
    })
    wiredHandler(result) {
        this.wired = result;
        this.isLoading = !result.data && !result.error;
        if (result.data) {
            this.identifier = result.data.identifier;
            this.total      = result.data.total || 0;
            this.events     = result.data.events || [];
            this.error      = undefined;
            this.lastUpdated = new Date();
        } else if (result.error) {
            this.error  = this.extractError(result.error);
            this.events = [];
            this.total  = 0;
        }
    }

    /* ----------------------------- Summary ----------------------------- */

    get summary() {
        const s = { sends: 0, opens: 0, clicks: 0, bounces: 0 };
        for (const e of this.events) {
            const t = e.eventType || '';
            if (SENT_TYPES.has(t))   s.sends++;
            if (OPEN_TYPES.has(t))   s.opens++;
            if (CLICK_TYPES.has(t))  s.clicks++;
            if (BOUNCE_TYPES.has(t)) s.bounces++;
        }
        return s;
    }

    get sendsCount()   { return this.summary.sends;   }
    get opensCount()   { return this.summary.opens;   }
    get clicksCount()  { return this.summary.clicks;  }
    get bouncesCount() { return this.summary.bounces; }

    get showSummary() {
        // hide for SMS / WhatsApp where the Sends/Opens/Clicks/Bounces taxonomy
        // doesn't fully map; show for Email and All Channels.
        return this.selectedChannel === 'Email' || this.selectedChannel === 'All Channels';
    }

    /* ----------------------------- Getters ----------------------------- */

    get hasEvents() { return !this.isLoading && !this.error && this.events.length > 0; }
    get isEmpty()   { return !this.isLoading && !this.error && this.events.length === 0; }

    get filterLabel() {
        if (!this.identifier) return '';
        return `Filtered by ${this.identifier}`;
    }

    get lastUpdatedLabel() {
        if (!this.lastUpdated) return '';
        const seconds = Math.floor((new Date() - this.lastUpdated) / 1000);
        if (seconds < 5) return 'Updated just now';
        if (seconds < 60) return `Updated ${seconds}s ago`;
        const minutes = Math.floor(seconds / 60);
        if (minutes < 60) return `Updated ${minutes}m ago`;
        return `Updated ${Math.floor(minutes / 60)}h ago`;
    }

    get decoratedEvents() {
        return this.events.map((e, i) => this.decorate(e, i));
    }

    /* ----------------------------- Handlers ---------------------------- */

    handleChannelChange(e) {
        this.selectedChannel = e.detail.value;
        this.events = [];
        this.error = undefined;
    }

    handleDateRangeChange(e) {
        this.selectedDateRange = e.detail.value;
    }

    handleRefresh() {
        this.isLoading = true;
        return refreshApex(this.wired).finally(() => {
            this.isLoading = false;
            this.lastUpdated = new Date();
        });
    }

    /* ----------------------------- Helpers ----------------------------- */

    decorate(e, idx) {
        const type = e.eventType || 'Event';
        const channelPrefix = (this.selectedChannel === 'All Channels' && e.channel)
            ? `${e.channel} · ` : '';
        const whatsAppDetails = this.whatsAppDetails(e);
        return {
            ...e,
            key:        idx + '|' + (e.eventDate || '') + '|' + type,
            icon:       ICON_BY_TYPE[type] || this.currentCardIcon,
            badgeClass: BADGE_BY_TYPE[type] || 'slds-badge',
            title:      e.subjectLine || e.messageName || type,
            subtitle:   channelPrefix + (
                e.journeyName ? 'Journey: ' + e.journeyName
                : e.messageName && e.subjectLine ? e.messageName
                : (e.channel || '')),
            hasWhatsAppDetails: whatsAppDetails.length > 0,
            whatsAppDetails
        };
    }

    whatsAppDetails(e) {
        const isWhatsApp = this.selectedChannel === 'WhatsApp'
            || e.channel === 'WhatsApp'
            || e.channelId
            || e.channelName
            || e.sendType;
        if (!isWhatsApp) return [];

        return [
            { label: 'Sender', value: e.channelId },
            { label: 'To', value: e.mobileNumber || e.recipient },
            { label: 'Institution', value: e.channelName },
            { label: 'Send Type', value: e.sendType }
        ].filter(item => item.value);
    }

    extractError(err) {
        if (!err) return 'Unknown error';
        if (typeof err === 'string') return err;
        if (err.body && err.body.message) return err.body.message;
        if (Array.isArray(err.body)) return err.body.map(x => x.message).join(', ');
        return err.message || 'Failed to load';
    }
}