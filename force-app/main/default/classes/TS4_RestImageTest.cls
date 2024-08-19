@isTest
public class TS4_RestImageTest{

	@testSetup static void setup(){
		Product2 product = TestDataFactory.createProduct('Test Product', 'Pza', 'extId'); 
	}

	@isTest static void testMethod1() {
		// code_block	
		Product2 product = [SELECT Id FROM Product2 LIMIT 1];
		Test.setMock(HttpCalloutMock.class, new MockPageReferenceContent());
		product.INT_Imagen_URL__c = '';
		upsert product;
	}

	@isTest static void testMethod2() {
		// code_block	
		Product2 product = [SELECT Id FROM Product2 LIMIT 1];
		Test.setMock(HttpCalloutMock.class, new MockPageReferenceContent());
		product.INT_Imagen_URL__c = 'https://uy0b6rjcn9.execute-api.us-west-2.amazonaws.com/dev/obtenimagenarticulo-get?artnum=312696';
		TS4_RestImage.TS4_RestImage(product.INT_Imagen_URL__c, product.Id);
		upsert product;
		
	}

	// Mock HTTP callout response
	public class MockPageReferenceContent implements HttpCalloutMock{
		public HttpResponse respond(HttpRequest request){
			HttpResponse response = new HttpResponse();

			response.setHeader('Content-Type', 'application/json');
			Blob pdfBlob = Blob.valueOf('%PDF-1.4...'); 
			response.setBodyAsBlob(pdfBlob);
			response.setStatusCode(200);
			return response;
		}

	}
}