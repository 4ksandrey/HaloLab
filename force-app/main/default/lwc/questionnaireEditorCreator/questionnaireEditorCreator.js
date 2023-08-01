import { LightningElement, track, wire } from 'lwc';
import createNewQuestionnaire from '@salesforce/apex/QuestionnaireCreateUpdateController.createNewQuestionnaire';
import updateQuestionnaire from '@salesforce/apex/QuestionnaireCreateUpdateController.updateQuestionnaire';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCaseTypeNames from "@salesforce/apex/QuestionnaireController.getCaseTypes";
import { loadStyle } from 'lightning/platformResourceLoader';
import myComponentStyles from '@salesforce/resourceUrl/myComponentStyles';
import getQuestionnaireList from '@salesforce/apex/CustomQuestionnaireSearch.getQuestionnaireList';

export default class QuestionnaireEditorCreator extends LightningElement {
    @track selectedCaseType;
    @track caseTypeOptions = [];
    @track selectedPicklistValue;
    @track questionnaireName;
    @track caseType;
    @wire(getCaseTypeNames)
    wiredCaseTypes({ error, data }) {
        if (data) {
            this.caseTypeOptions = data.map((caseType) => ({
                label: caseType,
                value: caseType
            }));
        } else if (error) {
            this.showErrorToast("Error fetching Case Types.");
        }
    }

    @track fieldTypeOptions = [
        { label: 'Text', value: 'Text' },
        { label: 'Long Text Area', value: 'LongTextArea' },
        { label: 'Picklist', value: 'Picklist' },
        { label: 'Checkbox', value: 'Checkbox' },
    ];

    getPicklistFieldName() {
        if (this.listOfQuestionnaires && this.listOfQuestionnaires.length > 0) {
            return this.listOfQuestionnaires[2].fieldName;
        }
        return '';
    }

    @track selectedFieldType;

    handleQuestionnaireNameChange(event) {
        this.questionnaireName = event.target.value;
    }

    handleCaseTypeChange(event) {
        this.caseType = event.target.value;
    }

    @track listOfQuestionnaires;
    connectedCallback() {
        loadStyle(this, myComponentStyles);
        this.initData();
    }

    initData() {
        let listOfQuestionnaires = [];
        this.createRow(listOfQuestionnaires);
        this.listOfQuestionnaires = listOfQuestionnaires;
    }

    createRow(listOfQuestionnaires) {
        let questionnaireObject = {};
        if(listOfQuestionnaires.length > 0) {
            questionnaireObject.index = listOfQuestionnaires[listOfQuestionnaires.length - 1].index + 1;
        } else {
            questionnaireObject.index = 1;
        }
        questionnaireObject.Field = null;
        questionnaireObject.Picklist = null;
        questionnaireObject.maxLength = null;
        listOfQuestionnaires.push(questionnaireObject);
    }

    addNewRow() {
        this.createRow(this.listOfQuestionnaires);
    }

    removeRow(event) {
        let toBeDeletedRowIndex = event.target.name;
        let listOfQuestionnaires = [];
        for(let i = 0; i < this.listOfQuestionnaires.length; i++) {
            let tempRecord = Object.assign({}, this.listOfQuestionnaires[i]);
            if(tempRecord.index !== toBeDeletedRowIndex) {
                listOfQuestionnaires.push(tempRecord);
            }
        }
        for(let i = 0; i < listOfQuestionnaires.length; i++) {
            listOfQuestionnaires[i].index = i + 1;
        }
        this.listOfQuestionnaires = listOfQuestionnaires;
    }

    removeAllRows() {
        let listOfQuestionnaires = [];
        this.createRow(listOfQuestionnaires);
        this.listOfQuestionnaires = listOfQuestionnaires;
    }

    handleInputChange(event) {
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;
    
        for(let i = 0; i < this.listOfQuestionnaires.length; i++) {
            if(this.listOfQuestionnaires[i].index === parseInt(index)) {
                this.listOfQuestionnaires[i][fieldName] = value;
                this.listOfQuestionnaires[i].isTextFieldOrTextArea = this.listOfQuestionnaires[i].Picklist === 'Text' || this.listOfQuestionnaires[i].Picklist === 'LongTextArea';
                this.listOfQuestionnaires[i].isPicklist = this.listOfQuestionnaires[i].Picklist === 'Picklist';
                this.listOfQuestionnaires[i].isCheckbox = this.listOfQuestionnaires[i].Picklist === 'Checkbox';
            }
        }
    }

    handleSave() {
        let fieldsData = '';
        this.listOfQuestionnaires.forEach((record, index) => {
            let fieldData = `${record.Field}:${record.Picklist}:`;
    
            if (record.isTextFieldOrTextArea) {
                fieldData += record.maxLength;
            } else if (record.isPicklist) {
                fieldData += record.picklistValues;
            } else if (record.isCheckbox) {
                fieldData += ''; 
            }
    
            fieldsData += fieldData;
    
            if (index < this.listOfQuestionnaires.length - 1) {
                fieldsData += '\n';
            }
        });
    
        createNewQuestionnaire({
            questionnaireName: this.questionnaireName,
            caseType: this.caseType,
            field: fieldsData
        })
        .then(newQuestionnaireId => {
            console.log('New Questionnaire created successfully!');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'New Questionnaire created successfully!',
                    variant: 'success',
                }),
            );      
        })
        .catch(error => {
            console.error('Error during creating new Questionnaire', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error during creating new Questionnaire',
                    variant: 'error'
                })
            );
        });
    }

    @track questionnaires;
    @track selectedQuestionnaireId;
    searchValue = '';

    searchKeyword(event) {
        this.searchValue = event.target.value;
    }
    
    handleSearchKeyword() {
        if (this.searchValue !== '') {
            getQuestionnaireList({
                searchKey: this.searchValue
            })
                .then(result => {
                    this.questionnaires = result.map(que => {
                        return {
                            ...que,
                            shortenedField: que.Fields__c && que.Fields__c.length > 50 ? que.Fields__c.substring(0, 50) + '...' : que.Fields__c
                        }
                    });
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: error.body.message,
                    });
                    this.dispatchEvent(event);
                    this.questionnaires = null;
                });
        } else {
            const event = new ShowToastEvent({
                variant: 'error',
                message: 'Search text missing..',
            });
            this.dispatchEvent(event);
        }
    }

    handleSelect(event) {
        this.selectedQuestionnaireId = event.target.value;
    }

    handleUpdate() {
        let fieldsData = '';
        this.listOfQuestionnaires.forEach((record, index) => {
            let fieldData = `${record.Field}:${record.Picklist}:`;
    
            if (record.isTextFieldOrTextArea) {
                fieldData += record.maxLength;
            } else if (record.isPicklist) {
                fieldData += record.picklistValues;
            } else if (record.isCheckbox) {
                fieldData += ''; 
            }
    
            fieldsData += fieldData;
    
            if (index < this.listOfQuestionnaires.length - 1) {
                fieldsData += '\n';
            }
        });
        updateQuestionnaire({
            recordId: this.selectedQuestionnaireId,
            questionnaireName: this.questionnaireName,
            caseType: this.caseType,
            field: fieldsData
        })
        .then(newQuestionnaireId => {
            console.log('Questionnaire was updated successfully!');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Questionnaire was updated successfully!',
                    variant: 'success',
                }),
            );      
        })
        .catch(error => {
            console.error('Error during update Questionnaire', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error during update Questionnaire',
                    variant: 'error'
                })
            );
        });
    }
}