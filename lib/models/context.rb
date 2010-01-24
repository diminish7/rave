module Rave
  module Models
    # Contains server request information including current waves and operations.
    class Context

      attr_reader :primary_wavelet # :nodoc: API users should use Event#wavelet
      attr_reader :robot # The robot managing this context.

      # All waves by ID [Hash of String => Wave]
      def waves # :nodoc:
        @waves.dup
      end

      # All wavelets by ID [Hash of String => Wavelet]
      def wavelets # :nodoc:
        @wavelets.dup
      end

      # All wavelets by ID [Hash of String => Wavelet]
      def blips # :nodoc:
        @blips.dup
      end

      # All operations [Array of Operation]
      def operations # :nodoc:
        @operations.dup
      end

      # All users by ID [Hash of String => User]
      def users # :nodoc:
        @users.dup
      end
      
      JAVA_CLASS = 'com.google.wave.api.impl.OperationMessageBundle' # :nodoc:
      
      #Options include:
      # - :waves
      # - :wavelets
      # - :blips
      # - :operations
      # - :users
      def initialize(options = {}) # :nodoc:
        @waves = options[:waves] || {}
        @waves.values.each { |wave| wave.context = self }          #Set up self as this wave's context

        @wavelets = options[:wavelets] || {}
        @wavelets.values.each { |wavelet| wavelet.context = self } #Set up self as this wavelet's context
        @primary_wavelet = @wavelets.values[0] # As opposed to any that are created later.

        
        @blips = options[:blips] || {}
        @blips.values.each { |blip| blip.context = self }          #Set up self as this blip's context
        
        @operations = options[:operations] || []
        
        @users = options[:users] || {}
        @users.values.each { |user| user.context = self }          #Set up self as this user's context

        resolve_user_references(options[:robot])
      end

    protected
      # Create users for every reference to one in the wave.
      def resolve_user_references(robot) # :nodoc:
        if robot
          @users[robot.id] = robot
          robot.context = self
          @robot = robot
        end
        
        @wavelets.each_value do |wavelet|
          wavelet.participant_ids.each do |id|
            unless @users[id]
              add_user(:id => id)
            end
          end
          
          unless @users[wavelet.creator_id]
            add_user(:id => wavelet.creator_id)
          end
        end
        
        @blips.each_value do |blip|
          blip.contributor_ids.each do |id|
            unless @users[id]
              add_user(:id => id)
            end
          end
        end
      end

    public
      # Add a blip to blips (Use an Operation to actually add the blip to the Wave).
      # Returns: The blip [Blip].
      def add_blip(blip) # :nodoc:
        @blips[blip.id] = blip
        blip.context = self
        blip
      end

      # Add an operation to the list to be executed.
      # Returns: self [Context]
      def add_operation(options) # :nodoc:
        @operations << Operation.new(options)
        self
      end

      # Add a wavelet to wavelets (Use an Operation to actually add the blip to the Wave).
      # Returns: The wavelet [Wavelet].
      def add_wavelet(wavelet)# :nodoc:
        @wavelets[wavelet.id] = wavelet
        wavelet.context = self
        wavelet
      end

      # Add a wave to waves (Use an Operation to actually add the wave).
      # Returns: The wave [Wave].
      def add_wave(wave)# :nodoc:
        @waves[wave.id] = wave
        wave.context = self
        wave
      end

      # +participants+:: Participants to exist in the new wavelet, as IDs or objects [Array of String/User]
      # Returns: Newly created wave [Wave]
      def create_wavelet(participants) # :nodoc:
        # Map participants to strings, since they could be Users.
        participant_ids = participants.map {|p| p.to_s.downcase }
        participant_ids << @robot.id unless participant_ids.include? @robot.id
        
        wavelet = Wavelet.new(:context => self, :participants => participant_ids)
        add_wavelet(wavelet)

        # TODO: Get wave id from sensible place?
        add_operation(:type => Operation::WAVELET_CREATE, :wave_id => @waves.keys[0],
          :property => wavelet)

        wavelet
      end

      # Remove a blip.
      def remove_blip(blip) # :nodoc:
        @blips.delete(blip.id)
      end

      # Add a user to users (Use an Operation to actually add the blip to the Wave).
      def add_user(options) # :nodoc:
        options[:id].downcase! if options[:id]
        raise DuplicatedIDError.new("Can't add another User with id #{options[:id]}") if @users.has_key? options[:id].downcase
        user = User.new(options)
        @users[user.id] = user
        user.context = self
        user
      end
           
      #Serialize the context for use in the line protocol.
      def to_json # :nodoc:
        hash = {
          'operations' => { 'javaClass' => 'java.util.ArrayList', 'list' => @operations },
          'javaClass' => JAVA_CLASS
        }
        hash.to_json
      end

      def print_structure(indent = 0) # :nodoc:
        str = ''
        waves.each_value do |wave|
          str << wave.print_structure(indent)
        end
        str
      end
    end
  end
end
