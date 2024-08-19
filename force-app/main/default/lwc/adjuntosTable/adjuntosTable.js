import { LightningElement, track } from 'lwc';
import getAdjuntos from '@salesforce/apex/AdjuntosController.getAdjuntos'; // Apex method to get records

export default class AdjuntosList extends LightningElement {
    @track adjuntosData = [];
    acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg']; // Define the accepted file formats

    connectedCallback() {
        this.loadAdjuntosData();
    }

    loadAdjuntosData() {
        getAdjuntos()
            .then(result => {
                this.adjuntosData = result.map(item => ({
                    ...item,
                    fileName: '', // Initialize fileName
                    boxClass: 'slds-box slds-box_xx-small slds-m-bottom_small' // Default box class
                }));
            })
            .catch(error => {
                console.error('Error loading adjuntos data', error);
            });
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        const recordId = event.detail.recordId;

        this.adjuntosData = this.adjuntosData.map(item => {
            if (item.Id === recordId) {
                return {
                    ...item,
                    fileName: uploadedFiles.length > 0 ? uploadedFiles[0].name : '', // Update fileName
                    boxClass: 'slds-box slds-box_xx-small slds-m-bottom_small slds-background_color_success slds-text_success' // Update box class
                };
            }
            return item;
        });
    }
}