package com.example.lifeplus

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.content.Context
import android.util.Log
import com.cerashealth.ceras.*
import com.zhj.bluetooth.zhjbluetoothsdk.bean.*
import com.zhj.bluetooth.zhjbluetoothsdk.ble.BleCallbackWrapper
import com.zhj.bluetooth.zhjbluetoothsdk.ble.BleSdkWrapper
import com.zhj.bluetooth.zhjbluetoothsdk.ble.HandlerBleDataResult
import com.zhj.bluetooth.zhjbluetoothsdk.ble.bluetooth.BluetoothLe
import com.zhj.bluetooth.zhjbluetoothsdk.ble.bluetooth.OnLeConnectListener
import com.zhj.bluetooth.zhjbluetoothsdk.ble.bluetooth.OnLeScanListener
import com.zhj.bluetooth.zhjbluetoothsdk.ble.bluetooth.OnLeWriteCharacteristicListener
import com.zhj.bluetooth.zhjbluetoothsdk.ble.bluetooth.exception.ConnBleException
import com.zhj.bluetooth.zhjbluetoothsdk.ble.bluetooth.exception.ScanBleException
import com.zhj.bluetooth.zhjbluetoothsdk.ble.bluetooth.exception.WriteBleException
import com.zhj.bluetooth.zhjbluetoothsdk.ble.bluetooth.scanner.ScanRecord
import com.zhj.bluetooth.zhjbluetoothsdk.ble.bluetooth.scanner.ScanResult
import io.flutter.plugin.common.MethodChannel
import java.util.*

class ConnectionListener:OnLeConnectListener(){

    companion object{
        var result:MethodChannel.Result? = null
    }

    override fun onDeviceDisconnected() {
        BandDevice.isConnecting = false
        Log.i(BandDevice.TAG,"Device disconnected")
    }

    override fun onDeviceConnectFail(p0: ConnBleException?) {
        BandDevice.isConnecting = false
        Log.i(BandDevice.TAG,"Device Connection failed")
    }

    override fun onDeviceConnected() {
        BandDevice.isConnecting = false
        Log.i(BandDevice.TAG,"Device Connected connected")
    }

    override fun onServicesDiscovered(bluetoothGatt: BluetoothGatt?) {
        BandDevice.isConnecting = false
        Log.i(BandDevice.TAG,"Device Services discovered")
        BandDevice.syncDevice()

        //Load the data from device
        BandDevice.device?.let{ bleDevice->
            BandDevice.currentDeviceId =  bleDevice.mDeviceAddress
            result?.let{methodResult->
                methodResult.success(ConnectionInfo.createResponse(message = "Connected",connected = true,deviceId = bleDevice.mDeviceAddress,
                        deviceName = bleDevice.mDeviceName,additionalInfo = mapOf("factoryName" to bleDevice.mDeviceName),deviceType = BaseDevice.BAND_DEVICE))
            }
        }
        BandDevice.loadData()
    }

    override fun onDeviceConnecting() {

    }

}

class BandDevice :BaseDevice(){

