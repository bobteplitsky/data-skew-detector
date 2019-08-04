import { LightningElement, track } from 'lwc';
import getAccountSettingsWrapped from '@salesforce/apex/DSD_SettingsSupport.getAccountSettingsWrapped'
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
				console.log('this.accountSettings.lastRunStartTime: ' + this.accountSettings.lastRunStartTime);
				console.log('this.accountSettings.lastRunSkewedRecCount: ' + this.accountSettings.lastRunSkewedRecCount);

			})
			.catch(error => {
				this.error = error;
			});
	}

	// get lastRunStartTime() {
	// 	console.log('lastRunStartTime: ' + this.lastRunStartTime);
	// 	return (this.lastRunStartTime !== 'undefined') ? this.lastRunStartTime : 'Never';
	// }
}