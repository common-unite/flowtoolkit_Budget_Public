import { LightningElement, api } from "lwc";

export default class BudgetFormSectionNPC extends LightningElement {
  @api record;
  @api objectApiName;
  @api review = false;

  get budgetId() {
    const submission = this.record || {};
    return (
      submission.FlowToolKit__Budget_NPC__c ||
      submission.Budget_NPC__c ||
      undefined
    );
  }

  @api validate() {
    return { isValid: true };
  }
}
