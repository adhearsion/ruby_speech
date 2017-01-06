# encoding: utf-8
# frozen_string_literal: true

#
# Convert a simple DTMF string from "1 star 2" to "dtmf-1 dtmf-star dtmf-2".
#
# @param [Array] sequence A set of DTMF keys, such as `%w(1 star 2)`.
#
# @return [String] A string with "dtmf-" prefixed for each DTMF element.
#                  Example: "dtmf-1 dtmf-star dtmf-2".
#
def dtmf_seq(sequence)
  sequence.map { |d| "dtmf-#{d}" }.join ' '
end
