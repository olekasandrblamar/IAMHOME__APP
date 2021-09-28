package com.cerashealth.ceras.lifeplus

import android.content.Context
import android.util.Log
import com.inuker.bluetooth.library.Code
import com.inuker.bluetooth.library.search.SearchResult
import com.inuker.bluetooth.library.search.response.SearchResponse
import com.veepoo.protocol.VPOperateManager
import com.veepoo.protocol.listener.base.IConnectResponse
import com.veepoo.protocol.listener.base.INotifyResponse
import io.flutter.plugin.common.MethodChannel
import no.nordicsemi.android.support.v18.scanner.ScanFilter

class B360Device:BaseDevice(),SearchResponse {

    companion object{
        private const val B360DeviceTag = "B360Device"
        private var connectResult: MethodChannel.Result? = null
        private var deviceId:String? = ""
    }

    private var vManager:VPOperateManager? = null

    private fun getManager(context: Context):VPOperateManager{
       return  vManager?:VPOperateManager.getMangerInstance(context).apply {
            vManager = this
        }
    }

    override fun connectDevice(context: Context, result: MethodChannel.Result, deviceId: String?) {
        B360Device.deviceId = deviceId
        getManager(context).startScanDevice(this)
    }

    override fun onSearchStarted() {
        Log.i(B360DeviceTag,"Search started")
    }

    override fun onDeviceFounded(searchResult: SearchResult?) {
        searchResult?.let {
            val lastFour = it.address.substring(it.address.length - 5).replace(":", "")
            if(lastFour == deviceId){
                vManager?.connectDevice(it.address,it.name, { code, bleGattProfile, isOadModel -> {

                } }, {
                    if(it== Code.REQUEST_SUCCESS){

                    }else{

                    }
                })
            }
        }
    }

    override fun onSearchStopped() {
        Log.i(B360DeviceTag,"Search stopped")
    }

    override fun onSearchCanceled() {
        Log.i(B360DeviceTag,"Search cancelled")
    }

}