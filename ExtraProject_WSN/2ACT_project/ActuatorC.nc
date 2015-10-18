configuration ActuatorC {
}
implementation {
  components MainC, ActuatorP, LedsC, PlatformSerialC;
  components ActiveMessageC as Radio, SerialActiveMessageC as Serial;
  	  

  MainC.Boot <- ActuatorP;

  ActuatorP.RadioControl -> Radio;
  ActuatorP.SerialControl -> Serial;
  
  ActuatorP.UartSend -> Serial.AMSend;
  ActuatorP.UartPacket -> Serial.Packet;
  ActuatorP.UartAMPacket -> Serial.AMPacket;
  ActuatorP.UartByte -> PlatformSerialC;
  
  ActuatorP.RadioSend -> Radio.AMSend;
  ActuatorP.RadioReceive -> Radio.Receive;
  ActuatorP.RadioSnoop -> Radio.Snoop;
  ActuatorP.RadioPacket -> Radio.Packet;
  ActuatorP.RadioAMPacket -> Radio.AMPacket;
  
  ActuatorP.Leds -> LedsC;
}
