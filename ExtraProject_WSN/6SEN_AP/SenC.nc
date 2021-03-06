#include "WiTemp.h"
#include <UserButton.h>
#define SIGMA 0.00001

//#define PERIODIC 

module SenC
{
	uses
	{
		//general
		interface Boot;
		interface Leds;
		interface Timer<TMilli>;
		interface Notify<button_state_t>;

		interface SplitControl as SerialControl;
    	interface SplitControl as RadioControl;
		
		//for Radio comms
		interface Packet as RadioPacket;
		interface AMPacket as RadioAMPacket;
		interface AMSend;
		//interface SplitControl as AMControl;
		interface Receive;			
	
		interface UartByte;
		interface UartStream;
	}
}
implementation
{
	
	bool radioBusy= FALSE;
	uint8_t  sendVal=0, count=0;
	message_t packet;
	//uint8_t serial_data,timeout=0xff;
	uint16_t ser_byte=0, packet_count=0, send_byte;
	int16_t e=0;
  	uint16_t length=1;
	
  	task void radioSendToCon();

	event void Boot.booted()
	{
		call Notify.enable();
		call RadioControl.start();
		call SerialControl.start();
	}

	event void Notify.notify(button_state_t state)
  	{
	    if (state == BUTTON_PRESSED)
	    {
	      call Leds.led1On();
	      call UartByte.send(0xff & (packet_count>>8));
	      call UartByte.send(0xff & packet_count);
	      call UartByte.send('\n');
	    }
	    else if (state == BUTTON_RELEASED)
	    {
	      call Leds.led1Off();
	    }
  	}
	event void SerialControl.startDone(error_t error) 
	{
		if (error==SUCCESS)
		{
			call UartStream.receive(&ser_byte, length);
		}
		else
		{
			call SerialControl.start();
		}

			
	}

	event void Timer.fired()
	{

	}

	async event void UartStream.receivedByte(uint8_t byte)
  	{

	    call Leds.led0Toggle();
	    e = (uint16_t)byte - ser_byte ;

	    if (e<0)
		{
			e= -e;
		}
		#ifndef PERIODIC
	  	if ( e >= (float)(SIGMA*ser_byte))
	    {
			if(radioBusy==FALSE)
		    {
		    	send_byte = (uint16_t)byte;
		    	post radioSendToCon();
		    	radioBusy=TRUE;
		    }
	    }
	    #else
	    	if(radioBusy==FALSE)
		    {
		    	send_byte = (uint16_t)byte;
		    	post radioSendToCon();
		    	radioBusy=TRUE;
		    }
	    #endif
	    ser_byte = (uint16_t)byte;	
  	}

  	task void radioSendToCon()
  	{
  		//creating packet
        WsnMsg_t* msg= call RadioPacket.getPayload(& packet, sizeof(WsnMsg_t));
        msg -> NodeID= TOS_NODE_ID;
        msg -> Data = send_byte;

        //sending the packet
        if(call AMSend.send(1, & packet, sizeof(WsnMsg_t))==SUCCESS)
        {
            //radioBusy=TRUE;
            call Leds.led2Toggle();
            packet_count++;
        }
        else
        {
        	post radioSendToCon();
        }
  	}

	async event void UartStream.receiveDone(uint8_t *buf, uint16_t len, error_t error)
	{
	  call Leds.led0Toggle();
	}

	async event void UartStream.sendDone(uint8_t *buf, uint16_t len, error_t error)
	{

	}	

	event void AMSend.sendDone(message_t *msg, error_t error)
	{
		if(msg == & packet)
		{
			radioBusy = FALSE;
		}
	}

	event void RadioControl.startDone(error_t error)
	{
		if(error==FAIL)
		{
			call RadioControl.start();
		}
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		if(len == sizeof(WsnMsg_t))
		{
			WsnMsg_t * incomingPacket = (WsnMsg_t*) payload;
			//incomingPacket ->NodeID == 1;
			uint8_t data = incomingPacket -> Data ;
			
			/*if(incomingPacket->NodeID == 2)
			{
				call Leds.led1Toggle();
					
			}	
			else
			{
				call Leds.led1Off();
			}*/
				
		}
		return msg;
	}

	

  	event void SerialControl.stopDone(error_t error) {}
	
	event void RadioControl.stopDone(error_t error)
	{
		// TODO Auto-generated method stub
	}
}