    companion object{
        val TAG = BandDevice::class.java.simpleName
        var isConnecting = false
        var device:BLEDevice? = null
        var currentDeviceId:String? = null
        var mBluetoothLe: BluetoothLe? = null
        var isSyncing = false
        var lastSyncTime:Date? = null

        private fun setStatus(){
            Log.i(TAG,"setting device status")
            BleSdkWrapper.getDeviceState(object:OnLeWriteCharacteristicListener(){
                override fun onSuccess(result: HandlerBleDataResult?) {
                    Log.i(TAG, "Got status ${result?.data}")
                    if (result?.data is DeviceState) {
                        val deviceStatus = result?.data as DeviceState

                        deviceStatus.apply {
                            tempUnit = 1 //Set to imperial units
                            timeFormat = 1 // Set to 12 hour format
                            upHander = 1 //Raise hand for device brightness
                        }
                        BleSdkWrapper.setDeviceState(deviceStatus, object : OnLeWriteCharacteristicListener() {
                            override fun onSuccess(p0: HandlerBleDataResult?) {
                                Log.i(TAG, "Device state success")
                            }

                            override fun onFailed(ex: WriteBleException?) {
                                Log.e(TAG, "Error while setting device Info ${ex}")
                            }

                        })
                    }
                }

                override fun onFailed(ex: WriteBleException?) {
                    Log.e(TAG,"Error while getting device Info ${ex}")
                }

            })
        }

        fun syncDevice(){
            Log.i(TAG,"setting time")
            BleSdkWrapper.setTime(object:OnLeWriteCharacteristicListener(){
                override fun onSuccess(result: HandlerBleDataResult?) {
                    Log.i(TAG, "Time is set ${result?.data}")
                    setStatus()
                }

                override fun onFailed(ex: WriteBleException?) {
                    Log.e(BandDevice.TAG, "Time set failed ${ex}")
                }
            })


        }

        fun loadData(){
            val currentTime = Calendar.getInstance().timeInMillis
            lastSyncTime?.let {
                Log.i(TAG,"Difference ${currentTime - it.time}")
            }
            if((lastSyncTime==null|| currentTime - lastSyncTime!!.time  > 1000) && !isSyncing) {
                isSyncing = true
                lastSyncTime = Calendar.getInstance().time
                DataSync.sendHeartBeat(HeartBeat(deviceId = device?.mDeviceName, macAddress = currentDeviceId!!))
                syncTemperature() {
                    syncHeartRate() {
                        syncSteps() {
                            Log.i(TAG, "Data sync complete")
                            isSyncing = false
                        }
                    }
                }
            }

        }

        private fun getDateFromTime(year:Int,month:Int,dayOfMonth:Int,hour:Int,minutes:Int):Date{
            val cal = Calendar.getInstance()
            cal.set(year,month,dayOfMonth,hour,minutes,0)
            cal.set(Calendar.MILLISECOND,0)
            return cal.time
        }

        private fun syncSteps(next: (() -> Unit)?){
            val cal = Calendar.getInstance()
            BleSdkWrapper.getStepOrSleepHistory(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH)+1, cal.get(Calendar.DAY_OF_MONTH), object : OnLeWriteCharacteristicListener() {
                override fun onSuccess(handlerBleDataResult: HandlerBleDataResult) {
                    if(handlerBleDataResult.isComplete){
                        if(handlerBleDataResult.data is List<*>){
                            val exerciseDataSets = handlerBleDataResult.data as List<HealthSportItem>
                            val dailySteps = mutableListOf<DailyStepUpload>()
                            val steps = mutableListOf<StepUpload>()
                            val dailyCalories = mutableListOf<CaloriesUpload>()
                            var totalSteps = 0
                            var totalCalories = 0
                            exerciseDataSets.filter { it!=null&&it.stepCount>0 }.forEach {
                                Log.i(TAG,"Got Step data ${it} ${it.hour} ${it.minuter} ")
                                val readingTime = getDateFromTime(it.year,it.month,it.day,it.hour,it.minuter)
                                totalSteps+=it.stepCount
                                totalCalories+=it.calory
                                steps.add(StepUpload(measureTime = readingTime,deviceId = currentDeviceId!!,steps = it.stepCount))
                            }
                            val dailyTime = Calendar.getInstance()
                            dailyTime.set(cal.get(Calendar.YEAR),cal.get(Calendar.MONTH),cal.get(Calendar.DAY_OF_MONTH),0,0,0)
                            dailyTime.set(Calendar.MILLISECOND,0)
                            dailySteps.add(DailyStepUpload(measureTime = dailyTime.time,deviceId = currentDeviceId!!,steps = totalSteps))
                            dailyCalories.add(CaloriesUpload(measureTime = dailyTime.time,deviceId = currentDeviceId!!, calories = totalCalories))
                            DataSync.uploadCalories(dailyCalories)
                            DataSync.uploadDailySteps(dailySteps)
                            DataSync.uploadStepInfo(steps)
                        }
                    }
                    if(next!=null)
                        next()
                }

                override fun onFailed(p0: WriteBleException?) {
                    if(next!=null)
                        next()
                }

            })
        }

