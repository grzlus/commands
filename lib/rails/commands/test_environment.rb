require 'rails/commands/environment'

module Rails
  module Commands
    module TestEnvironment
      extend self
    
      def fork( detected_folder )
        Environment.fork do
          setup_for_test( detected_folder )
          yield
        end
        
        reset_active_record
      end


      private
        def setup_for_test( detected_folder )
          reload_classes        
          add_test_dir_to_load_path( detected_folder )
        end

        def reload_classes
          # Overwrite the default config.cache_classes = true,
          # so we can change classes in the test session.
          ActiveSupport::Dependencies.mechanism = :load

          ActionDispatch::Reloader.cleanup!
          ActionDispatch::Reloader.prepare!
        end

        def reset_active_record
          if defined? ActiveRecord
            ActiveRecord::Base.clear_active_connections!
            ActiveRecord::Base.establish_connection
          end
        end
      
        def add_test_dir_to_load_path( detected_folder )
          test_path = Rails.root.join( detected_folder )
          $:.unshift(test_path) unless $:.first == test_path
        end
    end
  end
end
