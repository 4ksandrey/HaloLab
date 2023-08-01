@isTest
public class QuestionnaireCreateUpdateControllerTest {
    @isTest
    static void testCreateQuestionnaireWithLargeField() {
        String Name = 'John';
        String caseType = 'Doe';
        String field = 'A'.repeat(131050);

        Test.startTest();

        QuestionnaireCreateUpdateController.createNewQuestionnaire(Name, caseType, field);

        Test.stopTest();

        List<T_Questionnaire__c> questionnaires = [SELECT Id, Name, First_Name__c, Questionnaire_Id__c, Fields__c, Data_1__c, Data_2__c, Data_3__c, Data_4__c, Data_5__c, Data_6__c, Data_7__c, Data_8__c, Data_9__c, Data_10__c
                                                   FROM T_Questionnaire__c 
                                                   WHERE Name = :Name];
        System.assertEquals(1, questionnaires.size());
        
        T_Questionnaire__c questionnaire = questionnaires[0];
        System.assertEquals(Name, questionnaire.Name);
        System.assertEquals('John_Doe', questionnaire.Questionnaire_Id__c);
        System.assertEquals(field.substring(0, 131000), questionnaire.Fields__c);
        System.assertEquals(field.substring(131000, 131050), questionnaire.Data_1__c);
        System.assertEquals(null, questionnaire.Data_2__c);
        System.assertEquals(null, questionnaire.Data_3__c);
        System.assertEquals(null, questionnaire.Data_4__c);
        System.assertEquals(null, questionnaire.Data_5__c);
        System.assertEquals(null, questionnaire.Data_6__c);
        System.assertEquals(null, questionnaire.Data_7__c);
        System.assertEquals(null, questionnaire.Data_8__c);
        System.assertEquals(null, questionnaire.Data_9__c);
        System.assertEquals(null, questionnaire.Data_10__c);
    }

    @isTest
    static void testUpdateQuestionnaireWithLargeField() {
        T_Questionnaire__c questionnaire = new T_Questionnaire__c();
        questionnaire.Name = 'Test Questionnaire';
        questionnaire.Case_Type__c = 'Test Case Type';
        questionnaire.Questionnaire_Name__c = 'Test Name';
        questionnaire.Questionnaire_Id__c = 'Test Id';
        questionnaire.Fields__c = 'Test Fields';
        questionnaire.RecordTypeId = getMappingRecordTypeId();
        insert questionnaire;
        
        Id recordId = (Id) questionnaire.Id;
        String newQuestionnaireName = 'Updated Questionnaire';
        String newCaseType = 'Updated';
        String newField = 'A'.repeat(131050);  

        Test.startTest();

        QuestionnaireCreateUpdateController.updateQuestionnaire(recordId, newQuestionnaireName, newCaseType, newField);

        Test.stopTest();

        List<T_Questionnaire__c> updatedQuestionnaire = [SELECT Id, Name, Case_Type__c, Questionnaire_Name__c, Questionnaire_Id__c, Fields__c, Data_1__c, Data_2__c, Data_3__c, Data_4__c, Data_5__c, Data_6__c, Data_7__c, Data_8__c, Data_9__c, Data_10__c
                                                         FROM T_Questionnaire__c 
                                                         WHERE Id = :recordId];

        System.assertEquals(newQuestionnaireName, updatedQuestionnaire[0].get('Name'));
        System.assertEquals(newCaseType, updatedQuestionnaire[0].get('Case_Type__c'));
        System.assertEquals('Updated Questionnaire_Updated', updatedQuestionnaire[0].get('Questionnaire_Id__c'));
        System.assertEquals(newField.substring(0, 131000), updatedQuestionnaire[0].get('Fields__c'));
        System.assertEquals(newField.substring(131000, 131050), updatedQuestionnaire[0].get('Data_1__c'));
        System.assertEquals(null, updatedQuestionnaire[0].get('Data_2__c'));
        System.assertEquals(null, updatedQuestionnaire[0].get('Data_3__c'));
        System.assertEquals(null, updatedQuestionnaire[0].get('Data_4__c'));
        System.assertEquals(null, updatedQuestionnaire[0].get('Data_5__c'));
        System.assertEquals(null, updatedQuestionnaire[0].get('Data_6__c'));
        System.assertEquals(null, updatedQuestionnaire[0].get('Data_7__c'));
        System.assertEquals(null, updatedQuestionnaire[0].get('Data_8__c'));
        System.assertEquals(null, updatedQuestionnaire[0].get('Data_9__c'));
        System.assertEquals(null, updatedQuestionnaire[0].get('Data_10__c'));
    }

    private static Id getMappingRecordTypeId() {
        return Schema.SObjectType.T_Questionnaire__c.getRecordTypeInfosByName().get('Mapping').getRecordTypeId();
    }
}