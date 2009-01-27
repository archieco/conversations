module Conversations

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval  do
      def default_url_options(options={})
        options.merge({:cid => @conversation_id})
      end
      before_filter :set_conversation_id_from_params
      include InstanceMethods
    end
  end
  
  module ClassMethods

    protected

    def conversation(options)
      before_filter :create_conversation, :only => [options[:start]]
      after_filter :end_conversation, :only => [options[:end]]
    end

  end

  module InstanceMethods
    
    def conversation
      raise "conversation has not been started" if @conversation_id.nil?
      session[@conversation_id] ||= HashWithIndifferentAccess.new
    end
  
    def create_conversation
      @conversation_id = Digest::MD5.hexdigest(request.path + Time.new.to_s)
    end
  
    def destroy_converstation
      session.delete @conversation_id
      @conversation_id = nil
    end
  
    def set_conversation_id_from_params
      @conversation_id = params[:cid]
      default_url_options[:cid] = @conversation_id
    end
  
  end
end
