import { LightningElement, track, wire } from 'lwc';
import createNewQuestionnaire from '@salesforce/apex/QuestionnaireCreateUpdateController.createNewQuestionnaire';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCaseTypeNames from "@salesforce/apex/QuestionnaireController.getCaseTypes";
import { loadStyle } from 'lightning/platformResourceLoader';
import myComponentStyles from '@salesforce/resourceUrl/myComponentStyles';

export default class QuestionnaireEditorCreator extends LightningElement {
    @track selectedCaseType;
    @track caseTypeOptions = [];
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

    @track selectedFieldType;

    handleQuestionnaireNameChange(event) {
        this.questionnaireName = event.target.value;
    }

    handleCaseTypeChange(event) {
        this.caseType = event.target.value;
    }

    handleSave() {
        let fieldsData = '';
        this.listOfAccounts.forEach((record, index) => {
            fieldsData += `${record.Field}:${record.Picklist}:${record.maxLength}`;
            if (index < this.listOfAccounts.length - 1) {
                fieldsData += '\n';
            }
        });
        createNewQuestionnaire({
            questionnaireName: this.questionnaireName,
            caseType: this.caseType,
            field: fieldsData
        })
        .then(newQuestionnaireId => {
            console.log('Новый опросник успешно создан!');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'New Questionnaire created successfully!',
                    variant: 'success',
                }),
            );      
        })
        .catch(error => {
            console.error('Ошибка при создании опросника:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Ошибка',
                    message: 'Ошибка при создании опросника',
                    variant: 'error'
                })
            );
        });
    }

    @track listOfAccounts;
    connectedCallback() {
        loadStyle(this, myComponentStyles);
        this.initData();
    }

    initData() {
        let listOfAccounts = [];
        this.createRow(listOfAccounts);
        this.listOfAccounts = listOfAccounts;
    }

    createRow(listOfAccounts) {
        let accountObject = {};
        if(listOfAccounts.length > 0) {
            accountObject.index = listOfAccounts[listOfAccounts.length - 1].index + 1;
        } else {
            accountObject.index = 1;
        }
        accountObject.Field = null;
        accountObject.Picklist = null;
        accountObject.maxLength = null;
        listOfAccounts.push(accountObject);
    }

    addNewRow() {
        this.createRow(this.listOfAccounts);
    }

    removeRow(event) {
        let toBeDeletedRowIndex = event.target.name;
        let listOfAccounts = [];
        for(let i = 0; i < this.listOfAccounts.length; i++) {
            let tempRecord = Object.assign({}, this.listOfAccounts[i]);
            if(tempRecord.index !== toBeDeletedRowIndex) {
                listOfAccounts.push(tempRecord);
            }
        }
        for(let i = 0; i < listOfAccounts.length; i++) {
            listOfAccounts[i].index = i + 1;
        }
        this.listOfAccounts = listOfAccounts;
    }

    removeAllRows() {
        let listOfAccounts = [];
        this.createRow(listOfAccounts);
        this.listOfAccounts = listOfAccounts;
    }

    handleInputChange(event) {
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;
        for(let i = 0; i < this.listOfAccounts.length; i++) {
            if(this.listOfAccounts[i].index === parseInt(index)) {
                this.listOfAccounts[i][fieldName] = value;
            }
        }
        console.log(this.listOfAccounts);
    }    
}
