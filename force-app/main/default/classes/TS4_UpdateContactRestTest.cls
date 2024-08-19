@isTest
public with sharing class TS4_UpdateContactRestTest {
    @testSetup
    public static void init(){
        Account testAccount = new Account(Name = 'Empresa de Prueba',INT_RFC__c='TEST000000TS3');
        insert testAccount;
        Contact con= new Contact();
        con.FirstName='Nombre Test';
        con.LastName='Apellido Test';
        con.CurrencyIsoCode='MXN';//* Esta de esta forma ya que me lo piden forzozamente salesfroce para insertar el contacto
        con.Email='tst@tst.com';
        con.TS4_Cost_UsuSinter__c='NAPELLIDO';
        con.title='test';//*
        con.accountId=testAccount.Id;
        con.TS4_Cost_Puesto_de_trabajo__c='Puesto test';
        con.TS4_Cont_idSucursal__c='Sucursal test';
        con.phone='0000000000';//*
        con.TS4_isActive__c=true;
        insert con;
    }

    @isTest 
    static void testUpdateContact() {
        String jsondata='{"idSinter":["NAPELLIDO"]}';
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/updateContact';
        request.httpMethod = 'PUT';
        RestContext.request = request;
        request.requestBody = Blob.valueOf(jsonData);
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        Test.startTest();
        TS4_UpdateContactRest.updateContact();
        Test.stopTest();
    }
    @isTest 
    static void testUpdateContactError() {
        Contact c=[Select TS4_isActive__c from Contact limit 1];
        c.TS4_isActive__c=false;
        update c;
        String jsondata='{"idSinter":["NAPELLIDO"]}';
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/updateContact';
        request.httpMethod = 'PUT';
        RestContext.request = request;
        request.requestBody = Blob.valueOf(jsonData);
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        Test.startTest();
        TS4_UpdateContactRest.updateContact();
        Test.stopTest();
    }
}