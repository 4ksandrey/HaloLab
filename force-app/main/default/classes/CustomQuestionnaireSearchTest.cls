@isTest
private class CustomQuestionnaireSearchTest {
    @isTest
    static void testGetQuestionnaireList() {
        Id mappingRecordTypeId = Schema.SObjectType.T_Questionnaire__c.getRecordTypeInfosByName().get('Mapping').getRecordTypeId();

        List<T_Questionnaire__c> testQuestionnaires = new List<T_Questionnaire__c>();
        for (Integer i = 1; i <= 5; i++) {
            T_Questionnaire__c questionnaire = new T_Questionnaire__c(
                Name = 'Test Questionnaire ' + i,
                Case_Type__c = 'Test Case Type ' + i,
                Questionnaire_Name__c = 'Test Name ' + i,
                Questionnaire_Id__c = 'Test Id ' + i,
                Fields__c = 'Test Fields ' + i,
                RecordTypeId = mappingRecordTypeId 
            );
            testQuestionnaires.add(questionnaire);
        }
        insert testQuestionnaires;

        Test.startTest();
        
        List<T_Questionnaire__c> resultQuestionnaires = CustomQuestionnaireSearch.getQuestionnaireList('Test');

        Test.stopTest();

        System.assertEquals(5, resultQuestionnaires.size());
        for (Integer i = 0; i < resultQuestionnaires.size(); i++) {
            String expectedName = 'Test Questionnaire ' + (i + 1);
            String expectedCaseType = 'Test Case Type ' + (i + 1);
            String expectedQuestionnaireName = 'Test Name ' + (i + 1);
            String expectedQuestionnaireId = 'Test Id ' + (i + 1);
            String expectedFields = 'Test Fields ' + (i + 1);

            System.assertEquals(expectedName, resultQuestionnaires[i].Name);
            System.assertEquals(expectedCaseType, resultQuestionnaires[i].Case_Type__c);
            System.assertEquals(expectedQuestionnaireName, resultQuestionnaires[i].Questionnaire_Name__c);
            System.assertEquals(expectedQuestionnaireId, resultQuestionnaires[i].Questionnaire_Id__c);
            System.assertEquals(expectedFields, resultQuestionnaires[i].Fields__c);
        }
    }
}