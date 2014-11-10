
# To run this test,
#  % bundle exec rake test
# or
#  % rake test
#

require 'helper'
require 'bio'

class TestBioLocationRdfize < Test::Unit::TestCase

  PREFIX = "http://localhost/test#".freeze

  def test_forward
    loc = Bio::Locations.new("123..456")[0]

    expected = <<EXPECTED
<http://localhost/test#Location123-456:1> a <http://biohackathon.org/resource/faldo#Region> ;
    <http://biohackathon.org/resource/faldo#begin> <http://localhost/test#Location123-456:1:begin> ;
    <http://biohackathon.org/resource/faldo#end> <http://localhost/test#Location123-456:1:end> .

<http://localhost/test#Location123-456:1:begin> a <http://biohackathon.org/resource/faldo#ExactPosition>, <http://biohackathon.org/resource/faldo#ForwardStrandedPosition> ;
    <http://biohackathon.org/resource/faldo#position> 123 .
<http://localhost/test#Location123-456:1:end> a <http://biohackathon.org/resource/faldo#ExactPosition>, <http://biohackathon.org/resource/faldo#ForwardStrandedPosition> ;
    <http://biohackathon.org/resource/faldo#position> 456 .

EXPECTED

    assert_equal(expected, loc.rdfize(PREFIX))
  end

  def test_reverse
    loc = Bio::Locations.new("complement(123..456)")[0]

    expected = <<EXPECTED
<http://localhost/test#Location-:-1> a <http://biohackathon.org/resource/faldo#Region> ;
    <http://biohackathon.org/resource/faldo#begin> <http://localhost/test#Location-:-1:begin> ;
    <http://biohackathon.org/resource/faldo#end> <http://localhost/test#Location-:-1:end> .

<http://localhost/test#Location-:-1:begin> a <http://biohackathon.org/resource/faldo#ExactPosition>, <http://biohackathon.org/resource/faldo#ReverseStrandedPosition> ;
    <http://biohackathon.org/resource/faldo#position>  .
<http://localhost/test#Location-:-1:end> a <http://biohackathon.org/resource/faldo#ExactPosition>, <http://biohackathon.org/resource/faldo#ReverseStrandedPosition> ;
    <http://biohackathon.org/resource/faldo#position>  .

EXPECTED

    assert_equal(expected, loc.rdfize(PREFIX))
  end

end
