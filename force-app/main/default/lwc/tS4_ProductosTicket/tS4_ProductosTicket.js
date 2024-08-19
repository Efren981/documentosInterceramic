import { LightningElement, api, track, wire } from 'lwc';
import getProductosDelTicket from '@salesforce/apex/TS4_ProductTableController.getProductosDelTicket';
import updateProductos from '@salesforce/apex/TS4_ProductTableController.updateProductos';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class ProductoTicketComponent extends LightningElement {
    @api recordId;
    @track productos;
    @track error;
    @track draftValues = [];
    COLUMNS = [
        { label: 'Clave de artículo', fieldName: 'TS4_Clave_de_articulo__c', type: 'text' },
        { label: 'Descripción', fieldName: 'DESCRIPCION__c', type: 'text' },
        { label: 'Tipo', fieldName: 'TS4_Tipo__c', type: 'text' },
        { label: 'Precio Unitario', fieldName: 'TS4_PRECIOUNITARIO__c', type: 'currency' },
        { label: 'Cantidad', fieldName: 'CANTIDAD__c', type: 'number' },
        { label: 'Monto Garantía', fieldName: 'TS4_Monto_Garantia__c', type: 'currency', editable: true },
        { label: 'Dictamen', fieldName: 'TS4_Dictamen__c', type: 'text', editable: true },
        { label: 'Número de piezas a reclamar', fieldName: 'TS4_Numero_de_piezas_a_reclamar__c', type: 'number', editable: true }
    ];
    wiredProductosResult;

    @wire(getProductosDelTicket, { casoId: '$recordId' })
    wiredProductos(result) {
        this.wiredProductosResult = result;
        if (result.data) {
            this.productos = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.productos = undefined;
            console.error('Error fetching productos:', result.error);
        }
    }

    handleSave(event) {
        console.log('Save event triggered:', JSON.stringify(event.detail));
        const updatedFields = event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return fields;
        });

        console.log('Updating fields:', JSON.stringify(updatedFields));

        updateProductos({ productos: updatedFields })
            .then(result => {
                console.log('Update result:', result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'Productos actualizados',
                        variant: 'success'
                    })
                );
                this.draftValues = [];
                return this.refreshData();
            })
            .catch(error => {
                console.error('Error updating records:', JSON.stringify(error));
                let errorMessage = 'Error desconocido al actualizar productos';
                if (error.body) {
                    errorMessage = error.body.message || error.body.exceptionType || errorMessage;
                } else if (error.message) {
                    errorMessage = error.message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error al actualizar productos: ' + errorMessage,
                        variant: 'error'
                    })
                );
            });
    }

    refreshData() {
        return refreshApex(this.wiredProductosResult)
            .then(() => {
                console.log('Data refreshed successfully');
            })
            .catch(error => {
                console.error('Error refreshing data:', JSON.stringify(error));
            });
    }
}