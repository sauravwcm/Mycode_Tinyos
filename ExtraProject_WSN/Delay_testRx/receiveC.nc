#include "WiTemp.h"
#include <UserButton.h>

#define REF 30
#define KP  5
#define KI  15
#define DT  0.1
module receiveC
{
	uses
	{
		//general
		interface Boot;
		interface Leds;
		interface Timer<TMilli>;
		interface Notify<button_state_t>;
		
		interface SplitControl as SerialControl;
		interface UartByte;

		//for Radio comms
		interface Packet;
		interface AMPacket;
		interface AMSend;
		interface SplitControl as AMControl;
		interface Receive;			
	}
}
implementation
{
	
	bool radioBusy= FALSE;
	//uint8_t  sendVal=0;			//controller OP (u)
	uint16_t sendVal=0xabcd;
	uint16_t  ref = REF,kp = KP,packet_count=0,send_byte, data;
	int16_t   err= REF;
	//uint16_t data=0 ;		//received from sensor mote
	uint16_t  ki = KI;
	float 	integral=0,dt = DT;	// equal to sampling time

	message_t packet;

	task void radioSendToSen();
	task void controlAlgo();
	event void Boot.booted()
	{
		//call Timer.startPeriodic(100);
		call Notify.enable();
		call AMControl.start();
		call SerialControl.start();

	}

	event void Timer.fired()
	{
        	
	}

	event void Notify.notify(button_state_t state)
  	{
	    if (state == BUTTON_PRESSED)
	    {
	      call Leds.led0On();
	      call UartByte.send(0xff & (packet_count>>8));
	      call UartByte.send(0xff & packet_count);
	      call UartByte.send('\t');
	    }
	    else if (state == BUTTON_RELEASED)
	    {
	      call Leds.led0Off();
	    }
  	}
	event void AMSend.sendDone(message_t *msg, error_t error)
	{
		if(msg == & packet)
		{
			radioBusy = FALSE;
		}
	}

	event void AMControl.startDone(error_t error)
	{
		if(error==FAIL)
		{
			call AMControl.start();
		}
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		if(len == sizeof(WsnMsg_t))
		{
			WsnMsg_t * incomingPacket = (WsnMsg_t*) payload;

			if(incomingPacket ->NodeID == 3)
			{

				data = incomingPacket -> Data ;
					
            	if(radioBusy==FALSE)
            	{
            		post radioSendToSen();
            		radioBusy=TRUE;
            	}
				call Leds.led1Toggle();		
			}			
		}
		return msg;
	}

	task void radioSendToSen()
	{
		//creating packet
    	WsnMsg_t* msg= call Packet.getPayload(& packet, sizeof(WsnMsg_t));
    	msg -> NodeID= TOS_NODE_ID;
    	msg -> Data = data;
		
    	//sending the packet
    	if(call AMSend.send(3, & packet, sizeof(WsnMsg_t))==SUCCESS)
    	{
        	
        	call Leds.led2Toggle();
        	
    	}
    	else
    	{
    		post radioSendToSen();
    	}
	}

	task void controlAlgo()
	{
		err = ref - data;

		//calculate controller OP
	
		integral = (integral + (float)(err * dt)) ;	
		sendVal = (kp * err) + (ki * integral);

		//controller OP calculated
	}
	

	event void AMControl.stopDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void SerialControl.startDone(error_t error) 
	{

			call SerialControl.start();
	}

  	event void SerialControl.stopDone(error_t error) {}
}