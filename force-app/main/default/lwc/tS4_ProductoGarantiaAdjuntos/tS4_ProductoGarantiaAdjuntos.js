import { LightningElement, track, api } from 'lwc';
import getFiles from '@salesforce/apex/TS4_AdjuntosController.getFiles';
import uploadFiles from '@salesforce/apex/TS4_AdjuntosController.uploadFiles';
import deleteFile from '@salesforce/apex/TS4_AdjuntosController.deleteFile';
import updateFile from '@salesforce/apex/TS4_AdjuntosController.updateFile';

export default class TS4_ProductoGarantiaAdjuntos extends LightningElement {
    @api recordId; // El ID del producto relacionado
    @track adjuntos = [];
    @track evidencias = [];
    @track isModalOpen = false;
    @track fileUploadedA = false;
    @track fileUploadedB = false;

    connectedCallback() {
        this.loadFiles();
    }

    loadFiles() {
        getFiles({ productId: this.recordId })
            .then(result => {
                // Asegúrate de que result no sea undefined o null
                if (result) {
                    this.adjuntos = result.filter(file => file.Tipo__c === 'Adjunto') || [];
                    this.evidencias = result.filter(file => file.Tipo__c === 'Evidencia de Garantía') || [];
                }
            })
            .catch(error => {
                console.error('Error loading files:', error);
            });
    }

    handleShowModal() {
        this.isModalOpen = true;
        this.fileUploadedA = false;
        this.fileUploadedB = false;
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }

    handleFileUploadA(event) {
        const files = event.target.files;
        if (!files.length) return;

        const fileList = [];
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const reader = new FileReader();
            reader.onloadend = () => {
                const base64Data = reader.result.split(',')[1];
                fileList.push({
                    Name: file.name,
                    Body: base64Data
                });

                if (fileList.length === files.length) {
                    this.uploadFiles(fileList, 'Adjunto');
                }
            };
            reader.readAsDataURL(file);
        }
    }

    handleFileUploadB(event) {
        const files = event.target.files;
        if (!files.length) return;

        const fileList = [];
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const reader = new FileReader();
            reader.onloadend = () => {
                const base64Data = reader.result.split(',')[1];
                fileList.push({
                    Name: file.name,
                    Body: base64Data
                });

                if (fileList.length === files.length) {
                    this.uploadFiles(fileList, 'Evidencia de Garantía');
                }
            };
            reader.readAsDataURL(file);
        }
    }

    uploadFiles(fileList, fileType) {
        uploadFiles({ productId: this.recordId, fileType: fileType, attachments: fileList })
            .then(() => {
                this.loadFiles();
                this.isModalOpen = false;
            })
            .catch(error => {
                console.error('Error uploading files:', error);
            });
    }

    handleDeleteFileA(event) {
        const recordId = event.target.dataset.id;
        if (recordId) {
            deleteFile({ recordId })
                .then(() => {
                    this.loadFiles();
                })
                .catch(error => {
                    console.error('Error deleting file:', error);
                });
        }
    }

    handleDeleteFileB(event) {
        const recordId = event.target.dataset.id;
        if (recordId) {
            deleteFile({ recordId })
                .then(() => {
                    this.loadFiles();
                })
                .catch(error => {
                    console.error('Error deleting file:', error);
                });
        }
    }

    handleEditFileA(event) {
        const recordId = event.target.dataset.id;
        if (recordId) {
            // Implement your logic for editing the file
        }
    }
}