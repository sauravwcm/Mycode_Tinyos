module BasicC
{
	uses
	{
	 interface Boot;
	 interface Timer<TMilli> as Timer0;
	 interface Timer<TMilli> as Timer1;
	 interface Leds;
	}
}
implementation
{
	enum
	{
		WARN_INTERVAL = 4096, WARN_DURATION = 64
	};
	event void Boot.booted()
	{
		call Timer1.startPeriodic(1000);
		signal Timer0.fired();
		
	}

	event void Timer1.fired()
	{
		call Leds.led1Toggle();
	}
	event void Timer0.fired()
	{
		if (call Leds.get() & LEDS_LED0)
		{
			call Leds.led0Off();
			call Timer0.startOneShot(WARN_INTERVAL-WARN_DURATION);
		}
		else
		{
			call Leds.led0On();
			call Timer0.startOneShot(WARN_DURATION);
		}
	}
}