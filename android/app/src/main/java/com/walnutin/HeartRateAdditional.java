package com.walnutin;

public class HeartRateAdditional {
    static {
        System.loadLibrary("Heart_rate_additional");
    }
    private long pointer;

    private native long constructor(long measuring_time, int heart_rate, int height, int weight, int gender, int age);

    private native void destructor(long pointer);

    private native int get_diastolic_blood_pressure(long pointer);

    private native int get_systolic_blood_pressure(long pointer);

    private native int get_blood_oxygen(long pointer);

    /**
     * gender male = 0 female = 1
     */
    public HeartRateAdditional(long measuring_time, int heart_rate, int height, int weight, int gender, int age) {
        pointer = constructor(measuring_time, heart_rate, height, weight, gender, age);
    }

    public synchronized void destroy() {
        if (pointer != 0) {
            destructor(pointer);
            pointer = 0;
        }
    }

    public int get_diastolic_blood_pressure()
    {
        return get_diastolic_blood_pressure(pointer);
    }

    public int get_systolic_blood_pressure()
    {
        return get_systolic_blood_pressure(pointer);
    }

    public int get_blood_oxygen()
    {
        return get_blood_oxygen(pointer);
    }
}