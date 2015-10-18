module Timer_extendedC
{
	uses
	{
		interface Boot;
		interface Leds;
		interface Timer<TMilli> as Timer0;
	}
}
implementation
{
	uint32_t base;
	enum
	{
		WARN_INTERVAL = 4096, WARN_DURATION = 64
	};
	event void Boot.booted()
	{
		base = call Timer0.getNow();
		signal Timer0.fired();
	}
	event void Timer0.fired()
	{
		if (call Leds.get() & LEDS_LED0)
		{
			call Leds.led0Off();
			call Timer0.startOneShotAt(base,WARN_INTERVAL-WARN_DURATION);
			base += WARN_INTERVAL-WARN_DURATION;
		}
		else
		{
			call Leds.led0On();
			call Timer0.startOneShotAt(base,WARN_DURATION);
			base +=WARN_DURATION;
		}
	}
}