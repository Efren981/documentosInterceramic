global class TS4_IS_CheckBusinessHoursChatBot {
    global static Boolean checkBusinessHoursById(String businessHoursId)
    {
        Boolean isWithin = false;
        if (businessHoursId != null)
        {
            isWithin = BusinessHours.isWithin(businessHoursId, System.now());
        }
        
        return isWithin;
    }
    
    @InvocableMethod(label='Check Now is within Business Hours')
    global static List<Boolean> checkBusinessHoursByName()
    {

        List<Boolean> results = new List<Boolean>();
        
            List<BusinessHours> businessHours = [SELECT Id,Name FROM BusinessHours WHERE Name='TS4 Horario Completo Oficina Interceramic' AND IsActive = true];
            if (businessHours.size() == 1) {
                results.add(TS4_IS_CheckBusinessHoursChatBot.checkBusinessHoursById(businessHours[0].Id));
            }
            else
            {
                results.add(false);
            }
        System.debug('results BH'+results);
        return results;
    }
    
    /*@isTest
public class Bot_CheckBusinessHoursTest {
	
    static BusinessHours bh;
    
    @testSetup
    static void setup() {
		Bot_CheckBusinessHoursTest.bh = [SELECT Name from BusinessHours where isDefault = true];
    }
    
    static testMethod void checkBusinessHoursByName() {
        // Becase we can't insert our own BusinessHours object (DML prevented by SF), we can't reliably test that this
        // is correctly returning if we are or aren't within business hours. Best we can do is try load the default
        // and at least call some of the code
        List<String> input = new List<String>();
        if (Bot_CheckBusinessHoursTest.bh != null) {
            input.add(Bot_CheckBusinessHoursTest.bh.Name);
        }
        else {
	        input.add('default');
        }
        Boolean result = Bot_CheckBusinessHours.checkBusinessHoursByName(input)[0];
        System.assert(result, 'No results returned.');
    }
}*/
}