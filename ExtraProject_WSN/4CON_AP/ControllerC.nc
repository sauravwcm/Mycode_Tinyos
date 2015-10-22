#include "WiTemp.h"
#include <UserButton.h>

#define REF 30
#define KP  10
#define KI  20
#define DT  0.1
module ControllerC
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
	uint16_t sendVal=0;
	uint16_t  ref = REF,kp = KP,packet_count=0;
	int16_t   err= REF;
	//uint16_t data=0 ;		//received from sensor mote
	uint16_t  ki = KI;
	float 	integral=0,dt = DT;	// equal to sampling time

	message_t packet;

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
			uint16_t data ;

			if(incomingPacket ->NodeID == 3)
			{
				data = incomingPacket -> Data ;
				call Leds.led1Toggle();
				//call UartByte.send(data);		//serially send the value received from SEN (for checking)

				err = ref - data;

				//calculate controller OP
			
				integral = (integral + (float)(err * dt)) ;	
        		sendVal = (kp * err) + (ki * integral);
       
        		//controller OP calculated	

            	if(radioBusy==FALSE)
            	{
                	//creating packet
                	WsnMsg_t* msg= call Packet.getPayload(& packet, sizeof(WsnMsg_t));
                	msg -> NodeID= TOS_NODE_ID;
                	msg -> Data = sendVal;
					
                	//sending the packet
                	if(call AMSend.send(2, & packet, sizeof(WsnMsg_t))==SUCCESS)
                	{
                    	radioBusy=TRUE;
                    	call Leds.led2Toggle();
                    	packet_count++;
                	}
            	}
				
					
			}			
		}
		return msg;
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