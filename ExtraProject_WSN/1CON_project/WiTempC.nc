#include "WiTemp.h"

#define REF 20
module WiTempC
{
	uses
	{
		//general
		interface Boot;
		interface Leds;
		interface Timer<TMilli>;
		
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
	uint16_t  ref = REF, err = REF ,kp = 5;

	//uint16_t data=0 ;		//received from sensor mote
	uint16_t integral=0, ki=20;
	float 	dt = 0.1;	// equal to sampling time

	message_t packet;

	event void Boot.booted()
	{
		call Timer.startPeriodic(100);
		call Leds.led1On();
		call AMControl.start();
		call SerialControl.start();
	}

	event void Timer.fired()
	{
		call Leds.led1Off();
		call Leds.led2Toggle();
        	
        integral = (uint16_t)(integral + (err * dt)) ;	
        //calculate controller OP
        //err = ref - data;
        sendVal = (kp * err) + (ki * integral);
       
        //controller OP calculated	

            if(radioBusy==FALSE)
            {
                //creating packet
                WsnMsg_t* msg= call Packet.getPayload(& packet, sizeof(WsnMsg_t));
                msg -> NodeID= TOS_NODE_ID;
                msg -> Data = sendVal;
				//msg -> Data = data;
                //sending the packet
                if(call AMSend.send(2, & packet, sizeof(WsnMsg_t))==SUCCESS)
                {
                    radioBusy=TRUE;
                }
            }
		
            else
            {
		 	call Leds.led0Toggle();
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
		if(error==SUCCESS)
		{
			//call Leds.led0On();
		}
		else
		{
			call AMControl.start();
		}
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		/*static count=0;

		if (count==0)
		{
			call Timer.startPeriodic(100);
			count++;
		}*/
		if(len == sizeof(WsnMsg_t))
		{
			WsnMsg_t * incomingPacket = (WsnMsg_t*) payload;
			//incomingPacket ->NodeID == 1;
			//uint8_t dataL=0,dataH=0;
			uint16_t data = incomingPacket -> Data ;

			//sendVal = incomingPacket -> Data ;
			if(incomingPacket ->NodeID == 3)
			{
				//data = incomingPacket -> Data ;
				call Leds.led1Toggle();
				//call UartByte.send(data);		//serially send the value received from SEN (for checking)

				err = ref - data;

				//test
				/*dataL = 0xff & data;
        		dataH = 0xff & (data >> 8);

        		call UartByte.send(dataL);
        		call UartByte.send(dataH);
				*/
				//test done
					
			}	
			else
			{
				call Leds.led1Off();
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