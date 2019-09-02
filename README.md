# Introducing the sms_serial gem

    require 'sms_serial'

    notice = ->(s) do
      puts 'incoming sms: ' + s
    end

    sms = SmsSerial.new('/dev/ttyUSB0', callback: notice)

    # count the number of SMS messages
    sms.count
    #=> 1

    sms.read 1
    #=> => {:header=>{:sender=>"+441372461", :sent=>2019-09-02 22:52:03 +0400}, :body=>"Your onetime code is 6368"} 

    # observing an incoming message
    #=> incoming sms: +CMTI: "SM",2

    sms.delete_all
    #=> "AT+CMGD=1,1\r\r\r\n==========\r\nSIM OK\r\n==========\r\n" 

    sms.read 1
    #=> SmsSerialError (Message not found)


The above example was tested using a TTGO T-Call Arduino compatible board. The related Arduino sketch can be found ?here http://www.jamesrobertson.eu/arduino/2019/aug/31/receiving-sms-using-the-ttgo-t-call.html?. 

The gist of the code is here:

<pre>
void loop()
{
    if (hwSerial.available()) {
        const char *s = hwSerial.readStringUntil('\n').c_str();
        if (strstr(s, "OK" ) != NULL) {
            Serial.println("SIM OK");
        } else if (strstr(s, "+CPIN: NOT READY") != NULL) {
            Serial.println("SIM +CPIN: NOT READY");
        } else if (strstr(s, "+CPIN: READY") != NULL) {
            Serial.println("SIM +CPIN: READY");
        } else if (strstr(s, "+CLIP:") != NULL) {
            Serial.printf("SIM %s\n", s);
        } else if (strstr(s, "RING") != NULL) {
            delay(200);
            hwSerial.write("ATA\r\n");
            Serial.println("SIM RING");
        } else if (strstr(s, "Call Ready") != NULL) {
            Serial.println("SIM Call Ready");
        } else if (strstr(s, "SMS Ready") != NULL) {
            Serial.println("SIM SMS Ready");
        } else if (strstr(s, "NO CARRIER") != NULL) {
            Serial.println("SIM NO CARRIER");
        } else if (strstr(s, "NO DIALTONE") != NULL) {
            Serial.println("SIM NO DIALTONE");
        } else if (strstr(s, "BUSY") != NULL) {
            Serial.println("SIM BUSY");
        } else {
            Serial.println(s);                                     
        }
        Serial.println("==========");
    }

    if (Serial.available()) {
        String r = Serial.readString();
        hwSerial.write(r.c_str());
        

    }
}
</pre>

As you can observe from above, each output is printed on its own new line.

## Resources

* sms_serial https://rubygems.org/gems/sms_serial

ttgo arduino serialport serial sms gsm gprs message
