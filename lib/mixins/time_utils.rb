module Rave
  module Mixins
    module TimeUtils
      
      def time_from_json(time)
        if time
          time_s = time.to_s
          epoch = if time_s.length > 10
            "#{time_s[0, 10]}.#{time_s[10..-1]}".to_f
          else
            time.to_i
          end
          Time.at(epoch)
        end
      end
      
    end
  end
end