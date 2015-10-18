configuration BasicAppC
{
	
}
implementation 
{
	components MainC, BasicC, LedsC;
	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as Timer1;

	BasicC -> MainC.Boot;
	BasicC.Timer0 -> Timer0;
	BasicC.Timer1 -> Timer1;
	BasicC.Leds -> LedsC;
}