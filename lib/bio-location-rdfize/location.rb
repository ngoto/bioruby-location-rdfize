#
# Copyright::	Copyright (C) 2014 Joachim Baran <joachim.baran@gmail.com>
# License::	The Ruby License

module Bio

# Bio::Location is a class in BioRuby.
# For adding methods, the module Bio::Location::RDFize is included.
class Location

# Bio::Location::RDFize is a module for providing
# Bio::Location#rdfize method. 
# For the usage of the method, see the documentation of
# Bio::Location::RDFize#rdfize.
#
module RDFize

  # Base URI of FALDO for use with rdfize and rdfize_positions:
  FALDO = 'http://biohackathon.org/resource/faldo#'.freeze

  # Returns a FALDO based representation of the location
  # in RDF Turtle format.
  # *Arguments*:
  # * (required) _prefix_: URI prefix of the location's URIs
  # *Returns*::
  # * a string containing the location formatted using FALDO
  #   in RDF Turtle format; the URI prefix will be prepended
  #   before either xref ID or a composite string that captures
  #   the location uniquely
  def rdfize(prefix)
    # Less-than/greater-than (@lt, @gt) are currently not holding
    # enough information to determine whether a single seq. position
    # is affected, or whether start/end positions are targeted by
    # the relation.
    # For example, "<500..>1000" and ">500..<1000" are both encoded
    # as:
    #   @lt = @gt = true
    #   @from = 500
    #   @to = 1000
    # It is an ambiguous representation and the original meaning
    # can no longer be determined.
    if @lt or @gt
      raise "Error: cannot RDFize locations with < or > in them. Sorry."
    end

    if @strand == 1
      faldo_begin, faldo_end = @from, @to
    else
      # Reverse begin/end, if on the reverse strand (5'-3' FALDO requirement)
      faldo_end, faldo_begin = faldo_begin, faldo_end
    end
    
    id = @xref_id
    unless id
      id = "Location#{faldo_begin}-#{faldo_end}:#{@strand}"
    end

    if @caret
      return """<#{prefix}#{id}> a <#{FALDO}InBetweenPosition> ;
    <#{FALDO}after> <#{prefix}#{id}:begin> ;
    <#{FALDO}before> <#{prefix}#{id}:end> .

#{rdfize_positions("#{prefix}#{id}", faldo_begin, faldo_end)}
"""
    end

    if @from == @to
      begin_uri_suffix = 'position'
      end_uri_suffix = 'position'
    else
      begin_uri_suffix = 'begin'
      end_uri_suffix = 'end'
    end

    return """<#{prefix}#{id}> a <#{FALDO}Region> ;
    <#{FALDO}begin> <#{prefix}#{id}:#{begin_uri_suffix}> ;
    <#{FALDO}end> <#{prefix}#{id}:#{end_uri_suffix}> .

#{rdfize_positions("#{prefix}#{id}", faldo_begin, faldo_end, begin_uri_suffix, end_uri_suffix)}
"""
  end

private

  # Returns FALDO ExactPosition RDF Turtle for @from and @to. Will only
  # serialize a single position if begin/end URI suffixes coincide.
  #
  # *Arguments*:
  # * (required) _location_prefix_: URI prefix of the location object
  #                                 whose positions are being described here
  # * (required) _faldo_begin_: start coordinate of the location
  # * (required) _faldo_end_: end coordinate of the location
  # * (optional) _begin_suffix_ : URI suffix that should be used for faldo_begin coodinate
  # * (optional) _end_suffix_ : URI suffix that should be used for faldo_end coodinate
  # *Returns*::
  # * a string containing FALDO ExactPosition instances that represent
  #   the location's start/end coordinates.
  def rdfize_positions(location_prefix, faldo_begin, faldo_end, begin_suffix = 'begin', end_suffix = 'end')
    if @strand == 1
      strandtype = "<#{FALDO}ForwardStrandedPosition>"
    else
      strandtype = "<#{FALDO}ReverseStrandedPosition>"
    end

    begin_uri = """<#{location_prefix}:#{begin_suffix}> a <#{FALDO}ExactPosition>, #{strandtype} ;
    <#{FALDO}position> #{faldo_begin} .
"""

    if begin_suffix == end_suffix
      end_uri = ''
    else
      end_uri = """<#{location_prefix}:#{end_suffix}> a <#{FALDO}ExactPosition>, #{strandtype} ;
    <#{FALDO}position> #{faldo_end} .
"""
    end

    return begin_uri + end_uri
  end

end #module RDFize

# adding the above methods to Bio::Locations
include RDFize

end # Locations

end # Bio
