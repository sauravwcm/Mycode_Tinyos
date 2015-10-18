#include "WiTemp.h"
module WiTempC
{
	uses
	{
		//general
		interface Boot;
		interface Leds;
		interface Timer<TMilli>;
		
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
	uint16_t ser_byte=0;
  	uint16_t length=1;
	

	event void Boot.booted()
	{
		//call Timer.startPeriodic(100);
		call Leds.led1On();
		call RadioControl.start();
		call SerialControl.start();
		call UartStream.receive(&ser_byte, length);
	}

	event void Timer.fired()
	{
		call Leds.led1Off();
	
		if(radioBusy==FALSE)
            {
                //creating packet
                WsnMsg_t* msg= call RadioPacket.getPayload(& packet, sizeof(WsnMsg_t));
                msg -> NodeID= TOS_NODE_ID;
                msg -> Data = ser_byte;
		
                //sending the packet
                if(call AMSend.send(1, & packet, sizeof(WsnMsg_t))==SUCCESS)
                {
                    radioBusy=TRUE;
                    call Leds.led2Toggle();
                    //call UartByte.send(msg -> Data);

                }
            }
		
            else
            {
		 	call Leds.led0Toggle();
            }	

    }

	async event void UartStream.receivedByte(uint8_t byte)
  {
  	static count=0;

  	
  	if (count==0)
  	{
  		call Timer.startPeriodic(100);
  		count++ ;
  	}
    call Leds.led0Toggle();
    
    ser_byte = (uint16_t)byte;

    
    	
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
		if(error==SUCCESS)
		{
			//call Leds.led0On();
		}
		else
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

	event void SerialControl.startDone(error_t error) 
	{

			call SerialControl.start();
	}

  	event void SerialControl.stopDone(error_t error) {}
	
	event void RadioControl.stopDone(error_t error){
		// TODO Auto-generated method stub
	}
}