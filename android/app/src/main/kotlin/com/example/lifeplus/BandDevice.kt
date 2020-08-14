package com.example.lifeplus

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.content.Context
import android.util.Log
import com.cerashealth.ceras.ConnectionInfo
import com.zhj.bluetooth.zhjbluetoothsdk.bean.BLEDevice
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

    override fun onServicesDiscovered(p0: BluetoothGatt?) {
        BandDevice.isConnecting = false
        Log.i(BandDevice.TAG,"Device Services discovered")
    }

    override fun onDeviceConnecting() {

    }

}

class BandDevice :BaseDevice(){

    companion object{
        val TAG = BandDevice::class.java.simpleName
        var isConnecting = false
        var device:BLEDevice? = null
    }

    private var mBluetoothLe: BluetoothLe? = null

    private fun startDeviceConnection(context: Context, result: MethodChannel.Result?){
        mBluetoothLe!!.setOnConnectListener(BandDevice.TAG,ConnectionListener())
        isConnecting = true
        mBluetoothLe!!.setScanPeriod(10000)
                .setReportDelay(0)
                .startScan(context, object : OnLeScanListener() {
                    override fun onScanResult(bluetoothDevice: BluetoothDevice, rssi: Int, scanRecord: ScanRecord) {
                        device = BLEDevice()
                        device?.let {bleDevice->
                            bleDevice.mDeviceAddress = bluetoothDevice.address
                            bleDevice.mDeviceName = bluetoothDevice.name
                            bleDevice.mRssi = rssi
                            mBluetoothLe!!.startConnect(bleDevice.mDeviceAddress)
                            result?.let{methodResult->
                                methodResult.success(ConnectionInfo.createResponse(message = "Connected",connected = true,deviceId = bleDevice.mDeviceAddress,
                                        deviceName = bleDevice.mDeviceName,additionalInfo = mapOf("factoryName" to bleDevice.mDeviceName),deviceType = BaseDevice.BAND_DEVICE))
                            }
                            mBluetoothLe!!.stopScan()
                        }
                        Log.i(TAG,"setting time")
                        BleSdkWrapper.setTime(object:OnLeWriteCharacteristicListener(){
                            override fun onSuccess(p0: HandlerBleDataResult?) {
                                Log.i(TAG, "Time is set")
                            }

                            override fun onFailed(ex: WriteBleException?) {
                                Log.e(TAG, "Time set failed ${ex}")
                            }

                        })

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
                    Log.i(TAG,"Init complete")
                    startDeviceConnection(context,result)
                }

            })
        }

    }

    override fun syncData(result: MethodChannel.Result, connectionInfo: ConnectionInfo, context: Context){

    }
    
}