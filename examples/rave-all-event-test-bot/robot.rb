require 'rubygems'
require 'rave'

module RaveAllEventTestBot
  class Robot < Rave::Models::Robot
    
    SPELLY_ID = 'spelly@gwave.com'
    DELETE_COMMAND = 'DELETE'
    INVITE_COMMAND = 'INVITE'
    TEXTILE_COMMAND = 'TEXTILE'
    HTML_COMMAND = 'HTML'
    KICK_COMMAND = 'KICK'
    TITLE_COMMAND = 'TITLE'
    WAVELET_COMMAND = 'PRIVATE'

    # Reply to the blip the event was generated by.
    def reply_blip(event, message, options = {})
      blip = event.blip.create_child_blip
      blip.append_text(message, options)
    end

    # Reply to the wavelet the event was generated by.
    def reply_wavelet(event, message, options = {})
      blip = event.wavelet.create_blip
      blip.append_text(message, options)
    end
    
    def wavelet_self_added(event, context)
      message =<<-MESSAGE
Hello everyone, I am #{name} (#{id})!
* My project can be found on <a href="http://github.com/diminish7/rave">Github</a>.
* I like to comment on what people are doing (creating, submitting and deleting blips).
* I will say hello and goodbye as people arrive or leave the wave.
* Submit a blip:
  * containing only "#{DELETE_COMMAND}" and I'll delete it for you.
  * containing "#{INVITE_COMMAND} fish@frog.com" to invite that user/robot into the wavelet.
  * containing "#{KICK_COMMAND} fish@appspot.com" to kick a robot from the wavelet.
  * containing "#{WAVELET_COMMAND} fish@cheese.com, frog@peas.com" start a wavelet with these users.
  * containing "#{TITLE_COMMAND} new-title" to change the wavelet's title.
  * starting with "#{TEXTILE_COMMAND}" or "#{HTML_COMMAND}" to convert the markup to properly styled text.
MESSAGE

      reply_wavelet(event, message, :format => :html)
    end

    # BUG: Never received.
    def wavelet_self_removed(event, context)
      reply_wavelet(event, "Goodbye world!")
    end
    
    def wavelet_participants_changed(event, context)
      event.participants_added.each do |user|
        reply_wavelet(event, "Hello #{user.name}!") unless user == self
      end
      
      event.participants_removed.each do |user|
        reply_wavelet(event, "Goodbye #{user.name}!") unless user == self
      end
    end

    # BUG: Only seems to get sent if robot is invited into a new wave on creation.
    def wavelet_blip_created(event, context)
      blip = event.blip.append_inline_blip
      blip.append_text("#{event.modified_by.name} created a new blip! I _would_ have done it better, though!", :format => :textile)
    end

    # BUG: Never received.
    def wavelet_blip_removed(event, context)
      reply_wavelet(event, "#{event.modified_by.name} removed a blip from the wavelet! Absolute power, eh?")
    end

    def blip_deleted(event, context)
      reply_wavelet(event, "#{event.modified_by.name} deleted a blip! _Which one will be next?_", :format => :textile)
    end

    def blip_submitted(event, context)
      case event.blip.content
      when /^#{DELETE_COMMAND}\s*$/
        if event.blip.root?
          reply_blip(event, "Silly #{event.modified_by.name}! I can't delete the root blip, can I?")
        else
          event.blip.delete
        end

      when /^#{TITLE_COMMAND}\s+/
        title = $'
        event.wavelet.title = title

      when /^#{WAVELET_COMMAND}\s+/
        participants = $'.strip.split(/\s*,\s*/) + [event.modified_by]
        create_wavelet(participants)
        reply_wavelet(event, "Created wavelet with #{participants.join(", ")}")

      when /^#{INVITE_COMMAND}\s+([\w\-\.]+@[\w\-\.]+)\s*$/
        invited = $1
        user = event.wavelet.participants.find { |u| u.id == invited }
        message = if user
         "Can't add #{user.name} since they are already here!"
        else
          event.wavelet.add_participant(invited)
          "#{invited} added!"
        end
        reply_wavelet(event, message)

      when /^#{KICK_COMMAND}\s+([\w\-\.]+@[\w\-\.]+)\s*$/
        kicked = $1
        user = event.wavelet.participants.find { |u| u.id == kicked }
        message = if user
          if user.robot?
            event.wavelet.remove_participant(user)
            "#{user.name} kicked!"
          else
            "Can't remove #{user.name} since they are not a robot!"
          end
        else
          "Can't remove #{user.name} since they are not here!"
        end
        reply_wavelet(event, message)

      when /^#{KICK_COMMAND}\s*$/
        reply_wavelet(event, "I know when I'm not wanted!")
        event.wavelet.remove_robot

      when /^#{TEXTILE_COMMAND}\s+/
        # Parse and stylise textile.
        event.blip.set_text($', :format => :textile) unless $'.empty?

      when /^#{HTML_COMMAND}\s+/
        # Parse and stylise HTML.
        event.blip.set_text($', :format => :html) unless $'.empty?
        
      else
        reply_blip(event, "#{event.modified_by.name} submitted a blip! Show off!")
      end
    end

    # BUG: Never received.
    def wavelet_title_changed(event, context)
      reply_wavelet(event, "#{event.modified_by.name} changed the title to: #{event.title}")
    end
    
    def document_changed(event, context)
      return if [SPELLY_ID, id].include? event.modified_by.id
      # Do something about it
    end

    def wavelet_created(event, context)
      reply_wavelet(event, "Created a new wavelet")
    end

    def operation_error(error, context)
      reply_wavelet(error, "Error: #{error.message} (#{error.operation_type}) at #{error.operation_timestamp}")
    end
  end
end