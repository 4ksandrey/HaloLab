@isTest
public class QuestionnaireControllerTest {
    
    @isTest
    static void testGetCaseTypes() {
        List<T_Case_Type__c> caseTypes = new List<T_Case_Type__c>();
        for(Integer i = 1; i <= 5; i++) {
            T_Case_Type__c caseType = new T_Case_Type__c();
            caseType.Name = 'Test Case Type ' + i;
            caseTypes.add(caseType);
        }
        insert caseTypes;
        
        List<String> result = QuestionnaireController.getCaseTypes();
        
        System.assertEquals(5, result.size());
        for(Integer i = 1; i <= 5; i++) {
            String expectedValue = 'Test Case Type ' + i;
            System.assertEquals(expectedValue, result[i-1]);
        }
    }

    @isTest
    static void testGetQuestionnaireNames() {
        T_Case_Type__c testCaseType = new T_Case_Type__c();
        testCaseType.Name = 'Test Case Type';
        insert testCaseType;

        Id standardPricebookId = Test.getStandardPricebookId();

        List<T_Questionnaire__c> questionnaires = new List<T_Questionnaire__c>();
        for(Integer i = 1; i <= 5; i++) {
            T_Questionnaire__c questionnaire = new T_Questionnaire__c();
            questionnaire.Name = 'Test Questionnaire ' + i;
            questionnaire.Case_Type__c = 'Test Case Type';
            questionnaire.Questionnaire_Name__c = 'Test Name ' + i;
            questionnaire.RecordTypeId = getMappingRecordTypeId();
            questionnaires.add(questionnaire);
        }
        insert questionnaires;
        
        List<String> result = QuestionnaireController.getQuestionnaireNames('Test Case Type');
        
        System.assertEquals(5, result.size());
        for(Integer i = 1; i <= 5; i++) {
            String expectedValue = 'Test Name ' + i;
            System.assertEquals(expectedValue, result[i-1]);
        }
    }

    @isTest
    static void testGetQuestionnaires() {
        List<T_Questionnaire__c> questionnaires = new List<T_Questionnaire__c>();
        for(Integer i = 1; i <= 5; i++) {
            T_Questionnaire__c questionnaire = new T_Questionnaire__c();
            questionnaire.Name = 'Test Questionnaire ' + i;
            questionnaire.Case_Type__c = 'Test Case Type';
            questionnaire.Questionnaire_Name__c = 'Test Name ' + i;
            questionnaire.Questionnaire_Id__c = 'Test Id ' + i;
            questionnaire.Fields__c = 'Test Fields ' + i;
            questionnaires.add(questionnaire);
        }
        insert questionnaires;
        
        List<T_Questionnaire__c> result = QuestionnaireController.getQuestionnaires('Test Case Type', 'Test Questionnaire 1');
        
        System.assertEquals(1, result.size());
        String expectedName = 'Test Questionnaire 1';
        System.assertEquals(expectedName, result[0].Name);
    }

    private static Id getMappingRecordTypeId() {
        return Schema.SObjectType.T_Questionnaire__c.getRecordTypeInfosByName().get('Mapping').getRecordTypeId();
    }
}