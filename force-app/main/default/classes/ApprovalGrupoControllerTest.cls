@isTest
public with sharing class ApprovalGrupoControllerTest {
    @isTest
    public static void executeApprovalFlow_nivel5() {
        
         /*Pricebook2 listaDePrecios = new Pricebook2();
        listaDePrecios.Name = 'Lista de Precios de Ejemplo';
        listaDePrecios.IsActive = true;
        insert listaDePrecios;*/
        
         Product2 newProduct = new Product2();
        
        // Establece los campos del producto
        newProduct.Name = 'Nivel 5'; // Nombre del producto
        newProduct.Description = 'Descripción del Producto'; // Descripción del producto
        newProduct.IsActive = true; // Activa el producto
        newProduct.CurrencyIsoCode = 'MXN';
        newProduct.TipoProducto__c = 'ESTRATEGICO';
        //newProduct.UnitPrice = 600000;
        insert newProduct;
        
        //Test.getStandardPricebookId();
        
        PricebookEntry standardPricebookEntry = new PricebookEntry();
        standardPricebookEntry.Product2Id = newProduct.Id;
        standardPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        //standardPricebookEntry.UseStandardPrice = true;
        standardPricebookEntry.UnitPrice = 600000;
        standardPricebookEntry.IsActive = true;
        //standardPricebookEntry.UnitPrice = 600000;
        insert standardPricebookEntry;
        
       /* PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Product2Id = newProduct.Id;
        pricebookEntry.Pricebook2Id = listaDePrecios.Id;
        pricebookEntry.UnitPrice = 600000; // Precio del producto para esta lista de precios
        pricebookEntry.IsActive = true;

        // Insertar el objeto PricebookEntry
        insert pricebookEntry;*/

        
        SBQQ__Quote__c  quote = new SBQQ__Quote__c();
        //quote.SBQQ__ListAmount__c = 600000;
       
        insert quote; 
       
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quote.Id;
        quoteLine.SBQQ__Product__c = newProduct.Id;
       // quoteLine.SBQQ__ProductName__c = 'Nivel 5';
        //quoteLine.Tipo_producto__c = 'PREMIUM';
        quoteLine.SBQQ__Discount__c = 4;
        quoteLine.SBQQ__Quantity__c = 1.00;
        //quoteLine.SBQQ__ListTotal__c = 600000;
        insert quoteLine;
        //system.debug(quoteLine);
         system.debug('list amount ql'+quoteLine.SBQQ__ListTotal__c);
        
        

       
		       
        ApprovalGrupoController.executeApprovalFlow(quote.Id);
    }
    
    @isTest
    public static void executeApprovalFlow_nivel4() {
        
        
         Product2 newProduct = new Product2();
        
        // Establece los campos del producto
        newProduct.Name = 'Nivel 5'; // Nombre del producto
        newProduct.Description = 'Descripción del Producto'; // Descripción del producto
        newProduct.IsActive = true; // Activa el producto
        newProduct.CurrencyIsoCode = 'MXN';
        newProduct.TipoProducto__c = 'ESTRATEGICO';
        //newProduct.UnitPrice = 600000;
        insert newProduct;
        
        //Test.getStandardPricebookId();
        
        PricebookEntry standardPricebookEntry = new PricebookEntry();
        standardPricebookEntry.Product2Id = newProduct.Id;
        standardPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        //standardPricebookEntry.UseStandardPrice = true;
        standardPricebookEntry.UnitPrice = 350000;
        standardPricebookEntry.IsActive = true;
        //standardPricebookEntry.UnitPrice = 600000;
        insert standardPricebookEntry;
        
       /* PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Product2Id = newProduct.Id;
        pricebookEntry.Pricebook2Id = listaDePrecios.Id;
        pricebookEntry.UnitPrice = 600000; // Precio del producto para esta lista de precios
        pricebookEntry.IsActive = true;

        // Insertar el objeto PricebookEntry
        insert pricebookEntry;*/

        
        SBQQ__Quote__c  quote = new SBQQ__Quote__c();
        //quote.SBQQ__ListAmount__c = 600000;
       
        insert quote; 
       
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quote.Id;
        quoteLine.SBQQ__Product__c = newProduct.Id;
       // quoteLine.SBQQ__ProductName__c = 'Nivel 5';
        //quoteLine.Tipo_producto__c = 'PREMIUM';
        quoteLine.SBQQ__Discount__c = 2 ;
        quoteLine.SBQQ__Quantity__c = 1.00;
        //quoteLine.SBQQ__ListTotal__c = 600000;
        insert quoteLine;
        //system.debug(quoteLine);
         system.debug('list amount ql'+quoteLine.SBQQ__ListTotal__c);
        
        

       
		       
        ApprovalGrupoController.executeApprovalFlow(quote.Id);
    }
    
    /*
      @isTest
    public static void executeApprovalFlow_nivel3() {
        
        
         Product2 newProduct = new Product2();
        
        // Establece los campos del producto
        newProduct.Name = 'Nivel 5'; // Nombre del producto
        newProduct.Description = 'Descripción del Producto'; // Descripción del producto
        newProduct.IsActive = true; // Activa el producto
        newProduct.CurrencyIsoCode = 'MXN';
        newProduct.TipoProducto__c = 'ESTRATEGICO';
        //newProduct.UnitPrice = 600000;
        insert newProduct;
        
        //Test.getStandardPricebookId();
        
        PricebookEntry standardPricebookEntry = new PricebookEntry();
        standardPricebookEntry.Product2Id = newProduct.Id;
        standardPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        //standardPricebookEntry.UseStandardPrice = true;
        standardPricebookEntry.UnitPrice = 200000;
        standardPricebookEntry.IsActive = true;
        //standardPricebookEntry.UnitPrice = 600000;
        insert standardPricebookEntry;
        
       /* PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Product2Id = newProduct.Id;
        pricebookEntry.Pricebook2Id = listaDePrecios.Id;
        pricebookEntry.UnitPrice = 600000; // Precio del producto para esta lista de precios
        pricebookEntry.IsActive = true;

        // Insertar el objeto PricebookEntry
        //insert pricebookEntry;

        
        SBQQ__Quote__c  quote = new SBQQ__Quote__c();
        //quote.SBQQ__ListAmount__c = 600000;
       
        insert quote; 
       
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quote.Id;
        quoteLine.SBQQ__Product__c = newProduct.Id;
       // quoteLine.SBQQ__ProductName__c = 'Nivel 5';
        //quoteLine.Tipo_producto__c = 'PREMIUM';
        quoteLine.SBQQ__Discount__c = 0 ;
        quoteLine.SBQQ__Quantity__c = 1.00;
        //quoteLine.SBQQ__ListTotal__c = 600000;
        insert quoteLine;
        //system.debug(quoteLine);
         system.debug('list amount ql'+quoteLine.SBQQ__ListTotal__c);
        
        

       
		       
        ApprovalGrupoController.executeApprovalFlow(quote.Id);
    }*/
    
       @isTest
    public static void executeApprovalFlow_nivel2() {
        
        
         Product2 newProduct = new Product2();
        
        // Establece los campos del producto
        newProduct.Name = 'Nivel 2'; // Nombre del producto
        newProduct.Description = 'Descripción del Producto'; // Descripción del producto
        newProduct.IsActive = true; // Activa el producto
        newProduct.CurrencyIsoCode = 'MXN';
        newProduct.TipoProducto__c = 'PREMIUM';
        //newProduct.UnitPrice = 600000;
        insert newProduct;
        
        //Test.getStandardPricebookId();
        
        PricebookEntry standardPricebookEntry = new PricebookEntry();
        standardPricebookEntry.Product2Id = newProduct.Id;
        standardPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        //standardPricebookEntry.UseStandardPrice = true;
        standardPricebookEntry.UnitPrice = 30000;
        standardPricebookEntry.IsActive = true;
        //standardPricebookEntry.UnitPrice = 600000;
        insert standardPricebookEntry;
        
       /* PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Product2Id = newProduct.Id;
        pricebookEntry.Pricebook2Id = listaDePrecios.Id;
        pricebookEntry.UnitPrice = 600000; // Precio del producto para esta lista de precios
        pricebookEntry.IsActive = true;

        // Insertar el objeto PricebookEntry
        insert pricebookEntry;*/

        
        SBQQ__Quote__c  quote = new SBQQ__Quote__c();
        //quote.SBQQ__ListAmount__c = 600000;
       
        insert quote; 
       
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quote.Id;
        quoteLine.SBQQ__Product__c = newProduct.Id;
       // quoteLine.SBQQ__ProductName__c = 'Nivel 5';
        //quoteLine.Tipo_producto__c = 'PREMIUM';
        quoteLine.SBQQ__Discount__c = 0 ;
        quoteLine.SBQQ__Quantity__c = 2.00;
        //quoteLine.SBQQ__ListTotal__c = 600000;
        insert quoteLine;
        //system.debug(quoteLine);
         system.debug('list amount ql'+quoteLine.SBQQ__ListTotal__c);
        
        

       
		       
        ApprovalGrupoController.executeApprovalFlow(quote.Id);
    }

      @isTest
    public static void executeApprovalFlow_nivel1() {
        
        
         Product2 newProduct = new Product2();
        
        // Establece los campos del producto
        newProduct.Name = 'Nivel 5'; // Nombre del producto
        newProduct.Description = 'Descripción del Producto'; // Descripción del producto
        newProduct.IsActive = true; // Activa el producto
        newProduct.CurrencyIsoCode = 'MXN';
        newProduct.TipoProducto__c = 'STANDARD C';
        //newProduct.UnitPrice = 600000;
        insert newProduct;
        
        //Test.getStandardPricebookId();
        
        PricebookEntry standardPricebookEntry = new PricebookEntry();
        standardPricebookEntry.Product2Id = newProduct.Id;
        standardPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        //standardPricebookEntry.UseStandardPrice = true;
        standardPricebookEntry.UnitPrice = 30000;
        standardPricebookEntry.IsActive = true;
        //standardPricebookEntry.UnitPrice = 600000;
        insert standardPricebookEntry;
        
       /* PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Product2Id = newProduct.Id;
        pricebookEntry.Pricebook2Id = listaDePrecios.Id;
        pricebookEntry.UnitPrice = 600000; // Precio del producto para esta lista de precios
        pricebookEntry.IsActive = true;

        // Insertar el objeto PricebookEntry
        insert pricebookEntry;*/

        
        SBQQ__Quote__c  quote = new SBQQ__Quote__c();
        //quote.SBQQ__ListAmount__c = 600000;
       
        insert quote; 
       
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quote.Id;
        quoteLine.SBQQ__Product__c = newProduct.Id;
       // quoteLine.SBQQ__ProductName__c = 'Nivel 5';
        //quoteLine.Tipo_producto__c = 'PREMIUM';
        quoteLine.SBQQ__Discount__c = 0 ;
        quoteLine.SBQQ__Quantity__c = 1.00;
        //quoteLine.SBQQ__ListTotal__c = 600000;
        insert quoteLine;
        //system.debug(quoteLine);
         system.debug('list amount ql'+quoteLine.SBQQ__ListTotal__c);
        
        

       
		       
        ApprovalGrupoController.executeApprovalFlow(quote.Id);
    }


}