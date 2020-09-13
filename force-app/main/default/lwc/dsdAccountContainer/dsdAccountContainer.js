import { LightningElement, wire } from 'lwc'
import { refreshApex } from '@salesforce/apex'
import getAccountSettingsWrapped from '@salesforce/apex/DSD_SettingsSupport.getAccountSettingsWrapped'
import saveAccountSettings from '@salesforce/apex/DSD_SettingsSupport.saveAccountSettings'
import startBatchJob from '@salesforce/apex/DSD_AccountDataSkewBatch.startBatchJob'
import checkBatchStatus from '@salesforce/apex/DSD_AccountDataSkewBatch.checkBatchStatus'
import getAccountReportId from '@salesforce/apex/DSD_UtilityFunctions.getAccountReportId'

export default class DsdAccountContainer extends LightningElement { 
	error;
	fill = 0;
	totalRecsToProcess;
	batchObject;
	batchStatus;
	accountSettingsWired;
	accountSettings;
	isBatchCompleted;
	isBatchRunning;
	parentObjectCount;
	lastRunStartTime;
	skewedRecCount;
	skewThreshold;
	reportingThreshold;
	showSettings;
	showSaveSuccess;
	showSaveError;
	progressRing_d;
	buttonDisabled;
	accountReportUrl;

	connectedCallback(){
		console.log('connectedCallback');
		this.getBatchStatus()
			.then(() =>{
				if(this.batchObject != undefined){
					console.log('connectedCallback batchObject: ' + JSON.stringify(this.batchObject));
					if(this.isBatchRunning){
						this.handleRun(false);
					}
				}
			})
	}

	@wire(getAccountSettingsWrapped)
	getAccountSettings(value){
		console.log('getAccountSettings');
		this.accountSettingsWired = value;
		const {data, error} = value;
		if(data){
			console.log('getAccountSettings data: ' + JSON.stringify(data));
			this.accountSettings = data;
			this.parentObjectCount = data.parentObjectCount;
			this.skewedRecCount = data.lastRunSkewedRecCount;
			this.lastRunStartTime = data.lastRunStartTime;
		}
		if(error){
			console.log('getAccountSettings error: ' + JSON.stringify(error));
		}
	}

	@wire(getAccountReportId)
	getReportId({error, data}){
		console.log('getReportId data: ' + JSON.stringify(data));
		if(data) this.accountReportUrl = '/lightning/r/Report/' + data + '/view';
	}

	//@wire(checkBatchStatus)
	async getBatchStatus(){
		return checkBatchStatus()
			.then(result => {
				console.log('getBatchStatus result: ' + JSON.stringify(result));
				this.batchObject = result;
				this.batchStatus = result.Status;
				this.isBatchCompleted = result.Status === 'Completed';
				this.isBatchRunning = !this.isBatchCompleted;
			})
	}

	montiorBatch(){
		this.getBatchStatus()
			.then(() => {
				let jobItemsProcessed = this.batchObject.JobItemsProcessed;
				let totalJobItems = this.batchObject.TotalJobItems;
				let fillPercent = Math.round((jobItemsProcessed/totalJobItems) * 100) / 100;
				this.fill = this.fillPercent * 100;
				
				let isLong = this.fillPercent > .5 ? 1 : 0;
				let arcX = Math.round((Math.cos(2 * Math.PI * fillPercent)) * 100) / 100;
				let arcY = Math.round((Math.sin(2 * Math.PI * fillPercent)) * 100) / 100;
				this.progressRing_d = "M 1 0 A 1 1 0 " + isLong + " 1 " + arcX + " " + arcY + "L 0 0";
				
				console.log('fillPercent:' + fillPercent);
				
				if(this.isBatchCompleted) this.finishRun();
			})
			.catch(error => {
				console.log('error: ' + JSON.stringify(error));
			})
	}

	handleRunClick(){
		this.handleRun(true);
	}

	handleRun(newRun){
		this.skewedRecCount = '--';
		this.lastRunStartTime = '--';
		this.batchStatus = '--';
		this.buttonDisabled = true;

		if(newRun){
			startBatchJob({ accountSettings: JSON.stringify(this.accountSettings) })
				.then(result => {
					this.totalRecsToProcess = result;
					this.montiorBatch();
				})
				.catch(error => {
					this.error = error;
				})
		}

		// eslint-disable-next-line @lwc/lwc/no-async-operation
		this._interval = setInterval(() => { 
			this.montiorBatch();
		}, 3000);
	}

	finishRun(){
		console.log('finishRun');
		this.buttonDisabled = false;
		clearInterval(this._interval);
		refreshApex(this.accountSettingsWired);
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
					}, 3000);
				}
				else{
					this.showSaveError = true;
					this.showSaveSuccess = false;
				}
			});
	}
}