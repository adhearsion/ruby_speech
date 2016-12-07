module RubySpeech::GRXML::Builtins
  #
  # Create a grammar for interpreting a boolean response, where 1 is true and two is false.
  #
  # @param [Hash] options Options to parameterize the grammar
  # @option options [#to_s] :y The positive/truthy/affirmative digit
  # @option options [#to_s] :n The negative/falsy digit
  #
  # @return [RubySpeech::GRXML::Grammar] a grammar for interpreting a boolean response.
  #
  # @raise [ArgumentError] if the :y and :n options are the same
  #
  def self.boolean(options = {})
    truthy_digit = (options[:y] || options['y'] || '1').to_s
    falsy_digit = (options[:n] || options['n'] || '2').to_s

    raise ArgumentError, "Yes and no values cannot be the same" if truthy_digit == falsy_digit

    RubySpeech::GRXML.draw mode: :dtmf, root: 'boolean' do
      rule id: 'boolean', scope: 'public' do
        one_of do
          item do
            tag { 'true' }
            truthy_digit
          end
          item do
            tag { 'false' }
            falsy_digit
          end
        end
      end
    end
  end

  #
  # Create a grammar for interpreting a date.
  #
  # @return [RubySpeech::GRXML::Grammar] a grammar for interpreting a date in the format yyyymmdd
  #
  def self.date(options = nil)
    RubySpeech::GRXML.draw mode: :dtmf, root: 'date' do
      rule id: 'date', scope: 'public' do
        item repeat: '8' do
          one_of do
            0.upto(9) { |d| item { d.to_s } }
          end
        end
      end
    end
  end

  #
  # Create a grammar for interpreting a string of digits.
  #
  # @param [Hash] options Options to parameterize the grammar
  # @option options [#to_i] :minlength Minimum length for the string of digits.
  # @option options [#to_i] :maxlength Maximum length for the string of digits.
  # @option options [#to_i] :length Absolute length for the string of digits.
  #
  # @return [RubySpeech::GRXML::Grammar] a grammar for interpreting an integer response.
  #
  # @raise [ArgumentError] if any of the length attributes logically conflict
  #
  def self.digits(options = {})
    raise ArgumentError, "Cannot specify both absolute length and a length range" if options[:length] && (options[:minlength] || options[:maxlength])

    minlength = options[:minlength] || options['minlength'] || 0
    maxlength = options[:maxlength] || options['maxlength']
    length = options[:length] || options['length']

    repeat = length ? length : "#{minlength}-#{maxlength}"

    RubySpeech::GRXML.draw mode: :dtmf, root: 'digits' do
      rule id: 'digits', scope: 'public' do
        item repeat: repeat do
          one_of do
            0.upto(9) { |d| item { d.to_s } }
          end
        end
      end
    end
  end

  #
  # Create a grammar for interpreting a monetary value. Uses '*' as the decimal point.
  # Matches any number of digits, optionally followed by a '*' and up to two more digits.
  #
  # @return [RubySpeech::GRXML::Grammar] a grammar for interpreting a monetary value.
  #
  def self.currency(options = nil)
    RubySpeech::GRXML.draw mode: :dtmf, root: 'currency' do
      rule id: 'currency', scope: 'public' do
        item repeat: '0-' do
          ruleref uri: '#digit'
        end
        item repeat: '0-1' do
          item { '*' }
          item repeat: '0-2' do
            ruleref uri: '#digit'
          end
        end
      end

      rule id: 'digit' do
        one_of do
          0.upto(9) { |d| item { d.to_s } }
        end
      end
    end
  end

  #
  # Create a grammar for interpreting a numeric value. Uses '*' as the decimal point.
  # Matches any number of digits, optionally followed by a '*' and any number more digits.
  #
  # @return [RubySpeech::GRXML::Grammar] a grammar for interpreting a numeric value.
  #
  def self.number(options = nil)
    RubySpeech::GRXML.draw mode: :dtmf, root: 'number' do
      rule id: 'number', scope: 'public' do
        one_of do
          item { ruleref uri: '#less_than_one' }
          item { ruleref uri: '#one_or_more' }
        end
      end

      rule id: 'less_than_one' do
        item { '*' }
        item do
          ruleref uri: '#digit_series'
        end
      end

      rule id: 'one_or_more' do
        item do
          ruleref uri: '#digit_series'
        end
        item repeat: '0-1' do
          item { '*' }
          item repeat: '0-1' do
            ruleref uri: '#digit_series'
          end
        end
      end

      rule id: 'digit_series' do
        item repeat: '1-' do
          ruleref uri: '#digit'
        end
      end

      rule id: 'digit' do
        one_of do
          0.upto(9) { |d| item { d.to_s } }
        end
      end
    end
  end

  #
  # Create a grammar for interpreting a phone number. Uses '*' to represent 'x' for a number with an extension.
  #
  # @return [RubySpeech::GRXML::Grammar] a grammar for interpreting a phone number.
  #
  def self.phone(options = nil)
    RubySpeech::GRXML.draw mode: :dtmf, root: 'number' do
      rule id: 'number', scope: 'public' do
        item repeat: '1-' do
          ruleref uri: '#digit'
        end
        item repeat: '0-1' do
          item { '*' }
          item repeat: '0-' do
            ruleref uri: '#digit'
          end
        end
      end

      rule id: 'digit' do
        one_of do
          0.upto(9) { |d| item { d.to_s } }
        end
      end
    end
  end

  #
  # Create a grammar for interpreting a time.
  #
  # @return [RubySpeech::GRXML::Grammar] a grammar for interpreting a time.
  #
  def self.time(options = nil)
    RubySpeech::GRXML.draw mode: :dtmf, root: 'time' do
      rule id: 'time', scope: 'public' do
        item repeat: '1-4' do
          one_of do
            0.upto(9) { |d| item { d.to_s } }
          end
        end
      end
    end
  end
end
