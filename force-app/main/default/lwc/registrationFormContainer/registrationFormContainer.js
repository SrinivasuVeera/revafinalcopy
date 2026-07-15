import { LightningElement, wire, api, track } from 'lwc';
import ApplicationPortalBannerPC from '@salesforce/resourceUrl/ApplicationPortalBannerPC';
import ApplicationPortalBannerMobile from '@salesforce/resourceUrl/ApplicationPortalBannerMobile';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getSiteUrl from '@salesforce/apex/RegistrationFormUtility.getSiteURL';
import isSandboxOrg from '@salesforce/apex/RegistrationFormUtility.isSandboxOrg';
const UTM_SOURCE_DIRECT = 'Direct';
const UTM_SOURCE_ORGANIC = 'Organic';
const PRODUCTION_URL = 'https://www.reva.edu.in/new-admissions';
const MS4_URL = 'https://go.demo.pardot.com/l/553903/2022-12-23/r41';
const PAYMENT_PAGE_LINKEXT = '/s/payment-page?contactId=';
export default class RegistrationFormContainer extends NavigationMixin(LightningElement) {
  backgroundImagePC = ApplicationPortalBannerPC;
  backgroundImageMobile = ApplicationPortalBannerMobile;
  referrer = '';
  contactId;
  loader = false;
  error;
  email = '';
  currentPage;
  emailParameter = false;
  @api propYear;
  @track callCount = 1;
  @wire(CurrentPageReference)
  getStateParameters(currPage) {
    this.currentPage = currPage;

    this.referrer = document.referrer ? document.referrer : '';
    this.emailParameter = currPage.state.c__email;
    if (this.emailParameter) {
      this.email = currPage.state.c__email
    }
  }
  @wire(getSiteUrl)
  wired_getSiteUrl({ data, error }) {
    if (data) {
      this.siteUrl = data;
      this.error = undefined;
    } else if (error) {
      this.siteUrl = undefined;
      this.error = error;
    }
  };
  get showRegistrationFlow() {
    return this.referrer !== undefined;
  }
  @wire(isSandboxOrg)
  wired_isSandboxOrg({ data, error }) {
    if (data) {
      this.isSandboxOrg = data;
      this.error = undefined;
    } else if (error) {
      this.isSandboxOrg = undefined;
      this.error = error;
    }
  }
  get flowInputVariables() {
    const flowInput = [
      {
        name: 'varReferrer',
        type: 'String',
        value: this.referrer
      },
      {
        name: 'varInputEmail',
        type: 'String',
        value: this.email
      },
    ];
    return flowInput;
  }
  handleStatusChange(event) {
    let outputVars = event.detail.outputVariables;
    if (outputVars.length > 0) {
      let lastElementFlowName = outputVars[outputVars.length - 1].flowName;
      if (lastElementFlowName === "Registration_Main_Screen") {
        this.callCount = 1;
      }
      else if (lastElementFlowName === "Registration_OTP_Screen_for_Resend_SMS") {
        this.callCount = 2;
      }
      else if (lastElementFlowName === "Registration_Program_Screen") {
        this.callCount = 2;
      }
    }
    const eventToSend = new CustomEvent('sendcallcount', {
      detail: { count: this.callCount }
    });
    this.dispatchEvent(eventToSend);
    if (event.detail.status === 'FINISHED') {
      this.loader = true;
      var outputVariables = event.detail.outputVariables;
      var outputVar;
      for (var i = 0; i < outputVariables.length; i++) {
        outputVar = outputVariables[i];
        if (outputVar.name === "contactId" && outputVar.value != null) {

          this.contactId = outputVar.value;
        } else if (outputVar.name === "Id" && outputVar.value != null) {

          this.contactId = outputVar.value;
        }
      }
      const navConfig = {
        type: 'standard__webPage',
        attributes: {
          url: this.siteUrl + PAYMENT_PAGE_LINKEXT + this.contactId
        }
      }

      this[NavigationMixin.Navigate](navConfig);
    }
  }
}