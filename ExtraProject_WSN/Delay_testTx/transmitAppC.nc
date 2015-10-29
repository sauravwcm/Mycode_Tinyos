configuration transmitAppC
{
}
implementation
{
	//general
	components transmitC as App;
	components MainC;
	components LedsC;
	components UserButtonC;
	components new TimerMilliC();
	components PlatformSerialC;

	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer -> TimerMilliC;
	App.Notify -> UserButtonC;
	
	//for temperature sensor
	//components new SensirionSht11C() as TempSensor;
	
	//App.TempRead -> TempSensor.Temperature;
	
	//radioComm
	components ActiveMessageC;
	components new AMSenderC(AM_RADIO);
	components new AMReceiverC(AM_RADIO);
	components SerialActiveMessageC as Serial;
	
	App.RadioPacket -> AMSenderC;
	App.RadioAMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.RadioControl -> ActiveMessageC;
	App.Receive -> AMReceiverC; 

	App.SerialControl -> Serial;
	App.UartByte -> PlatformSerialC;
	App.UartStream -> PlatformSerialC;
	
}