#ifndef WI_TEMP_H
#define WI_TEMP_H
typedef nx_struct WsnMsg
 {
 	nx_uint16_t NodeID;
 	//nx_uint8_t  Data;
	nx_uint16_t   Data;	
 }WsnMsg_t;
 
 enum
 {
 	AM_RADIO = 6
 }; 
#endif /* WI_TEMP_H */
