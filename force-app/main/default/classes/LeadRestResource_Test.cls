@isTest
private class LeadRestResource_Test {

    @isTest
    public static void testCreateLeadsStatus200and500() {
        // Create test data
        Pais__c pais = new Pais__c();
        pais.INT_PaisClave__c = '1';
        insert pais;
        
        Estado__c estado = new Estado__c();
        estado.INT_PaisClave__c = '1';
        estado.INT_Pais__c = pais.Id;
        estado.INT_External_Id__c = '1 15';
        estado.INT_EntFedNum__c = 15;
        insert estado;
        
        Ciudad__c ciudad = new Ciudad__c();
        ciudad.INT_EntFedNum__c = 15;
        ciudad.INT_PaisClave__c = '1';
        ciudad.INT_MpoNum__c = 126;
        ciudad.INT_Estado__c = estado.Id;
        ciudad.INT_External_Id__c = '1 15 126';
        insert ciudad;
        
        Colonia__c colonia = new Colonia__c();
        colonia.INT_PaisClave__c = '1';
        colonia.INT_MpoNum__c = 126;
        colonia.INT_EntFedNum__c = 15;
        colonia.INT_CP__c = 54023;
        colonia.INT_ColNum__c = 4;
        colonia.INT_Ciudad__c = ciudad.Id;
        colonia.INT_External_Id__c = '1 15 126 4';
        insert colonia;
        
        Franquicia__c franquicia = new Franquicia__c();
        franquicia.INT_PaisClave__c = '1';
        franquicia.INT_MpoNum__c = 126;
        franquicia.INT_EntFedNum__c = 15;
        franquicia.INT_ColNum__c = 2;
        franquicia.INT_EmpNum__c = 202;
        franquicia.INT_Colonia__c = colonia.Id;
        insert franquicia;
        
        Sucursal__c sucursal = new Sucursal__c();
        sucursal.INT_SucClave__c = 'DIME';
        sucursal.INT_PaisClave__c = '1';
        sucursal.INT_MpoNum__c = 126;
        sucursal.INT_EntFedNum__c = 15;
        sucursal.INT_EmpNum__c = 202;
        sucursal.INT_ColNum__c = 2;
        sucursal.INT_Franquicia__c = franquicia.Id;
        insert sucursal;
        
        String jsonString = '{'+
                                '"Clientes": ['+
                                    '{'+
                                        '"Cliente_Id": "987654321",'+
                                        '"Nombre": "Johnnier",'+
                                        '"Apellido_Paterno": "Doe",'+
                                        '"Apellido_Materno": "Smith",'+
                                        '"Correo": "johndoe@example.com",'+
                                        '"Telefono": "1234567890",'+
                                        '"Celular": "9876543210",'+
                                        '"Direccion": {'+
                                            '"Pais": "Mexico",'+
                                            '"Estado": "Jalisco",'+
                                            '"Ciudad": "Guadalajara",'+
                                            '"Codigo_Postal": "44100",'+
                                            '"Colonia": "Centro",'+
                                            '"Calle": "Av. Juarez",'+
                                            '"Numero_Exterior": "123",'+
                                            '"Numero_Interior": "456"'+
                                        '},'+
                                        '"Ejecutivo_Asignado": "johndoe123",'+
                                        '"Tipo_cliente": "Constructora",'+
                                        '"Clasificacion_Ventas": "A",'+
                                        '"Clasificacion": "Franquiciatario",'+
                                        '"Industria": "Construcción",'+
                                        '"Compania": "ACME",'+
                                        '"Persona": "Física",'+
                                        '"Cargo": "Gerente",'+
                                        '"Presencia": "Nacional",'+
                                        '"Ubicacion": "Ubicación Test",'+
                                        '"Pais": "1",'+
                                        '"Estado": "15",'+
                                        '"Ciudad": "126",'+
                                        '"Colonia": "4",'+
                                        '"Franquicia": "202",'+
                                        '"Sucursal": "DIME",'+
                                        '"Zona": "1",'+
                                        '"Canal_de_Venta": "1",'+
                                        '"Datos_fiscales": {'+
                                            '"RFC": "DOEJ891011ABC",'+
                                            '"Razon_Social": "John Doe Construction",'+
                                            '"Direccion_Fiscal": {'+
                                                '"Pais": "1",'+
                                                '"Estado": "15",'+
                                                '"Ciudad": "126",'+
                                                '"Codigo_Postal": "44100",'+
                                                '"Colonia": "4",'+
                                                '"Calle": "Av. Juarez",'+
                                                '"Numero_Exterior": "789",'+
                                                '"Numero_Interior": "101"'+
                                            '},'+
                                            '"Uso_CFDI": "G01",'+
                                            '"Regimen_Fiscal": "Personas Morales con Fines no Lucrativos",'+
                                            '"Regimen_de_capital": "No aplica",'+
                                            '"Origen": "Nacional"'+
                                        '}'+
                                    '},'+
            						'{'+
                                        '"Cliente_Id": "123456798",'+
                                        '"Nombre": "Johnnier",'+
                                        '"Apellido_Paterno": "Doe",'+
                                        '"Apellido_Materno": "Smith",'+
                                        '"Correo": "johndoe@example.com",'+
                                        '"Telefono": "1234567890",'+
                                        '"Celular": "9876543210",'+
                                        '"Direccion": {'+
                                            '"Pais": "Mexico",'+
                                            '"Estado": "Jalisco",'+
                                            '"Ciudad": "Guadalajara",'+
                                            '"Codigo_Postal": "44100",'+
                                            '"Colonia": "Centro",'+
                                            '"Calle": "Av. Juarez",'+
                                            '"Numero_Exterior": "123",'+
                                            '"Numero_Interior": "456"'+
                                        '},'+
                                        '"Ejecutivo_Asignado": "johndoe123",'+
                                        '"Tipo_cliente": "Constructora",'+
                                        '"Clasificacion_Ventas": "A",'+
                                        '"Clasificacion": "Franquiciatario",'+
                                        '"Industria": "Construcción",'+
                                        '"Compania": null,'+
                                        '"Persona": "Física",'+
                                        '"Cargo": "Gerente",'+
                                        '"Presencia": "Nacional",'+
                                        '"Ubicacion": "Ubicación Test",'+
                                        '"Pais": "1",'+
                                        '"Estado": "15",'+
                                        '"Ciudad": "126",'+
                                        '"Colonia": "4",'+
                                        '"Franquicia": "202",'+
                                        '"Sucursal": "DIME",'+
                                        '"Zona": "1",'+
                                        '"Canal_de_Venta": "1",'+
                                        '"Datos_fiscales": {'+
                                            '"RFC": "DOEJ891011ABC",'+
                                            '"Razon_Social": "John Doe Construction",'+
                                            '"Direccion_Fiscal": {'+
                                                '"Pais": "1",'+
                                                '"Estado": "15",'+
                                                '"Ciudad": "126",'+
                                                '"Codigo_Postal": "44100",'+
                                                '"Colonia": "4",'+
                                                '"Calle": "Av. Juarez",'+
                                                '"Numero_Exterior": "789",'+
                                                '"Numero_Interior": "101"'+
                                            '},'+
                                            '"Uso_CFDI": "G01",'+
                                            '"Regimen_Fiscal": "Personas Morales con Fines no Lucrativos",'+
                                            '"Regimen_de_capital": "No aplica",'+
                                            '"Origen": "Nacional"'+
                                        '}'+
                                    '}'+
                                ']'+
                            '}';
        
        // Set up mock
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(jsonString);
        Test.setMock(HttpCalloutMock.class, new LeadRestResourceMock());
        
        // Call the REST endpoint
        Test.startTest();
        LeadRestResource.createLeads();
        Test.stopTest();
    }
    
    @isTest
    public static void testErrorCreateLeads() {
        // Create test data
        String jsonString = '';
        
        // Set up mock
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(jsonString);
        Test.setMock(HttpCalloutMock.class, new LeadRestResourceMock());
        
        // Call the REST endpoint
        Test.startTest();
        LeadRestResource.createLeads();
        Test.stopTest();
    }
}