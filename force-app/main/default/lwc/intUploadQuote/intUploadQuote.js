import {  LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/INT_UploadQuoteController.uploadFile'
import LightningPrompt from 'lightning/prompt';

export default class intUploadQuote extends LightningElement {
    
    @api recordId;
    @track isLoading = false;
    @track showError = false;
    @track errorMessage = ''; 
    /**
    * @description Function to process the records in CSV attachment and send them to APEX
    **/
    openfileUpload(event) {
      
      var grupoProductosId = this.recordId.substring(0, 15);
      console.log('idRecord::' + grupoProductosId);
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
          console.log('body'+body);
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
          
          //var headers = 'Quote Id.,Quote Line Id.';
          //var headers = '';

          var headers = body.substring(0, body.indexOf('\n')); // Obtener la primera línea que contiene los encabezados
          console.log('headers: '+headers);
          var bodyWithoutHeaders = body.substring(body.indexOf('\n') + 1); // Obtener el cuerpo del CSV sin los encabezados
          console.log('bodyWithoutHeaders:'+bodyWithoutHeaders);
          var headersWithoutSpecialChars = headers.replace(/[:.óú%()]/g, '');
          console.log('headersWithoutSpecialChars:'+headersWithoutSpecialChars);


          var csvConcated  = headersWithoutSpecialChars.concat('\n' + bodyWithoutHeaders);
          console.log('csvConcated: '+ csvConcated);
          // If file contains headers replace csvConcated var with body variable
          //var json =  CSVToJSON(csvConcated.replace(" ",""));
          var json =  CSVToJSON(csvConcated);
          // Javascript automatically create the list with one more item, delete last one
          json.splice(-1);

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

          // With data ready Apex method is called sending QuoteLineId and CSV data as string params
          uploadFile({csvData : JSON.stringify(json), grupoProductosId:grupoProductosId} )
            .then((result) => {

              if (result.includes('Error')) {
                //this.showToast('¡Error! Valida la estructura del archivo.', result, 'Error');
                //this.showError = true;
                //this.errorMessage = 'Valida la estructura del archivo. \n'+ result;
                //this.openModal(result);
                if(result.includes('Error. Se cargó')){
                  this.showError = true;
                this.errorMessage = 'Valida la estructura del archivo. \n'+ result;
                }else{
                  this.showToast('¡Error! Valida la estructura del archivo.', result, 'Error');
                }

            } else {
                let successMessage = `Archivo procesado correctamente!`;
                this.showToast('¡Éxito!', successMessage, 'Success', 'dismissable');
                this.updateRecordView();
            }

            })
            .catch((error) => {
              let errorMessage ;
                if ( error.body && error.body.message) {
                    errorMessage =error.body.message;
                }
                this.showToast('¡Error! Valida la estructura del archivo.', errorMessage, 'Error');
            }).finally(()=>{
                this.handleIsLoading(false);
            });
        }
    }
    /**
    * @description Function to refresh standard components in record page

    **/
    updateRecordView() {
      setTimeout(() => {
           eval("$A.get('e.force:refreshView').fire();");
      }, 1000);
   }

    /**
    * @description Function to show/hide spinner

    **/
    handleIsLoading(isLoading) {
        this.isLoading = isLoading;
    }
    /**
    * @description Function to show toas by params title, message, variant and mode

    **/

    openModal(result) {
      var uno = 'hola' + '<br>';
            var dos = 'hola2';

        LightningPrompt.open({
            message: result,
            //theme defaults to "default"
            //label: 'Please Respond', // this is the header text

            defaultValue:"Hola,\n\nEste es un mensaje\ncon saltos de línea." //this is optional
        }).then((result) => {
            //Prompt has been closed
            //result is input text if OK clicked
            //and null if cancel was clicked
        });
    







    }

    closeModal() {
        this.showModal = false;
    }

    closeError() {
        this.showError = false;
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode || 'sticky'
        });
        this.dispatchEvent(event);
    }
}