
#include "AM.h"
#include "Serial.h"
#include "WiTemp.h"
//#include "msp430usart.h"

module ActuatorP 
{
  uses 
  {
    interface Boot;
    interface Timer<TMilli>;
    interface SplitControl as SerialControl;
    interface SplitControl as RadioControl;

    interface AMSend as UartSend[am_id_t id];
    interface Packet as UartPacket;
    interface AMPacket as UartAMPacket;
    interface UartByte;
    
    interface AMSend as RadioSend[am_id_t id];
    interface Receive as RadioReceive[am_id_t id];
    interface Receive as RadioSnoop[am_id_t id];
    interface Packet as RadioPacket;
    interface AMPacket as RadioAMPacket;

    interface Leds;
  }
}

implementation
{

  message_t  Data;					// most recently received message_t package
  message_t  *DataPtr = &Data;		// pointer to most recently received message_t package
  uint16_t act_val=0; 
  uint8_t data, dataL,dataH, head ='s',tail='\n' ;

  //task void uartSendTask();			// send package over serial port

  
  void failBlink() {
    call Leds.led0Toggle();			// toggle yellow LED to indicate failure during transmission
  }

  event void Boot.booted()      // initialization
  {		
    call Timer.startPeriodic(100);
    call RadioControl.start();
    call SerialControl.start();
  }

  event void Timer.fired()
  {
    call Leds.led1Off();

    dataL = 0xff & act_val;
    dataH = 0xff & (act_val >> 8);
   
    //sending 16 bit over uart,  send lower 8 bits 1st and then higher 8 bits
    call UartByte.send(head);
    call UartByte.send(dataL);
    call UartByte.send(dataH);
    if(call UartByte.send(tail)==FAIL)
    {
      failBlink();
    }
  }  
  event void RadioControl.startDone(error_t error) {}
  event void SerialControl.startDone(error_t error) {}

  event void SerialControl.stopDone(error_t error) {}
  event void RadioControl.stopDone(error_t error) {}

  message_t* receive(message_t* msg, void* payload, uint8_t len);	// receive package through radio
  
  event message_t *RadioSnoop.receive[am_id_t id](message_t *msg,
						    void *payload,
						    uint8_t len) 
  {
    return receive(msg, payload, len);
  }
  
  event message_t *RadioReceive.receive[am_id_t id](message_t *msg,
						    void *payload,
						    uint8_t len) 
  {
    return receive(msg, payload, len);
  }

  message_t* receive(message_t *msg, void *payload, uint8_t len) // receive package through radio
  {	
    message_t *ret;

  	if(len == sizeof(WsnMsg_t))
  	{
  		
  			WsnMsg_t * incomingPacket = (WsnMsg_t*) payload;


        if(incomingPacket ->NodeID == 1)
        {  
          act_val = incomingPacket -> Data ;
          call Leds.led1Toggle();          // TOGGLE led 1 when data received from node 1
        }	
  	}
  	atomic
    {
  		ret = DataPtr;
  		DataPtr = msg;
  	}
  	//call Leds.led1Toggle();			// toggle green LED to indicate success in receiving a radio package
  	

    return ret;						// return next available buffer for receiving packages
  }


  event void UartSend.sendDone[am_id_t id](message_t* msg, error_t error) 
  {
    if (error != SUCCESS)
      failBlink();
  }

  
  event void RadioSend.sendDone[am_id_t id](message_t* msg, error_t error) {}

}	// end implementation
