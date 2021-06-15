import { LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertAccounts from '@salesforce/apex/addDeleteRowDynamicComponnetClass.insertAccounts';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import Phone_FIELD from '@salesforce/schema/Account.Phone';
import Employee_FIELD from '@salesforce/schema/Account.NumberOfEmployees';
import Website_FIELD from '@salesforce/schema/Account.Website';

export default class AddDeleteRowDynamicComponent extends LightningElement {
    @track accRecord = {Name : NAME_FIELD,NumberOfEmployees : Employee_FIELD,Phone : Phone_FIELD,Website : Website_FIELD,key : Math.random().toString(36).substring(2, 15)};
    @track accRecords = [];
    toggleSaveLabel = 'Save';
    NumberOfEmployees

    @track accountName;  
    @track accountRecordId;  
 
    onAccountSelection(event){  
    this.accountName = event.detail.selectedValue;  
    this.accountRecordId = event.detail.selectedRecordId;  
    }  

    connectedCallback(){
        console.log('  === connectedCallback === ');
        /*for(var i=0; i < 4 ; i++){
            this.accRecords.push({Name : NAME_FIELD,NumberOfEmployees : Employee_FIELD,Phone : Phone_FIELD,Website : Website_FIELD,key : Math.random().toString(36).substring(2, 15)});
        } */
        this.accountTempRecords();
    }
    
    accountTempRecords(){
        this.accRecords = [];
        for(var i=0; i < 4 ; i++){
            this.accRecords.push({Name : NAME_FIELD,NumberOfEmployees : Employee_FIELD,Phone : Phone_FIELD,Website : Website_FIELD,key : Math.random().toString(36).substring(2, 15)});
        }
    }

    addRow(){
        const len = this.accRecords.length;
        this.accRecords.push({Name : NAME_FIELD,NumberOfEmployees : Employee_FIELD,Phone : Phone_FIELD,Website : Website_FIELD,key : Math.random().toString(36).substring(2, 15)});
    }

    removeRow(event){
        const indexPos = event.currentTarget.name;
        let remList = [];
        remList = this.accRecords;
        remList.splice(indexPos,1);
        this.accRecords = remList;
    }

    handleNameChange(event){
        let foundelement = this.accRecords.find(ele => ele.key == event.target.dataset.id);
        foundelement.Name = event.target.value;
        this.accRecords = [...this.accRecords];
        //console.log(' ==> ' +  JSON.stringify(this.accRecords));
    }

    handleEmpChange(event){
        let foundelement = this.accRecords.find(ele => ele.key == event.target.dataset.id);
        foundelement.NumberOfEmployees = event.target.value;
        this.accRecords = [...this.accRecords];
        //console.log(' ==> ' +  JSON.stringify(this.accRecords));
    }

    handlePhoneChange(event){
        let foundelement = this.accRecords.find(ele => ele.key == event.target.dataset.id);
        foundelement.Phone = event.target.value;
        this.accRecords = [...this.accRecords];
        //console.log(' ==> ' +  JSON.stringify(this.accRecords));
    }

    handleWebsiteChange(event){
        let foundelement = this.accRecords.find(ele => ele.key == event.target.dataset.id);
        foundelement.Website = event.target.value;
        this.accRecords = [...this.accRecords];
        //console.log(' ==> ' +  JSON.stringify(this.accRecords));
    }

    handleSave(){
        this.toggleSaveLabel = 'Saving...'
        let toSaveList = this.accRecords.slice(0);;
        toSaveList.forEach((element, index) => {
            console.log( index + ' ==> ' + JSON.stringify(element.Name));
            let eleType = typeof element.Name;
            console.log( 'typeof ==> ' + eleType);
            if(element.Name === '' || eleType=='object'){
                toSaveList.splice(index);
            }
        });  
        console.log( ' Final Save ==> ' + JSON.stringify(toSaveList));

        insertAccounts({accList : toSaveList})
        .then(() => {
            this.toggleSaveLabel = 'Saved';
            console.log('Success Log');
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : `Records saved succesfully!`,
                    variant : 'success',
                }),
            )
            this.accountTempRecords();
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.record = undefined;
            console.log("Error in Save call back:", this.error);
        })
        .finally(() => {
            setTimeout(() => {
                this.toggleSaveLabel = 'Save';
            }, 3000);
        });
    }
 
}