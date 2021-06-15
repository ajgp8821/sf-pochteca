import { LightningElement, track,api } from 'lwc';
import createAccounts from '@salesforce/apex/AccountController.createAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns=[
    { "label" : "Name", "apiName" : "Name" ,"fieldType":"text","objectName":"Account"}, 
    { "label" : "Phone", "apiName" : "Phone" ,"fieldType":"text","type":"phone","objectName":"Account"},
    { "label" : "Est", "apiName" : "POCH_Estatus__c","fieldType":"picklist","objectName":"Account" }
];

export default class DynamicTableTest extends LightningElement {
   @track records;
   @api recordJson;
   @track columns=columns;
   submit(event) {
        var table = this.template.querySelector("c-dynamic-table");
        if(table!=undefined)
        {
            this.records = table.retrieveRecords();

            console.log(JSON.stringify(this.records));
            createAccounts({ accounts : this.records })
            .then(result => {
                this.message = result;
                this.error = undefined;                
                
                //this.accountRecList = [];
                if(this.message !== undefined) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Accounts Created!',
                            variant: 'success',
                        }),
                    );
                }

                console.log(JSON.stringify(result));
                console.log("result", this.message);
            })
            .catch(error => {
                this.message = undefined;
                this.error = error;
                
                console.log("error", JSON.stringify(this.error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating records',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
        }
    }
}