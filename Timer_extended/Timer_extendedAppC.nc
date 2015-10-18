configuration Timer_extendedAppC
{

}
implementation
{
	components MainC, Timer_extendedC as App, LedsC;
	components new TimerMilliC() as Timer0;

	App -> MainC.Boot;
	App.Timer0 -> Timer0;
	App.Leds-> LedsC;
}