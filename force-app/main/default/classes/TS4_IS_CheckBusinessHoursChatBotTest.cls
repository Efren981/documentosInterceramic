@isTest
public class TS4_IS_CheckBusinessHoursChatBotTest {
    
    
    static BusinessHours bh;
    
    @testSetup
    static void setup() {
		bh = [SELECT Name from BusinessHours where Name='TS4 Horario Completo Oficina Interceramic' AND IsActive = true];
    }
    
    static testMethod void checkBusinessHoursByName() {
       
        List<String> input = new List<String>();
        if (bh != null) {
            input.add(bh.Name);
        }
        else {
	        input.add('default');
        }
        List<Boolean> result = TS4_IS_CheckBusinessHoursChatBot.checkBusinessHoursByName();
        //System.assert(result, 'No results returned.');
    }
}