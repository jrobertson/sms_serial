#!/usr/bin/env ruby

# file: sms_serial.rb

require 'c32'
require 'csv'
require 'time'
require "serialport"


class SmsSerialError < Exception
end

class SmsSerial
  using ColouredText

  attr_reader :t

  def initialize(dev='/dev/ttyUSB0', callback: nil, debug: false)

    @debug = debug
    @sp = SerialPort.new dev, 115200    
    puts 'running ' + "SmsSerial".highlight 

    @t = Thread.new {

      Thread.current[:v] = []

      loop do

        message = @sp.read
        if message.length > 0
    
          callback.call(message) if callback and @debug
    
          if message =~ /^\+CMTI:/ then
            callback.call(message.lines[2]) if callback
          else

            Thread.current[:v] ||= []
            Thread.current[:v]  << message 

          end
        end
    
        sleep 0.3
    
      end
    }
    
  end

  # count the number of SMS messages
  #
  def count()

    puts 'inside count'.info if @debug

    cmd 'CPMS?' do |r|
      puts 'r: ' + r.inspect if @debug
      total = r.lines[2].split(',')[1].to_i
      puts ('message count: ' + total.to_s).debug if @debug

      total
    end
    
  end

  def delete(idx)
    
    return delete_all() if idx.to_sym == :all

    cmd 'CMD' do |r|
      total = r.lines[2].split(',')[1].to_i
      puts ('message count: ' + total.to_s).debug if @debug

      total
    end

  end
  
  alias del delete

  def delete_all()

    # format: [index, delflag]
    # delflag 1 means delete all read messages
    cmd 'CMGD=1,1'

  end

  def list_all()

    n = count()
    sleep 0.3

    @sp.write %Q(AT+CMGL="ALL"\r\n)
    n.times.map {r = read_buffer; parse_msg(r)}

    flush_output() if n < 1

  end

  # read an SMS message
  #
  def read(idx=1)

    cmd('CMGR=' + idx.to_s) do |r| 
      begin
        parse_msg r 
      rescue SmsSerialError => e
        puts 'Invalid message no.'.warning
        nil
      end
    end

  end

  private

  # e.g. cmd 'cmgr=1'
  #
  def cmd(s)

    puts ('inside cmd s: ' + s.inspect).debug if @debug
    r2 = @sp.write "AT+%s\r\n" % [s]
    puts 'r2: ' + r2.inspect if @debug
    puts '@t[:v] ' + @t[:v].inspect if @debug
    
    r = read_buffer

    block_given? ? yield(r) : r
  end

  def flush_output()
    r = read_buffer
    []
  end

  def read_buffer()
    
    sleep 2 if @debug

    puts 'inside read_buffer @t[:v]: ' + @t[:v].inspect if @debug
    r = ''
    @t[:v].any? ? (r += @t[:v].shift until @t[:v].empty?).to_s : r = ''
    
    puts 'read_buffer r: ' + r.inspect if @debug
    r
    
  end

  def parse_msg(r)

    puts ('parse_msg r: ' + r.inspect).debug if @debug
    return if r.empty?
    heading = r.lines[2][/\+CMG[RL]: (?:[^,]+,)?(.*)/,1]
    puts ('heading: ' + heading.inspect).debug if @debug

    raise SmsSerialError, "Message not found" unless heading

    sender, sent = CSV.parse(heading).first.values_at(0,2)
    {sender: sender, sent: Time.parse(sent), body: r.lines[4].rstrip}

  end

end
