require "json"

if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__
  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

@time_start = Time.now.getutc

@length = ARGV[0].to_i
@locale = ARGV[1]
@typo_per_line = ARGV[2].to_i
@typo_per_result = ((ARGV[2].to_f % 1)*@length).round

@file = File.open("./lib/locales/#{@locale}.json", "r:UTF-8", &:read)
@data = JSON.parse @file
@address = @data['address']
@name = @data['name']
@additional = @data['additional']
@phone_pattern = @additional['phonenumber']

@result = []

@length.times do 
  @address_arr = []
  @name_arr = []
  @phone_arr = Marshal.load( Marshal.dump( @phone_pattern.sample.split('') ) )

  @address.each { | key, value |
  if (value[0] == '#') then
    if (rand(2) == 1 && key == 'build_num') then 
      @chars = ['-', '/', ' '];
      @address_arr.push(rand(250), @chars.sample, @additional['postfix'].sample)
    else
      @address_arr.push(rand(250))
    end
  else
    @address_arr.push(value.sample)
  end

  if (key.include? 'prefix') then
    @address_arr.push(' ')
  else
    @address_arr.push(', ')
  end
  }

  @name[@name.keys.sample].each_value { | value |
      @name_arr.push(value.sample)
  }

  @phone_arr.each_with_index { | value, index |
  if (value === '#') then
    @phone_arr[index] = rand(9)
  end
  }

  @pre_result = [@name_arr.join(' '), @address_arr.join, @phone_arr.join('')]
  @del_state = 1 # To keep balace. +1: delete char, -1: paste char

  def getMistake (str)
    @mistake = rand(str.length - 3) + 1;
    case (rand(1))
      when 0 # delete or paste char
        @del_state *= -1;
        return "#{str[0...@mistake]}#{str[(@mistake + @del_state)...str.length]}";
      when 1 # change order
        return "#{str[0...@mistake]}#{str[@mistake+1]}#{str[@mistake]}#{str[(@mistake+2)...str.length]}";
      end
  end

  if (@typo_per_line > 0) then
    @typo_per_line.times do 
      @typo_index = rand(@pre_result.length)
      @pre_result[@typo_index] = getMistake(@pre_result[@typo_index])
    end
  end

  if (@typo_per_result > 0 && (rand() > 0.7 || (@length - @result.length) < @typo_per_result) ) then
    @typo_index = rand(@pre_result.length)
      @pre_result[@typo_index] = getMistake(@pre_result[@typo_index])
    @typo_per_result -=1
  end
  @result.push(@pre_result.join(' | '))
end

# @result.each { |x| puts x }

p "Generate in #{Time.now.getutc - @time_start}ms"