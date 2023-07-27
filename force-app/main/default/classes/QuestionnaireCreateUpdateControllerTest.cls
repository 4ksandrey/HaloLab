@isTest
public class QuestionnaireCreateUpdateControllerTest {
    @isTest
    static void testCreateQuestionnaire() {
        String Name = 'John';
        String caseType = 'Doe';
        String field = 'John_doe';

        Test.startTest();

        QuestionnaireCreateUpdateController.createNewQuestionnaire(Name, caseType, field);

        Test.stopTest();

        List<T_Questionnaire__c> questionnaires = [SELECT Id, Name, First_Name__c, Questionnaire_Id__c, Fields__c FROM T_Questionnaire__c WHERE Name = :Name];
        System.assertEquals(1, questionnaires.size());
		
        T_Questionnaire__c questionnaire = questionnaires[0];
        System.assertEquals(Name, questionnaire.Name);
        System.assertEquals('John_Doe', questionnaire.Questionnaire_Id__c);
        System.assertEquals('John_doe', questionnaire.Fields__c);
    }

    @isTest
    static void testUpdateQuestionnaire() {
        T_Questionnaire__c questionnaire = new T_Questionnaire__c();
        questionnaire.Name = 'Test Questionnaire';
        questionnaire.Case_Type__c = 'Test Case Type';
        questionnaire.Questionnaire_Name__c = 'Test Name';
        questionnaire.Questionnaire_Id__c = 'Test Id';
        questionnaire.Fields__c = 'Test Fields';
        questionnaire.RecordTypeId = getMappingRecordTypeId();
        insert questionnaire;
        List<T_Questionnaire__c> questionnaires = [SELECT Id, Name, Case_Type__c, Questionnaire_Name__c, Questionnaire_Id__c, Fields__c
                                                  FROM T_Questionnaire__c
                                                  LIMIT 1];
        
        Id recordId = (Id) questionnaires[0].get('Id');
        String newQuestionnaireName = 'Updated Questionnaire';
        String newCaseType = 'Updated';
        String newField = 'Updated Fields';        
        
        QuestionnaireCreateUpdateController.updateQuestionnaire(recordId, newQuestionnaireName, newCaseType, newField);

        List<T_Questionnaire__c> updatedQuestionnaire = [SELECT Id, Name, Case_Type__c, Questionnaire_Name__c, Questionnaire_Id__c, Fields__c
                                                  FROM T_Questionnaire__c
                                                  WHERE Id = :recordId];
        
        System.assertEquals(newQuestionnaireName, updatedQuestionnaire[0].get('Name'));
        System.assertEquals(newCaseType, updatedQuestionnaire[0].get('Case_Type__c'));
        System.assertEquals('Updated Questionnaire_Updated', updatedQuestionnaire[0].get('Questionnaire_Id__c'));
        System.assertEquals(newField, updatedQuestionnaire[0].get('Fields__c'));
    }

    private static Id getMappingRecordTypeId() {
        return Schema.SObjectType.T_Questionnaire__c.getRecordTypeInfosByName().get('Mapping').getRecordTypeId();
    }
}