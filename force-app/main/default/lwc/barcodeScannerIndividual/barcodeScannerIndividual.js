/**
 * @description       : 
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 09-29-2023
 * @last modified by  : emeza@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   09-28-2023   emeza@freewayconsulting.com   Initial Version
**/
// barcodeScannerExample.js
import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import createLeads from '@salesforce/apex/BarcodeScannerController.createLeads';

export default class BarcodeScannerExample extends LightningElement {
    myScanner;
    scanButtonDisabled = false;
    scannedBarcode = '';

    // When component is initialized, detect whether to enable Scan button
    connectedCallback() {
        this.myScanner = getBarcodeScanner();
        if (this.myScanner == null || !this.myScanner.isAvailable()) {
            this.scanButtonDisabled = true;
        }
    }

    handleBeginScanClick(event) {
        // Reset scannedBarcode to empty string before starting new scan
        this.scannedBarcode = '';

        // Make sure BarcodeScanner is available before trying to use it
        // Note: We _also_ disable the Scan button if there's no BarcodeScanner
        if (this.myScanner != null && this.myScanner.isAvailable()) {
            const scanningOptions = {
                barcodeTypes: [this.myScanner.barcodeTypes.QR],
                instructionText: 'Escanea el código QR',
                successText: 'Escaneo completo.'
            };
            this.myScanner
                .beginCapture(scanningOptions)
                .then((result) => {
                    console.log(result);

                    // Do something with the barcode scan value:
                    // - look up a record
                    // - create or update a record
                    // - parse data and put values into a form
                    // - and so on; this is YOUR code
                    // Here, we just display the scanned value in the UI
                    this.scannedBarcode = result.value;
                    //
                    try {
                        let resultValue = result.value;
                        let myArrayData = resultValue.split("||");
                        let company = myArrayData[1];
                        let contactData = myArrayData[0];
                        let myArrayName = contactData.split("|");
                        let firstName = myArrayName[0];
                        let lastName = myArrayName[1];
                        let email = myArrayName[2];
                        let address = myArrayName[3];
                        let myArrayAddress = address.split(", ");
                        let city = myArrayAddress[0];
                        let state = myArrayAddress[1];
                        let phone = myArrayName[4];

                        createLeads({ firstName : firstName,lastName : lastName, org:company, email : email, phone : phone, city:city, state:state})
                        .then(result => {
                            if(result){
                                showSuccessToast();
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__recordPage',
                                    attributes: {
                                        recordId: result,
                                        actionName: 'view'
                                    }
                                });
                            }
                        })
                        .catch(error => {
                            console.log('error');
                        });
                    } catch (e) {
                        console.error(e);
                        console.error('e.name => ' + e.name );
                        console.error('e.message => ' + e.message );
                        console.error('e.stack => ' + e.stack );
                    }
                    

                    //
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Escaneo correcto',
                            message: 'QR escaneado correctamente.',
                            variant: 'success'
                        })
                    );
                })
                .catch((error) => {
                    // Handle cancellation and unexpected errors here
                    console.error(error);

                    if (error.code == 'userDismissedScanner') {
                        // User clicked Cancel
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Escaneo cancelado',
                                message:
                                    'Has cerrado la sesión antes de completar el escaneo.',
                                mode: 'sticky'
                            })
                        );
                    }
                    else { 
                        // Inform the user we ran into something unexpected
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error al escanear',
                                message:
                                    'Hubo un error al intentar escanear el código QR: ' +
                                    error.message,
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                    }
                })
                .finally(() => {
                    console.log('#finally');

                    // Clean up by ending capture,
                    // whether we completed successfully or had an error
                    this.myScanner.endCapture();
                });
        } else {
            // BarcodeScanner is not available
            // Not running on hardware with a camera, or some other context issue
            console.log(
                'Scan Barcode button should be disabled and unclickable.'
            );
            console.log('Somehow it got clicked: ');
            console.log(event);

            // Let user know they need to use a mobile phone with a camera
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Barcode Scanner no se encuentra disponible',
                    message:
                        'Intenta de nuevo desde un dispositivo con la aplicación de Salesforce',
                    variant: 'error'
                })
            );
        }
    }
}