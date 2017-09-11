## 获取不同分辨率设备相对于TRAGET_DEVICE分辨率的比例 ##

    
    private float RATIO = 1f;
    private float TRAGET_DEVICE_HEIGHT = 1920;
    private float TRAGET_DEVICE_WIDTH = 1080;
     /**
     * 初始化RATTO
     */
    private void initRatto() {
        DisplayMetrics displayMetrics = new DisplayMetrics();
        WindowManager mWm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        //android 4.2后增加了虚拟按键，API 17之后使用，获取的像素宽高包含虚拟键所占空间，在API 17之前通过反射获取
        if (Build.VERSION.SDK_INT >= 17) {
            mWm.getDefaultDisplay().getRealMetrics(displayMetrics);
        } else {
            Display display = mWm.getDefaultDisplay();
            @SuppressWarnings("rawtypes")
            Class c;
            try {
                c = Class.forName("android.view.Display");
                @SuppressWarnings("unchecked")
                Method method = c.getMethod("getRealMetrics", DisplayMetrics.class);
                method.invoke(display, displayMetrics);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        int screenWidth = displayMetrics.widthPixels;
        int screenHeight = displayMetrics.heightPixels;
        float ratioWidth = (float) screenWidth / TRAGET_DEVICE_WIDTH;
        float ratioHeight = (float) screenHeight / TRAGET_DEVICE_HEIGHT;
        RATIO = Math.min(ratioWidth, ratioHeight);
    } 

## 绘制字体 ##

    //假定在TRAGET_DEVICE屏幕下字体大小为35 
    Paint paint = new Paint();  
    paint.setTextSize(RATIO * 35);  
    canvas.drawText("test", 0, 0, paint);    
 
