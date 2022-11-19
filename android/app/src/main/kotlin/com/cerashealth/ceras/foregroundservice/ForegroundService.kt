package com.cerashealth.ceras.foregroundservice

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.cerashealth.ceras.AppSync
import com.cerashealth.ceras.CerasBluetoothSync
import com.cerashealth.ceras.MainActivity
import com.cerashealth.ceras.R
import com.cerashealth.ceras.lifeplus.BaseDevice
import com.cerashealth.ceras.lifeplus.data.ConnectionInfo
import com.google.gson.Gson
import com.google.gson.internal.LinkedTreeMap
import java.util.concurrent.TimeUnit

class ForegroundService : Service() {
    private val CHANNEL_ID = "ForegroundService Kotlin"
    private val mInterval = 300000 // 5 min
    private var mHandler: Handler? = null
    companion object {
        fun startService(context: Context, message: String) {
            val startIntent = Intent(context, ForegroundService::class.java)
            startIntent.putExtra("inputExtra", message)
            ContextCompat.startForegroundService(context, startIntent)
        }
        fun stopService(context: Context) {
            val stopIntent = Intent(context, ForegroundService::class.java)
            context.stopService(stopIntent)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        //do heavy work on a background thread
        val input = intent?.getStringExtra("inputExtra")
        createNotificationChannel()
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0, notificationIntent, 0
        )
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Ceras")
            .setContentText(input)
            .setSmallIcon(R.drawable.sync)
            .setContentIntent(pendingIntent)
            .build()
        startForeground(1, notification)

        mHandler = Handler()
        startRepeatingTask()

        return START_NOT_STICKY
    }

    var mStatusChecker: Runnable = object : Runnable {
        override fun run() {
            try {
                doWork()
            } finally {
                mHandler!!.postDelayed(this, mInterval.toLong())
            }
        }
    }
    //////////////THIS IS SAME FUNCTION IN MAINACTIVITY//////////////
    public fun doWork() {
        try {
            Log.i(MainActivity.TAG, "Doing background work")
            val devicesListString = this.getSharedPreferences(MainActivity.SharedPrefernces, Context.MODE_PRIVATE)
                .getString("flutter.deviceData", "")
            Gson().fromJson(devicesListString, List::class.java).forEach {
                //val data = Gson().fromJson(it.toString(),Map::class.java)
                val currentData = it as LinkedTreeMap<String, Any>
                val watchInfo = it["watchInfo"] as LinkedTreeMap<String, Any>
                val connectionInfo = ConnectionInfo().apply {
                    deviceId = watchInfo["deviceId"].toString()
                    deviceName = watchInfo["deviceName"].toString()
                    deviceType = watchInfo["deviceType"].toString()
                    additionalInformation = watchInfo["additionalInformation"] as LinkedTreeMap<String, String>
                }
                BaseDevice.getDeviceImpl(connectionInfo.deviceType).syncData(null, connectionInfo, this)
            }
            Toast.makeText(applicationContext,"DoWork function is called Successfully", Toast.LENGTH_SHORT).show()
        }catch(ex:Exception){
            Toast.makeText(applicationContext,"DoWork function is called with Exception That is:" + ex.toString(), Toast.LENGTH_SHORT).show()
            Log.e(CerasBluetoothSync.TAG,"Error syncing health data",ex)
        }
    }
    ////////////////////////////////////////////////////////////////////////////////
    fun startRepeatingTask() {
        mStatusChecker.run()
    }

    fun stopRepeatingTask() {
        mHandler!!.removeCallbacks(mStatusChecker)
    }
    override fun onBind(intent: Intent): IBinder? {
        return null
    }
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(CHANNEL_ID, "Ceras is capturing Health Data",
                NotificationManager.IMPORTANCE_DEFAULT)
            val manager = getSystemService(NotificationManager::class.java)
            manager!!.createNotificationChannel(serviceChannel)
        }
    }
}