        private fun syncHeartRate(next: (() -> Unit)?){
            val cal = Calendar.getInstance()
            BleSdkWrapper.getHistoryHeartRateData(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH)+1, cal.get(Calendar.DAY_OF_MONTH), object : OnLeWriteCharacteristicListener() {
                override fun onSuccess(handlerBleDataResult: HandlerBleDataResult) {
                    if (handlerBleDataResult.isComplete) {
                        Log.i(TAG,"Got Heart result ${handlerBleDataResult.data}")
                        if(handlerBleDataResult.data is List<*>){
                            val heartRateInfos = handlerBleDataResult.data as List<HealthHeartRateItem>
                            val oxygenUploads = mutableListOf<OxygenLevelUpload>()
                            val bloodPressureUploads = mutableListOf<BpUpload>()
                            val heartRateUploads = heartRateInfos.filter { it!=null&&it.heartRaveValue>0 }.map {
                                Log.i(TAG,"Got HR Data ${it} ${it.hour} ${it.minuter} ")
                                val readingTime = getDateFromTime(it.year,it.month,it.day,it.hour,it.minuter)
                                bloodPressureUploads.add(BpUpload(measureTime = readingTime,systolic = it.ss,distolic = it.fz,deviceId = currentDeviceId!!))
                                oxygenUploads.add(OxygenLevelUpload(measureTime = readingTime,oxygenLevel = it.oxygen,deviceId = currentDeviceId!!))
                                HeartRateUpload(measureTime = readingTime,deviceId = currentDeviceId!!,heartRate = it.heartRaveValue)
                            }
                            DataSync.uploadHeartRate(heartRateUploads)
                            DataSync.uploadBloodPressure(bloodPressureUploads)
                            DataSync.uploadOxygenData(oxygenUploads)
                        }
                        if(next!=null)
                            next()
                    }
                }
                override fun onFailed(e: WriteBleException) {
                    if(next!=null)
                        next()
                }
            })
        }

        private fun syncTemperature(next: (() -> Unit)?){
            val cal = Calendar.getInstance()
            BleSdkWrapper.getHistoryTemp(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH)+1, cal.get(Calendar.DAY_OF_MONTH), object : OnLeWriteCharacteristicListener() {
                override fun onSuccess(handlerBleDataResult: HandlerBleDataResult) {
                    if (handlerBleDataResult.isComplete) {
                        Log.i(TAG,"Got temperature result ${handlerBleDataResult.data}")
                        if(handlerBleDataResult.data is List<*>){
                            val tempInfos = handlerBleDataResult.data as List<TempInfo?>
                            val tempUploads = tempInfos.filter { tempInfo ->
                                tempInfo != null && tempInfo.tmpHandler > 0
                            }.map {
                                val celsius:Double = it!!.tmpHandler/100.0
                                val fahrenheit = (celsius*9/5)+32
                                TemperatureUpload(deviceId = currentDeviceId!!,measureTime = getDateFromTime(it.year,it.month,it.day,it.hour,it.minute),fahrenheit = fahrenheit,celsius = celsius)
                            }
                            DataSync.uploadTemperature(tempUploads)
                            if(next!=null)
                                next()
                        }
                    }
                }
                override fun onFailed(e: WriteBleException) {
                    if(next!=null)
                        next()
                }
            })

        }
    }

    private fun startDeviceConnection(context: Context, result: MethodChannel.Result?,deviceId:String? = null){
        mBluetoothLe!!.setOnConnectListener(TAG,ConnectionListener())
        isConnecting = true
        deviceId?.let {
            mBluetoothLe = mBluetoothLe?.setScanWithDeviceAddress(it)
        }
        mBluetoothLe!!.setScanPeriod(50000)
                .setReportDelay(0)
                .startScan(context, object : OnLeScanListener() {
                    override fun onScanResult(bluetoothDevice: BluetoothDevice, rssi: Int, scanRecord: ScanRecord) {
                        device = BLEDevice()
                        device?.let {bleDevice->
                            bleDevice.mDeviceAddress = bluetoothDevice.address
                            bleDevice.mDeviceName = bluetoothDevice.name
                            bleDevice.mRssi = rssi
                            ConnectionListener.result = result
                            mBluetoothLe!!.startConnect(bleDevice.mDeviceAddress)
                            mBluetoothLe!!.stopScan()
                        }
                    }

                    override fun onBatchScanResults(results: List<ScanResult>) {
                        Log.i(TAG, "Got results ：$results")
                    }

                    override fun onScanCompleted() {
                        mBluetoothLe!!.stopScan()
                    }

                    override fun onScanFailed(e: ScanBleException) {
                        Log.e(TAG, "Sa failed：$e")
                        onScanCompleted()
                        mBluetoothLe!!.stopScan()
                    }
                })
    }

    override fun connectDevice(context: Context, result: MethodChannel.Result) {
        Log.i(TAG,"The package id is ${context.packageName}")
        if(mBluetoothLe==null) {
            Log.i(TAG,"Bluetooth le is null initializing it")
            BluetoothLe.getDefault().init(context, object: BleCallbackWrapper(){
                override fun setSuccess() {
                    Log.i(TAG,"Init success")
                }

                override fun complete(resultCode: Int, data: Any?) {
                    mBluetoothLe = BluetoothLe.getDefault()
                    Log.i(TAG,"Init complete ${mBluetoothLe}")
                    startDeviceConnection(context,result)
                }

            })
        }

    }

    override fun syncData(result: MethodChannel.Result, connectionInfo: ConnectionInfo, context: Context){
        currentDeviceId = connectionInfo.deviceId
        if(mBluetoothLe==null) {
            Log.i(TAG, "Bluetooth le is null initializing it")
            BluetoothLe.getDefault().init(context, object : BleCallbackWrapper() {
                override fun setSuccess() {
                    Log.i(TAG, "Init success")
                }

                override fun complete(resultCode: Int, data: Any?) {
                    mBluetoothLe = BluetoothLe.getDefault()
                    Log.i(TAG, "Init complete ${mBluetoothLe}")
                    if (!mBluetoothLe!!.connected)
                        startDeviceConnection(context, null, connectionInfo.deviceId)
                    else
                        loadData()
                }
            })
            result.success("Load complete")
        }else{
            if (!mBluetoothLe!!.connected)
                startDeviceConnection(context, null, connectionInfo.deviceId)
            else
                loadData()
            result.success("Load complete")
        }
    }

    
}