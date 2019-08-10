import { LightningElement, track } from 'lwc';
import getAccountSettingsWrapped from '@salesforce/apex/DSD_SettingsSupport.getAccountSettingsWrapped'
import saveAccountSettings from '@salesforce/apex/DSD_SettingsSupport.saveAccountSettings'
import startBatchJob from '@salesforce/apex/DSD_AccountDataSkewBatch.startBatchJob'
import checkBatchStatus from '@salesforce/apex/DSD_AccountDataSkewBatch.checkBatchStatus'

export default class DsdAccountContainer extends LightningElement { 
	@track accountSettings;
	@track error;
	@track progress = 0;
	@track isProgressing = false;
	@track totalRecsToProcess;
	@track batchStatus;
	@track batchObject;
	@track parentObjectCount;
	@track lastRunStartTime;
	@track skewedRecCount;
	@track skewThreshold;
	@track reportingThreshold;
	@track orgName;
	@track showSettings = false;
	@track showSaveSuccess = false;
	@track showSaveError = false;

	constructor(){
		super();
		this.getAccountSettings();
	}

	handleRun(){
		startBatchJob({ accountSettings: JSON.stringify(this.accountSettings) })
			.then(result => {
				this.isProgressing = true;
				this.totalRecsToProcess = result;
				// eslint-disable-next-line @lwc/lwc/no-async-operation
				this._interval = setInterval(() => { 
					this.checkStatus();
				}, 2000);
			})
			.catch(error => {
				this.error = error;
			});
	}

	checkStatus(){
		checkBatchStatus({ accountSettings: JSON.stringify(this.accountSettings)})
			.then(result => { 
				this.batchStatus = result.Status; 
				this.batchObject = result;
  
				let jobItemsProcessed = 0;
				let totalJobItems = 0;

				if(this.batchStatus === 'Completed') {
					this.progress = 100;
					this.isProgressing = false;
					clearInterval(this._interval);
					this.finishRun();
				}
				else if (this.batchStatus === 'Processing') {
					this.isProgressing = true;
					jobItemsProcessed = this.batchObject.JobItemsProcessed;
					totalJobItems = this.batchObject.TotalJobItems;
				}

				if(this.isProgressing) {
					this.progress = parseInt((jobItemsProcessed/totalJobItems) * 100, 10);
				}
			});
	}

	finishRun(){
		this.getAccountSettings();
	}

	getAccountSettings() {
		getAccountSettingsWrapped()
			.then(result => {
				this.accountSettings = result;
				this.parentObjectCount = this.accountSettings.parentObjectCount;
				this.skewedRecCount = this.accountSettings.lastRunSkewedRecCount !== 'undefined' ? this.accountSettings.lastRunSkewedRecCount : null;
				this.lastRunStartTime = this.accountSettings.lastRunStartTime !== 'undefined' ? this.accountSettings.lastRunStartTime : null;
				this.skewThreshold = this.accountSettings.skewThreshold !== 'undefined' ? this.accountSettings.skewThreshold : null;
				this.reportingThreshold = this.accountSettings.reportingThreshold !== 'undefined' ? this.accountSettings.reportingThreshold : null;
				this.orgName = (this.accountSettings.orgName !== 'undefined') ? this.accountSettings.orgName : '????';

			})
			.catch(error => {
				this.error = error;
			});
	}

	handleToggleSettings(){
		console.log('handleToggleSettings');
		this.showSettings = this.showSettings ? false : true;
	}

	handleToggleSaveSuccess(){
		this.showSaveSuccess = this.showSaveSuccess ? false : true;
	}

	handleFieldChange(event){
		this[event.target.name] = event.target.value;
		console.log('name: ' + event.target.name);
		console.log('value: ' + event.target.value);
	}

	handleSaveSettings(){
		console.log('reportingThreshold: ' + this.reportingThreshold);
		this.accountSettings.skewThreshold = this.skewThreshold;
		this.accountSettings.reportingThreshold = this.reportingThreshold;
		
		saveAccountSettings({ accountSettings: JSON.stringify(this.accountSettings)})
			.then(result => {
				this.showSettings = false;
				console.log('result: ' + result);
				if(result){
					this.showSaveSuccess = true;
					this.showSaveError = false;

					// eslint-disable-next-line @lwc/lwc/no-async-operation
					this._interval = setInterval(() => { 
						this.showSaveSuccess = false;
					}, 5000);
				}
				else{
					this.showSaveError = true;
					this.showSaveSuccess = false;
				}
			});
	}
}