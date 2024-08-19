/**
 * @description       : Component to Preview of file on button click
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 08-30-2023
 * @last modified by  : emeza@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   08-30-2023   emeza@freewayconsulting.com   Initial Version
**/
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getRelatedFilesByRecordId from '@salesforce/apex/filePreviewAndDownloadController.getRelatedFilesByRecordId'
import {NavigationMixin} from 'lightning/navigation'
import QUOTE_FIELD from "@salesforce/schema/Grupo_de_productos_a_aprobar__c.Cotizacion__c";

const FIELDS = [QUOTE_FIELD];

export default class FilePreviewAndDownloads extends NavigationMixin(LightningElement) {

    @api recordId;
    @api quote;
    @api quoteId;
    connectedCallback() {
       console.log("$recordId");
    }
    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredRecord({ error, data }) {
    if (error) {
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading Attachments",
          message,
          variant: "error",
        }),
      );
    } else if (data) {
        console.log(data)
      this.quote = data;
      this.quoteId = this.quote.fields.Cotizacion__c.value;
      console.log(this.quoteId);
    }
  }

    filesList =[]
    @wire(getRelatedFilesByRecordId, {recordId: "$quoteId"})
    wiredResult({data, error}){
        
        if(data){
            console.log(data)
            this.filesList = Object.keys(data).map(item=>({"label":data[item],
             "value": item,
             "url":`/sfc/servlet.shepherd/document/download/${item}`
            }))
            console.log(this.filesList)
        }
        if(error){
            
            console.log(error)
        }
    }
    previewHandler(event){
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({
            type:'standard__namedPage',
            attributes:{
                pageName:'filePreview'
            },
            state:{
                selectedRecordId: event.target.dataset.id
            }
        })
    }
}