import { LightningElement, api } from "lwc";

export default class BudgetFormSectionOFM extends LightningElement {
  @api record;
  @api objectApiName;
  @api review = false;

  get budgetId() {
    const submission = this.record || {};
    return (
      submission.FlowToolKit__Budget_OFM__c ||
      submission.Budget_OFM__c ||
      undefined
    );
  }

  @api validate() {
    return { isValid: true };
  }
}
