# Manipulation of LDAP control data.
#
# $Id$
#
# Copyright (C) 2004 Ian Macdonald <ian@caliban.org>
#

module LDAP
  class Control

    require 'openssl'

    # Take +vals+, produce an Array of values in ASN.1 format and then
    # convert the Array to DER.
    #
    def self::encode( *vals )
      encoded_vals = []

      vals.each do |val|
        encoded_vals <<
          case val
          when Integer
            OpenSSL::ASN1::Integer( val )
          when String
            OpenSSL::ASN1::OctetString.new( val )
          else
            # What other types may exist?
          end
      end

      OpenSSL::ASN1::Sequence.new( encoded_vals ).to_der
    end


    # Create a new LDAP::Control. +oid+ is the OID of the control, +value+ is the
    # value to be assigned to the control, and +criticality+ is the criticality
    # of the control, which should be *true* or *false*.
    def initialize( oid=nil, value=nil, criticality=false )
      @oid      = oid
      @value    = value
      @critical = criticality
    end


    # Copy constructor -- dup the Control's instance variables.
    def initialize_copy( original )
      super

      @oid      = original.oid.dup if original.oid
      @value    = original.value.dup if original.value
      @critical = original.critical?
    end


    ######
    public
    ######

    # The OID of the control in numeric format
    attr_accessor :oid

    # The ASN1-encoded value of the control
    attr_accessor :value

    # The criticality of the control
    attr_accessor :critical
    alias_method :critical?, :critical
    alias_method :iscritical, :critical
    alias_method :iscritical=, :critical=


    # Decode the Control's ASN1-encoded value and return its contents as an Array.
    def decode
      return OpenSSL::ASN1::decode( self.value ).value.inject( [] ) do |ary, val|
	      ary << val.value
      end
    end


    # Produce a concise representation of the control.
    def inspect
      "#<%s oid=%p value=%p iscritical=%p>" % [
        self.class.name,
        self.oid,
        self.value,
        self.critical?
        ]
    end

  end
end
