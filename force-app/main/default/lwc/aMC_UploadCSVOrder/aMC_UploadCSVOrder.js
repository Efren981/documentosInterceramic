import {  LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/AMC_UploadCSVOrderController.uploadFile'

export default class AMC_UploadCSVOrder extends LightningElement {
    // Opportunity Id  from the present record
    @api recordId;
    @track isLoading = false;
    /**
    * @description Function to process the records in CSV attachment and send them to APEX
    * @author emeza@freewayconsulting.com | 03-28-2022
    **/
    openfileUpload(event) {
        // Start spinner
        this.handleIsLoading(true);
      //Get file definition in a constant
        const file = event.target.files[0];
        //Instance file reader to read content as text
        var reader = new FileReader();
        reader.readAsText(file, 'UTF-8');
        reader.onload = () => {
          //Get the file body as text
          var body = reader.result;
          console.log(body);
          //function to convert csv to JSON
          const CSVToJSON = (data, delimiter = ',') => {
            const titles = data.slice(0, data.indexOf('\n')).split(delimiter);
            return data
              .slice(data.indexOf('\n') + 1)
              .split(/\r\n|\n|\r/)
              .map(v => {
                const values = v.split(delimiter);
                return titles.reduce(
                  (obj, title, index) => ((obj[title] = values[index]), obj),
                  {}
                );
              });
          };
          // Add headers to CSV text and concate them
          var headers = 'Producto,Cantidad\n';
          var csvConcated  = headers.concat(body);
          // If file contains headers replace csvConcated var with body variable
          var json =  CSVToJSON(csvConcated.replace(" ",""));
          // Javascript automatically create the list with one more item, delete last one
          json.splice(-1);
          console.log(json);
          // At the end of the JSON appear \r items and spaces, this function replace them with empty string
          json.forEach(function(e, i) {
            // Iterate over the keys of object
            Object.keys(e).forEach(function(key) {

              // Copy the value
              var val = e[key],
                newKey = key.replace(/\s+/g, '');

              // Remove key-value from object
              delete json[i][key];

              // Add value with new key
              json[i][newKey] = val;
            });
          });
          console.log(json);
          // With data ready Apex method is called sending OpportunityId and CSV data as string params
          uploadFile({ opportunityId: this.recordId, csvData : JSON.stringify(json)})
            .then((result) => {
              let successMessage = `Archivo procesado correctamente!`;
              this.showToast('¡Éxito!', successMessage, 'Success', 'dismissable');
              this.updateRecordView();
            })
            .catch((error) => {
              let errorMessage ;
                if ( error.body && error.body.message) {
                    errorMessage =error.body.message;
                }
                this.showToast('¡Error!', errorMessage, 'Error', 'dismissable');
            }).finally(()=>{
                this.handleIsLoading(false);
            });
        }
    }
    /**
    * @description Function to refresh standard components in record page
    * @author emeza@freewayconsulting.com | 03-28-2022
    **/
    updateRecordView() {
      setTimeout(() => {
           eval("$A.get('e.force:refreshView').fire();");
      }, 1000);
   }

    /**
    * @description Function to show/hide spinner
    * @author emeza@freewayconsulting.com | 03-28-2022
    **/
    handleIsLoading(isLoading) {
        this.isLoading = isLoading;
    }
    /**
    * @description Function to show toas by params title, message, variant and mode
    * @author emeza@freewayconsulting.com | 03-28-2022
    **/
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
}